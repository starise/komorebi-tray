#Include Komorebi.ahk
#Include Settings.ahk

Class KomorebiProfile
{
  ; Folder path that contains all custom *.ahk profiles.
  static folder => Komorebi.CONFIG_HOME "\profiles"

  ; Check if a profile is different from the current active one.
  static isDifferent(profile) => this.active != profile

  ; Make the given profile the current active one.
  static activate(profile) => this.active := profile

  ; Currently active autohotkey profile.
  static active := ""

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
    temporaryConfig := Komorebi.configAhk ".tmp"
    if (FileExist(temporaryConfig)) {
      FileDelete(temporaryConfig)
    }
    ; Create the new hard link before replacing the active configuration.
    success := DllCall(
      "CreateHardLink",
      "Str", temporaryConfig, ; Name of the new file (hard link).
      "Str", this.folder "\" profile, ; Name of the existing file.
      "Int", 0, ; Reserved; must be NULL.
      "Int" ; Return type: nonzero (success) or zero (failed).
    )
    if (not success) {
      throw OSError(A_LastError)
    }
    FileMove(temporaryConfig, Komorebi.configAhk, true)
    Settings.save(profile, "active", "profiles")
    Komorebi.reloadConfigAhk()
    this.activate(profile)

    return success
  }
}
