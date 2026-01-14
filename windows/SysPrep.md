Erstellen einer SysPrep

Vorbereitung des Referenzservers:

    Installieren Sie Windows Server 2022 und führen Sie alle notwendigen Updates durch.
    Installieren Sie gewünschte Anwendungen und nehmen Sie alle allgemeinen Konfigurationen vor.

Sysprep starten:

    Öffnen Sie die Eingabeaufforderung als Administrator (Rechtsklick auf CMD).
    Navigieren Sie zu C:\Windows\System32\Sysprep oder geben Sie direkt %SYSTEMROOT%\system32\sysprep\sysprep.exe ein und drücken Sie Enter.

Systemvorbereitung konfigurieren:

    Im Sysprep-Fenster wählen Sie unter Systembereinigungsaktion: OOBE (Out-of-Box Experience).
    Aktivieren Sie das Kontrollkästchen Verallgemeinern (Generalize). Dies entfernt system-spezifische Informationen wie die SID.
    Wählen Sie unter Herunterfahren-Optionen: Herunterfahren (Shutdown).
    Klicken Sie auf OK.

Warten auf Herunterfahren:

    Sysprep führt die Bereinigung durch und fährt den Server automatisch herunter. Starten Sie den Server nicht neu, wenn er sich ausgeschaltet hat.

Master-Image erstellen:

    Erstellen Sie ein Disk-Image (z. B. mit DISM oder Ihrer Imaging-Software) der Festplatte des Server-VMs.
    Dieses Image dient nun als Master-Vorlage für die Bereitstellung auf weiteren Servern. 
