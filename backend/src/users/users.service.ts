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

        return {
            message: "Profile successfully retrieved",
            profile: {
                sub: user.id,
                username: user.username,
                activeRole: activeRole,
                roles: user.roles.map(ur => ur.role.name),
            }
        };
    }
}