## 1. Schlüsselpaar auf deinem Windows-PC erstellen

Öffne die PowerShell oder CMD auf deinem Rechner und gib folgendes ein:

```powershell
ssh-keygen -t ed25519 -C "Name-des-Geräts"
```
* Bestätige den Speicherort einfach mit `Enter`.
* Passphrase: Du kannst ein Passwort für den Key vergeben (noch sicherer) oder einfach zweimal `Enter` drücken (bequemer).
* Kommentar-Flag, damit du später weißt, welcher Key zu welchem Gerät gehört

Dein PC hat nun zwei Dateien im Ordner `%userprofile%\.ssh\` erstellt:

* `id_ed25519` (Dein privater Schlüssel – geheim halten!)
* `id_ed25519.pub` (Dein öffentlicher Schlüssel – das "Schloss")

## 2. Den Public Key auf den LXC übertragen

Da du den Root-Login vorhin aktiviert hast, geht das jetzt ganz einfach von deinem Windows-PC aus:

```powershell
# Ersetze <IP-VOM-LXC> durch die echte IP
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh root@<IP-VOM-LXC> "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```
*(Unter Linux/Mac gäbe es dafür den Befehl ssh-copy-id, unter Windows nutzen wir diesen kleinen Einzeiler).*

## 3. Die Berechtigungen

SSH ist extrem pingelig. Wenn die Rechte nicht stimmen, lehnt Linux den Key aus Sicherheitsgründen ab. Prüfe im LXC (über die Proxmox-Konsole):

```shell
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## 4. Der Test

Wenn du jetzt in der PowerShell tippst: `ssh root@<IP-VOM-LXC>`, solltest du direkt eingeloggt sein, ohne nach dem Passwort gefragt zu werden.

## 5. Das System "härten"

Wenn der Key-Login funktioniert, kannst du das Passwort-Login komplett abschalten. Das ist der Moment, in dem dein LXC richtig sicher wird.

1. Wieder in die `/etc/ssh/sshd_config` im LXC gehen.
2. Folgende Werte setzen:
```
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```
3. SSH neu starten: `systemctl restart ssh`

**Achtung:** Ab jetzt kommst du per SSH NUR noch mit deinem Key rein. Verlierst du den Key, musst du über die Proxmox-Konsole gehen, um es zu reparieren.

#### Bonus für Proxmox

Du kannst bei der Erstellung eines neuen LXC in Proxmox direkt unter dem Reiter "General" deinen Public Key (den Inhalt der .pub Datei) reinkopieren. Dann ist der Container ab der ersten Sekunde perfekt abgesichert!














---
### Warum ausgerechnet Ed25519? (FISI-Wissen)

Früher war der Standard RSA. In deiner Ausbildung wirst du sicher noch über RSA-Schlüssel stolpern. Hier ist der Vergleich, warum man heute fast immer ed25519 wählt:

| Feature | RSA (der alte Standard) | Ed25519 (der moderne Standard) |
| :--- | :--- | :--- |
| **Sicherheit** | Braucht 3072 oder 4096 Bit, um sicher zu sein. | Viel sicherer bei viel kürzerer Schlüssellänge. |
| **Geschwindigkeit** | Das Generieren und Anmelden dauert messbar länger. | Extrem schnell beim Signieren und Verifizieren. |
| **Größe** | Der Key ist ein langer Textblock. | Der Key ist sehr kurz (ca. 68 Zeichen), was ihn handlicher macht. |
| **Kollisionen** | Anfälliger für theoretische Angriffe (wenn zu kurz). | Gilt aktuell als mathematisch extrem robust und sicher. |
