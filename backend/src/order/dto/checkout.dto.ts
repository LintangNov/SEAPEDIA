import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { DeliveryMethod } from '@prisma/client';

export class CheckoutDto {
    @IsEnum(DeliveryMethod)
    @IsNotEmpty()
    deliveryMethod!: DeliveryMethod;

    @IsString()
    @IsNotEmpty()
    deliveryAddress!: string;

    @IsString()
    @IsOptional()
    discountCode?: string;
}