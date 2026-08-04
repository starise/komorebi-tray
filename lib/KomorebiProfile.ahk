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
  static enable(profile) {
    Komorebi.startConfigAhk(this.folder "\" profile)
    Settings.save(profile, "active", "profiles")
    this.active := profile
  }
}
