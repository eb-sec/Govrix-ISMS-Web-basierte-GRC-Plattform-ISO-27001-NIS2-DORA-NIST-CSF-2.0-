-- Fix corrupted umlauts in actions titles
UPDATE actions SET title = 'MFA für alle Admin-Konten einrichten'
  WHERE title LIKE 'MFA f%r alle Admin%';

UPDATE actions SET title = 'DORA Art.17: Vorfallsmanagement-Prozess dokumentieren'
  WHERE title LIKE 'DORA Art.17%';

UPDATE actions SET title = 'NIS2 Art.23: Meldeprozess 24h/72h implementieren'
  WHERE title LIKE 'NIS2 Art.23%';

UPDATE actions SET title = 'DRP-Test durchführen (12-Monats-Frist überschritten)'
  WHERE title LIKE 'DRP-Test%';

UPDATE actions SET title = 'Lieferanten-Assessment für 3 kritische Anbieter'
  WHERE title LIKE 'Lieferanten-Assessment%';

UPDATE actions SET title = 'Backup-Verschlüsselung auf AES-256 upgraden'
  WHERE title LIKE 'Backup-Verschl%';

UPDATE actions SET title = 'Security Awareness Training Q1 abschließen'
  WHERE title LIKE 'Security Awareness%';

UPDATE actions SET title = 'Konfigurationsmanagement-DB aufbauen (CMDB)'
  WHERE title LIKE 'Konfigurationsmanagement%';

UPDATE actions SET title = 'Kryptographie-Richtlinie überarbeiten (TLS 1.3)'
  WHERE title LIKE 'Kryptographie%';

UPDATE actions SET title = 'Zugangsrechte-Review aller Admin-Accounts'
  WHERE title LIKE 'Zugangsrechte%';

UPDATE actions SET title = 'Notfallplan für Rechenzentrum aktualisiert'
  WHERE title LIKE 'Notfallplan%';

SELECT id, title FROM actions WHERE tenant_id = '00000000-0000-0000-0000-000000000001' ORDER BY status;
