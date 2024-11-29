# Spacebirds64
A flappy bird inspired obstacle avoidance game for the commodore c64 of 1982 developed in 2024.



# Coding Conventions

### Warung der Kompatiblität. 
Um kompatiblität zum c64 nativen Turbo Macro Pro 1.2 von Style zu waren muss der Quellcode folgenden Format vorgaben entsprechen.

- Alle Label dürfen ausschließlich aus Kleinbuchstaben bestehen.
- Alle Label dürfen eine Länge von 15 Zeichen nicht überschreiten.
- Alle Psudo-op Zeichenketten dürfen eine Länge von 30 Zeichen nicht überschreiten.
- Alle Hexadezimal zahlen dürfen nur aus Ziffern und Kleinbuchstaben bestehen.

### Register-Sicherung in Subroutinen

- Wenn eine Subroutine ein Register verändert, speichert sie dessen Wert vor der Nutzung auf dem Stack (oder in temporären Variablen im Zero-Page-Bereich), damit Register beim Aufrufer unverändert bleiben.

```nasm
; Register X und A sichern
PHA             ; Akkumulator auf Stack legen
TXA             ; Wert von X in A kopieren
PHA             ; A (jetzt X-Wert) auf Stack legen

; Subroutine Code

PLA             ; X-Wert vom Stack holen
TAX             ; X-Wert wiederherstellen
PLA             ; A-Wert wiederherstellen
```

- Man muss natürlich nur die Register sichern die auch in der Routine genutzt werden.

### Dokumentation und Kommentare

- Kommentiert jeden Block und erklärt, was er macht – besonders bei komplexen Codeabschnitten.
- Dokumentiert in jeder Subroutine welche Parameter einer Routine übergeben werden

```nasm
;------------------------------
; delay a = delay in seconds
;-------------------------------
delay
.block
; code 
.bend
```

### Lokales Scoping für Labels

- Verwendet `.block` und `.bend`, um Labels innerhalb eines Bereichs lokal zu definieren. Labels in diesem Block sind dann nur innerhalb des Blocks sichtbar und überschreiben keine Labels in anderen Bereichen.

```nasm
Subroutine
.block
;code
loop          ;Dieses Label kann man nur im Block sehen
;code
.bend
```

### Verwendung der vscode + tmpx zu c64 + tmp development toolchain
Für all jene die durch zu viel programmieren in Turbo Macro Pro ihre Sehle verloren haben.
Hört hört! Die Rettung naht. 

Als erstes stellen wir sicher, dass unser 6502 code, als solcher erkannt wird. Dazu können wir die 6502-ASM Syntax Erweiterung aus dem Addon Store beziehen.
Alternativ kann auch die umfassende vs64 Erweiterung bezogen werden. Die kommt auch direkt mit einer Anleitung zur Installation des VICE Comodore 8 bit Computer Emulators. Weshalb der notwendige Schritt der VICE Installation hier nicht weiter behandelt wird. Leider ist Tmpx nicht unter den druch vs64 nativ unterstüzten Assemblern. 

Daher müssen wir die wichtigsten druch vs64 für andere Assembler bereitgestellten Funktionen nun selbst für TMPx nachbilden. Dazu sind bereits Buildscripts so wie eine vscode compatible tasks.json bereitgestellt. 

Sobald diese sich in der Lokalen Kopie des Repos befinden müssen wir nur noch petcat und c1541 (beide befinden sich im VICE Hauptverzeichniss) zur PATH Umgebungsvariable hinzufügen.

Ist das erledigt, sollten wir einige neue vsbuild Aufgaben widerfinden. die es uns erlauben mit tmpx ein Compilat zu erstellen (tmpx assemble), unser Programm in VICE zu testen (launch in vice) oder eine code disk zu packen (pack asm / code disk). Die Code disk entählt dann alle Sourcecode Datein von Ascii nach Petscii convertiert. Und zwar so das Turbo Macro Pro sie als SEQ Datein einlesen kann.

## Transfer von Turbo macro pro zu TMPx.

Für alle diese die ihre Seele an Style verkauft haben und nur deswegen, denn das ist gewiss die einzig sinnige Erklärung, Freude am programmieren mit Turbo Macro Pro haben aber dennoch auf Vorzüge einer modernen Versionsverwaltung nicht verzichten wollen (Möglicherweise weil sie von mir dazu verdonnert, äh, ich meine gebeten wurden, dieses Github Repo zu verwenden).

Zur Übertragung findet ihr also unter dem im Repo enthaltenden VScode Task, "unpack asm disk". Um diesen verwenden zu können müssen wir nur styles TMPview installieren und zur PATH-Umgebungsvariable hinzufügen. Das erledigt, können wir den "unpack asm disk" Task benutzen. Wie gefordert noch angeben wo sich das d64 Image welches es zu entpacken gilt befindet und fertig.

Jetzt ist der Inhalt des d64 Images im Ordner build/unpack zu finden.
