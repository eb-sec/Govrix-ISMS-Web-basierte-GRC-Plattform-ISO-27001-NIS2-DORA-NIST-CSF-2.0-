-- Backfill old_value / new_value für bestehende Audit-Log-Einträge
-- Ausführen mit:
-- Get-Content backfill_audit_log.sql -Encoding UTF8 | docker exec -i isms_postgres psql -U isms_user -d isms_db

-- 1. LOGIN-Einträge: new_value = Benutzerinfo
UPDATE audit_log
SET
  new_value  = jsonb_build_object(
    'email', user_email,
    'role',  COALESCE((SELECT role FROM users WHERE email = audit_log.user_email LIMIT 1), 'analyst'),
    'name',  COALESCE((SELECT display_name FROM users WHERE email = audit_log.user_email LIMIT 1), user_email)
  ),
  entity_type = 'user',
  entity_id   = COALESCE(entity_id, (SELECT id FROM users WHERE email = audit_log.user_email LIMIT 1))
WHERE event_type IN ('LOGIN', 'USER_LOGIN')
  AND new_value IS NULL;

-- 2. RISK_CREATED-Einträge
UPDATE audit_log al
SET new_value = jsonb_build_object(
    'risk_ref',        COALESCE(r.risk_ref, 'RIS-2026-???'),
    'title',           COALESCE(r.title,    'Unbekanntes Risiko'),
    'status',          COALESCE(r.status,   'open'),
    'likelihood',      COALESCE(r.likelihood, 3),
    'impact',          COALESCE(r.impact, 3),
    'score',           COALESCE(r.risk_score, 9),
    'iso_control_ref', COALESCE(r.iso_control_ref, '—'),
    'treatment',       COALESCE(r.treatment, 'mitigate')
  ),
  entity_type = 'risk',
  entity_id   = COALESCE(al.entity_id, r.id)
FROM risks r
WHERE al.event_type IN ('RISK_CREATED')
  AND al.new_value IS NULL
  AND r.tenant_id = al.tenant_id
  AND r.created_at >= al.created_at - interval '10 minutes'
  AND r.created_at <= al.created_at + interval '10 minutes';

-- 3. RISK_UPDATED / RISK_CLOSED / RISK_STATUS_CHANGED
UPDATE audit_log al
SET
  old_value = jsonb_build_object('risk_ref', r.risk_ref, 'title', r.title, 'status', 'open'),
  new_value = jsonb_build_object(
    'risk_ref', r.risk_ref,
    'title',    r.title,
    'status',   CASE WHEN al.event_type = 'RISK_CLOSED' THEN 'closed' ELSE r.status END,
    'score',    r.risk_score
  ),
  entity_type = 'risk',
  entity_id   = COALESCE(al.entity_id, r.id)
FROM risks r
WHERE al.event_type IN ('RISK_UPDATED', 'RISK_CLOSED', 'RISK_STATUS_CHANGED', 'RISK_ACCEPTED')
  AND al.new_value IS NULL
  AND r.tenant_id = al.tenant_id
ORDER BY r.updated_at DESC;

-- 4. CONTROL_UPDATED-Einträge (ISO Controls)
UPDATE audit_log al
SET
  old_value = jsonb_build_object(
    'control_ref', ic.control_ref,
    'title',       ic.title,
    'status',      'not_started',
    'completion_pct', 0
  ),
  new_value = jsonb_build_object(
    'control_ref',    ic.control_ref,
    'title',          ic.title,
    'status',         COALESCE(ci.status, 'in_progress'),
    'completion_pct', COALESCE(ci.completion_pct, 50)
  ),
  entity_type = 'control',
  entity_id   = ic.id::text
FROM control_implementations ci
JOIN iso_controls ic ON ic.id = ci.iso_control_id
WHERE al.event_type IN ('CONTROL_UPDATED', 'CONTROL_STATUS_CHANGED')
  AND al.new_value IS NULL
  AND ci.tenant_id = al.tenant_id
LIMIT 10;

-- 5. ACTION_COMPLETED / ACTION_UPDATED (Kanban)
UPDATE audit_log al
SET
  old_value = jsonb_build_object('title', a.title, 'status', 'in_progress'),
  new_value = jsonb_build_object(
    'title',    a.title,
    'status',   a.status,
    'priority', COALESCE(a.priority, 'medium')
  ),
  entity_type = 'action',
  entity_id   = a.id::text
FROM actions a
WHERE al.event_type IN ('ACTION_COMPLETED', 'ACTION_UPDATED', 'ACTION_STATUS_CHANGED')
  AND al.new_value IS NULL
  AND a.tenant_id = al.tenant_id
LIMIT 5;

-- Überprüfung
SELECT event_type, user_email,
       COALESCE(new_value::text, '(leer)') AS new_val_preview
FROM audit_log
ORDER BY created_at DESC
LIMIT 10;
