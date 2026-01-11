## Konfiguration statische IP - Debian 13 (Trixie)

### 1. Vorbereitung: Interface-Namen ermitteln
Bevor du startest, musst du wissen, wie dein Netzwerkinterface heißt (z. B. `eno1`, `enp3s0` oder `eth0`).
```shell
ip link
```

---

#### Methode A: Der Klassiker via `/etc/network/interfaces`

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
Das wird bei minimalen Debian-Installationen immer beliebter und ist sehr performant.

---

### 2. DNS-Konfiguration (wichtig!)
Falls du die DNS-Server nicht direkt in der Interface-Datei festlegst, musst du die `/etc/resolv.conf` prüfen:
```shell
sudo nano /etc/resolv.conf
```
Dort sollte stehen:
```plaintext
nameserver 192.168.178.1
```

---

### 3. Überprüfung
Ob alles geklappt hat, siehst du mit diesen Befehlen:
- IP prüfen: `ip a`
- Route prüfen: `ip r` (Hier sollte dein Gateway als `default` stehen)
- Ping-Test: `ping -c 3 google.com`
