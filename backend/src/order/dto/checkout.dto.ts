import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { DeliveryMethod } from '@prisma/client';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CheckoutDto {
    @ApiProperty({
        description: 'The selected delivery method for the order',
        enum: DeliveryMethod,
        example: 'REGULAR',
    })
    @IsEnum(DeliveryMethod)
    @IsNotEmpty()
    deliveryMethod!: DeliveryMethod;

    @ApiProperty({
        description: 'The shipping address for the order delivery',
        example: 'Jl. Raya Salemba No. 4, Jakarta Pusat',
    })
    @IsString()
    @IsNotEmpty()
    deliveryAddress!: string;

    @ApiPropertyOptional({
        description: 'Optional discount/promo code to apply to the checkout',
        example: 'DISCOUNT50',
    })
    @IsString()
    @IsOptional()
    discountCode?: string;
}