# Schritt-für-Schritt: Dein Python-Spielplatz

## LXC oder VM?

Für reines Python-Programmieren ist ein **LXC (Linux Container)** fast immer die bessere Wahl als eine volle VM:

| Feature | LXC (Empfehlung) | VM (Virtuelle Maschine) |
| :--- | :--- | :--- |
| **Ressourcen** | Extrem sparsam (braucht kaum RAM/CPU). | Höherer Overhead (eigenes OS-Kernel). |
| **Geschwindigkeit** | Startet in Sekunden. | Braucht länger zum Booten. |
| **Snapshots** | Blitzschnell (vor riskanten Änderungen). | Etwas langsamer. |
| **Einsatzzweck** | Perfekt für Skripte, Webserver, Tools. | Wenn du ein anderes OS (Windows) oder tiefe Kernel-Eingriffe brauchst. |

## 1. Container erstellen

Erstelle in Proxmox einen neuen LXC.

* Template: Wähle ein aktuelles debian-12-standard oder ubuntu-22.04-standard.
* Ressourcen: 1 Kern und 512 MB bis 1 GB RAM reichen für den Anfang völlig aus.
* Disk: 4 GB - 8 GB (Root-Disk klein halten, Daten lieber mounten)
* Netzwerk: Statische IP oder DHCP (merke dir die IP für VS Code!).
* Root-Passwort: Vergeben und SSH-Zugriff erlauben.
* Tipp: Nutze ein "Unprivileged Container" (unprivilegierter Container) für mehr Sicherheit. Das ist Standard in Proxmox und reicht für 99% der Python-Anwendungen völlig aus.

## 2. Die Grundausstattung (im LXC Terminal)

Sobald der Container läuft, konfiguriere ihn für Python:

```shell
# System aktualisieren
apt update && apt upgrade -y

# Python und Pip (Paketmanager) installieren
apt install -y python3 python3-pip python3-venv git

# Prüfen, ob alles da ist
python3 --version
```

## 3. Ein "Virtual Environment" (venv) erstellen

Das ist ein wichtiger Profi-Tipp: Installiere Python-Bibliotheken nie global im System, sondern immer in eine virtuelle Umgebung für dein jeweiliges Projekt.
```shell
# Ordner für dein Projekt erstellen
mkdir ~/passwort_projekt
cd ~/passwort_projekt

# Virtuelle Umgebung erstellen
python3 -m venv venv

# Umgebung aktivieren
source venv/bin/activate
```

*(Du erkennst, dass es aktiv ist, wenn vor deiner Eingabezeile ein `(venv)` steht.)*

## Verbindung mit VS Code

Jetzt kommt der Teil, den wir vorhin besprochen haben:
1. Öffne VS Code auf deinem Rechner
2. Nutze die Remote-SSH Erweiterung
3. Verbinde dich mit der IP deines neuen LXC (z.B. `ssh root@192.168.0.199`)
4. Öffne in VS Code den Ordner `/root/passwort_projekt`

**Vorteil:** Du schreibst den Code bequem unter Windows/macOS, aber er wird direkt im LXC auf Zion ausgeführt.


