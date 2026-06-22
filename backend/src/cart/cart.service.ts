import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class CartService {
    constructor(private prisma: PrismaService){}
    
    async addToCart(buyerId: string, productId: string, quantity: number) {
        if (quantity<=0) throw new ConflictException("Quantity must be greater than zero");

        return this.prisma.$transaction(async (tx) => {
            const product = await tx.product.findUnique({
                where: {id: productId},
                select: {id: true, sellerId: true, stock: true},
            });

            if (!product) throw new NotFoundException("Product not found");
            if (product.stock < quantity) throw new ConflictException("Insufficient stock");

            let cart = await tx.cart.upsert({
                where: {buyerId},
                update: {},
                create: {buyerId},
            });
            
            if (cart.sellerId && cart.sellerId !== product.sellerId){
                throw new ConflictException("Single-store checkout rule: Your cart contains products from another store. Please clear your cart first.");

            }

            if (!cart.sellerId) {
                cart = await tx.cart.update({
                    where: {id: cart.id},
                    data: { sellerId: product.sellerId},
                });
            }

            const cartItem = await tx.cartItem.upsert({
                where: {
                    cartId_productId: { cartId: cart.id, productId: product.id },
                },
                update: { quantity: { increment: quantity } },
                create: {
                    cartId: cart.id,
                    productId: product.id,
                    quantity: quantity,
                },
            });
            return {message: "Product added to cart", cartItem};
            
        },
        {
            isolationLevel: Prisma.TransactionIsolationLevel.Serializable
        }
    );  
    }

    async removeCartItem(buyerId: string, cartItemId: string) {
        return this.prisma.$transaction(async (tx) =>{
            const cart = await tx.cart.findUnique({
                where: {buyerId},
                include: {items: true}
            });

            if (!cart) throw new NotFoundException("Cart not found");

            await tx.cartItem.delete({
                where: {id: cartItemId}
            });

            if (cart.items.length === 1 && cart.items[0].id === cartItemId) {
                await tx.cart.update({
                    where: { id: cart.id },
                    data: { sellerId: null },
                });
            }

            return {message: "Item removed from cart"};
            
        });
    }
}