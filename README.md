# Govrix ISMS

Ich habe dieses Projekt im Rahmen meines Cybersecurity Bootcamps bei Masterschool gebaut. Die Idee war, ein Tool zu entwickeln mit dem man den Compliance-Status einer Organisation gegenüber ISO 27001, NIS2, DORA und NIST CSF 2.0 verwalten kann — also das was in der Praxis als ISMS bezeichnet wird.

Das Projekt läuft lokal per Docker und besteht aus einem NestJS Backend, einer PostgreSQL Datenbank und einem reinen HTML/CSS/JS Frontend ohne irgendein Framework.

---

## Was funktioniert

**ISO 27001:2022**
Alle 93 Controls aus Annex A sind in der Datenbank hinterlegt. Man kann für jeden Control den Umsetzungsstatus setzen und den Fortschritt in Prozent angeben. Die Werte werden direkt gespeichert.

**NIS2 & DORA**
Die Artikel aus NIS2 (Art. 21 + 23) und DORA sind als Anforderungen hinterlegt und auf die entsprechenden ISO-Controls gemappt. NIS2 hat eine eigene Seite zusammen mit dem Kanban-Board, DORA eine separate Seite.

**NIST CSF 2.0**
Die 54 Subcategories aus den sechs Funktionen (Govern, Identify, Protect, Detect, Respond, Recover) sind in der Datenbank hinterlegt und werden angezeigt.

**Kanban-Board**
Maßnahmen lassen sich per Drag & Drop durch vier Spalten schieben: Offen, In Arbeit, Review, Erledigt.

**KI-Risikoanalyse**
Ollama läuft lokal und analysiert eingetragene Risiken. Es bewertet die Eintrittswahrscheinlichkeit und schlägt Maßnahmen vor. Kein Cloud-Dienst, keine Daten verlassen den Rechner.

**Asset-Management**
IT-Assets können erfasst und verwaltet werden.

---

## Was noch in Arbeit ist

- NIST CSF 2.0 — Status pro Subcategory editierbar machen
- Audit-Log — Backend vorhanden, Frontend noch leer
- PDF/SoA-Export — Skript existiert, aber noch nicht in die App integriert

---

## Stack

- NestJS + TypeScript (Backend / REST API)
- PostgreSQL (Datenbank)
- HTML, CSS, JavaScript (Frontend)
- Docker + Docker Compose + Nginx
- Ollama (lokale KI, kein externer Dienst)

---

## Starten

Voraussetzungen: Docker Desktop, Ollama

```bash
git clone https://github.com/eb-sec/Govrix-ISMS-Web-basierte-GRC-Plattform-ISO-27001-NIS2-DORA-NIST-CSF-2.0-.git
cd Govrix-ISMS-Web-basierte-GRC-Plattform-ISO-27001-NIS2-DORA-NIST-CSF-2.0-

cp .env.example .env
docker compose up -d

docker exec -i isms_postgres psql -U isms_user -d isms_db < database/01_schema.sql
docker exec -i isms_postgres psql -U isms_user -d isms_db < database/seed.sql
```

App läuft dann auf `http://localhost:8080`

Login: `admin@govrix.io` / `Admin1234!`

Für die KI-Funktion einmalig das Modell laden:
```bash
ollama pull llama3
```

---

## Ordnerstruktur

```
├── backend/
│   └── src/
│       ├── auth/
│       ├── controls/
│       ├── actions/
│       ├── risks/
│       ├── ai/
│       └── audit/
├── frontend/
│   ├── isms-login.html
│   ├── isms-dashboard.html
│   ├── isms-iso27001.html
│   ├── isms-kanban-nis2.html
│   ├── isms-dora.html
│   ├── isms-nist.html
│   ├── isms-risk-analyzer.html
│   └── isms-assets.html
├── database/
│   ├── 01_schema.sql
│   └── seed.sql
└── docker-compose.yml
```

---

## Anmerkungen

Die Seed-Daten habe ich manuell gegen die offiziellen Quellen geprüft — ISO 27001:2022 Annex A, EUR-Lex für NIS2 und DORA, und das NIST CSWP.29 Dokument für CSF 2.0. Ein paar Fehler die ich dabei gefunden habe sind dokumentiert und per SQL-Patch korrigiert.

Kein fertiges Produkt, aber ein funktionierendes. Issues und Feedback willkommen.

---

Elias Bach · [github.com/eb-sec](https://github.com/eb-sec)
