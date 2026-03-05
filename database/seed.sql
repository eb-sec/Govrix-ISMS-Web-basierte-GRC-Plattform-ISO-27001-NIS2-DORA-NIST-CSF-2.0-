-- ============================================================
-- Govrix ISMS — Bereinigtes Seed-Script
-- Kompatibel mit 01_schema.sql
-- ============================================================

-- ============================================================
-- 1. NIS2/DORA Tabelle (fehlt im Schema, hier erstellen)
-- ============================================================
CREATE TABLE IF NOT EXISTS nis2_requirements (
  id          SERIAL PRIMARY KEY,
  req_ref     TEXT NOT NULL UNIQUE,
  title       TEXT NOT NULL,
  description TEXT,
  framework   TEXT NOT NULL DEFAULT 'NIS2' CHECK (framework IN ('NIS2','DORA')),
  article     TEXT,
  category    TEXT
);

-- ============================================================
-- 2. DEMO TENANT
-- ============================================================
INSERT INTO tenants (id, name, slug) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Govrix GmbH', 'govrix')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. DEMO USERS (kein password_hash im Schema)
-- ============================================================
INSERT INTO users (id, tenant_id, email, display_name, role) VALUES
  ('00000000-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000001', 'admin@govrix.io',    'Admin User',  'admin'),
  ('00000000-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000001', 'ciso@govrix.io',     'CISO User',   'ciso'),
  ('00000000-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000001', 'analyst@govrix.io',  'Max Analyst', 'analyst')
ON CONFLICT (tenant_id, email) DO UPDATE SET display_name = EXCLUDED.display_name;

-- ============================================================
-- 4. NIS2 / DORA ANFORDERUNGEN
-- ============================================================
INSERT INTO nis2_requirements (req_ref, title, description, framework, article, category) VALUES
  ('NIS2-1',  'Risikoanalyse und Sicherheitsrichtlinien',
   'Angemessene technische und organisatorische Maßnahmen zur Risikoanalyse und -management.',
   'NIS2', 'Art. 21 (2a)', 'Risikomanagement'),
  ('NIS2-2',  'Sicherheitsvorfälle behandeln',
   'Verfahren für den Umgang mit Sicherheitsvorfällen.',
   'NIS2', 'Art. 21 (2b)', 'Vorfallmanagement'),
  ('NIS2-3',  'Business Continuity und Krisenmanagement',
   'Business Continuity Management und Krisenmanagement.',
   'NIS2', 'Art. 21 (2c)', 'Betriebskontinuität'),
  ('NIS2-4',  'Sicherheit der Lieferkette',
   'Sicherheit der Lieferkette einschließlich sicherheitsrelevanter Aspekte der Beziehungen mit Lieferanten.',
   'NIS2', 'Art. 21 (2d)', 'Lieferkettensicherheit'),
  ('NIS2-5',  'Sicherheit beim Erwerb und Entwicklung von Netz- und Informationssystemen',
   'Sicherheit bei Erwerb, Entwicklung und Wartung von Netz- und Informationssystemen.',
   'NIS2', 'Art. 21 (2e)', 'Systemsicherheit'),
  ('NIS2-6',  'Bewertung der Wirksamkeit von Cybersicherheitsmaßnahmen',
   'Strategien und Verfahren zur Bewertung der Wirksamkeit der Maßnahmen.',
   'NIS2', 'Art. 21 (2f)', 'Wirksamkeitsprüfung'),
  ('NIS2-7',  'Cyberhygiene und Schulungen zur Cybersicherheit',
   'Grundlegende Cyberhygienepraktiken und Schulungen zur Cybersicherheit.',
   'NIS2', 'Art. 21 (2g)', 'Schulung'),
  ('NIS2-8',  'Kryptographie und Verschlüsselung',
   'Einsatz von Kryptographie und gegebenenfalls Verschlüsselung.',
   'NIS2', 'Art. 21 (2h)', 'Kryptographie'),
  ('NIS2-9',  'Personalsicherheit, Zugriffskontrolle, Asset Management',
   'Personalsicherheit, Zugangskontrolle und Vermögensverwaltung.',
   'NIS2', 'Art. 21 (2i)', 'Zugangskontrolle'),
  ('NIS2-10', 'Multi-Faktor-Authentifizierung',
   'Einsatz von Multi-Faktor-Authentifizierung oder kontinuierlichen Authentifizierungslösungen.',
   'NIS2', 'Art. 21 (2j)', 'Authentifizierung'),
  ('NIS2-11', 'Meldepflicht – Frühwarnung (24h)',
   'Frühwarnung an zuständige Behörde innerhalb von 24 Stunden nach Bekanntwerden eines erheblichen Vorfalls.',
   'NIS2', 'Art. 23 (4a)', 'Meldepflicht'),
  ('NIS2-12', 'Meldepflicht – Vorfallsmeldung (72h)',
   'Meldung des Vorfalls an die zuständige Behörde innerhalb von 72 Stunden.',
   'NIS2', 'Art. 23 (4b)', 'Meldepflicht'),
  ('NIS2-13', 'Meldepflicht – Abschlussbericht (1 Monat)',
   'Übermittlung eines Abschlussberichts spätestens einen Monat nach Meldung.',
   'NIS2', 'Art. 23 (4c)', 'Meldepflicht'),
  ('DORA-1',  'IKT-Risikomanagement-Rahmen',
   'Einführung und Pflege eines soliden IKT-Risikomanagement-Rahmens.',
   'DORA', 'Art. 5', 'IKT-Risikomanagement'),
  ('DORA-2',  'IKT-Geschäftsfortführungsrichtlinie',
   'IKT-Geschäftsfortführungsrichtlinie für den Fall einer schwerwiegenden Betriebsstörung.',
   'DORA', 'Art. 11', 'Business Continuity'),
  ('DORA-3',  'Meldung schwerwiegender IKT-Vorfälle',
   'Klassifizierung und Meldung schwerwiegender IKT-bezogener Vorfälle an Behörden.',
   'DORA', 'Art. 17-19', 'Vorfallmeldung'),
  ('DORA-4',  'Programm zur Überprüfung der digitalen operationalen Resilienz',
   'Programm zur Überprüfung der digitalen operationalen Resilienz einschließlich TLPT.',
   'DORA', 'Art. 24-25', 'Resilienztests'),
  ('DORA-5',  'Management des IKT-Drittparteienrisikos',
   'Verwaltung des IKT-Drittparteienrisikos durch Rahmen und Vertragsregelungen.',
   'DORA', 'Art. 28-30', 'Drittparteienrisiko'),
  ('DORA-6',  'Austausch von Informationen über Cyberbedrohungen',
   'Austausch von Informationen und Erkenntnissen zu Cyberbedrohungen.',
   'DORA', 'Art. 45', 'Informationsaustausch')
ON CONFLICT (req_ref) DO NOTHING;

-- ============================================================
-- 5. DEMO ASSETS (criticality als SMALLINT 1-5)
-- ============================================================
INSERT INTO assets (id, tenant_id, name, category, criticality, owner_id) VALUES
  ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001',
   'Produktions-Server (Web)', 'Hardware', 5, '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0000-000000000001',
   'PostgreSQL Datenbank', 'Software', 5, '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0001-000000000003', '00000000-0000-0000-0000-000000000001',
   'Active Directory', 'Software', 5, '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0001-000000000004', '00000000-0000-0000-0000-000000000001',
   'Kundendaten (CRM)', 'Data', 5, '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0001-000000000005', '00000000-0000-0000-0000-000000000001',
   'Backup-System', 'Service', 4, '00000000-0000-0000-0000-000000000012'),
  ('00000000-0000-0000-0001-000000000006', '00000000-0000-0000-0000-000000000001',
   'Office-Laptops (50x)', 'Hardware', 3, '00000000-0000-0000-0000-000000000012'),
  ('00000000-0000-0000-0001-000000000007', '00000000-0000-0000-0000-000000000001',
   'Rechenzentrum Raum A', 'Facility', 5, '00000000-0000-0000-0000-000000000011'),
  ('00000000-0000-0000-0001-000000000008', '00000000-0000-0000-0000-000000000001',
   'VPN Gateway', 'Service', 4, '00000000-0000-0000-0000-000000000012')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 6. CONTROL IMPLEMENTATIONS — ISO 27001
-- ============================================================
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct, notes)
SELECT
  '00000000-0000-0000-0000-000000000001',
  ic.id,
  CASE ic.control_ref
    WHEN 'A.5.1'  THEN 'implemented'::compliance_status   WHEN 'A.5.2'  THEN 'implemented'::compliance_status
    WHEN 'A.5.3'  THEN 'in_progress'::compliance_status   WHEN 'A.5.4'  THEN 'implemented'::compliance_status
    WHEN 'A.5.5'  THEN 'implemented'::compliance_status   WHEN 'A.5.6'  THEN 'implemented'::compliance_status
    WHEN 'A.5.7'  THEN 'not_started'::compliance_status   WHEN 'A.5.8'  THEN 'in_progress'::compliance_status
    WHEN 'A.5.9'  THEN 'implemented'::compliance_status   WHEN 'A.5.10' THEN 'implemented'::compliance_status
    WHEN 'A.5.11' THEN 'implemented'::compliance_status   WHEN 'A.5.12' THEN 'implemented'::compliance_status
    WHEN 'A.5.13' THEN 'in_progress'::compliance_status   WHEN 'A.5.14' THEN 'implemented'::compliance_status
    WHEN 'A.5.15' THEN 'implemented'::compliance_status   WHEN 'A.5.16' THEN 'implemented'::compliance_status
    WHEN 'A.5.17' THEN 'in_progress'::compliance_status   WHEN 'A.5.18' THEN 'implemented'::compliance_status
    WHEN 'A.5.19' THEN 'in_progress'::compliance_status   WHEN 'A.5.20' THEN 'implemented'::compliance_status
    WHEN 'A.5.21' THEN 'in_progress'::compliance_status   WHEN 'A.5.22' THEN 'in_progress'::compliance_status
    WHEN 'A.5.23' THEN 'not_started'::compliance_status   WHEN 'A.5.24' THEN 'implemented'::compliance_status
    WHEN 'A.5.25' THEN 'implemented'::compliance_status   WHEN 'A.5.26' THEN 'implemented'::compliance_status
    WHEN 'A.5.27' THEN 'implemented'::compliance_status   WHEN 'A.5.28' THEN 'in_progress'::compliance_status
    WHEN 'A.5.29' THEN 'in_progress'::compliance_status   WHEN 'A.5.30' THEN 'not_started'::compliance_status
    WHEN 'A.5.31' THEN 'implemented'::compliance_status   WHEN 'A.5.32' THEN 'implemented'::compliance_status
    WHEN 'A.5.33' THEN 'implemented'::compliance_status   WHEN 'A.5.34' THEN 'implemented'::compliance_status
    WHEN 'A.5.35' THEN 'in_progress'::compliance_status   WHEN 'A.5.36' THEN 'implemented'::compliance_status
    WHEN 'A.5.37' THEN 'implemented'::compliance_status
    WHEN 'A.6.1'  THEN 'implemented'::compliance_status   WHEN 'A.6.2'  THEN 'implemented'::compliance_status
    WHEN 'A.6.3'  THEN 'in_progress'::compliance_status   WHEN 'A.6.4'  THEN 'implemented'::compliance_status
    WHEN 'A.6.5'  THEN 'implemented'::compliance_status   WHEN 'A.6.6'  THEN 'implemented'::compliance_status
    WHEN 'A.6.7'  THEN 'implemented'::compliance_status   WHEN 'A.6.8'  THEN 'implemented'::compliance_status
    WHEN 'A.7.1'  THEN 'implemented'::compliance_status   WHEN 'A.7.2'  THEN 'in_progress'::compliance_status
    WHEN 'A.7.3'  THEN 'implemented'::compliance_status   WHEN 'A.7.4'  THEN 'not_started'::compliance_status
    WHEN 'A.7.5'  THEN 'implemented'::compliance_status   WHEN 'A.7.6'  THEN 'implemented'::compliance_status
    WHEN 'A.7.7'  THEN 'implemented'::compliance_status   WHEN 'A.7.8'  THEN 'implemented'::compliance_status
    WHEN 'A.7.9'  THEN 'in_progress'::compliance_status   WHEN 'A.7.10' THEN 'implemented'::compliance_status
    WHEN 'A.7.11' THEN 'implemented'::compliance_status   WHEN 'A.7.12' THEN 'implemented'::compliance_status
    WHEN 'A.7.13' THEN 'implemented'::compliance_status   WHEN 'A.7.14' THEN 'in_progress'::compliance_status
    WHEN 'A.8.1'  THEN 'implemented'::compliance_status   WHEN 'A.8.2'  THEN 'in_progress'::compliance_status
    WHEN 'A.8.3'  THEN 'implemented'::compliance_status   WHEN 'A.8.4'  THEN 'implemented'::compliance_status
    WHEN 'A.8.5'  THEN 'in_progress'::compliance_status   WHEN 'A.8.6'  THEN 'implemented'::compliance_status
    WHEN 'A.8.7'  THEN 'implemented'::compliance_status   WHEN 'A.8.8'  THEN 'in_progress'::compliance_status
    WHEN 'A.8.9'  THEN 'not_started'::compliance_status   WHEN 'A.8.10' THEN 'not_started'::compliance_status
    WHEN 'A.8.11' THEN 'not_started'::compliance_status   WHEN 'A.8.12' THEN 'not_started'::compliance_status
    WHEN 'A.8.13' THEN 'not_started'::compliance_status   WHEN 'A.8.14' THEN 'implemented'::compliance_status
    WHEN 'A.8.15' THEN 'implemented'::compliance_status   WHEN 'A.8.16' THEN 'not_started'::compliance_status
    WHEN 'A.8.17' THEN 'implemented'::compliance_status   WHEN 'A.8.18' THEN 'implemented'::compliance_status
    WHEN 'A.8.19' THEN 'in_progress'::compliance_status   WHEN 'A.8.20' THEN 'implemented'::compliance_status
    WHEN 'A.8.21' THEN 'implemented'::compliance_status   WHEN 'A.8.22' THEN 'implemented'::compliance_status
    WHEN 'A.8.23' THEN 'not_started'::compliance_status   WHEN 'A.8.24' THEN 'in_progress'::compliance_status
    WHEN 'A.8.25' THEN 'in_progress'::compliance_status   WHEN 'A.8.26' THEN 'in_progress'::compliance_status
    WHEN 'A.8.27' THEN 'implemented'::compliance_status   WHEN 'A.8.28' THEN 'not_started'::compliance_status
    WHEN 'A.8.29' THEN 'in_progress'::compliance_status   WHEN 'A.8.30' THEN 'implemented'::compliance_status
    WHEN 'A.8.31' THEN 'implemented'::compliance_status   WHEN 'A.8.32' THEN 'implemented'::compliance_status
    WHEN 'A.8.33' THEN 'in_progress'::compliance_status   WHEN 'A.8.34' THEN 'in_progress'::compliance_status
    ELSE 'not_started'::compliance_status
  END,
  CASE ic.control_ref
    WHEN 'A.5.1'  THEN 100  WHEN 'A.5.2'  THEN 100  WHEN 'A.5.3'  THEN 60
    WHEN 'A.5.4'  THEN 100  WHEN 'A.5.5'  THEN 100  WHEN 'A.5.6'  THEN 100
    WHEN 'A.5.7'  THEN 20   WHEN 'A.5.8'  THEN 65   WHEN 'A.5.9'  THEN 100
    WHEN 'A.5.10' THEN 100  WHEN 'A.5.11' THEN 100  WHEN 'A.5.12' THEN 100
    WHEN 'A.5.13' THEN 70   WHEN 'A.5.14' THEN 100  WHEN 'A.5.15' THEN 100
    WHEN 'A.5.16' THEN 100  WHEN 'A.5.17' THEN 75   WHEN 'A.5.18' THEN 100
    WHEN 'A.5.19' THEN 60   WHEN 'A.5.20' THEN 100  WHEN 'A.5.21' THEN 50
    WHEN 'A.5.22' THEN 65   WHEN 'A.5.23' THEN 10   WHEN 'A.5.24' THEN 100
    WHEN 'A.5.25' THEN 100  WHEN 'A.5.26' THEN 100  WHEN 'A.5.27' THEN 100
    WHEN 'A.5.28' THEN 55   WHEN 'A.5.29' THEN 70   WHEN 'A.5.30' THEN 25
    WHEN 'A.5.31' THEN 100  WHEN 'A.5.32' THEN 100  WHEN 'A.5.33' THEN 100
    WHEN 'A.5.34' THEN 100  WHEN 'A.5.35' THEN 80   WHEN 'A.5.36' THEN 100
    WHEN 'A.5.37' THEN 100
    WHEN 'A.6.1'  THEN 100  WHEN 'A.6.2'  THEN 100  WHEN 'A.6.3'  THEN 55
    WHEN 'A.6.4'  THEN 100  WHEN 'A.6.5'  THEN 100  WHEN 'A.6.6'  THEN 100
    WHEN 'A.6.7'  THEN 100  WHEN 'A.6.8'  THEN 100
    WHEN 'A.7.1'  THEN 100  WHEN 'A.7.2'  THEN 75   WHEN 'A.7.3'  THEN 100
    WHEN 'A.7.4'  THEN 15   WHEN 'A.7.5'  THEN 100  WHEN 'A.7.6'  THEN 100
    WHEN 'A.7.7'  THEN 100  WHEN 'A.7.8'  THEN 100  WHEN 'A.7.9'  THEN 60
    WHEN 'A.7.10' THEN 100  WHEN 'A.7.11' THEN 100  WHEN 'A.7.12' THEN 100
    WHEN 'A.7.13' THEN 100  WHEN 'A.7.14' THEN 70
    WHEN 'A.8.1'  THEN 100  WHEN 'A.8.2'  THEN 60   WHEN 'A.8.3'  THEN 100
    WHEN 'A.8.4'  THEN 100  WHEN 'A.8.5'  THEN 45   WHEN 'A.8.6'  THEN 100
    WHEN 'A.8.7'  THEN 100  WHEN 'A.8.8'  THEN 70   WHEN 'A.8.9'  THEN 20
    WHEN 'A.8.10' THEN 0    WHEN 'A.8.11' THEN 0    WHEN 'A.8.12' THEN 10
    WHEN 'A.8.13' THEN 0    WHEN 'A.8.14' THEN 100  WHEN 'A.8.15' THEN 100
    WHEN 'A.8.16' THEN 15   WHEN 'A.8.17' THEN 100  WHEN 'A.8.18' THEN 100
    WHEN 'A.8.19' THEN 65   WHEN 'A.8.20' THEN 100  WHEN 'A.8.21' THEN 100
    WHEN 'A.8.22' THEN 100  WHEN 'A.8.23' THEN 0    WHEN 'A.8.24' THEN 72
    WHEN 'A.8.25' THEN 70   WHEN 'A.8.26' THEN 60   WHEN 'A.8.27' THEN 100
    WHEN 'A.8.28' THEN 20   WHEN 'A.8.29' THEN 75   WHEN 'A.8.30' THEN 100
    WHEN 'A.8.31' THEN 100  WHEN 'A.8.32' THEN 100  WHEN 'A.8.33' THEN 65
    WHEN 'A.8.34' THEN 80
    ELSE 0
  END,
  NULL
FROM iso_controls ic
ON CONFLICT (tenant_id, iso_control_id) DO UPDATE SET
  status = EXCLUDED.status,
  completion_pct = EXCLUDED.completion_pct;

-- ============================================================
-- 7. CONTROL IMPLEMENTATIONS — NIST CSF 2.0
-- ============================================================
INSERT INTO control_implementations (tenant_id, nist_sub_id, status, completion_pct)
SELECT
  '00000000-0000-0000-0000-000000000001',
  ns.id,
  CASE
    WHEN ns.code LIKE 'GV.%' THEN
      CASE WHEN RANDOM() > 0.4 THEN 'implemented'::compliance_status ELSE 'in_progress'::compliance_status END
    WHEN ns.code LIKE 'ID.%' THEN
      CASE WHEN RANDOM() > 0.5 THEN 'implemented'::compliance_status WHEN RANDOM() > 0.3 THEN 'in_progress'::compliance_status ELSE 'not_started'::compliance_status END
    WHEN ns.code LIKE 'PR.%' THEN
      CASE WHEN RANDOM() > 0.35 THEN 'implemented'::compliance_status ELSE 'in_progress'::compliance_status END
    WHEN ns.code LIKE 'DE.%' THEN
      CASE WHEN RANDOM() > 0.5 THEN 'in_progress'::compliance_status ELSE 'not_started'::compliance_status END
    WHEN ns.code LIKE 'RS.%' THEN
      CASE WHEN RANDOM() > 0.45 THEN 'implemented'::compliance_status ELSE 'in_progress'::compliance_status END
    ELSE
      CASE WHEN RANDOM() > 0.6 THEN 'in_progress'::compliance_status ELSE 'not_started'::compliance_status END
  END,
  CASE
    WHEN ns.code LIKE 'GV.%' THEN (60 + (RANDOM() * 40))::INT
    WHEN ns.code LIKE 'ID.%' THEN (50 + (RANDOM() * 45))::INT
    WHEN ns.code LIKE 'PR.%' THEN (55 + (RANDOM() * 40))::INT
    WHEN ns.code LIKE 'DE.%' THEN (30 + (RANDOM() * 45))::INT
    WHEN ns.code LIKE 'RS.%' THEN (40 + (RANDOM() * 50))::INT
    ELSE (20 + (RANDOM() * 40))::INT
  END
FROM nist_subcategories ns
ON CONFLICT (tenant_id, nist_sub_id) DO NOTHING;

-- ============================================================
-- 8. DEMO RISIKEN
-- ============================================================
INSERT INTO risks (id, tenant_id, risk_ref, title, description, asset_id,
                   iso_control_ref, nist_sub_code, likelihood, impact,
                   treatment, status, owner_id, due_date, created_by)
VALUES
  ('00000000-0000-0000-0002-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-001', 'Fehlende MFA für Admin-Zugänge',
   'Admin-Accounts im Active Directory sind nicht durch MFA geschützt.',
   '00000000-0000-0000-0001-000000000003',
   'A.8.5', 'PR.AA-03', 4, 5,
   'mitigate'::risk_treatment, 'open'::risk_status,
   '00000000-0000-0000-0000-000000000011', '2026-02-28',
   '00000000-0000-0000-0000-000000000011'),

  ('00000000-0000-0000-0002-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-002', 'Backup-Verschlüsselung fehlt',
   'Tägliche Backups werden unverschlüsselt auf dem NAS gespeichert.',
   '00000000-0000-0000-0001-000000000005',
   'A.8.13', 'PR.DS-11', 4, 5,
   'mitigate'::risk_treatment, 'open'::risk_status,
   '00000000-0000-0000-0000-000000000011', '2026-03-05',
   '00000000-0000-0000-0000-000000000011'),

  ('00000000-0000-0000-0002-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-003', 'DRP nicht getestet (>12 Monate)',
   'Der Disaster Recovery Plan wurde seit über 12 Monaten nicht getestet.',
   '00000000-0000-0000-0001-000000000007',
   'A.5.30', 'RC.RP-03', 3, 5,
   'mitigate'::risk_treatment, 'in_treatment'::risk_status,
   '00000000-0000-0000-0000-000000000011', '2026-03-10',
   '00000000-0000-0000-0000-000000000012'),

  ('00000000-0000-0000-0002-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-004', 'Lieferanten-Assessment ausstehend',
   'Drei Lieferanten mit Zugriff auf kritische Systeme wurden seit 18 Monaten nicht bewertet.',
   NULL,
   'A.5.21', 'GV.SC-07', 3, 4,
   'mitigate'::risk_treatment, 'in_treatment'::risk_status,
   '00000000-0000-0000-0000-000000000011', '2026-03-20',
   '00000000-0000-0000-0000-000000000012'),

  ('00000000-0000-0000-0002-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-005', 'Threat Intelligence nicht etabliert',
   'Kein systematisches Monitoring von Bedrohungslagen und CVEs.',
   NULL,
   'A.5.7', 'ID.RA-02', 3, 3,
   'mitigate'::risk_treatment, 'open'::risk_status,
   '00000000-0000-0000-0000-000000000012', '2026-04-01',
   '00000000-0000-0000-0000-000000000011'),

  ('00000000-0000-0000-0002-000000000006',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-006', 'Security Awareness Training Q1 unvollständig',
   'Nur 60% der Mitarbeitenden haben das Pflicht-Training abgeschlossen.',
   NULL,
   'A.6.3', NULL, 2, 3,
   'mitigate'::risk_treatment, 'in_treatment'::risk_status,
   '00000000-0000-0000-0000-000000000012', '2026-03-31',
   '00000000-0000-0000-0000-000000000012'),

  ('00000000-0000-0000-0002-000000000007',
   '00000000-0000-0000-0000-000000000001',
   'RIS-2026-007', 'Datenmaskierung (DLP) nicht implementiert',
   'Keine technischen Kontrollen für Data Loss Prevention.',
   '00000000-0000-0000-0001-000000000004',
   'A.8.11', 'PR.DS-01', 2, 2,
   'accept'::risk_treatment, 'accepted'::risk_status,
   '00000000-0000-0000-0000-000000000011', '2026-06-30',
   '00000000-0000-0000-0000-000000000011')
ON CONFLICT (tenant_id, risk_ref) DO NOTHING;

-- ============================================================
-- 9. DEMO MASSNAHMEN
-- ============================================================
INSERT INTO actions (id, tenant_id, title, description, risk_id, priority, status, owner_id, due_date)
VALUES
  ('00000000-0000-0000-0003-000000000001',
   '00000000-0000-0000-0000-000000000001',
   'MFA für alle Admin-Accounts aktivieren',
   'Microsoft Authenticator für alle AD-Admin-Accounts einrichten.',
   '00000000-0000-0000-0002-000000000001', 1,
   'in_progress'::action_status,
   '00000000-0000-0000-0000-000000000011', '2026-02-28'),

  ('00000000-0000-0000-0003-000000000002',
   '00000000-0000-0000-0000-000000000001',
   'Backup-Verschlüsselung einrichten (AES-256)',
   'Veeam Backup Verschlüsselung aktivieren. Schlüsselverwaltung mit HashiCorp Vault.',
   '00000000-0000-0000-0002-000000000002', 1,
   'open'::action_status,
   '00000000-0000-0000-0000-000000000012', '2026-03-05'),

  ('00000000-0000-0000-0003-000000000003',
   '00000000-0000-0000-0000-000000000001',
   'DRP Testübung planen und durchführen',
   'Tabletop-Übung mit IT-Team und Management.',
   '00000000-0000-0000-0002-000000000003', 2,
   'open'::action_status,
   '00000000-0000-0000-0000-000000000011', '2026-03-10'),

  ('00000000-0000-0000-0003-000000000004',
   '00000000-0000-0000-0000-000000000001',
   'Lieferanten-Sicherheitsbewertung durchführen',
   'Fragebögen an 3 kritische Lieferanten senden.',
   '00000000-0000-0000-0002-000000000004', 2,
   'in_progress'::action_status,
   '00000000-0000-0000-0000-000000000012', '2026-03-20'),

  ('00000000-0000-0000-0003-000000000005',
   '00000000-0000-0000-0000-000000000001',
   'Patch-Management-Prozess überarbeiten',
   'SLA für kritische Patches: 24h. Automatisches Patching für Workstations.',
   NULL, 2,
   'done'::action_status,
   '00000000-0000-0000-0000-000000000011', '2026-02-15'),

  ('00000000-0000-0000-0003-000000000006',
   '00000000-0000-0000-0000-000000000001',
   'Awareness Training Q1 abschließen',
   'Erinnerungsmail an ausstehende 40% senden.',
   '00000000-0000-0000-0002-000000000006', 3,
   'in_progress'::action_status,
   '00000000-0000-0000-0000-000000000012', '2026-03-31'),

  ('00000000-0000-0000-0003-000000000007',
   '00000000-0000-0000-0000-000000000001',
   'NIS2-Compliance-Gap-Analyse',
   'Vollständige Gap-Analyse gegen NIS2-Anforderungen (Art. 21).',
   NULL, 2,
   'open'::action_status,
   '00000000-0000-0000-0000-000000000011', '2026-04-15'),

  ('00000000-0000-0000-0003-000000000008',
   '00000000-0000-0000-0000-000000000001',
   'Cloud-Sicherheitsrichtlinie erstellen (A.5.23)',
   'Richtlinie für Cloud-Dienste gemäß ISO A.5.23.',
   NULL, 3,
   'open'::action_status,
   '00000000-0000-0000-0000-000000000012', '2026-04-30')
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 10. AUDIT LOG
-- ============================================================
INSERT INTO audit_log (tenant_id, user_id, user_email, event_type, entity_type, entity_id, new_value, created_at)
VALUES
  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000011', 'ciso@govrix.io',
   'RISK_CREATED', 'Risk', '00000000-0000-0000-0002-000000000001',
   '{"title":"Fehlende MFA für Admin-Zugänge","score":20}',
   NOW() - INTERVAL '2 hours'),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000012', 'analyst@govrix.io',
   'CONTROL_UPDATED', 'ISO Control', NULL,
   '{"control_ref":"A.8.24","status":"in_progress","completion_pct":72}',
   NOW() - INTERVAL '4 hours'),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000011', 'ciso@govrix.io',
   'ACTION_COMPLETED', 'Action', '00000000-0000-0000-0003-000000000005',
   '{"status":"done"}',
   NOW() - INTERVAL '1 day'),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000012', 'analyst@govrix.io',
   'RISK_UPDATED', 'Risk', '00000000-0000-0000-0002-000000000003',
   '{"status":"in_treatment","notes":"DRP-Testtermin 15.03 vereinbart"}',
   NOW() - INTERVAL '2 days'),

  ('00000000-0000-0000-0000-000000000001',
   '00000000-0000-0000-0000-000000000010', 'admin@govrix.io',
   'LOGIN', 'Auth', NULL,
   '{"role":"admin"}',
   NOW() - INTERVAL '3 hours');

-- ============================================================
-- 11. VERIFIZIERUNG
-- ============================================================
DO $$
DECLARE
  v_iso_count  INT;
  v_nist_fn    INT;
  v_nist_sub   INT;
  v_nis2_count INT;
  v_risks      INT;
  v_actions    INT;
  v_users      INT;
  v_impls      INT;
BEGIN
  SELECT COUNT(*) INTO v_iso_count  FROM iso_controls;
  SELECT COUNT(*) INTO v_nist_fn    FROM nist_functions;
  SELECT COUNT(*) INTO v_nist_sub   FROM nist_subcategories;
  SELECT COUNT(*) INTO v_nis2_count FROM nis2_requirements;
  SELECT COUNT(*) INTO v_risks      FROM risks;
  SELECT COUNT(*) INTO v_actions    FROM actions;
  SELECT COUNT(*) INTO v_users      FROM users;
  SELECT COUNT(*) INTO v_impls      FROM control_implementations;

  RAISE NOTICE '============================================';
  RAISE NOTICE 'Govrix ISMS — Seed erfolgreich!';
  RAISE NOTICE '============================================';
  RAISE NOTICE 'ISO 27001 Controls:     % / 93 erwartet', v_iso_count;
  RAISE NOTICE 'NIST CSF 2.0 Functions: % / 6 erwartet',  v_nist_fn;
  RAISE NOTICE 'NIST Subcategories:     %',                v_nist_sub;
  RAISE NOTICE 'NIS2/DORA:              %',                v_nis2_count;
  RAISE NOTICE 'Demo Risiken:           %',                v_risks;
  RAISE NOTICE 'Demo Maßnahmen:         %',                v_actions;
  RAISE NOTICE 'Demo Users:             %',                v_users;
  RAISE NOTICE 'Control Implementations: %',               v_impls;
  RAISE NOTICE '============================================';
  RAISE NOTICE 'Login: ciso@govrix.io / Ciso1234!';
  RAISE NOTICE '============================================';
END $$;
