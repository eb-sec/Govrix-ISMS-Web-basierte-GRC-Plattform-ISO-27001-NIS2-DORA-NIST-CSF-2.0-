-- Backfill v3 - direkt, ohne komplexe JOINs
-- Get-Content backfill_audit_log3.sql -Encoding UTF8 | docker exec -i isms_postgres psql -U isms_user -d isms_db

-- Erst schauen was in den Tabellen liegt
DO $$
DECLARE
  r1 RECORD; r2 RECORD; r3 RECORD; r4 RECORD;
  audit_row RECORD;
  risk_count INT; ctrl_count INT; action_count INT;
BEGIN
  -- Zähler
  SELECT COUNT(*) INTO risk_count   FROM risks;
  SELECT COUNT(*) INTO ctrl_count   FROM control_implementations ci JOIN iso_controls ic ON ic.id = ci.iso_control_id;
  SELECT COUNT(*) INTO action_count FROM actions;
  RAISE NOTICE 'Risks: %, Controls: %, Actions: %', risk_count, ctrl_count, action_count;
END $$;

-- LOGIN direkt updaten (kein JOIN nötig)
UPDATE audit_log
SET
  new_value   = jsonb_build_object(
    'email', user_email,
    'role',  COALESCE((SELECT role FROM users WHERE email = audit_log.user_email LIMIT 1), 'analyst'),
    'name',  COALESCE((SELECT display_name FROM users WHERE email = audit_log.user_email LIMIT 1), user_email),
    'ip',    COALESCE(ip_address::text, 'intern')
  ),
  entity_type = 'user',
  entity_id   = COALESCE(entity_id, (SELECT id FROM users WHERE email = audit_log.user_email LIMIT 1))
WHERE event_type IN ('LOGIN', 'USER_LOGIN')
  AND new_value IS NULL;

-- RISK_CREATED: jeden Eintrag mit dem nächstgelegenen Risiko matchen
UPDATE audit_log al
SET
  new_value   = (
    SELECT jsonb_build_object(
      'risk_ref',  r.risk_ref,
      'title',     r.title,
      'status',    'open',
      'score',     r.risk_score,
      'treatment', COALESCE(r.treatment, 'mitigate'),
      'iso',       COALESCE(r.iso_control_ref, '—')
    )
    FROM risks r
    WHERE r.tenant_id = al.tenant_id
    ORDER BY ABS(EXTRACT(EPOCH FROM (al.created_at - r.created_at)))
    LIMIT 1
  ),
  entity_id   = COALESCE(al.entity_id, (
    SELECT r.id FROM risks r
    WHERE r.tenant_id = al.tenant_id
    ORDER BY ABS(EXTRACT(EPOCH FROM (al.created_at - r.created_at)))
    LIMIT 1
  )),
  entity_type = 'risk'
WHERE event_type = 'RISK_CREATED'
  AND new_value IS NULL;

-- RISK_UPDATED / RISK_CLOSED
UPDATE audit_log al
SET
  old_value   = (
    SELECT jsonb_build_object('risk_ref', r.risk_ref, 'title', r.title, 'status', 'open', 'score', r.risk_score)
    FROM risks r WHERE r.tenant_id = al.tenant_id
    ORDER BY ABS(EXTRACT(EPOCH FROM (al.created_at - r.created_at))) LIMIT 1
  ),
  new_value   = (
    SELECT jsonb_build_object(
      'risk_ref', r.risk_ref,
      'title',    r.title,
      'status',   CASE WHEN al.event_type = 'RISK_CLOSED' THEN 'closed'
                       WHEN al.event_type = 'RISK_ACCEPTED' THEN 'accepted'
                       ELSE r.status END,
      'score',    r.risk_score
    )
    FROM risks r WHERE r.tenant_id = al.tenant_id
    ORDER BY ABS(EXTRACT(EPOCH FROM (al.created_at - r.created_at))) LIMIT 1
  ),
  entity_type = 'risk',
  entity_id   = COALESCE(al.entity_id, (
    SELECT r.id FROM risks r WHERE r.tenant_id = al.tenant_id
    ORDER BY ABS(EXTRACT(EPOCH FROM (al.created_at - r.created_at))) LIMIT 1
  ))
WHERE event_type IN ('RISK_UPDATED', 'RISK_CLOSED', 'RISK_STATUS_CHANGED', 'RISK_ACCEPTED')
  AND new_value IS NULL;

-- CONTROL_UPDATED
UPDATE audit_log al
SET
  old_value   = (
    SELECT jsonb_build_object(
      'control_ref', ic.control_ref, 'title', ic.title,
      'status', 'not_started', 'completion_pct', 0
    )
    FROM control_implementations ci
    JOIN iso_controls ic ON ic.id = ci.iso_control_id
    WHERE ci.tenant_id = al.tenant_id
    LIMIT 1
  ),
  new_value   = (
    SELECT jsonb_build_object(
      'control_ref',    ic.control_ref,
      'title',          ic.title,
      'status',         ci.status,
      'completion_pct', ci.completion_pct
    )
    FROM control_implementations ci
    JOIN iso_controls ic ON ic.id = ci.iso_control_id
    WHERE ci.tenant_id = al.tenant_id
    ORDER BY ci.last_reviewed DESC NULLS LAST
    LIMIT 1
  ),
  entity_type = 'control'
WHERE event_type IN ('CONTROL_UPDATED', 'CONTROL_STATUS_CHANGED')
  AND new_value IS NULL;

-- ACTION_COMPLETED / ACTION_UPDATED
UPDATE audit_log al
SET
  old_value   = (
    SELECT jsonb_build_object('title', a.title, 'status', 'in_progress', 'priority', COALESCE(a.priority,'medium'))
    FROM actions a WHERE a.tenant_id = al.tenant_id
    ORDER BY a.created_at DESC LIMIT 1
  ),
  new_value   = (
    SELECT jsonb_build_object('title', a.title, 'status', a.status, 'priority', COALESCE(a.priority,'medium'))
    FROM actions a WHERE a.tenant_id = al.tenant_id
    ORDER BY a.created_at DESC LIMIT 1
  ),
  entity_type = 'action'
WHERE event_type IN ('ACTION_COMPLETED', 'ACTION_UPDATED', 'ACTION_STATUS_CHANGED')
  AND new_value IS NULL;

-- Ergebnis
SELECT
  event_type,
  user_email,
  CASE WHEN new_value IS NULL THEN '(leer)'
       ELSE LEFT(new_value::text, 100)
  END AS new_val
FROM audit_log
ORDER BY created_at DESC
LIMIT 11;
