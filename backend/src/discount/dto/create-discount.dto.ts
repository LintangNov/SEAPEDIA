import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { DiscountType } from '@prisma/client';
import { Type } from 'class-transformer';

export class CreateDiscountDto {
    @IsString()
    @IsNotEmpty()
    code!: string;

    @IsEnum(DiscountType)
    @IsNotEmpty()
    type!: DiscountType;

    @IsNumber({ maxDecimalPlaces: 2 })
    @Min(1)
    amount!: number;

    @IsNotEmpty()
    @Type(() => Date)
    expiryDate!: Date;

    @IsNumber()
    @Min(1)
    @IsOptional()
    remainingUsage?: number;
}