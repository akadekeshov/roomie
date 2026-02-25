import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole } from '@prisma/client';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
<<<<<<< HEAD
=======
    // Skip role check for public endpoints
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

<<<<<<< HEAD
=======
    // If no roles required, allow access (endpoint is protected by JWT but no specific role needed)
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    if (!user || !user.role) {
      throw new ForbiddenException('User role not found');
    }

    const hasRole = requiredRoles.some((role) => user.role === role);

    if (!hasRole) {
      throw new ForbiddenException(
        'Insufficient permissions. Required roles: ' + requiredRoles.join(', '),
      );
    }

    return true;
  }
}
<<<<<<< HEAD

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
