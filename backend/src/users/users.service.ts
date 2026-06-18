import { Injectable, ConflictException, InternalServerErrorException } from "@nestjs/common";
import { PrismaService } from "../prisma.service";
import { UpdateStoreDto } from "./dto/update-store.dto";

@Injectable()
export class UserService{
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
}