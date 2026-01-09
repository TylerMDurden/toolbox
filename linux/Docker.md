# Docker sauber installieren

**dockerdocs:** https://docs.docker.com/engine/install/debian/

Installiere Docker nicht einfach über die Debian-Repos, sondern direkt über die Docker-Quellen, um immer die aktuellste Version für Immich zu haben:

```bash
# Repository-Schlüssel hinzufügen
sudo apt update
sudo apt install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL [https://download.docker.com/linux/debian/gpg](https://download.docker.com/linux/debian/gpg) | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Repository einbinden
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] [https://download.docker.com/linux/debian](https://download.docker.com/linux/debian) \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

------
### Docker Post-Installation (Optional)

Führe diese Schritte aus, um Docker als aktueller Benutzer ohne `sudo` verwenden zu können:

```bash
# Docker-Gruppe erstellen (falls noch nicht vorhanden)
sudo groupadd docker

# Den aktuellen Benutzer zur Docker-Gruppe hinzufügen
sudo usermod -aG docker $USER

# Gruppenänderungen ohne Logout/Login sofort anwenden
newgrp docker
```
### Docker Autostart aktivieren

Damit Docker und die Container-Runtime nach einem Systemneustart automatisch starten, müssen die entsprechenden Dienste aktiviert werden:

```bash
# Docker-Dienst aktivieren
sudo systemctl enable docker.service

# Containerd-Dienst aktivieren
sudo systemctl enable containerd.service
```
### Installation und Status überprüfen

Um sicherzustellen, dass Docker korrekt installiert wurde und die Dienste ordnungsgemäß laufen, kannst du folgende Befehle nutzen:

```bash
# Status des Docker-Dienstes prüfen
sudo systemctl status docker

# Installierte Docker-Version anzeigen
docker --version

# Test-Container ausführen, um die Funktionalität zu bestätigen
sudo docker run hello-world
```
### Docker Compose verifizieren

Da wir oben das `docker-compose-plugin` mit installiert haben, ist Docker Compose bereits als Plugin verfügbar. Du kannst dies mit folgendem Befehl prüfen:

```bash
# Version von Docker Compose anzeigen
docker compose version
```
### Docker Maintenance & Cleanup

Um dein System sauber zu halten und Speicherplatz freizugeben (z. B. von alten Images oder gestoppten Containern), kannst du folgende Befehle nutzen:

```bash
# Nicht genutzte Daten (Container, Netzwerke, Images ohne Tags) entfernen
docker system prune

# Zusätzlich auch alle nicht verwendeten Images löschen
docker system prune -a

# Nur ungenutzte Volumes löschen (Vorsicht: Daten in Volumes werden entfernt!)
docker volume prune
```
### Docker Logging & Fehlerdiagnose

Um zu verstehen, was innerhalb eines Containers passiert, sind die Logs die wichtigste Anlaufstelle:

```bash
# Die letzten Logs eines Containers anzeigen
docker logs <container_name_oder_id>

# Logs live mitverfolgen (Follow-Modus)
docker logs -f <container_name_oder_id>

# Die letzten 100 Zeilen anzeigen und live weiterverfolgen
docker logs --tail 100 -f <container_name_oder_id>

# Logs mit Zeitstempeln anzeigen
docker logs -t <container_name_oder_id>
```
### Docker Container & Images aktualisieren

Da Docker-Container "statisch" sind, erfolgt ein Update nicht innerhalb des Containers, sondern durch das Austauschen des Images gegen eine neuere Version:

```bash
# 1. In das Verzeichnis mit der docker-compose.yml wechseln
cd /pfad/zu/deinem/projekt

# 2. Die neuesten Image-Versionen herunterladen (Pull)
docker compose pull

# 3. Container neu erstellen und im Hintergrund starten
# (Docker erkennt automatisch, welche Images neuer sind und tauscht nur diese aus)
docker compose up -d

# 4. (Optional) Alte, ungenutzte Images nach dem Update entfernen
docker image prune -f
```
### Grafische Verwaltung mit Portainer

Portainer bietet eine benutzerfreundliche Weboberfläche, um Container, Images, Volumes und Netzwerke zu verwalten, ohne ständig die Kommandozeile nutzen zu müssen.

```bash
# Volume für Portainer-Daten erstellen
docker volume create portainer_data

# Portainer Community Edition (CE) starten
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/var/data \
  portainer/portainer-ce:latest
```
*Hinweis: Die Oberfläche ist danach unter `https://<deine-ip>:9443` erreichbar.*

---

### Automatische Updates mit Watchtower

Watchtower überwacht deine laufenden Docker-Container und aktualisiert sie automatisch, sobald ein neues Image im Repository (z. B. Docker Hub) verfügbar ist.

```bash
# Watchtower starten
docker run -d \
  --name watchtower \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower
```
***Konfigurations-Tipp:*** Wenn Watchtower nur die Container prüfen, aber nicht automatisch neu starten soll (nur Benachrichtigung oder manuelles Update), kann man das Intervall oder bestimmte Filter setzen. Standardmäßig prüft dieser Befehl alle 24 Stunden alle laufenden Container.

---

### Docker Networking: Bridge vs. Macvlan

Standardmäßig nutzt Docker das **Bridge-Netzwerk**. Wenn ein Container jedoch eine eigene IP-Adresse aus deinem "echten" Heimnetz (z. B. von der FritzBox) erhalten soll, nutzt man **Macvlan**.



#### 1. Eigenes Bridge-Netzwerk erstellen
Es ist Best Practice, für zusammengehörige Dienste ein eigenes Netzwerk zu erstellen, statt das Standard-Bridge-Netzwerk zu nutzen:
```bash
# Netzwerk erstellen
docker network create mein_projekt_netzwerk

# Container in diesem Netzwerk starten
docker run -d --name mein_container --network mein_projekt_netzwerk nginx
```

#### 2. Macvlan-Netzwerk (Container mit eigener IP im LAN)

*Hinweis: Dies ist nützlich für Dienste wie Pi-hole oder AdGuard Home.*

```bash
docker network create -d macvlan \
  --subnet=192.168.178.0/24 \
  --gateway=192.168.178.1 \
  --ip-range=192.168.178.200/29 \
  -o parent=eth0 \
  macvlan_net
```
*(Passe Subnetz, Gateway und das Interface parent an dein System an!)*

---

### Docker Security Hardening

Ein Standard-Docker-Setup ist oft "zu offen". Hier sind zwei wichtige Schritte, um den Host abzusichern.
#### 1. Log-Rotation begrenzen

Standardmäßig schreibt Docker unbegrenzt Logs, was die Festplatte füllen kann. Erstelle oder editiere die Datei /etc/docker/daemon.json:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```
*Danach den Dienst neu starten: `sudo systemctl restart docker`*

#### 2. Docker & UFW Firewall-Problem

Vorsicht: Docker umgeht standardmäßig die ufw-Regeln auf Debian/Ubuntu! Um das zu verhindern, kann man den Userland-Proxy deaktivieren oder spezielle Tools wie ufw-docker nutzen.

Einfacher erster Schritt in der `daemon.json:`

```json
{
  "iptables": true,
  "userland-proxy": false
}
```

#### 3. Container als Non-Root ausführen

Wann immer möglich, solltest du in Dockerfiles oder Compose-Files einen User definieren, damit der Prozess im Container nicht mit Root-Rechten des Hosts läuft:

```yaml
services:
  app:
    image: node:alpine
    user: "1000:1000"
```

---

### Backup

#### Backup-Strategie 1: Lokale Sicherung (Tar-Archiv)

Die einfachste Methode ist es, die Datenverzeichnisse der Container in ein komprimiertes Archiv zu packen.

```bash
# 1. Container stoppen (für Datenkonsistenz)
docker compose stop

# 2. Backup des gesamten Projektordners erstellen
# Ersetze 'mein_projekt' durch deinen Ordnernamen
tar -cvpzf backup_$(date +%Y%m%d).tar.gz /pfad/zu/deinem/projekt

# 3. Container wieder starten
docker compose start
````
