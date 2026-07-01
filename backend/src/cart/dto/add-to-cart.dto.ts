import { IsString, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AddToCartDto {
    @ApiProperty({
        description: 'The UUID of the product to add to the cart',
        example: '5f9f1b9b-b9b9-4b9b-8b9b-9b9b9b9b9b9b',
    })
    @IsString()
    productId!: string;

    @ApiProperty({
        description: 'The quantity of the product to add',
        minimum: 1,
        example: 2,
    })
    @IsInt()
    @Min(1)
    quantity!: number;
}