-- seed_risks.sql (final)
-- Status-Enum: open | in_treatment | accepted | closed | transferred
-- Ausführen: Get-Content seed_risks.sql | docker exec -i isms_postgres psql -U isms_user -d isms_db

DELETE FROM risks WHERE tenant_id = '00000000-0000-0000-0000-000000000001';

INSERT INTO risks (tenant_id, risk_ref, title, description, iso_control_ref, nist_sub_code, likelihood, impact, risk_score, status, treatment, due_date, owner_id) VALUES
('00000000-0000-0000-0000-000000000001','R-001','Ransomware-Angriff auf kritische Systeme','Angreifer könnten durch Phishing Ransomware einschleusen und Produktionssysteme verschlüsseln.','A.8.7','DE.CM-01',5,5,25.0,'open','mitigate','2026-04-30','00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0000-000000000001','R-002','Datenleck durch privilegierten Insider','Mitarbeiter mit Admin-Rechten könnten sensible Kundendaten exfiltrieren. Fehlende DLP-Kontrollen erhöhen das Risiko.','A.6.3','PR.AA-05',3,5,15.0,'in_treatment','mitigate','2026-03-31','00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0000-000000000001','R-003','Ausfall kritischer Cloud-Infrastruktur','Abhängigkeit von einem einzelnen Cloud-Anbieter ohne Failover-Konzept. Mehrtägiger Ausfall möglich.','A.8.14','PR.IR-04',3,5,15.0,'open','mitigate','2026-05-31','00000000-0000-0000-0000-000000000012'),
('00000000-0000-0000-0000-000000000001','R-004','Ungepatchte Schwachstellen in Produktivsystemen','CVSS > 9 Schwachstellen bleiben durchschnittlich 45 Tage ungepacht.','A.8.8','DE.CM-08',4,4,16.0,'in_treatment','mitigate','2026-03-15','00000000-0000-0000-0000-000000000012'),
('00000000-0000-0000-0000-000000000001','R-005','Fehlende Verschlüsselung sensibler Daten at Rest','Personenbezogene Daten werden ohne Verschlüsselung gespeichert. DSGVO-Verstoß möglich.','A.8.24','PR.DS-01',3,4,12.0,'in_treatment','mitigate','2026-04-15','00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0000-000000000001','R-006','Unzureichende MFA für Admin-Zugänge','Administratoren nutzen nur Passwort-Authentifizierung. Brute-Force-Angriffe könnten zu Kontrollverlust führen.','A.8.5','PR.AA-03',4,4,16.0,'open','mitigate','2026-03-31','00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0000-000000000001','R-007','Lieferantenrisiko: Kritischer SaaS-Anbieter ohne SOC 2','Ein kritischer SaaS-Dienstleister verfügt über keine SOC-2-Zertifizierung.','A.5.21','GV.SC-07',3,4,12.0,'open','transfer','2026-06-30','00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0000-000000000001','R-008','Fehlender Notfallplan für Rechenzentrumsausfall','Das BCM-Konzept ist veraltet. RTO und RPO sind nicht definiert und werden nicht getestet.','A.5.30','PR.IR-01',2,5,10.0,'in_treatment','mitigate','2026-04-30','00000000-0000-0000-0000-000000000012'),
('00000000-0000-0000-0000-000000000001','R-009','Unzureichendes Security-Awareness-Training','Phishing-Simulationen zeigen eine Klickrate von 23%. Neue Mitarbeiter erhalten kein Onboarding-Training.','A.6.3','PR.AT-01',3,3,9.0,'in_treatment','mitigate','2026-03-31','00000000-0000-0000-0000-000000000012'),
('00000000-0000-0000-0000-000000000001','R-010','Shadow IT: Nicht genehmigte Cloud-Dienste','Mitarbeiter nutzen nicht-genehmigte Cloud-Dienste für den Datenaustausch. Keine Kontrolle über abgelegte Daten.','A.5.23','PR.AA-05',4,3,12.0,'open','mitigate','2026-05-15','00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0000-000000000001','R-011','Veraltete Kryptographie-Standards (TLS 1.0/1.1)','Einige interne Systeme unterstützen noch TLS 1.0/1.1 — als unsicher eingestuft.','A.8.24','PR.DS-02',2,4,8.0,'in_treatment','mitigate','2026-03-15','00000000-0000-0000-0000-000000000011'),
('00000000-0000-0000-0000-000000000001','R-012','Unvollständiges Asset-Inventar','IoT-Geräte und Remote-Endpunkte fehlen im CMDB. Blind Spots für Schwachstellen-Scans.','A.8.1','ID.AM-01',2,3,6.0,'open','mitigate','2026-05-31','00000000-0000-0000-0000-000000000012'),
('00000000-0000-0000-0000-000000000001','R-013','Veraltete Dokumentation der ISMS-Richtlinien','Einige ISMS-Richtlinien wurden zuletzt 2023 aktualisiert.','A.5.1','GV.PO-01',2,2,4.0,'accepted','accept','2026-12-31','00000000-0000-0000-0000-000000000010'),
('00000000-0000-0000-0000-000000000001','R-014','Fehlende DSGVO-Einwilligung für Newsletter','Double-Opt-In-Prozess nicht vollständig dokumentiert. Geringes Bußgeldrisiko.','A.5.34','GV.PO-02',1,3,3.0,'accepted','accept','2026-12-31','00000000-0000-0000-0000-000000000010');

SELECT risk_ref, title, likelihood, impact, risk_score, status FROM risks
WHERE tenant_id = '00000000-0000-0000-0000-000000000001'
ORDER BY risk_score DESC;
