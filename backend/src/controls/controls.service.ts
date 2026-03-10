import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class ControlsService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  private async auditLog(params: {
    tenantId: string; userEmail: string; userId?: string;
    eventType: string; entityType: string; entityId?: string;
    oldValue?: any; newValue?: any; ipAddress?: string;
  }) {
    try {
      await this.db.query(
        `INSERT INTO audit_log
           (tenant_id, user_id, user_email, event_type, entity_type, entity_id,
            old_value, new_value, ip_address)
         VALUES ($1,$2,$3,$4,$5,$6,$7::jsonb,$8::jsonb,$9::inet)`,
        [
          params.tenantId, params.userId || null, params.userEmail,
          params.eventType, params.entityType, params.entityId || null,
          params.oldValue  ? JSON.stringify(params.oldValue)  : null,
          params.newValue  ? JSON.stringify(params.newValue)  : null,
          params.ipAddress || null,
        ]
      );
    } catch (e) { console.warn('Audit-Log Fehler:', e.message); }
  }

  // ─── ISO 27001 ────────────────────────────────────────────────────────────

  async getIsoControls(tenantId: string, category?: string) {
    const params: any[] = [tenantId];
    let categoryFilter = '';
    if (category) {
      params.push(category.toUpperCase());
      categoryFilter = `AND cat.code = $${params.length}`;
    }
    const result = await this.db.query(`
      SELECT ic.id, ic.control_ref, ic.title, ic.is_new_in_2022, ic.sort_order,
             cat.name AS category_name, cat.code AS category_code,
             COALESCE(ci.status, 'not_started') AS status,
             COALESCE(ci.completion_pct, 0)     AS completion_pct,
             ci.evidence_url, ci.notes, ci.due_date, ci.last_reviewed,
             u.display_name AS owner_name
      FROM iso_controls ic
      JOIN iso_control_categories cat ON cat.id = ic.category_id
      LEFT JOIN control_implementations ci ON ci.iso_control_id = ic.id AND ci.tenant_id = $1
      LEFT JOIN users u ON u.id = ci.owner_id
      WHERE 1=1 ${categoryFilter}
      ORDER BY ic.sort_order
    `, params);
    return result.rows;
  }

  async getIsoScore(tenantId: string) {
    const result = await this.db.query(`
      SELECT cat.name AS category, cat.code AS category_code,
             COUNT(ic.id) AS total,
             SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1 ELSE 0 END) AS compliant,
             SUM(CASE WHEN ci.status = 'in_progress' THEN 1 ELSE 0 END) AS in_progress,
             ROUND(SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1.0 ELSE 0 END)
               / COUNT(ic.id) * 100, 1) AS compliance_pct
      FROM iso_controls ic
      JOIN iso_control_categories cat ON cat.id = ic.category_id
      LEFT JOIN control_implementations ci ON ci.iso_control_id = ic.id AND ci.tenant_id = $1
      GROUP BY cat.id, cat.name, cat.code ORDER BY cat.id
    `, [tenantId]);
    const categories     = result.rows;
    const totalCompliant = categories.reduce((s, r) => s + parseInt(r.compliant), 0);
    const totalControls  = categories.reduce((s, r) => s + parseInt(r.total), 0);
    return {
      overall_pct: totalControls > 0 ? Math.round(totalCompliant / totalControls * 1000) / 10 : 0,
      total_controls: totalControls, compliant: totalCompliant, categories,
    };
  }

  async updateIsoControl(tenantId: string, controlRef: string, dto: any, userEmail?: string, ipAddress?: string) {
    const ctrl = await this.db.query(
      'SELECT id FROM iso_controls WHERE control_ref = $1', [controlRef]
    );
    if (!ctrl.rows.length) throw new Error(`Control ${controlRef} nicht gefunden`);
    const controlId = ctrl.rows[0].id;

    // Vorher-Zustand
    const before = await this.db.query(
      'SELECT * FROM control_implementations WHERE tenant_id=$1 AND iso_control_id=$2',
      [tenantId, controlId]
    );
    const oldVal = before.rows[0];

    const result = await this.db.query(`
      INSERT INTO control_implementations
        (tenant_id, iso_control_id, status, completion_pct, evidence_url, notes, due_date, owner_id)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
      ON CONFLICT (tenant_id, iso_control_id) DO UPDATE SET
        status=EXCLUDED.status, completion_pct=EXCLUDED.completion_pct,
        evidence_url=EXCLUDED.evidence_url, notes=EXCLUDED.notes,
        due_date=EXCLUDED.due_date, owner_id=EXCLUDED.owner_id,
        last_reviewed=CURRENT_DATE
      RETURNING *
    `, [tenantId, controlId, dto.status, dto.completion_pct,
        dto.evidence_url||null, dto.notes||null, dto.due_date||null, dto.owner_id||null]);

    await this.auditLog({
      tenantId, userEmail: userEmail || 'system',
      eventType: 'CONTROL_UPDATED', entityType: 'control', entityId: controlId,
      oldValue: oldVal ? {
        control_ref: controlRef,
        status:      oldVal.status,
        completion_pct: oldVal.completion_pct,
      } : { control_ref: controlRef, status: 'not_started' },
      newValue: {
        control_ref:    controlRef,
        status:         dto.status,
        completion_pct: dto.completion_pct,
      },
      ipAddress,
    });

    return result.rows[0];
  }

  // ─── NIST CSF 2.0 ─────────────────────────────────────────────────────────

  async getNistControls(tenantId: string, functionCode?: string) {
    const params: any[] = [tenantId];
    let fnFilter = '';
    if (functionCode) {
      params.push(functionCode.toUpperCase());
      fnFilter = `AND fn.code = $${params.length}`;
    }
    const result = await this.db.query(`
      SELECT ns.id, ns.code, ns.description, ns.sort_order,
             nc.code AS category_code, nc.name AS category_name,
             fn.code AS function_code, fn.name AS function_name, fn.color AS function_color,
             COALESCE(ci.status, 'not_started') AS status,
             COALESCE(ci.completion_pct, 0)     AS completion_pct,
             ci.notes, ci.due_date, ci.last_reviewed
      FROM nist_subcategories ns
      JOIN nist_categories nc ON nc.id = ns.category_id
      JOIN nist_functions fn  ON fn.id = nc.function_id
      LEFT JOIN control_implementations ci ON ci.nist_sub_id = ns.id AND ci.tenant_id = $1
      WHERE 1=1 ${fnFilter}
      ORDER BY fn.code, nc.code, ns.sort_order
    `, params);
    return result.rows;
  }

  async getNistScore(tenantId: string) {
    const result = await this.db.query(`
      SELECT fn.code AS function_code, fn.name AS function_name, fn.color,
             COUNT(ns.id) AS total_subcategories,
             SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1 ELSE 0 END) AS compliant,
             COALESCE(ROUND(AVG(COALESCE(ci.completion_pct,0)),1),0) AS avg_pct
      FROM nist_functions fn
      JOIN nist_categories nc ON nc.function_id = fn.id
      JOIN nist_subcategories ns ON ns.category_id = nc.id
      LEFT JOIN control_implementations ci ON ci.nist_sub_id = ns.id AND ci.tenant_id = $1
      GROUP BY fn.id, fn.code, fn.name, fn.color ORDER BY fn.code
    `, [tenantId]);
    return result.rows;
  }

  async updateNistControl(tenantId: string, subCode: string, dto: any, userEmail?: string, ipAddress?: string) {
    const sub = await this.db.query(
      'SELECT id FROM nist_subcategories WHERE code = $1', [subCode]
    );
    if (!sub.rows.length) throw new Error(`NIST Subcategory ${subCode} nicht gefunden`);
    const subId = sub.rows[0].id;

    const before = await this.db.query(
      'SELECT * FROM control_implementations WHERE tenant_id=$1 AND nist_sub_id=$2',
      [tenantId, subId]
    );
    const oldVal = before.rows[0];

    const result = await this.db.query(`
      INSERT INTO control_implementations (tenant_id, nist_sub_id, status, completion_pct, notes, due_date)
      VALUES ($1,$2,$3,$4,$5,$6)
      ON CONFLICT (tenant_id, nist_sub_id) DO UPDATE SET
        status=EXCLUDED.status, completion_pct=EXCLUDED.completion_pct,
        notes=EXCLUDED.notes, due_date=EXCLUDED.due_date, last_reviewed=CURRENT_DATE
      RETURNING *
    `, [tenantId, subId, dto.status, dto.completion_pct, dto.notes||null, dto.due_date||null]);

    await this.auditLog({
      tenantId, userEmail: userEmail || 'system',
      eventType: 'CONTROL_UPDATED', entityType: 'control', entityId: subId,
      oldValue: { nist_code: subCode, status: oldVal?.status || 'not_started', completion_pct: oldVal?.completion_pct || 0 },
      newValue: { nist_code: subCode, status: dto.status, completion_pct: dto.completion_pct },
      ipAddress,
    });

    return result.rows[0];
  }

  // ─── NIS2 / DORA ──────────────────────────────────────────────────────────

  async getNis2Requirements(tenantId: string, framework?: string) {
    const params: any[] = [tenantId];
    let fwFilter = '';
    if (framework) {
      params.push(framework.toUpperCase());
      fwFilter = `AND nr.framework = $${params.length}`;
    }
    const result = await this.db.query(`
      SELECT nr.id, nr.req_ref, nr.title, nr.description, nr.framework,
             nr.article, nr.category,
             COALESCE(nc.status, 'not_started') AS status,
             COALESCE(nc.completion_pct, 0)     AS completion_pct,
             nc.notes, nc.due_date, nc.last_reviewed
      FROM nis2_requirements nr
      LEFT JOIN nis2_compliance nc ON nc.req_id = nr.id AND nc.tenant_id = $1
      WHERE 1=1 ${fwFilter}
      ORDER BY nr.framework, nr.req_ref
    `, params);
    return result.rows;
  }

  async updateNis2Requirement(tenantId: string, reqRef: string, dto: any, userEmail?: string, ipAddress?: string) {
    const req = await this.db.query(
      'SELECT id, title, framework FROM nis2_requirements WHERE req_ref = $1', [reqRef]
    );
    if (!req.rows.length) throw new Error(`Requirement ${reqRef} nicht gefunden`);
    const { id: reqId, title, framework } = req.rows[0];

    const before = await this.db.query(
      'SELECT * FROM nis2_compliance WHERE tenant_id=$1 AND req_id=$2', [tenantId, reqId]
    );
    const oldVal = before.rows[0];

    const result = await this.db.query(`
      INSERT INTO nis2_compliance (tenant_id, req_id, status, completion_pct, notes, due_date)
      VALUES ($1,$2,$3,$4,$5,$6)
      ON CONFLICT (tenant_id, req_id) DO UPDATE SET
        status=EXCLUDED.status, completion_pct=EXCLUDED.completion_pct,
        notes=EXCLUDED.notes, due_date=EXCLUDED.due_date, last_reviewed=CURRENT_DATE
      RETURNING *
    `, [tenantId, reqId, dto.status, dto.completion_pct, dto.notes||null, dto.due_date||null]);

    await this.auditLog({
      tenantId, userEmail: userEmail || 'system',
      eventType: 'CONTROL_UPDATED', entityType: 'control', entityId: reqId,
      oldValue: { req_ref: reqRef, framework, title, status: oldVal?.status || 'not_started' },
      newValue: { req_ref: reqRef, framework, title, status: dto.status, completion_pct: dto.completion_pct },
      ipAddress,
    });

    return result.rows[0];
  }

  // ─── Dashboard Score ───────────────────────────────────────────────────────

  async getScore(tenantId: string) {
    const [iso, nist] = await Promise.all([
      this.getIsoScore(tenantId), this.getNistScore(tenantId),
    ]);
    const nis2Result = await this.db.query(`
      SELECT nr.framework, COUNT(*) AS total,
             SUM(CASE WHEN nc.status IN ('implemented','audited') THEN 1 ELSE 0 END) AS compliant,
             COALESCE(ROUND(AVG(COALESCE(nc.completion_pct,0)),1),0) AS avg_pct
      FROM nis2_requirements nr
      LEFT JOIN nis2_compliance nc ON nc.req_id = nr.id AND nc.tenant_id = $1
      GROUP BY nr.framework
    `, [tenantId]);
    return { iso, nist, nis2_dora: nis2Result.rows };
  }
}
