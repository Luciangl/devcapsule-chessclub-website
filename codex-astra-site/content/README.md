# Ghid de conținut — ACS Smart Galați

Conținutul acestui site este independent de celelalte variante. Editează fișierele din `codex-astra-site/content/`, din IDE sau direct pe GitHub, fără să modifici aspectul paginilor.

## Publică o știre

1. Copiază `news/_template.md` în `news/AAAA-LL-ZZ-titlu-scurt.md`.
2. Completează titlul, data și rezumatul dintre liniile `---`.
3. Scrie textul mai jos: `##` pentru subtitluri, `**text**` pentru accent, `[text](https://...)` pentru linkuri.
4. Pentru o copertă, adaugă un JPG în `src/assets/photos/` și scrie doar numele fișierului în `cover_image`. Folosește fotografii pentru care clubul are drept de publicare.
5. Verifică local cu `npm run dev`, apoi salvează modificarea. Publicarea se face prin procesul de deploy din README.

Nu copia liniile opționale cu linkuri demonstrative ca și cum ar fi linkuri reale. Dacă nu ai album sau studiu Lichess, lasă liniile comentate ori elimină-le. Nu folosi un șir gol pentru un câmp URL.

## Ce fișier editez?

| Director | Conținut |
|---|---|
| `home/` | Titlul, introducerea, cardurile de cursuri și povestea de pe prima pagină |
| `pages/` | Despre noi, cursuri, echipe, contact, susținere |
| `coaches/` | Un fișier pentru fiecare antrenor; `order` stabilește ordinea |
| `performances/` | Rezultate, categorie, an, medalii |
| `news/` | Articole și anunțuri, sortate după dată |
| `galleries/` | Albume, descrieri, fotografii locale și/sau linkuri externe |

Fișierele `_template.md` nu se publică. Nu redenumi fișierele publicate fără să discuți cu persoana care întreține site-ul: numele face parte din adresă.

## Arhivarea automată

La fiecare build, articolele mai vechi de doi ani față de data UTC a buildului apar în `/arhiva/AN/NUME/`. Cele exact la limita de doi ani rămân în noutăți. Nu muta fișierele manual. Site-ul este static: o nouă publicare actualizează arhiva; nu se schimbă singur la miezul nopții. Rezultatele din `performances/` reprezintă palmaresul permanent, nu știrile.

## Fotografii și albume

Fotografiile locale sunt optimizate automat în WebP la build. Cele 51 de fotografii istorice au fost preluate din arhiva existentă a clubului. Pentru evenimente noi cu multe imagini, recomandăm un album public extern și o singură copertă locală. În `galleries/_template.md` găsești ambele variante. Completează `alt` cu o descriere reală a fotografiei; evită date personale inutile.

## Contact și formular

Adresa formularului este păstrată intenționat: `https://forms.gle/smartgalati-inscriere`. Este un link cunoscut ca nefuncțional în acest experiment; nu îl înlocui fără instrucțiuni. Butoanele comune folosesc `src/lib/site.ts`; linkul editorial este în `pages/contact.md`.

Telefonul și emailul se dezvăluie la apăsarea unui buton. Nu le adăuga în textul Markdown dacă dorești să păstrezi protecția simplă împotriva colectării automate. Protecția nu este o garanție împotriva unui colector care execută JavaScript.

## Verificare și limite

`npm run build` verifică schema câmpurilor și tipurile înainte de generare. Confirmă cu clubul programul, componența echipelor, titulaturile și rezultatele înainte de publicarea în producție. Textul inițial provine din varianta de site existentă; nu reprezintă o verificare independentă a acestor informații.

Nu este instalat un CMS vizual. Editarea Markdown prin GitHub și IDE este metoda complet funcțională; un CMS Git poate fi adăugat ulterior fără schimbarea formatului.
