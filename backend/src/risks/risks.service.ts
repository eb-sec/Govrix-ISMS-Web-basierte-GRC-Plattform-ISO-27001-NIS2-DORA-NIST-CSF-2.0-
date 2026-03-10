import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';

@Injectable()
export class RisksService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  private async auditLog(params: {
    tenantId: string; userId?: string; userEmail: string;
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
          (() => { const ip = params.ipAddress; if (!ip) return null; const v4 = ip.match(/^::ffff:(\d+\.\d+\.\d+\.\d+)$/); return v4 ? v4[1] : (/^[\d.:a-fA-F]+$/.test(ip) ? ip : null); })(),
        ]
      );
    } catch (e) { console.warn('Audit-Log Fehler:', e.message); }
  }

  async getRisks(tenantId: string, status?: string) {
    const params: any[] = [tenantId];
    let statusFilter = '';
    if (status) {
      params.push(status);
      statusFilter = `AND r.status = $${params.length}`;
    }
    const result = await this.db.query(`
      SELECT r.*, u.display_name AS owner_name,
             a.name AS asset_name, a.category AS asset_category
      FROM risks r
      LEFT JOIN users u ON u.id = r.owner_id
      LEFT JOIN assets a ON a.id = r.asset_id
      WHERE r.tenant_id = $1 ${statusFilter}
      ORDER BY r.risk_score DESC
    `, params);
    return result.rows;
  }

  async createRisk(tenantId: string, dto: any, createdBy: string | null, userEmail?: string, ipAddress?: string) {
    const countResult = await this.db.query(
      'SELECT COUNT(*) FROM risks WHERE tenant_id = $1', [tenantId]
    );
    const count = parseInt(countResult.rows[0].count) + 1;
    const year  = new Date().getFullYear();
    const riskRef = `RIS-${year}-${String(count).padStart(3, '0')}`;

    // Werte defensive absichern
    const safeInt = (v: any, def = 3) => {
      const n = parseInt(String(v));
      return isNaN(n) ? def : Math.min(5, Math.max(1, n));
    };

    // IP-Adresse validieren (PostgreSQL inet akzeptiert kein ::ffff:-Prefix ohne Quotes)
    const safeIp = (ip?: string): string | null => {
      if (!ip) return null;
      // Normalisiere IPv4-mapped IPv6
      const v4 = ip.match(/^::ffff:(\d+\.\d+\.\d+\.\d+)$/);
      if (v4) return v4[1];
      // Nur gültige IPs durchlassen
      if (/^[\d.:a-fA-F]+$/.test(ip)) return ip;
      return null;
    };

    // created_by: nur setzen wenn UUID tatsächlich in users-Tabelle existiert
    let validCreatedBy: string | null = null;
    if (createdBy) {
      try {
        const userCheck = await this.db.query(
          'SELECT id FROM users WHERE id = $1 AND tenant_id = $2',
          [createdBy, tenantId]
        );
        if (userCheck.rows.length > 0) validCreatedBy = createdBy;
        else console.warn('createRisk: created_by UUID nicht in users gefunden, setze NULL');
      } catch { validCreatedBy = null; }
    }

    let result: any;
    try {
      result = await this.db.query(`
        INSERT INTO risks (
          tenant_id, risk_ref, title, description,
          asset_id, iso_control_ref,
          likelihood, impact, treatment, status,
          owner_id, due_date, created_by
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,'open',$10,$11,$12::uuid)
        RETURNING *
      `, [
        tenantId, riskRef, dto.title, dto.description || null,
        dto.asset_id || null, dto.iso_control_ref || null,
        safeInt(dto.likelihood), safeInt(dto.impact),
        dto.treatment || 'mitigate',
        dto.owner_id || null, dto.due_date || null,
        validCreatedBy,
      ]);
    } catch (dbErr: any) {
      console.error('createRisk DB-Fehler:', dbErr.message, dbErr.detail || '');
      throw dbErr;
    }

    const risk = result.rows[0];

    await this.auditLog({
      tenantId, userId: createdBy, userEmail: userEmail || createdBy,
      eventType: 'RISK_CREATED', entityType: 'risk', entityId: risk.id,
      newValue: {
        risk_ref:        riskRef,
        title:           dto.title,
        iso_control_ref: dto.iso_control_ref || '—',
        likelihood:      dto.likelihood,
        impact:          dto.impact,
        score:           dto.likelihood * dto.impact,
        treatment:       dto.treatment || 'mitigate',
        status:          'open',
      },
      ipAddress,
    });

    return risk;
  }

  async updateRisk(tenantId: string, id: string, dto: any, userEmail?: string, ipAddress?: string) {
    // Vorher-Zustand holen
    const before = await this.db.query(
      'SELECT * FROM risks WHERE id = $1 AND tenant_id = $2', [id, tenantId]
    );
    const oldRisk = before.rows[0];

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

    const newRisk = result.rows[0];

    // Event-Typ aus Änderung ableiten
    let eventType = 'RISK_UPDATED';
    if (oldRisk && dto.status && dto.status !== oldRisk.status) {
      if      (dto.status === 'closed')       eventType = 'RISK_CLOSED';
      else if (dto.status === 'accepted')     eventType = 'RISK_ACCEPTED';
      else if (dto.status === 'in_treatment') eventType = 'RISK_STATUS_CHANGED';
      else                                    eventType = 'RISK_STATUS_CHANGED';
    }

    await this.auditLog({
      tenantId, userEmail: userEmail || 'system',
      eventType, entityType: 'risk', entityId: id,
      oldValue: oldRisk ? {
        title:     oldRisk.title,
        status:    oldRisk.status,
        likelihood: oldRisk.likelihood,
        impact:    oldRisk.impact,
        risk_ref:  oldRisk.risk_ref,
      } : undefined,
      newValue: {
        title:     newRisk?.title,
        status:    newRisk?.status,
        likelihood: newRisk?.likelihood,
        impact:    newRisk?.impact,
        risk_ref:  newRisk?.risk_ref,
      },
      ipAddress,
    });

    return newRisk;
  }

  async getRiskStats(tenantId: string) {
    const result = await this.db.query(`
      SELECT
        COUNT(*) FILTER (WHERE status = 'open')                         AS open_count,
        COUNT(*) FILTER (WHERE status = 'in_treatment')                 AS in_treatment_count,
        COUNT(*) FILTER (WHERE status = 'closed')                       AS closed_count,
        COUNT(*) FILTER (WHERE risk_score >= 15 AND status != 'closed') AS critical_count,
        COUNT(*) FILTER (WHERE due_date < CURRENT_DATE AND status = 'open') AS overdue_count,
        ROUND(AVG(risk_score), 1)                                       AS avg_score
      FROM risks WHERE tenant_id = $1
    `, [tenantId]);
    return result.rows[0];
  }
}
