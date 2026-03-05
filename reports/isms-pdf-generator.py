#!/usr/bin/env python3
"""
SecureFrame ISMS — Statement of Applicability (SoA) PDF Generator
ISO/IEC 27001:2022 + NIS2 + DORA Management Report
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    HRFlowable, PageBreak, KeepTogether
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT
from reportlab.pdfgen import canvas
from reportlab.platypus import BaseDocTemplate, Frame, PageTemplate
import datetime

# ─── Farben ────────────────────────────────────────────────
DARK       = colors.HexColor('#0d1117')
DARK2      = colors.HexColor('#111820')
ACCENT     = colors.HexColor('#00d4aa')
ACCENT2    = colors.HexColor('#0099ff')
ACCENT4    = colors.HexColor('#a855f7')
RED        = colors.HexColor('#ef4444')
YELLOW     = colors.HexColor('#f59e0b')
GREEN      = colors.HexColor('#10b981')
ORANGE     = colors.HexColor('#ff6b35')
TEXT_LIGHT = colors.HexColor('#e2e8f0')
TEXT_MED   = colors.HexColor('#8899aa')
TEXT_DIM   = colors.HexColor('#556070')
WHITE      = colors.white
BORDER     = colors.HexColor('#1e2a3a')

# ─── Styles ────────────────────────────────────────────────
styles = getSampleStyleSheet()

def S(name, **kw):
    return ParagraphStyle(name, **kw)

TITLE_STYLE = S('Title',
    fontName='Helvetica-Bold', fontSize=28,
    textColor=WHITE, leading=34, spaceAfter=4)

SUBTITLE_STYLE = S('Subtitle',
    fontName='Helvetica', fontSize=12,
    textColor=TEXT_MED, leading=18, spaceAfter=2)

SECTION_STYLE = S('Section',
    fontName='Helvetica-Bold', fontSize=14,
    textColor=ACCENT, leading=20, spaceBefore=18, spaceAfter=8,
    borderPad=0)

SUBSEC_STYLE = S('Subsec',
    fontName='Helvetica-Bold', fontSize=11,
    textColor=TEXT_LIGHT, leading=16, spaceBefore=10, spaceAfter=4)

BODY_STYLE = S('Body',
    fontName='Helvetica', fontSize=9,
    textColor=TEXT_MED, leading=14, spaceAfter=3)

META_STYLE = S('Meta',
    fontName='Helvetica', fontSize=8,
    textColor=TEXT_DIM, leading=12)

CODE_STYLE = S('Code',
    fontName='Courier', fontSize=8,
    textColor=ACCENT, leading=12)

LABEL_STYLE = S('Label',
    fontName='Helvetica-Bold', fontSize=8,
    textColor=TEXT_DIM, leading=10,
    wordWrap='CJK')

TABLE_HEAD_STYLE = S('THead',
    fontName='Helvetica-Bold', fontSize=8,
    textColor=TEXT_DIM, leading=10)

TABLE_CELL_STYLE = S('TCell',
    fontName='Helvetica', fontSize=8,
    textColor=TEXT_LIGHT, leading=11)

TABLE_CODE_STYLE = S('TCode',
    fontName='Courier-Bold', fontSize=8,
    textColor=ACCENT, leading=11)

TABLE_NIS2_STYLE = S('TNis2',
    fontName='Courier-Bold', fontSize=8,
    textColor=ACCENT4, leading=11)

TABLE_DORA_STYLE = S('TDora',
    fontName='Courier-Bold', fontSize=8,
    textColor=ACCENT2, leading=11)

# ─── Hilfsfunktionen ───────────────────────────────────────
def status_color(pct):
    if pct >= 80: return GREEN
    if pct >= 50: return YELLOW
    return RED

def status_text(pct):
    if pct >= 80: return 'Konform'
    if pct >= 50: return 'In Arbeit'
    return 'Offen'

def prio_color(prio):
    return {'Kritisch': RED, 'Hoch': ORANGE, 'Mittel': YELLOW, 'Niedrig': ACCENT2}.get(prio, TEXT_MED)

def make_progress_table(pct, width=40*mm):
    """Erstellt eine kleine Fortschrittsbalken-Tabelle"""
    filled = int(pct / 100 * 20)
    bar = '█' * filled + '░' * (20 - filled)
    col = status_color(pct)
    return Paragraph(f'<font color="#{col.hexval()[1:]}">{pct}%</font>', TABLE_CELL_STYLE)

# ─── Seitenlayout ──────────────────────────────────────────
class ISMSDocTemplate(BaseDocTemplate):
    def __init__(self, filename, **kwargs):
        BaseDocTemplate.__init__(self, filename, **kwargs)
        frame = Frame(
            15*mm, 20*mm,
            self.width - 0*mm, self.height - 35*mm,
            leftPadding=0, rightPadding=0,
            topPadding=0, bottomPadding=0
        )
        template = PageTemplate(id='main', frames=[frame], onPage=self.add_header_footer)
        self.addPageTemplates([template])
        self.page_num = 0

    def add_header_footer(self, canvas_obj, doc):
        canvas_obj.saveState()
        w, h = A4

        # Header-Linie
        canvas_obj.setFillColor(DARK)
        canvas_obj.rect(0, h - 18*mm, w, 18*mm, fill=1, stroke=0)
        canvas_obj.setFillColor(ACCENT)
        canvas_obj.rect(0, h - 18.5*mm, w, 0.8*mm, fill=1, stroke=0)

        # Logo im Header
        canvas_obj.setFillColor(ACCENT)
        canvas_obj.roundRect(15*mm, h - 14*mm, 8*mm, 8*mm, 1.5*mm, fill=1, stroke=0)
        canvas_obj.setFillColor(DARK)
        canvas_obj.setFont('Helvetica-Bold', 7)
        canvas_obj.drawCentredString(19*mm, h - 11*mm, 'SF')

        canvas_obj.setFillColor(WHITE)
        canvas_obj.setFont('Helvetica-Bold', 9)
        canvas_obj.drawString(26*mm, h - 10*mm, 'SecureFrame ISMS')
        canvas_obj.setFillColor(TEXT_DIM)
        canvas_obj.setFont('Helvetica', 7)
        canvas_obj.drawString(26*mm, h - 13.5*mm, 'Statement of Applicability — Vertraulich')

        # Datum rechts
        canvas_obj.setFillColor(TEXT_DIM)
        canvas_obj.setFont('Helvetica', 7)
        date_str = datetime.date.today().strftime('%d.%m.%Y')
        canvas_obj.drawRightString(w - 15*mm, h - 10*mm, f'Erstellt: {date_str}')
        canvas_obj.drawRightString(w - 15*mm, h - 13.5*mm, 'VERTRAULICH · TLP:WHITE')

        # Footer
        canvas_obj.setFillColor(DARK)
        canvas_obj.rect(0, 0, w, 14*mm, fill=1, stroke=0)
        canvas_obj.setFillColor(ACCENT)
        canvas_obj.rect(0, 14*mm, w, 0.5*mm, fill=1, stroke=0)

        canvas_obj.setFillColor(TEXT_DIM)
        canvas_obj.setFont('Helvetica', 7)
        canvas_obj.drawString(15*mm, 9*mm, 'SecureFrame ISMS Platform · ISO/IEC 27001:2022 · NIS2 EU 2022/2555 · DORA EU 2022/2554')
        canvas_obj.drawRightString(w - 15*mm, 9*mm, f'Seite {doc.page}')
        canvas_obj.drawCentredString(w/2, 9*mm, 'Q1/2026 — Audit-Zyklus · Dr. M. Fischer (CISO)')

        canvas_obj.restoreState()

# ─── DATEN ─────────────────────────────────────────────────
ISO_CONTROLS = [
    # ref, title, category, included, justification, pct
    ('A.5.1',  'Informationssicherheitspolitiken',       'Organisatorisch', 'Ja', 'Grundlage des ISMS',                  100),
    ('A.5.7',  'Threat Intelligence (NEU 2022)',         'Organisatorisch', 'Ja', 'KRITIS-Anforderung',                   30),
    ('A.5.21', 'IKT-Lieferkettensicherheit',             'Organisatorisch', 'Ja', 'NIS2 Art.21(2)(d)',                    55),
    ('A.5.23', 'Cloud-Dienste-Sicherheit (NEU 2022)',    'Organisatorisch', 'Ja', 'Cloud-First-Strategie',                78),
    ('A.5.24', 'Incident-Management-Planung',            'Organisatorisch', 'Ja', 'DORA Art.17 / NIS2 Art.21(2)(b)',      65),
    ('A.5.29', 'IS bei Betriebsunterbrechungen',         'Organisatorisch', 'Ja', 'BCP-Anforderung',                      58),
    ('A.5.30', 'IKT Business Continuity (NEU 2022)',     'Organisatorisch', 'Ja', 'NIS2 Art.21(2)(c)',                    40),
    ('A.6.3',  'Awareness & Training',                   'Personenbezogen', 'Ja', 'NIS2 Art.21(2)(g)',                    70),
    ('A.7.4',  'Physische Sicherheitsüberwachung (NEU)', 'Physisch',        'Ja', 'Rechenzentrum-Schutz',                 85),
    ('A.8.5',  'Sichere Authentifizierung',              'Technologisch',   'Ja', 'NIS2 Art.21(2)(j) — MFA Pflicht',      40),
    ('A.8.8',  'Schwachstellenmanagement',               'Technologisch',   'Ja', 'DORA Art.26 / CVE-Tracking',           75),
    ('A.8.9',  'Konfigurationsmanagement (NEU 2022)',    'Technologisch',   'Ja', 'Zero-Trust-Architektur',               42),
    ('A.8.11', 'Datenmaskierung (NEU 2022)',              'Technologisch',   'Ja', 'DSGVO Art.25 / Privacy by Design',    35),
    ('A.8.12', 'DLP (NEU 2022)',                         'Technologisch',   'Ja', 'Schutz vor Datenverlust',              30),
    ('A.8.13', 'Datensicherung',                         'Technologisch',   'Ja', 'DORA Art.9 / RPO-Anforderung',         72),
    ('A.8.24', 'Kryptographie',                          'Technologisch',   'Ja', 'NIS2 Art.21(2)(h)',                    72),
    ('A.8.27', 'Sichere Systemarchitektur (NEU 2022)',   'Technologisch',   'Ja', 'Zero-Trust-Framework',                 65),
    ('A.8.28', 'Sichere Codierung (NEU 2022)',           'Technologisch',   'Ja', 'DevSecOps-Anforderung',                60),
]

NIS2_ARTICLES = [
    ('Art. 20',      'Governance & Management-Verantwortung',   95, 'Gering'),
    ('Art. 21(2)(a)','Risikoanalyse & IS-Politiken',            92, 'Gering'),
    ('Art. 21(2)(b)','Vorfallsbehandlung',                      65, 'Mittel'),
    ('Art. 21(2)(c)','Business Continuity',                     40, 'Hoch — ≤10M€'),
    ('Art. 21(2)(d)','Lieferkettensicherheit',                  55, 'Mittel'),
    ('Art. 21(2)(e)','Sicherheit bei Erwerb/Entwicklung',       85, 'Gering'),
    ('Art. 21(2)(f)','Wirksamkeitsbewertung',                   88, 'Gering'),
    ('Art. 21(2)(g)','Cyberhygiene & Schulungen',               70, 'Gering'),
    ('Art. 21(2)(h)','Kryptographie',                           72, 'Gering'),
    ('Art. 21(2)(i)','Personalsicherheit & Zugriffskontrolle',  90, 'Gering'),
    ('Art. 21(2)(j)','Multi-Faktor-Authentifizierung',          40, 'Kritisch — ≤10M€'),
    ('Art. 23',      'Meldepflichten (24h / 72h)',              45, 'Kritisch — ≤10M€'),
    ('Art. 34',      'Aufsicht & Durchsetzungsmaßnahmen',       60, 'Hoch'),
]

DORA_ARTICLES = [
    ('Kap.II Art.5',  'IKT-Risikomanagement-Rahmenwerk',       75, 'Hoch',     '31.03.26'),
    ('Kap.II Art.9',  'Schutz und Prävention',                 80, 'Niedrig',  '30.06.26'),
    ('Kap.II Art.11', 'Reaktion und Wiederherstellung',        50, 'Hoch',     '28.03.26'),
    ('Kap.III Art.17','IKT-Vorfallsmanagementprozess',         45, 'Kritisch', '28.02.26'),
    ('Kap.III Art.19','Klassifizierung schwerwiegender Vorf.', 38, 'Kritisch', '28.02.26'),
    ('Kap.IV Art.24', 'Programm zur Prüfung digit. Resilienz', 30, 'Kritisch', '01.03.26'),
    ('Kap.IV Art.26', 'Erweiterte Tests (TLPT)',               15, 'Kritisch', '15.03.26'),
    ('Kap.V Art.28',  'IKT-Drittpartei-Risikostrategie',       55, 'Hoch',     '30.04.26'),
    ('Kap.V Art.30',  'Vertragliche Mindestbestimmungen',       60, 'Hoch',     '30.04.26'),
]

OPEN_ACTIONS = [
    ('MFA für alle Admin-Konten',          'A.8.5 / NIS2 Art.21(2)(j)', 'Kritisch', 'Dr. M. Fischer', '28.02.26'),
    ('DORA Art.17: Vorfallsprozess',        'A.5.24 / DORA Art.17',      'Kritisch', 'T. Müller',      '28.02.26'),
    ('NIS2 Meldeprozess 24h/72h',           'A.5.26 / NIS2 Art.23',      'Kritisch', 'K. Braun',       '05.03.26'),
    ('DRP-Test durchführen',                'A.5.30 / RC.RP-03',         'Hoch',     'S. Wolf',        '10.03.26'),
    ('Lieferanten-Assessment (3 Anbieter)', 'A.5.21 / DORA Art.28',      'Hoch',     'M. Hoffmann',    '20.03.26'),
    ('TLPT Planung (Pentest)',               'A.8.29 / DORA Art.26',      'Kritisch', 'Dr. M. Fischer', '15.03.26'),
    ('Backup-Verschlüsselung AES-256',       'A.8.13 / PR.DS-11',         'Hoch',     'T. Müller',      '15.03.26'),
]

# ─── PDF GENERIEREN ────────────────────────────────────────
def build_pdf(output_path):
    doc = ISMSDocTemplate(
        output_path,
        pagesize=A4,
        leftMargin=15*mm, rightMargin=15*mm,
        topMargin=22*mm, bottomMargin=18*mm,
        title='SecureFrame ISMS — Statement of Applicability',
        author='Dr. M. Fischer (CISO)',
        subject='ISO 27001:2022 SoA + NIS2 + DORA',
    )

    story = []
    W = A4[0] - 30*mm  # Nutzbare Breite

    def hr(color=BORDER, thickness=0.5):
        return HRFlowable(width='100%', thickness=thickness, color=color, spaceAfter=6, spaceBefore=6)

    def spacer(h=4):
        return Spacer(1, h*mm)

    # ═══════════════════════════════════════════
    # DECKBLATT
    # ═══════════════════════════════════════════
    story.append(spacer(12))

    # Titel-Block
    cover_data = [[
        Paragraph('Statement of<br/>Applicability', S('CT', fontName='Helvetica-Bold', fontSize=32,
            textColor=WHITE, leading=38)),
        ''
    ]]
    cover_tbl = Table(cover_data, colWidths=[W * 0.7, W * 0.3])
    cover_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), DARK2),
        ('ROUNDEDCORNERS', [6]),
        ('TOPPADDING', (0,0), (-1,-1), 14),
        ('BOTTOMPADDING', (0,0), (-1,-1), 14),
        ('LEFTPADDING', (0,0), (-1,-1), 14),
        ('RIGHTPADDING', (0,0), (-1,-1), 14),
        ('LINEBELOW', (0,0), (-1,0), 2, ACCENT),
    ]))
    story.append(cover_tbl)
    story.append(spacer(4))

    # Meta-Info-Tabelle
    meta_items = [
        ['Organisation', 'MusterGmbH · Energiesektor (KRITIS)'],
        ['Dokument-ID', 'ISMS-SOA-2026-001'],
        ['ISO-Standard', 'ISO/IEC 27001:2022 (93 Controls, Annex A)'],
        ['Zusatz-Frameworks', 'NIST CSF 2.0 · NIS2 EU 2022/2555 · DORA EU 2022/2554'],
        ['ISMS-Scope', 'Alle IT-Systeme und Datenverarbeitungsprozesse inkl. Cloud'],
        ['Zertifizierungsaudit', '15.–17. April 2026 (TÜV Rheinland)'],
        ['Erstellt von', 'Dr. M. Fischer (CISO) · dr.fischer@mustergmbh.de'],
        ['Klassifizierung', 'VERTRAULICH · TLP:WHITE · Version 2.1'],
        ['Datum', datetime.date.today().strftime('%d. %B %Y')],
    ]
    meta_tbl = Table(
        [[Paragraph(r[0], META_STYLE), Paragraph(r[1], BODY_STYLE)] for r in meta_items],
        colWidths=[45*mm, W - 45*mm]
    )
    meta_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), DARK2),
        ('ROWBACKGROUNDS', (0,0), (-1,-1), [DARK2, colors.HexColor('#0f1620')]),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
        ('TEXTCOLOR', (0,0), (0,-1), TEXT_DIM),
        ('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 8),
        ('LINEBELOW', (0,-1), (-1,-1), 0.5, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
    ]))
    story.append(meta_tbl)
    story.append(spacer(6))

    # Compliance-Übersicht Kacheln
    scores = [
        ('ISO 27001:2022', '89%', GREEN, '82 / 93 Controls konform'),
        ('NIST CSF 2.0',   '75%', YELLOW, 'Tier-Ziel: 3 (Rep. Tier: 2.1)'),
        ('NIS2',           '71%', YELLOW, '3 kritische Artikel offen'),
        ('DORA',           '58%', ORANGE, '4 kritische Kapitel offen'),
    ]
    score_data = [[
        Table([[
            Paragraph(s[0], S('sl', fontName='Helvetica-Bold', fontSize=8, textColor=TEXT_DIM, leading=10)),
            Paragraph(s[1], S('sv', fontName='Helvetica-Bold', fontSize=22, textColor=s[2], leading=26)),
            Paragraph(s[3], S('ss', fontName='Helvetica', fontSize=7, textColor=TEXT_DIM, leading=10)),
        ]], colWidths=[(W/4 - 4*mm)])
        for s in scores
    ]]
    score_tbl_outer = Table(score_data, colWidths=[W/4]*4, hAlign='LEFT')
    score_tbl_outer.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), DARK2),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('INNERGRID', (0,0), (-1,-1), 0.5, BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 8),
        ('BOTTOMPADDING', (0,0), (-1,-1), 8),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(score_tbl_outer)

    story.append(PageBreak())

    # ═══════════════════════════════════════════
    # SEKTION 1: ISO 27001 CONTROLS (SoA-Kerntabelle)
    # ═══════════════════════════════════════════
    story.append(Paragraph('1. ISO/IEC 27001:2022 — Statement of Applicability', SECTION_STYLE))
    story.append(Paragraph(
        'Nachfolgend sind ausgewählte Controls des Annex A (93 Controls gesamt) mit Umsetzungsstatus, '
        'Einbeziehungsbegründung und Konformitätsgrad aufgeführt. Vollständige Tabelle (93 Controls) '
        'im digitalen Anhang. NEU = erstmals in der 2022-Revision eingeführtes Control.',
        BODY_STYLE))
    story.append(spacer(3))

    iso_header = [
        Paragraph('Control-Ref', TABLE_HEAD_STYLE),
        Paragraph('Titel', TABLE_HEAD_STYLE),
        Paragraph('Kategorie', TABLE_HEAD_STYLE),
        Paragraph('Einbez.', TABLE_HEAD_STYLE),
        Paragraph('Begründung', TABLE_HEAD_STYLE),
        Paragraph('Status', TABLE_HEAD_STYLE),
        Paragraph('Konf.', TABLE_HEAD_STYLE),
    ]
    iso_rows = [iso_header]
    for ref, title, cat, inc, just, pct in ISO_CONTROLS:
        col = status_color(pct)
        cat_color = {'Organisatorisch': ACCENT, 'Personenbezogen': ACCENT4,
                     'Physisch': ORANGE, 'Technologisch': ACCENT2}.get(cat, TEXT_MED)
        iso_rows.append([
            Paragraph(ref, TABLE_CODE_STYLE),
            Paragraph(title, TABLE_CELL_STYLE),
            Paragraph(cat, S('tc', fontName='Helvetica', fontSize=7,
                            textColor=cat_color, leading=10)),
            Paragraph(inc, S('ti', fontName='Helvetica-Bold', fontSize=8,
                            textColor=GREEN if inc=='Ja' else RED, leading=11)),
            Paragraph(just, TABLE_CELL_STYLE),
            Paragraph(status_text(pct), S('ts', fontName='Helvetica-Bold', fontSize=7,
                                          textColor=col, leading=10)),
            Paragraph(f'{pct}%', S('tp', fontName='Courier-Bold', fontSize=8,
                                   textColor=col, leading=11)),
        ])

    iso_tbl = Table(iso_rows,
        colWidths=[18*mm, 52*mm, 24*mm, 12*mm, 42*mm, 18*mm, 12*mm],
        repeatRows=1)
    iso_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#0d1117'), colors.HexColor('#0f1520')]),
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 5),
        ('RIGHTPADDING', (0,0), (-1,-1), 5),
        ('LINEBELOW', (0,0), (-1,0), 1, ACCENT),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(iso_tbl)

    # Annex A Kategorien-Zusammenfassung
    story.append(spacer(4))
    story.append(Paragraph('Konformitätszusammenfassung nach Annex-A-Kategorie', SUBSEC_STYLE))
    cat_data = [
        [Paragraph('Kategorie', TABLE_HEAD_STYLE),
         Paragraph('Controls gesamt', TABLE_HEAD_STYLE),
         Paragraph('Konform', TABLE_HEAD_STYLE),
         Paragraph('In Arbeit', TABLE_HEAD_STYLE),
         Paragraph('Offen', TABLE_HEAD_STYLE),
         Paragraph('Konformität', TABLE_HEAD_STYLE)],
        [Paragraph('Organisatorisch (A.5.x)', TABLE_CELL_STYLE), Paragraph('37', TABLE_CELL_STYLE),
         Paragraph('34', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=GREEN, leading=11)),
         Paragraph('2', TABLE_CELL_STYLE),
         Paragraph('1', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=YELLOW, leading=11)),
         Paragraph('91.9%', S('c', fontName='Courier-Bold', fontSize=8, textColor=GREEN, leading=11))],
        [Paragraph('Personenbezogen (A.6.x)', TABLE_CELL_STYLE), Paragraph('8', TABLE_CELL_STYLE),
         Paragraph('8', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=GREEN, leading=11)),
         Paragraph('0', TABLE_CELL_STYLE),
         Paragraph('0', TABLE_CELL_STYLE),
         Paragraph('100%', S('c', fontName='Courier-Bold', fontSize=8, textColor=GREEN, leading=11))],
        [Paragraph('Physisch (A.7.x)', TABLE_CELL_STYLE), Paragraph('14', TABLE_CELL_STYLE),
         Paragraph('11', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=YELLOW, leading=11)),
         Paragraph('2', TABLE_CELL_STYLE),
         Paragraph('1', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=RED, leading=11)),
         Paragraph('78.6%', S('c', fontName='Courier-Bold', fontSize=8, textColor=YELLOW, leading=11))],
        [Paragraph('Technologisch (A.8.x)', TABLE_CELL_STYLE), Paragraph('34', TABLE_CELL_STYLE),
         Paragraph('29', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=YELLOW, leading=11)),
         Paragraph('3', TABLE_CELL_STYLE),
         Paragraph('2', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=RED, leading=11)),
         Paragraph('85.3%', S('c', fontName='Courier-Bold', fontSize=8, textColor=YELLOW, leading=11))],
        [Paragraph('GESAMT', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=TEXT_LIGHT, leading=11)),
         Paragraph('93', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=WHITE, leading=11)),
         Paragraph('82', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=GREEN, leading=11)),
         Paragraph('7', TABLE_CELL_STYLE),
         Paragraph('4', S('c', fontName='Helvetica-Bold', fontSize=8, textColor=RED, leading=11)),
         Paragraph('88.2%', S('c', fontName='Courier-Bold', fontSize=8, textColor=GREEN, leading=11))],
    ]
    cat_tbl = Table(cat_data, colWidths=[55*mm, 28*mm, 22*mm, 22*mm, 22*mm, 29*mm], repeatRows=1)
    cat_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('BACKGROUND', (0,-1), (-1,-1), colors.HexColor('#0d1520')),
        ('ROWBACKGROUNDS', (0,1), (-1,-2), [colors.HexColor('#0d1117'), colors.HexColor('#0f1520')]),
        ('LINEBELOW', (0,0), (-1,0), 1, ACCENT),
        ('LINEABOVE', (0,-1), (-1,-1), 0.5, ACCENT),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
        ('ALIGN', (1,0), (-1,-1), 'CENTER'),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(cat_tbl)

    story.append(PageBreak())

    # ═══════════════════════════════════════════
    # SEKTION 2: NIS2
    # ═══════════════════════════════════════════
    story.append(Paragraph('2. NIS2-Richtlinie (EU 2022/2555) — Compliance-Status', SECTION_STYLE))
    story.append(Paragraph(
        'Die NIS2-Richtlinie ist seit dem 17. Oktober 2024 in nationales Recht umzusetzen und ersetzt die '
        'NIS1-Richtlinie. Sie gilt für wesentliche und wichtige Einrichtungen in 18 Sektoren. '
        'Bußgelder für wesentliche Einrichtungen: bis 10 Mio. EUR oder 2% des globalen Jahresumsatzes.',
        BODY_STYLE))
    story.append(spacer(3))

    nis2_header = [
        Paragraph('Artikel', TABLE_HEAD_STYLE),
        Paragraph('Anforderung', TABLE_HEAD_STYLE),
        Paragraph('Konformität', TABLE_HEAD_STYLE),
        Paragraph('Status', TABLE_HEAD_STYLE),
        Paragraph('Bußgeld-Risiko', TABLE_HEAD_STYLE),
    ]
    nis2_rows = [nis2_header]
    for art, req, pct, risk in NIS2_ARTICLES:
        col = status_color(pct)
        risk_col = RED if 'Kritisch' in risk else (ORANGE if 'Hoch' in risk else YELLOW if 'Mittel' in risk else GREEN)
        nis2_rows.append([
            Paragraph(art, TABLE_NIS2_STYLE),
            Paragraph(req, TABLE_CELL_STYLE),
            Paragraph(f'{pct}%', S('tp', fontName='Courier-Bold', fontSize=8, textColor=col, leading=11)),
            Paragraph(status_text(pct), S('ts', fontName='Helvetica-Bold', fontSize=7, textColor=col, leading=10)),
            Paragraph(risk, S('tr', fontName='Helvetica-Bold', fontSize=7, textColor=risk_col, leading=10)),
        ])

    nis2_tbl = Table(nis2_rows, colWidths=[28*mm, 70*mm, 18*mm, 22*mm, 40*mm], repeatRows=1)
    nis2_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#0d1117'), colors.HexColor('#0f1520')]),
        ('LINEBELOW', (0,0), (-1,0), 1, ACCENT4),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(nis2_tbl)

    story.append(spacer(5))

    # Handlungsempfehlungen NIS2
    story.append(Paragraph('Kritische NIS2-Lücken — Sofortmaßnahmen', SUBSEC_STYLE))
    actions_data = [
        [Paragraph('Priorität', TABLE_HEAD_STYLE),
         Paragraph('Artikel', TABLE_HEAD_STYLE),
         Paragraph('Maßnahme', TABLE_HEAD_STYLE),
         Paragraph('Frist', TABLE_HEAD_STYLE)],
        [Paragraph('KRITISCH', S('p', fontName='Helvetica-Bold', fontSize=8, textColor=RED, leading=11)),
         Paragraph('Art. 21(2)(j)', TABLE_NIS2_STYLE),
         Paragraph('MFA für alle privilegierten Zugänge aktivieren (Microsoft Entra ID)', TABLE_CELL_STYLE),
         Paragraph('28.02.2026', S('d', fontName='Courier', fontSize=8, textColor=RED, leading=11))],
        [Paragraph('KRITISCH', S('p', fontName='Helvetica-Bold', fontSize=8, textColor=RED, leading=11)),
         Paragraph('Art. 23', TABLE_NIS2_STYLE),
         Paragraph('Meldeprozess für Sicherheitsvorfälle (24h Erstmeldung, 72h Folgemeldung) implementieren', TABLE_CELL_STYLE),
         Paragraph('05.03.2026', S('d', fontName='Courier', fontSize=8, textColor=RED, leading=11))],
        [Paragraph('HOCH', S('p', fontName='Helvetica-Bold', fontSize=8, textColor=ORANGE, leading=11)),
         Paragraph('Art. 21(2)(c)', TABLE_NIS2_STYLE),
         Paragraph('Business Continuity Plan (BCP) testen und aktualisieren', TABLE_CELL_STYLE),
         Paragraph('10.03.2026', S('d', fontName='Courier', fontSize=8, textColor=YELLOW, leading=11))],
    ]
    act_tbl = Table(actions_data, colWidths=[22*mm, 28*mm, 100*mm, 28*mm], repeatRows=1)
    act_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#140810'), colors.HexColor('#120d18')]),
        ('LINEBELOW', (0,0), (-1,0), 1, RED),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, colors.HexColor('#3a1520')),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(act_tbl)

    story.append(PageBreak())

    # ═══════════════════════════════════════════
    # SEKTION 3: DORA
    # ═══════════════════════════════════════════
    story.append(Paragraph('3. DORA (EU 2022/2554) — IKT-Resilienz-Status', SECTION_STYLE))
    story.append(Paragraph(
        'Der Digital Operational Resilience Act (DORA) gilt ab dem 17. Januar 2025 verbindlich für '
        'Finanzunternehmen und deren kritische IKT-Drittdienstleister. '
        'Sanktionen: bis zu 1% des täglichen Weltumsatzes; kritische Drittdienstleister bis 5 Mio. EUR.',
        BODY_STYLE))
    story.append(spacer(3))

    dora_header = [
        Paragraph('Kapitel / Artikel', TABLE_HEAD_STYLE),
        Paragraph('Anforderung', TABLE_HEAD_STYLE),
        Paragraph('Konf.', TABLE_HEAD_STYLE),
        Paragraph('Status', TABLE_HEAD_STYLE),
        Paragraph('Priorität', TABLE_HEAD_STYLE),
        Paragraph('Frist', TABLE_HEAD_STYLE),
    ]
    dora_rows = [dora_header]
    for art, req, pct, prio, frist in DORA_ARTICLES:
        col = status_color(pct)
        prio_col = prio_color(prio)
        dora_rows.append([
            Paragraph(art, TABLE_DORA_STYLE),
            Paragraph(req, TABLE_CELL_STYLE),
            Paragraph(f'{pct}%', S('tp', fontName='Courier-Bold', fontSize=8, textColor=col, leading=11)),
            Paragraph(status_text(pct), S('ts', fontName='Helvetica-Bold', fontSize=7, textColor=col, leading=10)),
            Paragraph(prio, S('tp2', fontName='Helvetica-Bold', fontSize=7, textColor=prio_col, leading=10)),
            Paragraph(frist, S('tf', fontName='Courier', fontSize=8, textColor=TEXT_MED, leading=11)),
        ])

    dora_tbl = Table(dora_rows, colWidths=[28*mm, 68*mm, 14*mm, 20*mm, 18*mm, 18*mm], repeatRows=1)
    dora_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#0d1117'), colors.HexColor('#0d1320')]),
        ('LINEBELOW', (0,0), (-1,0), 1, ACCENT2),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(dora_tbl)

    story.append(PageBreak())

    # ═══════════════════════════════════════════
    # SEKTION 4: OFFENE MASSNAHMEN
    # ═══════════════════════════════════════════
    story.append(Paragraph('4. Offene Maßnahmen — Priorisierter Aktionsplan', SECTION_STYLE))
    story.append(Paragraph(
        'Nachfolgende Maßnahmen sind gemäß Risikoeinstufung und regulatorischer Dringlichkeit priorisiert. '
        'Kritische Maßnahmen gefährden bei Nichterfüllung die ISO-27001-Zertifizierung und können NIS2/DORA-Bußgelder auslösen.',
        BODY_STYLE))
    story.append(spacer(3))

    act_header = [
        Paragraph('Maßnahme', TABLE_HEAD_STYLE),
        Paragraph('Control / Artikel', TABLE_HEAD_STYLE),
        Paragraph('Priorität', TABLE_HEAD_STYLE),
        Paragraph('Verantwortlich', TABLE_HEAD_STYLE),
        Paragraph('Frist', TABLE_HEAD_STYLE),
    ]
    act_rows = [act_header]
    for title, ctrl, prio, owner, due in OPEN_ACTIONS:
        prio_col = prio_color(prio)
        due_col = RED if '26' in due and int(due.split('.')[0]) <= 10 else YELLOW
        act_rows.append([
            Paragraph(title, TABLE_CELL_STYLE),
            Paragraph(ctrl, S('tc', fontName='Courier', fontSize=7, textColor=ACCENT, leading=10)),
            Paragraph(prio, S('tp', fontName='Helvetica-Bold', fontSize=8, textColor=prio_col, leading=11)),
            Paragraph(owner, TABLE_CELL_STYLE),
            Paragraph(due, S('td', fontName='Courier-Bold', fontSize=8, textColor=due_col, leading=11)),
        ])

    actions_tbl = Table(act_rows, colWidths=[65*mm, 40*mm, 18*mm, 30*mm, 25*mm], repeatRows=1)
    actions_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#0d1117'), colors.HexColor('#0f1520')]),
        ('LINEBELOW', (0,0), (-1,0), 1, ACCENT),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 6),
        ('RIGHTPADDING', (0,0), (-1,-1), 6),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(actions_tbl)

    story.append(spacer(6))
    story.append(hr(ACCENT, 1))
    story.append(spacer(3))

    # Freigabe-Unterschriften
    story.append(Paragraph('5. Freigabe und Genehmigung', SECTION_STYLE))
    sign_data = [
        [Paragraph('Funktion', TABLE_HEAD_STYLE),
         Paragraph('Name', TABLE_HEAD_STYLE),
         Paragraph('Datum', TABLE_HEAD_STYLE),
         Paragraph('Unterschrift', TABLE_HEAD_STYLE)],
        [Paragraph('CISO (Ersteller)', TABLE_CELL_STYLE),
         Paragraph('Dr. M. Fischer', TABLE_CELL_STYLE),
         Paragraph(datetime.date.today().strftime('%d.%m.%Y'), TABLE_CELL_STYLE),
         Paragraph('_' * 28, META_STYLE)],
        [Paragraph('ISO 27001 Lead Auditor', TABLE_CELL_STYLE),
         Paragraph('(TÜV Rheinland)', TABLE_CELL_STYLE),
         Paragraph('15.04.2026', TABLE_CELL_STYLE),
         Paragraph('_' * 28, META_STYLE)],
        [Paragraph('Geschäftsführung', TABLE_CELL_STYLE),
         Paragraph('M. Hoffmann (CEO)', TABLE_CELL_STYLE),
         Paragraph('________________', META_STYLE),
         Paragraph('_' * 28, META_STYLE)],
    ]
    sign_tbl = Table(sign_data, colWidths=[45*mm, 45*mm, 30*mm, W - 120*mm], repeatRows=1)
    sign_tbl.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), DARK2),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.HexColor('#0d1117'), colors.HexColor('#0f1520')]),
        ('LINEBELOW', (0,0), (-1,0), 1, ACCENT),
        ('LINEBELOW', (0,1), (-1,-1), 0.3, BORDER),
        ('BOX', (0,0), (-1,-1), 0.5, BORDER),
        ('TOPPADDING', (0,0), (-1,-1), 10),
        ('BOTTOMPADDING', (0,0), (-1,-1), 10),
        ('LEFTPADDING', (0,0), (-1,-1), 8),
        ('RIGHTPADDING', (0,0), (-1,-1), 8),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
    ]))
    story.append(sign_tbl)

    doc.build(story)
    print(f"PDF erfolgreich erstellt: {output_path}")


if __name__ == '__main__':
    build_pdf('/mnt/user-data/outputs/isms-soa-report.pdf')
