import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateListingDto } from './dto/create-listing.dto';
import { UpdateListingDto } from './dto/update-listing.dto';
import { QueryListingDto } from './dto/query-listing.dto';
import { FilterListingDto } from './dto/filter-listing.dto';

@Injectable()
export class ListingsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, createListingDto: CreateListingDto) {
    const listing = await this.prisma.listing.create({
      data: {
        ...createListingDto,
        availableFrom: createListingDto.availableFrom
          ? new Date(createListingDto.availableFrom)
          : null,
        availableTo: createListingDto.availableTo
          ? new Date(createListingDto.availableTo)
          : null,
        ownerId: userId,
      },
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
    });

    return listing;
  }

  async findAll(queryDto: QueryListingDto) {
    const {
      page = 1,
      limit = 10,
      city,
      state,
      roomType,
      minPrice,
      maxPrice,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = queryDto;

    const skip = (page - 1) * limit;

    const where: any = {};

    if (city) {
      where.city = { contains: city, mode: 'insensitive' };
    }

    if (state) {
      where.state = { contains: state, mode: 'insensitive' };
    }

    if (roomType) {
      where.roomType = roomType;
    }

    if (minPrice !== undefined || maxPrice !== undefined) {
      where.price = {};
      if (minPrice !== undefined) {
        where.price.gte = minPrice;
      }
      if (maxPrice !== undefined) {
        where.price.lte = maxPrice;
      }
    }

    const orderBy: any = {};
    orderBy[sortBy] = sortOrder;

    const [listings, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        skip,
        take: limit,
        orderBy,
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
      }),
      this.prisma.listing.count({ where }),
    ]);

    return {
      data: listings,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async filter(queryDto: FilterListingDto) {
    const {
      page = 1,
      limit = 20,
      city,
      priceMin,
      priceMax,
      gender,
      petsPreference,
      smokingPreference,
      noisePreference,
      roomType,
      availableFrom,
      availableTo,
    } = queryDto;

    const safePage = page < 1 ? 1 : page;
    const safeLimit = Math.min(Math.max(limit, 1), 100);
    const skip = (safePage - 1) * safeLimit;

    const where: any = {};

    if (city) {
      where.city = { contains: city, mode: 'insensitive' };
    }

    if (roomType) {
      where.roomType = roomType;
    }

    if (priceMin !== undefined || priceMax !== undefined) {
      where.price = {};
      if (priceMin !== undefined) {
        where.price.gte = priceMin;
      }
      if (priceMax !== undefined) {
        where.price.lte = priceMax;
      }
    }

    if (availableFrom || availableTo) {
      const availabilityCondition: any = {};

      if (availableFrom) {
        availabilityCondition.availableFrom = {
          gte: new Date(availableFrom),
        };
      }

      if (availableTo) {
        availabilityCondition.availableTo = {
          lte: new Date(availableTo),
        };
      }

      if (Object.keys(availabilityCondition).length > 0) {
        if (!where.AND) {
          where.AND = [];
        }
        where.AND.push(availabilityCondition);
      }
    }

    if (gender || petsPreference || smokingPreference || noisePreference) {
      where.owner = {};

      if (gender) {
        where.owner.gender = gender;
      }

      if (petsPreference) {
        where.owner.petsPreference = petsPreference;
      }

      if (smokingPreference) {
        where.owner.smokingPreference = smokingPreference;
      }

      if (noisePreference) {
        where.owner.noisePreference = noisePreference;
      }
    }

    const orderBy: any = { createdAt: 'desc' };

    const [listings, total] = await Promise.all([
      this.prisma.listing.findMany({
        where,
        skip,
        take: safeLimit,
        orderBy,
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
      }),
      this.prisma.listing.count({ where }),
    ]);

    return {
      data: listings,
      meta: {
        page: safePage,
        limit: safeLimit,
        total,
        totalPages: total === 0 ? 0 : Math.ceil(total / safeLimit),
      },
    };
  }

  async findOne(id: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
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
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    return listing;
  }

  async update(id: string, updateListingDto: UpdateListingDto) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    const updateData: any = { ...updateListingDto };

    if (updateListingDto.availableFrom) {
      updateData.availableFrom = new Date(updateListingDto.availableFrom);
    }

    if (updateListingDto.availableTo) {
      updateData.availableTo = new Date(updateListingDto.availableTo);
    }

    const updatedListing = await this.prisma.listing.update({
      where: { id },
      data: updateData,
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
    });

    return updatedListing;
  }

  async remove(id: string) {
    const listing = await this.prisma.listing.findUnique({
      where: { id },
    });

    if (!listing) {
      throw new NotFoundException('Listing not found');
    }

    await this.prisma.listing.delete({
      where: { id },
    });

    return { message: 'Listing deleted successfully' };
  }
}
