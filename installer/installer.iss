; -- installer.iss --
; Generates an installer with Inno Setup.

#define tools_dir_name "embedded-tools"
#define releasedir "..\build\windows\runner\Release\"
#define instbuilddir "..\build\installer"
#define toolsdir "..\"+tools_dir_name

#define vcredist_version "14.31.31103.00"

#define executable "WSA-pacman.exe"
#define app_name "WSA Package Manager"
#define dist_appname "WSA-pacman"
#define reg_appname "wsa-pacman"
#define reg_name_installer "Package installer"

#define reg_assoc_xapk reg_appname + ".xapk"
#define reg_assoc_apk reg_appname + ".apk"

#define path_classes "SOFTWARE\Classes\"
#define path_assoc_user "Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\"
#define path_assoc_default ".DEFAULT\"+path_assoc_user 

[Setup]
AppVersion=1.5.0
PrivilegesRequired=admin
AppName=WSA PacMan
AppPublisher=alesimula
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern
DefaultDirName={autopf}\WSA PacMan
DefaultGroupName=WSA PacMan
UninstallDisplayIcon={app}\{#executable}
Compression=lzma2
SolidCompression=yes
ChangesAssociations=yes
ChangesEnvironment=yes
OutputBaseFilename={#dist_appname}-v{#SetupSetting("AppVersion")}-installer
OutputDir={#instbuilddir}

[Tasks]
Name: fileassoc_apk; Description: "{cm:AssocFileExtension,{#app_name},.apk}";
Name: fileassoc_xapk; Description: "{cm:AssocFileExtension,{#app_name},.xapk}";

[Registry]
Root: HKA; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: string; ValueName: "WSA_PACMAN_HOME"; ValueData: "{app}"; Flags: createvalueifdoesntexist preservestringtype uninsdeletevalue
; File association: apk
Root: HKA; Subkey: "{#path_classes}\.apk"; ValueData: "{#reg_assoc_apk}"; Flags: uninsdeletevalue; ValueType: string; ValueName: ""
Root: HKA; Subkey: "{#path_classes}\.apk\OpenWithProgids"; ValueType: string; ValueName: "{#reg_assoc_apk}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_apk}"; ValueData: "{#reg_name_installer}"; Flags: uninsdeletekey; ValueType: string; ValueName: ""
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_apk}\DefaultIcon"; ValueData: "%WSA_PACMAN_HOME%\{#executable},0"; ValueType: expandsz;  ValueName: ""
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_apk}\shell\open\command";  ValueData: """%WSA_PACMAN_HOME%\{#executable}"" ""%1""";  ValueType: expandsz;  ValueName: ""
Root: HKU; Subkey: "{#path_assoc_default}\.apk\UserChoice"; ValueType: none; Flags: deletekey; Tasks: fileassoc_apk
Root: HKCU; Subkey: "{#path_assoc_user}\.apk\UserChoice"; ValueType: none; Flags: deletekey; Tasks: fileassoc_apk
; File association: xapk
Root: HKA; Subkey: "{#path_classes}\.xapk"; ValueData: "{#reg_assoc_xapk}"; Flags: uninsdeletevalue; ValueType: string; ValueName: ""
Root: HKA; Subkey: "{#path_classes}\.xapk\OpenWithProgids"; ValueType: string; ValueName: "{#reg_assoc_xapk}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_xapk}"; ValueData: "{#reg_name_installer}"; Flags: uninsdeletekey; ValueType: string; ValueName: ""
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_xapk}\DefaultIcon"; ValueData: "%WSA_PACMAN_HOME%\{#executable},0"; ValueType: expandsz;  ValueName: ""
Root: HKA; Subkey: "{#path_classes}\{#reg_assoc_xapk}\shell\open\command";  ValueData: """%WSA_PACMAN_HOME%\{#executable}"" ""%1""";  ValueType: expandsz;  ValueName: ""
Root: HKU; Subkey: "{#path_assoc_default}\.xapk\UserChoice"; ValueType: none; Flags: deletekey; Tasks: fileassoc_xapk
Root: HKCU; Subkey: "{#path_assoc_user}\.xapk\UserChoice"; ValueType: none; Flags: deletekey; Tasks: fileassoc_xapk

[Files]
Source: "{#releasedir}\*"; Excludes: "\*.lib,\*.exp,\{#tools_dir_name}"; DestDir: "{app}"; Flags: recursesubdirs
Source: "{#toolsdir}\*"; DestDir: "{app}\{#tools_dir_name}"; Flags: recursesubdirs
Source: ".\redist\VC_redist.x64.exe"; DestDir: {tmp}; Flags: dontcopy

[Run]
Filename: "{tmp}\VC_redist.x64.exe"; StatusMsg: "Installing Visual C++ Redistributable..."; \
  Parameters: "/quiet /norestart /install"; Check: ShouldInstallVCRedist; Flags: waituntilterminated

[Icons]
Name: "{group}\WSA PacMan"; Filename: "{app}\{#executable}"

[Code]
function ShouldInstallVCRedist: Boolean;
var 
  Version: String;
begin
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64', 'Version', Version) then
  begin 
    Log('VC Redist Version check : found ' + Version);
    //Check if the installed version is lower than the version included in the installer
    Result := (CompareStr(Version, 'v{#vcredist_version}')<0);
  end
  else 
  begin
    // Not even an old version installed
    Result := True;
  end;
  if (Result) then
  begin
    ExtractTemporaryFile('VC_redist.x64.exe');
  end;
end;
