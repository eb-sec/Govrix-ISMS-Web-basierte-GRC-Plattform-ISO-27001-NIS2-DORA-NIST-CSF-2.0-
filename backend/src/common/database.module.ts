import { Module, Global } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { Pool } from "pg";

export const DATABASE_POOL = "DATABASE_POOL";

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: DATABASE_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        return new Pool({
          connectionString: config.get<string>("DATABASE_URL"),
          ssl:
            config.get("NODE_ENV") === "production"
              ? { rejectUnauthorized: false }
              : false,
        });
      },
    },
  ],
  exports: [DATABASE_POOL],
})
export class DatabaseModule {}
