#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

global komorebiConfig := EnvGet("KOMOREBI_CONFIG_HOME") "\komorebi.ahk"
global profileFolder := A_ScriptDir "\profiles"
global profileStored := A_ScriptDir "\profile.ini"
global activeProfile := ""

Komorebic(cmd) {
  RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

GetProfiles() {
  global profileFolder
  profiles := []

  Loop Files, profileFolder "\*.ahk" {
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

  if (activeProfile == "") {
    if (FileExist(profileStored)) {
      activeProfile := FileRead(profileStored)
    } else {
      activeProfile := profiles[1]
      FileAppend(activeProfile, profileStored)
    }
  }

  EnableProfile(activeProfile)
  profileMenu.ToggleCheck(activeProfile)  
  TrayMenu.Add("Profiles", profileMenu)
  TrayMenu.Add("Reload", ReloadScript)
  TrayMenu.Add("Exit", ExitScript)

  ProfileMenuHandler(newProfile, pos, profileMenu) {
    global activeProfile, profileStored
  
    EnableProfile(newProfile)
  
    if (activeProfile != newProfile) {
      FileDelete(profileStored)
      FileAppend(newProfile, profileStored)
      profileMenu.ToggleCheck(activeProfile)
      profileMenu.ToggleCheck(newProfile)
    }
  
    activeProfile := newProfile
  }

  ReloadScript(Item, *) {
    Reload()
  }
  
  ExitScript(Item, *) {
    ExitApp()
  }  
}

GenerateMenu(GetProfiles())
