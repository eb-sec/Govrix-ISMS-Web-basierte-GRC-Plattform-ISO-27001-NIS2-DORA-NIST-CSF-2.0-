import { Controller, Get, Post, Put, Body, Param, Query } from '@nestjs/common';
import { RisksService } from './risks.service';

const DEMO_TENANT = '00000000-0000-0000-0000-000000000001';
const DEMO_USER   = '10000000-0000-0000-0000-000000000001';

@Controller('risks')
export class RisksController {
  constructor(private readonly service: RisksService) {}

  // GET /api/v1/risks
  @Get()
  getRisks(@Query('status') status?: string) {
    return this.service.getRisks(DEMO_TENANT, status);
  }

  // GET /api/v1/risks/stats
  @Get('stats')
  getStats() {
    return this.service.getRiskStats(DEMO_TENANT);
  }

  // POST /api/v1/risks
  @Post()
  createRisk(@Body() body: any) {
    return this.service.createRisk(DEMO_TENANT, body, DEMO_USER);
  }

  // PUT /api/v1/risks/:id
  @Put(':id')
  updateRisk(@Param('id') id: string, @Body() body: any) {
    return this.service.updateRisk(DEMO_TENANT, id, body);
  }
}
