import { IsString, MinLength, MaxLength } from 'class-validator';

export class UpdateStoreDto {
    @IsString()
    @MinLength(3)
    @MaxLength(100)
    storeName!: string;
}