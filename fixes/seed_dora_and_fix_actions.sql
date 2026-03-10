-- ============================================================
-- 1) DORA REQUIREMENTS SEEDEN
-- ============================================================

-- Tabelle prüfen / anlegen falls nicht vorhanden
CREATE TABLE IF NOT EXISTS nis2_requirements (
  id SERIAL PRIMARY KEY,
  tenant_id UUID,
  req_ref VARCHAR(50),
  article VARCHAR(100),
  title VARCHAR(255),
  category VARCHAR(100),
  framework VARCHAR(20) DEFAULT 'NIS2',
  status VARCHAR(50) DEFAULT 'not_started',
  completion_pct INTEGER DEFAULT 0
);

-- DORA Requirements einfügen (nur wenn noch nicht vorhanden)
INSERT INTO nis2_requirements (tenant_id, req_ref, article, title, category, framework, status, completion_pct)
SELECT
  '00000000-0000-0000-0000-000000000001',
  req_ref, article, title, category, 'DORA', status, completion_pct
FROM (VALUES
  ('DORA-5.1',  'Art. 5',  'IKT-Risikomanagement-Rahmen einrichten',          'IKT-Risikomanagement',    'not_started', 0),
  ('DORA-5.2',  'Art. 5',  'IKT-Risikomanagement in Governance integrieren',   'IKT-Risikomanagement',    'not_started', 0),
  ('DORA-6.1',  'Art. 6',  'IKT-Systeme und Prozesse identifizieren',          'IKT-Risikomanagement',    'in_progress', 40),
  ('DORA-7.1',  'Art. 7',  'IKT-Systeme kontinuierlich ' || chr(252) || 'berwachen', 'Schutz & Pr' || chr(228) || 'vention', 'in_progress', 30),
  ('DORA-9.1',  'Art. 9',  'Schutz- und Pr' || chr(228) || 'ventionsma' || chr(223) || 'nahmen implementieren', 'Schutz & Pr' || chr(228) || 'vention', 'not_started', 0),
  ('DORA-9.2',  'Art. 9',  'Zugangskontrollen und Verschl' || chr(252) || 'sselungsrichtlinien', 'Schutz & Pr' || chr(228) || 'vention', 'in_progress', 55),
  ('DORA-10.1', 'Art. 10', 'Anomalie- und Angriffserkennung implementieren',   'Erkennung',               'not_started', 0),
  ('DORA-11.1', 'Art. 11', 'IKT-Reaktionsplan dokumentieren',                  'Reaktion & Wiederherst.', 'in_progress', 60),
  ('DORA-11.2', 'Art. 11', 'Kommunikationsplan f' || chr(252) || 'r Vorf' || chr(228) || 'lle erstellen', 'Reaktion & Wiederherst.', 'not_started', 0),
  ('DORA-12.1', 'Art. 12', 'Backup- und Wiederherstellungsrichtlinien',         'Backup & Recovery',       'in_progress', 50),
  ('DORA-12.2', 'Art. 12', 'Wiederherstellungsziele (RTO/RPO) definieren',     'Backup & Recovery',       'not_started', 0),
  ('DORA-13.1', 'Art. 13', 'Lessons Learned nach Vorf' || chr(228) || 'llen dokumentieren', 'Lernen & Weiterentw.', 'not_started', 0),
  ('DORA-17.1', 'Art. 17', 'IKT-Vorfallsmanagement-Prozess einrichten',        'Vorfallsmanagement',      'in_progress', 70),
  ('DORA-17.2', 'Art. 17', 'Vorfallskategorisierung und -klassifizierung',      'Vorfallsmanagement',      'not_started', 0),
  ('DORA-19.1', 'Art. 19', 'Meldung schwerwiegender IKT-Vorf' || chr(228) || 'lle an Beh' || chr(246) || 'rden', 'Meldepflichten', 'not_started', 0),
  ('DORA-19.2', 'Art. 19', 'Erste Meldung innerhalb 4 Stunden sicherstellen',  'Meldepflichten',           'not_started', 0),
  ('DORA-24.1', 'Art. 24', 'Programm f' || chr(252) || 'r digitale Resilienztests erstellen', 'Resilienztests', 'not_started', 0),
  ('DORA-25.1', 'Art. 25', 'J' || chr(228) || 'hrliche IKT-Systemtests durchf' || chr(252) || 'hren', 'Resilienztests', 'not_started', 0),
  ('DORA-26.1', 'Art. 26', 'TLPT (Threat-Led Penetration Test) durchf' || chr(252) || 'hren', 'Resilienztests (TLPT)', 'in_progress', 35),
  ('DORA-28.1', 'Art. 28', 'IKT-Drittanbieterrisiken identifizieren',          'Drittanbieter-Risiko',    'in_progress', 45),
  ('DORA-28.2', 'Art. 28', 'Kritische IKT-Dienstleister registrieren',         'Drittanbieter-Risiko',    'not_started', 0),
  ('DORA-30.1', 'Art. 30', 'Vertragliche Mindestanforderungen an IKT-Anbieter','Drittanbieter-Risiko',    'not_started', 0)
) AS t(req_ref, article, title, category, status, completion_pct)
WHERE NOT EXISTS (
  SELECT 1 FROM nis2_requirements WHERE req_ref = t.req_ref
);


-- ============================================================
-- 2) FRAMEWORK-SPALTE ZU ACTIONS HINZUFÜGEN
-- ============================================================

ALTER TABLE actions ADD COLUMN IF NOT EXISTS framework VARCHAR(20) DEFAULT 'iso';

-- ============================================================
-- 3) BESTEHENDE ACTIONS KORREKT TAGGEN
-- ============================================================

-- NIS2 Actions
UPDATE actions SET framework = 'nis2'
WHERE title ILIKE '%NIS2%'
   OR title ILIKE '%Meldeprozess%'
   OR title ILIKE '%Meldepflicht%'
   OR title ILIKE '%24h%72h%';

-- DORA Actions  
UPDATE actions SET framework = 'dora'
WHERE title ILIKE '%DORA%'
   OR title ILIKE '%TLPT%'
   OR title ILIKE '%Threat-Led%'
   OR title ILIKE '%Vorfallsmanagement%'
   OR title ILIKE '%IKT%'
   OR title ILIKE '%Resilienzt%';

-- NIST Actions
UPDATE actions SET framework = 'nist'
WHERE title ILIKE '%NIST%'
   OR title ILIKE '%CSF%';

-- ISO bleibt Standard für alle anderen (bereits DEFAULT 'iso')

-- ============================================================
-- 4) ERGEBNIS PRÜFEN
-- ============================================================
SELECT framework, COUNT(*) as anzahl
FROM actions
GROUP BY framework
ORDER BY framework;

SELECT framework, title FROM actions ORDER BY framework, title;
