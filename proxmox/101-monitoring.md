## 1. Debian LXC


- Memory 2GiB
- Swap 512MiB
- Cores 2
- Root Disk 32GiB vm-storage-secure

```bash
apt update && apt upgrade -y
```

## 2. Vorbereitung & InfluxDB 2.x Installation

- ### Tools installieren
  ```bash
  apt install curl gpg
  ```

- ### InfluxDB Repository hinzufügen
  ```bash
  # Add the InfluxData key to verify downloads and add the repository

  curl --silent --location -O https://repos.influxdata.com/influxdata-archive.key

  gpg --show-keys --with-fingerprint --with-colons ./influxdata-archive.key 2>&1 | grep -q '^fpr:\+24C975CBA61A024EE1B631787C3D57159FC2F927:$' && cat influxdata-archive.key | gpg --dearmor | sudo tee /etc/apt/keyrings/influxdata-archive.gpg > /dev/null && echo 'deb [signed-by=/etc/apt/keyrings/influxdata-archive.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list
  ```

- ### Installation
  ```bash
  apt update && apt install -y influxdb2
  ```

- ### Start & Enable
  ```bash
  systemctl enable --now influxdb
  ```

- ### Status abfragen
  ```bash
  systemctl status influxdb
  ```

- ### Konfiguration
  ```bash
  influx setup
  ```

  | Eigenschaft | Wert |
  | :--- | :--- |
  | username | admin |
  | Password | ******** |
  | Organisation | mb-homelab |
  | Bucket | proxmox |

- ### Einloggen Web-UI

  `http://192.168.25.100:8086`

- ### Token generieren

  -> Load Data -> API Tokens -> `+ GENERATE API TOKEN` -> All Access API Token
  
  Description: Proxmox

  *generierten Token kopieren!!!*

- ### Metric Server Proxmox einrichten

  -> Datacenter -> Metric Server -> `Add` -> InfluxDB

  | Eigenschaft | Wert |
  | :--- | :--- |
  | Name | Monitoring |
  | Server | 192.168.25.100 |
  | Port | 8086 |
  | Protocol | HTTP |
  | Organisation | mb-homelab |
  | Bucket | proxmox |
  | Token | ********** |

  


  

  



  

