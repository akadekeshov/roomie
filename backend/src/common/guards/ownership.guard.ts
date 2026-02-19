import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class OwnershipGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const listingId = request.params.id;

    if (!user || !listingId) {
      throw new ForbiddenException('Access denied');
    }

    const listing = await this.prisma.listing.findUnique({
      where: { id: listingId },
      select: { ownerId: true },
    });

    if (!listing) {
      throw new ForbiddenException('Listing not found');
    }

    if (listing.ownerId !== user.id) {
      throw new ForbiddenException('You do not have permission to access this resource');
    }

    return true;
  }
}
