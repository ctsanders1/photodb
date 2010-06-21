unit uFileUtils;

interface

uses Windows, Classes, SysUtils, ACLApi, AccCtrl,  ShlObj, ActiveX, uConstants;
                                                
function GetAppDataDirectory: string;

implementation

function SetDirectoryWriteRights(lPath : String): Dword;
var
  pDACL: PACL;
  pEA: PEXPLICIT_ACCESS_A;
  R: DWORD;
begin
  pEA := AllocMem(SizeOf(EXPLICIT_ACCESS));
  BuildExplicitAccessWithName(pEA, 'EVERYONE', GENERIC_WRITE or
GENERIC_READ, GRANT_ACCESS, SUB_OBJECTS_ONLY_INHERIT);
  R := SetEntriesInAcl(1, pEA, nil, pDACL);
  if R = ERROR_SUCCESS then
  begin
    if SetNamedSecurityInfo(PChar(lPath), SE_FILE_OBJECT,
DACL_SECURITY_INFORMATION, nil, nil, pDACL, nil) <> ERROR_SUCCESS then
      result := 2
    else
      result := 0;
   LocalFree(Cardinal(pDACL));
 end
 else
   result := 1;
end;

function GetSpecialFolder(hWindow: HWND; Folder: Integer): String;
var
  pMalloc: IMalloc;
  pidl: PItemIDList;
  Path: PChar;
begin
  // get IMalloc interface pointer
  if (SHGetMalloc(pMalloc) <> S_OK) then
  begin
   MessageBox(hWindow, 'Couldn''t get pointer to IMalloc interface.','SHGetMalloc(pMalloc)', 16);
   exit;
  end;
  // retrieve path
  SHGetSpecialFolderLocation(hWindow, Folder, pidl);
  GetMem(Path, MAX_PATH);
  SHGetPathFromIDList(pidl, Path);
  Result := Path;
  FreeMem(Path);
  // free memory allocated by SHGetSpecialFolderLocation
  pMalloc.Free(pidl);
end;

function GetSpecialFolder2(FolderID : longint) : string;
var
  Path : pchar;
  idList : PItemIDList;
begin
  GetMem(Path, MAX_PATH);
  SHGetSpecialFolderLocation(0, FolderID, idList);
  SHGetPathFromIDList(idList, Path);
  Result := string(Path);
  FreeMem(Path);
end;

function GetDrives: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_Drives));
end;

function GetMyMusic: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(13));
end;

function GetTmpInternetDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_INTERNET_CACHE));
end;

function GetCookiesDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_COOKIES));
end;

function GetHistoryDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_HISTORY));
end;

function GetDesktop: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_DESKTOP));
end;

function GetDesktopDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_DESKTOPDIRECTORY));
end;

function GetProgDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_PROGRAMS));
end;

function GetMyDocDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_PERSONAL));
end;

function GetFavDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_FAVORITES));
end;

function GetStartUpDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_STARTUP));
end;

function GetRecentDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_RECENT));
end;

function GetSendToDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_SENDTO));
end;

function GetStartMenuDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_STARTMENU));
end;

function GetNetHoodDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_NETHOOD));
end;

function GetFontsDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_FONTS));
end;

function GetTemplateDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_TEMPLATES));
end;

function GetAppDataDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_APPDATA));
end;

function GetPrintHoodDir: string;
begin
  Result := IncludeTrailingBackslash(GetSpecialFolder2(CSIDL_PRINTHOOD));
end;

function GetAppDataDirectory: string;
begin
  Result := GetAppDataDir + PHOTO_DB_APPDATA_DIRECTORY;
end;

end.