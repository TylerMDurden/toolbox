## 1. Installation auf deinem Hauptrechner

Lade dir VS Code für dein Betriebssystem (Windows oder Linux) herunter und installiere es:

https://code.visualstudio.com/

## 2. Die wichtigsten Erweiterungen (Extensions)

VS Code ist von Haus aus "nackt". Du brauchst Erweiterungen, um es für Python fit zu machen. Klicke links auf das Quadrat-Symbol (Extensions) oder drücke `Strg+Umschalt+X` und suche nach:

* Python (von Microsoft): Das absolute Must-have. Es bietet Syntax-Highlighting und IntelliSense (Vorschläge beim Tippen).
* German Language Pack: Falls du die Menüs lieber auf Deutsch hättest.
* Remote - SSH (von Microsoft): Das ist für dich besonders wichtig! Damit kannst du dich von VS Code aus direkt mit einer VM oder einem Container auf deinem Zion-Server verbinden. Du bearbeitest die Dateien auf dem Server, als lägen sie auf deinem PC.

## 3. Verbindung zu "Zion" (Remote-Arbeiten)

Da du Systemintegration lernst, ist das hier der "Pro-Way":

    Stelle sicher, dass in deiner Linux-VM auf Proxmox ein SSH-Server läuft (sudo apt install openssh-server).

    Klicke in VS Code unten links auf das kleine blaue Symbol (><) oder drücke F1 und gib Remote-SSH: Connect to Host... ein.

    Gib nutzername@ip-deines-servers ein.

    VS Code öffnet ein neues Fenster. Jetzt bist du "im" Server. Alles, was du speicherst, landet direkt auf Zion.
