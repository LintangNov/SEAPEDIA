import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
    constructor(private readonly prisma: PrismaService) {}

    async create(sellerId: string, dto: CreateProductDto) {
        const sellerProfile = await this.prisma.sellerProfile.findUnique({
            where: { userId: sellerId }
        });

        if (!sellerProfile || !sellerProfile.storeName) {
            throw new BadRequestException("You must complete your store profile (store name) before managing products.");
            
        }

        const product = await this.prisma.product.create({
            data: {
                sellerId: sellerId,
                name: dto.name,
                description: dto.description,
                price: dto.price,
                stock: dto.stock,
            }
        });

        return {
            message: "Product created succesfully",
            data: product,
        };
    }

    async findSellerProducts(sellerId: string) {
        const products = await this.prisma.product.findMany({
            where: {sellerId},
            orderBy: {createdAt: 'desc'}
        });
        return {
            message: "Your products retrieved successfully",
            data: products
        };
    }

    async update(sellerId: string, productId: string, dto: UpdateProductDto) {
        await this.verifyProductOwnership(sellerId, productId);

        const updatedProduct = await this.prisma.product.update({
            where: { id: productId },
            data: dto,
        });

        return { message: "Product updated successfully", data: updatedProduct };
    }

    async remove(sellerId: string, productId: string) {
        await this.verifyProductOwnership(sellerId, productId);

        await this.prisma.product.delete({
            where: { id: productId }
        });

        return { message: "Product deleted successfully" };
    }

    private async verifyProductOwnership(sellerId: string, productId: string) {
        const product = await this.prisma.product.findUnique({
            where: { id: productId },
            select: { sellerId: true }
        });

        if (!product) {
            throw new NotFoundException(`Product with ID: ${productId} not found`);
        }

        if (product.sellerId !== sellerId) {
            throw new ForbiddenException("You do not have permission to modify this product");
        }
    }

    async findAllPublic() {
        const products = await this.prisma.product.findMany({
            include: {
                seller: { select: { storeName: true } } // Sertakan info toko
            },
            orderBy: { createdAt: 'desc' }
        });

        return { message: "Product catalog successfully retrieved", data: products };
    }

    async findOnePublic(id: string) {
        const product = await this.prisma.product.findUnique({
            where: { id },
            include: {
                seller: { select: { storeName: true } }
            }
        });

        if (!product) throw new NotFoundException(`Product with ID: ${id} not found`);

        return { message: "Product detail successfully retrieved", data: product };
    }
}
