import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class RisksService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  async getRisks(tenantId: string, status?: string) {
    const params: any[] = [tenantId];
    let statusFilter = '';
    if (status) {
      params.push(status);
      statusFilter = `AND r.status = $${params.length}`;
    }

    const result = await this.db.query(`
      SELECT
        r.*,
        u.display_name AS owner_name,
        a.name         AS asset_name,
        a.category     AS asset_category
      FROM risks r
      LEFT JOIN users u ON u.id = r.owner_id
      LEFT JOIN assets a ON a.id = r.asset_id
      WHERE r.tenant_id = $1 ${statusFilter}
      ORDER BY r.risk_score DESC
    `, params);

    return result.rows;
  }

  async createRisk(tenantId: string, dto: any, createdBy: string) {
    // Fortlaufende Referenznummer generieren
    const countResult = await this.db.query(
      'SELECT COUNT(*) FROM risks WHERE tenant_id = $1', [tenantId]
    );
    const count = parseInt(countResult.rows[0].count) + 1;
    const year = new Date().getFullYear();
    const riskRef = `RIS-${year}-${String(count).padStart(3, '0')}`;

    const result = await this.db.query(`
      INSERT INTO risks (
        tenant_id, risk_ref, title, description,
        asset_id, iso_control_ref, nist_sub_code,
        likelihood, impact, treatment, status,
        owner_id, due_date, created_by
      ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,'open',$11,$12,$13)
      RETURNING *
    `, [
      tenantId, riskRef, dto.title, dto.description || null,
      dto.asset_id || null, dto.iso_control_ref || null, dto.nist_sub_code || null,
      dto.likelihood, dto.impact,
      dto.treatment || 'mitigate',
      dto.owner_id || null,
      dto.due_date || null,
      createdBy,
    ]);

    return result.rows[0];
  }

  async updateRisk(tenantId: string, id: string, dto: any) {
    const result = await this.db.query(`
      UPDATE risks SET
        status         = COALESCE($3, status),
        treatment      = COALESCE($4, treatment),
        likelihood     = COALESCE($5, likelihood),
        impact         = COALESCE($6, impact),
        residual_score = COALESCE($7, residual_score),
        due_date       = COALESCE($8, due_date),
        updated_at     = NOW()
      WHERE id = $1 AND tenant_id = $2
      RETURNING *
    `, [
      id, tenantId,
      dto.status || null, dto.treatment || null,
      dto.likelihood || null, dto.impact || null,
      dto.residual_score || null, dto.due_date || null,
    ]);

    return result.rows[0];
  }

  async getRiskStats(tenantId: string) {
    const result = await this.db.query(`
      SELECT
        COUNT(*) FILTER (WHERE status = 'open')                        AS open_count,
        COUNT(*) FILTER (WHERE status = 'in_treatment')                AS in_treatment_count,
        COUNT(*) FILTER (WHERE status = 'closed')                      AS closed_count,
        COUNT(*) FILTER (WHERE risk_score >= 15 AND status != 'closed') AS critical_count,
        COUNT(*) FILTER (WHERE due_date < CURRENT_DATE AND status = 'open') AS overdue_count,
        ROUND(AVG(risk_score), 1)                                      AS avg_score
      FROM risks
      WHERE tenant_id = $1
    `, [tenantId]);

    return result.rows[0];
  }
}
