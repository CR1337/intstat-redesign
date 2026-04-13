## Benutzung der Datenbank

### Einfügen einer Zeile

Das Einfügen einer neuen Zeile in die Tabelle `tab_<NAME>` geschieht durch Ausführen der _Procedure_ `insert_into_<NAME>`. Durch folgenden SQL-Code kann z.B. ein neuer Kontinent "_Atlantis_" eingefügt werden:

```SQL
SET @neue_id = 0;

CALL insert_into_kontinente(
    "atlantis",
    "Atlantis",
    @neue_id
);

SELECT @neue_id;
```

Die `id` für den neuen Eintrag wird automatisch vergeben und kann durch die Kombination von `SET` und `SELECT` ausgegeben werden. Für die folgenden Beispiele sei diese `id = 3`.

### Auslesen einer aktuell gültigen Zeile

Um die aktuell gültige Version einer Zeile auszulesen kann ein normales SELECT-Statement verwendet werden. Das Auslesen der Zeile mit der `id = 3` aus der Tabelle `tab_kontinente` funktiontiert so:

```SQL
SELECT t.*
from tab_kontinente t
INNER JOIN (
    SELECT kontinente_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_kontinente
    GROUP BY kontinente_id
) latest
ON t.kontinente_id = latest.kontinente_id
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv AND t.kontinente_id = 3;
```

Weil das sehr aufwändig uns schwer zu lesen ist, existiert für jede Tabelle eine View `view_<NAME>_aktuell`, welche diesen Vorgang erleichtert:

```SQL
SELECT * from view_kontinente_aktuell WHERE kontinente_id = 3;
```

Es wird empfohlen, für sämtliche Abfragen, welche nicht die Historie benötigen, nur diese Views zu verwenden.

### Aktualisieren einer Zeile

Das Aktualisieren einer Zeile mittels des UPDATE-Statements ist nicht möglich, um Datenverlust in der Historie zu verhindern. Stattdessen existieren für jede Tabelle `tab_<NAME>` mehrere _Procedures_ `update_value_<NAME>_<SPALTENNAME>`, eine für jede Spalte.

Um die Groß-Klein-Schreibung des deutschen Namens des Kontinentes Atlantis zu verändern, kann folgender SQL.Befehl verwendet werden:

```SQL
CALL update_value_kontinente_name_de(3, 'Atlantis');
```

### Löschen einer Zeile

Genauso wie das direkte Aktualisieren mit UPDATE ist auch das direkte Löschen mit DELETE nicht möglich. Stattdessen gibt es die _Procedure_ `delete_from_<NAME>`. Um den Kontinent Atlanis zu löschen kann also folgender Befehl benutzt werden:

```SQL
CALL delete_from_kontinente(3);
```

### Auslesen einer älteren Version einer Zeile

Um ältere Versionen eine Zeile auszulesen existiert keine View. Es kann allerdings mit einem SELECT-Statement gearbeitet werden. Um z.B. den Stand der Tabelle `tab_kontinente` zum Zeitpunkt `2025-12-31 12:00:00` zu erhalten, kann dieser SQL-Befehl ausgeführt werden:

```SQL
SELECT t.*
from tab_kontinente t
INNER JOIN (
    SELECT kontinente_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_kontinente
    WHERE gueltig_seit <= '2025-12-31 12:00:00'
    GROUP BY kontinente_id
) latest
ON t.kontinente_id = latest.kontinente_id
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;
```