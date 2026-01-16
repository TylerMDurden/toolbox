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
## Verschiedene Varianten den Key zu übertragen (Proxmox)

Oft ist der direkte SSH-Login für root gesperrt, bevor der Key hinterlegt wurde.

### Weg 1: Über die Proxmox Web-Konsole (Der einfachste Weg)

Dieser Weg funktioniert immer, solange du Zugriff auf die Proxmox-Weboberfläche hast.

1. Kopiere deinen Public Key auf deinem Windows-PC (Inhalt der `.pub`-Datei).
2. Gehe in Proxmox auf deinen LXC -> Console.
3. Logge dich dort als `root` mit dem Passwort ein, das du bei der Erstellung vergeben hast.
4. Gib folgenden Befehl ein (um die Datei zu öffnen):
   ```shell
   nano ~/.ssh/authorized_keys
   ```
*(Falls der Ordner nicht existiert: `mkdir -p ~/.ssh && chmod 700 ~/.ssh)`*

5. Füge den Key ein (Rechtsklick in der Proxmox-Konsole fügt oft direkt ein).
6. Speichern mit `Strg+O`, `Enter` und `Strg+X`.

### Weg 2: Über den Host "Zion" (Der FISI-Pro-Weg)

Da der LXC nur ein Verzeichnis auf deinem Host-System ist, kannst du den Key einfach von der Zion-Shell aus "hineinschieben". Das ist extrem elegant, weil du den Container dafür nicht mal starten musst.

1. Logge dich per SSH auf deinem Host Zion ein.
2. Nutze den Befehl `pct push`, um eine Datei vom Host in den Container zu kopieren:
   - Erstelle erst eine temporäre Datei auf Zion mit deinem Key.
   - Dann:
     ```shell
     # pct push <Container-ID> <Quelle-auf-Zion> <Ziel-im-LXC>
     pct push 100 /tmp/my_key.pub /root/.ssh/authorized_keys
     ```
3. Danach im LXC noch kurz die Rechte korrigieren (auch über Zion möglich):
   ```shell
   pct exec 100 -- chown root:root /root/.ssh/authorized_keys
   pct exec 100 -- chmod 600 /root/.ssh/authorized_keys
   ```

### Weg 3: Direktes Editieren des Filesystems (Tiefstes Linux-Wissen)

Da dein LXC auf Zion liegt (wahrscheinlich auf deinem ZFS-Pool oder der NVMe), ist sein Dateisystem unter `/var/lib/lxc/<ID>/rootfs/` gemountet, während er läuft (oder du kannst es mounten).

Du kannst auf Zion einfach dies tun:
```shell
nano /var/lib/lxc/100/rootfs/root/.ssh/authorized_keys
```
Hier fügst du den Key ein, speicherst, und fertig. Der LXC sieht die Änderung sofort.

---

#### Zusammenfassung für deine Unterlagen:
- Weg 1 ist super, wenn man schnell mal was ändern will.
- Weg 2 ist der sauberste Weg für Automatisierung und Skripte.
- Weg 3 zeigt dir, wie Container unter Linux wirklich funktionieren (sie sind nur isolierte Prozesse mit einem eigenen Ordner als "Wurzel").

**Wichtig:** Wenn du den Key übertragen hast, vergiss nicht, in der `/etc/ssh/sshd_config` des LXC zu prüfen, ob der Key-Login erlaubt ist (`PubkeyAuthentication yes`).



---
### Warum ausgerechnet Ed25519? (FISI-Wissen)

Früher war der Standard RSA. In deiner Ausbildung wirst du sicher noch über RSA-Schlüssel stolpern. Hier ist der Vergleich, warum man heute fast immer ed25519 wählt:

| Feature | RSA (der alte Standard) | Ed25519 (der moderne Standard) |
| :--- | :--- | :--- |
| **Sicherheit** | Braucht 3072 oder 4096 Bit, um sicher zu sein. | Viel sicherer bei viel kürzerer Schlüssellänge. |
| **Geschwindigkeit** | Das Generieren und Anmelden dauert messbar länger. | Extrem schnell beim Signieren und Verifizieren. |
| **Größe** | Der Key ist ein langer Textblock. | Der Key ist sehr kurz (ca. 68 Zeichen), was ihn handlicher macht. |
| **Kollisionen** | Anfälliger für theoretische Angriffe (wenn zu kurz). | Gilt aktuell als mathematisch extrem robust und sicher. |
