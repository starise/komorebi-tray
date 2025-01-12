; komorebi-tray.ahk:
; A tray app for komorebi tiling window manager.
; Author: Andrea Brandi <git@andreabrandi.com>

;@Ahk2Exe-Let version=0.1.1
;@Ahk2Exe-SetVersion %U_version%
;@Ahk2Exe-SetProductVersion %U_version%
;@Ahk2Exe-SetName Komorebi Tray
;@Ahk2Exe-SetDescription Komorebi Tray
;@Ahk2Exe-SetCopyright Copyright (c) 2024`, Andrea Brandi
;@Ahk2Exe-SetLanguage 0x0409
;@Ahk2Exe-SetMainIcon ./images/ico/app.ico

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

#Include %A_ScriptDir%\lib\Komorebi.ahk
#Include %A_ScriptDir%\lib\KomorebiEvents.ahk
#Include %A_ScriptDir%\lib\KomorebiProfile.ahk
#Include %A_ScriptDir%\lib\KomorebiTray.ahk
#Include %A_ScriptDir%\lib\Settings.ahk

Startup() {
  if ( not Komorebi.CONFIG_HOME) {
    userChoice := MsgBox(
      Format("══ {:U} {:T} ══`n`n", "KOMOREBI_CONFIG_HOME", "is required")
      "Press [Continue] to read the documentation.`n", ,
      "CancelTryAgainContinue"
    )
    Switch userChoice {
      Case "Continue":
        Run("https://github.com/starise/komorebi-tray")
        ExitApp()
      Case "TryAgain":
        Reload()
      Default:
        ExitApp()
    }
  }

  if ( not FileExist(Komorebi.configJson)) {
    DirCreate(Komorebi.CONFIG_HOME)
    if (FileExist(Komorebi.userProfileJson)) {
      MsgBox(
        "Detected: " Komorebi.userProfileJson "`n`n" .
        "Moving to: " Komorebi.configJson
      )
      FileMove(Komorebi.userProfileJson, Komorebi.configJson)
    } else {
      MsgBox(
        "komorebi.json and applications.json not detected.`n`n" .
        "Downloading defaults to: " Komorebi.CONFIG_HOME
      )
      Komorebi.newConfigFiles()
    }
  }

  ; Add default profiles if they don't exist
  if ( not DirExist(KomorebiProfile.folder)) {
    MsgBox(
      Format("══ {:T} ══`n`n", "Profile folder not detected")
      "Creating new defaults to: " KomorebiProfile.folder
    )
    DirCopy(A_ScriptDir "\profiles", KomorebiProfile.folder)
  }

  ; Load all profiles from the folder
  profiles := KomorebiProfile.getAll()

  if (FileExist(Settings.configFile)) {
    KomorebiProfile.active := Settings.load("active", "profiles")
  } else {
    MsgBox(
      Format("══ {:T} ══`n`n", "Configuration file not detected")
      "Creating new defaults to: " Settings.configFile
    )
    KomorebiProfile.active := profiles[1]
    Settings.save(profiles[1], "active", "profiles")
  }

  KomorebiTray.create(profiles)
  KomorebiProfile.enable(KomorebiProfile.active)

  if ( not Komorebi.isRunning) {
    try {
      RunWait(("komorebic.exe"), , "Hide")
    }
    catch {
      MsgBox(
        "Komorebi not found.`n" .
        "Install it and try again."
      )
      ExitApp()
    }

    Komorebi.start()
  }

  KomorebiEvents.start()
}

TraySetIcon("images/ico/app.ico")
Startup()
