# Releasing

Release from Windows. Required: Node.js 24, pnpm, WiX 7, and `gh` for
publication. The managed ahk-build provider supplies AutoHotkey and Ahk2Exe.

1. Start from clean `main`; choose `MAJOR.MINOR.PATCH`.
2. Update only `package.json.version`; the build derives EXE, ZIP, MSI, and
   release metadata from it.
3. Run relevant checks in [TESTING.md](TESTING.md), then build:

   ```powershell
   pnpm run build
   ```

   `build` cleans generated artifacts before compiling.

4. Inspect `build/KomorebiTray-<version>.zip`; run the extracted app. Install and
   uninstall `build/KomorebiTray-<version>.msi`; check shortcut and resources.
5. Confirm EXE/MSI metadata and ZIP/MSI filenames use the same version.
6. Commit the version change, create the matching Git tag, and push both. The
   configured tag is exactly the package version, without a `v` prefix:

   ```powershell
   git add package.json
   git commit -m "chore(release): prepare <version>"
   git tag -a <version> -m "Release <version>"
   git push origin main
   git push origin <version>
   ```

7. Publish:

   ```powershell
   pnpm run release
   ```

   `pnpm release` is equivalent. It verifies GitHub CLI authentication, checks
   that the versioned ZIP and MSI exist, and creates the GitHub release with
   `--verify-tag`; it does not build, commit, tag, or push anything. Check the
   public release has both assets. Do not replace published binaries under the
   same version; fix, increment, rebuild.
