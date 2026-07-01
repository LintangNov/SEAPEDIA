import { IsString, IsNotEmpty, IsOptional, IsNumber, Min, IsInt, IsIn } from "class-validator";
import { Type } from "class-transformer";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateProductDto{
    @ApiProperty({
        description: 'The name of the product',
        example: 'Ergonomic Office Chair',
    })
    @IsString()
    @IsNotEmpty()
    name!: string;

    @ApiPropertyOptional({
        description: 'The detailed description of the product',
        example: 'A comfortable ergonomic office chair with lumbar support and adjustable armrests.',
    })
    @IsString()
    @IsOptional()
    description?:string;

    @ApiProperty({
        description: 'The price of the product (maximum 2 decimal places)',
        minimum: 0,
        example: 1500000,
    })
    @IsNumber({maxDecimalPlaces: 2})
    @Min(0)
    @Type(() => Number)
    price!: number;

    @ApiProperty({
        description: 'The inventory/stock count of the product',
        minimum: 0,
        example: 50,
    })
    @IsInt()
    @Min(0)
    @Type(() => Number)
    stock!: number;
}