# Repository instructions

Komorebi Tray is a Windows-only AutoHotkey v2 tray application that
controls komorebi, follows its state through a named pipe, and switches
between AutoHotkey profiles.

This is not a Node.js application. npm is used only to generate icons.

## Commands

Run from source:

    AutoHotkey64.exe .\komorebi-tray.ahk

Build distributable packages on Windows:

    make build

## Commits

Use Conventional Commits. Subject: 50 characters max; body lines: 72 max.

## Before changing code

Read only the relevant guide:

- Architecture and lifecycle invariants: `docs/ARCHITECTURE.md`
- AutoHotkey conventions and vendored code: `docs/AUTOHOTKEY.md`
- Validation and manual tests: `docs/TESTING.md`
- Packaging and releases: `docs/RELEASING.md`

## Validation

There is no unified automated test runner. Do not claim that a change is
verified without following `docs/TESTING.md`.
