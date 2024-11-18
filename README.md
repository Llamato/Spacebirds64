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
