import { Controller, Get, Post, Body } from '@nestjs/common';
import { OpenAIService } from './openai.service';
import { Public } from '../auth/public.decorator';

@Controller('ai')
export class AiController {
  constructor(private readonly openAIService: OpenAIService) {}

  @Public()
  @Get('test')
  async test() {
    const result = await this.openAIService.testChat();
    return { ok: true, result };
  }

  @Public()
  @Post('embed')
  async embed(@Body('text') text: string) {
    const embedding = await this.openAIService.createEmbedding(text);
    return {
      ok: true,
      length: embedding.length,
      preview: embedding.slice(0, 5),
    };
  }
}