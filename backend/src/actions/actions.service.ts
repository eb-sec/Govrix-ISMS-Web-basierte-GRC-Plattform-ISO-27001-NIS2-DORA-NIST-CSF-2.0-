import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class ActionsService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  async getActions(tenantId: string, status?: string) {
    const params: any[] = [tenantId];
    let filter = '';
    if (status) { params.push(status); filter = `AND a.status = $${params.length}`; }

    const result = await this.db.query(`
      SELECT
        a.*,
        u.display_name AS owner_name,
        r.title        AS risk_title,
        r.risk_ref
      FROM actions a
      LEFT JOIN users u  ON u.id = a.owner_id
      LEFT JOIN risks r  ON r.id = a.risk_id
      WHERE a.tenant_id = $1 ${filter}
      ORDER BY a.priority ASC, a.due_date ASC
    `, params);

    return result.rows;
  }

  async updateStatus(tenantId: string, id: string, status: string) {
    const result = await this.db.query(`
      UPDATE actions
      SET status = $3, closed_at = CASE WHEN $3 = 'done' THEN NOW() ELSE NULL END
      WHERE id = $1 AND tenant_id = $2
      RETURNING *
    `, [id, tenantId, status]);
    return result.rows[0];
  }

  async createAction(tenantId: string, dto: any) {
    const result = await this.db.query(`
      INSERT INTO actions (tenant_id, risk_id, title, description, priority, owner_id, due_date)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `, [tenantId, dto.risk_id || null, dto.title, dto.description || null,
        dto.priority || 2, dto.owner_id || null, dto.due_date || null]);
    return result.rows[0];
  }
}
