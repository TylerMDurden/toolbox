### Beispielbefehl zur Erstellung eines Debian-LXC

```shell
pct create 110 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname python-dev \
  --storage local-lvm \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp,firewall=1 \
  --ssh-public-keys /tmp/micha_key.pub \
  --unprivileged 1 \
  --memory 512 \
  --cores 1
```
#### Was der Befehl genau macht

| Parameter | Bedeutung |
| :--- | :--- |
| `pct create 110` | Erstellt einen Container mit der **ID 110**. |
| `local:vztmpl/...` | Nutzt das **Debian 12 Template**, das unter "local" gespeichert ist. |
| `--hostname python-dev` | Der Container bekommt den Netzwerknamen `python-dev`. |
| `--storage local-lvm` | Das Root-Dateisystem wird auf dem Speicher `local-lvm` abgelegt. |
| `--net0 ...` | Konfiguriert das Netzwerk: Karte `eth0`, Bridge `vmbr0`, IP via **DHCP** und Firewall aktiv. |
| `--ssh-public-keys ...` | Kopiert deinen SSH-Key (`micha_key.pub`), damit du dich später ohne Passwort anmelden kannst. |
| `--unprivileged 1` | **Wichtig für die Sicherheit:** Der Container läuft unprivilegiert (erhöhter Schutz für den Host). |
| `--memory 512` | Weist dem Container **512 MB RAM** zu. |
| `--cores 1` | Der Container darf **einen CPU-Kern** nutzen. |

#### Tipps
1. **Zusätzlicher Speicher:** In dem Befehl oben fehlt die Angabe der Festplattengröße. Standardmäßig nimmt Proxmox meist 4GB oder den Wert aus dem Template. Du kannst mit `--rootfs local-lvm:8` explizit z.B. 8 GB zuweisen.
2. **Automatisches Starten:** Wenn der Container nach dem Erstellen direkt hochfahren soll, hänge einfach `--start 1` an das Ende des Befehls an.

