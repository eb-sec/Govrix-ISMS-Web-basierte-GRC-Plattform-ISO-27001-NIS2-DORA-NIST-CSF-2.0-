-- fix_umlauts_safe.sql
-- Verwendet chr() statt direkte Umlaute → kein Encoding-Problem beim Ausführen

-- ü = chr(252), ö = chr(246), ä = chr(228)
-- Ü = chr(220), Ö = chr(214), Ä = chr(196), ß = chr(223)

UPDATE actions SET title = 'Backup-Verschl' || chr(252) || 'sselung auf AES-256 upgraden'
  WHERE title ILIKE '%Verschl%sselung%AES%';

UPDATE actions SET title = 'DRP-Test durchf' || chr(252) || 'hren (12-Monats-Frist ' || chr(252) || 'berschritten)'
  WHERE title ILIKE '%DRP-Test%';

UPDATE actions SET title = 'Lieferanten-Assessment f' || chr(252) || 'r 3 kritische Anbieter'
  WHERE title ILIKE '%Lieferanten-Assessment%';

UPDATE actions SET title = 'Security Awareness Training Q1 abschlie' || chr(223) || 'en'
  WHERE title ILIKE '%Awareness Training%';

UPDATE actions SET title = 'Kryptographie-Richtlinie ' || chr(252) || 'berarbeiten (TLS 1.3)'
  WHERE title ILIKE '%Kryptographie%';

UPDATE actions SET title = 'Notfallplan f' || chr(252) || 'r Rechenzentrum aktualisiert'
  WHERE title ILIKE '%Notfallplan%Rechenzentrum%';

UPDATE actions SET title = 'MFA f' || chr(252) || 'r alle Admin-Konten einrichten'
  WHERE title ILIKE '%MFA%Admin%';

UPDATE actions SET title = 'DORA Art.17: Vorfallsmanagement-Prozess dokumentieren'
  WHERE title ILIKE '%Vorfallsmanagement%';

-- Prüfen
SELECT id, title FROM actions ORDER BY created_at;
