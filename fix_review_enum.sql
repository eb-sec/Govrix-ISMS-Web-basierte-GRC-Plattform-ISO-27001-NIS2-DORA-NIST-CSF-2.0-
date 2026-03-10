-- Fix: 'review' als gültiger action_status Enum-Wert hinzufügen
-- Ausführen mit: Get-Content fix_review_enum.sql -Encoding UTF8 | docker exec -i isms_postgres psql -U isms_user -d isms_db

ALTER TYPE action_status ADD VALUE IF NOT EXISTS 'review';
