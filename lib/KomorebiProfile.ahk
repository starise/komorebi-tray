#Include Komorebi.ahk
#Include Settings.ahk

Class KomorebiProfile
{
  ; Folder path that contains all custom *.ahk profiles.
  static folder => Komorebi.CONFIG_HOME "\profiles"

  ; Currently active autohotkey profile.
  static active := ""

  ; Get array of all available autohotkey profiles.
  static getAll() {
    profiles := []
    Loop Files (this.folder "\*.ahk") {
      profiles.Push(A_LoopFileName)
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
    Komorebi.startConfigAhk()
    this.active := profile
  }
}
