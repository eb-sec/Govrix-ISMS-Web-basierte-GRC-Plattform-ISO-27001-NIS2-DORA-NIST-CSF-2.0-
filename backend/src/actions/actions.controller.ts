import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
} from "@nestjs/common";
import { ActionsService } from "./actions.service";

const DEMO_TENANT = "00000000-0000-0000-0000-000000000001";

@Controller("actions")
export class ActionsController {
  constructor(private readonly service: ActionsService) {}

  @Get()
  getActions(@Query("status") status?: string) {
    return this.service.getActions(DEMO_TENANT, status);
  }

  @Post()
  createAction(@Body() body: any) {
    return this.service.createAction(DEMO_TENANT, body);
  }

  // PATCH /api/v1/actions/:id/status
  @Patch(":id/status")
  updateStatus(@Param("id") id: string, @Body("status") status: string) {
    return this.service.updateStatus(DEMO_TENANT, id, status);
  }
}
