import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from './common/database.module';
import { HealthModule } from './health/health.module';
import { ControlsModule } from './controls/controls.module';
import { RisksModule } from './risks/risks.module';
import { ActionsModule } from './actions/actions.module';
import { AuditModule } from './audit/audit.module';
import { AuthModule } from './auth/auth.module';
import { AiModule } from './ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    DatabaseModule,
    HealthModule,
    ControlsModule,
    RisksModule,
    ActionsModule,
    AuditModule,
    AuthModule,
    AiModule,
  ],
})
export class AppModule {}
