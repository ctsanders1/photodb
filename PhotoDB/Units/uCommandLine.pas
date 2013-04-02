unit uCommandLine;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Forms,

  Dmitry.Utils.Files,

  CMDUnit,
  GraphicCrypt,
  UnitCrypting,

  uConstants,
  uMemoryEx,
  uAppUtils,
  uSplashThread,
  uMediaPlayers,
  uLogger,
  uSettings,
  uTranslate,
  uShellIntegration,
  uUninstallUtils,
  uRuntime,
  uShellUtils,
  uFormInterfaces,
  uSessionPasswords,
  uAssociations,
  uDBUtils;

type
  TCommandLine = class
    class procedure ProcessServiceCommands;
    class procedure ProcessUserCommandLine;
  end;

implementation

procedure StopApplication;
begin
  CloseSplashWindow;
  DBTerminating := True;
end;

{ TCommandLine }

class procedure TCommandLine.ProcessServiceCommands;
var
  ExtensionList: string;
begin
  if GetParamStrDBBool('/AddPass') then
    SessionPasswords.GetPasswordsFromParams;

  if GetParamStrDBBool('/installExt') then
  begin
    ExtensionList := GetParamStrDBValue('/installExt');

    InstallGraphicFileAssociationsFromParamStr(Application.ExeName, ExtensionList);
    RefreshSystemIconCache;
  end;

  if GetParamStrDBBool('/CPU1') then
    ProcessorCount := 1;

  if not FolderView and not DBTerminating and GetParamStrDBBool('/install') then
  begin
    RegisterVideoFiles;
    StopApplication;
  end;

  if not FolderView and not DBTerminating and GetParamStrDBBool('/uninstall') then
  begin
    CleanUpUserSettings;
    StopApplication;
  end;

  if GetParamStrDBBool('/close') then
    StopApplication;

  if not FolderView and not DBTerminating then
    if not GetParamStrDBBool('/NoFaultCheck') then
      if (Settings.ReadProperty('Starting', 'ApplicationStarted') = '1') then
      begin
        CloseSplashWindow;
        if ID_OK = MessageBoxDB(Application.MainFormHandle, TA('There was an error closing previous instance of this program! Check database file for errors?', 'System'), TA('Error'), TD_BUTTON_OKCANCEL, TD_ICON_ERROR) then
        begin
          Settings.WriteBool('StartUp', 'Pack', False);
          Application.CreateForm(TCMDForm, CMDForm);
          CMDForm.PackPhotoTable;
          R(CMDForm);
        end;
      end;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/PACKTABLE') or Settings.ReadBool('StartUp', 'Pack', False) then
    begin
      CloseSplashWindow;
      EventLog('Packing...');
      Settings.WriteBool('StartUp', 'Pack', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.PackPhotoTable;
      R(CMDForm);
    end;

  if not FolderView and not DBTerminating then
    if GetParamStrDBBool('/BACKUP') or Settings.ReadBool('StartUp', 'BackUp', False) then
    begin
      CloseSplashWindow;
      EventLog('BackUp...');
      Settings.WriteBool('StartUp', 'BackUp', False);
      Application.CreateForm(TCMDForm, CMDForm);
      CMDForm.BackUpTable;
      R(CMDForm);
    end;
end;

class procedure TCommandLine.ProcessUserCommandLine;
var
  S: string;
  Password: string;
  ID: Integer;
begin
  if GetParamStrDBBool('/cmd') then
  begin
    CloseSplashWindow;
    DBTerminating := True;
  end;

  if GetParamStrDBBool('/SQLExec') then
  begin
    ExecuteQuery(AnsiDequotedStr(GetParamStrDBValue('/SQLExec'), '"'));
  end;

  if GetParamStrDBBool('/SQLExecFile') then
  begin
    S := AnsiDequotedStr(GetParamStrDBValue('/SQLExecFile'), '"');
    S := ReadTextFileInString(S);
    ExecuteQuery(S);
  end;

  if GetParamStrDBBool('/e') then
  begin
    S := AnsiDequotedStr(GetParamStrDBValue('/e'), '"');
    ID := GetIdByFileName(S);
    Password := AnsiDequotedStr(GetParamStrDBValue('/p'), '"');

    EncryptImageByFileName(nil, S, ID, Password, CRYPT_OPTIONS_NORMAL, False);
  end;

  if GetParamStrDBBool('/d') then
  begin
    S := AnsiDequotedStr(GetParamStrDBValue('/d'), '"');
    ID := GetIdByFileName(S);
    Password := AnsiDequotedStr(GetParamStrDBValue('/p'), '"');

    ResetPasswordImageByFileName(nil, S, ID, Password);
  end;

  if not FolderView then
  begin
    if AnsiUpperCase(ParamStr(1)) = '/GETPHOTOS' then
      if ParamStr(2) <> '' then
        ImportForm.FromDrive(ParamStr(2)[1]);
  end;
end;

end.
