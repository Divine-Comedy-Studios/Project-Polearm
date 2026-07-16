# Project-Polearm: Zwischenabgabe

Dieses Dokument dient als Orientierungshilfe für die Inhalte der Abgabe und erläutert die aktuell implementierten Funktionen des Prototyps. Sie ist auch unter demselben Namen im PDF-Format verfügbar.


## Inhalt der ZIP-Datei

Die ZIP-Datei enthält folgende Bestandteile:

* Dieses README
* Den schriftlichen Begleitbericht
* Eine ausführbare Version des Spiels (`Spiel.exe` als ZIP-Datei)
* Arbeitsjournale (Ordner: `Arbeitsjournal/`)
* Die vollständige Projektdatei des Spiels (Ordner: `Source Code`)


Der Begleitbericht ist grundsätzlich eigenständig verständlich. Das vorliegende README dient insbesondere dazu, die Verbindung zwischen den im Begleitbericht beschriebenen Systemen und den beigelegten Quellcodedateien herzustellen.


## Ausführen des Prototyps

Starten Sie die Datei `Spiel.exe`.

Nach dem Start erscheint das Hauptmenü.


### Menüs

Die Menünavigation funktioniert wie folgend:
* ESC-Taste: Eine Menüebene zurück
* B-Taste (Xbox-Controller): Eine Menüebene zurück
* Entsprechende Zurück-Tasten anderer Controller werden ebenfalls unterstützt

Im Spiel können folgende Tasten gedrückt werden, um auf das Pausierungsmenü zurückzugreifen:
* ESC-Taste auf Keyboard
* Start-Button auf Controller

Das Save-Menü besitzt derzeit noch keine Funktion und dient als Platzhalter. Einige Einstellungen wurden für diese Zwischenabgabe bewusst deaktiviert oder vereinfacht, um einen stabilen und reproduzierbaren Ablauf des Prototyps sicherzustellen. Wir empfehlen nicht, Einstellungen abzuändern.

Im Bereich „Controller Mapping“ bzw. „Keyboard Mapping“ können die aktuell verwendeten Eingabebelegungen eingesehen werden. Das Button Mapping wurde ebenfalls abgestellt.


### Steuerung

Folgende Eingaben sind im Prototyp funktional:
* Kamerabewegung
* Bewegung (inkl. dynamische Laufanimation bei verschiedener Neigung des Joysticks. Nur möglich auf Controller)
* Boden- und Luftsprünge (Sprunghöhe wird basierend auf die Länge des Knopfdruckes ausgerechnet)
* Gleiten (der Sprung-Knopf kann beim Fallen gehalten werden, um dies zu aktivieren)
* Light-Attacks auf Boden und Luft
* Dashen (der Knopf kann gehalten werden, um ins Sprinten überzugehen)

**Wir empfehlen, das Spiel auf dem Controller zu erleben.** Falls kein Controller vorhanden ist, funktionieren Tastatur und Maus oder Trackpad ebenfalls.


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

Da im späteren Spielverlauf zusätzliche Luftsprünge (d.h. insgesamt drei Sprünge) freigeschaltet werden sollen, existieren drei verschiedene Turmkomplexe für unterschiedliche Sprunganzahlen.

Innerhalb jeder Gruppe gilt:

* Kleiner Turm: problemlos erreichbar
* Mittlerer Turm: maximale erreichbare Höhe
* Großer Turm: nur durch Festhalten an der Kante erreichbar

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

Folgende Kampffunktionen sind implementiert:
* Eine vierteilige Boden-Combo
* Eine vierteilige Luft-Combo
* Treffererkennung
* Leben und Schaden
* Rückstoß

Bei dem wiederholten Ausführen von Light-Attacks können verschiedene Animationen beobachtet werden, dies sind die Combos. Die Boden-Combo kann durch das einfache Angreifen auf den Boden ausgelöst werden, während der Spieler in der Luft angreifen muss, um die Luft-Combo zu aktivieren.

Direkt vor dem Erscheinungspunkt des Spielers befinden sich zwei Charaktere, ein roter Klon des Spielers und eine weiße Kapsel. An der weißen Kapsel kann die Rückstoßmechanik des Spiels getestet werden. Wird diese geschlagen, so wird sie weggestoßen. Der rote Klon spielt eine Schadens-Animation ab, wenn dieser getroffen wird. Bei einem Treffer werden ihm eine gewisse Lebensmenge abgezogen, welche an der Lebensleiste über seinem Kopf dargestellt wird. Jeder Angriff innerhalb eines Kombos besitzt verschiedene Schadensmengen. Sollte man den Klon für einige Zeit nicht schlagen, wird dieser sein Leben langsam zurückkriegen, ebenfalls an seiner Lebensleiste dargestellt. Der Klon kann im Prototyp nicht sterben.


## Quellcode

Der Quellcode des Projektes verfügt über rund 8000 Zeilen selbstgeschriebenen Code und mehrere Third-Party Libraries und Addons für Godot. Diese befinden sich im `addons/` Ordner. Ihnen wurden keine Änderungen unternommen. In den `Assets/` Ordner befinden sich zusätzlich die visuellen Komponenten des Spiels, welche ebenfalls extern erworben und gelegentlich modifiziert wurden, mit der Ausnahme der Szenen- und GD-Script-Dateien in `Assets/3D \Models/Characters/YBot`. Bis auf diese müssen für die Bewertung weder die Third-Party Komponenten noch die Assets in Betracht gezogen werden.

> Die Linienanzahl des Quellprogrammes wurde durch folgenden Command-Line-Command auf einem UNIX-System berechnet:
> ```
> find . \
>   -path ./addons -prune -o \
>   -path ./.godot -prune -o \
>   ( -name ".gd" -o -name ".cs" ) \
>   -print0 |
> xargs -0 wc -l |
> tail -1
> ```
> Diese betrachtet nur die von uns geschriebenen oder generierten GD-Script- und C#-Dateien. Leere Linien wurden dabei auch mitgezählt.


### Navigation

In den folgenden Ordnern finden sich die wichtigsten Dateien des Quellprogrammes und beinhalten folgende Inhalte:
* `Common/`: Häufig wiederverwendbare Komponenten. Darunter:
	- **`Collision/FloatingBody.cs`**: Ein Algorithmus, welcher die Bewegung über raue Ebenen erlaubt
	- **`Collision/Hitbox.gd`**, **`Collision/Hurtbox.gd`**: Universelle Treffer-Logik
	- **`StateMachine/BasicState.gd`**, **`StateMachine/BasicStateMachine.gd`**: Universelle State-Machine-Implementierung, wird von allen Entities und dem Spiel-Manager benutzt
* `Core/`: Die Kernkomponente für die Funktion des Spiels. Darunter:
	- `AppStateMachine/`: Basis-Implementierungen für die State-Machine von Main und dem Spiel-Manager
	- `Main/`: State und State Machine für den Einstiegspunkt des Programmes. Verwaltet Start-Sequenz, Menüs und das Laden des Spiels selbst
	- `Game/`: State und State Machine für das Makro-Spielverhalten. Verwaltet das Spiel und das Pause-Menü
	- `Settings/SettingsManager.gd`: Lädt, verifiziert und verwaltet die Einstellungen des Spiels und stellt diese für alle anderen Komponenten zur Verfügung.
* `Entities/`:
	- `Entity/`: Basis-Entity-Implementierung
		- **`Actions/EntityAction.gd`**, **`Actions/EntityActionManager.gd`**: Basis-State und State-Machine-Implementierung für eine dynamische Entity, d.h. Spieler und Gegner
		- **`Animation/EntityAnimator.gd`**: Verwaltet und spielt Animationen auf Nachfrage ab, kann dynamisch Animationen ein- und ausblenden
		- **`Animation/EntityFrameData.gd`**: Steuert das Verhalten des Spielers durch eine konfigurierbare Anreihung von Parametern basierend auf der jetzigen Animation
		- **`Combat/EntityCombatManager.gd`**: Verwaltet Combos und Kampfstatistiken des Objektes
		- **`Data/EntityResources.gd`**: Verwaltet Ressourcen des Entitys wie Lebenszahl, Energie und SuperArmor. Zusätzlich zuständig für das Unterbrechen der jetzigen States bei Schadensnahme
	- **`Player/`**: Quellcode des Spielers. Beinhaltet Spezialisierungen auf die Funktionalitäten der Basis-Entity-Klasse. Alle Strukturen im Spieler werden in dem Inheritance-Struktur-Diagramm im Begleitbericht dargestellt, bis auf die konkreten States/Actions
	- `DummyEnemy/`: Quellcode und Daten des Dummy Enemies
	- `Test/`: Quellcode der weißen Kapsel
* `Interfaces/`:
	- `InterfaceStateMachine/`: State und State-Machine-Implementierung für Menüs. Nicht von `Common/StateMachine/` abgeleitet.
	- `Menus/`: Menüs und Untermenüs
		- `MainMenu/`: Hauptmenü
		- `PauseMenu/`: Pause-Menü
		- `OptionsMenu/`: Menü zur Konfiguration des Spiels, im Spiel durch das Hauptmenü und Pause-Menü verfügbar
	- `UIElements/`: Menüelemente wie Knöpfe für Button-Remapping
	- `ValueBar/ValueBarUI/ValueBarUI.gd`: Lebensleiste, sichtbar über dem Kopf des roten Klons
* `Objects/`: Einfache und semi-statische Objekte
	- `Weapon/`: Generelle Waffen-Implementierung und Waffe des Spielers
* `Stages/`: Levels und Räume
	- `Documentation/Gym/Gym.tscn`: Das GYM des Spiels, wo man sich nach dem Starten des Spiels befindet
* `Trenchbroom/`: (Trenchbroom ist die Software, die wir benutzen, um zu grayboxen) Alle nötigen Skripte und Dateien, die man braucht, um die Trenchbroom-Map in Godot zu benutzen.
	- `CustomScripts/`: Hier kommen alle Skripte rein, die Trenchbroom beim Builden modifizieren, damit es weniger Aufwand ist, z.B. automatisches Setzen von Collision-Boxen.
	- `Maps/`: Das sind die Map-Dateien, die aus Trenchbroom exportiert werden.
	- `Textures/`: Texturen, damit das Grayboxen nicht wirklich grau, sondern ein wenig farbenfroh ist.

Die dick markierten Sachen wurden in den UML-Diagrammen aus dem Begleitbericht erwähnt. Die Klassen besitzen in der Regel den gleichen Namen wie ihre Datei.


![image](Assets/Selfie.png)
Wir bedanken uns bei Ihnen für Ihren Aufwand und hoffen, dass das Prototyp Ihnen gefällt!
