# Das Automatisierungs-Skript: `add-ssh-key.sh`

Kopiere diesen Code in eine neue Datei auf Zion, zum Beispiel mit `nano ~/add-ssh-key.sh`:

```shell
#!/bin/bash

# Überprüfung der Parameter
if [ "$#" -ne 2 ]; then
    echo "Nutzung: $0 <LXC_ID> <PFAD_ZUM_PUBKEY>"
    echo "Beispiel: $0 105 /tmp/id_ed25519.pub"
    exit 1
fi

CTID=$1
PUBKEY_PATH=$2

# Prüfen, ob der Container existiert
if ! pct status $CTID > /dev/null 2>&1; then
    echo "Fehler: Container $CTID wurde nicht gefunden!"
    exit 1
fi

# Prüfen, ob die Key-Datei existiert
if [ ! -f "$PUBKEY_PATH" ]; then
    echo "Fehler: Public Key unter $PUBKEY_PATH nicht gefunden!"
    exit 1
fi

echo "Verarbeite Container $CTID..."

# 1. .ssh Verzeichnis im Container erstellen (falls nicht vorhanden)
pct exec $CTID -- mkdir -p /root/.ssh
pct exec $CTID -- chmod 700 /root/.ssh

# 2. Key in den Container schieben
# Wir nutzen 'cat' und 'pct exec', um den Key direkt anzuhängen
cat "$PUBKEY_PATH" | pct exec $CTID -- bash -c "cat >> /root/.ssh/authorized_keys"

# 3. Berechtigungen im Container setzen
pct exec $CTID -- chmod 600 /root/.ssh/authorized_keys
pct exec $CTID -- chown -R root:root /root/.ssh

echo "Erfolg: Der Key aus $PUBKEY_PATH wurde zu Container $CTID hinzugefügt."
```
## So nutzt du das Skript auf Zion
1. Skript ausführbar machen:
   ```shell
   chmod +x ~/add-ssh-key.sh
   ```
2. Public Key auf Zion bereitstellen: Kopiere deinen Public Key (den du auf deinem Windows-PC erstellt hast) einmalig nach Zion (z.B. nach `/tmp/micha_key.pub`).
3. Skript starten: Wenn du einen neuen Container mit der ID `105` erstellt hast, tippst du einfach:
   ```shell
   ./add-ssh-key.sh 105 /tmp/micha_key.pub
   ```

---
- `$#`: Prüft die Anzahl der übergebenen Argumente.
- `pct exec`: Erlaubt es dir, Befehle innerhalb eines Containers auszuführen, ohne dich per SSH einloggen zu müssen. Das ist das mächtigste Werkzeug für Proxmox-Admins.
- Pipes (`|`): Wir "pipen" den Inhalt der Key-Datei direkt in den `pct exec Befehl. Das ist effizienter, als die Datei erst mühsam zu kopieren.

   
