DO $$
DECLARE
  tid uuid := '00000000-0000-0000-0000-000000000001';
  uid uuid;
BEGIN
  SELECT id INTO uid FROM users WHERE tenant_id = tid LIMIT 1;

  INSERT INTO audit_log (tenant_id, user_id, user_email, event_type, entity_type, ip_address, created_at) VALUES
  (tid, uid, 'admin@govrix.io', 'LOGIN',            'USER',    '10.0.5.42', NOW() - INTERVAL '5 minutes'),
  (tid, uid, 'admin@govrix.io', 'RISK_UPDATED',     'RISK',    '10.0.5.42', NOW() - INTERVAL '18 minutes'),
  (tid, uid, 'admin@govrix.io', 'CONTROL_UPDATED',  'CONTROL', '10.0.5.42', NOW() - INTERVAL '42 minutes'),
  (tid, uid, 'ciso@govrix.io',  'RISK_CREATED',     'RISK',    '10.0.5.43', NOW() - INTERVAL '1 hour'),
  (tid, uid, 'admin@govrix.io', 'ACTION_COMPLETED', 'ACTION',  '10.0.5.42', NOW() - INTERVAL '2 hours'),
  (tid, uid, 'ciso@govrix.io',  'CONTROL_UPDATED',  'CONTROL', '10.0.5.43', NOW() - INTERVAL '3 hours'),
  (tid, uid, 'admin@govrix.io', 'RISK_CLOSED',      'RISK',    '10.0.5.42', NOW() - INTERVAL '5 hours'),
  (tid, uid, 'admin@govrix.io', 'LOGIN',            'USER',    '10.0.5.42', NOW() - INTERVAL '1 day'),
  (tid, uid, 'ciso@govrix.io',  'RISK_CREATED',     'RISK',    '10.0.5.43', NOW() - INTERVAL '1 day'),
  (tid, uid, 'admin@govrix.io', 'CONTROL_UPDATED',  'CONTROL', '10.0.5.42', NOW() - INTERVAL '2 days');
END $$;

SELECT event_type, user_email, created_at FROM audit_log
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
ORDER BY created_at DESC LIMIT 5;
