# ACS Smart Galați - Site Web Static (`ag-flash3.8-site`)

Soluție modernă de site web static pentru clubul de șah **ACS Smart Galați** ([smartgalati.ro](https://smartgalati.ro/)), dezvoltată conform comenzii de lucru [`engineering-docs/work-orders/2026-09-26-chessclub-website.md`](../engineering-docs/work-orders/2026-09-26-chessclub-website.md).

---

## 1. Arhitectură și Tehnologii

- **Framework**: [Astro 5](https://astro.build/) configurat în mod static pur (`output: "static"`). Zero JavaScript pe paginile de prezentare, asigurând viteză instantanee și scoruri maxime Lighthouse.
- **Stilizare**: [Tailwind CSS](https://tailwindcss.com/) cu o paletă elegantă specifică șahului (slate profund, ivoire cald, accente aurii și texturi subtile de tablă de șah).
- **Gestiune Conținut**: Astro Content Collections cu validare Zod și încărcare directă din `content/`.
- **Multilingvism (i18n)**: Limba implicită este română (`ro`), configurat nativ pentru adăugarea facilă a altor limbi (ex: `en`).
- **Compatibilitate CMS / Git**: Textele sunt fișiere Markdown pure. Conținutul poate fi editat direct din interfața web GitHub sau printr-un CMS Git-backed (Keystatic / Decap CMS).
- **Comutator de Teme (5 Palete Open-Source)**: Selector direct în meniul de sus (dreapta) care permite comutarea instantanee, fără reîncărcare de pagină, cu persistență automată în `localStorage`:
  1. 🌙 **Classic Dark** — Ardezie profundă și accente de aur/chihlimbar.
  2. ☀️ **Solarized Light** — Celebra paletă a lui Ethan Schoonover (crem `#fdf6e3`, panouri `#eee8d5`, accente `#b58900`).
  3. ❄️ **Nordic Clean** — Minimalism scandinav, alb arctic (`#f8fafc`), text ardezie închis și accente bleu-ceresc.
  4. ♟️ **Tournament Green** — Aspectul clasic al tablelor de șah de concurs (verde smarald, chenar fildeș și text cald).
  5. ⚡ **Midnight Blitz** — Contrast ridicat inspirat din tema Dracula (`#21222c`, accente portocaliu și violet).
- **Protecție Anti-Spam**: Datele de contact (email și telefon) sunt protejate împotriva roboților automați de recoltare prin inversare direcțională CSS și buton inteligent de deblocare/copiere.

---

## 2. Comenzi de Dezvoltare și Rulare Locală

Din directorul `ag-flash3.8-site`:

```bash
# Instalare dependințe
npm install

# Pornire server local de dezvoltare cu hot-reload (http://localhost:4321)
npm run dev

# Verificare tipuri și construire statică de producție (generează dist/)
npm run build

# Previzualizare locală a build-ului de producție
npm run preview
```

---

## 3. Organizarea Conținutului pentru Non-Dezvoltatori

Toate textele site-ului sunt organizate în directorul dedicat `content/`, fără amestec cu codul sursă:

```text
content/
├── README.md               # Ghid detaliat în limba română pentru antrenori
├── pages/                  # Pagini statice principale
│   ├── despre-noi.md       # Istoric, misiune, obiective
│   ├── echipe.md           # Seniori și juniori Divizia Națională
│   ├── contact.md          # Adresă, orar, program, formular
│   └── sustine.md          # Formular 230 (3.5% impozit) & sponsorizări
├── coaches/                # Profile antrenori și conducere
│   ├── lucian-gilea.md     # Președinte & Antrenor principal (MF Elo 2280)
│   ├── cristian-daianu.md  # Instructor sportiv (MF Elo 2166)
│   ├── robert-pisu.md      # Instructor sportiv (MF Elo 2230)
│   ├── flavius-mihailiuc.md# Secretar general & arbitru național
│   ├── robert-ionica.md    # Instructor sportiv & pedagog
│   ├── danut-radu.md       # Instructor șah (Elo 2105)
│   └── _template.md        # Model de copiat
├── performances/           # Rezultate și medalii oficiale
│   ├── 2024-campionat-echipe.md
│   ├── 2023-juniori-blitz.md
│   ├── 2022-cupa-romaniei.md
│   └── _template.md
└── news/                   # Știri, concursuri, turnee blitz
    ├── 2025-02-09-blitz-editia-2.md (articol recent)
    ├── 2024-03-20-memorialul-de-sah-editia-5.md (articol arhivat)
    └── _template.md
```

### Regula de Arhivare la 2 Ani
Articolele din `content/news/` cu o vechime mai mare de 2 ani sunt direcționate **automat** către secțiunea de **Arhivă** (`/arhiva/` și `/arhiva/[slug]`). Secțiunea principală de noutăți (`/noutati/`) rămâne aerisită și concentrată pe evenimentele actuale, fără a necesita mutarea manuală a fișierelor de către antrenori.

---

## 4. Gestiunea Imaginilor și Mediilor (Modelul Hibrid)

1. **Active Esențiale Locale** (`public/images/`):
   - Sigla clubului (`logo.svg`), grafica hero (`hero-chess.svg`), portretele antrenorilor și imaginile reprezentative de copertă sunt versionate în repo pentru fiabilitate și viteză.
2. **Albume Foto de la Turnee (Google Photos)**:
   - Pentru a evita încărcarea repository-ului Git cu sute de poze de pe telefon, antrenorii adaugă link-ul unui album public Google Photos în antetul articolului:
     ```markdown
     photos_album_url: "https://photos.app.goo.gl/..."
     photos_count: 54
     ```
   - Site-ul generează automat un card grafic cu insignă și link direct către album.

---

## 5. Integrare Șah & Lichess

- **Studii Interactive**: Orice articol sau pagină poate include un studiu Lichess adăugând `lichess_study_url` în frontmatter sau folosind componenta `<LichessEmbed />`.
- **Lichess TV & Partide Live**: Pagina dedicată `/lichess` demonstrează transmiterea în direct a partidelor de mari maeștri și lecții tactice.
- **Independență**: Site-ul rămâne 100% funcțional chiar dacă serviciile externe Lichess sunt temporar indisponibile.

---

## 6. Găzduire și Previzualizare

- **Adresă previzualizare**: `smartgalati-test.mycodespace.ai`
- **Ținte de găzduire compatibile**: GitHub Pages sau Google Cloud Storage (GCS). Build-ul static din `dist/` este portabil și gata de publicare prin GitHub Actions.
