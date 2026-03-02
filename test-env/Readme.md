## Installation von R, Shiny Server und RStudio Server auf dem Raspberry Pi

In diesem Ordner befinden sich drei Installationsskripte, die nacheinander ausgeführt werden sollten, um die benötigte Software auf einem Raspberry Pi zu installieren:

1. **install-r.sh**
	- Installiert die Programmiersprache R und die notwendigen Pakete.
2. **install-shiny-server.sh**
	- Installiert den Shiny Server, um interaktive Webanwendungen mit R bereitzustellen.
3. **install-rstudio-server.sh**
	- Installiert den RStudio Server für browserbasiertes Arbeiten mit R.

**Automatische Ausführung:**
Sie können alle drei Installationsschritte automatisch und in der richtigen Reihenfolge mit folgendem Skript ausführen:

```bash
sudo bash pipeline.sh
```

Das Skript führt nacheinander `install-r.sh`, `install-shiny-server.sh` und `install-rstudio-server.sh` aus. Alle Skripte werden mit administrativen Rechten ausgeführt.

_Quelle: [https://www.r-bloggers.com/2022/09/setting-up-your-own-shiny-and-rstudio-server-on-a-raspberry-pi/](https://www.r-bloggers.com/2022/09/setting-up-your-own-shiny-and-rstudio-server-on-a-raspberry-pi/)_
