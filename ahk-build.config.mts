import { defineConfig } from "@alysoid/ahk-build";

export default defineConfig({
  entry: "komorebi-tray.ahk",
  app: {
    name: "Komorebi Tray",
    executable: "komorebi-tray.exe",
    artifactName: "KomorebiTray",
    description: "Komorebi Tray",
    copyright: "Copyright (c) 2024, Andrea Brandi",
    language: "0x0409",
    icon: "images/ico/app.ico",
  },
  compile: {
    architecture: "x64",
    compression: "upx",
    upxArgs: ["-q", "--all-methods", "--compress-icons=0"],
    includes: ["lib"],
    assets: [
      { from: "images/ico", to: "images/ico" },
      { from: "profiles", to: "profiles" },
    ],
  },
  portable: {
    output: "${buildDir}/KomorebiTray-${packageVersion}.zip",
    files: [
      { from: "${buildDir}/komorebi-tray.exe", to: "komorebi-tray.exe" },
      "LICENSE",
      { from: "images", to: "images" },
      { from: "profiles", to: "profiles" },
    ],
    exclude: ["png/**", "preview.webp", "**/preview.webp", "ico/app.ico"],
  },
  wix: {
    source: "wix/script.wxs",
    output: "${buildDir}/KomorebiTray-${packageVersion}.msi",
    architecture: "x64",
    extensions: ["WixToolset.UI.wixext"],
  },
  release: {
    repository: "alysoid/komorebi-tray",
    tag: "${packageVersion}",
    title: "Release v${packageVersion}",
    notes: "Release version ${packageVersion}",
    assets: [
      "${buildDir}/KomorebiTray-${packageVersion}.zip",
      "${buildDir}/KomorebiTray-${packageVersion}.msi",
    ],
  },
  hooks: {
    beforeCompile: [{ command: "pnpm", args: ["run", "genicons"] }],
  },
});
