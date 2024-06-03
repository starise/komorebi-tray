#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

global komorebiHome := EnvGet("KOMOREBI_CONFIG_HOME")
global komorebiJson := komorebiHome "\komorebi.json"
global komorebiConfig := komorebiHome "\komorebi.ahk"
global profileFolder := komorebiHome "\profiles"
global profileStored := komorebiHome "\profile.ini"
global activeProfile := ""

Komorebic(cmd) {
  RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

GetProfiles() {
  global profileFolder
  profiles := []

  Loop Files (profileFolder "\*.ahk") {
    fileName := StrSplit(A_LoopFilePath, "\").Pop()
    profiles.Push(fileName)
  }

  return profiles
}

EnableProfile(profile) {
  global profileFolder, komorebiConfig
  profilePath := profileFolder "\" profile

  FileCopy(profilePath, komorebiConfig, 1)
  Komorebic("reload-configuration")
}

; Generare il menu per selezionare gli script
GenerateMenu(profiles) {
  global activeProfile, profileStored
  TrayMenu := A_TrayMenu
  TrayMenu.Delete()
  profileMenu := Menu()

  for (profile in profiles) {
    profileMenu.Add(profile, ProfileMenuHandler)
  }

  TrayMenu.Add("Profiles", profileMenu)
  TrayMenu.Add("Reload", ReloadScript)
  TrayMenu.Add("Exit", ExitScript)

  profileMenu.ToggleCheck(activeProfile)

  ProfileMenuHandler(newProfile, pos, profileMenu) {
    global activeProfile, profileStored

    if (activeProfile != newProfile) {
      FileDelete(profileStored)
      FileAppend(newProfile, profileStored)
      profileMenu.ToggleCheck(activeProfile)
      profileMenu.ToggleCheck(newProfile)
      activeProfile := newProfile
    }

    EnableProfile(newProfile)
  }

  ReloadScript(Item, *) {
    Reload()
  }

  ExitScript(Item, *) {
    ExitApp()
  }
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
        Run "https://github.com/starise/komorebi-tray"
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
    DirCopy(A_ScriptDir . "\profiles", profileFolder)
  }

  global activeProfile
  if ( not FileExist(profileStored)) {
    activeProfile := profiles[1]
    FileAppend(activeProfile, profileStored)
  } else {
    activeProfile := FileRead(profileStored)
  }
  EnableProfile(activeProfile)

  GenerateMenu(profiles)
}

Startup(GetProfiles())
