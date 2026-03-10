-- ============================================================
-- Govrix ISMS — NIST & NIS2/DORA Data Fix v2
-- ============================================================

-- 1. Unique constraints on control_implementations
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_ci_tenant_nist'
  ) THEN
    ALTER TABLE control_implementations
      ADD CONSTRAINT uq_ci_tenant_nist UNIQUE (tenant_id, nist_sub_id);
  END IF;
END $$;

-- 2. Seed NIST control_implementations (alle Subcategories → not_started)
INSERT INTO control_implementations (tenant_id, nist_sub_id, status, completion_pct)
SELECT
  '00000000-0000-0000-0000-000000000001',
  ns.id,
  'not_started',
  0
FROM nist_subcategories ns
ON CONFLICT (tenant_id, nist_sub_id) DO NOTHING;

-- Demo-Scores: implemented
UPDATE control_implementations ci
SET status = 'implemented', completion_pct = 100
FROM nist_subcategories ns
WHERE ci.nist_sub_id = ns.id
  AND ci.tenant_id = '00000000-0000-0000-0000-000000000001'
  AND ns.code IN (
    'GV.OC-01','GV.OC-02','GV.OC-03',
    'GV.RM-01','GV.RM-02','GV.RM-03',
    'ID.AM-01','ID.AM-02',
    'ID.RA-01','ID.RA-02','ID.RA-03',
    'PR.AA-01','PR.AA-02','PR.AA-03',
    'PR.DS-01','PR.DS-02',
    'DE.CM-01',
    'RS.MA-01','RS.MA-02',
    'RC.RP-01'
  );

-- Demo-Scores: in_progress
UPDATE control_implementations ci
SET status = 'in_progress', completion_pct = 50
FROM nist_subcategories ns
WHERE ci.nist_sub_id = ns.id
  AND ci.tenant_id = '00000000-0000-0000-0000-000000000001'
  AND ns.code IN (
    'GV.OC-04','GV.OC-05',
    'GV.RM-04','GV.RM-05',
    'ID.AM-03','ID.AM-04',
    'ID.RA-04','ID.RA-05',
    'PR.AA-04','PR.AA-05',
    'PR.DS-10','PR.DS-11',
    'DE.CM-02','DE.CM-03',
    'RS.MA-03','RS.MA-04',
    'RC.RP-02','RC.RP-03'
  );

-- 3. NIS2/DORA Compliance Tabelle (mit INTEGER FK)
CREATE TABLE IF NOT EXISTS nis2_compliance (
  id             SERIAL PRIMARY KEY,
  tenant_id      UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  req_id         INTEGER NOT NULL REFERENCES nis2_requirements(id) ON DELETE CASCADE,
  status         compliance_status DEFAULT 'not_started',
  completion_pct SMALLINT DEFAULT 0 CHECK (completion_pct BETWEEN 0 AND 100),
  notes          TEXT,
  owner_id       UUID REFERENCES users(id),
  due_date       DATE,
  last_reviewed  DATE,
  UNIQUE (tenant_id, req_id)
);
CREATE INDEX IF NOT EXISTS idx_nis2c_tenant ON nis2_compliance(tenant_id);

-- 4. Seed NIS2/DORA compliance rows
INSERT INTO nis2_compliance (tenant_id, req_id, status, completion_pct)
SELECT
  '00000000-0000-0000-0000-000000000001',
  nr.id,
  'not_started',
  0
FROM nis2_requirements nr
ON CONFLICT (tenant_id, req_id) DO NOTHING;

-- Demo-Scores: implemented
UPDATE nis2_compliance nc
SET status = 'implemented', completion_pct = 100
FROM nis2_requirements nr
WHERE nc.req_id = nr.id
  AND nc.tenant_id = '00000000-0000-0000-0000-000000000001'
  AND nr.req_ref IN ('NIS2-1','NIS2-2','NIS2-7','NIS2-8','NIS2-9','NIS2-10',
                     'DORA-1','DORA-4','DORA-5');

-- Demo-Scores: in_progress
UPDATE nis2_compliance nc
SET status = 'in_progress', completion_pct = 55
FROM nis2_requirements nr
WHERE nc.req_id = nr.id
  AND nc.tenant_id = '00000000-0000-0000-0000-000000000001'
  AND nr.req_ref IN ('NIS2-3','NIS2-4','NIS2-5','NIS2-6',
                     'DORA-2','DORA-3','DORA-6','DORA-7');

-- 5. Verify
SELECT 'NIST implementations' AS check, COUNT(*) AS count
FROM control_implementations
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
  AND nist_sub_id IS NOT NULL
UNION ALL
SELECT 'NIS2/DORA compliance rows', COUNT(*)
FROM nis2_compliance
WHERE tenant_id = '00000000-0000-0000-0000-000000000001';
