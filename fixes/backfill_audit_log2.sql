-- Backfill Audit-Log (korrigiert)
-- Get-Content backfill_audit_log2.sql -Encoding UTF8 | docker exec -i isms_postgres psql -U isms_user -d isms_db

-- 1. LOGIN
UPDATE audit_log
SET
  new_value   = jsonb_build_object(
    'email', user_email,
    'role',  COALESCE((SELECT role FROM users WHERE email = audit_log.user_email LIMIT 1), 'analyst'),
    'name',  COALESCE((SELECT display_name FROM users WHERE email = audit_log.user_email LIMIT 1), user_email)
  ),
  entity_type = 'user',
  entity_id   = COALESCE(entity_id, (SELECT id FROM users WHERE email = audit_log.user_email LIMIT 1))
WHERE event_type IN ('LOGIN', 'USER_LOGIN')
  AND new_value IS NULL;

-- 2. RISK_CREATED
UPDATE audit_log al
SET
  new_value   = jsonb_build_object(
    'risk_ref',        r.risk_ref,
    'title',           r.title,
    'status',          'open',
    'likelihood',      r.likelihood,
    'impact',          r.impact,
    'score',           r.risk_score,
    'iso_control_ref', COALESCE(r.iso_control_ref, '—'),
    'treatment',       COALESCE(r.treatment, 'mitigate')
  ),
  entity_type = 'risk',
  entity_id   = r.id
FROM (
  SELECT DISTINCT ON (r2.tenant_id) r2.*
  FROM risks r2
  ORDER BY r2.tenant_id, r2.created_at ASC
) r
WHERE al.event_type = 'RISK_CREATED'
  AND al.new_value IS NULL
  AND al.tenant_id = r.tenant_id;

-- 3. RISK_CREATED zweite Zeile (anderer User / spätere Zeile)
UPDATE audit_log al
SET
  new_value   = sub.nv,
  entity_type = 'risk',
  entity_id   = sub.rid
FROM (
  SELECT
    a.id AS audit_id,
    r.id AS rid,
    jsonb_build_object(
      'risk_ref',        r.risk_ref,
      'title',           r.title,
      'status',          'open',
      'likelihood',      r.likelihood,
      'impact',          r.impact,
      'score',           r.risk_score,
      'iso_control_ref', COALESCE(r.iso_control_ref, '—'),
      'treatment',       COALESCE(r.treatment, 'mitigate')
    ) AS nv,
    ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY ABS(EXTRACT(EPOCH FROM (a.created_at - r.created_at)))) AS rn
  FROM audit_log a
  JOIN risks r ON r.tenant_id = a.tenant_id
  WHERE a.event_type = 'RISK_CREATED'
    AND a.new_value IS NULL
) sub
WHERE sub.rn = 1
  AND al.id = sub.audit_id;

-- 4. RISK_UPDATED / RISK_CLOSED
UPDATE audit_log al
SET
  old_value   = jsonb_build_object('risk_ref', sub.risk_ref, 'title', sub.title, 'status', 'open'),
  new_value   = jsonb_build_object(
    'risk_ref', sub.risk_ref,
    'title',    sub.title,
    'status',   CASE WHEN al.event_type = 'RISK_CLOSED' THEN 'closed' ELSE sub.status END,
    'score',    sub.risk_score
  ),
  entity_type = 'risk',
  entity_id   = sub.id
FROM (
  SELECT DISTINCT ON (tenant_id) id, tenant_id, risk_ref, title, status, risk_score
  FROM risks
  ORDER BY tenant_id, updated_at DESC NULLS LAST
) sub
WHERE al.event_type IN ('RISK_UPDATED', 'RISK_CLOSED', 'RISK_STATUS_CHANGED', 'RISK_ACCEPTED')
  AND al.new_value IS NULL
  AND al.tenant_id = sub.tenant_id;

-- 5. CONTROL_UPDATED
UPDATE audit_log al
SET
  old_value   = jsonb_build_object('control_ref', sub.control_ref, 'title', sub.title, 'status', 'not_started', 'completion_pct', 0),
  new_value   = jsonb_build_object('control_ref', sub.control_ref, 'title', sub.title, 'status', COALESCE(sub.status,'in_progress'), 'completion_pct', COALESCE(sub.completion_pct, 50)),
  entity_type = 'control',
  entity_id   = sub.ctrl_id::text
FROM (
  SELECT DISTINCT ON (ci.tenant_id) ci.tenant_id, ci.iso_control_id AS ctrl_id,
    ic.control_ref, ic.title, ci.status, ci.completion_pct
  FROM control_implementations ci
  JOIN iso_controls ic ON ic.id = ci.iso_control_id
  ORDER BY ci.tenant_id, ci.last_reviewed DESC NULLS LAST
) sub
WHERE al.event_type IN ('CONTROL_UPDATED', 'CONTROL_STATUS_CHANGED')
  AND al.new_value IS NULL
  AND al.tenant_id = sub.tenant_id;

-- 6. ACTION_COMPLETED / ACTION_UPDATED
UPDATE audit_log al
SET
  old_value   = jsonb_build_object('title', sub.title, 'status', 'in_progress'),
  new_value   = jsonb_build_object('title', sub.title, 'status', sub.status, 'priority', COALESCE(sub.priority, 'medium')),
  entity_type = 'action',
  entity_id   = sub.id::text
FROM (
  SELECT DISTINCT ON (tenant_id) id, tenant_id, title, status, priority
  FROM actions
  ORDER BY tenant_id, updated_at DESC NULLS LAST
) sub
WHERE al.event_type IN ('ACTION_COMPLETED', 'ACTION_UPDATED', 'ACTION_STATUS_CHANGED')
  AND al.new_value IS NULL
  AND al.tenant_id = sub.tenant_id;

-- Ergebnis prüfen
SELECT event_type, user_email,
  CASE WHEN new_value IS NULL THEN '(leer)'
       ELSE LEFT(new_value::text, 80)
  END AS new_val_preview
FROM audit_log
ORDER BY created_at DESC
LIMIT 10;
