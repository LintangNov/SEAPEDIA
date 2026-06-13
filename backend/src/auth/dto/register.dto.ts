import { IsString, MinLength, IsArray, ArrayNotEmpty, IsIn } from 'class-validator';

export class RegisterDto{
    @IsString()
    @MinLength(3)
    username!: string;

    @IsString()
    @MinLength(6)
    password!: string;

    @IsArray()
    @ArrayNotEmpty()

    @IsIn(['SELLER', 'BUYER', 'DRIVER'], {each:true})
    roles!: string[];
}