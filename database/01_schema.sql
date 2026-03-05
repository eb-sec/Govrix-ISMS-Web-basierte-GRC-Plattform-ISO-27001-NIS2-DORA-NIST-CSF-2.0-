-- ============================================================
-- SecureFrame ISMS — PostgreSQL Schema v1.0
-- ISO/IEC 27001:2022 + NIST CSF 2.0
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- TENANTS (Multi-Mandanten-Fähigkeit)
-- ============================================================
CREATE TABLE tenants (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name          VARCHAR(255) NOT NULL,
    slug          VARCHAR(100) UNIQUE NOT NULL,
    plan          VARCHAR(50) NOT NULL DEFAULT 'enterprise',
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- USERS & RBAC
-- ============================================================
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id     UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    email         VARCHAR(255) NOT NULL,
    display_name  VARCHAR(255),
    entra_oid     VARCHAR(255),         -- Microsoft Entra Object ID für SSO
    role          VARCHAR(50) NOT NULL DEFAULT 'analyst'
                  CHECK (role IN ('admin','ciso','auditor','analyst','read_only')),
    is_active     BOOLEAN DEFAULT TRUE,
    last_login    TIMESTAMPTZ,
    created_at    TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (tenant_id, email)
);
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_entra ON users(entra_oid);

-- ============================================================
-- FRAMEWORKS
-- ============================================================
CREATE TABLE frameworks (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code          VARCHAR(50) UNIQUE NOT NULL,  -- 'ISO27001_2022', 'NIST_CSF_2'
    name          VARCHAR(255) NOT NULL,
    version       VARCHAR(50) NOT NULL,
    description   TEXT,
    published_at  DATE
);

-- ============================================================
-- ISO 27001:2022 — ANNEX A CONTROLS (93 Controls)
-- ============================================================
CREATE TABLE iso_control_categories (
    id     SMALLINT PRIMARY KEY,
    code   CHAR(1) NOT NULL,  -- O, P, T, F (Org/Person/Technol/Physisch)
    name   VARCHAR(100) NOT NULL,
    count  SMALLINT NOT NULL
);

INSERT INTO iso_control_categories VALUES
    (1, 'O', 'Organisatorisch',    37),
    (2, 'P', 'Personenbezogen',     8),
    (3, 'F', 'Physisch',           14),
    (4, 'T', 'Technologisch',      34);

CREATE TABLE iso_controls (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    framework_id    UUID NOT NULL REFERENCES frameworks(id),
    category_id     SMALLINT NOT NULL REFERENCES iso_control_categories(id),
    control_ref     VARCHAR(20) NOT NULL UNIQUE,  -- z.B. 'A.5.1'
    title           VARCHAR(255) NOT NULL,
    purpose         TEXT,
    is_new_in_2022  BOOLEAN DEFAULT FALSE,        -- neu in ISO 27001:2022
    sort_order      SMALLINT
);

-- ============================================================
-- ISO 27001:2022 SEED — Alle 93 Controls
-- (Framework-ID wird per DO-Block gesetzt)
-- ============================================================
DO $$
DECLARE
    fw_id UUID;
BEGIN

INSERT INTO frameworks(code, name, version, published_at)
VALUES ('ISO27001_2022','ISO/IEC 27001','2022-10-01','2022-10-01')
RETURNING id INTO fw_id;

-- === KATEGORIE 1: ORGANISATORISCH (A.5.x) — 37 Controls ===
INSERT INTO iso_controls(framework_id,category_id,control_ref,title,is_new_in_2022,sort_order) VALUES
(fw_id,1,'A.5.1','Informationssicherheitspolitiken',FALSE,1),
(fw_id,1,'A.5.2','Rollen und Verantwortlichkeiten für Informationssicherheit',FALSE,2),
(fw_id,1,'A.5.3','Aufgabentrennung',FALSE,3),
(fw_id,1,'A.5.4','Managementverantwortlichkeiten',FALSE,4),
(fw_id,1,'A.5.5','Kontakt mit Behörden',FALSE,5),
(fw_id,1,'A.5.6','Kontakt mit speziellen Interessengruppen',FALSE,6),
(fw_id,1,'A.5.7','Bedrohungsanalyse (Threat Intelligence)',TRUE,7),
(fw_id,1,'A.5.8','Informationssicherheit im Projektmanagement',FALSE,8),
(fw_id,1,'A.5.9','Inventar von Informationen und anderen zugehörigen Assets',FALSE,9),
(fw_id,1,'A.5.10','Zulässiger Gebrauch von Informationen und anderen Assets',FALSE,10),
(fw_id,1,'A.5.11','Rückgabe von Assets',FALSE,11),
(fw_id,1,'A.5.12','Klassifizierung von Informationen',FALSE,12),
(fw_id,1,'A.5.13','Kennzeichnung von Informationen',FALSE,13),
(fw_id,1,'A.5.14','Informationsübertragung',FALSE,14),
(fw_id,1,'A.5.15','Zugriffskontrolle',FALSE,15),
(fw_id,1,'A.5.16','Identitätsmanagement',FALSE,16),
(fw_id,1,'A.5.17','Authentifizierungsinformationen',FALSE,17),
(fw_id,1,'A.5.18','Zugriffsrechte',FALSE,18),
(fw_id,1,'A.5.19','Informationssicherheit in Lieferantenbeziehungen',FALSE,19),
(fw_id,1,'A.5.20','Informationssicherheit in Lieferantenvereinbarungen',FALSE,20),
(fw_id,1,'A.5.21','Management der Informationssicherheit in der IKT-Lieferkette',FALSE,21),
(fw_id,1,'A.5.22','Überwachung, Überprüfung und Änderungsmanagement von Lieferantendienstleistungen',FALSE,22),
(fw_id,1,'A.5.23','Informationssicherheit bei der Nutzung von Cloud-Diensten',TRUE,23),
(fw_id,1,'A.5.24','Planung und Vorbereitung des Managements von Informationssicherheitsvorfällen',FALSE,24),
(fw_id,1,'A.5.25','Bewertung und Entscheidung über Informationssicherheitsereignisse',FALSE,25),
(fw_id,1,'A.5.26','Reaktion auf Informationssicherheitsvorfälle',FALSE,26),
(fw_id,1,'A.5.27','Erkenntnisse aus Informationssicherheitsvorfällen',FALSE,27),
(fw_id,1,'A.5.28','Sammeln von Beweismitteln',FALSE,28),
(fw_id,1,'A.5.29','Informationssicherheit während einer Unterbrechung',FALSE,29),
(fw_id,1,'A.5.30','IKT-Bereitschaft für Business Continuity',TRUE,30),
(fw_id,1,'A.5.31','Rechtliche, gesetzliche, regulatorische und vertragliche Anforderungen',FALSE,31),
(fw_id,1,'A.5.32','Rechte an geistigem Eigentum',FALSE,32),
(fw_id,1,'A.5.33','Schutz von Aufzeichnungen',FALSE,33),
(fw_id,1,'A.5.34','Datenschutz und Schutz personenbezogener Daten',FALSE,34),
(fw_id,1,'A.5.35','Unabhängige Überprüfung der Informationssicherheit',FALSE,35),
(fw_id,1,'A.5.36','Einhaltung von Richtlinien und Standards für die Informationssicherheit',FALSE,36),
(fw_id,1,'A.5.37','Dokumentierte Betriebsverfahren',FALSE,37);

-- === KATEGORIE 2: PERSONENBEZOGEN (A.6.x) — 8 Controls ===
INSERT INTO iso_controls(framework_id,category_id,control_ref,title,is_new_in_2022,sort_order) VALUES
(fw_id,2,'A.6.1','Überprüfung',FALSE,38),
(fw_id,2,'A.6.2','Beschäftigungsbedingungen',FALSE,39),
(fw_id,2,'A.6.3','Informationssicherheitsbewusstsein, -ausbildung und -schulung',FALSE,40),
(fw_id,2,'A.6.4','Disziplinarverfahren',FALSE,41),
(fw_id,2,'A.6.5','Verantwortlichkeiten nach Beendigung oder Wechsel des Arbeitsverhältnisses',FALSE,42),
(fw_id,2,'A.6.6','Vertraulichkeits- oder Geheimhaltungsvereinbarungen',FALSE,43),
(fw_id,2,'A.6.7','Telearbeit',FALSE,44),
(fw_id,2,'A.6.8','Meldung von Informationssicherheitsereignissen',FALSE,45);

-- === KATEGORIE 3: PHYSISCH (A.7.x) — 14 Controls ===
INSERT INTO iso_controls(framework_id,category_id,control_ref,title,is_new_in_2022,sort_order) VALUES
(fw_id,3,'A.7.1','Physische Sicherheitsbereiche',FALSE,46),
(fw_id,3,'A.7.2','Physischer Zutritt',FALSE,47),
(fw_id,3,'A.7.3','Sicherung von Büros, Räumen und Einrichtungen',FALSE,48),
(fw_id,3,'A.7.4','Physische Sicherheitsüberwachung',TRUE,49),
(fw_id,3,'A.7.5','Schutz vor physischen und umweltbedingten Bedrohungen',FALSE,50),
(fw_id,3,'A.7.6','Arbeiten in Sicherheitsbereichen',FALSE,51),
(fw_id,3,'A.7.7','Aufgeräumter Schreibtisch und aufgeräumter Bildschirm',FALSE,52),
(fw_id,3,'A.7.8','Platzierung und Schutz der Betriebsmittel',FALSE,53),
(fw_id,3,'A.7.9','Sicherheit von Assets außerhalb des Standorts',FALSE,54),
(fw_id,3,'A.7.10','Speichermedien',FALSE,55),
(fw_id,3,'A.7.11','Unterstützende Betriebsmittel',FALSE,56),
(fw_id,3,'A.7.12','Verkabelungssicherheit',FALSE,57),
(fw_id,3,'A.7.13','Wartung von Betriebsmitteln',FALSE,58),
(fw_id,3,'A.7.14','Sichere Entsorgung oder Wiederverwendung von Betriebsmitteln',FALSE,59);

-- === KATEGORIE 4: TECHNOLOGISCH (A.8.x) — 34 Controls ===
INSERT INTO iso_controls(framework_id,category_id,control_ref,title,is_new_in_2022,sort_order) VALUES
(fw_id,4,'A.8.1','Endbenutzergeräte',FALSE,60),
(fw_id,4,'A.8.2','Privilegierte Zugriffsrechte',FALSE,61),
(fw_id,4,'A.8.3','Einschränkung des Informationszugriffs',FALSE,62),
(fw_id,4,'A.8.4','Zugriff auf Quellcode',FALSE,63),
(fw_id,4,'A.8.5','Sichere Authentifizierung',FALSE,64),
(fw_id,4,'A.8.6','Kapazitätsmanagement',FALSE,65),
(fw_id,4,'A.8.7','Schutz vor Malware',FALSE,66),
(fw_id,4,'A.8.8','Management technischer Schwachstellen',FALSE,67),
(fw_id,4,'A.8.9','Konfigurationsmanagement',TRUE,68),
(fw_id,4,'A.8.10','Löschung von Informationen',TRUE,69),
(fw_id,4,'A.8.11','Datenmaskierung',TRUE,70),
(fw_id,4,'A.8.12','Verhinderung von Datenlecks (DLP)',TRUE,71),
(fw_id,4,'A.8.13','Sicherung von Informationen',FALSE,72),
(fw_id,4,'A.8.14','Redundanz von informationsverarbeitenden Einrichtungen',FALSE,73),
(fw_id,4,'A.8.15','Protokollierung',FALSE,74),
(fw_id,4,'A.8.16','Überwachungsaktivitäten',TRUE,75),
(fw_id,4,'A.8.17','Uhrensynchronisation',FALSE,76),
(fw_id,4,'A.8.18','Verwendung privilegierter Hilfsprogramme',FALSE,77),
(fw_id,4,'A.8.19','Installation von Software auf Betriebssystemen',FALSE,78),
(fw_id,4,'A.8.20','Netzwerksicherheit',FALSE,79),
(fw_id,4,'A.8.21','Sicherheit von Netzwerkdiensten',FALSE,80),
(fw_id,4,'A.8.22','Trennung von Netzwerken',FALSE,81),
(fw_id,4,'A.8.23','Web-Filterung',TRUE,82),
(fw_id,4,'A.8.24','Verwendung von Kryptographie',FALSE,83),
(fw_id,4,'A.8.25','Sicherer Entwicklungslebenszyklus',FALSE,84),
(fw_id,4,'A.8.26','Anforderungen an die Anwendungssicherheit',FALSE,85),
(fw_id,4,'A.8.27','Sichere Systemarchitektur und technische Grundsätze',TRUE,86),
(fw_id,4,'A.8.28','Sichere Codierung',TRUE,87),
(fw_id,4,'A.8.29','Sicherheitstests in Entwicklung und Abnahme',FALSE,88),
(fw_id,4,'A.8.30','Ausgelagerte Entwicklung',FALSE,89),
(fw_id,4,'A.8.31','Trennung von Entwicklungs-, Test- und Produktionsumgebungen',FALSE,90),
(fw_id,4,'A.8.32','Änderungsmanagement',FALSE,91),
(fw_id,4,'A.8.33','Testinformationen',FALSE,92),
(fw_id,4,'A.8.34','Schutz von Informationssystemen während des Audits',FALSE,93);

END $$;

-- ============================================================
-- NIST CSF 2.0 — FUNCTIONS, CATEGORIES, SUBCATEGORIES
-- ============================================================
CREATE TABLE nist_functions (
    id       UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code     CHAR(2) NOT NULL UNIQUE,   -- GV, ID, PR, DE, RS, RC
    name     VARCHAR(100) NOT NULL,
    color    CHAR(7)                    -- Hex-Farbe für UI
);

INSERT INTO nist_functions(code, name, color) VALUES
('GV','Govern',  '#a855f7'),
('ID','Identify','#0099ff'),
('PR','Protect', '#00d4aa'),
('DE','Detect',  '#f59e0b'),
('RS','Respond', '#ff6b35'),
('RC','Recover', '#ef4444');

CREATE TABLE nist_categories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    function_id UUID NOT NULL REFERENCES nist_functions(id),
    code        VARCHAR(10) NOT NULL UNIQUE,  -- z.B. 'GV.OC'
    name        VARCHAR(255) NOT NULL
);

CREATE TABLE nist_subcategories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES nist_categories(id),
    code        VARCHAR(15) NOT NULL UNIQUE,  -- z.B. 'GV.OC-01'
    description TEXT NOT NULL,
    sort_order  SMALLINT
);

-- NIST CSF 2.0 Seed (ausgewählte Subcategories — vollständige Liste im GitHub)
DO $$
DECLARE
    fn_gv UUID; fn_id UUID; fn_pr UUID; fn_de UUID; fn_rs UUID; fn_rc UUID;
    cat UUID;
BEGIN
SELECT id INTO fn_gv FROM nist_functions WHERE code='GV';
SELECT id INTO fn_id FROM nist_functions WHERE code='ID';
SELECT id INTO fn_pr FROM nist_functions WHERE code='PR';
SELECT id INTO fn_de FROM nist_functions WHERE code='DE';
SELECT id INTO fn_rs FROM nist_functions WHERE code='RS';
SELECT id INTO fn_rc FROM nist_functions WHERE code='RC';

-- GV — GOVERN
INSERT INTO nist_categories(function_id,code,name) VALUES(fn_gv,'GV.OC','Organizational Context') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'GV.OC-01','Die Missionsrolle der Organisation in der Lieferkette wird berücksichtigt',1),
(cat,'GV.OC-02','Interne und externe Stakeholder werden identifiziert',2),
(cat,'GV.OC-03','Rechtliche, regulatorische und vertragliche Anforderungen sind verstanden',3),
(cat,'GV.OC-04','Kritische Objektive, Fähigkeiten und Dienste sind bekannt',4),
(cat,'GV.OC-05','Ergebnisse, Fähigkeiten und Dienste sind priorisiert',5);

INSERT INTO nist_categories(function_id,code,name) VALUES(fn_gv,'GV.RM','Risk Management Strategy') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'GV.RM-01','Risikoappetit und -toleranz werden bestimmt und kommuniziert',1),
(cat,'GV.RM-02','Risikomanagement-Infrastruktur und -Prozesse sind etabliert',2),
(cat,'GV.RM-03','Cybersecurity-Risikomanagement ist in Enterprise-RM integriert',3),
(cat,'GV.RM-04','Strategische Cybersecurity-Risiken werden erfasst und kommuniziert',4),
(cat,'GV.RM-05','Linien-Verantwortung für Cybersecurity-Risiken sind klar',5),
(cat,'GV.RM-06','Eine Strategie für Drittrisiken ist etabliert und kommuniziert',6),
(cat,'GV.RM-07','Reaktion auf strategische Risiken ist priorisiert',7);

-- ID — IDENTIFY
INSERT INTO nist_categories(function_id,code,name) VALUES(fn_id,'ID.AM','Asset Management') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'ID.AM-01','Inventar physischer Assets ist geführt',1),
(cat,'ID.AM-02','Inventar von Software, Diensten und Systemen ist geführt',2),
(cat,'ID.AM-03','Kommunikation und Datenflüsse sind abgebildet',3),
(cat,'ID.AM-04','Externe Informationssysteme sind katalogisiert',4),
(cat,'ID.AM-05','Assets sind priorisiert nach Kritikalität',5),
(cat,'ID.AM-07','Inventar von Daten wird geführt',6),
(cat,'ID.AM-08','Systeme werden verwaltet nach der gesamten Assetlebensdauer',7);

INSERT INTO nist_categories(function_id,code,name) VALUES(fn_id,'ID.RA','Risk Assessment') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'ID.RA-01','Schwachstellen in Assets werden identifiziert',1),
(cat,'ID.RA-02','Cyber-Bedrohungsinformationen werden empfangen',2),
(cat,'ID.RA-03','Interne und externe Bedrohungen werden identifiziert',3),
(cat,'ID.RA-04','Potenzielle Auswirkungen und Wahrscheinlichkeit werden bewertet',4),
(cat,'ID.RA-05','Bedrohungen, Schwachstellen, Wahrscheinlichkeiten und Auswirkungen werden priorisiert',5),
(cat,'ID.RA-06','Risikoreaktionen werden identifiziert und priorisiert',6),
(cat,'ID.RA-07','Änderungen und Ausnahmen sind risikoinformiert',7),
(cat,'ID.RA-08','Prozesse für Empfang, Analyse, Reaktion auf Schwachstellen sind etabliert',8),
(cat,'ID.RA-09','Authentizität und Integrität von Hardware und Software werden bewertet',9),
(cat,'ID.RA-10','Kritische Lieferanten werden untersucht',10);

-- PR — PROTECT
INSERT INTO nist_categories(function_id,code,name) VALUES(fn_pr,'PR.AA','Identity Management, Authentication and Access Control') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'PR.AA-01','Identitäten und Credentials für autorisierte Nutzer, Dienste, Hardware werden verwaltet',1),
(cat,'PR.AA-02','Identitäten werden verifiziert bevor Zugriff gewährt wird',2),
(cat,'PR.AA-03','Nutzer, Dienste und Hardware werden authentifiziert',3),
(cat,'PR.AA-04','Identitätsbeweise werden gesammelt und validiert',4),
(cat,'PR.AA-05','Zugriff auf Assets wird privilegiert vergeben',5),
(cat,'PR.AA-06','Physischer Zugriff auf Assets wird verwaltet',6);

INSERT INTO nist_categories(function_id,code,name) VALUES(fn_pr,'PR.DS','Data Security') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'PR.DS-01','Ruhende Daten sind geschützt',1),
(cat,'PR.DS-02','Übertragene Daten sind geschützt',2),
(cat,'PR.DS-10','Daten im Einsatz sind geschützt',3),
(cat,'PR.DS-11','Backups von Daten werden erstellt, gesichert und getestet',4);

-- DE — DETECT
INSERT INTO nist_categories(function_id,code,name) VALUES(fn_de,'DE.CM','Continuous Monitoring') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'DE.CM-01','Netzwerke und Dienste werden überwacht',1),
(cat,'DE.CM-02','Physische Umgebung wird überwacht',2),
(cat,'DE.CM-03','Personalaktivität und -technologie werden überwacht',3),
(cat,'DE.CM-06','Externe Dienstleister werden überwacht',4),
(cat,'DE.CM-09','Rechner-Hardware und -Software werden überwacht',5);

-- RS — RESPOND
INSERT INTO nist_categories(function_id,code,name) VALUES(fn_rs,'RS.MA','Incident Management') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'RS.MA-01','Incident-Response-Plan wird ausgeführt',1),
(cat,'RS.MA-02','Incidents werden triagiert',2),
(cat,'RS.MA-03','Incidents werden kategorisiert',3),
(cat,'RS.MA-04','Incidents werden eskaliert oder eingedämmt',4),
(cat,'RS.MA-05','Incidents werden aus dem Live-Betrieb herausgenommen',5);

-- RC — RECOVER
INSERT INTO nist_categories(function_id,code,name) VALUES(fn_rc,'RC.RP','Incident Recovery Plan Execution') RETURNING id INTO cat;
INSERT INTO nist_subcategories(category_id,code,description,sort_order) VALUES
(cat,'RC.RP-01','Wiederherstellungsplan wird ausgeführt',1),
(cat,'RC.RP-02','Wiederherstellungsmaßnahmen werden ausgewählt',2),
(cat,'RC.RP-03','Wiederherstellung kritischer Dienste wird priorisiert',3),
(cat,'RC.RP-04','Systemwiederherstellung und -validierung finden statt',4),
(cat,'RC.RP-05','Vollständige Incident-Bewältigung wird deklariert',5);

END $$;

-- ============================================================
-- COMPLIANCE STATUS (je Tenant + Control)
-- ============================================================
CREATE TYPE compliance_status AS ENUM (
    'not_started','in_progress','implemented','audited','not_applicable'
);

CREATE TABLE control_implementations (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id),
    iso_control_id  UUID REFERENCES iso_controls(id),
    nist_sub_id     UUID REFERENCES nist_subcategories(id),
    status          compliance_status DEFAULT 'not_started',
    completion_pct  SMALLINT DEFAULT 0 CHECK (completion_pct BETWEEN 0 AND 100),
    evidence_url    TEXT,
    notes           TEXT,
    owner_id        UUID REFERENCES users(id),
    due_date        DATE,
    last_reviewed   DATE,
    reviewed_by     UUID REFERENCES users(id),
    CONSTRAINT chk_one_control CHECK (
        (iso_control_id IS NOT NULL) <> (nist_sub_id IS NOT NULL)
        OR (iso_control_id IS NOT NULL AND nist_sub_id IS NOT NULL)
    )
);
CREATE INDEX idx_ci_tenant ON control_implementations(tenant_id);
CREATE INDEX idx_ci_iso ON control_implementations(iso_control_id);
CREATE INDEX idx_ci_nist ON control_implementations(nist_sub_id);

ALTER TABLE control_implementations ADD CONSTRAINT uq_ci_iso UNIQUE (tenant_id, iso_control_id);
ALTER TABLE control_implementations ADD CONSTRAINT uq_ci_nist UNIQUE (tenant_id, nist_sub_id);

-- ===
-- ============================================================
-- RISIKO-REGISTER
-- ============================================================
CREATE TYPE risk_status AS ENUM ('open','in_treatment','accepted','closed','transferred');
CREATE TYPE risk_treatment AS ENUM ('mitigate','accept','transfer','avoid');

CREATE TABLE assets (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id   UUID NOT NULL REFERENCES tenants(id),
    name        VARCHAR(255) NOT NULL,
    category    VARCHAR(100),  -- Software, Hardware, Data, People, Service
    criticality SMALLINT CHECK (criticality BETWEEN 1 AND 5),
    owner_id    UUID REFERENCES users(id),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE risks (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id       UUID NOT NULL REFERENCES tenants(id),
    risk_ref        VARCHAR(20) NOT NULL,  -- RIS-2026-001
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    asset_id        UUID REFERENCES assets(id),
    iso_control_ref VARCHAR(20) REFERENCES iso_controls(control_ref),
    nist_sub_code   VARCHAR(15) REFERENCES nist_subcategories(code),

    -- CVSS-ähnliche Risikobewertung
    likelihood      SMALLINT NOT NULL CHECK (likelihood BETWEEN 1 AND 5),
    impact          SMALLINT NOT NULL CHECK (impact BETWEEN 1 AND 5),
    risk_score      NUMERIC(4,1) GENERATED ALWAYS AS (likelihood * impact * 1.0) STORED,
    residual_score  NUMERIC(4,1),

    treatment       risk_treatment,
    status          risk_status DEFAULT 'open',
    owner_id        UUID REFERENCES users(id),
    due_date        DATE,
    created_by      UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_risks_tenant ON risks(tenant_id);
CREATE INDEX idx_risks_score ON risks(risk_score DESC);

-- ============================================================
-- MASSNAHMEN (Treatment Actions)
-- ============================================================
CREATE TYPE action_status AS ENUM ('open','in_progress','done','overdue','cancelled');

CREATE TABLE actions (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id   UUID NOT NULL REFERENCES tenants(id),
    risk_id     UUID REFERENCES risks(id),
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    status      action_status DEFAULT 'open',
    priority    SMALLINT DEFAULT 2 CHECK (priority BETWEEN 1 AND 4),  -- 1=kritisch
    owner_id    UUID REFERENCES users(id),
    due_date    DATE,
    closed_at   TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_actions_tenant ON actions(tenant_id);
CREATE INDEX idx_actions_risk ON actions(risk_id);

-- ============================================================
-- AUDIT-TRAIL (unveränderlich — Append Only)
-- ============================================================
CREATE TABLE audit_log (
    id          BIGSERIAL PRIMARY KEY,
    tenant_id   UUID NOT NULL,
    user_id     UUID,
    user_email  VARCHAR(255),
    event_type  VARCHAR(100) NOT NULL,  -- 'CONTROL_UPDATED','RISK_CREATED', etc.
    entity_type VARCHAR(50),
    entity_id   UUID,
    old_value   JSONB,
    new_value   JSONB,
    ip_address  INET,
    user_agent  TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_audit_tenant_time ON audit_log(tenant_id, created_at DESC);
CREATE INDEX idx_audit_entity ON audit_log(entity_type, entity_id);

-- Schutz: Keine Updates/Deletes auf audit_log
CREATE RULE no_update_audit AS ON UPDATE TO audit_log DO INSTEAD NOTHING;
CREATE RULE no_delete_audit AS ON DELETE TO audit_log DO INSTEAD NOTHING;

-- ============================================================
-- HELPER VIEWS
-- ============================================================

-- ISO Compliance Score je Tenant
CREATE VIEW v_iso_compliance_score AS
SELECT
    ci.tenant_id,
    cat.name AS category,
    cat.code AS category_code,
    COUNT(*) AS total_controls,
    SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1 ELSE 0 END) AS compliant,
    ROUND(
        SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1.0 ELSE 0 END)
        / COUNT(*) * 100, 1
    ) AS compliance_pct
FROM control_implementations ci
JOIN iso_controls ic ON ic.id = ci.iso_control_id
JOIN iso_control_categories cat ON cat.id = ic.category_id
WHERE ci.iso_control_id IS NOT NULL
GROUP BY ci.tenant_id, cat.name, cat.code;

-- NIST Score je Function
CREATE VIEW v_nist_function_score AS
SELECT
    ci.tenant_id,
    fn.code AS function_code,
    fn.name AS function_name,
    fn.color,
    COUNT(*) AS total_subcategories,
    SUM(CASE WHEN ci.status IN ('implemented','audited') THEN 1 ELSE 0 END) AS compliant,
    ROUND(AVG(ci.completion_pct), 1) AS avg_completion_pct
FROM control_implementations ci
JOIN nist_subcategories ns ON ns.id = ci.nist_sub_id
JOIN nist_categories nc ON nc.id = ns.category_id
JOIN nist_functions fn ON fn.id = nc.function_id
WHERE ci.nist_sub_id IS NOT NULL
GROUP BY ci.tenant_id, fn.code, fn.name, fn.color;

-- Open high risks
CREATE VIEW v_open_risks AS
SELECT
    r.*,
    u.display_name AS owner_name,
    a.name AS asset_name
FROM risks r
LEFT JOIN users u ON u.id = r.owner_id
LEFT JOIN assets a ON a.id = r.asset_id
WHERE r.status = 'open'
ORDER BY r.risk_score DESC;

-- ============================================================
-- TRIGGER: updated_at automatisch setzen
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_risks_updated BEFORE UPDATE ON risks
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
