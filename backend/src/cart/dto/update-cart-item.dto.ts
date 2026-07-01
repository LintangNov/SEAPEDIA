import { IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateCartItemDto {
    @ApiProperty({
        description: 'The updated quantity of the cart item',
        minimum: 1,
        example: 5,
    })
    @IsInt()
    @Min(1)
    quantity!: number;
}