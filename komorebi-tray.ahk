#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

#Include %A_ScriptDir%\lib\Komorebi.ahk
#Include %A_ScriptDir%\lib\KomorebiProfile.ahk
#Include %A_ScriptDir%\lib\KomorebiTray.ahk

Startup() {
  if ( not Komorebi.CONFIG_HOME) {
    userChoice := MsgBox(
      "KOMOREBI_CONFIG_HOME is required.`n`n" .
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
    if (FileExist(Komorebi.userProfileJson)) {
      MsgBox(
        "Detected: " Komorebi.userProfileJson "`n`n" .
        "Moving to: " Komorebi.configJson
      )
      FileMove(Komorebi.userProfileJson, Komorebi.configJson)
    } else {
      MsgBox(
        "komorebi.json not detected.`n`n" .
        "Downloading defaults to: " Komorebi.configJson
      )
      Download(
        "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/docs/komorebi.example.json",
        Komorebi.configJson
      )
    }
  }

  profiles := KomorebiProfile.getAll()

  if ( not DirExist(KomorebiProfile.folder)) {
    MsgBox(
      "Profile folder not detected.`n`n" .
      "Creating new defaults to: " KomorebiProfile.folder
    )
    DirCopy(A_ScriptDir "\profiles", KomorebiProfile.folder)
  }

  if (FileExist(KomorebiProfile.stored)) {
    KomorebiProfile.active := FileRead(KomorebiProfile.stored)
  } else {
    KomorebiProfile.active := profiles[1]
    FileAppend(profiles[1], KomorebiProfile.stored)
  }

  KomorebiTray.generateMenu(profiles)
}

Startup()
