# Contributing

Windows, AutoHotkey v2, komorebi, `komorebic.exe` on `PATH`, and
`KOMOREBI_CONFIG_HOME` are required. Use a disposable config for startup or
profile work:

```powershell
$env:KOMOREBI_CONFIG_HOME = "$PWD\.local-test\komorebi"
AutoHotkey64.exe .\komorebi-tray.ahk
```

Read the guide relevant to the change in [`docs/`](docs/README.md). Keep the
change focused; do not reformat `lib/JSON.ahk`.

```powershell
make compile
make build v=0.1.1
```

`make` expects Scoop AutoHotkey. Full packages also need Ahk2Exe, 7-Zip, WiX,
and PowerShell 7. Node/npm are only for `npm run genicons`.

There is no test suite: run relevant scripts and manual checks from
[`docs/TESTING.md`](docs/TESTING.md), then report what ran and what did not.
