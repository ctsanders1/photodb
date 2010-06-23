unit uFastLoad;

interface

uses WIndows, SysUtils, UnitDBThread, uTime;

type
  TLoad = class(TObject)
  private  
    //FAST LOAD
    LoadDBKernelIconsThread,
    LoadDBSettingsThread,
    LoadCRCCheckThread : TDBThread;
  public
    constructor Create;
    destructor Destroy;
    class function Instance : TLoad;
    //Starts
    procedure StartDBKernelIconsThread;
    procedure StartDBSettingsThread;
    procedure StartCRCCheckThread;
    //Requareds
    procedure RequaredCRCCheck;
    procedure RequaredDBKernelIcons;  
    procedure RequaredDBSettings;
  end;

implementation

uses
UnitLoadDBSettingsThread,
UnitLoadDBKernelIconsThread,
UnitLoadCRCCheckThread;

var
  SLoadInstance : TLoad = nil;

{ TLoad }

constructor TLoad.Create;
begin
  LoadDBKernelIconsThread := nil;
  LoadDBSettingsThread := nil;
  LoadCRCCheckThread := nil;
end;

destructor TLoad.Destroy;
begin

end; 

procedure TLoad.StartDBKernelIconsThread;
begin
  LoadDBKernelIconsThread := TLoadDBKernelIconsThread.Create(False);
end;

class function TLoad.Instance: TLoad;
begin
  if SLoadInstance = nil then
    SLoadInstance := TLoad.Create;

  Result := SLoadInstance;
end;

procedure TLoad.StartDBSettingsThread;
begin
  LoadDBSettingsThread := TLoadDBSettingsThread.Create(False);
end;

procedure TLoad.StartCRCCheckThread;
begin
 LoadCRCCheckThread := TLoadCRCCheckThread.Create(False);
end;

procedure TLoad.RequaredCRCCheck;
begin    
  TW.I.Start('TLoad.RequaredCRCCheck');
  if LoadCRCCheckThread <> nil then
  begin
    if not LoadCRCCheckThread.IsTerminated then
      WaitForSingleObject(LoadCRCCheckThread.Handle, INFINITE);
    FreeAndNil(LoadCRCCheckThread);
  end;
end;

procedure TLoad.RequaredDBKernelIcons;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  if LoadDBKernelIconsThread <> nil then
  begin
    if not LoadDBKernelIconsThread.IsTerminated then
      WaitForSingleObject(LoadDBKernelIconsThread.Handle, INFINITE);
    FreeAndNil(LoadDBKernelIconsThread);
  end;
end;

procedure TLoad.RequaredDBSettings;
begin
  TW.I.Start('TLoad.RequaredDBKernelIcons');
  if LoadDBSettingsThread <> nil then
  begin
    if not LoadDBSettingsThread.IsTerminated then
      WaitForSingleObject(LoadDBSettingsThread.Handle, INFINITE);
    FreeAndNil(LoadDBSettingsThread);
  end;
end;

end.