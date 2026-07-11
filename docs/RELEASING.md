# Releasing

Release from Windows. Required: AutoHotkey v2, Ahk2Exe, `make`, PowerShell 7,
7-Zip, WiX, and `gh`. Node/npm only if icons changed.

1. Start from clean `main`; choose `MAJOR.MINOR.PATCH`.
2. Set the same version in `komorebi-tray.ahk`, `wix/script.wxs`, and the make
   command. `v` names packages; it does not update metadata.
3. Run relevant checks in [TESTING.md](TESTING.md), then build:

   ```powershell
   make clean
   make build v=0.2.0
   ```

4. Inspect `build/KomorebiTray-0.2.0.zip`; run the extracted app. Install and
   uninstall `build/KomorebiTray-0.2.0.msi`; check shortcut and resources.
5. Confirm EXE/MSI metadata and ZIP/MSI filenames use the same version.
6. Push the release commit, then publish:

   ```powershell
   make release v=0.2.0
   ```

   Check the public release has both assets. Do not replace published binaries
   under the same version; fix, increment, rebuild.
