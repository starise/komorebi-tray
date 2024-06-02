# komorebi-tray

A tray app to manage komorebi tiling window manager for Windows. 

- Switch between custom AutoHotkey configuration profiles.

## AutoHotkey configuration profiles

Add custom `*.ahk` scripts into the `profiles\` folder.

```autohotkey
#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

Komorebic(cmd) {
  RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

; Custom hotkeys below
...
```

Load new added scripts: `Right click -> Reload`.

Enable your profiles using the app's tray icon: `Right click -> Profiles -> profile.ahk`.
