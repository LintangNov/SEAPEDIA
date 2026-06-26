import { IsString, MinLength } from "class-validator";

export class LoginDto {
    @IsString()
    @MinLength(6)
    password!: string;

    @IsString()
    @MinLength(6)
    username!: string;
}