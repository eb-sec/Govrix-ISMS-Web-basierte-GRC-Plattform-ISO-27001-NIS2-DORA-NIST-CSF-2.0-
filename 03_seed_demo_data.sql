-- ============================================================
-- SecureFrame ISMS — Demo Seed Data
-- Datei: database/03_seed_demo_data.sql
-- Ausführen NACH 01_schema.sql
-- ============================================================

-- ─── TENANT ────────────────────────────────────────────────
INSERT INTO tenants (id, name, slug, plan) VALUES
  ('00000000-0000-0000-0000-000000000001',
   'MusterGmbH — Energiesektor',
   'mustergmbh',
   'enterprise');

-- ─── USERS ─────────────────────────────────────────────────
INSERT INTO users (id, tenant_id, email, display_name, role) VALUES
  ('10000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'dr.fischer@mustergmbh.de',   'Dr. M. Fischer',  'ciso'),
  ('10000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000001',
   't.mueller@mustergmbh.de',    'T. Müller',        'analyst'),
  ('10000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000001',
   's.wolf@mustergmbh.de',       'S. Wolf',          'analyst'),
  ('10000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'k.braun@mustergmbh.de',      'K. Braun',         'auditor'),
  ('10000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'm.hoffmann@mustergmbh.de',   'M. Hoffmann',      'read_only');

-- ─── ASSETS ────────────────────────────────────────────────
INSERT INTO assets (id, tenant_id, name, category, criticality, owner_id) VALUES
  ('20000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'Active Directory / Entra ID',  'Service',   5,
   '10000000-0000-0000-0000-000000000002'),
  ('20000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'Backup-Server (Veeam)',         'Hardware',  5,
   '10000000-0000-0000-0000-000000000003'),
  ('20000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'ERP-System (SAP S/4HANA)',      'Software',  5,
   '10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'Azure Cloud-Infrastruktur',     'Service',   4,
   '10000000-0000-0000-0000-000000000002'),
  ('20000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'SCADA/OT-Netzwerk',             'Hardware',  5,
   '10000000-0000-0000-0000-000000000001'),
  ('20000000-0000-0000-0000-000000000006',
   '00000000-0000-0000-0000-000000000001',
   'Kundendatenbank (PostgreSQL)',   'Data',      5,
   '10000000-0000-0000-0000-000000000003'),
  ('20000000-0000-0000-0000-000000000007',
   '00000000-0000-0000-0000-000000000001',
   'E-Mail-System (Exchange Online)','Service',  3,
   '10000000-0000-0000-0000-000000000002');

-- ─── RISIKEN ───────────────────────────────────────────────
INSERT INTO risks (
  id, tenant_id, risk_ref, title, description,
  asset_id, iso_control_ref, nist_sub_code,
  likelihood, impact, treatment, status,
  owner_id, due_date, created_by
) VALUES
  ('30000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-001',
   'Fehlende MFA für Admin-Zugänge',
   'Administrator-Konten in Active Directory und Azure sind nicht mit '
   'Multi-Faktor-Authentifizierung gesichert. Erhöhtes Risiko bei '
   'Credential-Stuffing-Angriffen und Phishing.',
   '20000000-0000-0000-0000-000000000001',
   'A.8.5', 'PR.AA-03',
   5, 4, 'mitigate', 'open',
   '10000000-0000-0000-0000-000000000002',
   '2026-02-28',
   '10000000-0000-0000-0000-000000000002'),

  ('30000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-002',
   'Backup-Verschlüsselung fehlt',
   'Backup-Daten auf dem Veeam-Server werden unverschlüsselt gespeichert. '
   'Bei physischem Zugriff auf Backup-Medien sind alle Daten lesbar. '
   'Verstößt gegen NIS2 Art.21(2)(h).',
   '20000000-0000-0000-0000-000000000002',
   'A.8.13', 'PR.DS-11',
   4, 5, 'mitigate', 'open',
   '10000000-0000-0000-0000-000000000002',
   '2026-03-05',
   '10000000-0000-0000-0000-000000000001'),

  ('30000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-003',
   'DRP nicht getestet (>12 Monate)',
   'Der Disaster Recovery Plan wurde seit mehr als 12 Monaten nicht '
   'getestet. ISO 27001 A.5.30 und DORA Art.24 verlangen regelmäßige Tests. '
   'Im Ernstfall unbekannte Wiederherstellungszeit (RTO/RPO nicht validiert).',
   '20000000-0000-0000-0000-000000000002',
   'A.5.30', 'RC.RP-03',
   3, 5, 'mitigate', 'in_treatment',
   '10000000-0000-0000-0000-000000000003',
   '2026-03-10',
   '10000000-0000-0000-0000-000000000001'),

  ('30000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-004',
   'Lieferanten-Assessment für 3 kritische Anbieter ausstehend',
   'Drei kritische IKT-Lieferanten (Cloud-Provider, SCADA-Hersteller, '
   'SOC-Dienstleister) wurden seit über 18 Monaten nicht bewertet. '
   'Verstößt gegen ISO A.5.21 und DORA Art.28.',
   '20000000-0000-0000-0000-000000000004',
   'A.5.21', 'GV.RM-06',
   3, 4, 'mitigate', 'in_treatment',
   '10000000-0000-0000-0000-000000000005',
   '2026-03-20',
   '10000000-0000-0000-0000-000000000004'),

  ('30000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-005',
   'Threat Intelligence nicht etabliert',
   'Kein formaler Prozess zur Sammlung, Analyse und Verarbeitung von '
   'Bedrohungsinformationen. ISO A.5.7 (neu in 2022) fordert explizit '
   'einen Threat-Intelligence-Prozess.',
   NULL,
   'A.5.7', 'ID.RA-02',
   3, 3, 'mitigate', 'open',
   '10000000-0000-0000-0000-000000000001',
   '2026-04-01',
   '10000000-0000-0000-0000-000000000001'),

  ('30000000-0000-0000-0000-000000000006',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-006',
   'Security Awareness Training Q1 unvollständig',
   '38% der Mitarbeitenden haben das Pflicht-Training noch nicht absolviert. '
   'NIS2 Art.21(2)(g) fordert verpflichtende Cyberhygiene-Schulungen.',
   NULL,
   'A.6.3', NULL,
   2, 3, 'mitigate', 'in_treatment',
   '10000000-0000-0000-0000-000000000004',
   '2026-03-31',
   '10000000-0000-0000-0000-000000000004'),

  ('30000000-0000-0000-0000-000000000007',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-007',
   'Datenmaskierung (DLP) nicht implementiert',
   'Personenbezogene Daten in der Kundendatenbank werden nicht maskiert. '
   'ISO A.8.11 (neu 2022) und DSGVO Art.25 (Privacy by Design) verlangen '
   'Datenmaskierung für produktionsfremde Umgebungen.',
   '20000000-0000-0000-0000-000000000006',
   'A.8.11', 'PR.DS-01',
   2, 2, 'accept', 'accepted',
   '10000000-0000-0000-0000-000000000001',
   '2026-06-30',
   '10000000-0000-0000-0000-000000000002');

-- ─── MASSNAHMEN ────────────────────────────────────────────
INSERT INTO actions (
  id, tenant_id, risk_id, title, description,
  status, priority, owner_id, due_date
) VALUES
  ('40000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000001',
   'MFA in Microsoft Entra ID für alle Admin-Konten aktivieren',
   'Conditional Access Policy erstellen: MFA für alle Nutzer mit '
   'privilegierten Rollen (Global Admin, Security Admin, etc.)',
   'open', 1,
   '10000000-0000-0000-0000-000000000002',
   '2026-02-28'),

  ('40000000-0000-0000-0000-000000000002',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000001',
   'Privileged Identity Management (PIM) einrichten',
   'Just-in-Time (JIT) Zugriff für Admin-Rollen via Azure PIM. '
   'Keine dauerhaft aktiven privilegierten Rollen.',
   'open', 1,
   '10000000-0000-0000-0000-000000000002',
   '2026-03-15'),

  ('40000000-0000-0000-0000-000000000003',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000002',
   'Veeam Backup Encryption mit AES-256 aktivieren',
   'Veeam Backup & Replication: Verschlüsselung auf Job-Ebene aktivieren. '
   'Schlüsselverwaltung via Azure Key Vault.',
   'in_progress', 1,
   '10000000-0000-0000-0000-000000000003',
   '2026-03-05'),

  ('40000000-0000-0000-0000-000000000004',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000003',
   'DRP-Tabletop-Übung durchführen',
   'Halbtägige Krisenübung mit IT, Management und Fachabteilungen. '
   'Szenario: Ransomware-Angriff auf ERP-System. RTO/RPO validieren.',
   'open', 2,
   '10000000-0000-0000-0000-000000000003',
   '2026-03-10'),

  ('40000000-0000-0000-0000-000000000005',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000004',
   'Lieferanten-Fragebogen (TISAX-Level 2) versenden',
   'Standardisierter Security-Fragebogen an die 3 kritischen Anbieter. '
   'Frist für Rückantwort: 4 Wochen.',
   'in_progress', 2,
   '10000000-0000-0000-0000-000000000005',
   '2026-03-20'),

  ('40000000-0000-0000-0000-000000000006',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000005',
   'Threat Intelligence Feed abonnieren (MISP / BSI CERT-Bund)',
   'Anbindung an BSI CERT-Bund-Feed und MISP-Plattform. '
   'Wöchentliche Auswertung durch Security-Team.',
   'open', 2,
   '10000000-0000-0000-0000-000000000002',
   '2026-04-01'),

  ('40000000-0000-0000-0000-000000000007',
   '00000000-0000-0000-0000-000000000001',
   '30000000-0000-0000-0000-000000000006',
   'Awareness-Training-Erinnerung an alle Mitarbeitenden senden',
   'Eskalations-E-Mail von CISO an alle TN mit ausstehenden Modulen. '
   'Frist: 2 Wochen. Danach HR-Eskalation.',
   'in_progress', 3,
   '10000000-0000-0000-0000-000000000004',
   '2026-03-31');

-- ─── AUDIT-LOG EINTRÄGE ────────────────────────────────────
INSERT INTO audit_log (
  tenant_id, user_id, user_email,
  event_type, entity_type, entity_id,
  old_value, new_value
) VALUES
  ('00000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000001',
   'dr.fischer@mustergmbh.de',
   'RISK_CREATED', 'risk',
   '30000000-0000-0000-0000-000000000001',
   NULL,
   '{"title":"Fehlende MFA für Admin-Zugänge","risk_score":20,"status":"open"}'::jsonb),

  ('00000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000002',
   't.mueller@mustergmbh.de',
   'CONTROL_UPDATED', 'iso_control',
   NULL,
   '{"control_ref":"A.8.24","status":"not_started","completion_pct":0}'::jsonb,
   '{"control_ref":"A.8.24","status":"in_progress","completion_pct":72}'::jsonb),

  ('00000000-0000-0000-0000-000000000001',
   '10000000-0000-0000-0000-000000000003',
   's.wolf@mustergmbh.de',
   'ACTION_COMPLETED', 'action',
   '40000000-0000-0000-0000-000000000003',
   '{"status":"in_progress","completion_pct":80}'::jsonb,
   '{"status":"done","completion_pct":100}'::jsonb),

  ('00000000-0000-0000-0000-000000000001',
   NULL, 'system@secureframe.io',
   'SYSTEM_REMINDER', 'action',
   '40000000-0000-0000-0000-000000000001',
   NULL,
   '{"message":"Frist in 3 Tagen","action_title":"MFA Admin-Konten","due_date":"2026-02-28"}'::jsonb);

-- ─── CONTROL-IMPLEMENTIERUNGEN (Stichproben) ───────────────
-- Setzt Status für einige Controls des Demo-Tenants
DO $$
DECLARE
  t_id UUID := '00000000-0000-0000-0000-000000000001';
  ciso UUID := '10000000-0000-0000-0000-000000000001';
  ctrl RECORD;
BEGIN
  FOR ctrl IN
    SELECT id, control_ref FROM iso_controls
    WHERE control_ref IN ('A.5.1','A.5.2','A.5.3','A.6.1','A.6.2',
                          'A.6.3','A.6.4','A.6.5','A.7.1','A.7.2',
                          'A.7.3','A.8.1','A.8.3','A.8.6','A.8.7',
                          'A.8.14','A.8.15','A.8.17','A.8.20')
  LOOP
    INSERT INTO control_implementations
      (tenant_id, iso_control_id, status, completion_pct, owner_id, last_reviewed)
    VALUES
      (t_id, ctrl.id, 'implemented', 100, ciso, CURRENT_DATE)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- In-Progress Controls
  FOR ctrl IN
    SELECT id FROM iso_controls
    WHERE control_ref IN ('A.5.7','A.5.21','A.5.24','A.5.30',
                          'A.8.5','A.8.9','A.8.11','A.8.12','A.8.24')
  LOOP
    INSERT INTO control_implementations
      (tenant_id, iso_control_id, status, completion_pct, owner_id)
    VALUES
      (t_id, ctrl.id, 'in_progress',
       (ARRAY[30,40,42,45,55,60,65,68,72])[floor(random()*9+1)::int],
       ciso)
    ON CONFLICT DO NOTHING;
  END LOOP;
END $$;

-- Abschluss-Check
SELECT
  'Tenants'  AS entity, COUNT(*) FROM tenants  WHERE id = '00000000-0000-0000-0000-000000000001'
UNION ALL SELECT 'Users',   COUNT(*) FROM users   WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
UNION ALL SELECT 'Assets',  COUNT(*) FROM assets  WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
UNION ALL SELECT 'Risks',   COUNT(*) FROM risks   WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
UNION ALL SELECT 'Actions', COUNT(*) FROM actions WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
UNION ALL SELECT 'Audit Log',COUNT(*) FROM audit_log WHERE tenant_id = '00000000-0000-0000-0000-000000000001';
