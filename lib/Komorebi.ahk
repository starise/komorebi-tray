Class Komorebi
{
  ; Userprofile folder path.
  static USERPROFILE := EnvGet("USERPROFILE")
  ; Komorebi config home folder path.
  static CONFIG_HOME := EnvGet("KOMOREBI_CONFIG_HOME")

  ; Userprofile komorebi.json file path.
  static userProfileJson => this.USERPROFILE "\komorebi.json"
  ; Userprofile komorebi.ahk file path.
  static userProfileAhk => this.USERPROFILE "\komorebi.ahk"
  ; Userprofile applications.yaml file path.
  static userProfileYaml => this.USERPROFILE "\applications.yaml"

  ; Default komorebi.json file path.
  static configJson => this.CONFIG_HOME "\komorebi.json"
  ; Default komorebi.ahk file path.
  static configAhk => this.CONFIG_HOME "\komorebi.ahk"
  ; Default applications.yaml file path.
  static configYaml => this.CONFIG_HOME "\applications.yaml"

  ; True if komorebi is paused.
  static isPaused := false
  ; Number of current focused display.
  static display := 0
  ; Number of current focused workspace.
  static workspace := 0

  ; Send a command to komorebic executable.
  static command(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
  }

  ; Reload komorebi.ahk config file.
  static reloadConfigAhk() {
    this.command("reload-configuration")
  }

  ; Subscribe komorebi to a named pipe.
  static subscribe(pipe_name) {
    this.command(Format("subscribe-pipe {}", pipe_name))
  }

  ; Unsubscribe komorebi from a named pipe.
  static unsubscribe(pipe_name) {
    this.command(Format("unsubscribe-pipe {}", pipe_name))
  }
}
