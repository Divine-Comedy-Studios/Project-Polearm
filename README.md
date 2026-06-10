# Project-Polearm: Zwischenabgabe

Dieses Dokument dient als Orientierungshilfe für die Inhalte der Abgabe und erläutert die aktuell implementierten Funktionen des Prototyps.


## Inhalt der ZIP-Datei

Die ZIP-Datei enthält folgende Bestandteile:

* Dieses README
* Den schriftlichen Begleitbericht
* Eine ausführbare Version des Spiels (`Spiel.exe`)
* Ausgewählte Quellcodedateien


Der Begleitbericht ist grundsätzlich eigenständig verständlich. Das vorliegende README dient insbesondere dazu, die Verbindung zwischen den im Begleitbericht beschriebenen Systemen und den beigelegten Quellcodedateien herzustellen.


## Ausführen des Prototyps

Starten Sie die Datei `Spiel.exe`.

Nach dem Start erscheint das Hauptmenü.

### Steuerung der Menüs

* ESC-Taste: Eine Menüebene zurück
* B-Taste (Xbox-Controller): Eine Menüebene zurück
* Entsprechende Zurück-Tasten anderer Controller werden ebenfalls unterstützt

Das Save-Menü besitzt derzeit noch keine Funktion und dient als Platzhalter. Einige Einstellungen wurden für diese Zwischenabgabe bewusst deaktiviert oder vereinfacht, um einen stabilen und reproduzierbaren Ablauf der Demo sicherzustellen.

Im Bereich „Controller Mapping“ bzw. „Keyboard Mapping“ können die aktuell verwendeten Eingabebelegungen eingesehen werden. Es können auch Button Remappings vorgenommen werden.


## Die Greybox-Testumgebung (GYM)

Nach dem Drücken von „Play“ gelangen Sie in unsere Greybox-Testumgebung, die wir intern als „GYM“ bezeichnen.

Das GYM dient als Entwicklungs- und Testbereich. Es ermöglicht uns, spielrelevante Werte wie Bewegungsparameter, Sprunghöhen oder Reichweiten direkt im Spiel zu überprüfen und bei der Entwicklung neuer Level als Referenz zu verwenden.

Zur Veranschaulichung verschiedener Systeme befinden sich mehrere Teststationen im Level.

### Stufen

Auf der linken Seite befinden sich Stufen, deren Höhe jeweils um 0.1 Meter zunimmt.

Der Spielercharakter kann Stufen bis zu einer Höhe von ungefähr 0.4 Metern ohne Sprung flüssig überwinden. Höhere Stufen können nicht automatisch erklommen werden.

### Steigungen (Slopes)

Hinter den Stufen befinden sich mehrere Rampen mit unterschiedlichen Steigungswinkeln.

Der Spieler kann Steigungen bis ungefähr 45 Grad bewältigen. Die ersten beiden Rampen sollten daher begehbar sein, die rote Rampe nicht.

### Sprunghöhen

Auf der rechten Seite befinden sich mehrere Turmgruppen zur Demonstration der maximal erreichbaren Sprunghöhen.

Da im späteren Spielverlauf zusätzliche Luftsprünge freigeschaltet werden sollen, existieren drei verschiedene Turmkomplexe für unterschiedliche Sprunganzahlen.

Innerhalb jeder Gruppe gilt:

* Kleiner Turm: problemlos erreichbar
* Mittlerer Turm: maximale erreichbare Höhe
* Grosser Turm: nur durch Festhalten an der Kante erreichbar

Das Kantenfesthalten (Ledge Grab) ist bereits technisch implementiert. Die finale Animation existiert jedoch noch nicht. Stattdessen wird momentan die Idle-Animation abgespielt. Dieses Verhalten ist kein Fehler.

### Sprungweiten

Hinter den Sprungtürmen befinden sich Testfelder für horizontale Sprungweiten.

Die grauen Plattformen dienen als Startpunkte.

Die Zielflächen besitzen folgende Bedeutung:

* Orange: Sprung aus dem Stand
* Rot: Sprung mit Anlauf
* Violett: Sprung mit Anlauf und Dash

Die Bereiche sind zusätzlich nach der Anzahl verfügbarer Sprünge unterteilt.

### Kampftest

Im hinteren Bereich der Karte befindet sich ein Testgegner.

Dieser besitzt ein einfaches Armor-System. Wird die Armor vollständig reduziert, wird der Gegner sichtbar zurückgestossen.

Zusätzlich sind derzeit folgende Kampffunktionen implementiert:

* Vierteilige Boden-Combo
* Vierteilige Luft-Combo
* Treffererkennung
* Rückstoss bei Armor-Break

Die unterschiedlichen Animationen können durch wiederholtes Ausführen von Light Attacks beobachtet werden.


## Quellcode

