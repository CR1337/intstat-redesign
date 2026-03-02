# Verwende das offizielle MySQL 8.0.22 Image als Basis
FROM mysql:8.0.22

# Kopiere die benutzerdefinierte MySQL-Konfiguration
COPY container/my.cnf /etc/mysql/conf.d/

# Skript zum Erstellen der Datenbanken und Benutzer beim Start
COPY container/init.sql /docker-entrypoint-initdb.d/

# Belasse den Standard-Befehl, um MySQL zu starten
CMD ["mysqld"]
