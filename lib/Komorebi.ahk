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
  static userProfileAppYaml => this.USERPROFILE "\applications.yaml"
  ; Userprofile applications.json file path.
  static userProfileAppJson => this.USERPROFILE "\applications.json"

  ; Default komorebi.json file path.
  static configJson => this.CONFIG_HOME "\komorebi.json"
  ; Default komorebi.ahk file path.
  static configAhk => this.CONFIG_HOME "\komorebi.ahk"
  ; Default applications.yaml file path.
  static configAppYaml => this.CONFIG_HOME "\applications.yaml"
  ; Default applications.yaml file path.
  static configAppJson => this.CONFIG_HOME "\applications.json"

  ; Return true if komorebi.exe is running in background
  static isRunning => ProcessExist("komorebi.exe") ? true : false
  ; True if komorebi is paused.
  static isPaused := false
  ; Number of current focused display.
  static display := 0
  ; Name of current focused display.
  static displayName := ""
  ; Number of current focused workspace.
  static workspace := 0
  ; Name of the current workspace.
  static workspaceName := ""
  ; Number of max supported workspaces.
  static workspaceMax := 8
  ; Number of last focused workspace.
  static workspaceLast := 0

  ; Send a command to komorebic executable.
  static command(cmd) {
    RunWait(Format("komorebic.exe {}", cmd), , "Hide")
  }

  ; Start komorebi.exe with autohotkey config.
  static start() {
    this.command("start --ahk")
  }

  ; Stop komorebi.exe process.
  static stop() {
    this.command("stop")
  }

  ; Toggle on/off window tiling management.
  static togglePause() {
    this.command("toggle-pause")
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

  ; Fetch the latest version of applications.json.
  static getConfigAppJson() {
    this.command("fetch-app-specific-configuration")
  }

  ; Fetch and create needed configuration files
  static newConfigFiles() {
    ; Download latest komorebi.json example
    Download(
      "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/docs/komorebi.example.json",
      this.configJson
    )
    ; Use `KOMOREBI_CONFIG_HOME` as root for applications.json
    jsonConfig := FileRead(this.configJson)
    jsonConfig := StrReplace(jsonConfig, "$Env:USERPROFILE", "$Env:KOMOREBI_CONFIG_HOME")
    FileDelete(this.configJson)
    FileAppend(jsonConfig, this.configJson)
    ; Fetch the latest version of applications.json
    this.getConfigAppJson()
  }
}
