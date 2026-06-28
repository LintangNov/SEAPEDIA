import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { SchedulerService } from '../scheduler/scheduler.service';

@Injectable()
export class AdminService {
    constructor(private prisma: PrismaService, private scheduler: SchedulerService) {}

    async getMonitoringData() {
        const [users, stores, products, orders, returnedOrders, autoRefunds, discounts, activeDeliveries] = await Promise.all([
            this.prisma.user.count(),
            this.prisma.sellerProfile.count({ where: { storeName: { not: null } } }),
            this.prisma.product.count(),
            this.prisma.order.count(),
            this.prisma.order.count({ where: { status: 'RETURNED' } }),
            this.prisma.walletTransaction.count({ where: { type: 'REFUND', description: { contains: 'overdue' } } }),
            this.prisma.discount.count(),
            this.prisma.deliveryJob.count({ where: { completedAt: null } })
        ]);

        return {
            message: "Monitoring data retrieved",
            data: { totalUsers: users, totalStores: stores, totalProducts: products, totalOrders: orders, totalReturnedOrders: returnedOrders, totalAutoRefunds: autoRefunds, totalDiscounts: discounts, activeDeliveries }
        };
    }

    async triggerOverdueSimulation(daysToAdvance: number) {
        const simulatedTime = new Date();
        simulatedTime.setDate(simulatedTime.getDate() + daysToAdvance);

        await this.scheduler.processOverdueOrders(simulatedTime);
        return { message: `Simulated overdue check for time: ${simulatedTime.toISOString()}` };
    }
}
