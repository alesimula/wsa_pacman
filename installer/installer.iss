; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

#define tools_dir_name "embedded-adb"
#define releasedir "..\build\windows\runner\Release\"
#define toolsdir "..\"+tools_dir_name

#define executable "WSA-pacman.exe"
#define app_name "WSA Package Manager"
#define reg_appname "wsa-pacman"
#define reg_name_installer "Package installer"
#define reg_assoc_apk reg_appname + ".apk"

#define path_classes "SOFTWARE\Classes\"
#define path_assoc_user "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\"
#define path_assoc_default ".DEFAULT\"+path_assoc_user 

[Setup]
PrivilegesRequired=admin
AppName=WSA PacMan
AppVersion=0.4.2
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern
DefaultDirName={autopf}\WSA PacMan
DefaultGroupName=WSA PacMan
UninstallDisplayIcon={app}\{#executable}
Compression=lzma2
SolidCompression=yes
ChangesAssociations=yes
ChangesEnvironment=yes
OutputDir=userdocs:Inno Setup Examples Output

[Tasks]
Name: fileassoc; Description: "{cm:AssocFileExtension,{#app_name},.apk}";

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "WSA_PACMAN_HOME"; ValueData: "{app}"; Flags: createvalueifdoesntexist preservestringtype uninsdeletevalue
Root: HKA; Subkey: "{#path_classes}\.apk"; ValueData: "{#reg_assoc_apk}"; Flags: uninsdeletevalue; ValueType: string; ValueName: ""
Root: HKA; Subkey: "{#path_classes}\.apk\OpenWithProgids"; ValueType: string; ValueName: "{#reg_assoc_apk}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_apk}"; ValueData: "{#reg_name_installer}"; Flags: uninsdeletekey; ValueType: string; ValueName: ""
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_apk}\DefaultIcon"; ValueData: "%WSA_PACMAN_HOME%\{#executable},0"; ValueType: expandsz;  ValueName: ""
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_apk}\shell\open\command";  ValueData: """%WSA_PACMAN_HOME%\{#executable}"" ""%1""";  ValueType: expandsz;  ValueName: ""

Root: HKU; Subkey: "{#path_assoc_default}\.apk\UserChoice"; ValueType: none; Flags: deletekey; Tasks: fileassoc
Root: HKCU; Subkey: "{#path_assoc_user}\.apk\UserChoice"; ValueType: none; Flags: deletekey; Tasks: fileassoc

[Files]
Source: "{#releasedir}\*"; Excludes: "\*.lib,\*.exp,\{#tools_dir_name}"; DestDir: "{app}"; Flags: recursesubdirs
Source: "{#toolsdir}\*"; DestDir: "{app}\{#tools_dir_name}"; Flags: recursesubdirs

[Icons]
Name: "{group}\WSA PacMan"; Filename: "{app}\{#executable}"
