#Include Komorebi.ahk

Class KomorebiProfile
{
  ; Folder path that contains all custom *.ahk profiles.
  static folder => Komorebi.CONFIG_HOME "\profiles"
  ; Config file path that contains the last active profile.
  static stored => Komorebi.CONFIG_HOME "\profile.ini"
  ; Currently active autohotkey profile.
  static active := ""

  ; Check if a profile is different from the current active one.
  static isDifferent(profile) => this.active != profile

  ; Make the given profile the current active one.
  static activate(profile) => this.active := profile

  ; Get array of all available autohotkey profiles.
  static getAll() {
    profiles := []
    Loop Files (this.folder "\*.ahk") {
      fileName := StrSplit(A_LoopFilePath, "\").Pop()
      profiles.Push(fileName)
    }

    return profiles
  }

  ; Enable a new profile and disable the previous active one.
  ; https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createhardlinka
  static enable(profile) {
    ; New profile settings
    FileDelete(this.stored)
    FileAppend(profile, this.stored)
    ; Create a hard link from /profiles to config home.
    FileDelete(Komorebi.configAhk)
    success := DllCall(
      "CreateHardLink",
      "Str", Komorebi.configAhk, ; Name of the new file (hard link).
      "Str", this.folder "\" profile, ; Name of the existing file.
      "Int", 0, ; Reserved; must be NULL.
      "Int" ; Return type: nonzero (success) or zero (failed).
    )
    Komorebi.reloadConfigAhk()
    this.activate(profile)

    return success
  }
}
