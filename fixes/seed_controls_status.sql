DO $$
DECLARE
  tid uuid := '00000000-0000-0000-0000-000000000001';
BEGIN

DELETE FROM control_implementations WHERE tenant_id = tid AND iso_control_id IS NOT NULL;

-- Organisatorisch: implemented (100%)
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'implemented', 100 FROM iso_controls
WHERE control_ref IN ('A.5.1','A.5.2','A.5.9','A.5.10','A.5.12','A.5.15','A.5.17','A.5.18','A.5.31','A.5.32');

-- Organisatorisch: in_progress hoch (65%)
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 65 FROM iso_controls
WHERE control_ref IN ('A.5.3','A.5.4','A.5.5','A.5.7','A.5.8','A.5.11','A.5.13','A.5.14','A.5.16','A.5.19','A.5.20','A.5.21','A.5.22');

-- Organisatorisch: in_progress niedrig (30%)
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 30 FROM iso_controls
WHERE control_ref IN ('A.5.23','A.5.24','A.5.25','A.5.26','A.5.27','A.5.28','A.5.29','A.5.30');

-- Personenbezogen: implemented
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'implemented', 100 FROM iso_controls
WHERE control_ref IN ('A.6.1','A.6.2','A.6.3','A.6.4','A.6.5');

-- Personenbezogen: in_progress
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 55 FROM iso_controls
WHERE control_ref IN ('A.6.6','A.6.7','A.6.8');

-- Physisch: implemented
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'implemented', 100 FROM iso_controls
WHERE control_ref IN ('A.7.1','A.7.2','A.7.3','A.7.5','A.7.6','A.7.7','A.7.8');

-- Physisch: in_progress hoch
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 65 FROM iso_controls
WHERE control_ref IN ('A.7.4','A.7.9','A.7.10','A.7.11','A.7.12');

-- Physisch: in_progress niedrig
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 25 FROM iso_controls
WHERE control_ref IN ('A.7.13','A.7.14');

-- Technologisch: implemented
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'implemented', 100 FROM iso_controls
WHERE control_ref IN ('A.8.1','A.8.5','A.8.7','A.8.8','A.8.13','A.8.15','A.8.16','A.8.20');

-- Technologisch: in_progress hoch
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 50 FROM iso_controls
WHERE control_ref IN ('A.8.2','A.8.3','A.8.9','A.8.12','A.8.14','A.8.17','A.8.21','A.8.22','A.8.24');

-- Technologisch: in_progress niedrig
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'in_progress', 20 FROM iso_controls
WHERE control_ref IN ('A.8.4','A.8.6','A.8.10','A.8.11','A.8.18','A.8.19','A.8.23','A.8.25','A.8.26','A.8.27','A.8.28');

-- Rest: not_started
INSERT INTO control_implementations (tenant_id, iso_control_id, status, completion_pct)
SELECT tid, id, 'not_started', 0 FROM iso_controls
WHERE id NOT IN (
  SELECT iso_control_id FROM control_implementations
  WHERE tenant_id = tid AND iso_control_id IS NOT NULL
);

END $$;

SELECT status, COUNT(*) FROM control_implementations
WHERE tenant_id = '00000000-0000-0000-0000-000000000001' AND iso_control_id IS NOT NULL
GROUP BY status ORDER BY status;
