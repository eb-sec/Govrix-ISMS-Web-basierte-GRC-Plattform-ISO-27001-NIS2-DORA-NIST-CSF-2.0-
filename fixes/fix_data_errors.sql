-- ============================================================
-- Govrix ISMS – Datenkorrektur (Faktische Fehler)
-- Geprüft gegen offizielle Quellen:
--   DORA: Regulation (EU) 2022/2554, EUR-Lex
--   NIST CSF 2.0: NIST.CSWP.29 (Feb 2024)
-- ============================================================

-- ------------------------------------------------------------
-- 1. DORA Art. 5: Titel korrigieren
--    Fehler: "IKT-Risikomanagement-Rahmen" (= Art. 6)
--    Korrekt: Art. 5 = Governance-Regelungen des Managements
-- ------------------------------------------------------------
UPDATE nis2_requirements
SET
    title       = 'Governance-Regelungen (IKT-Risikomanagement)',
    description = 'Das Leitungsorgan des Finanzunternehmens definiert, genehmigt und überwacht alle Regelungen zur Steuerung des IKT-Risikomanagement-Rahmens (Art. 5 DORA). Hierzu gehören Verantwortlichkeiten, Risikoappetit und Aufsichtspflichten.'
WHERE framework = 'DORA'
  AND article   = 'Art. 5';

-- ------------------------------------------------------------
-- 2. NIST GV.OC-01: Kontext korrigieren
--    Fehler: "Missionsrolle der Organisation in der Lieferkette"
--    Korrekt: Organisationsmission als Grundlage für Cyber-RM
-- ------------------------------------------------------------
UPDATE nist_subcategories
SET description = 'Die Organisationsmission wird verstanden und priorisiert Cybersecurity-Risikomanagement-Entscheidungen'
WHERE code = 'GV.OC-01';

-- ------------------------------------------------------------
-- 3. NIST GV.RM-01: Beschreibung korrigieren
--    Fehler: Risikoappetit/-toleranz (= GV.RM-02)
--    Korrekt GV.RM-01: Risikomanagementziele festlegen
-- ------------------------------------------------------------
UPDATE nist_subcategories
SET description = 'Cybersecurity-Risikomanagementziele werden festgelegt und mit organisatorischen Stakeholdern vereinbart'
WHERE code = 'GV.RM-01';

-- ------------------------------------------------------------
-- 4. NIST GV.RM-02: Beschreibung korrigieren
--    Fehler: "Infrastruktur und Prozesse" (zu vage / falsch)
--    Korrekt GV.RM-02: Risikoappetit und -toleranzerklärungen
-- ------------------------------------------------------------
UPDATE nist_subcategories
SET description = 'Risikoappetit- und Risikotoleranzaussagen werden bestimmt, genehmigt und kommuniziert'
WHERE code = 'GV.RM-02';

-- ------------------------------------------------------------
-- 5. NIST GV.RM-06: Beschreibung korrigieren
--    Fehler: "Strategie für Drittrisiken" (= GV.SC, nicht GV.RM)
--    Korrekt GV.RM-06: Standardisierter Risikoprozess
-- ------------------------------------------------------------
UPDATE nist_subcategories
SET description = 'Ein standardisierter Cybersecurity-Risikoprozess wird im gesamten Unternehmen angewendet und kommuniziert'
WHERE code = 'GV.RM-06';

-- ------------------------------------------------------------
-- Verifikation
-- ------------------------------------------------------------
SELECT 'DORA Art. 5' AS check, title FROM nis2_requirements WHERE framework = 'DORA' AND article = 'Art. 5'
UNION ALL
SELECT code, description FROM nist_subcategories WHERE code IN ('GV.OC-01','GV.RM-01','GV.RM-02','GV.RM-06')
ORDER BY 1;
