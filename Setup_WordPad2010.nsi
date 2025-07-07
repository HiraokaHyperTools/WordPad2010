; example2.nsi
;
; This script is based on example1.nsi, but it remember the directory, 
; has uninstall support and (optionally) installs start menu shortcuts.
;
; It will install example2.nsi into a directory that the user selects.
;
; See install-shared.nsi for a more robust way of checking for administrator rights.
; See install-per-user.nsi for a file association example.

;--------------------------------

!define APP "WordPad2010"
!define BINDIR64 "wordpad\amd64\Release"
!define BINDIR32 "wordpad\Release"

!system 'MySign "${BINDIR32}\WordPad.exe" "${BINDIR64}\WordPad.exe"'
!finalize 'MySign "%1"'

; The name of the installer
Name "${APP}"

; The file to write
OutFile "Setup_${APP}.exe"

; Request application privileges for Windows Vista and higher
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir "$PROGRAMFILES\${APP}"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\${APP}" "Install_Dir"

XPStyle on

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section ""

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put file there
  File "${BINDIR64}\WordPad.exe"
  
  ; Write the installation path into the registry
  WriteRegStr HKLM "SOFTWARE\${APP}" "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${APP}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
SectionEnd

SectionGroup "AMD64"

Section "WordPad.exe"
  File "${BINDIR64}\WordPad.exe"
SectionEnd

Section "Create write.exe"
  File "/oname=$WINDIR\write.exe" "${BINDIR64}\WordPad.exe"
SectionEnd

SectionGroupEnd

SectionGroup "x86"

Section /o "WordPad.exe"
  File "${BINDIR32}\WordPad.exe"
SectionEnd

Section /o "Create write.exe"
  File "/oname=$WINDIR\write.exe" "${BINDIR32}\WordPad.exe"
SectionEnd

SectionGroupEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\${APP}"
  CreateShortcut "$SMPROGRAMS\${APP}\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\${APP}\WordPad.lnk" "$INSTDIR\WordPad.exe"

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
  DeleteRegKey HKLM "SOFTWARE\${APP}"

  ; Remove files and uninstaller
  Delete $INSTDIR\WordPad.exe
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\${APP}\*.lnk"

  ; Remove directories
  RMDir "$SMPROGRAMS\${APP}"
  RMDir "$INSTDIR"

SectionEnd
