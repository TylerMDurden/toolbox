## 1. In den Container einloggen

Da SSH ja noch nicht geht, musst du über die Proxmox-Weboberfläche gehen:

1. Wähle deinen LXC aus.
2. Klicke auf „Console“.
3. Logge dich dort als `root` ein.

## 2. Die SSH-Konfiguration anpassen

Die Einstellungen für den SSH-Dienst liegen in der Datei /etc/ssh/sshd_config.

1. Öffne die Datei mit dem Editor `nano`:
```shell
nano /etc/ssh/sshd_config
```
2. Suche die Zeile `#PermitRootLogin prohibit-password (oder ähnlich)`.
3. Ändere sie ab in:
```shell
PermitRootLogin yes
```
*Wichtig: Entferne das # am Anfang der Zeile, falls es da ist!*

4. Speichere mit `Strg + O`, bestätige mit `Enter` und beende mit `Strg + X`.

## 3. SSH-Dienst neu starten

Damit die Änderungen übernommen werden, musst du den Dienst neu laden:
```shell
systemctl restart ssh
```
---
#### Was bedeutet „prohibit-password“?

In der Ausbildung wirst du hören, dass `PermitRootLogin yes` (Login mit Passwort) im professionellen Umfeld kritisch gesehen wird.

* prohibit-password (Standard): Root darf sich einloggen, aber nur mit einem SSH-Key, niemals mit einem Passwort. Das schützt vor Brute-Force-Angriffen.
* yes: Root darf sich mit seinem normalen Passwort einloggen.

**Tipp für Zion:** Wenn dein Proxmox-Server nur in deinem Heimnetzwerk steht, ist `yes` völlig okay. Sobald ein Server aber im Internet steht (z.B. ein V-Server), solltest du immer auf SSH-Keys setzen.
