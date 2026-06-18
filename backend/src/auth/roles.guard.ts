import { Reflector } from "@nestjs/core";
import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from "@nestjs/common";
import { ROLES_KEY } from "./roles.decorator";
import { Observable } from "rxjs";

@Injectable()
export class RolesGuard implements CanActivate {
    constructor(private reflector: Reflector){}

    canActivate(context: ExecutionContext): boolean {
        const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
            context.getHandler(),
            context.getClass(),
        ]);

        if(!requiredRoles){
            return true;
        }

        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (!user || !user.activeRole){
            throw new ForbiddenException("Active role not found in session. Please select a role.");

        }

        if(!requiredRoles.includes(user.activeRole)){
            throw new ForbiddenException(`Access denied. Requires one of the following roles: ${requiredRoles.join(', ')}`);
            
        }

        return true;
    }
}