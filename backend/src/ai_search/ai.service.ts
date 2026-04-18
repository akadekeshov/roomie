import { Injectable } from '@nestjs/common';
import { AiSearchService } from './ai-search.service';
import { AiSearchRequestDto } from './dto/ai-search-request.dto';
import { AiSearchResponseDto } from './dto/ai-search-response.dto';

@Injectable()
export class AiService {
  constructor(private readonly aiSearchService: AiSearchService) {}

  async search(
    userId: string,
    dto: AiSearchRequestDto,
  ): Promise<AiSearchResponseDto> {
    return this.aiSearchService.search(userId, dto);
  }

  health() {
    return {
      module: 'ai_search',
      status: 'ok',
      stage: 6,
    };
  }
}
