# TODO Maturaarbeit Project-Polearm, in Reihenfolge

Stand: Sa 31.10.2026 · **Druck: Mo 9.11.** · **Abgabe: Di 10.11.** · Präsentation 24.–26.11.
Ältere, ausführliche Liste: `Source/_alt/TODO_Begleitbericht_bis-31-10.md`

**Kapitel (neu):** 1 Einleitung · 2 Theorie & Methodik · 3 Analysen · 4 Leveldesign · 5 Design & Umsetzung (`5Umsetzung.tex`) · 6 Evaluation (`7Evaluation.tex`) · 7 Schlussfolgerung (`8Schlussfolgerung.tex`) · 8 Reflexion (`9Reflektion.tex`) · 9 Verzeichnisse/Anhang (`10Verzeichnis.tex`)

**Täglich nebenher (20–30 min):** Arbeitsjournal nachführen, mit Zeitaufwand, Reflexion und KI-Nachweis (Tool, Prompt, Datum, Zweck).

**Kontrollpunkte:** Mi 4.11. abends: Kap. 5 fertig, Kap. 6 halb · Fr 6.11. abends: alle Kapitel inhaltlich geschrieben (**Inhaltsstopp**). Wenn du im Rückstand bist, kürzt du zuerst beim README, dann bei optionalen Abbildungen.

---

## ✅ Erledigt

- [x] Game-Polish (31.10.)
- [x] Mängelliste erstellt, Kap. 5 und 6 zusammengelegt, Begriff „Designvorschlag V1–V8“ vereinheitlicht
- [x] Kap. 5: Rohtext strukturiert (Gegnertypen, V1–V8, Raumtabelle)
- [x] Anhang: Layout nur noch mit Nummern und Antworten, TP4/TP5-Notizen B1–B14 zugeordnet, Kompilierfehler behoben
- [x] **Gliederung festgelegt (1.11.)**: Kap. 2 = Grundlagen und Methodik (2.3 Analyseframework, 2.4 Leveldesign-Recherche, 2.5 Umsetzung *neu*, 2.6/2.7 Playtests mit Auswahl der Testpersonen und Auswertung *neu*), 1.4 Aufbau *neu*, Kap. 4 Zwischenfazit *neu*, Kap. 5 mit Prototyp-Überblick zuerst, Kap. 6 neu gegliedert, 8.3 KI *neu*, Kap. 9 mit Ludografie/Tabellenverzeichnis/Assets/Erklärung, Anhang separat. Alle neuen Unterkapitel haben rote Stichpunkte; Erinnerungen ans Vorgehen am Anfang von Kap. 3–6.
- [x] Kap. 5 (1.11.): Playtest-Spalte aus Tab. 1 entfernt, Gegnerbild und Karte eingebunden, Werte in V1 angepasst, Gegnermanager-Text in V2, „Soldier“ überall korrigiert

---

## 1 · Blocker & Absprachen (Sa 31.10. – So 1.11.)

- [ ] **TP1 (Cyrill) vervollständigen:** Post, Beobachtungsraster und Interview aus der Aufnahme ergänzen, oder TP1 durchführen (rote Platzhalter in `10Verzeichnis.tex`). Falls das nicht klappt: mit n = 4 arbeiten und das in den Limitationen nennen.
- [ ] **Mail an Herrn Schneider** (eine Mail, alles auf einmal):
  - [ ] Erkenntnisfrage und Titel weichen vom Vertrag ab → ok?
  - [ ] Zitierstil biblatex (authortitle) statt Kanti-Fussnotenstil → ok?
  - [ ] Umfang (~40 S. + technische Doku) → ok?
  - [ ] KI-Nachweis bei langen Chats: erster Prompt wörtlich + Chat-Export im Logbuch → reicht das?
  - [ ] Falls nötig: Aufgabenteilung bzw. Beitrag von Zhile ansprechen
- [ ] Definitiven **Titel (≤ 50 Zeichen) + Untertitel (≤ 150, mit Projektform) im schulNetz** erfassen

## 2 · Kapitel 5 Design & Umsetzung (So 1.11. – Mo 2.11.)

- [ ] **Widersprüche klären:**
  - [ ] **V2: Vorschlag „nie alle greifen gleichzeitig an“ vs. Umsetzung „meistens greifen alle an“** (wichtigster Punkt, betrifft auch V4)
  - [ ] „Kein Gegner kann springen“ vs. „Heavy Soldier springt irgendwohin“ (TP5)
  - [ ] „Welle: 10–30 Gegner“ vs. Raum 1/2 (1 bzw. 5 Gegner)
  - [ ] V4-Begründung („so viele greifen gleichzeitig an“) widerspricht V2 → umformulieren
  - [ ] V5: „Soldiers zufällig“ vs. „erste Aufstellung manuell“ → präzisieren
  - [ ] „Raum 7.5“ (TP2) und „12 Räume“ vs. Karte (Raum 3 = Raum 12) → Rundgang im Text beschreiben
- [ ] **Raumtabelle Räume 6–12** ausfüllen (Ablauf, Funktion)
- [ ] **„Überprüfbarkeit“ bei V1–V8:** jeweils Datei, Szene oder Klasse bzw. Kapitel der technischen Doku nennen
- [ ] Offene Fragen in den roten Notizen: Angriffsmodus-Vergabe (V2), Rollensystem ja/nein (V3), Zeitfenster Telegraph (V4), Erholung zwischen Wellen begründen (V7), „Heavy Archer → Heavy Soldier“ prüfen, pro Level vs. pro Raum (V8)
- [ ] **Abbildungen:** Karte aufwerten (Raumtypen farbig + Legende, Weg als Pfeile, Drop-in 11→12, höhere Auflösung); Chain Archer im Gegnerbild ggf. neu aufnehmen; optional Screenshot einer Angriffsankündigung
- [ ] V6: Einteilung der Raumtypen ausdrücklich als eigene Anpassung von Totten kennzeichnen
- [ ] Kapiteleinleitung und Einleitung 5.1 in eigenen Worten gegenlesen
- [ ] Alle roten Notizen in `5Umsetzung.tex` abarbeiten und löschen

## 3 · Kapitel 6 Evaluation (Mo 2.11. – Mi 4.11.)

- [ ] **6.2 Durchführung** neu schreiben (der aktuelle Text ist umgangssprachlich): Datum/Ort, Hardware/Eingabe, Dauer, Instruktionen (mündliche Erklärung wegen fehlendem Tutorial), Aufnahme, wer beobachtet hat
- [ ] **Testpersonen** (Kap. 2.6.1, dort steht noch „kommt noch“): anonymisierte Tabelle TP1–TP5 (Spielzeit, Genres, Können P5, Spielstil P6), Rekrutierung offenlegen
- [ ] **Auswertungsmethode** in 2–3 Sätzen: Likert → Median/Mittelwert/Spannweite; qualitative Daten pro Vorschlag; Fragebogen, Beobachtung und Interview zusammen auswerten
- [ ] **6.3.1 Quantitativ:** Tabelle Q1–Q11 × TP + ein Diagramm (Claude kann das aus dem Anhang erstellen)
- [ ] **6.3.2 Qualitativ:** wichtigste Muster pro Vorschlag mit Verweis auf den Anhang (TP/Item)
- [ ] **6.4.1 Interpretation pro V1–V8:** bestätigt / teilweise / nicht bestätigt, mit Belegen. Streuung und Widersprüche diskutieren (z. B. Q4 Telegraphing, Q6 Raum, Q7 Erholung). **Selbst schreiben.**
- [ ] **6.4.2 Verbesserungsvorschläge:** konkret, jeder mit Datenbeleg (z. B. Audio-Telegraph, Tutorial, Signal beim Türöffnen, Combos abbrechbar, Block)

## 4 · Kapitel 7 Schlussfolgerung (Do 5.11.)

- [ ] 7.1 Erkenntnisfrage **explizit beantworten** (auf Basis von Recherche, Analyse, Prototyp und Playtest)
- [ ] 7.2 Wichtigste Erkenntnisse (inhaltlich + aus dem Arbeitsprozess)
- [ ] 7.3 Limitationen: n klein, Testpersonen aus dem Umfeld, kein Tutorial, Analysen nur von aussen, Quellen nicht genrespezifisch, fehlende Zeitstempel, Zeitmangel
- [ ] 7.4 Ausblick: 2–4 Punkte (z. B. Spawn-Art als Variable, Höhen/Flanken, Audio-Telegraphing)

## 5 · Kapitel 8 Reflexion (Do 5.11.)

- [ ] 8.1 Arbeitsprozess: Plan vs. Realität (Meilensteine laut Vertrag), Scope-Entscheide, was du anders machen würdest
- [ ] **KI-Reflexion** (gehört zur Bewertung des Arbeitsprozesses): wofür, Nutzen, Grenzen, wie überprüft
- [ ] 8.2 Gruppenarbeit + **Tabelle Aufgabenteilung/Eigenleistung** (Bericht und Prototyp: Rodin / Zhile / gemeinsam)
- [ ] 8.3 Persönliche Erkenntnisse

## 6 · Kapitel 2–4 überarbeiten (Fr 6.11.)

- [ ] Kap. 2: kaputten Einleitungssatz reparieren („Des weiteren ist unser Vorgehen und es…“)
- [ ] Kap. 2: **Tabelle Analyseframework** (A1–M5 → Kriterium → Begründung + Quelle), das ist ein Vertragspunkt
- [ ] Kap. 2: leere Überschrift „Fragebogen“ füllen oder löschen; Auswahlkriterium der Recherche nennen (wirkt auf Gegnerverhalten/-platzierung, umsetzbar, im Playtest prüfbar)
- [ ] Kap. 2: doppelter Punkt nach `\autocite{drachen…}.` entfernen
- [ ] Kap. 3: **3.3.3 „Erkenntnisse für Project-Polearm“ neu** (rote Notiz)
- [ ] Kap. 3: „Dies ist befriedigend, weil…“ als eigene Interpretation formulieren; M5 Input-Buffer und M4 Super-Armor abschwächen oder belegen; Methode der Analyse ergänzen (Plattform, Missionen, Spielzeit)
- [ ] Kap. 3: Widerspruch Raumverengung beheben (M3 hypothetisch formuliert vs. 4.3 „beobachtet“)
- [ ] Kap. 3: Combo-lastige Antworten (A5, D5, M5) kürzen
- [ ] Kap. 4: Bloat streichen (Burnout/Mehrfachpfade, Backtracking, Lynch, Pickups, Counter-Strike-Scanning); behalten, was Kap. 5 nutzt
- [ ] Kap. 4.1: rote Notiz durch Verweis auf 5.2.1 und die technische Doku ersetzen
- [ ] Ninja Gaiden einheitlich als „Sigma Plus“

## 7 · Einleitung & Abstract (Fr 6.11.) → **INHALTSSTOPP**

- [ ] 1.3 Zielsetzung/Produktdefinition schreiben (Produktbestandteile laut Vertrag A.4), rote Platzhalter weg
- [ ] Abgrenzung Begleitbericht ↔ technische Doku, Relevanz/Zielgruppe, **Aufbau der Arbeit**
- [ ] Abstract: „[Kernergebnis]“ ersetzen, **300 ± 50 Wörter, 3 Absätze**, Überschrift „Abstract“ (`\renewcommand{\abstractname}{Abstract}`), „Ninja Gaiden Sigma Plus“

## 8 · Transparenz (Sa 7.11.)

- [ ] **KI-Deklaration neu** (nach dem Abbildungsverzeichnis): Tabelle mit Datum, Tool/Version, Raster-Bereich, Stelle, Prompt, Art der Übernahme, Eigenanteil/Überprüfung. Absolute Aussagen („sämtlicher Code selbst“, „keine inhaltlichen Bestandteile“) korrigieren.
- [ ] Kurze KI-Fussnoten an den betroffenen Stellen (Kap. 5, Anhang Beobachtungsraster)
- [ ] **KI-Raster** (docx) mit Seitenverweisen ins Logbuch ausfüllen
- [ ] **Liste externer Assets/Tutorials/fremder Code** mit Lizenzen (oder klarer Verweis auf die technische Doku)
- [ ] **Selbstständigkeitserklärung** mit Unterschrift

## 9 · Quellen & Abbildungen (Sa 7.11.)

- [ ] Wikipedia/Fandom auf ≤ 10 % senken: Genre-Definition durch Fachquelle; Spieldaten über Game-Einträge statt Wikipedia; NG-Wikipedia-Eintrag betrifft das 2004er-Spiel
- [ ] **Ludografie:** alle genannten Spiele als Game-Einträge (Zitierregeln 6.5)
- [ ] **Seitenzahlen** (Totten, Rogers, Swink, Drachen) und **Zeitstempel** (GDC-Talks); `[s.5-s.7]` → `[5--7]`
- [ ] GDC: Sprecher statt „Game Developers Conference“, Jahre prüfen (Ten Principles = Dan Taylor, nicht 2010)
- [ ] Lindgren als `@thesis`; Verlagsorte Totten/Rogers; `Sources.bib` vs. `sources.bib` angleichen
- [ ] Abbildungsverzeichnis mit voller Quelle (`\caption[Langform]{…}`), eigene Bilder als „Eigene Abbildung“
- [ ] `\listoftables` ergänzen

## 10 · Anhang & Formales (Sa 7.11.)

- [ ] Testpersonen **anonymisieren** (TP1–TP5, auch Namen in den Antworten)
- [ ] Transkripte einheitlich (wörtlich oder geglättet) und in der Einleitung angeben
- [ ] TP4: genaue Interviewfragen ergänzen; TP5: I2 löschen bzw. „entfällt“; TP5 B3/B8 rote Notizen
- [ ] Zuordnung der Beobachtungsnotizen TP4/TP5 prüfen
- [ ] Titelblatt: „Zweitbetreuer“ → **Zweitbewerter**, „Kantonschule“ → Kantonsschule, `\today` → **10. November 2026**, „Maturitätsarbeit, Kantonsschule Baden“
- [ ] Inhaltsverzeichnis: Anhang mit kleinerer Tiefe

## 11 · Rest ausserhalb des Berichts (So 8.11.)

- [ ] README aktualisieren
- [ ] **Arbeitsjournale fertigstellen und prüfen** (Zeitaufwand konsequent, KI-Nachweise passen zur Deklaration, Reflexionen substanziell)
- [ ] Game exportieren und testen (Build läuft, Tod/Neustart, mind. 2 Gegnertypen spielbar)

## 12 · Qualitätsdurchgang für die 6 (Mo 9.11. Vormittag)

- [ ] `grep -n textcolor Main.tex Source/*.tex` → muss leer sein
- [ ] Ganzes PDF einmal am Stück lesen: roter Faden, Begriffe (Designvorschlag V1–V8, Soldier), Verweise, Widersprüche
- [ ] **Vertrag C abhaken:** ≥ 2 Referenzspiele mit Framework ✓ · Framework mit Quellen · ≥ 2 Gegnertypen belegt · Bericht-Code-Verknüpfung · Playtest ca. 5 TP · Fragebogen passt zur Erkenntnisfrage · Verbesserungen abgeleitet · Schlussfolgerung beantwortet die Frage · Quellen, Assets, KI und Eigenleistung deklariert
- [ ] Zwischenbewertung abhaken: Aussagen abgesichert, Abb. 2 (Architektur) überarbeitet (technische Doku), Wikipedia trägt keine Kernaussagen
- [ ] Sprachkorrektur (wenn mit KI: deklarieren); idealerweise liest eine Drittperson gegen
- [ ] LaTeX-Warnungen prüfen (Overfull, undefined)

## 13 · Abgabe (Mo 9.11. Nachmittag → Di 10.11.)

- [ ] Finales PDF exportieren
- [ ] **2 Exemplare drucken und binden** (Ringbindung; Copyshop vorher wegen Zeit anfragen)
- [ ] PDF für die Mediothek, Arbeitsjournal für den Erstbetreuer
- [ ] **Abgabe Di 10.11.**

## Danach (bis 24.11.)

- [ ] 2 A3-Plakate (Datum für den Aushang prüfen)
- [ ] Schlusspräsentation 15–20 min (Rückmeldung: nicht länger werden) + Vorbereitung Fachgespräch
