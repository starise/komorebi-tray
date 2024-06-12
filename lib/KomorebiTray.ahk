#Include KomorebiEvents.ahk
#Include KomorebiProfile.ahk

Class KomorebiTray
{
  ; Main tray menu object.
  static mainMenu := A_TrayMenu

  ; Profile menu instance.
  static profileMenu := Menu()

  ; Reload the entire app.
  static reload(*) {
    KomorebiEvents.stop()
    Reload()
  }

  ; Exit the entire app.
  static exit(*) {
    KomorebiEvents.stop()
    ExitApp()
  }

  ; Add the checkmark on the .ahk profile item in the Profile menu.
  static checkProfile(profile) => this.profileMenu.Check(profile)

  ; Remove the checkmark the .ahk profile item in the Profile menu.
  static uncheckProfile(profile) => this.profileMenu.Uncheck(profile)

  ; Generate the tray menu with a list of available profiles.
  static start(profiles) {
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
    ; Launch subroutine for tray icon updates.
    SetTimer(this.updateTrayIcon.Bind(this), 10)
  }

  ; Update tray icon with current workspace number
  static updateTrayIcon() {
    if (FileExist("images/ico/d-" Komorebi.workspace ".ico")) {
      TraySetIcon("images/ico/d-" Komorebi.workspace ".ico")
    } else {
      TraySetIcon("images/ico/app.ico")
    }
  }

  ; Activate a new given profile and disable the previous one.
  static enableProfile(profile, *) {
    this.checkProfile(profile)
    this.uncheckProfile(KomorebiProfile.active)
    KomorebiProfile.enable(profile)
  }
}
