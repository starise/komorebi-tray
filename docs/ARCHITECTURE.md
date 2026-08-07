# Architecture

Komorebi Tray is a Windows AutoHotkey v2 tray app. It controls `komorebic.exe`,
listens to komorebi state through a named pipe, and switches user profiles.

## Ownership

| Area                      | Module                                        |
| ------------------------- | --------------------------------------------- |
| Startup                   | `komorebi-tray.ahk`                           |
| Commands and shared state | `lib/Komorebi.ahk`                            |
| Pipe and event parsing    | `lib/KomorebiEvents.ahk`, `lib/NamedPipe.ahk` |
| Profiles                  | `lib/KomorebiProfile.ahk`                     |
| Tray and popup            | `lib/KomorebiTray.ahk`, `lib/Popup.ahk`       |
| Settings                  | `lib/Settings.ahk`                            |

Keep work in its owner. `lib/JSON.ahk` is vendored: do not reformat it.

## Invariants

- Startup: validate config home, recover config/profiles, select and activate a
  profile, create the tray, start komorebi if needed, then listen for events.
  Profile activation must precede starting komorebi.
- Events: read and parse a complete state before changing shared state. A bad
  event must not leave mixed old/new display, workspace, or pause values.
- Reconnect: an external komorebi stop puts the tray in waiting state; restart
  reconnects without restarting the tray. Close old pipe handles first.
- Profiles: launch the selected file directly from `profiles/`, then persist
  the selection. Stop the previous profile before starting its replacement.
- Popup: keep one non-activating GUI/HWND. Update it with `SetWindowPos`; hide
  it by transparency/off-screen movement. Do not call `Gui.Show()`/`Gui.Hide()`
  for each message.
- Paths: bundled files use `A_ScriptDir`; user files use
  `KOMOREBI_CONFIG_HOME`, never the working directory.

Use `Komorebi.command()` for application `komorebic.exe` commands. Bundled
profiles are standalone user configuration and may have their own helper.
