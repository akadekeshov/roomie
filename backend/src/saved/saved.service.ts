import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SavedService {
  constructor(private prisma: PrismaService) {}

  async saveListing(userId: string, listingId: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id: listingId },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    const existingSaved = await this.prisma.savedListing.findUnique({
      where: {
        userId_listingId: {
          userId,
          listingId,
        },
      },
    });

    if (existingSaved) {
      throw new ConflictException('Listing already saved');
    }

    const savedListing = await this.prisma.savedListing.create({
      data: {
        userId,
        listingId,
      },
      include: {
        listing: {
          include: {
            owner: {
              select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
              },
            },
          },
        },
      },
    });

    return savedListing;
  }

  async unsaveListing(userId: string, listingId: string) {
    const savedListing = await this.prisma.savedListing.findUnique({
      where: {
        userId_listingId: {
          userId,
          listingId,
        },
      },
    });

    if (!savedListing) {
      throw new NotFoundException('Saved listing not found');
    }

    await this.prisma.savedListing.delete({
      where: {
        userId_listingId: {
          userId,
          listingId,
        },
      },
    });

    return { message: 'Listing unsaved successfully' };
  }

  async getSavedListings(userId: string) {
    const savedListings = await this.prisma.savedListing.findMany({
      where: { userId },
      include: {
        listing: {
          include: {
            owner: {
              select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
              },
            },
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return savedListings;
  }
}
