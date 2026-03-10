-- Seed demo actions for Govrix ISMS Kanban
-- priority: 1=critical, 2=high, 3=medium, 4=low
-- owner_id: Admin=...0010, CISO=...0011, Analyst=...0012

INSERT INTO actions (title, description, status, priority, due_date, owner_id, tenant_id) VALUES
('MFA für alle Admin-Konten einrichten',
 'Multi-Faktor-Authentifizierung für sämtliche Admin-Accounts aktivieren.',
 'open', 1, '2026-02-28',
 '00000000-0000-0000-0000-000000000010',
 '00000000-0000-0000-0000-000000000001'),

('DORA Art.17: Vorfallsmanagement-Prozess dokumentieren',
 'Prozessdokumentation für IKT-Vorfallsmanagement nach DORA Art. 17.',
 'open', 1, '2026-02-28',
 '00000000-0000-0000-0000-000000000011',
 '00000000-0000-0000-0000-000000000001'),

('NIS2 Art.23: Meldeprozess 24h/72h implementieren',
 'Meldeweg und Vorlagen für 24h/72h-Fristen nach NIS2 Art. 23 bereitstellen.',
 'open', 1, '2026-03-05',
 '00000000-0000-0000-0000-000000000012',
 '00000000-0000-0000-0000-000000000001'),

('DRP-Test durchführen (12-Monats-Frist überschritten)',
 'Disaster Recovery Plan testen – Frist seit Q1/2025 überschritten.',
 'open', 2, '2026-03-10',
 '00000000-0000-0000-0000-000000000011',
 '00000000-0000-0000-0000-000000000001'),

('Lieferanten-Assessment für 3 kritische Anbieter',
 'Sicherheitsbewertung der Top-3-Lieferanten nach ISO A.5.21.',
 'open', 2, '2026-03-20',
 '00000000-0000-0000-0000-000000000012',
 '00000000-0000-0000-0000-000000000001'),

('Backup-Verschlüsselung auf AES-256 upgraden',
 'Alle Backup-Systeme auf AES-256-Verschlüsselung migrieren.',
 'in_progress', 2, '2026-03-15',
 '00000000-0000-0000-0000-000000000011',
 '00000000-0000-0000-0000-000000000001'),

('Security Awareness Training Q1 abschließen',
 'Pflichttraining für alle Mitarbeiter bis Ende Q1/2026 abschließen.',
 'in_progress', 3, '2026-03-31',
 '00000000-0000-0000-0000-000000000012',
 '00000000-0000-0000-0000-000000000001'),

('DORA TLPT (Threat-Led Pen Test) planen',
 'Bedrohungsgeleiteten Penetrationstest nach DORA Art. 26 planen und beauftragen.',
 'in_progress', 1, '2026-03-15',
 '00000000-0000-0000-0000-000000000010',
 '00000000-0000-0000-0000-000000000001'),

('Konfigurationsmanagement-DB aufbauen (CMDB)',
 'CMDB für alle IT-Assets aufbauen und mit Monitoring verknüpfen.',
 'in_progress', 3, '2026-04-30',
 '00000000-0000-0000-0000-000000000011',
 '00000000-0000-0000-0000-000000000001'),

('Patch-Management-Prozess aktualisieren',
 'Prozess auf monatlichen Patch-Zyklus mit automatisiertem Reporting anpassen.',
 'done', 3, '2026-03-01',
 '00000000-0000-0000-0000-000000000011',
 '00000000-0000-0000-0000-000000000001'),

('Kryptographie-Richtlinie überarbeiten (TLS 1.3)',
 'Richtlinie auf TLS 1.3 als Mindeststandard aktualisieren.',
 'done', 2, '2026-03-10',
 '00000000-0000-0000-0000-000000000010',
 '00000000-0000-0000-0000-000000000001'),

('ISO 27001 Risikobewertung Q4/2025 abgeschlossen',
 'Vollständige Risikobewertung aller Assets für Q4/2025 durchgeführt.',
 'done', 2, '2026-01-31',
 '00000000-0000-0000-0000-000000000010',
 '00000000-0000-0000-0000-000000000001'),

('Zugangsrechte-Review aller Admin-Accounts',
 'Vierteljährlicher Review aller privilegierten Zugangsrechte abgeschlossen.',
 'done', 3, '2026-01-15',
 '00000000-0000-0000-0000-000000000011',
 '00000000-0000-0000-0000-000000000001'),

('Notfallplan für Rechenzentrum aktualisiert',
 'BCP/DRP für primäres Rechenzentrum überarbeitet und genehmigt.',
 'done', 2, '2026-02-01',
 '00000000-0000-0000-0000-000000000012',
 '00000000-0000-0000-0000-000000000001');

SELECT status, COUNT(*) as anzahl FROM actions
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
GROUP BY status ORDER BY status;
