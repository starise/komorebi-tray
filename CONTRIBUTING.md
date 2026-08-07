# Contributing

Windows, AutoHotkey v2, komorebi, `komorebic.exe` on `PATH`, and
`KOMOREBI_CONFIG_HOME` are required. Use a disposable config for startup or
profile work:

```powershell
$env:KOMOREBI_CONFIG_HOME = "$PWD\.local-test\komorebi"
AutoHotkey.exe .\komorebi-tray.ahk
```

Read the guide relevant to the change in [`docs/`](docs/README.md). Keep the
change focused; do not reformat `lib/JSON.ahk`.

```powershell
pnpm install
pnpm run setup
pnpm run build
```

WiX 7 is required for the optional MSI. The managed ahk-build provider installs
the pinned AutoHotkey and Ahk2Exe toolchain; `pnpm run genicons` remains the
consumer-owned icon generator.

There is no test suite: run relevant scripts and manual checks from
[`docs/TESTING.md`](docs/TESTING.md), then report what ran and what did not.
