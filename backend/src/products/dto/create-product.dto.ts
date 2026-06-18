import { IsString, IsNotEmpty, IsOptional, IsNumber, Min, IsInt, IsIn } from "class-validator";
import { Type } from "class-transformer";

export class CreateProductDto{
    @IsString()
    @IsNotEmpty()
    name!: string;

    @IsString()
    @IsOptional()
    description?:string;

    @IsNumber({maxDecimalPlaces: 2})
    @Min(0)
    @Type(() => Number)
    price!: number;

    @IsInt()
    @Min(0)
    @Type(() => Number)
    stock!: number;
}