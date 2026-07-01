import { IsString, IsIn } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class SelectRoleDto {
    @ApiProperty({
        description: 'The active role the user wants to switch/log in to',
        enum: ['ADMIN', 'SELLER', 'BUYER', 'DRIVER'],
        example: 'BUYER',
    })
    @IsString()
    @IsIn(['ADMIN', 'SELLER', 'BUYER', 'DRIVER'])
    activeRole!: string;
}