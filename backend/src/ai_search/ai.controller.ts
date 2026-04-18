import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiBearerAuth,
  ApiInternalServerErrorResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AiService } from './ai.service';
import { AiSearchRequestDto } from './dto/ai-search-request.dto';
import { AiSearchResponseDto } from './dto/ai-search-response.dto';

@ApiTags('ai')
@ApiBearerAuth()
@Controller('ai')
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Get('health')
  @ApiOperation({ summary: 'AI search module health check' })
  health() {
    return this.aiService.health();
  }

  @Post('search')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'AI roommate search endpoint with hybrid scoring and pgvector-optimized semantic retrieval',
  })
  @ApiOkResponse({ type: AiSearchResponseDto })
  @ApiBadRequestResponse({ description: 'Invalid request payload' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid JWT token' })
  @ApiInternalServerErrorResponse({ description: 'AI search execution failed' })
  async search(
    @CurrentUser() user: { id: string },
    @Body() body: AiSearchRequestDto,
  ): Promise<AiSearchResponseDto> {
    return this.aiService.search(user.id, body);
  }
}
