import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Pool } from 'pg';
import { DATABASE_POOL } from '../common/database.module';
import * as fs from 'fs';
import * as path from 'path';

const DEMO_TENANT = '00000000-0000-0000-0000-000000000001';

@Injectable()
export class EvidenceService {
  constructor(@Inject(DATABASE_POOL) private readonly db: Pool) {}

  private async auditLog(params: {
    userId?: string; userEmail: string;
    eventType: string; entityId?: string;
    newValue?: any; ipAddress?: string;
  }) {
    try {
      await this.db.query(
        `INSERT INTO audit_log
           (tenant_id, user_id, user_email, event_type, entity_type, entity_id,
            new_value, ip_address)
         VALUES ($1,$2,$3,$4,'evidence',$5,$6::jsonb,$7::inet)`,
        [
          DEMO_TENANT, params.userId || null, params.userEmail,
          params.eventType, params.entityId || null,
          params.newValue ? JSON.stringify(params.newValue) : null,
          params.ipAddress || null,
        ]
      );
    } catch (e) { console.warn('Audit-Log Fehler:', e.message); }
  }

  async getEvidenceForControl(controlRef: string, controlType = 'iso') {
    const res = await this.db.query(
      `SELECT id, control_ref, control_type, file_name, file_size, mime_type,
              description, uploaded_by, uploaded_at, valid_until, is_active
       FROM evidence
       WHERE tenant_id=$1 AND control_ref=$2 AND control_type=$3 AND is_active=TRUE
       ORDER BY uploaded_at DESC`,
      [DEMO_TENANT, controlRef, controlType]
    );
    return res.rows;
  }

  async getAllEvidence(controlType?: string) {
    const res = await this.db.query(
      `SELECT id, control_ref, control_type, file_name, file_size, mime_type,
              description, uploaded_by, uploaded_at, valid_until, is_active
       FROM evidence
       WHERE tenant_id=$1 ${controlType ? 'AND control_type=$2' : ''} AND is_active=TRUE
       ORDER BY uploaded_at DESC`,
      controlType ? [DEMO_TENANT, controlType] : [DEMO_TENANT]
    );
    return res.rows;
  }

  async getEvidenceSummary() {
    const res = await this.db.query(
      `SELECT control_ref, control_type, COUNT(*) as count
       FROM evidence
       WHERE tenant_id=$1 AND is_active=TRUE
       GROUP BY control_ref, control_type`,
      [DEMO_TENANT]
    );
    // Gibt { 'A.5.1': 2, 'A.5.2': 1, ... } zurück
    const summary: Record<string, number> = {};
    for (const row of res.rows) {
      summary[row.control_ref] = parseInt(row.count);
    }
    return summary;
  }

  async createEvidence(params: {
    controlRef: string;
    controlType: string;
    fileName: string;
    filePath: string;
    fileSize: number;
    mimeType: string;
    description?: string;
    validUntil?: string;
    userEmail: string;
    userId?: string;
    ipAddress?: string;
  }) {
    const res = await this.db.query(
      `INSERT INTO evidence
         (tenant_id, control_ref, control_type, file_name, file_path,
          file_size, mime_type, description, uploaded_by, valid_until)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
       RETURNING id, control_ref, file_name, uploaded_at`,
      [
        DEMO_TENANT, params.controlRef, params.controlType,
        params.fileName, params.filePath,
        params.fileSize, params.mimeType,
        params.description || null, params.userEmail,
        params.validUntil || null,
      ]
    );
    const row = res.rows[0];
    await this.auditLog({
      userId: params.userId, userEmail: params.userEmail,
      eventType: 'evidence.upload', entityId: row.id,
      newValue: { controlRef: params.controlRef, fileName: params.fileName },
      ipAddress: params.ipAddress,
    });
    return row;
  }

  async deleteEvidence(id: string, userEmail: string, ipAddress?: string) {
    // Soft-Delete: is_active = false, Datei bleibt auf Disk (Audit-Trail)
    const res = await this.db.query(
      `UPDATE evidence SET is_active=FALSE
       WHERE id=$1 AND tenant_id=$2
       RETURNING id, file_name, file_path, control_ref`,
      [id, DEMO_TENANT]
    );
    if (res.rowCount === 0) throw new NotFoundException('Nachweis nicht gefunden');
    const row = res.rows[0];
    await this.auditLog({
      userEmail, eventType: 'evidence.delete', entityId: id,
      newValue: { controlRef: row.control_ref, fileName: row.file_name },
      ipAddress,
    });
    return { deleted: true, id };
  }

  async getFileInfo(id: string): Promise<{ filePath: string; fileName: string; mimeType: string }> {
    const res = await this.db.query(
      `SELECT file_path, file_name, mime_type FROM evidence WHERE id=$1 AND tenant_id=$2`,
      [id, DEMO_TENANT]
    );
    if (res.rowCount === 0) throw new NotFoundException('Nachweis nicht gefunden');
    return res.rows[0];
  }
}
