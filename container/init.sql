-- Erstelle die vier Datenbanken
CREATE DATABASE IF NOT EXISTS intstat2_wt;
CREATE DATABASE IF NOT EXISTS intstat2_wot;

-- Erstelle einen Benutzer mit Zugriff auf alle vier Datenbanken
CREATE USER IF NOT EXISTS 'user'@'%' IDENTIFIED BY 'password';

-- Gewähre dem Benutzer alle Rechte auf die Datenbanken
GRANT ALL PRIVILEGES ON intstat2_wt.* TO 'user'@'%';
GRANT ALL PRIVILEGES ON intstat2_wot.* TO 'user'@'%';

-- Aktualisiere die Berechtigungen
FLUSH PRIVILEGES;
