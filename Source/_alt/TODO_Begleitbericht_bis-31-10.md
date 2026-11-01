# TODO – Begleitbericht Project-Polearm (Entwicklungs- & Forschungsteil)

Stand: 28.10.2026 · Abgabe: **Di, 10.11.2026** (13 Tage) · Schlusspräsentation 24.–26.11.2026

Grundlage: Vertrag, Rückmeldung Zwischenabgabe, Merkblatt Schriftlicher Kommentar, Checkliste wissenschaftliche Texte, Zitierregeln 2025, Merkblatt KI, KI-Raster, aktueller Stand von `Main.tex` + `Source/*.tex` + kompiliertes `Main.pdf` (65 S.).
Die technische Dokumentation ist hier bewusst ausgeklammert. Sie taucht nur dort auf, wo der Begleitbericht auf sie verweisen muss.

> **Update 28.10.:** Die alten Kapitel 5 (Designvorschläge) und 6 (Entwicklung) sind zusammengelegt zu **Kap. 5 „Design und Umsetzung des Kampfabschnitts“** (`Source/5Umsetzung.tex`). Alle folgenden Kapitel rücken eine Nummer nach vorne: Evaluation = 6, Schlussfolgerungen = 7, Reflexion = 8, Verzeichnisse = 9. Die Nummern unten sind bereits angepasst. Die alten Dateien liegen in `Source/_alt/`, ein Backup der geänderten Dateien in `Source/_alt/backup-2026-10-28/`.

**Reihenfolge-Logik:** Zuerst kommt, was von anderen Personen oder Daten abhängt (Playtests, Absprachen). Danach folgen die leeren Kernkapitel (5 → 6 → 7). Anschliessend wird überarbeitet, dann kommen Transparenz und Formales, und ganz am Schluss Einleitung und Abstract. Die beiden schreibt man am besten, wenn der Rest steht.

---

## 0. Sofort klären / blockierende Punkte

- [ ] **Playtest-Daten vervollständigen.** Vertraglich verlangt sind „ca. fünf Testpersonen“. Aktuell sind die Daten so unvollständig:
  - TP1 (Cyrill): nur Pre-Questionnaire. Post-Questionnaire, Beobachtungsraster und Interview fehlen (`10Verzeichnis.tex` Z. 30–104 enthält nur die Vorlage).
  - TP4 (Max): Post-Questionnaire nur als nackte Zahlen ohne Fragetext, **Beobachtungsraster leer**, Interview unstrukturiert.
  - TP5: komplett leer.
  - → Fehlende Daten aus den Aufnahmen nachtragen bzw. TP5 so schnell wie möglich durchführen. Falls das nicht klappt: In Kap. 6 transparent mit n = 4 arbeiten und das als Limitation nennen.
- [ ] **Erkenntnisfrage und Titel mit dem Vertrag abgleichen** (oder die Abweichung mit Herrn Schneider absprechen):
  - Vertrag: *„Wie können Gegnerverhalten und Gegnerplatzierung … so umgesetzt werden, dass ein Kampfabschnitt von Testspieler:innen als flüssig und herausfordernd erlebt wird?“*
  - Bericht (Kap. 1.2): *„Wie müssen … konzipiert sein, damit … nachvollziehbarer Spielfluss, angemessene Schwierigkeit und befriedigendes Spielgefühl entsteht?“*
  - Titel/Untertitel weichen ebenfalls ab (Vertrag: „Programmierung, Architektur und Evaluation…“, Titelblatt: „Konzeption, Umsetzung und Evaluation…“).
  - Definitiver Titel: max. 50 Zeichen, Untertitel max. 150 Zeichen inkl. Projektform. Beides **im schulNetz erfassen** (war „nach den Herbstferien“ fällig).
- [ ] **Zitierstil absprechen.** Ihr nutzt `biblatex authortitle-ibid`. Die Kanti verlangt standardmässig ihre eigene Fussnotenvariante (`Totten: Approach (2014), S. 45.`). Ein anderer Stil ist erlaubt, **muss aber vorab mit dem Betreuer abgesprochen** und einheitlich angewendet werden.
- [ ] **Umfang kurz ansprechen.** Das Merkblatt nennt „in der Regel 5–15 Seiten“. Der Hauptteil hat jetzt schon ~40 Seiten, dazu kommt die technische Doku. Mit Herrn Schneider bestätigen, dass das so ok ist.

---

## 1. Kapitel 5 „Design und Umsetzung des Kampfabschnitts“ – grösste Lücke (Vertrag: Level- und Gegnerdesign)

Struktur steht (5.1 Übersicht + Tabelle V1–V8, 5.2 Gegner mit 5.2.1 Gegnertypen + V1–V4, 5.3 Level mit 5.3.1 Überblick + V5–V8). Jedes V-Unterkapitel hat „Vorschlag und Herleitung“ (fertig) sowie „Umsetzung im Prototyp“ und „Überprüfbarkeit“ (rote Platzhalter).

- [x] Kopierte Designziele entfernt, Kap. 5 und 6 zusammengelegt.
- [x] Begriff vereinheitlicht: überall „Designvorschlag V1–V8“ (passt zu den Klammern im Fragebogen/Raster).
- [x] Übersichtstabelle V1 bis V8 mit Herleitung und Playtest-Items (5.1). Bitte trotzdem kontrollieren.
- [ ] **Kapiteleinleitung und 5.1-Einleitung gegenlesen.** Diese Sätze wurden beim Zusammenlegen neu formuliert und sollten in euren eigenen Worten stehen; in der KI-Deklaration erwähnen.
- [x] **5.2.1 Gegnertypen** Text + Tabellen (Gegnertypen, Combos) stehen (31.10.).
- [ ] 5.2.1: Bild aller Gegner einfügen (Platzhalter Abb.), rote Notizen abarbeiten (Schreibweise Soldier/Solider, Reichweite, Unterbrechbarkeit prüfen).
- [x] **V1–V4 „Umsetzung“** als Rohtext vorhanden, strukturiert und sprachlich korrigiert (31.10.).
- [ ] V1–V4: rote Notizen abarbeiten – v. a. Faktoren „doppelt bis viermal“ (V1), Widerspruch „Gegner können nicht springen“ vs. Sprungangriff Raum 4, technische Vergabe Angriffsmodus (V2), Rollensystem (V3), Satz „zum anderen …“ vervollständigen + Fernkämpfer-Ankündigung (V4). „Überprüfbarkeit“ überall noch offen.
- [x] **5.3.1** Wellensystem erklärt (aus V2 hierher verschoben), Raumtabelle Räume 1–4 (31.10.).
- [ ] 5.3.1: Räume 5–12 ergänzen, Widerspruch „10–30 Gegner pro Welle“ vs. Raum 1/2, „Raum 7.5“ klären, Diagramm, Greybox-Screenshot, Vorgehen, Spannungskurve.
- [x] **V4–V8 „Umsetzung“** Rohtext strukturiert (31.10., 2. Durchgang); Raumtabelle hat jetzt Raumtyp-Spalte und Zeilen 1–12.
- [ ] V4–V8: rote Notizen abarbeiten – v. a. V4-Argument „so viele greifen gleichzeitig an“ (Widerspruch zu V2), V6 Abweichung von Totten kennzeichnen, V7 kaum Erholung zwischen Wellen begründen, V8 „Heavy Archer“→„Heavy Soldier“ prüfen. „Überprüfbarkeit“ überall noch offen.
- [ ] **Recherche entschlacken (Lehrer: Bloat entfernen):** Kap. 3/4 durchgehen, Punkte ohne Bezug zu V1–V8 kürzen oder streichen; Auswahlkriterium (wirkt auf Gegnerverhalten/-platzierung, im linearen Abschnitt umsetzbar, im Playtest prüfbar) in Kap. 2 nennen; Zeitmangel in die Limitationen.
- [ ] Bei jedem Vorschlag **Bericht-Code-Verknüpfung**: Datei/Szene/Klasse bzw. Kapitel der technischen Doku nennen (Forderung der Zwischenbewertung).
- [ ] Prozess begründen: „Warum X? Welche Alternativen? Weshalb verworfen?“
- [ ] Am Ende alle roten Platzhalter in `5Umsetzung.tex` entfernen.

---

## 2. Kapitel 6 „Evaluation“ – Ergebnisse fehlen komplett

- [x] **6.1 „Ziel des Playtests“**: Begriffe und Verweis korrigiert (jetzt „acht Designvorschläge (V1–V8) … in Kapitel 5 umgesetzt“). Ggf. noch sprachlich glätten.
- [ ] **6.2 „Durchführung“ komplett neu schreiben.** Aktuell ist der Text umgangssprachlich und voller Tippfehler („Unser spiel eignet sich nicht für dien üblichen think aloud prozess…“, „instruirt“, „Wie gehabt beim Pre.“). Rein sollen: Datum/Ort, Setting, Hardware/Eingabe (Maus+Tastatur / Controller?), Build-Version, Dauer, Instruktionen an die TP (auch dass mündlich erklärt wurde, weil es kein Tutorial gibt), wer beobachtet/protokolliert hat, Aufnahme und Einverständnis.
- [ ] **Testpersonen charakterisieren** (gehört eigentlich in 2.6.1, dort steht noch „Teilnehmer, Auswertungsmethode kommt noch.“): anonymisierte Tabelle TP1–TP5 mit Spielzeit/Woche, Genres, Selbsteinschätzung (P5), Spielstil (P6). Rekrutierung (Mitschüler/Freunde) offenlegen.
- [ ] **Auswertungsmethode festlegen und beschreiben:** Likert → Median/Mittelwert + Spannweite pro Item. Qualitative Daten (B-Raster, Interview, offene Fragen) → nach Designziel codieren. Triangulation Q ↔ B ↔ I pro Vorschlag.
- [ ] **6.3.1 Quantitative Ergebnisse:** Tabelle Q1–Q11 × TP und ein Diagramm (Abbildung ins Verzeichnis aufnehmen). Uneinheitliche Antworten bereinigen bzw. erklären (z. B. TP3 Q10: „1 für raum zu raum und 4 für locked in“).
- [ ] **6.3.2 Qualitative Beobachtungen:** die wichtigsten Muster pro Vorschlag, mit Verweis auf die Anhang-Stellen (TP/Item).
- [ ] **6.4.1 Interpretation:** pro Vorschlag (V1–V8) festhalten, ob es bestätigt, teilweise bestätigt oder nicht bestätigt wurde, und mit Belegen begründen. Auch die Items mit grosser Streuung und Widersprüche zwischen Fragebogen und Beobachtung diskutieren. Die Interpretation müsst ihr selbst formulieren (KI-Regel: Schlussfolgerungen nicht von KI).
- [ ] **6.4.2 Verbesserungsvorschläge:** konkret und aus den Daten abgeleitet (Vertrag: „konkrete Verbesserungen …, die nicht mehr umgesetzt werden müssen“). Jeder Vorschlag braucht eine Datenstelle als Beleg.
- [ ] Hinweis „Die einzelnen Antworten … sind im Anhang“ → mit korrektem Verweis auf das Anhang-Kapitel.

---

## 3. Kapitel 7 „Schlussfolgerungen“ – leer

- [ ] **7.1 Erkenntnisfrage explizit beantworten**, gestützt auf Recherche + Analyse + Prototyp + Playtests (Vertrag C.5).
- [ ] **7.2 Wichtigste Erkenntnisse** (auch aus dem Arbeitsprozess, siehe Merkblatt „Ergebnisse“).
- [ ] **7.3 Limitationen:** kleine Stichprobe; TP aus dem Umfeld (Bias, z. B. kannten das Projekt schon); kein Tutorial; Referenzanalysen nur von aussen rekonstruiert; Leveldesign-Quellen sind nicht genrespezifisch und keine empirischen Studien (ihr schreibt das in 2.4 selbst).
- [ ] **7.4 Ausblick / offene Fragen.**
- [ ] Abschnitt mit dem Rückbezug zur Einleitung beginnen (Checkliste: „in der Einleitung beschriebene Fragen/Thesen werden aufgegriffen“).

---

## 4. Kapitel 3 „Analyse von Referenzspielen“ – überarbeiten

- [ ] **3.3.3 „Erkenntnisse für Project-Polearm“ neu schreiben** (rote Notiz Z. 341). Abgleichen mit dem, was tatsächlich umgesetzt wurde, und mit den Designvorschlägen in Kap. 5. (Verweis am Schluss zeigt jetzt auf Abschnitt 5.1.)
- [ ] **Aussagen-Absicherung (Hauptkritik der Zwischenbewertung).** Der Pauschalhinweis in der Kapiteleinleitung ist gut, reicht aber nicht überall:
  - Formulierungen wie „Dies ist befriedigend, weil…“ (sehr häufig in A1–D5) konsequent als eigene Interpretation formulieren („wir empfanden dies als befriedigend, weil…“).
  - Technische Aussagen prüfen und abschwächen oder belegen:
    - M5 „liegt an einer speziellen Input-Buffer-Implementierung, die in Ninja Gaiden vorhanden ist, in anderen … nicht in dieser Form existiert“. Das ist eine starke Sachbehauptung, belegt nur mit einer Fandom-Wiki-Seite.
    - M4 „in der Fachsprache oft als Super-Armor bezeichnet“ → Quelle oder „im Sprachgebrauch der Community“.
    - D1 „Grenzwert von maximal vier Gegnern“: Wie viele Durchläufe/Missionen wurden beobachtet? Zahl nennen.
  - Optional (von den Betreuern angeregt): die Kategorien *beobachtet / Quelle / Interpretation / Hypothese / im Playtest geprüft* sichtbar machen, z. B. mit einer kurzen Legende oder Marker.
- [ ] **Widerspruch Raumverengung beheben:** M3 (Ninja Gaiden) ist hypothetisch formuliert („Sollte das Spiel jedoch die Fläche verkleinern…“). Kap. 4.3 behauptet dagegen „konnten wir beobachten, dass die Räume im Verlauf gezielt schmaler wurden“, und V6 baut darauf auf. → In M3 konkret benennen, wo (welche Mission) das beobachtet wurde, oder 4.3/V6 abschwächen.
- [ ] **Methodik der Analyse ergänzen** (in 2.x oder am Anfang von Kap. 3): Plattform/Version, welche Ninja Missions bzw. welcher Abschnitt, Spielzeit, wer gespielt hat, ob aufgezeichnet wurde. So wird die Analyse überprüfbar.
- [ ] Ninja Gaiden einheitlich benennen: Abstract sagt „Ninja Gaiden Sigma“, sonst „Sigma Plus“.

---

## 5. Kapitel 2 „Theoretischer Hintergrund & Methodik“ – Lücken schliessen

- [ ] **Einleitungssatz reparieren:** „Des weiteren ist unser Vorgehen und es dem Leser erleichtern, unsere Arbeit zu verstehen.“
- [ ] **Analyseframework begründen (Vertragspunkt A.3.1 / C.1!).** Gefordert sind Kriterien zu *Gegnerverhalten, manueller und algorithmischer Gegnerplatzierung, Spielfluss, Schwierigkeit, Feedback*, jeweils **mit Quellen begründet**. Bisher ist nur MDA als Ganzes belegt, die 15 Fragen selbst nicht.
  - → Tabelle: Frage (A1–M5) → abgedecktes Kriterium → Begründung + Quelle (z. B. Swink für Feedback/Game Feel, Totten/Rogers für Platzierung/Raum, GDC-Talks für Pacing, Hunicke für die MDA-Ebenen).
- [ ] **2.6.1 Testpersonen** ausfüllen (Platzhalter „kommt noch“): Auswahlkriterien, Anzahl, Rekrutierung.
- [ ] **2.6.2 „Fragebogen“** ist eine leere Überschrift → füllen oder löschen.
- [ ] **Fragebogen-Konsistenz:** Bei TP5 lautet P4 „Wie vertraut bist du mit dem Hack-and-Slash-Genre? (1–5)“, im Methodikteil „Was stellst du dir unter einem Hack and Slash vor?“. Eine Version festlegen. Falls TPs unterschiedliche Versionen bekommen haben, das offenlegen.
- [ ] **Begründen, warum der Fragebogen zur Erkenntnisfrage und zum Analyseframework passt** (Vertrag C.4). Die (V1)–(V8)-Zuordnung ist schon da, ein Satz zur Herleitung aus dem MDA-Fragebogen fehlt noch.
- [ ] Zitat-Formalität: `\autocite{drachen2018gamesuserresearch}.` → doppelter Punkt nach der Fussnote („…Nacke.\autocite{…}.“).

---

## 6. Kapitel 4 – kleinere Überarbeitungen

- [ ] **4.1:** Rote Notiz ersetzen durch einen konkreten Halbsatz mit Verweis auf die Basisklasse (Entity o. ä.), Abschnitt 5.2.1 und die technische Doku (Verweis in der Notiz zeigt jetzt auf 5.2.1).
- [ ] **4.3 Lynch:** kennzeichnen, dass ihr Lynch über Totten zitiert (Sekundärzitat), z. B. „Lynch, zit. nach Totten“.
- [x] **Begriffe vereinheitlicht:** überall „Designvorschlag V1–V8“ (Kap. 3.3.3, Kap. 5, Kap. 6.1). „Designprinzipien“ in Kap. 4 meint die Prinzipien aus der Literatur und bleibt bewusst so.
- [x] Brücke Kap. 5 → Kap. 6 steht in der Kapiteleinleitung von Kap. 5.

---

## 7. Kapitel 8 „Reflexion“ – leer

- [ ] **8.1 Arbeitsprozess:** Planung vs. tatsächlicher Verlauf (Vertragsmeilensteine vs. Realität, z. B. Gegner-Meilenstein „Anfang September“), Scope-Entscheidungen, was ihr anders machen würdet.
- [ ] **Reflexion über die KI-Verwendung** (Vertrag, Arbeitsprozess a): wofür, was hat geholfen, wo lagen Grenzen, wie habt ihr überprüft.
- [ ] **8.2 Gruppenarbeit + Aufgabenteilung/Eigenleistung zentral aufführen** (ausdrückliche Forderung der Rückmeldung: „Die Eigenleistung und eine grobe Aufgabenteilung sollten irgendwo zentral aufgeführt werden“). Vorschlag: Tabelle *Bereich → Rodin / Zhile / gemeinsam*, für Bericht **und** Prototyp.
- [ ] **8.3 Persönliche Erkenntnisse**, je Person.

---

## 8. Einleitung (Kap. 1) – erst nach Kap. 5–7 fertigstellen

- [ ] **1.3 „Zielsetzung und Produktdefinition“ schreiben** (rote Platzhalter „stuff den wir gemacht haben“). Inhalt: Produktbestandteile gemäss Vertrag A.4 (Prototyp, Kampfabschnitt, ≥2 Gegnertypen, Mechaniken inkl. Tod/Neustart, Architektur-Doku, Analyse, Playtests). Satz „Wodurch unsere Erkenntnisfrage geklärt werden soll.“ ist kein vollständiger Satz.
- [ ] **Abgrenzung/Eingrenzung begründen:** Was steht in diesem Bericht, was in der technischen Dokumentation? Mit eindeutigem Verweis (Titel des anderen Dokuments).
- [ ] **Relevanz/Zielgruppe** aus dem Vertrag (A.5, Stylish-Action-Fans) aufnehmen.
- [ ] **Aufbau der Arbeit** erklären und begründen (fehlt, Pflicht laut Merkblatt und Checkliste).
- [ ] Zentrale Begriffe: kurz auf die Definitionen in Kap. 2 verweisen.
- [ ] Spiele, die genannt werden (God of War, Ninja Gaiden …), als Quelle (Game) belegen.

---

## 9. Abstract – ganz zum Schluss

- [ ] Platzhalter **„[Kernergebnis]“** ersetzen.
- [ ] Länge **300 ± 50 Wörter** (aktuell ~140), **genau drei Absätze:** 1. Fragestellung/Zweck, 2. Methode/Vorgehen, 3. Ergebnisse & Schlussfolgerungen. Sachlich, ohne Wertung.
- [ ] Überschrift „Zusammenfassung“ → **„Abstract“** (`\renewcommand{\abstractname}{Abstract}` nach `babel`).
- [ ] Muss auf der ersten Seite nach dem Titelblatt stehen (ist so).
- [ ] Erkenntnisfrage im Abstract wortgleich zur finalen Version.

---

## 10. Quellen & Zitation

- [ ] **Wikipedia/Fandom-Anteil senken.** Checkliste: max. 10 % Wikipedia. Aktuell sind es 6 von 17 gedruckten Einträgen (~35 %): 5× Wikipedia, 1× Fandom. Die Rückmeldung sagt: Wikipedia/Fandom sollen keine zentralen Aussagen tragen.
  - Genre-Definition (`wikipedia_hackandslash`) durch eine Fachquelle ersetzen bzw. ergänzen.
  - Spiel-Metadaten (Entwickler, Jahr, Plattform) nicht über Wikipedia, sondern das **Spiel selbst als Quelle** angeben (Zitierregeln 6.5 „Game“: *Titel. Produktionsfirma. (Plattform/Version) Jahr.*).
  - `wikipedia_ninjagaiden_2026` beschreibt das **2004er** Spiel, belegt aber Fakten zu *Sigma Plus (2012, Vita)* → passt nicht.
  - `dmcwiki_inputbuffering` (Fandom) trägt eine technische Kernaussage → bessere Quelle oder Aussage abschwächen.
- [ ] **Ludografie ergänzen:** Ninja Gaiden Sigma Plus und NieR: Automata als Game-Einträge, ausserdem alle namentlich genannten Spiele (God of War, DMC 3, Bayonetta, Dead Space 2, Burnout, Half-Life 2, Super Mario Bros., Zelda, Counter-Strike, Elden Ring …). Hinweis: `koeitechmo_ninjagaiden_2012` steht in der .bib, wird aber nie zitiert und erscheint darum nicht im Verzeichnis.
- [ ] **Seitenangaben bei Büchern** (Totten, Rogers, Swink, Drachen) bei *jeder* Fussnote ergänzen. Aktuell gibt es fast keine. Bei Vorträgen/Videos **Zeitstempel** (mm:ss) angeben.
- [ ] Falsche Seitenangabe: `\autocite[s.5-s.7]{…}` / `[s.1-s.6]` → `\autocite[5--7]{…}`, ergibt „S. 5–7“ (Abstand nach „S.“ laut Checkliste).
- [ ] **GDC-Einträge:** Als Autor:in die **Sprecher:innen** angeben statt „Game Developers Conference“, und **Jahre prüfen**. „Ten Principles for Good Level Design“ ist von Dan Taylor, das Jahr 2010 scheint nicht zu stimmen. „Moving Mountains“ ist im GDC Vault als Level-Design-Summit-Talk gelistet, auch da das Jahr kontrollieren.
- [ ] `lindgren2025striking` ist als `@article` mit „journal = Bachelor Thesis“ erfasst → `@thesis` mit `type = {Bachelorarbeit}`, `institution = {Uppsala universitet}`.
- [ ] `totten2014architectural`: Verlagsort fehlt. `rogers2014levelup`: Ort ergänzen.
- [ ] Wikipedia-Einträge ohne Autor sollen laut Kanti nach Titel einsortiert werden, nicht unter „Wikipedia contributors“ (falls ihr beim Kanti-Stil bleibt).
- [ ] `Main.tex`: `\addbibresource{Source/Sources.bib}`, die Datei heisst aber `sources.bib`. Auf dem Mac funktioniert das, unter Linux/Overleaf bricht es. Schreibweise angleichen.

---

## 11. Abbildungen & Tabellen

- [ ] **Abbildungsverzeichnis mit vollständigen Quellen.** Aktuell erscheint dort nur „Quelle: Totten“. Mit `\caption[Verzeichniseintrag mit voller Quelle]{Bildunterschrift}` z. B. „Abb. 1: Proximity-Diagramm … Quelle: Totten: Approach (2014), S. xx.“ Bei Nachzeichnungen „Nach Totten …“ bzw. „In Anlehnung an …“.
- [ ] Eigene Abbildungen als **„Eigene Abbildung“** kennzeichnen (Level-Diagramm, Screenshots, Ergebnisdiagramm).
- [ ] Bisher hat der Bericht nur 2 Abbildungen (+ 1 Tabelle) → Kap. 5 und 6 brauchen eigene Visualisierungen (siehe oben).
- [ ] **Tabellenverzeichnis** anlegen (`\listoftables`). Es gibt jetzt die Übersichtstabelle der Designvorschläge (Tab. 1), weitere folgen.
- [ ] Reihenfolge laut Zitierregeln: Quellenverzeichnis → Abbildungsverzeichnis → (Tabellenverzeichnis) → KI-Teil.

---

## 12. Transparenz: KI, Eigenleistung, Assets, Erklärung (bewertungskritisch!)

- [ ] **KI-Deklaration komplett überarbeiten.** Der aktuelle Text ist pauschal und erfüllt das Merkblatt nicht. Laut Vertrag gilt eine unvollständige Deklaration als „aktive Täuschung“.
  - Pro Einsatz: **System + Version, wörtlicher Prompt, Datum, Art der Übernahme** (Zitierregeln 3.8), platziert nach der betroffenen Überschrift/Textstelle und gesammelt im Verzeichnis.
  - **KI-Raster** („Verwendung von KI“) ausfüllen, mit Seitenverweisen ins Logbuch. Die Teile, die in die Arbeit einfliessen, **nach dem Abbildungsverzeichnis ausformulieren**.
  - **Absolute Aussagen auf Richtigkeit prüfen.** „Sämtliche zur Bewertung eingereichten Codeabschnitte wurden von den Autoren selbst entwickelt“ und „KI-Systeme wurden nicht zur Erstellung inhaltlicher Bestandteile … verwendet“ müssen exakt stimmen. Laut Rückmeldung nennt das README „selbstgeschriebenen bzw. **generierten** Code“, und es gibt ein Claude-generiertes Tool-Skript. Falls KI auch bei Struktur/Planung des Berichts im Spiel war (z. B. die „Wissenslandkarte“ in den Platzhaltern), gehört das ebenfalls rein.
  - Auch **diese Durchsicht** deklarieren (Bereich „Überprüfung und Kontrolle“): Claude, Prompt wörtlich, 28.10.2026, „Mängelliste als Orientierung für die Überarbeitung verwendet“.
- [ ] **Eigenleistung/Aufgabenteilung** zentral (siehe Kap. 8.2), mit Verweis auf Logbuch und Code-Header.
- [ ] **Liste externer Assets/Tutorials/fremder Code** (Vertrag A.4 verlangt sie im schriftlichen Kommentar): Poly Haven, Rigify/Animationen, Plugins, Shader-Vorlagen, Tutorials, Sounds usw., je mit Lizenz (CC-Angaben laut Zitierregeln 1.6/4). Falls die Liste nur in der technischen Doku steht, hier zumindest klar darauf verweisen.
- [ ] **Selbstständigkeitserklärung** mit Unterschriften beider (Vertrag: „Bestätigung verlangt, dass die Arbeit selbst entwickelt und verfasst wurde“).

---

## 13. Anhang-Struktur (`10Verzeichnis.tex`)

- [ ] **TP1 (Cyrill) fertig ausfüllen:** Post-Questionnaire, Beobachtungsraster, Interview (rote Platzhalter stehen).
- [ ] Playtest-Protokolle aus „Verzeichnisse“ herauslösen und als eigenes **„Anhang“-Kapitel** führen. Momentan stehen „Interview Antworten“ (leer) und „Testperson 1…5“ auf derselben Ebene. Gliederung z. B.: *Anhang A Playtest-Protokolle → A.1 TP1 → Pre / Post / Beobachtung / Interview*.
- [ ] **Testpersonen anonymisieren** (TP1–TP5 statt Vornamen). Auch Namen Dritter in Antworten ersetzen (z. B. „Lörach“, „herrr röörich“ → „[Name]“).
- [x] **Alle TP im selben Format** (31.10.): nur noch Nummern + Antworten, Interview mit tatsächlich gestellten Fragen; Einleitung „Playtest-Protokolle“ verweist auf Kap. 2. TP4/TP5-Notizen den Kriterien B1–B14 zugeordnet → Zuordnung prüfen.
- [ ] Transkripte: wörtlich lassen, aber klar markieren, ob wörtlich oder sinngemäss, und offensichtliche Scherzantworten (TP4 I8 „Bestechungsgelder…“) einordnen bzw. in der Auswertung nicht werten. Aktuell: TP2/TP3 geglättet, TP4/TP5 wörtlich → vereinheitlichen. TP4: genaue Interviewfragen ergänzen (rot markiert). TP5: I2 nicht gestellt?
- [x] Wiederholte Methodik-Einleitungstexte pro TP entfernt (31.10.).
- [ ] Inhaltsverzeichnis: Anhang mit geringerer Tiefe anzeigen (`\addtocontents{toc}{\setcounter{tocdepth}{1}}` vor dem Anhang). Aktuell nimmt der Anhang eine ganze TOC-Seite ein.

---

## 14. Formales & Titelblatt

- [ ] **„Zweitbetreuer“ → „Zweitbewerter“** (Checkliste: „es gibt keine Zweitbetreuer, nur Zweitbewerter“).
- [ ] Tippfehler „Kantonschule“ → „Kantonsschule“ (Zweitbewerter-Zeile).
- [ ] `\today` durch das feste **Abgabedatum 10. November 2026** ersetzen.
- [ ] „Maturitätsarbeit, Kantonsschule Baden“ explizit aufs Titelblatt. Abteilung G23g ist drauf.
- [ ] Titel/Untertitel nach Punkt 0 finalisieren (Untertitel: Projektform nennen).
- [ ] Alle `\textcolor{red}{…}` entfernen. Offene Stellen aktuell: `Main.tex` (Abstract), `1Einleitung.tex` Z. 32/36, `3KampfAnalyse.tex` Z. 341, `4Leveldesign.tex` Z. 15, `5Umsetzung.tex` (alle Platzhalter-Bullets). Am Ende `grep -n textcolor Source/*.tex Main.tex` → muss leer sein.
- [ ] Checkliste: 1.5 Zeilenabstand ✓, Blocksatz ✓, Seitenzahlen ✓. Einheitliche Schrift prüfen. Fussnoten enden mit Punkt.
- [ ] Kapitel ohne Mini-Abschnitte (≥ 2 Sätze pro Absatz). Jedes Kapitel mit kurzem Überleitungs-/Rückbezugssatz zur Erkenntnisfrage.
- [ ] **Sprachkorrektur des gesamten Texts** (Gross-/Kleinschreibung v. a. in Kap. 6, Kommas, „des Weiteren“). KI-Sprachkorrektur ist erlaubt, muss aber deklariert werden.
- [ ] LaTeX-Warnungen beheben: `enumitem: Negative labelwidth` (2×), `!h float specifier changed` (2×).
- [ ] Schlusskontrolle aller Querverweise (`\ref`) nach dem Umbau.

---

## 15. Ausserhalb des Dokuments, aber für die Abgabe nötig

- [ ] Abgabe: **2 gedruckte, gebundene Exemplare** (z. B. Ringbindung) für Erstbetreuer + Zweitbewerter, **PDF für die Mediothek**, **Arbeitsjournal** für den Erstbetreuer.
- [ ] Arbeitsjournal: **Zeitaufwand konsequent** für beide ausweisen, Reflexionen substanziell (Kritik der Zwischenbewertung). KI-Nachweise gehören laut Vertrag auch ins Logbuch.
- [ ] Zwei **A3-Plakate** für die Ausstellung (Datum für euren Jahrgang prüfen, in der Regel ca. 1 Woche vor den Präsentationen).
- [ ] Schlusspräsentation 10–15 (max. 20) Min. Rückmeldung: „Der Vortrag darf nicht länger werden.“

---

## Vorschlag Zeitplan (13 Tage)

| Datum | Fokus |
|---|---|
| Mi 28.10 – Do 29.10 | Punkt 0 (Absprachen, TP5 + fehlende TP-Daten), Anhang vereinheitlichen und anonymisieren |
| Fr 30.10 – So 01.11 | Kap. 5 Design und Umsetzung inkl. Abbildungen |
| Mo 02.11 – Di 03.11 | Kap. 6 Evaluation (Tabellen, Diagramm, Interpretation, Verbesserungen) |
| Mi 04.11 | Kap. 7 Schlussfolgerung, 3.3.3 neu, Kap. 2 Framework-Begründung |
| Do 05.11 | Kap. 8 Reflexion, Eigenleistung, KI-Deklaration + Raster, Asset-Liste, Erklärung |
| Fr 06.11 | Einleitung, Abstract, Quellen/Ludografie, Seitenzahlen |
| Sa 07.11 – So 08.11 | Formales, Abbildungsverzeichnis, Sprachkorrektur, Gegenlesen (ideal: eine Drittperson) |
| Mo 09.11 | Druck + Bindung, PDF, Journal finalisieren |
| **Di 10.11** | **Abgabe** |
