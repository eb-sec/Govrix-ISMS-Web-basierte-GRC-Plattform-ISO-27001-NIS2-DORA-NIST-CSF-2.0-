import { Controller, Get, Query } from '@nestjs/common';
import { AuditService } from './audit.service';

const DEMO_TENANT = '00000000-0000-0000-0000-000000000001';

@Controller('audit')
export class AuditController {
  constructor(private readonly service: AuditService) {}

  // GET /api/v1/audit?limit=50
  @Get()
  getLog(@Query('limit') limit?: string) {
    return this.service.getLog(DEMO_TENANT, limit ? parseInt(limit) : 50);
  }
}
