import { IsEnum, IsNotEmpty, IsString } from 'class-validator';
import { DeliveryMethod } from '@prisma/client';

export class CheckoutDto {
    @IsEnum(DeliveryMethod)
    @IsNotEmpty()
    deliveryMethod!: DeliveryMethod;

    @IsString()
    @IsNotEmpty()
    deliveryAddress!: string;
}