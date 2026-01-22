# Proxmox „No valid subscription“ Meldung entfernen


In den Ordner wechseln:
```shell
cd /usr/share/javascript/proxmox-widget-toolkit/
```
Backup erstellen:
```shell
cp proxmoxlib.js proxmoxlib.js.backup
```
Datei editieren:
```shell
nano proxmoxlib.js
```
Textabschnitt suchen:

`Strg+F` „No vaild subscription“ `ENTER`

Gesucht wird dieser Abschnitt:
```shell
success: function (response, opts) {
let res = response.result;
if (
res === null ||
res === undefined ||
!res ||
res.data.status.toLowerCase() !== ‚active‘
) {
Ext.Msg.show({
title: gettext(‚No valid subscription‘),
icon: Ext.Msg.WARNING,
message: Proxmox.Utils.getNoSubKeyHtml(res.data.url),
buttons: Ext.Msg.OK,
callback: function (btn) {
if (btn !== ‚ok‘) {
return;
}
orig_cmd();
```
In der Zeile `res.data.status.toLowerCase() !== ‚active‘` das Ausrufezeichen `!` entfernen.

Ergebnis:
`res.data.status.toLowerCase() == ‚active‘`

`STRG+X` mit `Y` bestätigen und `ENTER`

Danach den Browsercache leeren und neu einloggen.

Getestet mit Proxmox 9.1.4
