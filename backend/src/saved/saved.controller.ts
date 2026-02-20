import { Controller, Get, Post, Delete, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { SavedService } from './saved.service';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('saved')
@Controller('saved')
@ApiBearerAuth()
export class SavedController {
  constructor(private readonly savedService: SavedService) {}

  @Post(':listingId')
  @ApiOperation({ summary: 'Save a listing' })
  @ApiResponse({ status: 201, description: 'Listing saved successfully' })
  @ApiResponse({ status: 404, description: 'Listing not found' })
  @ApiResponse({ status: 409, description: 'Listing already saved' })
  async saveListing(@CurrentUser() user: any, @Param('listingId') listingId: string) {
    return this.savedService.saveListing(user.id, listingId);
  }

  @Delete(':listingId')
  @ApiOperation({ summary: 'Unsave a listing' })
  @ApiResponse({ status: 200, description: 'Listing unsaved successfully' })
  @ApiResponse({ status: 404, description: 'Saved listing not found' })
  async unsaveListing(@CurrentUser() user: any, @Param('listingId') listingId: string) {
    return this.savedService.unsaveListing(user.id, listingId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all saved listings' })
  @ApiResponse({ status: 200, description: 'Saved listings retrieved successfully' })
  async getSavedListings(@CurrentUser() user: any) {
    return this.savedService.getSavedListings(user.id);
  }
}
