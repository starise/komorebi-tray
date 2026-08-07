# Releasing

Release from Windows. Required: Node.js 24, pnpm, WiX 7, and `gh` for
publication. The managed ahk-build provider supplies AutoHotkey and Ahk2Exe.

1. Start from clean `main`; choose `MAJOR.MINOR.PATCH`.
2. Update only `package.json.version`; the build derives EXE, ZIP, MSI, and
   release metadata from it.
3. Run relevant checks in [TESTING.md](TESTING.md), then build:

   ```powershell
   pnpm run clean
   pnpm run build
   ```

4. Inspect `build/KomorebiTray-<version>.zip`; run the extracted app. Install and
   uninstall `build/KomorebiTray-<version>.msi`; check shortcut and resources.
5. Confirm EXE/MSI metadata and ZIP/MSI filenames use the same version.
6. Push the release commit, then publish:

   ```powershell
   pnpm run release
   ```

   Check the public release has both assets. Do not replace published binaries
   under the same version; fix, increment, rebuild.
