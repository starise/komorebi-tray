# komorebi-tray

A tray app to manage komorebi tiling window manager for Windows. 

- Switch between custom AutoHotkey configuration profiles.

## How to start

Install komorebi following the official [Getting Started](https://lgug2z.github.io/komorebi/installation.html) documentation.

Set `KOMOREBI_CONFIG_HOME` in your `Microsoft.PowerShell_profile.ps1`.

```powershell
# Locate your PowerShell profile:
echo $PROFILE

# Edit your PowerShell profile:
ii $PROFILE
```

```powershell
# Microsoft.PowerShell_profile.ps1
$Env:KOMOREBI_CONFIG_HOME = "$($Env:USERPROFILE)\.config\komorebi"
```

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
