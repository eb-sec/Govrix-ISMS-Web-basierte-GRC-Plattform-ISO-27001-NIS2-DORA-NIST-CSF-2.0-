# Govrix ISMS

Eine webbasierte Plattform zur Verwaltung von Informationssicherheit nach ISO 27001:2022, NIS2, DORA und NIST CSF 2.0. Das Projekt entstand im Rahmen meines Cybersecurity Bootcamps bei Masterschool und war mein erster Versuch, ein vollständiges ISMS-Tool von Grund auf zu bauen.

---

## Was kann das Tool?

- **ISO 27001:2022** — alle 93 Controls aus Annex A, mit der Möglichkeit Status und Fortschritt direkt zu bearbeiten
- **NIS2 Compliance** — Artikel 21 und 23 mit automatisch berechnetem Konformitätsscore basierend auf den ISO-Controls
- **DORA** — eigene Seite für Finanzunternehmen, ebenfalls mit Live-Scoring
- **NIST CSF 2.0** — 54 Subcategories trackbar
- **Kanban-Board** — Maßnahmen per Drag & Drop durch die Spalten Offen / In Arbeit / Review / Erledigt
- **Risikomanagement** — Risiken erfassen, bewerten und per KI analysieren lassen
- **KI-gestützte Risikoanalyse** — Ollama läuft lokal und bewertet Risiken, schlägt Maßnahmen vor und ordnet sie ISO-Controls zu, ohne dass Daten das Netzwerk verlassen
- **Asset-Management** — IT-Assets inventarisieren
- **Login** — JWT-Authentifizierung, kein öffentlicher Zugang

---

## Stack

- **Backend:** NestJS (TypeScript), REST API
- **Datenbank:** PostgreSQL
- **Frontend:** HTML, CSS, JavaScript — kein Framework
- **Infrastruktur:** Docker, Docker Compose, Nginx
- **KI:** Ollama (lokal, kein Cloud-Dienst)

---

## Setup

Docker und Ollama müssen installiert sein.

```bash
git clone https://github.com/eb-sec/Govrix-ISMS-Web-basierte-GRC-Plattform-ISO-27001-NIS2-DORA-NIST-CSF-2.0-.git
cd Govrix-ISMS-Web-basierte-GRC-Plattform-ISO-27001-NIS2-DORA-NIST-CSF-2.0-

cp .env.example .env
docker compose up -d

docker exec -i isms_postgres psql -U isms_user -d isms_db < database/01_schema.sql
docker exec -i isms_postgres psql -U isms_user -d isms_db < database/seed.sql
```

Danach ist die App unter `http://localhost:8080` erreichbar.

Login: `admin@govrix.io` / `Admin1234!`

### Ollama einrichten (für KI-Risikoanalyse)

```bash
ollama pull llama3
```

Ollama muss lokal laufen damit die Risikoanalyse funktioniert. Die KI-Anfragen bleiben vollständig lokal — es werden keine Daten an externe Server gesendet.

---

## Projektstruktur

```
├── backend/
│   └── src/
│       ├── auth/
│       ├── controls/
│       ├── actions/
│       ├── risks/
│       ├── ai/              # Ollama Risikoanalyse
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

## Hinweise

Die Seed-Daten (ISO-Controls, NIST-Subcategories, NIS2- und DORA-Artikel) wurden manuell gegen die offiziellen Quellen geprüft — EUR-Lex für NIS2/DORA und das NIST CSWP.29 Dokument für CSF 2.0.

Das Projekt ist kein fertiges Produkt, sondern ein Lernprojekt. Feedback gerne als Issue.

---

Elias Bach · [github.com/eb-sec](https://github.com/eb-sec)
