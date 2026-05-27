import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { DisputesService } from './disputes.service';
import { CreateDisputeDto } from './dto/create-dispute.dto';
import { DisputeAdminQueryDto } from './dto/dispute-admin-query.dto';
import { ResolveDisputeDto } from './dto/resolve-dispute.dto';
import { UpdateDisputeStatusDto } from './dto/update-dispute-status.dto';

@ApiTags('disputes')
@ApiBearerAuth()
@Controller('disputes')
export class DisputesController {
  constructor(private readonly disputesService: DisputesService) {}

  @Post()
  @ApiOperation({ summary: 'Create dispute or complaint' })
  @ApiResponse({ status: 201, description: 'Dispute created successfully' })
  create(@CurrentUser() user: any, @Body() dto: CreateDisputeDto) {
    return this.disputesService.createDispute(dto, user);
  }

  @Get('my')
  @ApiOperation({ summary: 'Get disputes related to current user' })
  getMy(@CurrentUser() user: any) {
    return this.disputesService.getMyDisputes(user.id);
  }

  @Get('admin/all')
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @ApiOperation({ summary: 'Get all disputes for admin moderation' })
  getAllForAdmin(@Query() query: DisputeAdminQueryDto) {
    return this.disputesService.getAllDisputes(query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get dispute details' })
  getById(@CurrentUser() user: any, @Param('id') id: string) {
    return this.disputesService.getDisputeById(id, user);
  }

  @Patch('admin/:id/resolve')
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @ApiOperation({ summary: 'Resolve dispute and apply moderation consequence' })
  resolve(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: ResolveDisputeDto,
  ) {
    return this.disputesService.resolveDispute(id, dto, user);
  }

  @Patch('admin/:id/status')
  @Roles(UserRole.ADMIN, UserRole.MODERATOR)
  @ApiOperation({ summary: 'Legacy dispute status update for admin web compatibility' })
  updateStatus(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateDisputeStatusDto,
  ) {
    return this.disputesService.updateDisputeStatusLegacy(id, dto, user);
  }
}
