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
  ; Get the current pause status
  static menuPaused := false
  ; Get the current pause menu name
  static pauseName => this.menuPaused ? "Resume" : "Pause"
  ; Method to update app's current status
  static statusUpdater := ObjBindMethod(this, "updateStatus")
  ; Theme and icon state.
  static currentIcon := "app"
  static darkMode := false
  static themeChangeHandler := ObjBindMethod(this, "onThemeChange")
  static themeUpdater := ObjBindMethod(this, "refreshTheme")

  ; Detect the Windows application theme.
  static isDarkMode() {
    key := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    appsUseLightTheme := RegRead(key, "AppsUseLightTheme", "")
    if (appsUseLightTheme == "") {
      appsUseLightTheme := RegRead(key, "SystemUsesLightTheme", 1)
    }
    return appsUseLightTheme = 0
  }

  ; Enable native dark/light rendering for Win32 menus and watch theme changes.
  static initializeTheme() {
    this.darkMode := this.isDarkMode()
    OnMessage(0x001A, this.themeChangeHandler) ; WM_SETTINGCHANGE
    OnMessage(0x031A, this.themeChangeHandler) ; WM_THEMECHANGED
    this.applyMenuTheme()
    this.setIcon(this.currentIcon)
  }

  static callUxTheme(ordinal, args*) {
    hModule := 0
    try {
      hModule := DllCall("kernel32\LoadLibrary", "Str", "uxtheme.dll", "Ptr")
      procedure := DllCall(
        "kernel32\GetProcAddress", "Ptr", hModule, "Ptr", ordinal, "Ptr"
      )
      if (not procedure) {
        return false
      }
      DllCall(procedure, args*)
      return true
    } catch Error as e {
      OutputDebug("Native theme call unavailable: " e.Message)
      return false
    } finally {
      if (hModule) {
        DllCall("kernel32\FreeLibrary", "Ptr", hModule)
      }
    }
  }

  ; Set the native menu palette for the current Windows application theme.
  static applyMenuTheme() {
    mode := this.darkMode ? 2 : 3 ; ForceDark / ForceLight
    return this.callUxTheme(135, "Int", mode)
  }

  ; Flush cached native menu theme data after menus have been created/updated.
  static flushMenuThemes() {
    return this.callUxTheme(136)
  }

  static onThemeChange(*) {
    SetTimer(this.themeUpdater, -150)
  }

  static refreshTheme() {
    darkMode := this.isDarkMode()
    if (darkMode = this.darkMode) {
      return
    }
    this.darkMode := darkMode
    this.applyMenuTheme()
    this.flushMenuThemes()
    this.setIcon(this.currentIcon)
  }

  ; Resolve the supplied icon state to the theme-specific ICO asset.
  static iconPath(name) {
    theme := this.darkMode ? "dark" : "light"
    fileName := name
    if (SubStr(name, 1, 2) = "d-") {
      fileName := "ws-" Format("{:02}", Integer(SubStr(name, 3)))
    }
    return A_ScriptDir "\images\ico\" theme "\" fileName "-" theme ".ico"
  }

  static setIcon(name) {
    this.currentIcon := name
    TraySetIcon(this.iconPath(name))
  }

  ; Start tray listener
  static start() {
    SetTimer(this.statusUpdater, 10)
    ; Enable the pause menu
    this.mainMenu.Enable(this.pauseName)
    this.mainMenu.Default := this.pauseName
  }

  ; Stop komorebi and trigger a waiting state.
  static stop(*) {
    this.waiting()
    Komorebi.stop()
  }

  ; Put the tray into a waiting state.
  static waiting() {
    SetTimer(this.statusUpdater, 0)
    ; Disable the pause menu
    this.mainMenu.Disable(this.pauseName)
    this.mainMenu.Default := ""
    ; Tray icon in waiting mode
    this.setIcon("app")
    A_IconTip := "Waiting for Komorebi..."
    Popup.new("Komorebi disconnected", 2000)
  }

  ; Restart komorebi.
  static restart(*) {
    Komorebi.stop()
    Komorebi.start()
  }

  ; Pause komorebi.
  static pause(*) {
    Komorebi.togglePause()
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

  ; Generate the tray menu with a list of available profiles.
  static create(profiles) {
    this.initializeTheme()
    this.mainMenu.Delete()
    for (profile in profiles) {
      this.profileMenu.Add(
        profile,
        ObjBindMethod(this, "enableProfile", profile)
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
    this.flushMenuThemes()

    this.start()
  }

  ; Update status with current data available
  static updateStatus() {
    if (Komorebi.display != Komorebi.displayLast
      or Komorebi.workspace != Komorebi.workspaceLast) {
      Komorebi.displayLast := Komorebi.display
      Komorebi.workspaceLast := Komorebi.workspace
      if (not Komorebi.isPaused) {
        if (Komorebi.workspace <= Komorebi.workspaceMax) {
          this.setIcon("d-" Komorebi.workspace)
        } else {
          this.setIcon("app")
        }
      }
      A_IconTip := Komorebi.workspaceName " @ " Komorebi.displayName
      Popup.new(Komorebi.workspaceName, 2000, , , , Komorebi.display)
    }
    if (Komorebi.isPaused and not this.menuPaused) {
      this.mainMenu.Rename(this.pauseName, "Resume")
      this.setIcon("pause")
      this.menuPaused := true
    }
    if ( not Komorebi.isPaused and this.menuPaused) {
      this.mainMenu.Rename(this.pauseName, "Pause")
      this.setIcon("d-" Komorebi.workspace)
      this.menuPaused := false
    }
  }

  ; Activate a new given profile and disable the previous active one.
  static enableProfile(profile, *) {
    if (KomorebiProfile.active != profile) {
      this.profileMenu.Check(profile)
      this.profileMenu.Uncheck(KomorebiProfile.active)
      KomorebiProfile.enable(profile)
      Popup.new(profile " activated", 2000)
    }
  }
}
