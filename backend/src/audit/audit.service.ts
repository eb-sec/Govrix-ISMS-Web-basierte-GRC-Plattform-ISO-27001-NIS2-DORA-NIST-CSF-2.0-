import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class AuditService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  async log(entry: {
    tenantId: string;
    userId?: string;
    userEmail?: string;
    eventType: string;
    entityType?: string;
    entityId?: string;
    oldValue?: any;
    newValue?: any;
  }) {
    await this.db.query(`
      INSERT INTO audit_log
        (tenant_id, user_id, user_email, event_type, entity_type, entity_id, old_value, new_value)
      VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb)
    `, [
      entry.tenantId, entry.userId || null, entry.userEmail || 'system',
      entry.eventType, entry.entityType || null, entry.entityId || null,
      entry.oldValue ? JSON.stringify(entry.oldValue) : null,
      entry.newValue ? JSON.stringify(entry.newValue) : null,
    ]);
  }

  async getLog(tenantId: string, limit = 50) {
    const result = await this.db.query(`
      SELECT
        al.id, al.event_type, al.entity_type, al.entity_id,
        al.old_value, al.new_value, al.user_email, al.created_at
      FROM audit_log al
      WHERE al.tenant_id = $1
      ORDER BY al.created_at DESC
      LIMIT $2
    `, [tenantId, limit]);

    return result.rows;
  }
}
