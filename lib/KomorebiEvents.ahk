#Include Komorebi.ahk
#Include KomorebiTray.ahk
#Include NamedPipe.ahk
#Include JSON.ahk

Class KomorebiEvents
{
  ; Name of the pipe.
  static pipeName := "komorebi-tray"
  ; Current named pipe instance.
  static pipe := NamedPipe(this.pipeName)
  ; Last valid event as json object.
  static lastEvent := ""
  ; Method for komorebi event listening.
  static listener := ObjBindMethod(this, "listen")
  ; Method to wait for komorebi to be launched.
  static waiter := ObjBindMethod(this, "wait")

  ; Convert a raw json string into a json object.
  static toJson(raw) => JSON.Load(raw)["state"]

  ; Start listening to komorebi named pipe.
  static start() {
    this.pipe.create()
    this.openConnection()
    SetTimer(this.listener, 10)
  }

  ; Stop listening and close the named pipe.
  static stop() {
    SetTimer(this.listener, 0)
    this.closeConnection()
  }

  ; Create and connect to a new named pipe.
  static openConnection() {
    Komorebi.subscribe(this.pipeName)
    this.pipe.connect()
  }

  ; Disconnect and close active named pipe.
  static closeConnection() {
    this.pipe.disconnect()
    this.pipe.closeHandle()
  }

  ; Wait for komorebi to exit the waiting state.
  static wait() {
    if (Komorebi.isRunning) {
      KomorebiEvents.start()
      KomorebiTray.start()
      SetTimer(this.waiter, 0)
    }
  }

  ; Listen to komorebi messages on the pipe.
  static listen() {
    ; The connection has been lost, maybe komorebi has been stopped.
    ; Stop listening and wait for komorebi to be started.
    if (this.pipe.lastErrorCode = this.pipe.ERROR_BROKEN_PIPE) {
      KomorebiEvents.stop()
      KomorebiTray.stop()
      SetTimer(this.waiter, 2000)
    }
    ; When komorebi is paused before the app is started, the pipe
    ; is reported as "bad": resume komorebi and try to reconnect.
    if (this.pipe.lastErrorCode = this.pipe.ERROR_BAD_PIPE) {
      Komorebi.togglePause()
      KomorebiEvents.start()
    }
    event := this.pipe.getData()
    if (event and event != this.lastEvent) {
      this.lastEvent := JSON.Load(event)["state"]
      Komorebi.isPaused := this.lastEvent["is_paused"]
      Komorebi.display := this.lastEvent["monitors"]["focused"] + 1
      displayData := this.lastEvent["monitors"]["elements"][Komorebi.display]
      Komorebi.displayName := displayData["name"]
      Komorebi.workspace := displayData["workspaces"]["focused"] + 1
      workspaceData := displayData["workspaces"]["elements"][Komorebi.workspace]
      Komorebi.workspaceName := workspaceData["name"]
    }
  }
}
