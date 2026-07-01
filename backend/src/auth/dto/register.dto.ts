import { IsString, MinLength, IsArray, ArrayNotEmpty, IsIn, IsEmail } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto{
    @ApiProperty({
        description: 'The unique username of the user',
        minLength: 3,
        example: 'john_doe',
    })
    @IsString()
    @MinLength(3)
    username!: string;

    @ApiProperty({
        description: 'The email address of the user',
        example: 'john.doe@example.com',
    })
    @IsEmail({}, { message: 'Invalid email format' })
    email!: string;

    @ApiProperty({
        description: 'The contact phone number of the user',
        minLength: 8,
        example: '081234567890',
    })
    @IsString()
    @MinLength(8, { message: 'Phone number must be at least 8 characters' })
    phoneNumber!: string;

    @ApiProperty({
        description: 'The password of the user',
        minLength: 6,
        example: 'password123',
    })
    @IsString()
    @MinLength(6)
    password!: string;

    @ApiProperty({
        description: 'The roles assigned to the user',
        type: [String],
        enum: ['SELLER', 'BUYER', 'DRIVER'],
        example: ['BUYER'],
    })
    @IsArray()
    @ArrayNotEmpty()
    @IsIn(['SELLER', 'BUYER', 'DRIVER'], {each:true})
    roles!: string[];
}