import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class AuditService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  async log(params: {
    tenantId:   string;
    userId?:    string;
    userEmail:  string;
    eventType:  string;
    entityType?: string;
    entityId?:   string;
    oldValue?:   Record<string, any>;
    newValue?:   Record<string, any>;
    ipAddress?:  string;
    userAgent?:  string;
  }) {
    try {
      await this.db.query(
        `INSERT INTO audit_log
           (tenant_id, user_id, user_email, event_type, entity_type, entity_id,
            old_value, new_value, ip_address, user_agent)
         VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9::inet,$10)`,
        [
          params.tenantId,
          params.userId    || null,
          params.userEmail,
          params.eventType,
          params.entityType || null,
          params.entityId   || null,
          params.oldValue   ? JSON.stringify(params.oldValue) : null,
          params.newValue   ? JSON.stringify(params.newValue) : null,
          params.ipAddress  || null,
          params.userAgent  || null,
        ]
      );
    } catch (e) {
      console.warn('Audit-Log Fehler:', e.message);
    }
  }

  async getLog(tenantId: string, limit: number = 50) {
    const result = await this.db.query(
      `SELECT * FROM audit_log WHERE tenant_id = $1 ORDER BY created_at DESC LIMIT $2`,
      [tenantId, limit]
    );
    return result.rows;
  }
}
