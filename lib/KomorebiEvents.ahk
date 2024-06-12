#Include Komorebi.ahk
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

  ; Start listening to komorebi named pipe.
  static start(name := "") {
    this.pipeName := name ? name : this.pipeName
    this.pipe.createNamedPipe()
    this.pipe.connectNamedPipe()
    Komorebi.subscribe(this.pipeName)
    ; Launch subroutine for event listening.
    SetTimer(this.listener.Bind(this), 10)
  }

  ; Stop listening and close the named pipe.
  static stop() {
    Komorebi.unsubscribe(this.pipeName)
    this.pipe.disconnectNamedPipe()
    this.pipe.closeHandle()
  }

  ; Convert a raw json string into a json object.
  static toJson(raw) => JSON.Load(raw)["state"]

  ; Listen to komorebi messages on the pipe.
  ; Keep `KomorebiEvents.lastEvent` updated.
  static listener() {
    event := this.pipe.getData()
    if (event and event != this.lastEvent) {
      this.lastEvent := JSON.Load(event)["state"]
      Komorebi.isPaused := this.lastEvent["is_paused"]
      Komorebi.display := this.lastEvent["monitors"]["focused"] + 1
      displayData := this.lastEvent["monitors"]["elements"][Komorebi.display]
      Komorebi.workspace := displayData["workspaces"]["focused"] + 1
    }
  }
}
