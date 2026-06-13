import { IsString, IsIn } from "class-validator";

export class SelectRoleDto {
    @IsString()
    @IsIn(['ADMIN', 'SELLER', 'BUYER', 'DRIVER'])
    activeRole!: string;
}