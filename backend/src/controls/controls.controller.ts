import { Controller, Get, Put, Body, Param, Query, Headers } from '@nestjs/common';
import { ControlsService } from './controls.service';

// Demo-Tenant-ID (später durch echten Auth-Guard ersetzen)
const DEMO_TENANT = '00000000-0000-0000-0000-000000000001';

@Controller('controls')
export class ControlsController {
  constructor(private readonly service: ControlsService) {}

  // GET /api/v1/controls/iso
  // Optional: ?category=O|P|F|T
  @Get('iso')
  getIsoControls(@Query('category') category?: string) {
    return this.service.getIsoControls(DEMO_TENANT, category);
  }

  // GET /api/v1/controls/score
  @Get('score')
  async getScore() {
    const [iso, nist] = await Promise.all([
      this.service.getIsoScore(DEMO_TENANT),
      this.service.getNistScore(DEMO_TENANT),
    ]);
    return { iso, nist };
  }

  // PUT /api/v1/controls/iso/:controlRef
  // Body: { status, completion_pct, notes?, evidence_url?, due_date? }
  @Put('iso/:controlRef')
  updateControl(
    @Param('controlRef') controlRef: string,
    @Body() body: any,
  ) {
    return this.service.updateIsoControl(DEMO_TENANT, controlRef, body);
  }
}
