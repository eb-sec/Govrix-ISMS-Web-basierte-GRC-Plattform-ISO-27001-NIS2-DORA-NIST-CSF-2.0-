-- fix_actions_umlauts.sql
-- Korrigiert kaputte Umlaute in der actions Tabelle
-- Ausführen mit: docker exec -i isms_postgres psql -U isms_user -d isms_db < fix_actions_umlauts.sql

UPDATE actions SET title = 'Backup-Verschlüsselung auf AES-256 upgraden'       WHERE title ILIKE '%Verschl%sselung%AES%';
UPDATE actions SET title = 'DRP-Test durchführen (12-Monats-Frist überschritten)' WHERE title ILIKE '%DRP-Test%';
UPDATE actions SET title = 'Lieferanten-Assessment für 3 kritische Anbieter'     WHERE title ILIKE '%Lieferanten-Assessment%';
UPDATE actions SET title = 'NIS2 Art.23: Meldeprozess 24h/72h implementieren'   WHERE title ILIKE '%Meldeprozess%';
UPDATE actions SET title = 'Security Awareness Training Q1 abschließen'          WHERE title ILIKE '%Awareness Training%';
UPDATE actions SET title = 'Kryptographie-Richtlinie überarbeiten (TLS 1.3)'     WHERE title ILIKE '%Kryptographie%';
UPDATE actions SET title = 'Notfallplan für Rechenzentrum aktualisiert'           WHERE title ILIKE '%Notfallplan%Rechenzentrum%';
UPDATE actions SET title = 'MFA für alle Admin-Konten einrichten'                WHERE title ILIKE '%MFA%Admin%';
UPDATE actions SET title = 'DORA Art.17: Vorfallsmanagement-Prozess dokumentieren' WHERE title ILIKE '%Vorfallsmanagement%';
UPDATE actions SET title = 'Zugangsrechte-Review aller Admin-Accounts'           WHERE title ILIKE '%Zugangsrechte%';
UPDATE actions SET title = 'Patch-Management-Prozess aktualisieren'              WHERE title ILIKE '%Patch-Management%';

-- Descriptions ebenfalls fixen falls betroffen
UPDATE actions SET description = REPLACE(description, '??', 'ü') WHERE description ILIKE '%??%';

-- Prüfen ob alles korrekt ist
SELECT id, title FROM actions ORDER BY created_at;
