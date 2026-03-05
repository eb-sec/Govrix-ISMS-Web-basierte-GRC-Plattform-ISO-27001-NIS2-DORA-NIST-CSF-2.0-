# SecureFrame ISMS Platform
### ISO 27001:2022 · NIST CSF 2.0 · NIS2 · DORA

---

## 📁 Empfohlene Projektstruktur für VS Code

```
secureframe-isms/
│
├── 📁 frontend/                          # Browser-Apps (sofort ausführbar)
│   ├── isms-dashboard.html               # ✅ Haupt-Dashboard (ISO + NIST Scores)
│   ├── isms-risk-analyzer.html           # ✅ Risiko-Register + KI-Analyse (Claude API)
│   └── isms-kanban-nis2.html             # ✅ Kanban-Tracker + NIS2 + DORA Compliance
│
├── 📁 backend/                           # NestJS API
│   ├── src/
│   │   ├── app.module.ts                 # ⬜ Root Module (TypeORM, JWT, etc.)
│   │   ├── 📁 auth/
│   │   │   ├── auth.module.ts            # ⬜ OAuth2 / Entra ID / OIDC
│   │   │   ├── entra.strategy.ts         # ⬜ Microsoft Entra ID SSO
│   │   │   └── rbac.guard.ts             # ⬜ Role-Based Access Control
│   │   ├── 📁 controls/
│   │   │   ├── controls.controller.ts    # ✅ (in isms-api.ts)
│   │   │   ├── controls.service.ts       # ⬜ Business Logic
│   │   │   └── controls.entity.ts        # ⬜ TypeORM Entity
│   │   ├── 📁 risks/
│   │   │   ├── risks.controller.ts       # ✅ (in isms-api.ts)
│   │   │   ├── risks.service.ts          # ⬜ CVSS-Scoring, Risikobewertung
│   │   │   └── risks.entity.ts           # ⬜ TypeORM Entity
│   │   ├── 📁 audit/
│   │   │   ├── audit.service.ts          # ✅ (in isms-api.ts) Append-Only Log
│   │   │   └── audit.entity.ts           # ⬜ TypeORM Entity
│   │   └── 📁 reports/
│   │       └── reports.controller.ts     # ⬜ PDF-Export Endpunkt
│   ├── .env.example                      # ✅ (in isms-api.ts, Kommentar-Block)
│   └── package.json                      # ⬜
│
├── 📁 database/
│   ├── 01_schema.sql                     # ✅ Vollständiges PostgreSQL-Schema
│   │                                     #    93 ISO Controls, NIST CSF 2.0,
│   │                                     #    NIS2, DORA, Audit-Trail, RBAC
│   ├── 02_seed_iso_controls.sql          # ⬜ (bereits in 01_schema.sql enthalten)
│   └── 03_seed_demo_data.sql             # ⬜ Demo-Risiken, Maßnahmen, Tenants
│
├── 📁 reports/
│   ├── generate_soa_pdf.py               # ✅ Python/ReportLab PDF-Generator
│   └── isms-soa-report.pdf               # ✅ Beispiel-Output (SoA, 5 Seiten)
│
└── README.md                             # Diese Datei
```

**Legende:** ✅ = bereits generiert · ⬜ = nächster Schritt

---

## 🚀 Schnellstart

### Frontend (sofort, kein Server nötig)
```bash
# Einfach im Browser öffnen:
open frontend/isms-dashboard.html
open frontend/isms-risk-analyzer.html
open frontend/isms-kanban-nis2.html
```

### Datenbank (PostgreSQL)
```bash
createdb isms_db
psql isms_db < database/01_schema.sql
# Erstellt alle Tabellen + 93 ISO Controls + NIST CSF 2.0 Seed-Daten
```

### PDF-Report generieren
```bash
pip install reportlab
python reports/generate_soa_pdf.py
# Erzeugt reports/isms-soa-report.pdf
```

### Backend (NestJS)
```bash
cd backend
npm install
cp .env.example .env   # Werte eintragen
npm run start:dev
# API läuft auf http://localhost:3000/api/v1
```

---

## 🗺️ Was wurde bisher gebaut

| Datei | Inhalt | Status |
|-------|--------|--------|
| `frontend/isms-dashboard.html` | Compliance-Scores ISO + NIST, Risiko-Register, Audit-Trail | ✅ |
| `frontend/isms-risk-analyzer.html` | Kanban-Risiko-Register, 5×5-Matrix, KI-Analyse (Claude API) | ✅ |
| `frontend/isms-kanban-nis2.html` | Drag & Drop Kanban, NIS2 Art.21, DORA Kapitel-Tabellen | ✅ |
| `database/01_schema.sql` | PostgreSQL: 93 ISO Controls, NIST CSF 2.0, Multi-Tenant, Audit-Log | ✅ |
| `backend/src/api.ts` | NestJS Controllers, DTOs, Audit-Service, Entra ID Auth | ✅ |
| `reports/generate_soa_pdf.py` | Statement of Applicability PDF (5 Seiten) | ✅ |

---

## 🔧 Tech Stack

| Schicht | Technologie |
|---------|-------------|
| Frontend | Vanilla HTML/CSS/JS → Next.js geplant |
| Backend | NestJS (Node.js) + TypeScript |
| Datenbank | PostgreSQL 15+ |
| Auth | Microsoft Entra ID (OAuth 2.0 / OIDC) |
| PDF | Python reportlab |
| AI | Claude API für Risikoanalyse |
| Deployment | Docker → Azure Container Apps |

---

## 📋 Nächste Schritte (priorisiert)

- [ ] `database/03_seed_demo_data.sql` — Demo-Tenants, Risiken, Maßnahmen
- [ ] `backend/src/controls/controls.service.ts` — Business Logic + TypeORM Entities
- [ ] `backend/src/reports/reports.controller.ts` — `GET /reports/soa` → PDF-Stream
- [ ] Asset-Inventar-Modul (CMDB) mit Kritikalitätsbewertung
- [ ] Docker Compose — Ein Befehl startet DB + Backend + Frontend
- [ ] Next.js Migration — React-Komponenten, Tailwind CSS, shadcn/ui
