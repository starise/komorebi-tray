# AutoHotkey conventions

- AutoHotkey v2 only; runnable scripts declare `#Requires AutoHotkey v2.0`.
- Follow `.editorconfig`; do not reformat unrelated code.
- Classes use a next-line brace; functions use a same-line brace. Use existing
  `PascalCase` classes and `camelCase` methods/variables.
- Keep `#Include` dependencies explicit. Static classes own one capability.
- Resolve bundled paths from `A_ScriptDir` and user config from
  `KOMOREBI_CONFIG_HOME`.
- Store reused bound callbacks and timer callbacks; stop a timer before
  replacing it.
- Fail with exceptions when an unsafe operation cannot proceed. Use
  `OutputDebug` for recoverable diagnostics.
- `DllCall` types, handle cleanup, unusual flags, and platform constraints must
  remain explicit. Comments explain why, not restate code.
- `lib/JSON.ahk` is vendored: preserve its license and style; update it alone.
- `profiles/` files are standalone v2 user examples; do not depend on the
  installation path.
