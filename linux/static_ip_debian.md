## Konfiguration statische IP - Debian 13 (Trixie)

### 1. Vorbereitung: Interface-Namen ermitteln
Bevor du startest, musst du wissen, wie dein Netzwerkinterface heißt (z. B. `eno1`, `enp3s0` oder `eth0`).
```shell
ip link
```

---

#### Methode A: Der Klassiker via `/etc/network/interfaces`

Nutzt das Paket `ifupdown` und ist die traditionelle Debian-Methode.

1. **Datei editieren:**
```shell
sudo nano /etc/network/interfaces
```
2. **Konfiguration anpassen:**
Suche dein Interface und ändere `dhcp` zu `static`. Füge dann deine Daten hinzu:
```plaintext
auto enp3s0
iface enp3s0 inet static
    address 192.168.178.50/24
    gateway 192.168.178.1
    dns-nameservers 192.168.178.1 8.8.8.8
```
3. **Netzwerk neu starten:**
```shell
sudo systemctl restart networking
```

---

#### Methode B: Modern via `systemd-networkd`

Das wird bei minimalen Debian-Installationen immer beliebter, ist sehr performant und benötigt kein zusätzliches Paket, da `systemd` ohnehin vorhanden ist.

> ⚠️ **Wichtig:** Nie beide Methoden gleichzeitig aktiv betreiben — `ifupdown` und `systemd-networkd` würden um die Interfaces konkurrieren und Race Conditions beim Boot verursachen.

##### Konfiguration

1. **Konfigurationsdatei erstellen:**

Dateien liegen in `/etc/systemd/network/` und enden auf `.network`.

```shell
sudo nano /etc/systemd/network/10-enp3s0.network
```

**Statische IP:**
```ini
[Match]
Name=enp3s0

[Network]
Address=192.168.178.50/24
Gateway=192.168.178.1
DNS=192.168.178.1
DNS=8.8.8.8
```

**DHCP (alternativ):**
```ini
[Match]
Name=enp3s0

[Network]
DHCP=yes
```

2. **DNS-Resolver verknüpfen:**
```shell
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

3. **Dienste aktivieren:**
```shell
sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved
```

##### Migration von Methode A zu Methode B

Die Reihenfolge ist dabei kritisch — erst Methode B vollständig konfigurieren, dann Methode A deaktivieren:

```shell
# 1. Konfigurationsdatei erstellen (s.o.)

# 2. DNS-Symlink setzen (s.o.)

# 3. systemd-networkd aktivieren (s.o.)

# 4. ERST JETZT ifupdown deaktivieren
sudo systemctl disable --now networking.service

# 5. /etc/network/interfaces bereinigen
sudo nano /etc/network/interfaces
```

Minimaler Inhalt der `/etc/network/interfaces` danach:
```plaintext
auto lo
iface lo inet loopback
```

##### Status prüfen

```shell
networkctl status          # Übersicht aller Interfaces
networkctl status enp3s0   # Details zur Schnittstelle
resolvectl status          # DNS-Auflösung prüfen
```

---

#### Welche Methode wählen?

| Kriterium | Methode A (`ifupdown`) | Methode B (`systemd-networkd`) |
|---|---|---|
| Zusatzpaket nötig | Ja (`ifupdown`) | Nein |
| Minimale Installationen | Oft nicht vorinstalliert | Immer verfügbar |
| Debugging | `ifup`/`ifdown` | `networkctl`, `journalctl` |
| Hook-Skripte | Direkt via `pre-up`/`post-up` | Über `networkd-dispatcher` |
| Zukunftssicherheit | Klassisch, stabil | Moderner Standard |

**Empfehlung:** Für neue Debian-13-Installationen → Methode B. Für bestehende Systeme mit komplexen Hook-Skripten → Methode A beibehalten.

> ℹ️ **Hinweis für Proxmox-Nutzer:** Der Proxmox-Host selbst verwendet `ifupdown2` (kein Wechsel auf `systemd-networkd` vornehmen!). Für Debian-Gast-VMs ist Methode B jedoch die empfohlene Wahl.

---

### 2. DNS-Konfiguration (wichtig!)

#### Methode A
Falls du die DNS-Server nicht direkt in der Interface-Datei festlegst, musst du die `/etc/resolv.conf` prüfen:
```shell
sudo nano /etc/resolv.conf
```
Dort sollte stehen:
```plaintext
nameserver 192.168.178.1
```

#### Methode B
Bei `systemd-networkd` wird DNS über `systemd-resolved` verwaltet. Der Symlink stellt sicher, dass `/etc/resolv.conf` auf den Stub-Resolver zeigt:
```shell
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

---

### 3. Überprüfung
Ob alles geklappt hat, siehst du mit diesen Befehlen:
- IP prüfen: `ip a`
- Route prüfen: `ip r` (Hier sollte dein Gateway als `default` stehen)
- Ping-Test: `ping -c 3 google.com`
