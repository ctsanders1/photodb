unit uPortableDeviceManager;

interface

uses
  System.SysUtils,
  Dmitry.Utils.System,
  uPortableClasses,
  uWIAClasses,
  uAppUtils,
  uWPDClasses;

function CreateDeviceManagerInstance: IPManager;
function GetDeviceEventManager: IPEventManager;
function IsWPDSupport: Boolean;
procedure ThreadCleanUp(ThreadID: THandle);

implementation

function IsWPDSupport: Boolean;
var
  IsWPDAvailable: Boolean;
begin
  if GetParamStrDBBool('/FORCEWIA') then
    Exit(False);
  if GetParamStrDBBool('/FORCEWPD') then
    Exit(True);

  IsWPDAvailable := False;
  //Vista SP1
  if (TOSVersion.Major = 6) and (TOSVersion.Minor = 0) and (TOSVersion.ServicePackMajor >= 1) then
    IsWPDAvailable := True;
  //Windows7 and higher
  if (TOSVersion.Major = 6) and (TOSVersion.Minor >= 1) then
    IsWPDAvailable := True;

  Result := IsWPDAvailable;
end;

function CreateDeviceManagerInstance: IPManager;
begin
  if IsWPDSupport then
    Result := TWPDDeviceManager.Create
  else
    Result := TWIADeviceManager.Create;
end;

function GetDeviceEventManager: IPEventManager;
begin
  if IsWPDSupport then
    Result := WPDEventManager
  else
    Result := WiaEventManager;
end;

procedure ThreadCleanUp(ThreadID: THandle);
begin
  if not IsWPDSupport then
    CleanUpWIA(ThreadID);
end;

end.
