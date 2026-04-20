## Inhaltliche Features

### Metadaten

Die Datenbank ermöglicht die flexible Zuordnung von Metadaten zu einzelnen Datenpunkten. Metadaten dienen hier als zusätzliche Informationen, die den Kontext, die Qualität oder die Besonderheiten eines statistischen Werts beschreiben – etwa methodische Hinweise, Fußnoten oder spezifische Anmerkungen zur Datenerhebung.

```mermaid
erDiagram
    tab_daten {
        INTEGER daten_id PK
    }

    tab_metadaten {
        INTEGER metadaten_id PK
        VARCHAR(8) kuerzel
        VARCHAR(256) bezeichnung
    }

    tab_metadatenzuordnungen {
        INTEGER metadatenzuordnungen_id PK
        INTEGER daten_id FK
        INTEGER metadaten_id FK
    }

    tab_metadatenzuordnungen ||--o{ tab_daten : ""
    tab_metadatenzuordnungen ||--o{ tab_metadaten : ""
```

### Ländergruppen

Ländergruppen ermöglichen die logische Gruppierung von Ländern nach politischen, wirtschaftlichen oder geografischen Kriterien (z.B. EU, OECD, G7). Dies vereinfacht Abfragen und Analysen, die sich auf bestimmte Länderblöcke beziehen.

```mermaid
erDiagram
    tab_laender {
        INTEGER laender_id PK
    }

    tab_laendergruppen {
        INTEGER laendergruppen_id PK
        VARCHAR(256) name_de
        VARCHAR(256) name_en
    }

    tab_laendergruppenzuordnungen {
        INTEGER laendergruppenzuordnungen_id PK
        INTEGER laender_id FK
        INTEGER laendergruppen_id FK
    }

    tab_laendergruppenzuordnungen ||--o{ tab_laender : ""
    tab_laendergruppenzuordnungen ||--o{ tab_laendergruppen : ""
```

### Quellen

Die Datenbank verwaltet Quellenangaben für jeden Datenpunkt einzeln, um auch Indikatoren mit gemischten Quellen unterstützen zu können. Es wird auch erfasst, ob ein Datenpunkt berechnet wurde. Weil berechnete Datenpunkte aus mehreren Quellen stammen können, kann jedem Datenpunkt eine beliege Menge an Quellen zugeordnet werden. Außerdem wird unterschieden zwischen _Quellen_, aus denen die Daten ursprünglich stammen und _Download-Quellen_, aus welchen die Daten geladen wurden.

```mermaid
erDiagram
    tab_daten {
        INTEGER daten_id PK
        BOOLEAN berechnet
    }

    tab_quellen {
        INTEGER quellen_id PK
        VARCHAR(256) name_de
        VARCHAR(256) name_en
        VARCHAR(16) name_kurz_de
        VARCHAR(16) name_kurz_de
        VARCHAR(512) url
    }

    tab_quellenzuordnungen {
        INTEGER quellenzuordnungen_id PK
        INTEGER daten_id FK
        INTEGER quellen_id FK
    }

    tab_downloadquellenzuordnungen {
        INTEGER quellenzuordnungen_id PK
        INTEGER daten_id FK
        INTEGER quellen_id FK
    }

    tab_quellenzuordnungen ||--o{ tab_daten : ""
    tab_quellenzuordnungen ||--o{ tab_quellen : ""

    tab_downloadquellenzuordnungen ||--o{ tab_daten : ""
    tab_downloadquellenzuordnungen ||--o{ tab_quellen : ""
```

### Lizenzen

Jedem Datenpunkt ist eine Lizenz zugeordnet. Die Lizenz gibt an, wie der Datenpunkt verwendet werden darf. Die Spalte `extra_bedingungen` gibt an, ob weitere Bedingungen bei der Verwendung des Datenpunktes zu beachten sind.

```mermaid
erDiagram
    tab_daten {
        INTEGER daten_id PK
        INTEGER lizenzen_id FK
    }

    tab_lizenzen {
        INTEGER lizenzen_id PK
        VARCHAR(64) name
        VARCHAR(512) url
        BOOLEAN extra_bedingungen
    }

    tab_lizenzen ||--o{ tab_daten : ""
```

### Einheiten

Jeder Indikator besitzt eine Einheit. Einheiten lassen sich durch einen Faktor und Angabe der jeweiligen Basiseinheit in einander umrechnen (z.B. m² in km²).

```mermaid
erDiagram
    tab_einheiten {
        INTEGER einheiten_id PK
        DOUBLE faktor
        VARCHAR(64) symbol_de
        VARCHAR(64) symbol_en
        INTEGER basis_einheiten_id FK
    }

    tab_indikatoren {
        INTEGER indikatoren_id PK
        INTEGER einheiten_id FK
    }

    tab_einheiten ||--o{ tab_indikatoren : ""
    tab_einheiten ||--o{ tab_einheiten : ""
```

### Untergliederungen (ugl)

```mermaid
erDiagram
    tab_indikatoren {
        INTEGER indikatoren_id PK
    }

    tab_daten {
        INTEGER daten_id PK
        INTEGER indikatoren_id FK
        INTEGER laender_id FK
    }

    tab_laender {
        INTEGER laender_id PK
    }

    tab_ugl {
        INTEGER ugl_id PK
        VARCHAR(64) name
    }

    tab_ugl_werte {
        INTEGER ugl_werte_id PK
        INTEGER ugl_id FK
        VARCHAR(64) name
        INTEGER laender_id FK
    }

    tab_ugl_zo {
        INTEGER ugl_zo_id PK
        INTEGER ugl_werte_id FK
        INTEGER daten_id FK
    }

    tab_indikatoren ||--o{ tab_daten : ""
    tab_laender ||--o{ tab_daten : ""

    tab_ugl ||--o{ tab_ugl_werte : ""
    tab_laender ||--o{ tab_ugl_werte : ""

    tab_ugl_werte ||--o{ tab_ugl_zo: ""
    tab_daten ||--o{ tab_ugl_zo: ""
```
