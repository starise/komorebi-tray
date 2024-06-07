#Include KomorebiProfile.ahk

Class KomorebiTray
{
  ; Main tray menu object.
  static mainMenu := A_TrayMenu

  ; Profile menu instance.
  static profileMenu := Menu()

  ; Reload the entire app.
  static reload(*) => Reload()

  ; Exit the entire app.
  static exit(*) => ExitApp()

  ; Add the checkmark on the .ahk profile item in the Profile menu.
  static checkProfile(profile) => this.profileMenu.Check(profile)

  ; Remove the checkmark the .ahk profile item in the Profile menu.
  static uncheckProfile(profile) => this.profileMenu.Uncheck(profile)

  ; Generate the tray menu with a list of available profiles.
  static generateMenu(profiles) {
    this.mainMenu.Delete()
    for (profile in profiles) {
      this.profileMenu.Add(
        profile,
        this.enableProfile.Bind(this, profile)
      )
    }
    this.profileMenu.Check(KomorebiProfile.active)
    this.mainMenu.Add("Profiles", this.profileMenu)
    this.mainMenu.Add("Reload", this.reload)
    this.mainMenu.Add("Exit", this.exit)
  }

  ; Activate a new given profile and disable the previous one.
  static enableProfile(profile, *) {
    this.checkProfile(profile)
    this.uncheckProfile(KomorebiProfile.active)
    KomorebiProfile.enable(profile)
  }
}
