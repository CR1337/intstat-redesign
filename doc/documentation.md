# Dokumantation für das INTSTAT Redesign

## Varianten

Die neue Datenbank soll eine Versionshistorie beinhalten. Das bedeutet, dass Daten nur hinzugefügt, jedoch nie gelöscht werden können. Wir eine Zeile verändert, so wird der alte Stand in der Historie gespeichert und eine neue Zeile mit dem neuen Stand hinzugefügt. Ältere Stände lassen sich jederzeit abrufen.

Der Zugriff auf die alte Datenbank erfolgte für jeden mit dem selben Benutzer-Account. Aus Gründen der Nachvollziehbarkeit, können wir darüber nachdenken, dass jeder seinen eigenen Account erhält und getrackt wird, welcher Nutzer welche Veränderungen vorgenommen hat.

### Nutzer Tracking

Beim Nutzer Tracking gäbe es eine weitere Tabelle `tab_nutzer`, in welcher alle Nutzer abgelegt sind. Weiterhin enthält jede Tabelle ine weitere Spalte `nutzer_id`. Diese Spalte enthält die ID des Nutzers, welcher diese Spalte angelegt hat.

### Manuelle vs. automatische Versionierung

Für die manuelle Versionierung erhält jede Tabelle zwei weitere Spalten: `gueltig_seit` und `ist_aktiv`. Wird eine neue Zeile hinzugefügt (durch INSERT oder UPDATE), wird `gueltig seit` automatisch auf den aktuellen Timestamp gesetzt. Soll die Zeile durch ein DELETE gelöscht werden, so wird tatsächlich eine neue Zeile mit `ist_aktiv = FALSE` eingefügt. Das ist ein _"Grabstein"_ und markiert, dass es keinen aktuellen Stand für diese Zeile gibt.

Das beschriebene Verhalten wird durch SQL-`TRIGGER` implementiert, welche `INSERT`-, `UPDATE`- und `DELETE`-Befehle abfangen und durch das gewünschte Verhalten ersetzen. Somit kann von außen mit der Datenbank interagiert werden, als existiere die Historie nicht.

Ab MySQL Version 8 existiert eine automatische Versionierung. Diese bietet grundsätzlich dieselben Features, wie die manuelle Versionierung. Sie ist deutlich einfacher in der Anwendung, erlaubt jedoch nicht soviel Kontrolle, wie die manuelle Versionierung (z.B. spezielles `TRIGGER`-Verhalten). Auch machen wir uns dann abhängig von MySQL Version >=8. Die automatische Versionierung erlaubt das Löschen der Historie über einen speziellen Befehl.

## Entity Relationship Diagramme

### Ohne Nutzer Tracking

```mermaid

```

### Mit Nutzer Tracking

```mermaid

```

## Tabellen

### `daten`

Speichert die eigentlichen Datenwerte, die mit Ländern und Indikatoren verknüpft sind.
### `laendergruppen`

Enthält Gruppen, zu welchen Länder gehören können, z.B. EU oder G7.
### `laendergruppenzuordnungen`

Diese Tabelle ordnet Ländergruppen ihre Länder zu.
### `nutzer`

Diese Tabelle speichert alle Nutzer. Sie ist nur notwendig, wenn Nutzer Tracking angewandt wird.
### `quellen`

Hier werden die Quellen gespeichert, aus denen die Werte für die Indikatoren stammen.
### `indikatoren`

Enthält alle Indikatoren. Jeder Indikator besizt ein Thema, eine Quelle und eine Einheit. Außerdem enthält er einen Faktor, welcher mit zugehörigen Werten multipliziert werden muss und eine Dezimalstellengenauigkeit. 
### `themen`

Jedes Thema hat einen deutschen und einen englischen namen und eine Farbe.
### `laender`

Hier sind die Länder gespeichert. Ein Land hat ISO2- und ISO3-Kennungen. Ein Land kann mehrere Namen haben. Auf die Anzeigenamen verweisen die Fremndschlüssel eines Landes.
### `einheiten`

Enthält die Einheiten. eine Einheit hat ein Symbol und einen Beasiseinheit, in welche sie sich mittels ein es Faktors umrechnen lässt.
### `laendernamen`

Hier sind alle Ländernamen abgelegt. Ein Ländername ist einem Land zugeordnet.
### `kontinente`

Jeder Kontinent hat einen deutschen und einen englischen Namen.

## Schnittstelle zur Datenbank

In diesem Abschnitt wird exemplarisch an der Tabelle `daten` die Interaktion mit der Datenbank demonstriert.

### Einfügen eines **neuen** Datensatzes

```sql
INSERT INTO tab_daten(
    daten_id,

    laender_id,
    indikatoren_id,

    datum,
    wert
) VALUES (
    SELECT neue_daten_id FROM view_daten_neue_id,

    123,
    42,

    '2026-01-01',
    3.141
);
```

Zu beachten ist hierbei:

1. Die Felder `gueltig_seit`, `ist_aktiv` und `nutzer_id` werden nicht vom benutzer gesetzt, sondern vom System verwaltet.
2. `SELECT neue_daten_id FROM view_daten_neue_id` liefert die nächste freie ID. Wir können nicht `AUTO_INCREMENT` verwenden, weil es auch für das Aktualisieren von Zeilen neue IDs erzeugen würde.

### Aktualisieren eines **bestehenden** Datensatzes

```sql
UPDATE tab_daten
SET wert = 3.0
WHERE daten_id = 11;
```

Das System wird die Zeile nicht überschreiben, sondern eine neue Zeile anlegen.

### Löschen eines bestehenden Datensatzes

```sql
DELETE FROM tab_daten
WHERE daten_id = 11;
```

Das System wird die Zeile nicht löschen, sondern eine _"Grabstein"_-Zeile einfügen.

### Auslesen eines aktuellen Datensatzes

```sql
SELECT *
FROM view_daten_aktuell
WHERE daten_id = 11;
```

Es kann zwar direkt aus `tab_daten` gelesen werden, jedoch muss dann die aktuelle Version noch manuell herausgefiltert werden. `view_daten_aktuell` führt diese Filterung bereits durch.

### Auslesen der Historie eines Datensatzes

```sql
SELECT *
from view_daten_historie
WHERE daten_id = 11;
```

Das liefert dasselbe Ergebnis, wie die direkte Abfrage auf `tab_daten` jedoch ist das Ergbnis bereits nach `gueltig_seit` sortiert.

### Auslesen des Standes eines bestimmten Datensatzes zu einer bestimmten Zeit

```sql
SELECT *
FROM view_daten_historie
WHERE daten_id = 11
    AND gueltig_seit <= '2025-12-31 12:00:00'
ORDER BY gueltig_seit DESC
LIMIT 1;
```

Diese Abfrage gibt die Zeile mit `daten_id` 11 zum Stand vom 31.12.2025 um 12 Uhr zurück.

### Auslesen des Standes einer ganzen Tabelle zu einer bestimmten Zeit

#### Manuelle Versionierung

```sql
SELECT t.*
FROM tab_daten t
JOIN (
    SELECT
        daten_id,
        MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_daten
    WHERE gueltig_seit <= '2025-12-31 12:00:00'
    GROUP BY daten_id
) latest
  ON t.daten_id = latest.daten_id
 AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;
``` 

#### Automatische Versionierung

```sql
SELECT *
FROM tab_daten
FOR SYSTEM_TIME AS OF '2025-12-31 12:00:00'
```
