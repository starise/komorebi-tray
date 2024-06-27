#Include Komorebi.ahk

Class Settings
{
  ; Config file path that contains app's settings.
  static configFile := Komorebi.CONFIG_HOME "\komorebi-tray.ini"

  ; Write a "key=value" into a [section] in the configuration file
  static save(value, key, section) {
    IniWrite(value, this.configFile, section, key)
  }

  ; Return the value from a "key=value" placed into a [section]
  static load(key, section) {
    return IniRead(this.configFile, section, key)
  }

  ; Delete a "key=value" from a [section] in the configuration file
  static delete(key, section) {
    IniDelete(this.configFile, key, section)
  }
}
