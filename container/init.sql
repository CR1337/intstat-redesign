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
    -- Diese Tabelle speichert alle Nutzer. Sie ist nur notwendig, wenn Nutzer Tracking angewandt wird.
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
    -- Hier werden die Quellen gespeichert, aus denen die Werte für die Indikatoren stammen.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,
    ersteller_nutzer_id INTEGER NOT NULL,
        
    quellen_id INTEGER NOT NULL,


    name_de VARCHAR(256) NOT NULL DEFAULT '',
    name_en VARCHAR(256) NOT NULL DEFAULT '',
    name_kurz_de VARCHAR(16) NOT NULL DEFAULT '',
    name_kurz_en VARCHAR(16) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (quellen_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_themen (
    -- Jedes Thema hat einen deutschen und einen englischen namen und eine Farbe.
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
    -- Enthält die Einheiten. eine Einheit hat ein Symbol und einen Beasiseinheit, in welche sie sich mittels ein es Faktors umrechnen lässt.
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
    -- Hier sind alle Ländernamen abgelegt. Ein Ländername ist einem Land zugeordnet.
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
    -- Jeder Kontinent hat einen deutschen und einen englischen Namen.
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
    -- Enthält Gruppen, zu welchen Länder gehören können, z.B. EU oder G7.
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

CREATE TABLE IF NOT EXISTS tab_indikatoren (
    -- Enthält alle Indikatoren. Jeder Indikator besizt ein Thema, eine Quelle und eine Einheit. Außerdem enthält er einen Faktor, welcher mit zugehörigen Werten multipliziert werden muss und eine Dezimalstellengenauigkeit. 
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,
    ersteller_nutzer_id INTEGER NOT NULL,
        
    indikatoren_id INTEGER NOT NULL,

    themen_id INTEGER NOT NULL,
    quellen_id INTEGER NOT NULL,
    einheiten_id INTEGER NOT NULL,

    faktor DOUBLE NOT NULL DEFAULT 0,
    dezimalstellen TINYINT UNSIGNED NOT NULL DEFAULT 0,
    name_de VARCHAR(256) NOT NULL DEFAULT '',
    name_en VARCHAR(256) NOT NULL DEFAULT '',
    beschreibung_de VARCHAR(4096) NOT NULL DEFAULT '',
    beschreibung_en VARCHAR(4096) NOT NULL DEFAULT '',

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (indikatoren_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_laender (
    -- Hier sind die Länder gespeichert. Ein Land hat ISO2- und ISO3-Kennungen. Ein Land kann mehrere Namen haben. Auf die Anzeigenamen verweisen die Fremndschlüssel eines Landes.
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
    -- Speichert die eigentlichen Datenwerte, die mit Ländern und Indikatoren verknüpft sind.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,
    ersteller_nutzer_id INTEGER NOT NULL,
        
    daten_id INTEGER NOT NULL,

    laender_id INTEGER NOT NULL,
    indikatoren_id INTEGER NOT NULL,

    datum DATE NOT NULL DEFAULT '2000-01-01',
    wert DOUBLE NOT NULL DEFAULT 0,

    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (daten_id, gueltig_seit)
);

CREATE TABLE IF NOT EXISTS tab_laendergruppenzuordnungen (
    -- Diese Tabelle ordnet Ländergruppen ihre Länder zu.
    gueltig_seit TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    ist_aktiv BOOL NOT NULL,
    ersteller_nutzer_id INTEGER NOT NULL,
        
    laendergruppenzuordnungen_id INTEGER NOT NULL,

    laender_id INTEGER NOT NULL,
    laendergruppen_id INTEGER NOT NULL,


    FOREIGN KEY (ersteller_nutzer_id)  -- erstellt von
        REFERENCES tab_nutzer(nutzer_id)
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    PRIMARY KEY (laendergruppenzuordnungen_id, gueltig_seit)
);

ALTER TABLE tab_einheiten
ADD CONSTRAINT fk_einheiten_einheiten_aea4754ddb0c48e4892f  --  hat Basiseinheit
FOREIGN KEY (basis_einheiten_id) REFERENCES tab_einheiten(einheiten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laendernamen
ADD CONSTRAINT fk_laendernamen_laender_a56edaa93ac0469a9de4  --  gehört zu Land
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_indikatoren
ADD CONSTRAINT fk_indikatoren_themen_c49be45157ee4df99c64  --  gehört zu Thema
FOREIGN KEY (themen_id) REFERENCES tab_themen(themen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_indikatoren
ADD CONSTRAINT fk_indikatoren_quellen_7329706296be43bd96e6  --  von Quelle
FOREIGN KEY (quellen_id) REFERENCES tab_quellen(quellen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_indikatoren
ADD CONSTRAINT fk_indikatoren_einheiten_3937d0f82abb472986a7  --  hat Einheit
FOREIGN KEY (einheiten_id) REFERENCES tab_einheiten(einheiten_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laender
ADD CONSTRAINT fk_laender_kontinente_554d9ba98bfe4211b5f1  --  gehört zu Kontinent
FOREIGN KEY (kontinente_id) REFERENCES tab_kontinente(kontinente_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laender
ADD CONSTRAINT fk_laender_laendernamen_05d12970e9284efb8cc6  --  hat dt. Namen
FOREIGN KEY (laendernamen_de_id) REFERENCES tab_laendernamen(laendernamen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laender
ADD CONSTRAINT fk_laender_laendernamen_36fbb926dbe742528ab9  --  hat en. Namen
FOREIGN KEY (laendernamen_en_id) REFERENCES tab_laendernamen(laendernamen_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_daten
ADD CONSTRAINT fk_daten_laender_5b768974c3584aa8a0dd  --  für Land
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_daten
ADD CONSTRAINT fk_daten_indikatoren_eae1b5ed5b0c451491c6  --  für Indikator
FOREIGN KEY (indikatoren_id) REFERENCES tab_indikatoren(indikatoren_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laendergruppenzuordnungen
ADD CONSTRAINT fk_laendergruppenzuordnungen_laender_9368291022f545abbc1c  --  ordnet Land zu
FOREIGN KEY (laender_id) REFERENCES tab_laender(laender_id)
    ON UPDATE RESTRICT
    ON DELETE RESTRICT;

ALTER TABLE tab_laendergruppenzuordnungen
ADD CONSTRAINT fk_laendergruppenzuordnungen_laendergruppen_a2b7d32d072c4171a11c  --  ordnet Länderguppe zu
FOREIGN KEY (laendergruppen_id) REFERENCES tab_laendergruppen(laendergruppen_id)
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
    

CREATE INDEX idx_laendergruppenzuordnungen_latest 
    ON tab_laendergruppenzuordnungen (
        laendergruppenzuordnungen_id, 
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

CREATE OR REPLACE VIEW view_laendergruppenzuordnungen_historie AS
SELECT *
FROM tab_laendergruppenzuordnungen
ORDER BY laendergruppenzuordnungen_id, gueltig_seit DESC;

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

CREATE OR REPLACE VIEW view_laendergruppenzuordnungen_aktuell AS
SELECT t.*
from tab_laendergruppenzuordnungen t
INNER JOIN (
    SELECT laendergruppenzuordnungen_id, MAX(gueltig_seit) AS max_gueltig_seit
    FROM tab_laendergruppenzuordnungen
    GROUP BY laendergruppenzuordnungen_id
) latest
ON t.laendergruppenzuordnungen_id = latest.laendergruppenzuordnungen_id 
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

CREATE OR REPLACE VIEW view_laendergruppenzuordnungen_neue_id AS
SELECT
    COALESCE(MAX(laendergruppenzuordnungen_id), 0) + 1 AS neue_laendergruppenzuordnungen_id
FROM tab_laendergruppenzuordnungen
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

CREATE TRIGGER trg_laendergruppenzuordnungen_delete
BEFORE DELETE ON tab_laendergruppenzuordnungen
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

CREATE TRIGGER trg_laendergruppenzuordnungen_update
BEFORE UPDATE ON tab_laendergruppenzuordnungen
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

CREATE TRIGGER trg_laendergruppenzuordnungen_insert
BEFORE INSERT ON tab_laendergruppenzuordnungen
FOR EACH ROW
BEGIN
    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    IF NOT EXISTS (SELECT 1 FROM __insert_allowed__) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) ist nur von der entsprechenden PROCEDURE aus erlaubt!';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM tab_laendergruppenzuordnungen
        WHERE
             laender_id = NEW.laender_id
            AND laendergruppen_id = NEW.laendergruppen_id
            AND laendergruppenzuordnungen_id <> NEW.laendergruppenzuordnungen_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Einfuegen (INSERT) von Duplikaten ( laender_id  laendergruppen_id ) in laendergruppenzuordnungen ist nicht erlaubt!';
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
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        name_de_in,
        name_en_in,
        name_kurz_de_in,
        name_kurz_en_in,
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

CREATE PROCEDURE insert_into_indikatoren(
    IN faktor_in DOUBLE,
    IN dezimalstellen_in TINYINT UNSIGNED,
    IN name_de_in VARCHAR(256),
    IN name_en_in VARCHAR(256),
    IN beschreibung_de_in VARCHAR(4096),
    IN beschreibung_en_in VARCHAR(4096),
    IN themen_in INTEGER,
    IN quellen_in INTEGER,
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
        themen_id,
        quellen_id,
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
        themen_in,
        quellen_in,
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
    IN laender_in INTEGER,
    IN indikatoren_in INTEGER,
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
        laender_id,
        indikatoren_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        datum_in,
        wert_in,
        laender_in,
        indikatoren_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_daten_id_out = v_new_id;
    
    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_laendergruppenzuordnungen(
    IN laender_in INTEGER,
    IN laendergruppen_in INTEGER,
    OUT new_laendergruppenzuordnungen_id_out INTEGER
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
        SELECT neue_laendergruppenzuordnungen_id
        FROM view_laendergruppenzuordnungen_neue_id
    );

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppenzuordnungen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppenzuordnungen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        laender_in,
        laendergruppen_in,
        v_new_id
    );

    TRUNCATE TABLE __insert_allowed__;

    SET new_laendergruppenzuordnungen_id_out = v_new_id;
    
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
        name_kurz_en
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en
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
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;

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
        laender_id,
        indikatoren_id
    INTO
        v_datum,
        v_wert,
        v_laender,
        v_indikatoren
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
        laender_id,
        indikatoren_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_laender,
        v_indikatoren,
        daten_id_to_delete
    );

    TRUNCATE TABLE __insert_allowed__;
   
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE delete_from_laendergruppenzuordnungen(
    IN laendergruppenzuordnungen_id_to_delete INTEGER
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
    FROM view_laendergruppenzuordnungen_aktuell
    WHERE laendergruppenzuordnungen_id = laendergruppenzuordnungen_id_to_delete;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppenzuordnungen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppenzuordnungen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        FALSE,
        v_nutzer_id,
        v_laender,
        v_laendergruppen,
        laendergruppenzuordnungen_id_to_delete
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
        name_kurz_en
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en
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
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en,
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
        name_kurz_en
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en
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
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        value_in,
        v_name_kurz_de,
        v_name_kurz_en,
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
        name_kurz_en
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en
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
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        value_in,
        v_name_kurz_en,
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
        name_kurz_en
    INTO
        v_name_de,
        v_name_en,
        v_name_kurz_de,
        v_name_kurz_en
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
        quellen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_name_de,
        v_name_en,
        v_name_kurz_de,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_quellen,
        v_einheiten,
        indikatoren_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_indikatoren_quellen(
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
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
    DECLARE v_themen INTEGER;
    DECLARE v_quellen INTEGER;
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
        themen_id,
        quellen_id,
        einheiten_id
    INTO
        v_faktor,
        v_dezimalstellen,
        v_name_de,
        v_name_en,
        v_beschreibung_de,
        v_beschreibung_en,
        v_themen,
        v_quellen,
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
        themen_id,
        quellen_id,
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
        v_themen,
        v_quellen,
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
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;

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
        laender_id,
        indikatoren_id
    INTO
        v_datum,
        v_wert,
        v_laender,
        v_indikatoren
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
        laender_id,
        indikatoren_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_wert,
        v_laender,
        v_indikatoren,
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
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;

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
        laender_id,
        indikatoren_id
    INTO
        v_datum,
        v_wert,
        v_laender,
        v_indikatoren
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
        laender_id,
        indikatoren_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        value_in,
        v_laender,
        v_indikatoren,
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
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;

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
        laender_id,
        indikatoren_id
    INTO
        v_datum,
        v_wert,
        v_laender,
        v_indikatoren
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
        laender_id,
        indikatoren_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        value_in,
        v_indikatoren,
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
    DECLARE v_laender INTEGER;
    DECLARE v_indikatoren INTEGER;

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
        laender_id,
        indikatoren_id
    INTO
        v_datum,
        v_wert,
        v_laender,
        v_indikatoren
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
        laender_id,
        indikatoren_id,
        daten_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_datum,
        v_wert,
        v_laender,
        value_in,
        daten_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendergruppenzuordnungen_laender(
    IN laendergruppenzuordnungen_id_in INTEGER,
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
    FROM view_laendergruppenzuordnungen_aktuell
    WHERE laendergruppenzuordnungen_id = laendergruppenzuordnungen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppenzuordnungen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppenzuordnungen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        value_in,
        v_laendergruppen,
        laendergruppenzuordnungen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE update_value_laendergruppenzuordnungen_laendergruppen(
    IN laendergruppenzuordnungen_id_in INTEGER,
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
    FROM view_laendergruppenzuordnungen_aktuell
    WHERE laendergruppenzuordnungen_id = laendergruppenzuordnungen_id_in;

    CREATE TEMPORARY TABLE IF NOT EXISTS __insert_allowed__ (is_allowed BOOLEAN);
    TRUNCATE TABLE __insert_allowed__;
    INSERT INTO __insert_allowed__ VALUES(TRUE);

    INSERT INTO tab_laendergruppenzuordnungen(
        gueltig_seit,
        ist_aktiv,
        ersteller_nutzer_id,
        laender_id,
        laendergruppen_id,
        laendergruppenzuordnungen_id
    ) VALUES (
        CURRENT_TIMESTAMP(6),
        TRUE,
        v_nutzer_id,
        v_laender,
        value_in,
        laendergruppenzuordnungen_id_in
    );

    TRUNCATE TABLE __insert_allowed__;
END$$

DELIMITER ;