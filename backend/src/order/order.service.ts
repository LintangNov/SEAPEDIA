import { BadRequestException, ConflictException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CheckoutDto } from './dto/checkout.dto';
import { DeliveryMethod, Prisma } from '@prisma/client';

@Injectable()
export class OrderService {
    constructor(private prisma: PrismaService) {}

    async checkout(buyerId: string, dto: CheckoutDto) {
        return this.prisma.$transaction(async (tx) => {
            const cart = await tx.cart.findUnique({
                where: { buyerId },
                include: { items: { include: { product: true } } },
            });

            if (!cart || cart.items.length === 0 || !cart.sellerId) {
                throw new BadRequestException("Your cart is empty or invalid.");
            }

            const buyerProfile = await tx.buyerProfile.findUnique({ where: { userId: buyerId } });
            if (!buyerProfile) throw new BadRequestException("Buyer profile not found.");

            let subtotal = new Prisma.Decimal(0);
            for (const item of cart.items) {
                if (item.product.stock < item.quantity) {
                    throw new ConflictException(`Insufficient stock for product: ${item.product.name}`);
                }
                const itemTotal = new Prisma.Decimal(item.product.price).mul(item.quantity);
                subtotal = subtotal.add(itemTotal);
            }

            let discountAmount = new Prisma.Decimal(0);
            let appliedDiscountId: string | null = null;

            if (dto.discountCode) {
                const discount = await tx.discount.findUnique({ where: { code: dto.discountCode } });
                if (!discount) throw new BadRequestException("Invalid discount code.");
                if (new Date() > discount.expiryDate) throw new BadRequestException("Discount code has expired.");
                
                if (discount.type === 'VOUCHER' && discount.remainingUsage !== null) {
                    if (discount.remainingUsage <= 0) throw new BadRequestException("Voucher usage limit reached.");
                    await tx.discount.update({
                        where: { id: discount.id },
                        data: { remainingUsage: { decrement: 1 } }
                    });
                }
                discountAmount = discount.amount;
                appliedDiscountId = discount.id;
            }

            let discountedSubtotal = subtotal.sub(discountAmount);
            if (discountedSubtotal.lessThan(0)) discountedSubtotal = new Prisma.Decimal(0);

            let deliveryFeeAmount = 0;
            switch (dto.deliveryMethod) {
                case DeliveryMethod.INSTANT: deliveryFeeAmount = 20000; break;
                case DeliveryMethod.NEXT_DAY: deliveryFeeAmount = 15000; break;
                case DeliveryMethod.REGULAR: deliveryFeeAmount = 10000; break;
            }
            const deliveryFee = new Prisma.Decimal(deliveryFeeAmount);
            
            const taxAmount = discountedSubtotal.mul(0.12); 
            const finalTotal = discountedSubtotal.add(deliveryFee).add(taxAmount);

            if (new Prisma.Decimal(buyerProfile.walletBalance).lessThan(finalTotal)) {
                throw new ConflictException("Insufficient wallet balance.");
            }

            await tx.buyerProfile.update({
                where: { userId: buyerId },
                data: {
                    walletBalance: { decrement: finalTotal },
                    deliveryAddress: dto.deliveryAddress,
                }
            });

            await tx.walletTransaction.create({
                data: { buyerId, amount: finalTotal, type: 'CHECKOUT', description: 'Order Checkout' }
            });

            for (const item of cart.items) {
                await tx.product.update({
                    where: { id: item.productId },
                    data: { stock: { decrement: item.quantity } }
                });
            }

            const order = await tx.order.create({
                data: {
                    buyerId,
                    sellerId: cart.sellerId,
                    subtotal,
                    discountId: appliedDiscountId,
                    discountAmount,
                    deliveryFee,
                    taxAmount,
                    finalTotal,
                    deliveryMethod: dto.deliveryMethod,
                    status: 'SEDANG_DIKEMAS',
                    items: {
                        create: cart.items.map(item => ({
                            productId: item.productId,
                            quantity: item.quantity,
                            priceAtPurchase: item.product.price,
                        }))
                    },
                    statusHistory: { create: [{ status: 'SEDANG_DIKEMAS' }] }
                }
            });

            await tx.cartItem.deleteMany({ where: { cartId: cart.id } });
            await tx.cart.update({ where: { id: cart.id }, data: { sellerId: null } });

            return { message: "Checkout successful", orderId: order.id, finalTotal: finalTotal.toNumber() };
        }, { isolationLevel: Prisma.TransactionIsolationLevel.Serializable, maxWait: 5000, timeout: 10000 });
    }

    async processSellerOrder(sellerId: string, orderId: string) {
        return this.prisma.$transaction(async (tx) => {
            const order = await tx.order.findUnique({ where: { id: orderId } });

            if (!order) throw new NotFoundException("Order not found.");
            if (order.sellerId !== sellerId) throw new ForbiddenException("You don't own this order.");
            if (order.status !== 'SEDANG_DIKEMAS') throw new BadRequestException("Order cannot be processed.");

            const updatedOrder = await tx.order.update({
                where: { id: orderId },
                data: { status: 'MENUNGGU_PENGIRIM' },
            });

            await tx.orderStatusHistory.create({
                data: { orderId: order.id, status: 'MENUNGGU_PENGIRIM' }
            });

            return { message: "Order processed to MENUNGGU_PENGIRIM", data: updatedOrder };
        }, { isolationLevel: Prisma.TransactionIsolationLevel.Serializable });
    }

    async getSellerOrders(sellerId: string) {
        const orders = await this.prisma.order.findMany({
            where: { sellerId },
            include: { items: { include: { product: { select: { name: true } } } }, statusHistory: true },
            orderBy: { createdAt: 'desc' }
        });
        return { message: "Seller orders retrieved", data: orders };
    }

    async getBuyerOrders(buyerId: string) {
        const orders = await this.prisma.order.findMany({
            where: { buyerId },
            include: { items: { include: { product: { select: { name: true } } } }, statusHistory: true, seller: { select: { storeName: true } } },
            orderBy: { createdAt: 'desc' }
        });
        return { message: "Buyer orders retrieved", data: orders };
    }
}