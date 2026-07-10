SHELL := cmd.exe
.SHELLFLAGS := /C

# Define variables
VERSION := $(or $(v),dev)
AHK2EXE := $(USERPROFILE)\Scoop\apps\autohotkey\current\Compiler\Ahk2Exe.exe
AHK_BASE := $(USERPROFILE)\Scoop\apps\autohotkey\current\v2\AutoHotkey64.exe
PACKER := $(USERPROFILE)\Scoop\apps\autohotkey\current\Compiler\Upx.exe
APP_AHK := komorebi-tray.ahk
APP_EXE := komorebi-tray.exe
BUILD_DIR := build
BUILD_ZIP := .\$(BUILD_DIR)\KomorebiTray-$(VERSION).zip
BUILD_MSI := .\$(BUILD_DIR)\KomorebiTray-$(VERSION).msi
APP_FILES := ".\$(APP_EXE)" ".\LICENSE" ".\images\ico\*" ".\profiles\*"
GIT_REPO := git@github.com:starise/komorebi-tray.git

# Print a helper
help:
	echo "options: clean, build, release v=1.0.0"

# Remove the build folder
clean:
	-pwsh -noprofile -command ri $(APP_EXE) -Force
	-pwsh -noprofile -command ri $(BUILD_DIR) -Force -Recurse

# Compile AHK files and compress with UPX
compile:
	pwsh -noprofile -command md $(BUILD_DIR) -Force
	"$(AHK2EXE)" /in $(APP_AHK) /out $(APP_EXE) /base "$(AHK_BASE)"

# Compile and create a ZIP portable
zip: compile
	7z.exe a "$(BUILD_ZIP)" $(APP_FILES)

# Compile and create a MSI installer
msi: compile
	wix build wix/script.wxs -ext WixToolset.UI.wixext -arch x64 -out "$(BUILD_MSI)"

# Clean and build new packages
build: clean compile zip msi

# Create a GitHub release and publish .zip and .msi files
release:
	gh release create $(VERSION) "$(BUILD_ZIP)" "$(BUILD_MSI)" --repo $(GIT_REPO) --title "Release v$(VERSION)" --notes "Release version $(VERSION)"
