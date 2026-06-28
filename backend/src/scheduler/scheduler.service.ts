import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma.service';

@Injectable()
export class SchedulerService {
    private readonly logger = new Logger(SchedulerService.name);

    constructor(private prisma: PrismaService) {}

    @Cron(CronExpression.EVERY_MINUTE)
    async handleCron() {
        this.logger.debug('Running Cron Job: Checking for Overdue Orders...');
        await this.processOverdueOrders(new Date());
    }

    async processOverdueOrders(currentTime: Date) {
        const activeOrders = await this.prisma.order.findMany({
            where: {
                status: {
                    in: ['BEING_PACKED', 'AWAITING_SHIPMENT', 'BEING_SHIPPED']
                }
            },
            include: { items: true }
        });

        for (const order of activeOrders) {
            let slaHours = 120; // 5 days
            if (order.deliveryMethod === 'INSTANT') slaHours = 24;
            else if (order.deliveryMethod === 'NEXT_DAY') slaHours = 48;

            const deadline = new Date(order.createdAt.getTime() + (slaHours * 60 * 60 * 1000));

            if (currentTime > deadline) {
                this.logger.log(`Order ${order.id} has exceeded the SLA. Processing refund...`);
                try {
                    await this.prisma.$transaction(async (tx) => {
                        const currentOrder = await tx.order.findUnique({ where: { id: order.id } });
                        if (!currentOrder || currentOrder.status === 'RETURNED' || currentOrder.status === 'ORDER_COMPLETED') {
                            return; 
                        }

                        await tx.order.update({
                            where: { id: order.id },
                            data: { status: 'RETURNED' }
                        });

                        await tx.orderStatusHistory.create({
                            data: { orderId: order.id, status: 'RETURNED' }
                        });

                        await tx.buyerProfile.update({
                            where: { userId: order.buyerId },
                            data: { walletBalance: { increment: order.finalTotal } }
                        });

                        await tx.walletTransaction.create({
                            data: {
                                buyerId: order.buyerId,
                                amount: order.finalTotal,
                                type: 'REFUND',
                                description: `Auto-refund Overdue orders (SLA ${order.deliveryMethod})`
                            }
                        });

                        for (const item of order.items) {
                            await tx.product.update({
                                where: { id: item.productId },
                                data: { stock: { increment: item.quantity } }
                            });
                        }

                        await tx.deliveryJob.deleteMany({
                            where: { orderId: order.id, completedAt: null }
                        });
                        
                    });
                    this.logger.log(`Atomic refund successful for order ${order.id}`);
                } catch (error) {
                    this.logger.error(`Failed to process the refund for order ${order.id}`, error);
                }
            }
        }
    }
}