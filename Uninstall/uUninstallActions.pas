unit uUninstallActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows,
  uActions,
  uInstallScope,
  SysUtils,
  uInstallUtils,
  Messages,
  uRuntime,
  uFileUtils,
  StrUtils,
  uConstants,
  uTranslate,
  ShellAPI,
  Registry,
  uActivationUtils,
  uUserUtils,
  uSysUtils,
  uShellUtils;

const
  InstallPoints_Close_PhotoDB = 1024 * 1024;
  DeleteFilePoints = 128 * 1024;
  UnInstallPoints_ShortCut = 128 * 1024;
  UnInstallPoints_FileAcctions = 512 * 1024;
  UninstallNotifyPoints_ShortCut = 1024 * 1024;
  DeleteRegistryPoints = 128 * 1024;

type
  TInstallCloseApplication = class(TInstallAction)
  public
    function CalculateTotalPoints: Int64; override;
    procedure Execute(Callback: TActionCallback); override;
  end;

  TUninstallFiles = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TInstallFileActions = class(TInstallAction)
  public
    function CalculateTotalPoints: Int64; override;
    procedure Execute(Callback: TActionCallback); override;
  end;

  TUninstallShortCuts = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TUninstallNotify = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

  TUninstallRegistry = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TUninstallFiles }

function TUninstallFiles.CalculateTotalPoints: Int64;
begin
  Result := CurrentInstall.Files.Count * DeleteFilePoints;
end;

procedure TUninstallFiles.Execute(Callback: TActionCallback);
var
  I: Integer;
  DiskObject: TDiskObject;
  Destination: string;
  Terminate: Boolean;
begin
  Terminate := False;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Destination := IncludeTrailingBackslash(ResolveInstallPath(DiskObject.FinalDestination)) + DiskObject.Name;
    if DiskObject is TFileObject then
      DeleteFile(Destination);
    if DiskObject is TDirectoryObject then
      DeleteDirectoryWithFiles(Destination);

    Callback(Self, I * DeleteFilePoints, CurrentInstall.Files.Count, Terminate);

    if Terminate then
      Break;
  end;
end;

{ TUninstallShortCuts }

function TUninstallShortCuts.CalculateTotalPoints: Int64;
var
  I: Integer;
  DiskObject: TDiskObject;
begin
  Result := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    Inc(Result, DiskObject.ShortCuts.Count * UnInstallPoints_ShortCut);
  end;
end;

procedure TUninstallShortCuts.Execute(Callback: TActionCallback);
var
  I, J: Integer;
  DiskObject: TDiskObject;
  CurentPosition: Int64;
  ShortcutPath: string;
begin
  CurentPosition := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    for J := 0 to DiskObject.ShortCuts.Count - 1 do
    begin
      Inc(CurentPosition, UnInstallPoints_ShortCut);
      ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Location);
      if StartsText('http', ShortcutPath) then
      begin
        DeleteFile(ShortcutPath);
        ShortcutPath := ResolveInstallPath(DiskObject.ShortCuts[J].Name);
        DeleteFile(ShortcutPath);
        Continue;
      end;
      DeleteFile(ShortcutPath);
    end;
  end;
end;

{ TUninstallNotify }

function TUninstallNotify.CalculateTotalPoints: Int64;
begin
  Result := UninstallNotifyPoints_ShortCut;
end;

procedure TUninstallNotify.Execute(Callback: TActionCallback);
var
  NotifyUrl: string;
  Version: string;
  ExeFileName: string;
begin
  Version := ProductMajorVersionVersion;
  ExeFileName := InstalledFileName;
  if ExeFileName <> '' then
    Version := ReleaseToString(GetExeVersion(ExeFileName));

  NotifyUrl := ResolveLanguageString(UnInstallNotifyURL) + '?v=' + Version + '&ac=' + TActivationManager.Instance.ApplicationCode;
  RunAsUser(NotifyUrl, NotifyUrl, NotifyUrl, False);
end;

{ TUninstallRegistry }

function TUninstallRegistry.CalculateTotalPoints: Int64;
begin
  Result := 5 * DeleteRegistryPoints;
end;

procedure TUninstallRegistry.Execute(Callback: TActionCallback);
var
  FReg: TRegistry;
  Terminated: Boolean;
begin
  Terminated := False;
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_CLASSES_ROOT;
    FReg.DeleteKey('\.photodb');
    FReg.DeleteKey('\PhotoDB.PhotodbFile\');
    FReg.DeleteKey('\.ids');
    FReg.DeleteKey('\PhotoDB.IdsFile\');
    FReg.DeleteKey('\.dbl');
    FReg.DeleteKey('\PhotoDB.DblFile\');
    FReg.DeleteKey('\.ith');
    FReg.DeleteKey('\PhotoDB.IthFile\');
    FReg.DeleteKey('\Directory\Shell\PhDBBrowse\');
    FReg.DeleteKey('\Drive\Shell\PhDBBrowse\');
  except
  end;
  FReg.Free;
  Callback(Self, 1 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_INSTALL;
    FReg.DeleteKey(RegRoot);
  except
  end;
  FReg.Free;
  Callback(Self, 2 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := HKEY_USER_WORK;
    FReg.DeleteKey(RegRoot);
  except
  end;
  FReg.Free;
  Callback(Self, 3 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Photo DataBase');
  except
  end;
  FReg.Free;
  Callback(Self, 4 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
  FReg := TRegistry.Create;
  try
    FReg.RootKey := Windows.HKEY_LOCAL_MACHINE;
    FReg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers\PhotoDBGetPhotosHandler');
    FReg.DeleteKey('\SOFTWARE\Classes\PhotoDB.AutoPlayHandler');
    FReg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlers\ShowPicturesOnArrival', True);
    FReg.DeleteValue('PhotoDBgetPhotosHandler');
  except
  end;
  FReg.Free;
  Callback(Self, 5 * DeleteRegistryPoints, CalculateTotalPoints, Terminated);
end;

{ TInstallCloseApplication }

function TInstallCloseApplication.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_Close_PhotoDB;
end;

procedure TInstallCloseApplication.Execute(Callback: TActionCallback);
const
  Timeout = 10000;
var
  WinHandle: HWND;
  StartTime: Cardinal;
begin
  inherited;
  WinHandle := FindWindow(nil, PChar(DBID));
  if WinHandle <> 0 then
  begin
    SendMessage(WinHandle, WM_CLOSE, 0, 0);
    StartTime := GetTickCount;
    while(true) do
    begin
      if (FindWindow(nil, PChar(DB_ID)) = 0) and (FindWindow(nil, PChar(DB_ID_CLOSING)) = 0) then
        Break;

      if (GetTickCount - StartTime) > Timeout then
        Break;

      Sleep(100);
    end;
  end;
end;

{ TInstallFileActions }

function TInstallFileActions.CalculateTotalPoints: Int64;
var
  I, J: Integer;
  DiskObject: TDiskObject;
begin
  Result := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    for J := 0 to DiskObject.Actions.Count - 1 do
      if DiskObject.Actions[J].Scope = asUninstall then
        Inc(Result, DiskObject.Actions.Count * UnInstallPoints_FileAcctions);
  end;
end;

procedure TInstallFileActions.Execute(Callback: TActionCallback);
var
  I, J: Integer;
  DiskObject: TDiskObject;
  CurentPosition: Int64;
  ObjectPath: string;
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
begin
  CurentPosition := 0;
  for I := 0 to CurrentInstall.Files.Count - 1 do
  begin
    DiskObject := CurrentInstall.Files[I];
    for J := 0 to DiskObject.Actions.Count - 1 do
    begin
      if DiskObject.Actions[J].Scope = asUninstall then
      begin
        Inc(CurentPosition, UnInstallPoints_FileAcctions);
        ObjectPath := ResolveInstallPath(IncludeTrailingBackslash(DiskObject.FinalDestination) + DiskObject.Name);

        { fill with known state }
        FillChar(StartInfo, SizeOf(TStartupInfo), #0);
        FillChar(ProcInfo, SizeOf(TProcessInformation), #0);
        try
          with StartInfo do begin
            cb := SizeOf(StartInfo);
            dwFlags := STARTF_USESHOWWINDOW;
            wShowWindow := SW_NORMAL;
          end;

          CreateProcess(nil, PChar('"' + ObjectPath + '"' + ' ' + DiskObject.Actions[J].CommandLine), nil, nil, False,
                      CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS,
                      nil, PChar(ExcludeTrailingPathDelimiter(ExtractFileDir(ObjectPath))), StartInfo, ProcInfo);

          WaitForSingleObject(ProcInfo.hProcess, 30000);
        finally
          CloseHandle(ProcInfo.hProcess);
          CloseHandle(ProcInfo.hThread);
        end;
      end;

    end;
  end;
end;

end.
