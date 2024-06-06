#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

#Include %A_ScriptDir%\lib\Komorebi.ahk

global komorebiHome := EnvGet("KOMOREBI_CONFIG_HOME")
global komorebiJson := komorebiHome "\komorebi.json"
global komorebiConfig := komorebiHome "\komorebi.ahk"
global profileFolder := komorebiHome "\profiles"
global profileStored := komorebiHome "\profile.ini"
global activeProfile := ""

GetProfiles() {
  profiles := []

  Loop Files (profileFolder "\*.ahk") {
    fileName := StrSplit(A_LoopFilePath, "\").Pop()
    profiles.Push(fileName)
  }

  return profiles
}

EnableProfile(profile) {
  global activeProfile

  if (activeProfile != profile) {
    profileMenu.Uncheck(activeProfile)
    profileMenu.Check(profile)
    FileDelete(profileStored)
    FileAppend(profile, profileStored)

    ; Overwrite main komorebi.ahk and reload configuration
    FileCopy(profileFolder "\" profile, komorebiConfig, 1)
    Komorebi.command("reload-configuration")

    activeProfile := profile
  }
}

GenerateMenu(profiles) {
  global profileMenu := Menu()
  TrayMenu := A_TrayMenu
  TrayMenu.Delete()

  for (profile in profiles) {
    profileMenu.Add(profile, ProfileMenuHandler)
  }
  profileMenu.Check(activeProfile)

  TrayMenu.Add("Profiles", profileMenu)
  TrayMenu.Add("Reload", ReloadScript)
  TrayMenu.Add("Exit", ExitScript)
}

ProfileMenuHandler(profile, *) {
  EnableProfile(profile)
}

ReloadScript(Item, *) {
  Reload()
}

ExitScript(Item, *) {
  ExitApp()
}

Startup(profiles) {
  if ( not komorebiHome) {
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

  if ( not FileExist(komorebiJson)) {
    userProfileJson := EnvGet("USERPROFILE") "\komorebi.json"
    if (FileExist(userProfileJson)) {
      MsgBox(
        "Detected: " userProfileJson "`n`n" .
        "Moving to: " komorebiJson
      )
      FileMove(userProfileJson, komorebiHome)
    } else {
      MsgBox(
        "komorebi.json not detected.`n`n" .
        "Downloading defaults to: " komorebiJson
      )
      Download(
        "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/docs/komorebi.example.json",
        komorebiHome "\komorebi.json"
      )
    }
  }

  if ( not DirExist(profileFolder)) {
    MsgBox(
      "Profile folder not detected.`n`n" .
      "Creating new defaults to: " profileFolder
    )
    DirCopy(A_ScriptDir "\profiles", profileFolder)
  }

  global activeProfile
  if (FileExist(profileStored)) {
    activeProfile := FileRead(profileStored)
  } else {
    activeProfile := profiles[1]
    FileAppend(profiles[1], profileStored)
  }

  GenerateMenu(profiles)
  EnableProfile(activeProfile)
}

Startup(GetProfiles())
