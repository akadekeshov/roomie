import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { ListingsService } from './listings.service';
import { CreateListingDto } from './dto/create-listing.dto';
import { UpdateListingDto } from './dto/update-listing.dto';
import { QueryListingDto } from './dto/query-listing.dto';
import { FilterListingDto } from './dto/filter-listing.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { OwnershipGuard } from '../common/guards/ownership.guard';

@ApiTags('listings')
@Controller('listings')
@ApiBearerAuth()
export class ListingsController {
  constructor(private readonly listingsService: ListingsService) {}

  @Get('filter')
  @ApiOperation({
    summary:
      'Filter listings by city, price range and roommate preferences (owner)',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    example: 1,
    description: 'Page number (starting from 1)',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    example: 20,
    description: 'Items per page (max 100)',
  })
  @ApiQuery({
    name: 'city',
    required: false,
    type: String,
    example: 'Almaty',
  })
  @ApiQuery({
    name: 'priceMin',
    required: false,
    type: Number,
    example: 50000,
  })
  @ApiQuery({
    name: 'priceMax',
    required: false,
    type: Number,
    example: 150000,
  })
  @ApiQuery({
    name: 'roomType',
    required: false,
    type: String,
    example: 'SINGLE',
    description: 'Room type',
  })
  @ApiQuery({
    name: 'availableFrom',
    required: false,
    type: String,
    example: '2026-03-15',
    description: 'Minimum available from date (ISO string)',
  })
  @ApiQuery({
    name: 'availableTo',
    required: false,
    type: String,
    example: '2026-04-01',
    description: 'Maximum available to date (ISO string)',
  })
  @ApiQuery({
    name: 'gender',
    required: false,
    type: String,
    example: 'FEMALE',
    description: 'Owner gender',
  })
  @ApiQuery({
    name: 'petsPreference',
    required: false,
    type: String,
    example: 'WITH_PETS',
  })
  @ApiQuery({
    name: 'smokingPreference',
    required: false,
    type: String,
    example: 'NON_SMOKER',
  })
  @ApiQuery({
    name: 'noisePreference',
    required: false,
    type: String,
    example: 'QUIET',
  })
  @ApiResponse({
    status: 200,
    description: 'Filtered listings with pagination meta',
  })
  async filter(@Query() queryDto: FilterListingDto) {
    return this.listingsService.filter(queryDto);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new listing' })
  @ApiResponse({ status: 201, description: 'Listing created successfully' })
  async create(
    @CurrentUser() user: any,
    @Body() createListingDto: CreateListingDto,
  ) {
    return this.listingsService.create(user.id, createListingDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all listings with filters and pagination' })
  @ApiResponse({ status: 200, description: 'Listings retrieved successfully' })
  async findAll(@Query() queryDto: QueryListingDto) {
    return this.listingsService.findAll(queryDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get listing by ID' })
  @ApiResponse({ status: 200, description: 'Listing found' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  async findOne(@Param('id') id: string) {
    return this.listingsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(OwnershipGuard)
  @ApiOperation({ summary: 'Update listing (owner only)' })
  @ApiResponse({ status: 200, description: 'Listing updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  async update(
    @Param('id') id: string,
    @Body() updateListingDto: UpdateListingDto,
  ) {
    return this.listingsService.update(id, updateListingDto);
  }

  @Delete(':id')
  @UseGuards(OwnershipGuard)
  @ApiOperation({ summary: 'Delete listing (owner only)' })
  @ApiResponse({ status: 200, description: 'Listing deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - not the owner' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  async remove(@Param('id') id: string) {
    return this.listingsService.remove(id);
  }
}
