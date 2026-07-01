import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { DiscountType } from '@prisma/client';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateDiscountDto {
    @ApiProperty({
        description: 'The unique alphanumeric discount code',
        example: 'DISCOUNT50',
    })
    @IsString()
    @IsNotEmpty()
    code!: string;

    @ApiProperty({
        description: 'The type of discount (PROMO or VOUCHER)',
        enum: DiscountType,
        example: 'PROMO',
    })
    @IsEnum(DiscountType)
    @IsNotEmpty()
    type!: DiscountType;

    @ApiProperty({
        description: 'The discount value/amount',
        minimum: 1,
        example: 50000,
    })
    @IsNumber({ maxDecimalPlaces: 2 })
    @Min(1)
    amount!: number;

    @ApiProperty({
        description: 'The expiration date and time of the discount',
        type: String,
        format: 'date-time',
        example: '2026-12-31T23:59:59Z',
    })
    @IsNotEmpty()
    @Type(() => Date)
    expiryDate!: Date;

    @ApiPropertyOptional({
        description: 'Remaining number of times this discount can be used',
        minimum: 1,
        example: 100,
    })
    @IsNumber()
    @Min(1)
    @IsOptional()
    remainingUsage?: number;
}