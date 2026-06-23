import { BadRequestException, ConflictException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CheckoutDto } from './dto/checkout.dto';
import { DeliveryMethod, Prisma } from '@prisma/client';

@Injectable()
export class OrderService {
    constructor(private prisma: PrismaService) {}

    async checkout(buyerId: string, dto: CheckoutDto) {
        return this.prisma.$transaction(async (tx)=>{
            const cart = await tx.cart.findUnique({
                where: { buyerId },
                include: {
                    items: { include: { product: true } },
                },
            });

            if (!cart || cart.items.length === 0 || !cart.sellerId) {
                throw new BadRequestException("Your cart is empty or invalid.");
            }

            const sellerId = cart.sellerId;

            const buyerProfile = await tx.buyerProfile.findUnique({
                where: {userId: buyerId}
            });

            if (!buyerProfile){
                throw new BadRequestException("Buyer prohile not found.");
                
            }

            let subtotal = new Prisma.Decimal(0);
            
            for (const item of cart.items) {
                if (item.product.stock < item.quantity) {
                    throw new ConflictException(`Insufficient stock for product: ${item.product.name}`);
                }
                const itemTotal = new Prisma.Decimal(item.product.price).mul(item.quantity);
                subtotal = subtotal.add(itemTotal);
            }

            let deliveryFreeAmount = 0;
            switch (dto.deliveryMethod) {
                case DeliveryMethod.INSTANT:
                    deliveryFreeAmount = 20000;
                    break;
                case DeliveryMethod.NEXT_DAY:
                    deliveryFreeAmount = 15000;
                    break;
                case DeliveryMethod.REGULAR:
                    deliveryFreeAmount = 10000;
                    break;
            }

            const deliveryFee = new Prisma.Decimal(deliveryFreeAmount);

            const taxAmount = subtotal.mul(0.12);

            const discountAmount = new Prisma.Decimal(0);
            const finalTotal = subtotal.add(deliveryFee).add(taxAmount).sub(discountAmount);

            if (new Prisma.Decimal(buyerProfile.walletBalance).lessThan(finalTotal)){
                throw new ConflictException("Insufficient wallet balance for this transaction.");
                
            }

            await tx.buyerProfile.update({
                where: {userId: buyerId},
                data: {
                    walletBalance: {decrement: finalTotal},
                    deliveryAddress: dto.deliveryAddress,
                }
            });

            await tx.walletTransaction.create({
                data: {
                    buyerId,
                    amount: finalTotal,
                    type: 'CHECKOUT',
                    description: 'Checkout orger from store',
                }
            });

            const order = await tx.order.create({
                data: {
                    buyerId,
                    sellerId,
                    subtotal,
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
                    statusHistory: {
                        create: [{ status: 'SEDANG_DIKEMAS' }]
                    }
                }
            });

            for (const item of cart.items) {
                await tx.product.update({
                    where: {id: item.productId},
                    data: {stock: {decrement: item.quantity}}
                });
            }

            await tx.cartItem.deleteMany({where: {cartId: cart.id}});
            await tx.cart.update({
                where: {id: cart.id},
                data: {sellerId: null},
            });

            return {
                message: "Checkout successfull",
                orderId: order.id,
                finalTotal: finalTotal.toNumber()
            };
        },
        {
            isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
            maxWait: 5000,
            timeout: 1000,
        }
    );
    }
}
