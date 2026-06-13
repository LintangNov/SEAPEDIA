import { Injectable, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from "./dto/register.dto";

@Injectable()
export class AuthService {
    constructor(private readonly prisma: PrismaService) {}

    async register(dto:RegisterDto) {
        const existingUser = await this.prisma.user.findUnique({
            where: { username: dto.username },
        });

        if (existingUser){
            throw new ConflictException("Username was registered");
            
        }

        const saltRounds =10;
        const hashedPassword = await bcrypt.hash(dto.password, saltRounds);

        const roleConnectors = dto.roles.map((roleName) => ({
            role: { connect: { name: roleName }},
        }));

        const user = await this.prisma.user.create({
            data: {
                username: dto.username,
                passwordHash: hashedPassword,
                roles: {
                    create: roleConnectors,
                },
            },
            include: {
                roles: {
                    include: { role: true }
                }
            }
        });

        delete (user as any).passwordHash;
        
        return {
            id: user.id,
            username: user.username,
            roles: user.roles.map(ur => ur.role.name),
            createdAt: user.createdAt,
        };
    }
}