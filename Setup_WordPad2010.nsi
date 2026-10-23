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
!define BINDIRARM64 "ARM64\Release"
!define BINDIRAMD64 "wordpad\amd64\Release"
!define BINDIR32 "wordpad\Release"

!system 'MySign "${BINDIR32}\WordPad.exe" "${BINDIRAMD64}\WordPad.exe" "${BINDIRARM64}\WordPad.exe"'
!finalize 'MySign "%1"'

!system 'DefineAsmVer.exe "${BINDIR32}\WordPad.exe" "!define VER ""[FileVersion]"" " "!define F4VER ""[F4VER]"" " "!define LegalCopyright ""[LegalCopyright]"" " "!define FileDescription ""[FileDescription]"" " "!define FileVersion ""[FileVersion]"" " > Appver.tmp'
!include "Appver.tmp"
!searchreplace APV "${VER}" "." "_"

; <IncludeSourceRevisionInInformationalVersion>false</IncludeSourceRevisionInInformationalVersion>

VIProductVersion "${F4VER}"
VIAddVersionKey FileDescription "${FileDescription}"
VIAddVersionKey FileVersion "${FileVersion}"
VIAddVersionKey LegalCopyright "${LegalCopyright}"
VIAddVersionKey ProductVersion "${VER}"

; The name of the installer
Name "${APP} v${VER}"

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

!include "LogicLib.nsh"
!include "x64.nsh"

;--------------------------------

; Pages

Page directory
Page components
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
  SetOutPath $INSTDIR
  File "${BINDIR32}\WordPad.exe"
  SetOutPath $INSTDIR\AMD64
  File "${BINDIRAMD64}\WordPad.exe"
  SetOutPath $INSTDIR\ARM64
  File "${BINDIRARM64}\WordPad.exe"
  
  SetOutPath $INSTDIR
  
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

Section /o "WordPad.exe" WORDPAD_X64
  File "${BINDIRAMD64}\WordPad.exe"
SectionEnd

Section /o "Create write.exe" WRITE_X64
  File "/oname=$WINDIR\write.exe" "${BINDIRAMD64}\WordPad.exe"
SectionEnd

SectionGroupEnd

SectionGroup "ARM64"

Section /o "WordPad.exe" WORDPAD_ARM64
  File "${BINDIRARM64}\WordPad.exe"
SectionEnd

Section /o "Create write.exe" WRITE_ARM64
  File "/oname=$WINDIR\write.exe" "${BINDIRARM64}\WordPad.exe"
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

Function .onInit
  ${If} ${IsNativeAMD64}
    SectionSetFlags ${WORDPAD_X64} ${SF_SELECTED}
    SectionSetFlags ${WRITE_X64} ${SF_SELECTED}
  ${EndIf}

  ${If} ${IsNativeARM64}
    SectionSetFlags ${WORDPAD_ARM64} ${SF_SELECTED}
    SectionSetFlags ${WRITE_ARM64} ${SF_SELECTED}
  ${EndIf}
FunctionEnd

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
