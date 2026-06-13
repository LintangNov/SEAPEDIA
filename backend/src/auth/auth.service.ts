import { Injectable, ConflictException, UnauthorizedException, BadGatewayException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
    constructor(private readonly prisma: PrismaService, private readonly jwtService: JwtService) {}

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
                },
            }
        });
        return { message: "Registration success", userId: user.id};

        delete (user as any).passwordHash;
        
        return {
            id: user.id,
            username: user.username,
            roles: user.roles.map(ur => ur.role.name),
            createdAt: user.createdAt,
        };
    }

    async login(dto: LoginDto) {
        const user = await this.prisma.user.findUnique({
            where: { username: dto.username },
            include: { roles: { include: { role: true } } }
        });

        if (!user){
            throw new UnauthorizedException("Invalid credential");
            
        }

        const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
        if (!isPasswordValid) {
            throw new UnauthorizedException("Invalid credential");
        }

        const userRoles = user.roles.map(ur => ur.role.name);

        const payload = { sub: user.id, username: user.username, roles: userRoles };
        const accessToken = await this.jwtService.signAsync(payload);

        return {
            message: "Login successful. Please choose your active role.",
            accessToken,
            availableRole: userRoles
        };
    }

    async selectRole(userId: string, requestedRole: string){
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { roles: { include: { role: true } } }
        });

        if (!user) throw new UnauthorizedException("User not found");

        const userRoles = user.roles.map(ur => ur.role.name);
        if(!userRoles.includes(requestedRole)){
            throw new BadRequestException(`You don't have access to ${requestedRole} role`);

        }

        const payload = { sub: user.id, username: user.username, activeRole: requestedRole};
        const finalAccessToken = await this.jwtService.signAsync(payload);

        return {
            message: `Active role set to ${requestedRole}`,
            accessToken: finalAccessToken
        }
    }
}