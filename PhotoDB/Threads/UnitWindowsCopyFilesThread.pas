unit UnitWindowsCopyFilesThread;

interface

uses
  Classes, Windows, DBCommon, SysUtils, Forms, Dolphin_DB, uFileUtils, uMemory,
  uLogger, uDBUtils, uDBForm, UnitDBDeclare, UnitDBKernel, uDBThread;

type
  TWindowsCopyFilesThread = class(TDBThread)
  private
    { Private declarations }
    FHandle: Hwnd;
    FSrc: TStrings;
    FDest: string;
    FMove, FAutoRename: Boolean;
    FOwnerExplorerForm: TDBForm;
    FID: Integer;
    FParams: TEventFields;
    FValue: TEventValues;
    FOnDone: TNotifyEvent;
    procedure CorrectPath(Owner : TDBForm; Src: TStrings; Dest: string);
    procedure KernelEventCallBack(ID: Integer; Params: TEventFields; Value: TEventValues);
    procedure KernelEventCallBackSync;
    procedure DoOnDone;
  protected
    procedure Execute; override;
  public
    constructor Create(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean;
      AutoRename: Boolean; OwnerExplorerForm: TDBForm; OnDone: TNotifyEvent = nil);
    destructor Destroy; override;
  end;

implementation

uses ExplorerUnit;

{ TWindowsCopyFilesThread }

constructor TWindowsCopyFilesThread.Create(Handle: Hwnd; Src: TStrings; Dest: string; Move, AutoRename: Boolean;
   OwnerExplorerForm: TDBForm; OnDone: TNotifyEvent = nil);
begin
  inherited Create(nil, False);
  FOnDone := OnDone;
  FHandle := Handle;
  FSrc := TStringList.Create;
  FSrc.Assign(Src);
  FDest := Dest;
  FMove := Move;
  FAutoRename := AutoRename;
  FOwnerExplorerForm := OwnerExplorerForm;
end;

destructor TWindowsCopyFilesThread.Destroy;
begin
  F(FSrc);
  inherited;
end;

procedure TWindowsCopyFilesThread.DoOnDone;
begin
  FOnDone(Self);
end;

procedure TWindowsCopyFilesThread.CorrectPath(Owner : TDBForm; Src: TStrings; Dest: string);
var
  I : Integer;
  FN, Adest : string;
begin
  Dest := ExcludeTrailingBackslash(Dest);
  for I := 0 to Src.Count - 1 do
  begin
    FN := Dest + '\' + ExtractFileName(Src[I]);
    if DirectoryExists(FN) then
    begin
      Adest := Dest + '\' + ExtractFileName(Src[I]);
      RenameFolderWithDB(KernelEventCallBack, Src[I], Adest, False);
    end;
    if FileExistsSafe(FN) then
    begin
      Adest := Dest + '\' + ExtractFileName(Src[I]);
      RenameFileWithDB(KernelEventCallBack, Src[I], Adest, GetIDByFileName(Src[I]), True);
    end;
  end;
end;

procedure TWindowsCopyFilesThread.Execute;
var
  Res: Boolean;
begin
  FreeOnTerminate := True;
  try
    Res := CopyFilesSynch(FHandle, FSrc, FDest, FMove, FAutoRename) = 0;

    if Res and (FOwnerExplorerForm <> nil) and FMove then
      CorrectPath(FOwnerExplorerForm, FSrc, FDest);
  except
    on e : Exception do
      EventLog(e.Message);
  end;
  if Assigned(FOnDone) then
    SynchronizeEx(DoOnDone);
end;

procedure TWindowsCopyFilesThread.KernelEventCallBack(ID: Integer;
  Params: TEventFields; Value: TEventValues);
begin
  FID := ID;
  FParams := Params;
  FValue := Value;
  Synchronize(KernelEventCallBackSync);
end;

procedure TWindowsCopyFilesThread.KernelEventCallBackSync;
begin
  DBKernel.DoIDEvent(FOwnerExplorerForm, FID, FParams, FValue);
end;

end.

