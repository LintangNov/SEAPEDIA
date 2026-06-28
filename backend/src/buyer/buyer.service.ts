import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { describe } from 'node:test';

@Injectable()
export class BuyerService {
    constructor(private prisma: PrismaService) { }

    async ensureBuyerProfile(userId: string) {
        return this.prisma.buyerProfile.upsert({
            where: { userId },
            update: {},
            create: { userId },
        });
    }

    async topUp(userId: string, amount: number) {
        if (amount <= 0) throw new BadRequestException("Amount must be greater than zero");

        await this.ensureBuyerProfile(userId);

        const result = await this.prisma.$transaction(async (tx) => {
            const updatedProfile = await tx.buyerProfile.update({
                where: { userId },
                data: { walletBalance: { increment: amount } }
            });

            const history = await tx.walletTransaction.create({
                data: {
                    buyerId: userId,
                    amount: amount,
                    type: 'TOP_UP',
                    description: 'Top Diamond FF',
                },
            });

            return { updatedProfile, history };
        });

        return {
            message: "Top-up successfull",
            balance: result.updatedProfile.walletBalance,
        };
    }

    async getWalletHistory(userId: string) {
        const history = await this.prisma.walletTransaction.findMany({
            where: { buyerId: userId },
            orderBy: { createdAt: 'desc' }
        });
        return { message: "Wallet history retrieved", data: history };
    }
}
