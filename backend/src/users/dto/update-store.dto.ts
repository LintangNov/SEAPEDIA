import { IsString, MinLength, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateStoreDto {
    @ApiProperty({
        description: 'The updated name of the store',
        minLength: 3,
        maxLength: 100,
        example: 'Super Seller Store',
    })
    @IsString()
    @MinLength(3)
    @MaxLength(100)
    storeName!: string;
}