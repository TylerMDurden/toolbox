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
