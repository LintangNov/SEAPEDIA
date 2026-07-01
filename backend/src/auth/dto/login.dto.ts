import { IsString, MinLength } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class LoginDto {
    @ApiProperty({
        description: 'The password of the user',
        minLength: 6,
        example: 'password123',
    })
    @IsString()
    @MinLength(6)
    password!: string;

    @ApiProperty({
        description: 'The unique username of the user',
        minLength: 6,
        example: 'john_doe',
    })
    @IsString()
    @MinLength(6)
    username!: string;
}