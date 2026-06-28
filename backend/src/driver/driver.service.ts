import { ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class DriverService {
    constructor(private prisma: PrismaService){}

    async ensureDriverProfile (userId: string) {
        return this.prisma.driverProfile.upsert({
            where: {userId},
            update: {},
            create: {userId}
        });
    }

    async getProfile(userId: string) {
        const profile = await this.ensureDriverProfile(userId);
        const activeJob = await this.prisma.deliveryJob.findFirst({
            where: {driverId: userId, completedAt: null},
            include: {order: true}
        });

        return {
            message: "Driver profile retrieved",
            data: {
                earnings: profile.earnings.toString(),
                activeJob
            }
        };
    }

    async getAvailableJobs() {
        const jobs = await this.prisma.order.findMany({
            where:{
                status: 'AWAITING_SHIPMENT',
                deliveryJob: null
            },
            include: {
                seller: {select: {storeName: true}},
                buyer: {select: {deliveryAddress: true}}
            },
            orderBy: {createdAt: 'asc'}
        });

        return {message: 'Available jobs retrieved', data: jobs};
    }

    async getJobDetail(orderId: string){
        const job = await this.prisma.order.findUnique({
            where: {id: orderId, status: 'AWAITING_SHIPMENT', deliveryJob: null},
            include: {
                items: {include: {product: {select: {name:true}}}},
                seller: {select: {storeName: true}},
                buyer: {select: {deliveryAddress: true}}
            }
        });

        if (!job) throw new NotFoundException("Job not found or has been taken by another driver.");

        return {message: "Job detail retrieved", data: job};
    }

    async takeJob(driverId: string, orderId: string) {
        await this.ensureDriverProfile(driverId);

        const activeJobs = await this.prisma.deliveryJob.count({
            where: {driverId, completedAt: null}
        });

        if (activeJobs > 0){
            throw new ConflictException("You already have an active delivery job. Complete it first.");
            
        }

        try {
            return await this.prisma.$transaction(async (tx) => {
                const order = await tx.order.findUnique({
                    where: {id: orderId},
                    include: {deliveryJob: true}
                });

                if (!order || order.status !== 'AWAITING_SHIPMENT' || order.deliveryJob) {
                    throw new ConflictException("Order is not available for delivery.");
                    
                }

                const deliveryJob = await tx.deliveryJob.create({
                    data: {
                        orderId: orderId,
                        driverId: driverId,
                        pickedUpAt: new Date()
                    }
                });

                await tx.order.update({
                    where: { id: orderId },
                    data: { status: 'BEING_SHIPPED' }
                });

                await tx.orderStatusHistory.create({
                    data: { orderId: orderId, status: 'BEING_SHIPPED' }
                });

                return { message: "Job taken successfully", data: deliveryJob };
            }, {isolationLevel: Prisma.TransactionIsolationLevel.Serializable});
        } catch (error: any) {
            if (error.code === 'P2002' && error.meta?.target?.includes('order_id')) {
                throw new ConflictException("Job has already been taken by another driver.");
            }
            throw error;
        }
    }

    async completeJob(driverId: string, orderId: string) {
        return await this.prisma.$transaction(async (tx) => {
            const job = await tx.deliveryJob.findUnique({
                where: {orderId: orderId},
                include: {order: true}
            });

            if (!job) throw new NotFoundException("Delivery job not found.");
            if (job.driverId !== driverId) throw new ForbiddenException("You don't own this job.");
            if (job.completedAt !== null || job.order.status !== 'BEING_SHIPPED') {
                throw new ConflictException("Job is already completed or not in shipping state.");
            }

            const completedJob = await tx.deliveryJob.update({
                where: {id: job.id},
                data: { completedAt: new Date() }
            });

            await tx.order.update({
                where: {id: orderId},
                data: {status: 'ORDER_COMPLETED'}
            });

            await tx.orderStatusHistory.create({
                data: {orderId: orderId, status: 'ORDER_COMPLETED'}
            });

            await tx.driverProfile.update({
                where: {userId: driverId},
                data: {earnings: {increment: job.order.deliveryFee}}
            });

            return {message: "Job completed successfuly", data: completedJob}
        }, {isolationLevel: Prisma.TransactionIsolationLevel.Serializable});
    }

    async getJobHistory(driverId: string) {
        const profile = await this.ensureDriverProfile(driverId);
        const history = await this.prisma.deliveryJob.findMany({
            where: { driverId, completedAt: { not: null } },
            include: {
                order: {
                    include: {
                        buyer: { select: { deliveryAddress: true } },
                        seller: { select: { storeName: true } }
                    }
                }
            },
            orderBy: { completedAt: 'desc' }
        });

        return {
            message: "Job history retrieved",
            summary: {
                totalEarnings: profile.earnings.toString()
            },
            data: history
        };
    }
}


