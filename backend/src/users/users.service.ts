import { Injectable, ConflictException, InternalServerErrorException } from "@nestjs/common";
import { PrismaService } from "../prisma.service";
import { UpdateStoreDto } from "./dto/update-store.dto";

@Injectable()
export class UsersService{
    constructor(private readonly prisma: PrismaService){}

    async updateStoreProfile(userId: string, dto: UpdateStoreDto){
        try {
            const profile = await this.prisma.sellerProfile.upsert({
                where: { userId},
                update: {storeName: dto.storeName},
                create: { userId, storeName: dto.storeName},
            });

            return {
                message: "Store profile updated successfully",
                data: profile,
            };
        } catch (error: any){
            if (error.code === 'P2002' && error.meta?.target?.includes('store_name')) {
                throw new ConflictException(`Store name '${dto.storeName}' is already taken.`);
                
            }
            throw new InternalServerErrorException("An error occurred while updating store profile.");
            
        }
    }

    async getUserProfile(userId: string, activeRole: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { roles: { include: { role: true } } }
        });

        if (!user) throw new InternalServerErrorException("User not found");

        let walletBalance = 0;
        let storeName: string | null = null;

        if (user.roles.some(ur => ur.role.name === 'BUYER')) {
            const buyerProfile = await this.prisma.buyerProfile.findUnique({
                where: { userId }
            });
            if (buyerProfile) {
                walletBalance = Number(buyerProfile.walletBalance);
            }
        }

        if (user.roles.some(ur => ur.role.name === 'SELLER')) {
            const sellerProfile = await this.prisma.sellerProfile.findUnique({
                where: { userId }
            });
            if (sellerProfile) {
                storeName = sellerProfile.storeName;
            }
        }

        return {
            message: "Profile successfully retrieved",
            profile: {
                sub: user.id,
                username: user.username,
                email: user.email,
                phoneNumber: user.phoneNumber,
                activeRole: activeRole,
                roles: user.roles.map(ur => ur.role.name),
                walletBalance: walletBalance,
                storeName: storeName
            }
        };
    }

    async updateUsername(userId: string, newUsername: string) {
        try {
            const updatedUser = await this.prisma.user.update({
                where: { id: userId },
                data: { username: newUsername }
            });
            return { message: "Username updated successfully", data: updatedUser.username };
        } catch (error: any) {
            if (error.code === 'P2002') {
                throw new ConflictException(`Username '${newUsername}' is already taken.`);
            }
            throw new InternalServerErrorException("An error occurred while updating username.");
        }
    }
}