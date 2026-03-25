# Govrix ISMS — Projektdokumentation

> **Version:** 2.1 · **Stand:** März 2026 · **Umgebung:** Lokal / On-Premise

---

## Inhaltsverzeichnis

1. [Projektübersicht](#1-projektübersicht)
2. [Systemanforderungen](#2-systemanforderungen)
3. [Abhängigkeiten](#3-abhängigkeiten)
4. [Startanleitung](#4-startanleitung)
5. [Zugangsdaten](#5-zugangsdaten)
6. [Projektstruktur](#6-projektstruktur)
7. [Verfügbare Seiten](#7-verfügbare-seiten)
8. [Backend-Architektur](#8-backend-architektur)
9. [Bekannte Einschränkungen & Workarounds](#9-bekannte-einschränkungen--workarounds)
10. [Häufige Probleme](#10-häufige-probleme)
11. [Changelog](#11-changelog)

---


![Dashboard](https://github.com/user-attachments/assets/239b6e3d-8815-4966-a84a-f177b0ee586a)



## 1. Projektübersicht

Govrix ISMS ist eine lokale Informationssicherheits-Management-Plattform die folgende Frameworks unterstützt:

- **ISO 27001:2022** — 93 Controls, Compliance-Tracking, SoA-Export
- **NIST CSF 2.0** — 54 Subcategories mit Score-Karten
- **NIS2** — EU 2022/2555, 19 Anforderungen mit Status-Tracking
- **DORA** — EU 2022/2554, 22 Anforderungen
- **Risikomanagement** — Risikoregister, KI-Analyse via Ollama
- **CVE-Bewertung & Risikoanalyse** *(NEU v2.1)* — Live-Daten via NVD-API, LLM-Analyse, automatische Risiko-Eintragung
- **Maßnahmen-Kanban** — Drag & Drop, Framework-Filter, PDF-Export
- **Audit-Log** — unveränderliches Aktivitätsprotokoll mit old/new-Value-Tracking
- **Reports & SoA** — PDF- und Excel-Export für alle Frameworks
- **Trust Center** — öffentliche Compliance-Übersicht

---

## 2. Systemanforderungen

| Komponente | Minimum |
|---|---|
| Betriebssystem | Windows 10/11, macOS 12+, Linux |
| RAM | 8 GB (16 GB empfohlen mit Ollama) |
| Festplatte | 10 GB frei (inkl. Docker Images + Ollama Modell) |
| Browser | Chrome, Firefox, Edge (aktuell) |
| Internetverbindung | Für NVD-API (CVE-Seite) empfohlen, nicht zwingend erforderlich |

---

## 3. Abhängigkeiten

Das Projekt hat genau **zwei externe Abhängigkeiten**:

### 3.1 Docker Desktop *(Pflicht)*

| Container | Beschreibung | Port |
|---|---|---|
| `isms_postgres` | PostgreSQL 16 Datenbank | 5433 |
| `isms_api` | NestJS REST-API | 3000 |
| `isms_nginx` | Frontend (HTML/JS) | 8080 |
| `isms_pgadmin` | Datenbank-Verwaltung | 5050 |

**Download:** https://www.docker.com/products/docker-desktop

### 3.2 Ollama *(nur für KI-Analyse)*

Läuft außerhalb von Docker direkt auf dem Host-System.

- **Empfohlenes Modell:** `gemma3` (~3,3 GB) oder `qwen2.5:3b` (schneller/kleiner)
- **Download:** https://ollama.com

```powershell
ollama pull gemma3
# oder:
ollama pull qwen2.5:3b
```

> Ohne Ollama greift die CVE-Seite automatisch auf eine regelbasierte Fallback-Analyse zurück.

### 3.3 Was NICHT benötigt wird

- ❌ Node.js / npm (nur für Backend-Entwicklung)
- ❌ Python / Git
- ❌ Internetverbindung (nach Setup — außer für NVD-API auf der CVE-Seite)

---

## 4. Startanleitung

### Schritt 1 — Erstinstallation (nur einmalig)

```powershell
# 1. Docker Desktop installieren: https://www.docker.com/products/docker-desktop

# 2. Ollama installieren: https://ollama.com
ollama pull gemma3
```

### Schritt 2 — Projekt starten (täglich)

```powershell
# PowerShell im Projektordner
docker compose up -d

# Ollama in separatem Terminal
ollama serve
```

**Browser:** http://localhost:8080

### Schritt 3 — Login

| Benutzer | E-Mail | Passwort | Rolle |
|---|---|---|---|
| Admin | admin@govrix.io | Admin1234! | Administrator |
| CISO | ciso@govrix.io | Govrix2026! | CISO |
| Analyst | analyst@govrix.io | Govrix2026! | Analyst |

### Projekt stoppen

```powershell
docker compose down
```

### Datenbank zurücksetzen

```powershell
docker compose down -v
docker compose up -d
```

---

## 5. Zugangsdaten

| Dienst | URL | Zugangsdaten |
|---|---|---|
| Frontend | http://localhost:8080 | Login-Seite |
| API | http://localhost:3000/api/v1 | JWT Bearer Token |
| pgAdmin | http://localhost:5050 | admin@mustergmbh.de / admin |
| PostgreSQL | localhost:5433 | isms_user / changeme_in_prod |
| Ollama | http://localhost:11434 | kein Login |
| NVD API | https://services.nvd.nist.gov | kein API-Key |

---

## 6. Projektstruktur

```
Govrix-isms/
├── frontend/
│   ├── isms-dashboard.html
│   ├── isms-iso27001.html
│   ├── isms-nist.html
│   ├── isms-nis2.html
│   ├── isms-kanban-nis2.html
│   ├── isms-dora.html
│   ├── isms-risk-analyzer.html
│   ├── isms-cve.html            ← NEU v2.1
│   ├── isms-assets.html
│   ├── isms-audit.html
│   ├── isms-reports.html
│   └── trust.html
├── backend/src/
│   ├── auth/                    # JWT-Auth, Login, Audit
│   ├── risks/                   # Risikoregister CRUD + Audit
│   ├── controls/                # ISO/NIST/NIS2 Controls + Audit
│   ├── audit/                   # Audit-Log Service
│   └── nvd/                     # NVD-Proxy Controller ← NEU v2.1
├── database/
│   ├── 01_schema.sql
│   └── seed.sql
├── docker-compose.yml
└── nginx.conf
```

---

## 7. Verfügbare Seiten

| Seite | URL | Beschreibung |
|---|---|---|
| Dashboard | /isms-dashboard.html | Übersicht, KPIs, Framework-Scores |
| ISO 27001 | /isms-iso27001.html | 93 Controls, Compliance-Status |
| NIST CSF 2.0 | /isms-nist.html | 54 Subcategories, Score-Karten |
| NIS2 / Kanban | /isms-kanban-nis2.html | Maßnahmen-Board |
| DORA | /isms-dora.html | DORA Compliance-Tracking |
| Risikomanagement | /isms-risk-analyzer.html | Risikoregister, KI-Analyse |
| **CVE & Risiko** | **/isms-cve.html** | **CVE-Bewertung, NVD, LLM ← NEU** |
| Assets & Inventar | /isms-assets.html | Asset-Verwaltung (Demo-Daten) |
| Audit-Log | /isms-audit.html | Aktivitätsprotokoll |
| Reports & SoA | /isms-reports.html | PDF/Excel-Export |
| Trust Center | /trust.html | Öffentliche Compliance-Übersicht |

---

## 8. Backend-Architektur

### API-Endpunkte

| Methode | Pfad | Beschreibung |
|---|---|---|
| POST | /api/v1/auth/login | JWT-Token |
| GET | /api/v1/auth/me | Aktueller User |
| GET | /api/v1/risks | Alle Risiken |
| POST | /api/v1/risks | Risiko erstellen |
| PUT | /api/v1/risks/:id | Risiko aktualisieren |
| GET | /api/v1/audit-log | Audit-Einträge |
| GET | /api/v1/nvd/cve?id=CVE-YYYY-N | NVD-Proxy: CVE-Daten ← NEU |
| GET | /api/v1/nvd/search?q=...&severity=HIGH | NVD-Proxy: Suche ← NEU |

### Datenbank (wichtige Tabellen)

| Tabelle | Beschreibung |
|---|---|
| `users` | Benutzerkonten (id, email, role, tenant_id) |
| `risks` | Risikoregister — `risk_score` ist GENERATED (likelihood × impact) |
| `audit_log` | Unveränderlich — kein DELETE/UPDATE erlaubt |
| `iso_controls` | ISO 27001:2022 |
| `nist_subcategories` | NIST CSF 2.0 |
| `nis2_requirements` | NIS2 |

### Enum-Werte

| Feld | Werte |
|---|---|
| `risks.status` | `open`, `in_treatment`, `accepted`, `closed`, `transferred` |
| `risks.treatment` | `mitigate`, `accept`, `transfer`, `avoid` |
| `compliance_status` | `not_started`, `in_progress`, `implemented`, `audited`, `not_applicable` |
| `action_status` | `open`, `in_progress`, `review`, `done` |

### JWT-Sessions

Nach jedem `docker compose up --build` werden alle Sessions invalidiert (neuer JWT-Secret).
**Dauerhafter Fix** — in `docker-compose.yml`:

```yaml
environment:
  JWT_SECRET: "dein-fester-secret-hier"
```

---

## 9. Bekannte Einschränkungen & Workarounds

### CVE-Seite — NVD-API nicht erreichbar (CORS)

Browser blockiert direkte API-Calls von lokalen Dateien.

**Option A — NVD-Proxy im Backend deployen:**
```powershell
New-Item -ItemType Directory -Force "backend\src\nvd"
Copy-Item nvd.controller.ts "backend\src\nvd\nvd.controller.ts"
# In app.module.ts: NvdController importieren und zu controllers[] hinzufügen
docker compose up -d --build api
```

**Option B — Manuell eintragen:** Auf „✏️ Manuell eintragen" klicken — alle CVE-Felder selbst ausfüllen, Analyse (LLM + Risiko) läuft trotzdem vollständig.

### CVE-Seite — Risiko-POST 401 nach Rebuild

JWT-Token abgelaufen. Auf **„🔄 Neu einloggen & Risiko speichern"** klicken — das Assessment wird nach dem Login automatisch gespeichert.

### CVE-Seite — Risiko-POST 500 (FK-Constraint)

```powershell
# Einmalig ausführen:
docker exec -i isms_postgres psql -U isms_user -d isms_db -c "ALTER TABLE risks DROP CONSTRAINT IF EXISTS risks_created_by_fkey;"
```

Danach den neuen `risks.service.ts` deployen (enthält permanenten Fix mit User-Validierung).

### Assets-Seite — nur Demo-Daten

Kein echtes Backend-API für Assets implementiert — alle Daten sind statisch.

### Audit-Log — ältere Einträge ohne Werte

Einträge vor v2.1 haben `old_value = NULL`. Neue Einträge nach Rebuild enthalten vollständige Daten.

---

## 10. Häufige Probleme

### API nicht erreichbar
```powershell
docker compose ps
docker logs isms_api --tail 50
```

### KI-Analyse zeigt nur Fallback
```powershell
# Ollama testen
curl http://localhost:11434/api/tags
ollama list
ollama pull gemma3
```

### CVE lädt nicht / Suche findet nichts
- Internetzugang prüfen
- NVD direkt testen: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2021-44228
- Bei Firewall/CORS: NVD-Proxy-Controller deployen (siehe Abschnitt 9)

### JWT-Secret nach Rebuild finden
```powershell
docker exec isms_api env | Select-String "JWT"
```

### Port bereits belegt
```powershell
netstat -ano | findstr :3000
```

---

## 11. Changelog

### v2.1 — März 2026

**Neue Features:**
- **CVE-Bewertung & Risikoanalyse** (`isms-cve.html`)
  - Live CVE-Daten via NVD-API
  - CVE-Suche nach Stichwort + Severity-Filter
  - Strukturiertes Formular: Exponierung, Datenkategorie (DSGVO), Patch-Status, Netzwerkschutz, Zugriffskontrolle, betroffene Nutzer
  - Ollama LLM-Analyse auf Deutsch (technische Zusammenfassung, Business Impact, Angriffsweg, Management Summary, Maßnahmen, Evidenzen)
  - Regelbasierter Fallback wenn Ollama offline
  - Automatische Risiko-Eintragung (ISO A.8.8)
  - PDF- und Excel-Export (Assessment + Gesamtverlauf)
  - Manueller Eingabemodus wenn NVD nicht erreichbar
  - Verlauf mit bis zu 50 Assessments (localStorage)
  - Re-Login-Flow bei abgelaufener Session mit automatischem Retry
- **NVD-Proxy Controller** (`nvd.controller.ts`) — löst CORS-Problem
- **CVE-Link** in Navbar aller Seiten mit „NEU"-Badge

**Backend-Fixes:**
- `audit.service.ts` — eigenständiger Service, `@Inject(DATABASE_POOL)`
- `auth.service.ts` — Login schreibt Audit-Log mit IP + User-Agent
- `risks.service.ts` — Audit-Log, `created_by` NULL-safe mit User-Validierung, IP-Normalisierung (`::ffff:` Prefix), `nist_sub_code` aus INSERT entfernt
- `controls.service.ts` — Audit-Log für ISO/NIST/NIS2 Updates
- `risks.controller.ts` — `@UseGuards(JwtAuthGuard)`, IP-Extraktion

**Frontend-Fixes:**
- Audit-Log: liest `old_value`/`new_value` JSONB-Felder
- Assets-Seite: Layout-Fix (fehlende `>` in `data-assetid`)

### v2.0 — Februar 2026
- Kanban-Board, DORA-Seite, Risiko-KI-Analyse, Trust Center, Reports & SoA, Audit-Log-Grundstruktur

---

*Govrix ISMS v2.1 · Masterschool Projekt · © 2026*
