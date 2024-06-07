#Include Komorebi.ahk

Class KomorebiProfile
{
  ; Folder path that contains all custom *.ahk profiles
  static folder => Komorebi.CONFIG_HOME "\profiles"
  ; Config file path that contains the last active profile
  static stored => Komorebi.CONFIG_HOME "\profile.ini"
  ; Currently active autohotkey profile
  static active := ""

  ; Check if a profile is different from the current active one
  static isDifferent(profile) => this.active != profile

  ; Make the given profile the current active one
  static activate(profile) => this.active := profile

  ; Get array of all available autohotkey profiles
  static getAll() {
    profiles := []
    Loop Files (this.folder "\*.ahk") {
      fileName := StrSplit(A_LoopFilePath, "\").Pop()
      profiles.Push(fileName)
    }

    return profiles
  }

  ; Enable a new profile and disable the old one
  static enable(profile) {
    if (this.isDifferent(profile)) {
      FileDelete(this.stored)
      FileAppend(profile, this.stored)
      FileCopy(this.folder "\" profile, Komorebi.configAhk, 1)
      Komorebi.reloadConfigAhk()

      this.activate(profile)
    }
  }
}
