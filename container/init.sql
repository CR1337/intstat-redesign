CREATE DATABASE IF NOT EXISTS intstat2;



CREATE USER IF NOT EXISTS 'write-1'@'%' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'write-2'@'%' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'read-1'@'%' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'read-2'@'%' IDENTIFIED BY 'password';
CREATE USER IF NOT EXISTS 'super'@'%' IDENTIFIED BY 'password';

GRANT SELECT, EXECUTE, LOCK TABLES, SHOW VIEW ON intstat2.* TO 'write-1'@'%';
GRANT SELECT, EXECUTE, LOCK TABLES, SHOW VIEW ON intstat2.* TO 'write-2'@'%';
GRANT SELECT, SHOW VIEW ON intstat2.* TO 'read-1'@'%';
GRANT SELECT, SHOW VIEW ON intstat2.* TO 'read-2'@'%';
GRANT ALL PRIVILEGES ON intstat2.* TO 'super'@'%';
GRANT SUPER ON *.* TO 'super'@'%';


FLUSH PRIVILEGES;

USE intstat2;

DELIMITER $$

CREATE FUNCTION get_aktuellen_nutzer_namen()
RETURNS VARCHAR(256)
NO SQL
BEGIN
    RETURN SUBSTRING_INDEX(CURRENT_USER(), '@', 1);
END$$

DELIMITER ;

CREATE TABLE IF NOT EXISTS tab_nutzer (
    -- Diese Tabelle speichert alle Nutzer.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    nutzer_id INTEGER NOT NULL,


    name VARCHAR(256) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (nutzer_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_quellen (
    -- Tabelle zur Verwaltung von Datenquellen.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    quellen_id INTEGER NOT NULL,


    name_de VARCHAR(256) NOT NULL DEFAULT '',
    name_en VARCHAR(256) NOT NULL DEFAULT '',
    name_kurz_de VARCHAR(16) NOT NULL DEFAULT '',
    name_kurz_en VARCHAR(16) NOT NULL DEFAULT '',
    url VARCHAR(512) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (quellen_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_themen (
    -- Tabelle welche Themen verwaltet, denen Indikatoren zugeordnet sind.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    themen_id INTEGER NOT NULL,


    name_de VARCHAR(64) NOT NULL DEFAULT '',
    name_en VARCHAR(64) NOT NULL DEFAULT '',
    farbe_r TINYINT UNSIGNED NOT NULL DEFAULT 0,
    farbe_g TINYINT UNSIGNED NOT NULL DEFAULT 0,
    farbe_b TINYINT UNSIGNED NOT NULL DEFAULT 0,

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (themen_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_einheiten (
    -- Tabelle zur Verwaltung der Einheiten, in denen statistische Werte angegeben werden.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    einheiten_id INTEGER NOT NULL,

    basis_einheiten_id INTEGER ,

    faktor DOUBLE NOT NULL DEFAULT 0,
    symbol_de VARCHAR(64) NOT NULL DEFAULT '',
    symbol_en VARCHAR(64) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (einheiten_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_laendernamen (
    -- Tabelle zuer Verwaltung von Ländernamen. Ein Land kann mehrere Ländernamen haben. Jedes Land hat einen deutschen und einen englischen Namen.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    laendernamen_id INTEGER NOT NULL,

    laender_id INTEGER ,

    name VARCHAR(256) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (laendernamen_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_kontinente (
    -- Tabelle zur Verwaltung der Kontinente, denen Länder zugeordnet werden können.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    kontinente_id INTEGER NOT NULL,


    name_de VARCHAR(64) NOT NULL DEFAULT '',
    name_en VARCHAR(64) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (kontinente_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_laendergruppen (
    -- Tabelle zur Verwaltung von Ländergruppen (z.B. EU, OECD, G7).
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    laendergruppen_id INTEGER NOT NULL,


    name_de VARCHAR(256) NOT NULL DEFAULT '',
    name_en VARCHAR(256) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (laendergruppen_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_lizenzen (
    -- Tabelle zur Verwaltung der Lizenzen, unter denen die statistischen Daten veröffentlicht werden.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    lizenzen_id INTEGER NOT NULL,


    name VARCHAR(64) NOT NULL DEFAULT '',
    url VARCHAR(512) NOT NULL DEFAULT '',
    extra_bedingungen BOOLEAN NOT NULL DEFAULT 0,

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (lizenzen_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_metadaten (
    -- Tabelle zur Verwaltung von Metadaten, die Datenpunkten zugeordnet werden können (z.B. methodische Hinweise, Fußnoten).
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    metadaten_id INTEGER NOT NULL,


    kuerzel VARCHAR(8) NOT NULL DEFAULT '',
    bezeichnung VARCHAR(256) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (metadaten_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_indikatoren (
    -- Tabelle zur Verwaltung der statistischen Indikatoren.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    indikatoren_id INTEGER NOT NULL,

    themen_id INTEGER NOT NULL,
    einheiten_id INTEGER NOT NULL,

    faktor DOUBLE NOT NULL DEFAULT 0,
    dezimalstellen TINYINT UNSIGNED NOT NULL DEFAULT 0,
    name_de VARCHAR(256) NOT NULL DEFAULT '',
    name_en VARCHAR(256) NOT NULL DEFAULT '',
    beschreibung_de VARCHAR(4096) NOT NULL DEFAULT '',
    beschreibung_en VARCHAR(4096) NOT NULL DEFAULT '',
    quellen_indikatoren_id VARCHAR(128)  DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (indikatoren_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_laender (
    -- Tabelle zur Verwaltung der Länder mit ISO-Codes und Namensreferenzen.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    laender_id INTEGER NOT NULL,

    kontinente_id INTEGER NOT NULL,
    laendernamen_de_id INTEGER NOT NULL,
    laendernamen_en_id INTEGER NOT NULL,

    iso2 VARCHAR(2) NOT NULL DEFAULT '',
    iso3 VARCHAR(3) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (laender_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_daten (
    -- Tabelle für die Speicherung von statistischen Einzelwerten (Zeitreihen) zu Ländern und Indikatoren.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    daten_id INTEGER NOT NULL,

    laender_id INTEGER NOT NULL,
    indikatoren_id INTEGER NOT NULL,
    lizenzen_id INTEGER ,
    quellen_id INTEGER ,

    datum DATE NOT NULL DEFAULT '2000-01-01',
    wert DOUBLE NOT NULL DEFAULT 0,
    berechnet BOOLEAN NOT NULL DEFAULT 0,

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (daten_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_ugl (
    -- Tabelle zur Verwaltung der möglichen Untergliederungen eines Indikators.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    ugl_id INTEGER NOT NULL,


    name VARCHAR(64) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (ugl_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_ugl_werte (
    -- Tabelle zur Verwaltung der Werte der Untergliederungen von Indikatoren.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    ugl_werte_id INTEGER NOT NULL,

    untergliederungen_id INTEGER ,
    laender_id INTEGER ,

    name VARCHAR(64) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (ugl_werte_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_ugl_zo (
    -- Diese Tabelle ordnet Daten ihre Untergliederungswerte zu.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    ugl_zo_id INTEGER NOT NULL,

    untergliederungswerte_id INTEGER NOT NULL,
    daten_id INTEGER NOT NULL,


    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (ugl_zo_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_laendergruppen_zo (
    -- Tabelle zur Zuordnung von Ländern zu Ländergruppen (z.B. Mitgliedschaft eines Landes in einer Gruppe).
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    laendergruppen_zo_id INTEGER NOT NULL,

    laender_id INTEGER NOT NULL,
    laendergruppen_id INTEGER NOT NULL,


    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (laendergruppen_zo_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_metadaten_zo (
    -- Diese Tabelle ordnet Datenpunkten ihre Metadaten zu.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    metadaten_zo_id INTEGER NOT NULL,

    daten_id INTEGER NOT NULL,
    metadaten_id INTEGER NOT NULL,


    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (metadaten_zo_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_quellen_zo (
    -- Diese Tabelle ordnet Datenpunkten ihre Quellen zu.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    quellen_zo_id INTEGER NOT NULL,

    daten_id INTEGER NOT NULL,
    quellen_id INTEGER NOT NULL,


    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (quellen_zo_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_downloadquellen_zo (
    -- Diese Tabelle ordnet Datenpunkten ihre Download-Quellen zu.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,

    ersteller_nutzer_id INTEGER NOT NULL,

    downloadquellen_zo_id INTEGER NOT NULL,

    daten_id INTEGER NOT NULL,
    quellen_id INTEGER NOT NULL,


    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (downloadquellen_zo_id, gueltig_seit)
);

ALTER TABLE tab_einheiten
ADD CONSTRAINT fk_einheiten_einheiten_9fad7e46d7d449aea7d7  --  Optionale Referenz auf eine Basiseinheit, falls die Einheit abgeleitet ist.
FOREIGN KEY (basis_einheiten_id) REFERENCES tab_einheiten(einheiten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laendernamen
ADD CONSTRAINT fk_laendernamen_laender_d76db0759d524a958398  --  Verweis auf das Land, dem der Name zugeordnet ist. (optional)
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_indikatoren
ADD CONSTRAINT fk_indikatoren_themen_4626fcf73346431b99d4  --  Verweis auf das Thema, dem der Indikator zugeordnet ist.
FOREIGN KEY (themen_id) REFERENCES tab_themen(themen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_indikatoren
ADD CONSTRAINT fk_indikatoren_einheiten_e2b2e810baa94ea0896e  --  Verweis auf die Einheit, in der der Indikator gemessen wird.
FOREIGN KEY (einheiten_id) REFERENCES tab_einheiten(einheiten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laender
ADD CONSTRAINT fk_laender_kontinente_3112e16e80fc42e687c1  --  Verweis auf den Kontinent, dem das Land zugeordnet ist.
FOREIGN KEY (kontinente_id) REFERENCES tab_kontinente(kontinente_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laender
ADD CONSTRAINT fk_laender_laendernamen_fb281ece622149d48b71  --  Verweis auf den deutschen Namen des Landes.
FOREIGN KEY (laendernamen_de_id) REFERENCES tab_laendernamen(laendernamen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laender
ADD CONSTRAINT fk_laender_laendernamen_40fbf98787024ea88b2a  --  Verweis auf den englischen Namen des Landes.
FOREIGN KEY (laendernamen_en_id) REFERENCES tab_laendernamen(laendernamen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_daten
ADD CONSTRAINT fk_daten_laender_843799bf79e4481d8643  --  Verweis auf das Land, für das der Wert gilt.
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_daten
ADD CONSTRAINT fk_daten_indikatoren_394ba2f787cc408b8833  --  Verweis auf den Indikator, zu dem der Wert gehört.
FOREIGN KEY (indikatoren_id) REFERENCES tab_indikatoren(indikatoren_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_daten
ADD CONSTRAINT fk_daten_lizenzen_396ed1f7253e4b0cb9d7  --  Verweis auf die Lizenz, unter welcher der Wert steht.
FOREIGN KEY (lizenzen_id) REFERENCES tab_lizenzen(lizenzen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_daten
ADD CONSTRAINT fk_daten_quellen_56855394c00647c1a2a7  --  Verweis auf die Quelle, aus welcher der Wert stammt.
FOREIGN KEY (quellen_id) REFERENCES tab_quellen(quellen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_ugl_werte
ADD CONSTRAINT fk_ugl_werte_ugl_a363544f42ad44f2938d  --  Optionalee Referenz auf die Untergliederung.
FOREIGN KEY (untergliederungen_id) REFERENCES tab_ugl(ugl_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_ugl_werte
ADD CONSTRAINT fk_ugl_werte_laender_e6cd8e2d4e494b638b94  --  Referenz auf ein Land.
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_ugl_zo
ADD CONSTRAINT fk_ugl_zo_ugl_werte_750190ce0b5a48c4ab92  --  Verweis auf den zugeordneten Untergliederungswert.
FOREIGN KEY (untergliederungswerte_id) REFERENCES tab_ugl_werte(ugl_werte_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_ugl_zo
ADD CONSTRAINT fk_ugl_zo_daten_f2ecf1a1a13f4a868b00  --  Verweis auf den zugeordneten Datenpunkt.
FOREIGN KEY (daten_id) REFERENCES tab_daten(daten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laendergruppen_zo
ADD CONSTRAINT fk_laendergruppen_zo_laender_5015337d48924f9980e5  --  Verweis auf das zugeordnete Land.
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laendergruppen_zo
ADD CONSTRAINT fk_laendergruppen_zo_laendergruppen_7a294100dde8421f9952  --  Verweis auf die zugeordnete Ländergruppe.
FOREIGN KEY (laendergruppen_id) REFERENCES tab_laendergruppen(laendergruppen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_metadaten_zo
ADD CONSTRAINT fk_metadaten_zo_daten_a173997238014aeaa3b0  --  Verweis auf den zugeordneten Datenpunkt.
FOREIGN KEY (daten_id) REFERENCES tab_daten(daten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_metadaten_zo
ADD CONSTRAINT fk_metadaten_zo_metadaten_5caf998dcd304bbdba27  --  Verweis auf das zugeordnete Metadatum.
FOREIGN KEY (metadaten_id) REFERENCES tab_metadaten(metadaten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_quellen_zo
ADD CONSTRAINT fk_quellen_zo_daten_e8dd6120073f4c59a9a5  --  Verweis auf den zugeordneten Datenpunkt.
FOREIGN KEY (daten_id) REFERENCES tab_daten(daten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_quellen_zo
ADD CONSTRAINT fk_quellen_zo_quellen_83110d8d936e45b59e01  --  Verweis auf die zugeordnete Quelle.
FOREIGN KEY (quellen_id) REFERENCES tab_quellen(quellen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_downloadquellen_zo
ADD CONSTRAINT fk_downloadquellen_zo_daten_5cfe7ffae8de4504a142  --  Verweis auf den zugeordneten Datenpunkt.
FOREIGN KEY (daten_id) REFERENCES tab_daten(daten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_downloadquellen_zo
ADD CONSTRAINT fk_downloadquellen_zo_quellen_62c7c417ab654b179b2f  --  Verweis auf die zugeordnete Download-Quelle.
FOREIGN KEY (quellen_id) REFERENCES tab_quellen(quellen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

CREATE INDEX idx_nutzer_latest 
    ON tab_nutzer (
        nutzer_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_quellen_latest 
    ON tab_quellen (
        quellen_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_themen_latest 
    ON tab_themen (
        themen_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_einheiten_latest 
    ON tab_einheiten (
        einheiten_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_laendernamen_latest 
    ON tab_laendernamen (
        laendernamen_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_kontinente_latest 
    ON tab_kontinente (
        kontinente_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_laendergruppen_latest 
    ON tab_laendergruppen (
        laendergruppen_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_lizenzen_latest 
    ON tab_lizenzen (
        lizenzen_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_metadaten_latest 
    ON tab_metadaten (
        metadaten_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_indikatoren_latest 
    ON tab_indikatoren (
        indikatoren_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_laender_latest 
    ON tab_laender (
        laender_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_daten_latest 
    ON tab_daten (
        daten_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_ugl_latest 
    ON tab_ugl (
        ugl_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_ugl_werte_latest 
    ON tab_ugl_werte (
        ugl_werte_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_ugl_zo_latest 
    ON tab_ugl_zo (
        ugl_zo_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_laendergruppen_zo_latest 
    ON tab_laendergruppen_zo (
        laendergruppen_zo_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_metadaten_zo_latest 
    ON tab_metadaten_zo (
        metadaten_zo_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_quellen_zo_latest 
    ON tab_quellen_zo (
        quellen_zo_id, 
        gueltig_seit DESC
    );
    

CREATE INDEX idx_downloadquellen_zo_latest 
    ON tab_downloadquellen_zo (
        downloadquellen_zo_id, 
        gueltig_seit DESC
    );
    

CREATE OR REPLACE VIEW view_nutzer_historie AS
SELECT *
FROM tab_nutzer
ORDER BY nutzer_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_quellen_historie AS
SELECT *
FROM tab_quellen
ORDER BY quellen_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_themen_historie AS
SELECT *
FROM tab_themen
ORDER BY themen_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_einheiten_historie AS
SELECT *
FROM tab_einheiten
ORDER BY einheiten_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_laendernamen_historie AS
SELECT *
FROM tab_laendernamen
ORDER BY laendernamen_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_kontinente_historie AS
SELECT *
FROM tab_kontinente
ORDER BY kontinente_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_laendergruppen_historie AS
SELECT *
FROM tab_laendergruppen
ORDER BY laendergruppen_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_lizenzen_historie AS
SELECT *
FROM tab_lizenzen
ORDER BY lizenzen_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_metadaten_historie AS
SELECT *
FROM tab_metadaten
ORDER BY metadaten_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_indikatoren_historie AS
SELECT *
FROM tab_indikatoren
ORDER BY indikatoren_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_laender_historie AS
SELECT *
FROM tab_laender
ORDER BY laender_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_daten_historie AS
SELECT *
FROM tab_daten
ORDER BY daten_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_ugl_historie AS
SELECT *
FROM tab_ugl
ORDER BY ugl_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_ugl_werte_historie AS
SELECT *
FROM tab_ugl_werte
ORDER BY ugl_werte_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_ugl_zo_historie AS
SELECT *
FROM tab_ugl_zo
ORDER BY ugl_zo_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_laendergruppen_zo_historie AS
SELECT *
FROM tab_laendergruppen_zo
ORDER BY laendergruppen_zo_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_metadaten_zo_historie AS
SELECT *
FROM tab_metadaten_zo
ORDER BY metadaten_zo_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_quellen_zo_historie AS
SELECT *
FROM tab_quellen_zo
ORDER BY quellen_zo_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_downloadquellen_zo_historie AS
SELECT *
FROM tab_downloadquellen_zo
ORDER BY downloadquellen_zo_id, gueltig_seit DESC;

CREATE OR REPLACE VIEW view_nutzer_aktuell AS
SELECT t.*
from tab_nutzer t
INNER JOIN (
    SELECT nutzer_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_nutzer
    GROUP BY nutzer_id
) latest
ON t.nutzer_id = latest.nutzer_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_quellen_aktuell AS
SELECT t.*
from tab_quellen t
INNER JOIN (
    SELECT quellen_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_quellen
    GROUP BY quellen_id
) latest
ON t.quellen_id = latest.quellen_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_themen_aktuell AS
SELECT t.*
from tab_themen t
INNER JOIN (
    SELECT themen_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_themen
    GROUP BY themen_id
) latest
ON t.themen_id = latest.themen_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_einheiten_aktuell AS
SELECT t.*
from tab_einheiten t
INNER JOIN (
    SELECT einheiten_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_einheiten
    GROUP BY einheiten_id
) latest
ON t.einheiten_id = latest.einheiten_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_laendernamen_aktuell AS
SELECT t.*
from tab_laendernamen t
INNER JOIN (
    SELECT laendernamen_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_laendernamen
    GROUP BY laendernamen_id
) latest
ON t.laendernamen_id = latest.laendernamen_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_kontinente_aktuell AS
SELECT t.*
from tab_kontinente t
INNER JOIN (
    SELECT kontinente_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_kontinente
    GROUP BY kontinente_id
) latest
ON t.kontinente_id = latest.kontinente_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_laendergruppen_aktuell AS
SELECT t.*
from tab_laendergruppen t
INNER JOIN (
    SELECT laendergruppen_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_laendergruppen
    GROUP BY laendergruppen_id
) latest
ON t.laendergruppen_id = latest.laendergruppen_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_lizenzen_aktuell AS
SELECT t.*
from tab_lizenzen t
INNER JOIN (
    SELECT lizenzen_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_lizenzen
    GROUP BY lizenzen_id
) latest
ON t.lizenzen_id = latest.lizenzen_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_metadaten_aktuell AS
SELECT t.*
from tab_metadaten t
INNER JOIN (
    SELECT metadaten_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_metadaten
    GROUP BY metadaten_id
) latest
ON t.metadaten_id = latest.metadaten_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_indikatoren_aktuell AS
SELECT t.*
from tab_indikatoren t
INNER JOIN (
    SELECT indikatoren_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_indikatoren
    GROUP BY indikatoren_id
) latest
ON t.indikatoren_id = latest.indikatoren_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_laender_aktuell AS
SELECT t.*
from tab_laender t
INNER JOIN (
    SELECT laender_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_laender
    GROUP BY laender_id
) latest
ON t.laender_id = latest.laender_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_daten_aktuell AS
SELECT t.*
from tab_daten t
INNER JOIN (
    SELECT daten_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_daten
    GROUP BY daten_id
) latest
ON t.daten_id = latest.daten_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_ugl_aktuell AS
SELECT t.*
from tab_ugl t
INNER JOIN (
    SELECT ugl_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_ugl
    GROUP BY ugl_id
) latest
ON t.ugl_id = latest.ugl_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_ugl_werte_aktuell AS
SELECT t.*
from tab_ugl_werte t
INNER JOIN (
    SELECT ugl_werte_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_ugl_werte
    GROUP BY ugl_werte_id
) latest
ON t.ugl_werte_id = latest.ugl_werte_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_ugl_zo_aktuell AS
SELECT t.*
from tab_ugl_zo t
INNER JOIN (
    SELECT ugl_zo_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_ugl_zo
    GROUP BY ugl_zo_id
) latest
ON t.ugl_zo_id = latest.ugl_zo_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_laendergruppen_zo_aktuell AS
SELECT t.*
from tab_laendergruppen_zo t
INNER JOIN (
    SELECT laendergruppen_zo_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_laendergruppen_zo
    GROUP BY laendergruppen_zo_id
) latest
ON t.laendergruppen_zo_id = latest.laendergruppen_zo_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_metadaten_zo_aktuell AS
SELECT t.*
from tab_metadaten_zo t
INNER JOIN (
    SELECT metadaten_zo_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_metadaten_zo
    GROUP BY metadaten_zo_id
) latest
ON t.metadaten_zo_id = latest.metadaten_zo_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_quellen_zo_aktuell AS
SELECT t.*
from tab_quellen_zo t
INNER JOIN (
    SELECT quellen_zo_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_quellen_zo
    GROUP BY quellen_zo_id
) latest
ON t.quellen_zo_id = latest.quellen_zo_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_downloadquellen_zo_aktuell AS
SELECT t.*
from tab_downloadquellen_zo t
INNER JOIN (
    SELECT downloadquellen_zo_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_downloadquellen_zo
    GROUP BY downloadquellen_zo_id
) latest
ON t.downloadquellen_zo_id = latest.downloadquellen_zo_id 
AND t.gueltig_seit = latest.max_gueltig_seit
WHERE t.ist_aktiv;

CREATE OR REPLACE VIEW view_nutzer_neue_id AS
SELECT
    COALESCE(MAX(nutzer_id), 0) + 1 AS neue_nutzer_id
FROM tab_nutzer
LIMIT 1;

CREATE OR REPLACE VIEW view_quellen_neue_id AS
SELECT
    COALESCE(MAX(quellen_id), 0) + 1 AS neue_quellen_id
FROM tab_quellen
LIMIT 1;

CREATE OR REPLACE VIEW view_themen_neue_id AS
SELECT
    COALESCE(MAX(themen_id), 0) + 1 AS neue_themen_id
FROM tab_themen
LIMIT 1;

CREATE OR REPLACE VIEW view_einheiten_neue_id AS
SELECT
    COALESCE(MAX(einheiten_id), 0) + 1 AS neue_einheiten_id
FROM tab_einheiten
LIMIT 1;

CREATE OR REPLACE VIEW view_laendernamen_neue_id AS
SELECT
    COALESCE(MAX(laendernamen_id), 0) + 1 AS neue_laendernamen_id
FROM tab_laendernamen
LIMIT 1;

CREATE OR REPLACE VIEW view_kontinente_neue_id AS
SELECT
    COALESCE(MAX(kontinente_id), 0) + 1 AS neue_kontinente_id
FROM tab_kontinente
LIMIT 1;

CREATE OR REPLACE VIEW view_laendergruppen_neue_id AS
SELECT
    COALESCE(MAX(laendergruppen_id), 0) + 1 AS neue_laendergruppen_id
FROM tab_laendergruppen
LIMIT 1;

CREATE OR REPLACE VIEW view_lizenzen_neue_id AS
SELECT
    COALESCE(MAX(lizenzen_id), 0) + 1 AS neue_lizenzen_id
FROM tab_lizenzen
LIMIT 1;

CREATE OR REPLACE VIEW view_metadaten_neue_id AS
SELECT
    COALESCE(MAX(metadaten_id), 0) + 1 AS neue_metadaten_id
FROM tab_metadaten
LIMIT 1;

CREATE OR REPLACE VIEW view_indikatoren_neue_id AS
SELECT
    COALESCE(MAX(indikatoren_id), 0) + 1 AS neue_indikatoren_id
FROM tab_indikatoren
LIMIT 1;

CREATE OR REPLACE VIEW view_laender_neue_id AS
SELECT
    COALESCE(MAX(laender_id), 0) + 1 AS neue_laender_id
FROM tab_laender
LIMIT 1;

CREATE OR REPLACE VIEW view_daten_neue_id AS
SELECT
    COALESCE(MAX(daten_id), 0) + 1 AS neue_daten_id
FROM tab_daten
LIMIT 1;

CREATE OR REPLACE VIEW view_ugl_neue_id AS
SELECT
    COALESCE(MAX(ugl_id), 0) + 1 AS neue_ugl_id
FROM tab_ugl
LIMIT 1;

CREATE OR REPLACE VIEW view_ugl_werte_neue_id AS
SELECT
    COALESCE(MAX(ugl_werte_id), 0) + 1 AS neue_ugl_werte_id
FROM tab_ugl_werte
LIMIT 1;

CREATE OR REPLACE VIEW view_ugl_zo_neue_id AS
SELECT
    COALESCE(MAX(ugl_zo_id), 0) + 1 AS neue_ugl_zo_id
FROM tab_ugl_zo
LIMIT 1;

CREATE OR REPLACE VIEW view_laendergruppen_zo_neue_id AS
SELECT
    COALESCE(MAX(laendergruppen_zo_id), 0) + 1 AS neue_laendergruppen_zo_id
FROM tab_laendergruppen_zo
LIMIT 1;

CREATE OR REPLACE VIEW view_metadaten_zo_neue_id AS
SELECT
    COALESCE(MAX(metadaten_zo_id), 0) + 1 AS neue_metadaten_zo_id
FROM tab_metadaten_zo
LIMIT 1;

CREATE OR REPLACE VIEW view_quellen_zo_neue_id AS
SELECT
    COALESCE(MAX(quellen_zo_id), 0) + 1 AS neue_quellen_zo_id
FROM tab_quellen_zo
LIMIT 1;

CREATE OR REPLACE VIEW view_downloadquellen_zo_neue_id AS
SELECT
    COALESCE(MAX(downloadquellen_zo_id), 0) + 1 AS neue_downloadquellen_zo_id
FROM tab_downloadquellen_zo
LIMIT 1;

DELIMITER $$

CREATE TRIGGER trg_nutzer_delete
BEFORE DELETE ON tab_nutzer
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_quellen_delete
BEFORE DELETE ON tab_quellen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_themen_delete
BEFORE DELETE ON tab_themen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_einheiten_delete
BEFORE DELETE ON tab_einheiten
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendernamen_delete
BEFORE DELETE ON tab_laendernamen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_kontinente_delete
BEFORE DELETE ON tab_kontinente
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendergruppen_delete
BEFORE DELETE ON tab_laendergruppen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_lizenzen_delete
BEFORE DELETE ON tab_lizenzen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_metadaten_delete
BEFORE DELETE ON tab_metadaten
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_indikatoren_delete
BEFORE DELETE ON tab_indikatoren
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laender_delete
BEFORE DELETE ON tab_laender
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_daten_delete
BEFORE DELETE ON tab_daten
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_delete
BEFORE DELETE ON tab_ugl
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_werte_delete
BEFORE DELETE ON tab_ugl_werte
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_zo_delete
BEFORE DELETE ON tab_ugl_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendergruppen_zo_delete
BEFORE DELETE ON tab_laendergruppen_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_metadaten_zo_delete
BEFORE DELETE ON tab_metadaten_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_quellen_zo_delete
BEFORE DELETE ON tab_quellen_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_downloadquellen_zo_delete
BEFORE DELETE ON tab_downloadquellen_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Loeschen (DELETE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_nutzer_update
BEFORE UPDATE ON tab_nutzer
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_quellen_update
BEFORE UPDATE ON tab_quellen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_themen_update
BEFORE UPDATE ON tab_themen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_einheiten_update
BEFORE UPDATE ON tab_einheiten
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendernamen_update
BEFORE UPDATE ON tab_laendernamen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_kontinente_update
BEFORE UPDATE ON tab_kontinente
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendergruppen_update
BEFORE UPDATE ON tab_laendergruppen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_lizenzen_update
BEFORE UPDATE ON tab_lizenzen
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_metadaten_update
BEFORE UPDATE ON tab_metadaten
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_indikatoren_update
BEFORE UPDATE ON tab_indikatoren
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laender_update
BEFORE UPDATE ON tab_laender
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_daten_update
BEFORE UPDATE ON tab_daten
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_update
BEFORE UPDATE ON tab_ugl
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_werte_update
BEFORE UPDATE ON tab_ugl_werte
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_zo_update
BEFORE UPDATE ON tab_ugl_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendergruppen_zo_update
BEFORE UPDATE ON tab_laendergruppen_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_metadaten_zo_update
BEFORE UPDATE ON tab_metadaten_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_quellen_zo_update
BEFORE UPDATE ON tab_quellen_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_downloadquellen_zo_update
BEFORE UPDATE ON tab_downloadquellen_zo
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Aktualisieren (UPDATE) von Eintraegen ist nicht erlaubt!';
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_nutzer_insert
BEFORE INSERT ON tab_nutzer
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_nutzer
        WHERE
             name = NEW.name
            AND nutzer_id <> NEW.nutzer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name ) in nutzer ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_quellen_insert
BEFORE INSERT ON tab_quellen
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_quellen
        WHERE
             name_de = NEW.name_de
            AND quellen_id <> NEW.quellen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_de ) in quellen ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_quellen
        WHERE
             name_en = NEW.name_en
            AND quellen_id <> NEW.quellen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_en ) in quellen ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_quellen
        WHERE
             name_kurz_de = NEW.name_kurz_de
            AND quellen_id <> NEW.quellen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_kurz_de ) in quellen ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_quellen
        WHERE
             name_kurz_en = NEW.name_kurz_en
            AND quellen_id <> NEW.quellen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_kurz_en ) in quellen ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_themen_insert
BEFORE INSERT ON tab_themen
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_themen
        WHERE
             name_de = NEW.name_de
            AND themen_id <> NEW.themen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_de ) in themen ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_themen
        WHERE
             name_en = NEW.name_en
            AND themen_id <> NEW.themen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_en ) in themen ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_einheiten_insert
BEFORE INSERT ON tab_einheiten
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_einheiten
        WHERE
             symbol_de = NEW.symbol_de
            AND einheiten_id <> NEW.einheiten_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( symbol_de ) in einheiten ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_einheiten
        WHERE
             symbol_en = NEW.symbol_en
            AND einheiten_id <> NEW.einheiten_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( symbol_en ) in einheiten ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendernamen_insert
BEFORE INSERT ON tab_laendernamen
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_laendernamen
        WHERE
             name = NEW.name
            AND laendernamen_id <> NEW.laendernamen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name ) in laendernamen ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_kontinente_insert
BEFORE INSERT ON tab_kontinente
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_kontinente
        WHERE
             name_de = NEW.name_de
            AND kontinente_id <> NEW.kontinente_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_de ) in kontinente ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_kontinente
        WHERE
             name_en = NEW.name_en
            AND kontinente_id <> NEW.kontinente_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_en ) in kontinente ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendergruppen_insert
BEFORE INSERT ON tab_laendergruppen
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_laendergruppen
        WHERE
             name_de = NEW.name_de
            AND laendergruppen_id <> NEW.laendergruppen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_de ) in laendergruppen ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_laendergruppen
        WHERE
             name_en = NEW.name_en
            AND laendergruppen_id <> NEW.laendergruppen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_en ) in laendergruppen ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_lizenzen_insert
BEFORE INSERT ON tab_lizenzen
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_lizenzen
        WHERE
             name = NEW.name
            AND lizenzen_id <> NEW.lizenzen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name ) in lizenzen ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_metadaten_insert
BEFORE INSERT ON tab_metadaten
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_metadaten
        WHERE
             kuerzel = NEW.kuerzel
            AND metadaten_id <> NEW.metadaten_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( kuerzel ) in metadaten ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_indikatoren_insert
BEFORE INSERT ON tab_indikatoren
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_indikatoren
        WHERE
             name_de = NEW.name_de
            AND indikatoren_id <> NEW.indikatoren_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_de ) in indikatoren ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_indikatoren
        WHERE
             name_en = NEW.name_en
            AND indikatoren_id <> NEW.indikatoren_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name_en ) in indikatoren ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laender_insert
BEFORE INSERT ON tab_laender
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_laender
        WHERE
             laendernamen_de_id = NEW.laendernamen_de_id
            AND laender_id <> NEW.laender_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( laendernamen_de_id ) in laender ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_laender
        WHERE
             laendernamen_en_id = NEW.laendernamen_en_id
            AND laender_id <> NEW.laender_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( laendernamen_en_id ) in laender ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_laender
        WHERE
             iso2 = NEW.iso2
            AND laender_id <> NEW.laender_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( iso2 ) in laender ist nicht erlaubt!';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM tab_laender
        WHERE
             iso3 = NEW.iso3
            AND laender_id <> NEW.laender_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( iso3 ) in laender ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_daten_insert
BEFORE INSERT ON tab_daten
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_daten
        WHERE
             laender_id = NEW.laender_id
            AND indikatoren_id = NEW.indikatoren_id
            AND daten_id <> NEW.daten_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( laender_id  indikatoren_id ) in daten ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_insert
BEFORE INSERT ON tab_ugl
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_ugl
        WHERE
             name = NEW.name
            AND ugl_id <> NEW.ugl_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( name ) in ugl ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_werte_insert
BEFORE INSERT ON tab_ugl_werte
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_ugl_zo_insert
BEFORE INSERT ON tab_ugl_zo
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_ugl_zo
        WHERE
             daten_id = NEW.daten_id
            AND untergliederungswerte_id = NEW.untergliederungswerte_id
            AND ugl_zo_id <> NEW.ugl_zo_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( daten_id  untergliederungswerte_id ) in ugl_zo ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_laendergruppen_zo_insert
BEFORE INSERT ON tab_laendergruppen_zo
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_laendergruppen_zo
        WHERE
             laender_id = NEW.laender_id
            AND laendergruppen_id = NEW.laendergruppen_id
            AND laendergruppen_zo_id <> NEW.laendergruppen_zo_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( laender_id  laendergruppen_id ) in laendergruppen_zo ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_metadaten_zo_insert
BEFORE INSERT ON tab_metadaten_zo
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_metadaten_zo
        WHERE
             daten_id = NEW.daten_id
            AND metadaten_id = NEW.metadaten_id
            AND metadaten_zo_id <> NEW.metadaten_zo_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( daten_id  metadaten_id ) in metadaten_zo ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_quellen_zo_insert
BEFORE INSERT ON tab_quellen_zo
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_quellen_zo
        WHERE
             daten_id = NEW.daten_id
            AND quellen_id = NEW.quellen_id
            AND quellen_zo_id <> NEW.quellen_zo_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( daten_id  quellen_id ) in quellen_zo ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_downloadquellen_zo_insert
BEFORE INSERT ON tab_downloadquellen_zo
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_downloadquellen_zo
        WHERE
             daten_id = NEW.daten_id
            AND quellen_id = NEW.quellen_id
            AND downloadquellen_zo_id <> NEW.downloadquellen_zo_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( daten_id  quellen_id ) in downloadquellen_zo ist nicht erlaubt!';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_current_nutzer()
BEGIN
    DECLARE v_current_username VARCHAR(256);
    DECLARE v_current_user_exists BOOL;
    DECLARE v_new_nutzer_id INTEGER;

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_current_user_exists = EXISTS (
        SELECT 1
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );
    
    IF NOT v_current_user_exists THEN
        SET v_new_nutzer_id = (
            SELECT neue_nutzer_id
            FROM view_nutzer_neue_id
        );

        CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
        TRUNCATE TABLE __insert_allowed__;
        INSERT INTO __insert_allowed__ VALUES(TRUE);

        INSERT INTO tab_nutzer(
            gueltig_seit,
            ist_aktiv,
            ersteller_nutzer_id,
            nutzer_id,
            name
        ) VALUES (
            CURRENT_TIMESTAMP(6),
            TRUE,
            v_new_nutzer_id,
            v_new_nutzer_id,
            v_current_username
        );

        TRUNCATE TABLE __insert_allowed__;

    END IF;
END$$

DELIMITER ;







































DELIMITER $$

CREATE PROCEDURE insert_into_nutzer(
    IN name_in VARCHAR(256),
    OUT new_nutzer_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_nutzer_id
        FROM view_nutzer_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_nutzer(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        nutzer_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_nutzer_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_quellen(
    IN name_de_in VARCHAR(256),
    IN name_en_in VARCHAR(256),
    IN name_kurz_de_in VARCHAR(16),
    IN name_kurz_en_in VARCHAR(16),
    IN url_in VARCHAR(512),
    OUT new_quellen_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_quellen_id
        FROM view_quellen_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_de_in,
        name_en_in,
        name_kurz_de_in,
        name_kurz_en_in,
        url_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_quellen_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_themen(
    IN name_de_in VARCHAR(64),
    IN name_en_in VARCHAR(64),
    IN farbe_r_in TINYINT UNSIGNED,
    IN farbe_g_in TINYINT UNSIGNED,
    IN farbe_b_in TINYINT UNSIGNED,
    OUT new_themen_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_themen_id
        FROM view_themen_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_de_in,
        name_en_in,
        farbe_r_in,
        farbe_g_in,
        farbe_b_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_themen_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_einheiten(
    IN faktor_in DOUBLE,
    IN symbol_de_in VARCHAR(64),
    IN symbol_en_in VARCHAR(64),
    IN basis_einheiten_in INTEGER,
    OUT new_einheiten_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_einheiten_id
        FROM view_einheiten_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_einheiten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id,
        einheiten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        faktor_in,
        symbol_de_in,
        symbol_en_in,
        basis_einheiten_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_einheiten_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_laendernamen(
    IN name_in VARCHAR(256),
    IN laender_in INTEGER,
    OUT new_laendernamen_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_laendernamen_id
        FROM view_laendernamen_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendernamen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        laender_id,
        laendernamen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_in,
        laender_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_laendernamen_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_kontinente(
    IN name_de_in VARCHAR(64),
    IN name_en_in VARCHAR(64),
    OUT new_kontinente_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_kontinente_id
        FROM view_kontinente_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_kontinente(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        kontinente_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_de_in,
        name_en_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_kontinente_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_laendergruppen(
    IN name_de_in VARCHAR(256),
    IN name_en_in VARCHAR(256),
    OUT new_laendergruppen_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_laendergruppen_id
        FROM view_laendergruppen_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        laendergruppen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_de_in,
        name_en_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_laendergruppen_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_lizenzen(
    IN name_in VARCHAR(64),
    IN url_in VARCHAR(512),
    IN extra_bedingungen_in BOOLEAN,
    OUT new_lizenzen_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_lizenzen_id
        FROM view_lizenzen_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_lizenzen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        url,
        extra_bedingungen,
        lizenzen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_in,
        url_in,
        extra_bedingungen_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_lizenzen_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_metadaten(
    IN kuerzel_in VARCHAR(8),
    IN bezeichnung_in VARCHAR(256),
    OUT new_metadaten_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_metadaten_id
        FROM view_metadaten_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        kuerzel,
        bezeichnung,
        metadaten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        kuerzel_in,
        bezeichnung_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_metadaten_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_indikatoren(
    IN faktor_in DOUBLE,
    IN dezimalstellen_in TINYINT UNSIGNED,
    IN name_de_in VARCHAR(256),
    IN name_en_in VARCHAR(256),
    IN beschreibung_de_in VARCHAR(4096),
    IN beschreibung_en_in VARCHAR(4096),
    IN quellen_indikatoren_id_in VARCHAR(128),
    IN themen_in INTEGER,
    IN einheiten_in INTEGER,
    OUT new_indikatoren_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_indikatoren_id
        FROM view_indikatoren_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        faktor_in,
        dezimalstellen_in,
        name_de_in,
        name_en_in,
        beschreibung_de_in,
        beschreibung_en_in,
        quellen_indikatoren_id_in,
        themen_in,
        einheiten_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_indikatoren_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_laender(
    IN iso2_in VARCHAR(2),
    IN iso3_in VARCHAR(3),
    IN kontinente_in INTEGER,
    IN laendernamen_de_in INTEGER,
    IN laendernamen_en_in INTEGER,
    OUT new_laender_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_laender_id
        FROM view_laender_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        iso2_in,
        iso3_in,
        kontinente_in,
        laendernamen_de_in,
        laendernamen_en_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_laender_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_daten(
    IN datum_in DATE,
    IN wert_in DOUBLE,
    IN berechnet_in BOOLEAN,
    IN laender_in INTEGER,
    IN indikatoren_in INTEGER,
    IN lizenzen_in INTEGER,
    IN quellen_in INTEGER,
    OUT new_daten_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_daten_id
        FROM view_daten_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        datum_in,
        wert_in,
        berechnet_in,
        laender_in,
        indikatoren_in,
        lizenzen_in,
        quellen_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_daten_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_ugl(
    IN name_in VARCHAR(64),
    OUT new_ugl_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_ugl_id
        FROM view_ugl_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        ugl_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_ugl_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_ugl_werte(
    IN name_in VARCHAR(64),
    IN untergliederungen_in INTEGER,
    IN laender_in INTEGER,
    OUT new_ugl_werte_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_ugl_werte_id
        FROM view_ugl_werte_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_werte(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        untergliederungen_id,
        laender_id,
        ugl_werte_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_in,
        untergliederungen_in,
        laender_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_ugl_werte_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_ugl_zo(
    IN untergliederungswerte_in INTEGER,
    IN daten_in INTEGER,
    OUT new_ugl_zo_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_ugl_zo_id
        FROM view_ugl_zo_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        untergliederungswerte_id,
        daten_id,
        ugl_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        untergliederungswerte_in,
        daten_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_ugl_zo_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_laendergruppen_zo(
    IN laender_in INTEGER,
    IN laendergruppen_in INTEGER,
    OUT new_laendergruppen_zo_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_laendergruppen_zo_id
        FROM view_laendergruppen_zo_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        laender_in,
        laendergruppen_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_laendergruppen_zo_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_metadaten_zo(
    IN daten_in INTEGER,
    IN metadaten_in INTEGER,
    OUT new_metadaten_zo_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_metadaten_zo_id
        FROM view_metadaten_zo_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        metadaten_id,
        metadaten_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        daten_in,
        metadaten_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_metadaten_zo_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_quellen_zo(
    IN daten_in INTEGER,
    IN quellen_in INTEGER,
    OUT new_quellen_zo_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_quellen_zo_id
        FROM view_quellen_zo_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        quellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        daten_in,
        quellen_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_quellen_zo_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_downloadquellen_zo(
    IN daten_in INTEGER,
    IN quellen_in INTEGER,
    OUT new_downloadquellen_zo_id_out INTEGER
)
BEGIN
    DECLARE v_new_id INTEGER;
    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);

    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    START TRANSACTION;

    SET v_new_id = (
        SELECT neue_downloadquellen_zo_id
        FROM view_downloadquellen_zo_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_downloadquellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        downloadquellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        daten_in,
        quellen_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_downloadquellen_zo_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_nutzer(
    IN nutzer_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name
    INTO
        v_name
    FROM view_nutzer_aktuell
    WHERE nutzer_id = nutzer_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_nutzer(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        nutzer_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name,
        nutzer_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_quellen(
    IN quellen_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_name_kurz_de VARCHAR(16);
    DECLARE v_name_kurz_en VARCHAR(16);
    DECLARE v_url VARCHAR(512);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url
    FROM view_quellen_aktuell
    WHERE quellen_id = quellen_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url,
        quellen_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_themen(
    IN themen_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);
    DECLARE v_farbe_r TINYINT UNSIGNED;
    DECLARE v_farbe_g TINYINT UNSIGNED;
    DECLARE v_farbe_b TINYINT UNSIGNED;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b
    INTO
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b
    FROM view_themen_aktuell
    WHERE themen_id = themen_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b,
        themen_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_einheiten(
    IN einheiten_id_to_delete INTEGER
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_symbol_de VARCHAR(64);
    DECLARE v_symbol_en VARCHAR(64);
    DECLARE v_basis_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id
    INTO
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten
    FROM view_einheiten_aktuell
    WHERE einheiten_id = einheiten_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_einheiten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id,
        einheiten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten,
        einheiten_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_laendernamen(
    IN laendernamen_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(256);
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        laender_id
    INTO
        v_name,
        v_laender
    FROM view_laendernamen_aktuell
    WHERE laendernamen_id = laendernamen_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendernamen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        laender_id,
        laendernamen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name,
        v_laender,
        laendernamen_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_kontinente(
    IN kontinente_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en
    INTO
        v_name_de,
        v_name_en
    FROM view_kontinente_aktuell
    WHERE kontinente_id = kontinente_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_kontinente(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        kontinente_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        kontinente_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_laendergruppen(
    IN laendergruppen_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en
    INTO
        v_name_de,
        v_name_en
    FROM view_laendergruppen_aktuell
    WHERE laendergruppen_id = laendergruppen_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        laendergruppen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        laendergruppen_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_lizenzen(
    IN lizenzen_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_url VARCHAR(512);
    DECLARE v_extra_bedingungen BOOLEAN;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        url,
        extra_bedingungen
    INTO
        v_name,
        v_url,
        v_extra_bedingungen
    FROM view_lizenzen_aktuell
    WHERE lizenzen_id = lizenzen_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_lizenzen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        url,
        extra_bedingungen,
        lizenzen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name,
        v_url,
        v_extra_bedingungen,
        lizenzen_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_metadaten(
    IN metadaten_id_to_delete INTEGER
)
BEGIN
    DECLARE v_kuerzel VARCHAR(8);
    DECLARE v_bezeichnung VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        kuerzel,
        bezeichnung
    INTO
        v_kuerzel,
        v_bezeichnung
    FROM view_metadaten_aktuell
    WHERE metadaten_id = metadaten_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        kuerzel,
        bezeichnung,
        metadaten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_kuerzel,
        v_bezeichnung,
        metadaten_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_indikatoren(
    IN indikatoren_id_to_delete INTEGER
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_laender(
    IN laender_id_to_delete INTEGER
)
BEGIN
    DECLARE v_iso2 VARCHAR(2);
    DECLARE v_iso3 VARCHAR(3);
    DECLARE v_kontinente INTEGER;
    DECLARE v_laendernamen_de INTEGER;
    DECLARE v_laendernamen_en INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id
    INTO
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en
    FROM view_laender_aktuell
    WHERE laender_id = laender_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en,
        laender_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_daten(
    IN daten_id_to_delete INTEGER
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen,
        daten_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_ugl(
    IN ugl_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(64);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name
    INTO
        v_name
    FROM view_ugl_aktuell
    WHERE ugl_id = ugl_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        ugl_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name,
        ugl_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_ugl_werte(
    IN ugl_werte_id_to_delete INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_untergliederungen INTEGER;
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        untergliederungen_id,
        laender_id
    INTO
        v_name,
        v_untergliederungen,
        v_laender
    FROM view_ugl_werte_aktuell
    WHERE ugl_werte_id = ugl_werte_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_werte(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        untergliederungen_id,
        laender_id,
        ugl_werte_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name,
        v_untergliederungen,
        v_laender,
        ugl_werte_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_ugl_zo(
    IN ugl_zo_id_to_delete INTEGER
)
BEGIN
    DECLARE v_untergliederungswerte INTEGER;
    DECLARE v_daten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        untergliederungswerte_id,
        daten_id
    INTO
        v_untergliederungswerte,
        v_daten
    FROM view_ugl_zo_aktuell
    WHERE ugl_zo_id = ugl_zo_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        untergliederungswerte_id,
        daten_id,
        ugl_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_untergliederungswerte,
        v_daten,
        ugl_zo_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_laendergruppen_zo(
    IN laendergruppen_zo_id_to_delete INTEGER
)
BEGIN
    DECLARE v_laender INTEGER;
    DECLARE v_laendergruppen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        laender_id,
        laendergruppen_id
    INTO
        v_laender,
        v_laendergruppen
    FROM view_laendergruppen_zo_aktuell
    WHERE laendergruppen_zo_id = laendergruppen_zo_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_laender,
        v_laendergruppen,
        laendergruppen_zo_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_metadaten_zo(
    IN metadaten_zo_id_to_delete INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_metadaten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        metadaten_id
    INTO
        v_daten,
        v_metadaten
    FROM view_metadaten_zo_aktuell
    WHERE metadaten_zo_id = metadaten_zo_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        metadaten_id,
        metadaten_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_daten,
        v_metadaten,
        metadaten_zo_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_quellen_zo(
    IN quellen_zo_id_to_delete INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        quellen_id
    INTO
        v_daten,
        v_quellen
    FROM view_quellen_zo_aktuell
    WHERE quellen_zo_id = quellen_zo_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        quellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_daten,
        v_quellen,
        quellen_zo_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_downloadquellen_zo(
    IN downloadquellen_zo_id_to_delete INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();
    
    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        quellen_id
    INTO
        v_daten,
        v_quellen
    FROM view_downloadquellen_zo_aktuell
    WHERE downloadquellen_zo_id = downloadquellen_zo_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_downloadquellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        downloadquellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_daten,
        v_quellen,
        downloadquellen_zo_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_nutzer_name(
    IN nutzer_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );


    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_nutzer(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        nutzer_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        nutzer_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_name_de(
    IN quellen_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_name_kurz_de VARCHAR(16);
    DECLARE v_name_kurz_en VARCHAR(16);
    DECLARE v_url VARCHAR(512);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url
    FROM view_quellen_aktuell
    WHERE quellen_id = quellen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url,
        quellen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_name_en(
    IN quellen_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_name_kurz_de VARCHAR(16);
    DECLARE v_name_kurz_en VARCHAR(16);
    DECLARE v_url VARCHAR(512);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url
    FROM view_quellen_aktuell
    WHERE quellen_id = quellen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        value_in,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url,
        quellen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_name_kurz_de(
    IN quellen_id_in INTEGER,
    IN value_in VARCHAR(16)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_name_kurz_de VARCHAR(16);
    DECLARE v_name_kurz_en VARCHAR(16);
    DECLARE v_url VARCHAR(512);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url
    FROM view_quellen_aktuell
    WHERE quellen_id = quellen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        value_in,
        v_name_kurz_en,
        v_url,
        quellen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_name_kurz_en(
    IN quellen_id_in INTEGER,
    IN value_in VARCHAR(16)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_name_kurz_de VARCHAR(16);
    DECLARE v_name_kurz_en VARCHAR(16);
    DECLARE v_url VARCHAR(512);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url
    FROM view_quellen_aktuell
    WHERE quellen_id = quellen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        value_in,
        v_url,
        quellen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_url(
    IN quellen_id_in INTEGER,
    IN value_in VARCHAR(512)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_name_kurz_de VARCHAR(16);
    DECLARE v_name_kurz_en VARCHAR(16);
    DECLARE v_url VARCHAR(512);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        v_url
    FROM view_quellen_aktuell
    WHERE quellen_id = quellen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        name_kurz_de,
        name_kurz_en,
        url,
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
        value_in,
        quellen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_themen_name_de(
    IN themen_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);
    DECLARE v_farbe_r TINYINT UNSIGNED;
    DECLARE v_farbe_g TINYINT UNSIGNED;
    DECLARE v_farbe_b TINYINT UNSIGNED;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b
    INTO
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b
    FROM view_themen_aktuell
    WHERE themen_id = themen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b,
        themen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_themen_name_en(
    IN themen_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);
    DECLARE v_farbe_r TINYINT UNSIGNED;
    DECLARE v_farbe_g TINYINT UNSIGNED;
    DECLARE v_farbe_b TINYINT UNSIGNED;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b
    INTO
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b
    FROM view_themen_aktuell
    WHERE themen_id = themen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        value_in,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b,
        themen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_themen_farbe_r(
    IN themen_id_in INTEGER,
    IN value_in TINYINT UNSIGNED
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);
    DECLARE v_farbe_r TINYINT UNSIGNED;
    DECLARE v_farbe_g TINYINT UNSIGNED;
    DECLARE v_farbe_b TINYINT UNSIGNED;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b
    INTO
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b
    FROM view_themen_aktuell
    WHERE themen_id = themen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        value_in,
        v_farbe_g,
        v_farbe_b,
        themen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_themen_farbe_g(
    IN themen_id_in INTEGER,
    IN value_in TINYINT UNSIGNED
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);
    DECLARE v_farbe_r TINYINT UNSIGNED;
    DECLARE v_farbe_g TINYINT UNSIGNED;
    DECLARE v_farbe_b TINYINT UNSIGNED;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b
    INTO
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b
    FROM view_themen_aktuell
    WHERE themen_id = themen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_farbe_r,
        value_in,
        v_farbe_b,
        themen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_themen_farbe_b(
    IN themen_id_in INTEGER,
    IN value_in TINYINT UNSIGNED
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);
    DECLARE v_farbe_r TINYINT UNSIGNED;
    DECLARE v_farbe_g TINYINT UNSIGNED;
    DECLARE v_farbe_b TINYINT UNSIGNED;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b
    INTO
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        v_farbe_b
    FROM view_themen_aktuell
    WHERE themen_id = themen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_themen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        farbe_r,
        farbe_g,
        farbe_b,
        themen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_farbe_r,
        v_farbe_g,
        value_in,
        themen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_einheiten_faktor(
    IN einheiten_id_in INTEGER,
    IN value_in DOUBLE
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_symbol_de VARCHAR(64);
    DECLARE v_symbol_en VARCHAR(64);
    DECLARE v_basis_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id
    INTO
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten
    FROM view_einheiten_aktuell
    WHERE einheiten_id = einheiten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_einheiten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id,
        einheiten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten,
        einheiten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_einheiten_symbol_de(
    IN einheiten_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_symbol_de VARCHAR(64);
    DECLARE v_symbol_en VARCHAR(64);
    DECLARE v_basis_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id
    INTO
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten
    FROM view_einheiten_aktuell
    WHERE einheiten_id = einheiten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_einheiten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id,
        einheiten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        value_in,
        v_symbol_en,
        v_basis_einheiten,
        einheiten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_einheiten_symbol_en(
    IN einheiten_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_symbol_de VARCHAR(64);
    DECLARE v_symbol_en VARCHAR(64);
    DECLARE v_basis_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id
    INTO
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten
    FROM view_einheiten_aktuell
    WHERE einheiten_id = einheiten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_einheiten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id,
        einheiten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_symbol_de,
        value_in,
        v_basis_einheiten,
        einheiten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_einheiten_basis_einheiten(
    IN einheiten_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_symbol_de VARCHAR(64);
    DECLARE v_symbol_en VARCHAR(64);
    DECLARE v_basis_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id
    INTO
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        v_basis_einheiten
    FROM view_einheiten_aktuell
    WHERE einheiten_id = einheiten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_einheiten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        symbol_de,
        symbol_en,
        basis_einheiten_id,
        einheiten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_symbol_de,
        v_symbol_en,
        value_in,
        einheiten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendernamen_name(
    IN laendernamen_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_name VARCHAR(256);
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        laender_id
    INTO
        v_name,
        v_laender
    FROM view_laendernamen_aktuell
    WHERE laendernamen_id = laendernamen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendernamen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        laender_id,
        laendernamen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_laender,
        laendernamen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendernamen_laender(
    IN laendernamen_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(256);
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        laender_id
    INTO
        v_name,
        v_laender
    FROM view_laendernamen_aktuell
    WHERE laendernamen_id = laendernamen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendernamen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        laender_id,
        laendernamen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name,
        value_in,
        laendernamen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_kontinente_name_de(
    IN kontinente_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en
    INTO
        v_name_de,
        v_name_en
    FROM view_kontinente_aktuell
    WHERE kontinente_id = kontinente_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_kontinente(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        kontinente_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_name_en,
        kontinente_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_kontinente_name_en(
    IN kontinente_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_name_de VARCHAR(64);
    DECLARE v_name_en VARCHAR(64);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en
    INTO
        v_name_de,
        v_name_en
    FROM view_kontinente_aktuell
    WHERE kontinente_id = kontinente_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_kontinente(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        kontinente_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        value_in,
        kontinente_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendergruppen_name_de(
    IN laendergruppen_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en
    INTO
        v_name_de,
        v_name_en
    FROM view_laendergruppen_aktuell
    WHERE laendergruppen_id = laendergruppen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        laendergruppen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_name_en,
        laendergruppen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendergruppen_name_en(
    IN laendergruppen_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name_de,
        name_en
    INTO
        v_name_de,
        v_name_en
    FROM view_laendergruppen_aktuell
    WHERE laendergruppen_id = laendergruppen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name_de,
        name_en,
        laendergruppen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        value_in,
        laendergruppen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_lizenzen_name(
    IN lizenzen_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_url VARCHAR(512);
    DECLARE v_extra_bedingungen BOOLEAN;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        url,
        extra_bedingungen
    INTO
        v_name,
        v_url,
        v_extra_bedingungen
    FROM view_lizenzen_aktuell
    WHERE lizenzen_id = lizenzen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_lizenzen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        url,
        extra_bedingungen,
        lizenzen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_url,
        v_extra_bedingungen,
        lizenzen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_lizenzen_url(
    IN lizenzen_id_in INTEGER,
    IN value_in VARCHAR(512)
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_url VARCHAR(512);
    DECLARE v_extra_bedingungen BOOLEAN;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        url,
        extra_bedingungen
    INTO
        v_name,
        v_url,
        v_extra_bedingungen
    FROM view_lizenzen_aktuell
    WHERE lizenzen_id = lizenzen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_lizenzen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        url,
        extra_bedingungen,
        lizenzen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name,
        value_in,
        v_extra_bedingungen,
        lizenzen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_lizenzen_extra_bedingungen(
    IN lizenzen_id_in INTEGER,
    IN value_in BOOLEAN
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_url VARCHAR(512);
    DECLARE v_extra_bedingungen BOOLEAN;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        url,
        extra_bedingungen
    INTO
        v_name,
        v_url,
        v_extra_bedingungen
    FROM view_lizenzen_aktuell
    WHERE lizenzen_id = lizenzen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_lizenzen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        url,
        extra_bedingungen,
        lizenzen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name,
        v_url,
        value_in,
        lizenzen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_metadaten_kuerzel(
    IN metadaten_id_in INTEGER,
    IN value_in VARCHAR(8)
)
BEGIN
    DECLARE v_kuerzel VARCHAR(8);
    DECLARE v_bezeichnung VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        kuerzel,
        bezeichnung
    INTO
        v_kuerzel,
        v_bezeichnung
    FROM view_metadaten_aktuell
    WHERE metadaten_id = metadaten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        kuerzel,
        bezeichnung,
        metadaten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_bezeichnung,
        metadaten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_metadaten_bezeichnung(
    IN metadaten_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_kuerzel VARCHAR(8);
    DECLARE v_bezeichnung VARCHAR(256);

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        kuerzel,
        bezeichnung
    INTO
        v_kuerzel,
        v_bezeichnung
    FROM view_metadaten_aktuell
    WHERE metadaten_id = metadaten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        kuerzel,
        bezeichnung,
        metadaten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_kuerzel,
        value_in,
        metadaten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_faktor(
    IN indikatoren_id_in INTEGER,
    IN value_in DOUBLE
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_dezimalstellen(
    IN indikatoren_id_in INTEGER,
    IN value_in TINYINT UNSIGNED
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        value_in,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_name_de(
    IN indikatoren_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        value_in,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_name_en(
    IN indikatoren_id_in INTEGER,
    IN value_in VARCHAR(256)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        value_in,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_beschreibung_de(
    IN indikatoren_id_in INTEGER,
    IN value_in VARCHAR(4096)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        value_in,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_beschreibung_en(
    IN indikatoren_id_in INTEGER,
    IN value_in VARCHAR(4096)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        value_in,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_quellen_indikatoren_id(
    IN indikatoren_id_in INTEGER,
    IN value_in VARCHAR(128)
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        value_in,
        v_themen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_themen(
    IN indikatoren_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        value_in,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_einheiten(
    IN indikatoren_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_faktor DOUBLE;
    DECLARE v_dezimalstellen TINYINT UNSIGNED;
    DECLARE v_name_de VARCHAR(256);
    DECLARE v_name_en VARCHAR(256);
    DECLARE v_beschreibung_de VARCHAR(4096);
    DECLARE v_beschreibung_en VARCHAR(4096);
    DECLARE v_quellen_indikatoren_id VARCHAR(128);
    DECLARE v_themen INTEGER;
    DECLARE v_einheiten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        v_einheiten
    FROM view_indikatoren_aktuell
    WHERE indikatoren_id = indikatoren_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_indikatoren(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        faktor,
        dezimalstellen,
        name_de,
        name_en,
        beschreibung_de,
        beschreibung_en,
        quellen_indikatoren_id,
        themen_id,
        einheiten_id,
        indikatoren_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_quellen_indikatoren_id,
        v_themen,
        value_in,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laender_iso2(
    IN laender_id_in INTEGER,
    IN value_in VARCHAR(2)
)
BEGIN
    DECLARE v_iso2 VARCHAR(2);
    DECLARE v_iso3 VARCHAR(3);
    DECLARE v_kontinente INTEGER;
    DECLARE v_laendernamen_de INTEGER;
    DECLARE v_laendernamen_en INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id
    INTO
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en
    FROM view_laender_aktuell
    WHERE laender_id = laender_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en,
        laender_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laender_iso3(
    IN laender_id_in INTEGER,
    IN value_in VARCHAR(3)
)
BEGIN
    DECLARE v_iso2 VARCHAR(2);
    DECLARE v_iso3 VARCHAR(3);
    DECLARE v_kontinente INTEGER;
    DECLARE v_laendernamen_de INTEGER;
    DECLARE v_laendernamen_en INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id
    INTO
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en
    FROM view_laender_aktuell
    WHERE laender_id = laender_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_iso2,
        value_in,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en,
        laender_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laender_kontinente(
    IN laender_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_iso2 VARCHAR(2);
    DECLARE v_iso3 VARCHAR(3);
    DECLARE v_kontinente INTEGER;
    DECLARE v_laendernamen_de INTEGER;
    DECLARE v_laendernamen_en INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id
    INTO
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en
    FROM view_laender_aktuell
    WHERE laender_id = laender_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_iso2,
        v_iso3,
        value_in,
        v_laendernamen_de,
        v_laendernamen_en,
        laender_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laender_laendernamen_de(
    IN laender_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_iso2 VARCHAR(2);
    DECLARE v_iso3 VARCHAR(3);
    DECLARE v_kontinente INTEGER;
    DECLARE v_laendernamen_de INTEGER;
    DECLARE v_laendernamen_en INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id
    INTO
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en
    FROM view_laender_aktuell
    WHERE laender_id = laender_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_iso2,
        v_iso3,
        v_kontinente,
        value_in,
        v_laendernamen_en,
        laender_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laender_laendernamen_en(
    IN laender_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_iso2 VARCHAR(2);
    DECLARE v_iso3 VARCHAR(3);
    DECLARE v_kontinente INTEGER;
    DECLARE v_laendernamen_de INTEGER;
    DECLARE v_laendernamen_en INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id
    INTO
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        v_laendernamen_en
    FROM view_laender_aktuell
    WHERE laender_id = laender_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laender(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        iso2,
        iso3,
        kontinente_id,
        laendernamen_de_id,
        laendernamen_en_id,
        laender_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_iso2,
        v_iso3,
        v_kontinente,
        v_laendernamen_de,
        value_in,
        laender_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_datum(
    IN daten_id_in INTEGER,
    IN value_in DATE
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_wert(
    IN daten_id_in INTEGER,
    IN value_in DOUBLE
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        value_in,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_berechnet(
    IN daten_id_in INTEGER,
    IN value_in BOOLEAN
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        value_in,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_laender(
    IN daten_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_berechnet,
        value_in,
        v_indikatoren,
        v_lizenzen,
        v_quellen,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_indikatoren(
    IN daten_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        value_in,
        v_lizenzen,
        v_quellen,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_lizenzen(
    IN daten_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        value_in,
        v_quellen,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_daten_quellen(
    IN daten_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_datum DATE;
    DECLARE v_wert DOUBLE;
    DECLARE v_berechnet BOOLEAN;
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;
    DECLARE v_lizenzen INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id
    INTO
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        v_quellen
    FROM view_daten_aktuell
    WHERE daten_id = daten_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_daten(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        datum,
        wert,
        berechnet,
        laender_id,
        indikatoren_id,
        lizenzen_id,
        quellen_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_berechnet,
        v_laender,
        v_indikatoren,
        v_lizenzen,
        value_in,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_ugl_name(
    IN ugl_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );


    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        ugl_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        ugl_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_ugl_werte_name(
    IN ugl_werte_id_in INTEGER,
    IN value_in VARCHAR(64)
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_untergliederungen INTEGER;
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        untergliederungen_id,
        laender_id
    INTO
        v_name,
        v_untergliederungen,
        v_laender
    FROM view_ugl_werte_aktuell
    WHERE ugl_werte_id = ugl_werte_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_werte(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        untergliederungen_id,
        laender_id,
        ugl_werte_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_untergliederungen,
        v_laender,
        ugl_werte_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_ugl_werte_untergliederungen(
    IN ugl_werte_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_untergliederungen INTEGER;
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        untergliederungen_id,
        laender_id
    INTO
        v_name,
        v_untergliederungen,
        v_laender
    FROM view_ugl_werte_aktuell
    WHERE ugl_werte_id = ugl_werte_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_werte(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        untergliederungen_id,
        laender_id,
        ugl_werte_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name,
        value_in,
        v_laender,
        ugl_werte_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_ugl_werte_laender(
    IN ugl_werte_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_name VARCHAR(64);
    DECLARE v_untergliederungen INTEGER;
    DECLARE v_laender INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        name,
        untergliederungen_id,
        laender_id
    INTO
        v_name,
        v_untergliederungen,
        v_laender
    FROM view_ugl_werte_aktuell
    WHERE ugl_werte_id = ugl_werte_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_werte(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        name,
        untergliederungen_id,
        laender_id,
        ugl_werte_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name,
        v_untergliederungen,
        value_in,
        ugl_werte_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_ugl_zo_untergliederungswerte(
    IN ugl_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_untergliederungswerte INTEGER;
    DECLARE v_daten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        untergliederungswerte_id,
        daten_id
    INTO
        v_untergliederungswerte,
        v_daten
    FROM view_ugl_zo_aktuell
    WHERE ugl_zo_id = ugl_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        untergliederungswerte_id,
        daten_id,
        ugl_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_daten,
        ugl_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_ugl_zo_daten(
    IN ugl_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_untergliederungswerte INTEGER;
    DECLARE v_daten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        untergliederungswerte_id,
        daten_id
    INTO
        v_untergliederungswerte,
        v_daten
    FROM view_ugl_zo_aktuell
    WHERE ugl_zo_id = ugl_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_ugl_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        untergliederungswerte_id,
        daten_id,
        ugl_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_untergliederungswerte,
        value_in,
        ugl_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendergruppen_zo_laender(
    IN laendergruppen_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_laender INTEGER;
    DECLARE v_laendergruppen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        laender_id,
        laendergruppen_id
    INTO
        v_laender,
        v_laendergruppen
    FROM view_laendergruppen_zo_aktuell
    WHERE laendergruppen_zo_id = laendergruppen_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_laendergruppen,
        laendergruppen_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendergruppen_zo_laendergruppen(
    IN laendergruppen_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_laender INTEGER;
    DECLARE v_laendergruppen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        laender_id,
        laendergruppen_id
    INTO
        v_laender,
        v_laendergruppen
    FROM view_laendergruppen_zo_aktuell
    WHERE laendergruppen_zo_id = laendergruppen_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_laender,
        value_in,
        laendergruppen_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_metadaten_zo_daten(
    IN metadaten_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_metadaten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        metadaten_id
    INTO
        v_daten,
        v_metadaten
    FROM view_metadaten_zo_aktuell
    WHERE metadaten_zo_id = metadaten_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        metadaten_id,
        metadaten_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_metadaten,
        metadaten_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_metadaten_zo_metadaten(
    IN metadaten_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_metadaten INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        metadaten_id
    INTO
        v_daten,
        v_metadaten
    FROM view_metadaten_zo_aktuell
    WHERE metadaten_zo_id = metadaten_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_metadaten_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        metadaten_id,
        metadaten_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_daten,
        value_in,
        metadaten_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_zo_daten(
    IN quellen_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        quellen_id
    INTO
        v_daten,
        v_quellen
    FROM view_quellen_zo_aktuell
    WHERE quellen_zo_id = quellen_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        quellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_quellen,
        quellen_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_quellen_zo_quellen(
    IN quellen_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        quellen_id
    INTO
        v_daten,
        v_quellen
    FROM view_quellen_zo_aktuell
    WHERE quellen_zo_id = quellen_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_quellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        quellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_daten,
        value_in,
        quellen_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_downloadquellen_zo_daten(
    IN downloadquellen_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        quellen_id
    INTO
        v_daten,
        v_quellen
    FROM view_downloadquellen_zo_aktuell
    WHERE downloadquellen_zo_id = downloadquellen_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_downloadquellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        downloadquellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_quellen,
        downloadquellen_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_downloadquellen_zo_quellen(
    IN downloadquellen_zo_id_in INTEGER,
    IN value_in INTEGER
)
BEGIN
    DECLARE v_daten INTEGER;
    DECLARE v_quellen INTEGER;

    DECLARE v_nutzer_id INTEGER;
    DECLARE v_current_username VARCHAR(256);
    
    CALL insert_current_nutzer();

    SET v_current_username = get_aktuellen_nutzer_namen();
    SET v_nutzer_id = (
        SELECT nutzer_id
        FROM view_nutzer_aktuell
        WHERE name = v_current_username
        LIMIT 1
    );

    SELECT 
        daten_id,
        quellen_id
    INTO
        v_daten,
        v_quellen
    FROM view_downloadquellen_zo_aktuell
    WHERE downloadquellen_zo_id = downloadquellen_zo_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_downloadquellen_zo(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        daten_id,
        quellen_id,
        downloadquellen_zo_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_daten,
        value_in,
        downloadquellen_zo_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;