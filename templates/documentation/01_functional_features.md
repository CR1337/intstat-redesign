## Funktionale Features

### Versionierung

Um Änderungen an den Daten auch nachträglich nachvollziehbar zu machen, arbeitet die Datenbank mit einem Versionierungssystem ähnlich [SCD Typ 2](https://de.wikipedia.org/wiki/Slowly_Changing_Dimensions#Typ_2).

Grundsätzlich werden dabei für vollständige Nachvollziehbarkeit niemals Daten gelöscht. Jede Veränderung oder Löschung eines Datensatzes zieht stattdessen die Erstellung eines neuen Datensatzes nach sich.

Um dies zu realisieren besitzt jede Tabelle die beiden Spalten `gueltig_seit` und `ist_aktiv`. Die Spalte `gueltig_seit` beinhaltet das Datum der Erstellung einer Zeile. Die Spalte `ist_aktiv` gibt an, ob es sich bei einer Zeile um einen aktiven Datensatz handelt.

Die `id`-Spalte einer Tabelle bildet zusammen mit `gueltig_seit` den Primärschlüssel. Für alle Zeilen mit identischer `id` ist jene mit dem jüngsten Eintrag in `gueltig_seit` die aktuell gültige Zeile. Alle anderen Zeilen gehören zur Historie und können im normalen Betrieb ignoriert werden.

Beim Ändern einer bestehenden Zeile wird also tatsächlich eine Neue Zeile mit dem aktuellen Datum in `gueltig_seit` erzeugt, siehe nachfolgendes Beispiel:

|gueltig_seit|ist_aktiv|ersteller_nutzer_id|kontinente_id|name_de|name_en|
|------------|---------|-------------------|-------------|-------|-------|
|  2026-01-01|        1|                 42|            3| Europa| Europa|

Dem Nutzer ist ein Schreibfehler im englischen Namen des Kontinentes Europa aufgefallen. Er führt am zweiten Februar folgenden SQL-Befehl aus, um den Fehler zu korrigieren:

```SQL
CALL update_value_kontinente_name_en(3, 'Europe');
```

Das Ergebnis ist folgendes:

|gueltig_seit|ist_aktiv|ersteller_nutzer_id|kontinente_id|name_de|name_en|
|------------|---------|-------------------|-------------|-------|-------|
|  2026-01-01|        1|                 42|            3| Europa| Europa|
|  2026-02-02|        1|                 42|            3| Europa| Europe|


Beim Löschen einer Zeile wird stattdessen eine neue Zeile (ein [_Tombstone_](https://en.wikipedia.org/wiki/Tombstone_(data_store))) mit `ist_aktiv = 0` dem aktuellen Datum in `gueltig_seit` erzeugt. Folgendes Beispiel verdeutlicht das Löschen:

Der Nutzer löscht nun am dritten März den Eintrag für Europa durch Ausführen des folgenden SQL-Befehles:

```SQL
CALL delete_from_kontinente(3);
```

Das Ergebnis ist folgendes:

|gueltig_seit|ist_aktiv|ersteller_nutzer_id|kontinente_id|name_de|name_en|
|------------|---------|-------------------|-------------|-------|-------|
|  2026-01-01|        1|                 42|            3| Europa| Europa|
|  2026-02-02|        1|                 42|            3| Europa| Europe|
|  2026-03-03|        0|                 42|            3| Europa| Europe|

Um die Arbeit mit der Datenbank zu vereinfachen existieren für jede Tabelle `tab_<NAME>` zwei Views:

- `view_<NAME>_historie`
- `view_<NAME>_aktuell`

`view_<NAME>_historie` enthält den gesamten Inhalt der Tabelle sortiert nach `id` und `gueltig_seit`.

`view_<NAME>_aktuell` enthält nur die aktuell gültigen Zeilen. Für jede `id` wird nur die Zeile mit dem jüngsten Wert in `gueltig_seit` angezeigt. Zeilen mit `ist_aktiv = 0` werden nicht angezeigt. Diese View simuliert das Aussehen einer Tabelle ohne Versionierung und Historie.

### Nutzertracking

Die Tabelle `tab_nutzer` enthält alle Nutzer der Datenbank. Interagiert ein Nutzer, welcher noch nicht in `tab_nutzer` enthalten ist, mit der Datenbank, so wird er automatisch zu `tab_nutzer` hinzugefügt.

Jede Tabelle besitzt die Spalte `ersteller_nutzer_id` welche ein Fremdschlüssel für die Tabelle `tab_nutzer` ist. Somit enthält jede Zeile jeder Tabelle einen Verweis auf einen Nutzer. Dieser Verweis wird automatisch erstellt und gibt den Nutzer an, welcher für die Erstellung der entsprechenden Zeile verantwortlich ist.

Das automatische Hizufügen von Nutzern und das automatische Erstellen der Nutzerverweise funktioniert nur, wenn zur Interaktion mit der Datenbank die vordefinierten _Stored procedures_ verwendet werden.

Ein ausschließlich lesender Zugriff erzeugt keine neuen Nutzer oder Nutzerverweise.