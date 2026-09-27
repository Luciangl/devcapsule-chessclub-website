# Ghid de Editare Conținut (Pentru Antrenori și Administratori)

Acest director (`content/`) conține toate textele, articolele și paginile site-ului **ACS Smart Galați**.
Nu este nevoie să știi programare sau HTML pentru a adăuga sau modifica conținut!

---

## 1. Cum funcționează fișierele Markdown?

Fiecare pagină sau articol este un fișier text simplu cu extensia `.md` (Markdown).
În partea de sus a fiecărui fișier se află un bloc între linii `---` numit **frontmatter** (informații de identificare), urmat de textul propriu-zis.

Exemplu simplu:
```markdown
---
title: "Titlul Articolului sau Paginii"
date: 2025-02-09
summary: "O scurtă descriere de 1-2 propoziții care apare în lista de știri."
cover_image: "/images/news/foto.jpg"
tags: ["blitz", "turnee"]
photos_album_url: "https://photos.app.goo.gl/..."
---

Aici scrii textul normal. Poți folosi:
- **Text îngroșat** punând două steluțe: `**text**`
- *Text cursiv* punând o steluță: `*text*`
- Subtitluri punând două diezuri: `## Subtitlu`
- Liste folosind liniuță la început de rând: `- Punct 1`
```

---

## 2. Structura directoarelor

- **`content/news/`**: Articole de știri, anunțuri de turnee, rapoarte de concurs.
  - Fișierele au numele de forma: `AN-LUNA-ZI-titlu.md` (ex: `2025-02-09-blitz-editia-2.md`).
  - *Regula de Arhivare*: Articolele mai vechi de 2 ani sunt mutate automat de site în secțiunea **Arhivă**, fără să fie nevoie să le muți manual!
  - Găsești un model gata de copiat în: `content/news/_template.md`.
- **`content/coaches/`**: Profilele antrenorilor și conducerii clubului.
  - Model: `content/coaches/_template.md`.
- **`content/performances/`**: Rezultatele și medaliile obținute la campionate naționale/internaționale.
  - Model: `content/performances/_template.md`.
- **`content/pages/`**: Paginile principale ale site-ului:
  - `despre-noi.md`: Istoria clubului, misiune, viziune.
  - `contact.md`: Date de contact, adresă, orar.
  - `echipe.md`: Componența echipelor de seniori și juniori.
  - `sustine.md`: Direcționarea a 3.5% din impozit (Formular 230) și sponsorizări.

---

## 3. Cum adaugi fotografii și galerii?

Ai la dispoziție două moduri flexibile:

1. **Fotografii principale (Copertă / Portret)**:
   - Pentru poza principală a articolului sau a unui antrenor, pune imaginea în folderul `public/images/news/` sau `public/images/coaches/`.
   - În fișierul `.md`, scrie calea: `cover_image: "/images/news/nume-poza.jpg"`.
2. **Albume întregi de la turnee (Zeci sau sute de poze)**:
   - Încarcă pozele de pe telefon într-un album public de **Google Photos**.
   - Copiază link-ul albumului și pune-l în articol:
     `photos_album_url: "https://photos.app.goo.gl/exemplu"`
   - Site-ul va afișa automat un buton elegant cu insignă către albumul complet!

---

## 4. Cum integrezi partide Lichess?

Dacă vrei să arăți o partidă analizată sau un studiu de pe Lichess într-un articol:
- În antetul articolului, adaugă:
  `lichess_study_url: "https://lichess.org/study/embed/ID_STUDIU/ID_CAPITOL?theme=brown&bg=dark"`
- Sau poți pune direct codul iframe în textul articolului.
