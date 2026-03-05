import { Controller, Post, Body } from '@nestjs/common';
import { AiService } from './ai.service';

export class AiAnalysisDto {
  prompt: string;
  max_tokens?: number;
}

@Controller('ai')
export class AiController {
  constructor(private aiService: AiService) {}

  @Post('analyse')
  async analyse(@Body() dto: AiAnalysisDto) {
    return this.aiService.analyse(dto.prompt, dto.max_tokens);
  }
}
