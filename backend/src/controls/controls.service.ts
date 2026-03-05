import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class ControlsService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  // Alle 93 ISO Controls mit Implementierungsstatus eines Tenants
  async getIsoControls(tenantId: string, category?: string) {
    const params: any[] = [tenantId];
    let categoryFilter = '';
    if (category) {
      params.push(category.toUpperCase());
      categoryFilter = `AND cat.code = $${params.length}`;
    }

    const result = await this.db.query(`
      SELECT
        ic.id,
        ic.control_ref,
        ic.title,
        ic.is_new_in_2022,
        ic.sort_order,
        cat.name  AS category_name,
        cat.code  AS category_code,
        COALESCE(ci.status, 'not_started') AS status,
        COALESCE(ci.completion_pct, 0)     AS completion_pct,
        ci.evidence_url,
        ci.notes,
        ci.due_date,
        ci.last_reviewed,
        u.display_name AS owner_name
      FROM iso_controls ic
      JOIN iso_control_categories cat ON cat.id = ic.category_id
      LEFT JOIN control_implementations ci
        ON ci.iso_control_id = ic.id AND ci.tenant_id = $1
      LEFT JOIN users u ON u.id = ci.owner_id
      WHERE 1=1 ${categoryFilter}
      ORDER BY ic.sort_order
    `, params);

    return result.rows;
  }

  // Aggregierter ISO Compliance Score
  async getIsoScore(tenantId: string) {
    const result = await this.db.query(`
      SELECT
        cat.name                                          AS category,
        cat.code                                          AS category_code,
        COUNT(ic.id)                                      AS total,
        SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1 ELSE 0 END) AS compliant,
        SUM(CASE WHEN ci.status = 'in_progress' THEN 1 ELSE 0 END)             AS in_progress,
        ROUND(
          SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1.0 ELSE 0 END)
          / COUNT(ic.id) * 100, 1
        ) AS compliance_pct
      FROM iso_controls ic
      JOIN iso_control_categories cat ON cat.id = ic.category_id
      LEFT JOIN control_implementations ci
        ON ci.iso_control_id = ic.id AND ci.tenant_id = $1
      GROUP BY cat.id, cat.name, cat.code
      ORDER BY cat.id
    `, [tenantId]);

    const categories = result.rows;
    const totalCompliant  = categories.reduce((s, r) => s + parseInt(r.compliant), 0);
    const totalControls   = categories.reduce((s, r) => s + parseInt(r.total), 0);

    return {
      overall_pct: totalControls > 0
        ? Math.round(totalCompliant / totalControls * 1000) / 10
        : 0,
      total_controls: totalControls,
      compliant: totalCompliant,
      categories,
    };
  }

  // NIST CSF 2.0 Score
  async getNistScore(tenantId: string) {
    const result = await this.db.query(`
      SELECT
        fn.code   AS function_code,
        fn.name   AS function_name,
        fn.color,
        COUNT(ns.id)              AS total_subcategories,
        COALESCE(ROUND(AVG(COALESCE(ci.completion_pct, 0)), 1), 0) AS avg_pct
      FROM nist_functions fn
      JOIN nist_categories nc ON nc.function_id = fn.id
      JOIN nist_subcategories ns ON ns.category_id = nc.id
      LEFT JOIN control_implementations ci
        ON ci.nist_sub_id = ns.id AND ci.tenant_id = $1
      GROUP BY fn.id, fn.code, fn.name, fn.color
      ORDER BY fn.code
    `, [tenantId]);

    return result.rows;
  }

  // Control-Status aktualisieren
  async updateIsoControl(tenantId: string, controlRef: string, dto: any) {
    // Control-ID holen
    const ctrl = await this.db.query(
      'SELECT id FROM iso_controls WHERE control_ref = $1',
      [controlRef]
    );
    if (!ctrl.rows.length) throw new Error(`Control ${controlRef} nicht gefunden`);

    const controlId = ctrl.rows[0].id;

    // Upsert: neu anlegen oder aktualisieren
    const result = await this.db.query(`
      INSERT INTO control_implementations
        (tenant_id, iso_control_id, status, completion_pct, evidence_url, notes, due_date, owner_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      ON CONFLICT (tenant_id, iso_control_id)
        DO UPDATE SET
          status         = EXCLUDED.status,
          completion_pct = EXCLUDED.completion_pct,
          evidence_url   = EXCLUDED.evidence_url,
          notes          = EXCLUDED.notes,
          due_date       = EXCLUDED.due_date,
          owner_id       = EXCLUDED.owner_id,
          last_reviewed  = CURRENT_DATE
      RETURNING *
    `, [
      tenantId, controlId,
      dto.status, dto.completion_pct,
      dto.evidence_url || null,
      dto.notes || null,
      dto.due_date || null,
      dto.owner_id || null,
    ]);

    return result.rows[0];
  }
}
