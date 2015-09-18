#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#Include Diablo2.ahk

Diablo2_InitConstants()
RegRead, Ahk2ExePath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Ahk2Exe.exe ; Get default value

Fail(Message) {
	MsgBox, % "Install failed: " . Message
	ExitApp
}

InstallFile(SourcePath) {
	global Diablo2
	if (!FileExist(SourcePath)) {
		Fail(Format("{}: File to install does not exist", SourcePath))
	}
	FileCopy, %SourcePath%, % Diablo2.AutoHotkeyLibDir , true
}

; Install the Diablo2 library and its dependencies to the AutoHotkey user library location.

FileCreateDir, % Diablo2.AutoHotkeyLibDir
InstallFile("Diablo2.ahk")
InstallFile("Vendor\JSON\JSON.ahk")
InstallFile("Vendor\WatchDirectory\WatchDirectory.ahk")
For __, BaseName in ["_Struct", "sizeof"] {
	InstallFile(Format("Vendor\_Struct\{}.ahk", BaseName))
}
InstallFile("Vendor\Gdip\Gdip.ahk")
;InstallFile("Vendor\MasterFocus\Functions\Gdip_ImageSearch\Gdip_ImageSearch.ahk")
; TODO: Correctly integrate our modifications to MasterFocus's Gdip_ImageSearch
InstallFile("Vendor\Gdip_ImageSearch.ahk")
FileCopyDir, Images, % Diablo2.AutoHotkeyLibDir . "\Images", true

; Compile after installing, as RunGame.ahk makes use of Diablo2.ahk.
ExePath := Diablo2.AutoHotkeyLibDir . "\Diablo II.exe"
RunWait, "%Ahk2ExePath%" /in RunGame.ahk /out "%ExePath%" /icon Game.ico
if (ErrorLevel != 0) {
	Fail("Running Ahk2Exe failed with return code " . ErrorLevel)
}

MsgBox, % Format("Install successful!`n`nInstalled to {}.", Diablo2.AutoHotkeyLibDir)
