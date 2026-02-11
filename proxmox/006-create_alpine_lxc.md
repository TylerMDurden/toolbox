# Anleitung: Proxmox LXC mit Alpine Linux (Grundeinrichtung)

Diese Anleitung beschreibt die Erstellung und Konfiguration eines **Alpine Linux** Containers in Proxmox VE. Alpine ist extrem ressourcenschonend und eignet sich perfekt für Dienste wie AdGuard Home.

---

## 1. Template herunterladen

Bevor der Container erstellt werden kann, muss das Alpine-Template geladen werden.

1.  Wähle in Proxmox deinen Speicher (z.B. `local` oder `local-lvm`).
2.  Gehe zu **CT Templates** -> **Templates**.
3.  Suche nach `alpine` (z.B. `alpine-3.23-default`).
4.  Klicke auf **Herunterladen**.

---

## 2. Container erstellen

Klicke oben rechts auf **"Erstelle CT"**.

### Reiter: Allgemein
*   **Hostname:** z.B. `adguard-alpine`
*   **Kennwort:** Root-Passwort setzen.
*   **Unprivileged:** `Häkchen gesetzt lassen` (Standard).

### Reiter: Template
*   Wähle das eben heruntergeladene **Alpine**-Template.

### Reiter: Disks
*   **Speicher:** 2 GB bis 4 GB reichen für Alpine völlig aus.

### Reiter: CPU
*   **Cores:** 1 Kern.

### Reiter: Speicher (RAM)
*   **Speicher:** 256 MB oder 512 MB (Alpine braucht im Leerlauf nur ca. 5 MB RAM!).
*   **Swap:** 512 MB.

### Reiter: Netzwerk
*   **IPv4:** Statisch (z.B. `192.168.178.50/24`).
*   **Gateway:** Router-IP (z.B. `192.168.178.1`).

> **Wichtig:** Merke dir die IP-Adresse für den späteren Zugriff.

---

## 3. Erste Schritte & Updates (Alpine Spezifisch)

Starte den Container und öffne die **Konsole**. Logge dich als `root` ein.

### A. Repository & System Update
Alpine nutzt den Paketmanager `apk`.

```bash
apk update && apk upgrade
```
### B. Komfort-Tools installieren

Alpine ist "nackt". Es gibt standardmäßig keinen `nano` Editor (nur `vi`) und kein `curl`. Wir installieren diese nach, da sie für die AdGuard-Installation benötigt werden.

```bash
apk add nano curl wget bash
```

### C. Zeitzone einstellen (Wichtig!)

Alpine ist standardmäßig auf UTC eingestellt. Für korrekte Logs und Zeitpläne muss die Zeitzone manuell eingerichtet werden (etwas anders als bei Debian).

1. Paket für Zeitzonen installieren:
   ```bash
   apk add tzdata
   ```
2. Zeitzone kopieren (Beispiel für Berlin/Deutschland):
   ```bash
   cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime
   echo "Europe/Berlin" > /etc/timezone
   ```
3. Überprüfen mit `date`.

## 4. SSH-Zugriff aktivieren

Standardmäßig erlaubt Alpine oft keinen Root-Login per Passwort über SSH.

1. Paket installieren:
   ```bash
   apk add openssh
   ```
2. Dienst zum Boot-Vorgang hinzufügen:
   ```bash
   rc-update add sshd default
   ```
3. Dienst manuell starten (falls er noch nicht läuft):
   ```bash
   rc-service sshd start
   ```
**Jetzt sollte der root Zugriff mittels  SSH-Key funktionieren!!!**
der Rest ist optional und dient der Information.
`PermitRootLogin yes` ist der "Quick & Dirty"-Weg.

- **Sicherer:** Nutze lieber `prohibit-password` statt `yes`. Dann kannst du dich nur mit einem SSH-Key einloggen, was deutlich sicherer gegen Brute-Force-Angriffe ist.
- Alternative: Wenn du gerade erst mit dem Container/der VM startest, kannst du bei Alpine auch einfach das Setup-Script nutzen: `setup-sshd`. Das erledigt die Installation und die grundlegende Konfiguration in einem Rutsch.

4. Datei bearbeiten:
   ```bash
   nano /etc/ssh/sshd_config
   ```
5. Suche die Zeile #PermitRootLogin ... und ändere sie zu:
   ```plain
   PermitRootLogin yes
   ```
6. Speichern (`STRG+O`, `Enter`) und Beenden (`STRG+X`).
7. SSH-Dienst neu starten:
   ```bash
   rc-service sshd restart
   ```

## 5. Vorbereitung für AdGuard Home

Da Alpine `musl` statt `glibc` nutzt, laufen manche Binaries nicht sofort. AdGuard Home ist jedoch in Go geschrieben und funktioniert meist direkt. Sollte es später Probleme bei der Namensauflösung geben, hilft oft dieser Trick, um sicherzustellen, dass der Container selbst DNS auflösen kann:

1. DNS-Resolver prüfen:
   ```bash
   nano /etc/resolv.conf
   ```
2. Stelle sicher, dass dort ein funktionierender Nameserver steht (z.B. dein Router oder Google):
   ```bash
   nameserver 8.8.8.8
   nameserver 1.1.1.1
   ```

## 6. Installation von AdGuard Home (Beispielbefehl)

Nun ist der Alpine-Container bereit. Du kannst AdGuard mit folgendem Befehl installieren:

```bash
curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v
```

## 7. Abschluss

1. **Snapshot erstellen:** Gehe in Proxmox auf den Container **-> Snapshots -> Erstellen** (Name: "Frisch Installiert").
2. **Webinterface aufrufen:** `http://<DEINE-IP>:3000`















