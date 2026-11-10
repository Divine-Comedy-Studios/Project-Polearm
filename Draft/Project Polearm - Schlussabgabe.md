![[ProjectPolearm.png]]

---
Dieses Dokument soll Ihnen als Orientierungshilfe für die Inhalte unserer Abgabe dienen. Es erklärt, wie Sie das Spiel starten und steuern, und zeigt Ihnen, welche Abschnitte unserer Berichte unserer Meinung nach das Wichtigste enthalten.

## 1. Inhalt der ZIP-Datei
---
- Dieses README
- `Begleitberichte/`
    - Der Begleitbericht zu Recherche, Design und Evaluation
    - Die _Project Polearm Technical Documentation_ zur technischen Umsetzung (auf Englisch)
- `Exports/`: Das spielbare Spiel für Windows und macOS
- `Arbeitsjournale/`: Die Arbeitsjournale von Rodin Arslan und Zhile Zhu

## 2. Ausführen des Spiels
---
### Windows:
1. `Exports/Windows Version.zip` entpacken.
2. `Project Polearm.exe` starten.

Falls Windows eine Warnung anzeigt («Der Computer wurde durch Windows geschützt»), auf «Weitere Informationen» und danach auf «Trotzdem ausführen» klicken. Die Warnung erscheint, weil das Spiel nicht kommerziell signiert ist.

### macOS:
1. `Exports/Mac Version.zip` entpacken.
2. `Project Polearm.app` starten.

Da das Spiel nicht von Apple signiert ist, blockiert macOS den Start möglicherweise. In diesem Fall einmal `Fix Mac App.command` ausführen. Das Skript signiert das Spiel lokal, danach startet es normal. Falls macOS auch das Skript blockiert, öffnen Sie _Systemeinstellungen → Datenschutz & Sicherheit_, scrollen ganz nach unten und klicken bei der Meldung zu `Fix Mac App.command` auf «Trotzdem öffnen». Danach lässt sich das Skript ausführen. Nachdem die Konformation kommt, dass es kompleted wurde können Sie das Terminal Fenster wieder schliessen und das Game erneut booten. Falls auch das nicht funktioniert, versuchen Sie die Windows-Version.

Nach dem Start erscheint das Hauptmenü. Mit «Play» beginnt der Kampfabschnitt.

## 3. Steuerung
---
Alle Belegungen lassen sich im Spiel unter _Options → Keyboard Mapping_ bzw. _Controller Mapping_ ändern. Wählen Sie dazu den gewünschten Eintrag an und drücken Sie die neue Taste. Solange das Spiel auf eine Eingabe wartet, ist der Eintrag farbig hervorgehoben.

|Aktion|Tastatur und Maus|Controller (Xbox-Belegung)|
|---|---|---|
|Bewegen|W, A, S, D|Linker Stick|
|Kamera|Maus|Rechter Stick|
|Springen|Leertaste|A|
|Leichter Angriff|Linke Maustaste|X|
|Schwerer Angriff|Rechte Maustaste|Y|
|Dash|Shift|RB|
|Sprinten|Shift gedrückt halten|RB gedrückt halten|
|Heilen|Q gedrückt halten|Steuerkreuz oben gedrückt halten|
|Pause|Esc|Start|
|Im Menü zurück|Esc|B|

Bei anderen Controllern (z.B. PlayStation) gelten die Tasten an derselben Position.

### 3.1. Moveset
---
**Bewegung**:
- **Laufen und Sprinten:** Auf dem Controller passt sich die Geschwindigkeit an, je nachdem wie weit der Stick geneigt ist. Halten Sie die Dash-Taste nach einem Dash gedrückt, geht die Spielfigur ins Sprinten über.
- **Sprung mit variabler Höhe:** Je länger Sie die Sprungtaste halten, desto höher springt die Spielfigur. Springen Sie aus dem Sprint, nimmt sie den Schwung mit.
- **Luftsprünge:** In der Luft kann die Spielfigur bis zu zweimal erneut springen.
- **Dash am Boden und in der Luft:** Ein kurzer, schneller Sprint in Bewegungsrichtung, um auszuweichen oder Distanz zu überbrücken.
- **Kante festhalten:** Springt die Spielfigur knapp an eine Kante, hält sie sich daran fest, solange Sie in Richtung Wand drücken. Von der Kante aus kann sie erneut springen, da die Luftsprünge dabei zurückgesetzt werden.

**Kampf**:
- **Combos:** Leichte und schwere Angriffe lassen sich zu verschiedenen Combos verbinden. Es gibt reine leichte, reine schwere und gemischte Boden-Combos sowie eine Luft-Combo. Probieren Sie ruhig verschiedene Abfolgen aus.
- **Energie und Heilen:** Jeder Treffer füllt die Energieleiste. Halten Sie die Heilen-Taste gedrückt, wandelt die Spielfigur Energie in Leben um. Während des Heilens steht sie still.
- **Tod und Neustart:** Stirbt die Spielfigur, erscheint der Todesbildschirm. Von dort aus können Sie neu starten oder ins Hauptmenü zurückkehren.

## 4. Highlights
---
Da unsere beiden Berichte zusammen sehr umfangreich sind, haben wir für Sie die Abschnitte zusammengestellt, die unsere Arbeit unserer Meinung nach am besten zeigen. Wenn Sie das Wichtigste sehen möchten, empfehlen wir Ihnen die folgenden Abschnitte:

### Begleitbericht:
- **1.2 Erkenntnisfrage:** Worauf die ganze Arbeit hinausläuft.
- **3.1 Analyse: Ninja Gaiden Sigma Plus:** Ein Beispiel dafür, wie wir ein Referenzspiel mit dem MDA-Framework analysiert haben. Die Erkenntnisse aus beiden Analysen fasst Abschnitt 3.3.3 zusammen.
- **4.7 Erkenntnisse für Project Polearm:** Was wir aus der Leveldesign-Recherche für unser eigenes Level mitgenommen haben.
- **5.1 Von der Recherche zu den Designvorschlägen:** Wie aus Referenzspielanalyse und Recherche unsere acht Designvorschläge V1 bis V8 entstanden sind. Die Tabelle dort ist die Brücke zwischen Theorie und Prototyp.
- **5.2.2 Kampfabschnitt und Wellensystem:** Karte und Aufbau der zwölf Encounter.
- **6.2.3 V3: Ein taktisches Dilemma durch Nah- und Fernkämpfer:** Ein typisches Beispiel für unsere Auswertung, vom Ziel über die Beobachtungen bis zur Interpretation. Alle Aussagen lassen sich in den Protokollen im Anhang nachprüfen.
- **7.1 Beantwortung der Erkenntnisfrage:** Unsere vorläufige Antwort, geordnet nach der Stärke der Tendenzen.
- **8.1 Reflexion des Arbeitsprozesses:** Wie das Projekt verlaufen ist und was wir beim nächsten Mal anders machen würden.

### Technical Documentation:
- **2.1 «_"Configure Everything, Code Nothing": Philosophies on Clean Code_ Die Grundidee hinter der ganzen Architektur. Abschnitt 2.3 zeigt an einem Beispiel, wie wir Designentscheidungen abgewogen haben.
- **3.3 Entities:** Wie Spieler und Gegner aufgebaut sind und warum sie alle auf derselben Grundlage stehen.
- **4.4 Enemy Role Assignment:** Wie die Gegner koordiniert werden. Das System ist direkt aus unserer Analyse von _Ninja Gaiden_ entstanden und verbindet die beiden Berichte.
- **5.1.2 Frame Data:** Wie das Verhalten jeder Aktion ohne Code konfiguriert wird.
- **6.2 Challenges During Development und 6.3 What We Would Do Differently:** Wo unsere Prinzipien an ihre Grenzen gestossen sind.