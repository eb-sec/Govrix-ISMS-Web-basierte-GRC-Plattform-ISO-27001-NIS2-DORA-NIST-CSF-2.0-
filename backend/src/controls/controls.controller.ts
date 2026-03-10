import { Controller, Get, Put, Body, Param, Query } from '@nestjs/common';
import { ControlsService } from './controls.service';

const DEMO_TENANT = '00000000-0000-0000-0000-000000000001';

@Controller('controls')
export class ControlsController {
  constructor(private readonly service: ControlsService) {}

  // ─── ISO 27001 ────────────────────────────────────────────────
  // GET /api/v1/controls/iso?category=O|P|F|T
  @Get('iso')
  getIsoControls(@Query('category') category?: string) {
    return this.service.getIsoControls(DEMO_TENANT, category);
  }

  // PUT /api/v1/controls/iso/:controlRef
  @Put('iso/:controlRef')
  updateIsoControl(@Param('controlRef') controlRef: string, @Body() body: any) {
    return this.service.updateIsoControl(DEMO_TENANT, controlRef, body);
  }

  // ─── NIST CSF 2.0 ─────────────────────────────────────────────
  // GET /api/v1/controls/nist?function=GV|ID|PR|DE|RS|RC
  @Get('nist')
  getNistControls(@Query('function') functionCode?: string) {
    return this.service.getNistControls(DEMO_TENANT, functionCode);
  }

  // GET /api/v1/controls/nist/score
  @Get('nist/score')
  getNistScore() {
    return this.service.getNistScore(DEMO_TENANT);
  }

  // PUT /api/v1/controls/nist/:subCode  (e.g. GV.OC-01)
  @Put('nist/:subCode')
  updateNistControl(@Param('subCode') subCode: string, @Body() body: any) {
    return this.service.updateNistControl(DEMO_TENANT, subCode, body);
  }

  // ─── NIS2 / DORA ──────────────────────────────────────────────
  // GET /api/v1/controls/nis2?framework=NIS2|DORA
  @Get('nis2')
  getNis2Requirements(@Query('framework') framework?: string) {
    return this.service.getNis2Requirements(DEMO_TENANT, framework);
  }

  // PUT /api/v1/controls/nis2/:reqRef  (e.g. NIS2-1, DORA-3)
  @Put('nis2/:reqRef')
  updateNis2Requirement(@Param('reqRef') reqRef: string, @Body() body: any) {
    return this.service.updateNis2Requirement(DEMO_TENANT, reqRef, body);
  }

  // ─── Combined Score ────────────────────────────────────────────
  // GET /api/v1/controls/score  (Dashboard: ISO + NIST + NIS2/DORA)
  @Get('score')
  getScore() {
    return this.service.getScore(DEMO_TENANT);
  }
}
