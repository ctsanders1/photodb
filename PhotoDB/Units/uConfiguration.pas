unit uConfiguration;

interface

uses
  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  uConstants;

function GetAppDataDirectory: string;

implementation

function GetAppDataDirectory: string;
begin
  Result := GetAppDataDir + PHOTO_DB_APPDATA_DIRECTORY;
  if not FileExistsSafe(Result) then
    CreateDirA(Result);
end;

end.
