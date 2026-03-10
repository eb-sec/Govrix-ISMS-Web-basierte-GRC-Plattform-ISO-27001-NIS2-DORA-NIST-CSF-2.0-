-- Fix: risks_created_by_fkey Constraint lockern
-- created_by darf NULL sein UND bei gelöschtem User auf NULL fallen

-- Alten Constraint entfernen
ALTER TABLE risks DROP CONSTRAINT IF EXISTS risks_created_by_fkey;

-- Neu mit ON DELETE SET NULL
ALTER TABLE risks
  ADD CONSTRAINT risks_created_by_fkey
  FOREIGN KEY (created_by)
  REFERENCES users(id)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

-- Test: Zeige aktuellen Constraint
SELECT conname, confupdtype, confdeltype
FROM pg_constraint
WHERE conname = 'risks_created_by_fkey';
