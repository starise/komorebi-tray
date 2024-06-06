Class Komorebi {
  ; Send a command to komorebic.exe
  static command(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
  }
}
