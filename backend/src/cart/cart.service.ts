import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class CartService {
    constructor(private prisma: PrismaService) {}

    async getCart(buyerId: string) {
        const cart = await this.prisma.cart.findUnique({
            where: { buyerId },
            include: {
                items: {
                    include: {
                        product: {
                            select: { name: true, price: true }
                        }
                    }
                }
            }
        });

        if (!cart) {
            throw new NotFoundException("Cart not found");
        }

        return { 
            message: "Cart retrieved successfully", 
            data: cart 
        };
    }

    async addToCart(buyerId: string, productId: string, quantity: number) {
        if (quantity <= 0) {
            throw new ConflictException("Quantity must be greater than zero");
        }

        return this.prisma.$transaction(async (tx) => {
            const product = await tx.product.findUnique({
                where: { id: productId },
                select: { id: true, sellerId: true, stock: true },
            });

            if (!product) throw new NotFoundException("Product not found");
            if (product.stock < quantity) throw new ConflictException("Insufficient stock");

            await tx.buyerProfile.upsert({
                where: {userId: buyerId},
                update: {},
                create: {userId: buyerId}
            });

            let cart = await tx.cart.upsert({
                where: { buyerId },
                update: {},
                create: { buyerId },
            });

            if (cart.sellerId && cart.sellerId !== product.sellerId) {
                throw new ConflictException("Single-store checkout rule: Your cart contains products from another store. Please clear your cart first.");
            }

            if (!cart.sellerId) {
                cart = await tx.cart.update({
                    where: { id: cart.id },
                    data: { sellerId: product.sellerId },
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

            return { message: "Product added to cart", data: cartItem };
        }, 
        { 
            isolationLevel: Prisma.TransactionIsolationLevel.Serializable 
        });
    }

    async updateCartItemQuantity(buyerId: string, cartItemId: string, quantity: number) {
        return this.prisma.$transaction(async (tx) => {
            const cart = await tx.cart.findUnique({
                where: { buyerId },
                include: { items: { include: { product: true } } }
            });

            if (!cart) throw new NotFoundException("Cart not found");

            const item = cart.items.find(i => i.id === cartItemId);
            if (!item) throw new NotFoundException("Item not found in cart");

            if (item.product.stock < quantity) {
                throw new ConflictException(`Only ${item.product.stock} items left in stock`);
            }

            const updatedItem = await tx.cartItem.update({
                where: { id: cartItemId },
                data: { quantity: quantity }
            });

            return { message: "Quantity updated", data: updatedItem };
        });
    }

    async removeCartItem(buyerId: string, cartItemId: string) {
        return this.prisma.$transaction(async (tx) => {
            const cart = await tx.cart.findUnique({
                where: { buyerId },
                include: { items: true },
            });

            if (!cart) throw new NotFoundException("Cart not found");

            const itemExists = cart.items.find(i => i.id === cartItemId);
            if (!itemExists) throw new NotFoundException("Item not found in cart");

            await tx.cartItem.delete({
                where: { id: cartItemId },
            });

            if (cart.items.length === 1 && cart.items[0].id === cartItemId) {
                await tx.cart.update({
                    where: { id: cart.id },
                    data: { sellerId: null },
                });
            }

            return { message: "Item removed from cart" };
        });
    }

    async clearCart(buyerId: string) {
        return this.prisma.$transaction(async (tx) => {
            const cart = await tx.cart.findUnique({
                where: { buyerId }
            });

            if (!cart) return { message: "Cart is already empty" };

            await tx.cartItem.deleteMany({
                where: { cartId: cart.id }
            });

            await tx.cart.update({
                where: { id: cart.id },
                data: { sellerId: null }
            });

            return { message: "Cart cleared successfully" };
        });
    }
}