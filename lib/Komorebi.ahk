Class Komorebi
{
  ; userprofile folder path
  static USERPROFILE := EnvGet("USERPROFILE")
  ; komorebi config home folder path
  static CONFIG_HOME := EnvGet("KOMOREBI_CONFIG_HOME")

  ; userprofile komorebi.json file path
  static userProfileJson => this.USERPROFILE "\komorebi.json"
  ; userprofile komorebi.ahk file path
  static userProfileAhk => this.USERPROFILE "\komorebi.ahk"
  ; userprofile applications.yaml file path
  static userProfileYaml => this.USERPROFILE "\komorebi.yaml"

  ; default komorebi.json file path
  static configJson => this.CONFIG_HOME "\komorebi.json"
  ; default komorebi.ahk file path
  static configAhk => this.CONFIG_HOME "\komorebi.ahk"
  ; default applications.yaml file path
  static configYaml => this.CONFIG_HOME "\komorebi.yaml"

  ; Send a command to komorebic.exe
  static command(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
  }

  ; Subscribe komorebi to a named pipe
  static subscribe(pipe_name) {
    this.command(Format("subscribe-pipe {}", pipe_name))
  }

  ; Unsubscribe komorebi from a named pipe
  static unsubscribe(pipe_name) {
    this.command(Format("unsubscribe-pipe {}", pipe_name))
  }
}
