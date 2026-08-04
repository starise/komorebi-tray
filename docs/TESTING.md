# Testing

There is no unified test command. Report scripts run, manual checks, and
untested paths. Use a disposable configuration for startup/profile work:

```powershell
$env:KOMOREBI_CONFIG_HOME = "$PWD\.local-test\komorebi"
AutoHotkey.exe .\komorebi-tray.ahk
```

## Scripts

| Change | Run | Also verify |
|---|---|---|
| Popup | `test/popup-test.ahk` | focus retention, placement/DPI, no AppStarting cursor |
| Pipe/events | `test/pipe-test.ahk` (requires komorebi) | external stop/restart reconnects; malformed/large events do not corrupt state |
| Settings | `test/settings-test.ahk` | expected key only changes |
| Theme/icons | `test/theme-test.ahk` | switch Windows light/dark mode and open the tray menu |

Run one script at a time:

```powershell
AutoHotkey64.exe .\test\popup-test.ahk
```

## By area

- Startup/profile: test with empty config; saved valid/invalid profile;
  profile switching; missing profile leaves the active process and settings
  unchanged.
- Tray: pause/resume label and icon, waiting state, tooltip, profile checkmark,
  and launch from a different working directory.
- Build: run the changed target. For release/package changes, inspect ZIP and
  install/uninstall the MSI independently.
- Icons: run `npm ci; npm run genicons`; verify generated tray icons exist.

For cross-cutting changes: start with empty config, switch workspace, pause and
resume, switch profile, then externally stop and restart komorebi.
