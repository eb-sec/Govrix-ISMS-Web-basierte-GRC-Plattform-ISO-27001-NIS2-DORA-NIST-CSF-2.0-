# Govrix ISMS — Project Documentation

> **Version:** 2.1 · **Last updated:** March 2026 · **Environment:** Local / On-Premise

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [System Requirements](#2-system-requirements)
3. [Dependencies](#3-dependencies)
4. [Getting Started](#4-getting-started)
5. [Credentials](#5-credentials)
6. [Project Structure](#6-project-structure)
7. [Available Pages](#7-available-pages)
8. [Backend Architecture](#8-backend-architecture)
9. [Known Limitations & Workarounds](#9-known-limitations--workarounds)
10. [Troubleshooting](#10-troubleshooting)
11. [Changelog](#11-changelog)

---

![Dashboard](https://github.com/user-attachments/assets/239b6e3d-8815-4966-a84a-f177b0ee586a)

---

## 1. Project Overview

Govrix ISMS is a local Information Security Management platform supporting the following frameworks:

- **ISO 27001:2022** — 93 controls, compliance tracking, SoA export
- **NIST CSF 2.0** — 54 subcategories with score cards
- **NIS2** — EU 2022/2555, 19 requirements with status tracking
- **DORA** — EU 2022/2554, 22 requirements
- **Risk Management** — Risk register, AI analysis via Ollama
- **CVE Assessment & Risk Analysis** *(NEW v2.1)* — Live data via NVD API, LLM analysis, automatic risk entry
- **Measures Kanban** — Drag & drop, framework filter, PDF export
- **Audit Log** — Immutable activity log with old/new value tracking
- **Reports & SoA** — PDF and Excel export for all frameworks
- **Trust Center** — Public compliance overview

---

## 2. System Requirements

| Component | Minimum |
|---|---|
| Operating System | Windows 10/11, macOS 12+, Linux |
| RAM | 8 GB (16 GB recommended with Ollama) |
| Disk Space | 10 GB free (incl. Docker images + Ollama model) |
| Browser | Chrome, Firefox, Edge (current versions) |
| Internet | Recommended for NVD API (CVE page), not strictly required |

---

## 3. Dependencies

The project has exactly **two external dependencies**:

### 3.1 Docker Desktop *(required)*

| Container | Description | Port |
|---|---|---|
| `isms_postgres` | PostgreSQL 16 database | 5433 |
| `isms_api` | NestJS REST API | 3000 |
| `isms_nginx` | Frontend (HTML/JS) | 8080 |
| `isms_pgadmin` | Database management | 5050 |

**Download:** https://www.docker.com/products/docker-desktop

### 3.2 Ollama *(AI analysis only)*

Runs outside Docker directly on the host system.

- **Recommended model:** `gemma3` (~3.3 GB) or `qwen2.5:3b` (faster/smaller)
- **Download:** https://ollama.com

```powershell
ollama pull gemma3
# or:
ollama pull qwen2.5:3b
```

> Without Ollama, the CVE page automatically falls back to a rule-based analysis.

### 3.3 What is NOT required

- ❌ Node.js / npm (only needed for backend development)
- ❌ Python / Git
- ❌ Internet connection (after setup — except for NVD API on the CVE page)

---

## 4. Getting Started

### Step 1 — Initial Setup (once only)

```powershell
# 1. Install Docker Desktop: https://www.docker.com/products/docker-desktop

# 2. Install Ollama: https://ollama.com
ollama pull gemma3
```

### Step 2 — Start the Project (daily)

```powershell
# PowerShell in the project folder
docker compose up -d

# Ollama in a separate terminal
ollama serve
```

**Browser:** http://localhost:8080

### Step 3 — Login

| User | E-Mail | Password | Role |
|---|---|---|---|
| Admin | admin@govrix.io | Admin1234! | Administrator |
| CISO | ciso@govrix.io | Govrix2026! | CISO |
| Analyst | analyst@govrix.io | Govrix2026! | Analyst |

### Stop the Project

```powershell
docker compose down
```

### Reset the Database

```powershell
docker compose down -v
docker compose up -d
```

---

## 5. Credentials

| Service | URL | Credentials |
|---|---|---|
| Frontend | http://localhost:8080 | Login page |
| API | http://localhost:3000/api/v1 | JWT Bearer Token |
| pgAdmin | http://localhost:5050 | admin@mustergmbh.de / admin |
| PostgreSQL | localhost:5433 | isms_user / changeme_in_prod |
| Ollama | http://localhost:11434 | no login |
| NVD API | https://services.nvd.nist.gov | no API key |

---

## 6. Project Structure

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
│   ├── isms-cve.html            ← NEW v2.1
│   ├── isms-assets.html
│   ├── isms-audit.html
│   ├── isms-reports.html
│   └── trust.html
├── backend/src/
│   ├── auth/                    # JWT auth, login, audit
│   ├── risks/                   # Risk register CRUD + audit
│   ├── controls/                # ISO/NIST/NIS2 controls + audit
│   ├── audit/                   # Audit log service
│   └── nvd/                     # NVD proxy controller ← NEW v2.1
├── database/
│   ├── 01_schema.sql
│   └── seed.sql
├── docker-compose.yml
└── nginx.conf
```

---

## 7. Available Pages

| Page | URL | Description |
|---|---|---|
| Dashboard | /isms-dashboard.html | Overview, KPIs, framework scores |
| ISO 27001 | /isms-iso27001.html | 93 controls, compliance status |
| NIST CSF 2.0 | /isms-nist.html | 54 subcategories, score cards |
| NIS2 / Kanban | /isms-kanban-nis2.html | Measures board |
| DORA | /isms-dora.html | DORA compliance tracking |
| Risk Management | /isms-risk-analyzer.html | Risk register, AI analysis |
| **CVE & Risk** | **/isms-cve.html** | **CVE assessment, NVD, LLM ← NEW** |
| Assets & Inventory | /isms-assets.html | Asset management (demo data) |
| Audit Log | /isms-audit.html | Activity log |
| Reports & SoA | /isms-reports.html | PDF/Excel export |
| Trust Center | /trust.html | Public compliance overview |

---

## 8. Backend Architecture

### API Endpoints

| Method | Path | Description |
|---|---|---|
| POST | /api/v1/auth/login | JWT token |
| GET | /api/v1/auth/me | Current user |
| GET | /api/v1/risks | All risks |
| POST | /api/v1/risks | Create risk |
| PUT | /api/v1/risks/:id | Update risk |
| GET | /api/v1/audit-log | Audit entries |
| GET | /api/v1/nvd/cve?id=CVE-YYYY-N | NVD proxy: CVE data ← NEW |
| GET | /api/v1/nvd/search?q=...&severity=HIGH | NVD proxy: search ← NEW |

### Database (key tables)

| Table | Description |
|---|---|
| `users` | User accounts (id, email, role, tenant_id) |
| `risks` | Risk register — `risk_score` is GENERATED (likelihood × impact) |
| `audit_log` | Immutable — no DELETE/UPDATE allowed |
| `iso_controls` | ISO 27001:2022 |
| `nist_subcategories` | NIST CSF 2.0 |
| `nis2_requirements` | NIS2 |

### Enum Values

| Field | Values |
|---|---|
| `risks.status` | `open`, `in_treatment`, `accepted`, `closed`, `transferred` |
| `risks.treatment` | `mitigate`, `accept`, `transfer`, `avoid` |
| `compliance_status` | `not_started`, `in_progress`, `implemented`, `audited`, `not_applicable` |
| `action_status` | `open`, `in_progress`, `review`, `done` |

### JWT Sessions

After every `docker compose up --build`, all sessions are invalidated (new JWT secret).
**Permanent fix** — in `docker-compose.yml`:

```yaml
environment:
  JWT_SECRET: "your-fixed-secret-here"
```

---

## 9. Known Limitations & Workarounds

### CVE Page — NVD API unreachable (CORS)

Browser blocks direct API calls from local files.

**Option A — Deploy NVD proxy in the backend:**
```powershell
New-Item -ItemType Directory -Force "backend\src\nvd"
Copy-Item nvd.controller.ts "backend\src\nvd\nvd.controller.ts"
# In app.module.ts: import NvdController and add to controllers[]
docker compose up -d --build api
```

**Option B — Manual entry:** Click "✏️ Enter manually" — fill in all CVE fields yourself; analysis (LLM + risk) still runs fully.

### CVE Page — Risk POST 401 after rebuild

JWT token expired. Click **"🔄 Re-login & save risk"** — the assessment is saved automatically after login.

### CVE Page — Risk POST 500 (FK constraint)

```powershell
# Run once:
docker exec -i isms_postgres psql -U isms_user -d isms_db -c "ALTER TABLE risks DROP CONSTRAINT IF EXISTS risks_created_by_fkey;"
```

Then deploy the new `risks.service.ts` (contains permanent fix with user validation).

### Assets Page — demo data only

No real backend API implemented for assets — all data is static.

### Audit Log — older entries without values

Entries created before v2.1 have `old_value = NULL`. New entries after rebuild contain complete data.

---

## 10. Troubleshooting

### API not reachable
```powershell
docker compose ps
docker logs isms_api --tail 50
```

### AI analysis shows fallback only
```powershell
# Test Ollama
curl http://localhost:11434/api/tags
ollama list
ollama pull gemma3
```

### CVE not loading / search returns nothing
- Check internet access
- Test NVD directly: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2021-44228
- If firewall/CORS: deploy NVD proxy controller (see section 9)

### JWT secret after rebuild
```powershell
docker exec isms_api env | Select-String "JWT"
```

### Port already in use
```powershell
netstat -ano | findstr :3000
```

---

## 11. Changelog

### v2.1 — March 2026

**New Features:**
- **CVE Assessment & Risk Analysis** (`isms-cve.html`)
  - Live CVE data via NVD API
  - CVE search by keyword + severity filter
  - Structured form: exposure, data category (GDPR), patch status, network protection, access control, affected users
  - Ollama LLM analysis (technical summary, business impact, attack vector, management summary, measures, evidence)
  - Rule-based fallback when Ollama is offline
  - Automatic risk entry (ISO A.8.8)
  - PDF and Excel export (assessment + full history)
  - Manual input mode when NVD is unreachable
  - History of up to 50 assessments (localStorage)
  - Re-login flow on expired session with automatic retry
- **NVD Proxy Controller** (`nvd.controller.ts`) — resolves CORS issue
- **CVE link** in navbar of all pages with "NEW" badge

**Backend Fixes:**
- `audit.service.ts` — standalone service, `@Inject(DATABASE_POOL)`
- `auth.service.ts` — login writes audit log with IP + user agent
- `risks.service.ts` — audit log, `created_by` NULL-safe with user validation, IP normalization (`::ffff:` prefix), `nist_sub_code` removed from INSERT
- `controls.service.ts` — audit log for ISO/NIST/NIS2 updates
- `risks.controller.ts` — `@UseGuards(JwtAuthGuard)`, IP extraction

**Frontend Fixes:**
- Audit log: reads `old_value`/`new_value` JSONB fields
- Assets page: layout fix (missing `>` in `data-assetid`)

### v2.0 — February 2026
- Kanban board, DORA page, risk AI analysis, Trust Center, Reports & SoA, audit log base structure
