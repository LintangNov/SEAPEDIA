import { IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateUsernameDto {
    @ApiProperty({
        description: 'The updated unique username of the user',
        minLength: 3,
        example: 'john_doe_new',
    })
    @IsString()
    @MinLength(3)
    username!: string;
}