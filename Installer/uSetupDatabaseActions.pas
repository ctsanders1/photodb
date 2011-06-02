unit uSetupDatabaseActions;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Windows, uActions, SysUtils, uAssociations, uInstallScope, uConstants,
  uUserUtils;

const
  InstallPoints_StartProgram = 1024 * 1024;
  InstallPoints_SetUpDatabaseProgram = 1024 * 1024;

type
  TSetupDatabaseActions = class(TInstallAction)
  public
    function CalculateTotalPoints : Int64; override;
    procedure Execute(Callback : TActionCallback); override;
  end;

implementation

{ TSetupDatabaseActions }

function TSetupDatabaseActions.CalculateTotalPoints: Int64;
begin
  Result := InstallPoints_StartProgram + InstallPoints_SetUpDatabaseProgram;
end;

procedure TSetupDatabaseActions.Execute(Callback: TActionCallback);
var
  PhotoDBExeFile: string;
  Terminate: Boolean;
  HProcess: THandle;
  ExitCode,
  StartTime: Cardinal;
begin
  inherited;
  PhotoDBExeFile := IncludeTrailingBackslash(CurrentInstall.DestinationPath) + PhotoDBFileName;

  HProcess := RunAsUser(PhotoDBExeFile, PhotoDBExeFile + ' /install /NoLogo', CurrentInstall.DestinationPath);

  Callback(Self, InstallPoints_StartProgram, CalculateTotalPoints, Terminate);

  StartTime := GetTickCount;
  repeat
    Sleep(100);

    GetExitCodeProcess(HProcess, ExitCode);
  until (ExitCode <> STILL_ACTIVE) or (GetTickCount - StartTime > 10 * 1000);

  Callback(Self, InstallPoints_StartProgram + InstallPoints_SetUpDatabaseProgram, CalculateTotalPoints, Terminate);
end;


end.
