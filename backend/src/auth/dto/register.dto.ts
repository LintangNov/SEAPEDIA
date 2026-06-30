import { IsString, MinLength, IsArray, ArrayNotEmpty, IsIn, IsEmail } from 'class-validator';

export class RegisterDto{
    @IsString()
    @MinLength(3)
    username!: string;

    @IsEmail({}, { message: 'Invalid email format' })
    email!: string;

    @IsString()
    @MinLength(8, { message: 'Phone number must be at least 8 characters' })
    phoneNumber!: string;

    @IsString()
    @MinLength(6)
    password!: string;

    @IsArray()
    @ArrayNotEmpty()
    @IsIn(['SELLER', 'BUYER', 'DRIVER'], {each:true})
    roles!: string[];
}