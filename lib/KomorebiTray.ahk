#Include Komorebi.ahk
#Include KomorebiEvents.ahk
#Include KomorebiProfile.ahk
#Include Popup.ahk

Class KomorebiTray
{
  ; Main tray menu object.
  static mainMenu := A_TrayMenu
  ; Profile menu instance.
  static profileMenu := Menu()
  ; Profile menu instance.
  static komorebiMenu := Menu()
  ; Get the current pause menu label
  static pauseName => Komorebi.isPaused ? "Resume" : "Pause"
  ; Method to update app's current status
  static statusUpdater := ObjBindMethod(this, "updateStatus")

  ; Start tray listener
  static start() {
    this.mainMenu.Enable("Pause")
    this.mainMenu.Default := "Pause"
    SetTimer(this.statusUpdater, 10)
  }

  ; Stop komorebi and trigger a waiting state.
  static stop(*) {
    Komorebi.stop()
    TraySetIcon("images/ico/app.ico")
    A_IconTip := "Waiting for Komorebi..."
    Popup.new("Komorebi disconnected", 2000)
    this.mainMenu.Default := ""
    this.mainMenu.Rename(this.pauseName, "Pause")
    this.mainMenu.Disable("Pause")
    SetTimer(this.statusUpdater, 0)
  }

  ; Restart komorebi.
  static restart(*) {
    Komorebi.stop()
    Komorebi.start()
  }

  ; Pause komorebi.
  static pause(name, pos, menu) {
    Komorebi.pause()
    if (Komorebi.isPaused) {
      TraySetIcon("images/ico/pause.ico")
    } else {
      TraySetIcon("images/ico/d-" Komorebi.workspace ".ico")
    }
    if (name = "Pause") {
      menu.Rename("Pause", "Resume")
    } else {
      menu.Rename("Resume", "Pause")
    }
  }

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
  static create(profiles) {
    this.mainMenu.Delete()
    for (profile in profiles) {
      this.profileMenu.Add(
        profile,
        this.enableProfile.Bind(this, profile)
      )
    }
    this.profileMenu.Check(KomorebiProfile.active)
    this.mainMenu.Add("Profiles", this.profileMenu)
    this.mainMenu.Add("Komorebi", this.komorebiMenu)
    this.komorebiMenu.Add("Restart", ObjBindMethod(this, "restart"))
    this.komorebiMenu.Add("Stop", ObjBindMethod(this, "stop"))
    this.mainMenu.Add() ; separator
    this.mainMenu.Add("Pause", ObjBindMethod(this, "pause"))
    this.mainMenu.Add("Reload", ObjBindMethod(this, "reload"))
    this.mainMenu.Add("Exit", ObjBindMethod(this, "exit"))
    this.mainMenu.ClickCount := 1

    this.start()
  }

  ; Update status with current data available
  static updateStatus() {
    if (Komorebi.workspace != Komorebi.workspaceLast) {
      Komorebi.workspaceLast := Komorebi.workspace
      if (Komorebi.workspace <= Komorebi.workspaceMax) {
        TraySetIcon("images/ico/d-" Komorebi.workspace ".ico")
      } else {
        TraySetIcon("images/ico/app.ico")
      }
      A_IconTip := Komorebi.workspaceName " @ " Komorebi.displayName
      Popup.new(Komorebi.workspaceName, 2000)
    }
  }

  ; Activate a new given profile and disable the previous one.
  static enableProfile(profile, *) {
    this.checkProfile(profile)
    this.uncheckProfile(KomorebiProfile.active)
    KomorebiProfile.enable(profile)
  }
}
