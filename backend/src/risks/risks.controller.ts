import { Controller, Get, Post, Put, Body, Param, Query, Request, UseGuards } from '@nestjs/common';
import { RisksService } from './risks.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

const DEMO_TENANT = '00000000-0000-0000-0000-000000000001';

@Controller('risks')
@UseGuards(JwtAuthGuard)
export class RisksController {
  constructor(private readonly service: RisksService) {}

  @Get()
  getRisks(@Query('status') status?: string) {
    return this.service.getRisks(DEMO_TENANT, status);
  }

  @Get('stats')
  getStats() {
    return this.service.getRiskStats(DEMO_TENANT);
  }

  @Post()
  createRisk(@Body() body: any, @Request() req: any) {
    const userId    = req.user?.sub   || null;
    const userEmail = req.user?.email || 'system';
    const ip        = req.ip || req.headers?.['x-forwarded-for'] || null;
    return this.service.createRisk(DEMO_TENANT, body, userId, userEmail, ip);
  }

  @Put(':id')
  updateRisk(@Param('id') id: string, @Body() body: any, @Request() req: any) {
    const userEmail = req.user?.email || 'system';
    const ip        = req.ip || req.headers?.['x-forwarded-for'] || null;
    return this.service.updateRisk(DEMO_TENANT, id, body, userEmail, ip);
  }
}
