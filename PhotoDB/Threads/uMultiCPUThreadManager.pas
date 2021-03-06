unit uMultiCPUThreadManager;

interface

uses
  System.Types,
  System.Math,
  System.Classes,
  System.SyncObjs,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Forms,
  Dmitry.Utils.System,
  uMemory,
  uTime,
  uGOM,
  uLogger,
  uGUIDUtils,
  uThreadEx,
  uThreadForm;

type
  TMultiCPUThread = class(TThreadEx)
  private
    FMode: Integer;
    FSyncEvent: Integer;
    FWorkingInProgress: Boolean;
    FThreadNumber: Integer;
    FOwner: TMultiCPUThread;
    FValid: Boolean;
    procedure DoMultiProcessorWork;
  protected
    procedure DoMultiProcessorTask; virtual; abstract;
    procedure CheckThreadPriority; override;
  public
    constructor Create(AOwnerForm: TThreadForm; AState: TGUID);
    destructor Destroy; override;
    procedure StartMultiThreadWork;
    property Mode: Integer read FMode write FMode;
    property SyncEvent: Integer read FSyncEvent write FSyncEvent;
    property WorkingInProgress: Boolean read FWorkingInProgress write FWorkingInProgress;
    property Owner: TMultiCPUThread read FOwner write FOwner;
    property Valid: Boolean read FValid write FValid;
  end;

type
  TThreadPoolCustom = class(TObject)
  private
    FAvaliableThreadList: TList;
    FBusyThreadList: TList;
    FTerminating : Boolean;
    FSync: TCriticalSection;
    FIsStated: Boolean;
    function GetAvaliableThreadsCount: Integer;
    function GetBusyThreadsCount: Integer;
  protected
    //
    procedure ThreadsCheck(Thread: TMultiCPUThread); virtual;
    procedure AddAvaliableThread(Thread: TMultiCPUThread);
    procedure CheckBusyThreads;
    procedure Lock;
    procedure Unlock;
  protected
    procedure AddNewThread(Thread: TMultiCPUThread); virtual; abstract;
    function GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
    procedure StartThread(Sender, Thread: TMultiCPUThread);
  public
    constructor Create;
    destructor Destroy; override;
    procedure CloseAndWaitForAllThreads;
    function GetBusyThreadsCountForThread(Thread: TMultiCPUThread): Integer;
    property AvaliableThreadsCount : Integer read GetAvaliableThreadsCount;
    property BusyThreadsCount : Integer read GetBusyThreadsCount;
  end;

const
  MAX_THREADS_USE = 4;

var
  MultiThreadManagers : TList = nil;

implementation

{ TThreadPoolCustom }

function GUIDToString(GUID: TGUID): string;
begin
  Result := Format('%d%d%d%d%d%d%d%d%d%d%d', [GUID.D1, GUID.D2, GUID.D3,
    GUID.D4[0], GUID.D4[1], GUID.D4[2], GUID.D4[3], GUID.D4[4],
    GUID.D4[5], GUID.D4[6], GUID.D4[7]]);
end;

procedure ValidateThread(Thread: TMultiCPUThread);
begin
  if not Thread.Valid then
    raise Exception.Create('Thread validation failed!');
end;

procedure TThreadPoolCustom.AddAvaliableThread(Thread: TMultiCPUThread);
begin
  FBusyThreadList.Add(Thread);
  Thread.FThreadNumber := FAvaliableThreadList.Count + FBusyThreadList.Count;
  Thread.Valid := True;
end;

constructor TThreadPoolCustom.Create;
begin
  FSync := TCriticalSection.Create;
  FAvaliableThreadList := TList.Create;
  FBusyThreadList := TList.Create;
  FTerminating := False;
  FIsStated := False;
  MultiThreadManagers.Add(Self);
end;

procedure TThreadPoolCustom.CloseAndWaitForAllThreads;
var
  I: Integer;
  FThreads, FWaitThreads : TList;
begin;
  FTerminating := True;
  FThreads := TList.Create;
  FWaitThreads := TList.Create;
  try
    //wait for all threads
    while True do
    begin
      Sleep(10);
      Application.ProcessMessages;
      FSync.Enter;
      try
        if FAvaliableThreadList.Count + FBusyThreadList.Count + FWaitThreads.Count = 0 then
          Break;

        CheckBusyThreads;
        //remove all avaliable thread from pool
        FThreads.Assign(FAvaliableThreadList);
        FAvaliableThreadList.Clear;

        for I := 0 to FThreads.Count - 1 do
        begin
          if GOM.IsObj(FThreads[I]) then
          begin
            try
              TMultiCPUThread(FThreads[I]).FMode := 0;
              TMultiCPUThread(FThreads[I]).Priority := tpTimeCritical;
            except
              //thread could be finished, so SetPriority can throw an exception
            end;
          end;
        end;
      finally
        FSync.Leave;
      end;

      //call thread to terminate
      for I := 0 to FThreads.Count - 1 do
        SetEvent(TMultiCPUThread(FThreads[I]).FSyncEvent);

      //add thread to wait list
      for I := 0 to FThreads.Count - 1 do
        FWaitThreads.Add(FThreads[I]);
      FThreads.Clear;

      //wait for all threads using GOM
      for I := 0 to FWaitThreads.Count - 1 do
      begin
        if not GOM.IsObj(FWaitThreads[I]) then
        begin
          FWaitThreads.Delete(I);
          Break;
        end;
      end;
    end;
  finally
    F(FThreads);
    F(FWaitThreads);
  end;
end;

destructor TThreadPoolCustom.Destroy;
begin
  F(FSync);
  F(FAvaliableThreadList);
  F(FBusyThreadList);
  MultiThreadManagers.Remove(Self);
  inherited;
end;

function TThreadPoolCustom.GetAvaliableThread(Sender: TMultiCPUThread): TMultiCPUThread;
begin
  Result := nil;

  while Result = nil do
  begin
    if FTerminating then
      Exit;

    ThreadsCheck(Sender);

    FSync.Enter;
    try
      if FAvaliableThreadList.Count > 0 then
      begin
        Result := FAvaliableThreadList[0];
        ValidateThread(Result);
        Result.WorkingInProgress := True;
        FAvaliableThreadList.Remove(Result);
        FBusyThreadList.Add(Result);
      end;
    finally
      FSync.Leave;
    end;
  end;
end;

function TThreadPoolCustom.GetAvaliableThreadsCount: Integer;
begin
  FSync.Enter;
  try
    Result := FAvaliableThreadList.Count;
  finally
    FSync.Leave;
  end;
end;

function TThreadPoolCustom.GetBusyThreadsCount: Integer;
begin
  FSync.Enter;
  try
    Result := FBusyThreadList.Count;
  finally
    FSync.Leave;
  end;
end;

function TThreadPoolCustom.GetBusyThreadsCountForThread(
  Thread: TMultiCPUThread): Integer;
var
  I : Integer;
begin
  FSync.Enter;
  try
    CheckBusyThreads;
    Result := 0;
    for I := 0 to FBusyThreadList.Count - 1 do
    begin
      ValidateThread(FBusyThreadList[I]);
      if TMultiCPUThread(FBusyThreadList[I]).Owner = Thread then
        Inc(Result);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TThreadPoolCustom.Lock;
begin
  FSync.Enter;
end;

procedure TThreadPoolCustom.StartThread(Sender, Thread: TMultiCPUThread);
begin
  ValidateThread(Thread);
  Thread.WorkingInProgress := True;
  Thread.FOwner := Sender;
  Sender.RegisterSubThread(Thread);
  TW.I.Start('Resume thread:' + IntToStr(Thread.ThreadID));
  SetEvent(TMultiCPUThread(Thread).SyncEvent);
  ValidateThread(Thread);
end;

procedure TThreadPoolCustom.CheckBusyThreads;
var
  I: Integer;
begin
  for I := FBusyThreadList.Count - 1 downto 0 do
  begin
    ValidateThread(FBusyThreadList[I]);
    if not GOM.IsObj(FBusyThreadList[I]) then
    begin
      FBusyThreadList.Delete(I);
      Continue;
    end;
    if not TMultiCPUThread(FBusyThreadList[I]).FWorkingInProgress then
    begin
      FAvaliableThreadList.Add(FBusyThreadList[I]);
      FBusyThreadList.Delete(I);
    end;
  end;
end;

procedure TThreadPoolCustom.ThreadsCheck(Thread: TMultiCPUThread);
var
  ThreadHandles: array [0 .. MAX_THREADS_USE - 1] of THandle;
  I, ThreadsCount: Integer;
  S: string;
begin
  FSync.Enter;
  try
    AddNewThread(Thread);
  finally
    FSync.Leave;
  end;
  ThreadsCount := 0;
  while FAvaliableThreadList.Count = 0 do
  begin
    FSync.Enter;
    try
      CheckBusyThreads;

      if FAvaliableThreadList.Count > 0 then
        Break;

      ThreadsCount := FBusyThreadList.Count;
      for I := 0 to ThreadsCount - 1 do
      begin
        ValidateThread(FBusyThreadList[I]);
        ThreadHandles[I] := TMultiCPUThread(FBusyThreadList[I]).FEvent;
      end;

      S := 'WaitForMultipleObjects: ' + IntToStr(FBusyThreadList.Count) + ' - ';
      for I := 0 to ThreadsCount - 1 do
        S := S + ',' + IntToStr(TMultiCPUThread(FBusyThreadList[I]).FSyncEvent);
      TW.I.Start(S);

    finally
      FSync.Leave;
    end;
    if ThreadsCount > 0 then
      WaitForMultipleObjects(ThreadsCount, @ThreadHandles[0], False, IIF(FIsStated, 1000, 10));

    TW.I.Start('WaitForMultipleObjects END');
  end;

  FIsStated := True;
end;

procedure TThreadPoolCustom.Unlock;
begin
  FSync.Leave;
end;

{ TMultiCPUThread }

procedure TMultiCPUThread.CheckThreadPriority;
begin
  if ThreadForm.Active then
  begin
    if FThreadNumber = 1 then
      Priority := tpNormal
    else
      Priority := tpLowest
  end else
    Priority := tpIdle;
end;

constructor TMultiCPUThread.Create(AOwnerForm: TThreadForm; AState: TGUID);
begin
  inherited Create(AOwnerForm, AState);
  FSyncEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
  FWorkingInProgress := True;
  FMode := -1;
  FValid := False;
end;

destructor TMultiCPUThread.Destroy;
begin
  inherited;
end;

procedure TMultiCPUThread.DoMultiProcessorWork;
begin
  while True do
  begin
    IsTerminated := False;
    try
      try
        try
          DoMultiProcessorTask;

          TW.I.Start('UnRegisterSubThread: ' + IntToStr(FEvent));
          if GOM.IsObj(ParentThread) then
            ParentThread.UnRegisterSubThread(Self);

          Valid := True;
          if Mode = 0 then
            Exit;
        except
          on E: Exception do
            EventLog('TExplorerThread.ProcessThreadImages' + E.message);
        end;
      finally
        TW.I.Start('SetEvent: ' + IntToStr(FEvent));
        WorkingInProgress := False;
        if Mode > 0 then
          SetEvent(FEvent);
      end;
    finally
      TW.I.Start('Suspended: ' + IntToStr(FEvent));
      if Mode <> 0 then
        WaitForSingleObject(FSyncEvent, INFINITE);
      TW.I.Start('Resumed: ' + IntToStr(FEvent));
      WorkingInProgress := True;
    end;
  end;
end;

procedure TMultiCPUThread.StartMultiThreadWork;
begin
  Priority := tpIdle;
  FEvent := CreateEvent(nil, False, False, PWideChar(GUIDToString(GetGUID)));
  TW.I.Start('CreateEvent: ' + IntToStr(FEvent));
  try
    DoMultiProcessorWork;
  finally
    CloseHandle(FEvent);
    CloseHandle(FSyncEvent);
    FEvent := 0;
    FSyncEvent := 0;
  end;
end;

initialization

 MultiThreadManagers := TList.Create;

finalization

 F(MultiThreadManagers);

end.


