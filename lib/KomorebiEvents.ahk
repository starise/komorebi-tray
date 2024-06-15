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


  ; Start listening to komorebi named pipe.
  static start() {
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
    this.pipe.create()
    Komorebi.subscribe(this.pipeName)
    this.pipe.connect()
  }

  ; Disconnect and close active named pipe.
  static closeConnection() {
    Komorebi.unsubscribe(this.pipeName)
    this.pipe.disconnect()
    this.pipe.closeHandle()
  }

  ; Convert a raw json string into a json object.
  static toJson(raw) => JSON.Load(raw)["state"]

  ; Listen to komorebi messages on the pipe.
  ; Keep `KomorebiEvents.lastEvent` updated.
  static listen() {
    event := this.pipe.getData()
    if ( not this.pipe.pipeConnected) {
      KomorebiTray.stop()
    }
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
