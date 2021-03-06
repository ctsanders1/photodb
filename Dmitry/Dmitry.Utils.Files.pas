unit Dmitry.Utils.Files;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Math,
  System.Win.Registry,
  Winapi.ShlObj,
  Winapi.ActiveX,
  Winapi.ShellAPI,
  Winapi.ACLApi,
  Winapi.AccCtrl,

  Dmitry.Memory,
  Dmitry.Utils.System,
  Dmitry.Utils.ShortCut,
  Dmitry.Utils.Network;

type
  TDriveState = (DS_NO_DISK, DS_UNFORMATTED_DISK, DS_EMPTY_DISK, DS_DISK_WITH_FILES);

type
  TCharBuffer = array of Char;

type
  TFileProgress = procedure(FileName: string; BytesTotal, BytesDone: Int64; var BreakOperation: Boolean) of object;
  TSimpleFileProgress = reference to procedure(FileName: string; BytesTotal, BytesDone: Int64; var BreakOperation: Boolean);

function IsDrive(S: string): Boolean;
function IsShortDrive(S: string): Boolean;
function IsNetworkServer(S: string): Boolean;
function IsNetworkShare(S: string): Boolean;

function CreateDirA(Dir: string): Boolean;
function FileExistsSafe(FileName: string) : Boolean;
function DirectoryExistsSafe(DirectoryPath: string) : Boolean;
function ResolveShortcut(Wnd: HWND; ShortcutPath: string): string;
function FileExistsEx(const FileName: TFileName) :Boolean;
function GetFileDateTime(FileName: string): TDateTime;
function GetFileNameWithoutExt(FileName: string): string;
function GetDirectorySize(Folder: string): Int64;
function GetFileSize(FileName: string): Int64;
function GetFileSizeByName(FileName: string): Int64;
function LongFileName(ShortName: string): string;
function LongFileNameW(ShortName: string): string;
function CopyFilesSynch(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean): Integer;
procedure Copy_Move(Handle: THandle; Copy: Boolean; FileList: TStrings);
function Mince(PathToMince: string; InSpace: Integer): string;
function WindowsCopyFile(FromFile, ToDir: string): Boolean;
function WindowsCopyFileSilent(FromFile, ToDir: string): Boolean;
function DateModify(FileName: string): TDateTime;
function GetFileDescription(FileName: string; UnknownFileDescription: string): string;
function MrsGetFileType(StrFilename: string): string;
function WipeFile(FileName: string; WipeCycles: Integer = 1; Progress: TSimpleFileProgress = nil): Boolean;
function DeleteFiles(Handle: HWnd; Files: TStrings; ToRecycle: Boolean): Integer;
function GetCDVolumeLabelEx(CDName: Char): string;
function GetDriveVolumeLabel(CDName: AnsiChar): string;
function DriveState(Driveletter: AnsiChar): TDriveState;
function SilentDeleteFile(Handle: HWnd; FileName: string; ToRecycle: Boolean;
  HideErrors: Boolean = False): Integer;
function SilentDeleteFiles(Handle: HWnd; Names: TStrings; ToRecycle: Boolean;
  HideErrors: Boolean = False): Integer;
procedure DeleteDirectoryWithFiles(DirectoryName: string);
procedure GetDirectoresOfPath(Dir: string; Listing: TStrings);
procedure GetFilesOfPath(Dir: string; Listing: TStrings);
procedure DelDir(Dir: string; Mask: string);
function ReadTextFileInString(FileName: string): string;
function ExtInMask(Mask: string; Ext: string): Boolean;
function GetExt(Filename: string): string;
function ProgramDir: string;
function GetConvertedFileName(FileName, NewEXT: string): string;
function GetConvertedFileNameWithDir(FileName, Dir, NewEXT: string): string;
procedure TryOpenFSForRead(var FS: TFileStream; FileName: string; DelayReadFileOperation: Integer);
function GetDirListing(Dir: String; Mask: string): TArray<string>;
function GetCommonDirectory(FileNames: TStrings): string;

function IsDirectoryHasDirectories(const Directory: string): Boolean;
function GetAppDataDir: string;
procedure ResetFileAttributes(FileName: string; FA: Integer);

var
  CopyFilesSynchCount: Integer = 0;

implementation

function WipeFile(FileName: string; WipeCycles: Integer = 1; Progress: TSimpleFileProgress = nil): Boolean;
var
  Buffer: array [0 .. 4095] of Byte;
  Max, N: Int64;
  I: Integer;
  FS: TFileStream;
  BreakOperation: Boolean;

  procedure RandomizeBuffer;
  var
    I: Integer;
  begin
    for I := Low(Buffer) to High(Buffer) do
      Buffer[I] := Random(256);
  end;

begin
  Result := True;
  BreakOperation := False;
  FS := TFileStream.Create(FileName, fmOpenReadWrite or fmShareExclusive);
  try
    for I := 1 to WipeCycles do
    begin
      RandomizeBuffer;
      Max := FS.Size;
      FS.Position := 0;
      while Max > 0 do
      begin
        if Max > SizeOf(Buffer) then
          N := SizeOf(Buffer)
        else
          N := Max;
        FS.Write(Buffer, N);
        Max := Max - N;

        if Assigned(Progress) then
        begin
          Progress(FileName, FS.Size, FS.Position, BreakOperation);
          if BreakOperation then
            Exit(False);
        end;
      end;
      FlushFileBuffers(FS.Handle);
    end;
  finally
    F(FS);
  end;
end;

procedure ResetFileAttributes(FileName: string; FA: Integer);
begin
  if (FA and faHidden) <> 0 then
    FA := FA - fahidden;
  if (FA and faReadOnly) <> 0 then
    FA := FA - faReadOnly;
  if (FA and faSysFile) <> 0 then
    FA := FA - faSysFile;
  FileSetAttr(FileName, FA);
end;

procedure TryOpenFSForRead(var FS: TFileStream; FileName: string; DelayReadFileOperation: Integer);
var
  I: Integer;
  OldMode: Cardinal;
begin
  FS := nil;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    for I := 1 to 20 do
    begin
      try
        FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
        Break;
      except
        if GetLastError in [0, ERROR_PATH_NOT_FOUND, ERROR_INVALID_DRIVE, ERROR_NOT_READY,
                            ERROR_FILE_NOT_FOUND, ERROR_GEN_FAILURE, ERROR_INVALID_NAME] then
          Exit;
        Sleep(DelayReadFileOperation);
      end;
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function IsNetworkServer(S: string): Boolean;
begin
  Result := False;
  S := ExcludeTrailingPathDelimiter(S);
  if (Length(S) > 2) and (Copy(S, 1, 2) = '\\') and (Copy(S, 3, 1) <> '\') and (PosEx('\', S, 3) = 0) then
    Result := True;
end;

function IsNetworkShare(S: string): Boolean;
begin
  Result := False;
  S := ExcludeTrailingPathDelimiter(S);
  if (Length(S) > 2) and (Copy(S, 1, 2) = '\\') and (Copy(S, 3, 1) <> '\') and (PosEx('\', S, PosEx('\', S, 3) + 1) = 0) then
    Result := True;
end;

function IsShortDrive(S: string): Boolean;
begin
  Result := (Length(S) = 2) and (S[2] = ':');
end;

function IsDrive(S: string): Boolean;
begin
  Result := IsShortDrive(S) or ((Length(S) = 3) and (S[2] = ':') and (S[3] = '\'));
end;

function CreateDirA(Dir: string): Boolean;
var
  I: Integer;
begin
  Result := DirectoryExistsSafe(Dir);
  if Result then
    Exit;
  Dir := ExcludeTrailingBackslash(Dir);

  if Length(Dir) < 3 then
    Exit;
  for I := 1 to Length(Dir) do
    try
      if (Dir[I] = '\') or (I = Length(Dir)) then
        if CreateDir(ExcludeTrailingBackslash(Copy(Dir, 1, I))) then
          Result := I = Length(Dir);
    except
      Result := False;
      Exit;
    end;
end;

function IsDirectoryHasDirectories(const Directory: string): Boolean;
var
  FI: WIN32_FIND_DATA;
  OldMode: Cardinal;
  H: THandle;
begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try

    H := FindFirstFileEx(
          PChar(IncludeTrailingPathDelimiter(Directory) + '*'),
          FindExInfoStandard,
          @FI,
          FindExSearchLimitToDirectories,
          nil,
          0);
    try
      if (H = INVALID_HANDLE_VALUE) then
        Exit(False);

      repeat
        if (string(fi.cFileName) <> '.') and (fi.cFileName <> '..') and (fi.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY > 0) then
          Exit(True)
      until (not FindNextFile(H, FI));

    finally
      Winapi.Windows.FindClose(H);
    end;

  finally
    SetErrorMode(OldMode);
  end;
end;

function FileExistsSafe(FileName: string): Boolean;
var
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := FileExists(FileName);
  finally
    SetErrorMode(OldMode);
  end;
end;

function DirectoryExistsSafe(DirectoryPath: string) : Boolean;
var
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DirectoryExists(DirectoryPath);
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetFileNameWithoutExt(FileName: string): string;
var
  I, N: Integer;
begin
  Result := '';
  if FileName = '' then
    Exit;
  N := 0;
  for I := Length(FileName) - 1 downto 1 do
    if FileName[I] = '\' then
    begin
      N := I;
      Break;
    end;
  Delete(FileName, 1, N);
  if FileName <> '' then
    if FileName[Length(FileName)] = '\' then
      Delete(FileName, Length(FileName), 1);
  for I := Length(FileName) downto 1 do
  begin
    if FileName[I] = '.' then
    begin
      FileName := Copy(FileName, 1, I - 1);
      Break;
    end;
  end;
  Result := FileName;
end;

function FileExistsEx(const FileName :TFileName) : Boolean;
var
  Code :DWORD;
begin
  Code := GetFileAttributes(PWideChar(FileName));
  Result := (Code <> DWORD(-1)) and (Code and FILE_ATTRIBUTE_DIRECTORY = 0);
end;

function ResolveShortcut(Wnd: HWND; ShortcutPath: string): string;
var
  ShortCut: TShortCut;
begin
  ShortCut:= TShortCut.Create(ShortcutPath);
  try
    Result := ShortCut.Path;
  finally
    ShortCut.Free;
  end;
end;

function SetDirectoryWriteRights(lPath : String): Dword;
var
  pDACL: PACL;
  pEA: PEXPLICIT_ACCESS_W;
  R: DWORD;
begin
  pEA := AllocMem(SizeOf(EXPLICIT_ACCESS));
  BuildExplicitAccessWithName(pEA, 'EVERYONE', GENERIC_WRITE or
GENERIC_READ, GRANT_ACCESS, SUB_OBJECTS_ONLY_INHERIT);
  R := SetEntriesInAcl(1, pEA, nil, pDACL);
  if R = ERROR_SUCCESS then
  begin
    if SetNamedSecurityInfo(PWideChar(lPath), SE_FILE_OBJECT,
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
  Path: PWideChar;
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
  Path : PWideChar;
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

function GetFileDateTime(FileName: string): TDateTime;
begin
  if not FileAge(FileName, Result) then
    Result := Now;
end;

function GetDirectorySize(Folder: string): Int64;
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  Result := 0;
  if Length(Trim(Folder)) < 2 then
    Exit;

  Folder := IncludeTrailingBackslash(Folder);
  Found := FindFirst(Folder + '*.*', FaAnyFile, SearchRec);
  while Found = 0 do
  begin
    if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
    begin
      if FileExistsSafe(Folder + SearchRec.name) then
        Result := Result + Int64(SearchRec.FindData.NFileSizeLow) + Int64(SearchRec.FindData.NFileSizeHigh) * 2 * MaxInt
      else if DirectoryExists(Folder + SearchRec.name) then
        Result := Result + GetDirectorySize(Folder + '\' + SearchRec.name);
    end;
    Found := System.SysUtils.FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

function FileTime2DateTime(FT: _FileTime): TDateTime;
var
  FileTime: _SystemTime;
begin
  FileTimeToLocalFileTime(FT, FT);
  FileTimeToSystemTime(FT, FileTime);
  Result := EncodeDate(FileTime.WYear, FileTime.WMonth, FileTime.WDay) + EncodeTime(FileTime.WHour, FileTime.WMinute,
    FileTime.WSecond, FileTime.WMilliseconds);
end;

function DateModify(FileName: string): TDateTime;
var
  Ts: TSearchRec;
begin
  Result := 0;
  if FindFirst(FileName, FaAnyFile, Ts) = 0 then
    Result := FileTime2DateTime(Ts.FindData.FtLastWriteTime);
end;


function GetFileSize(FileName: string): Int64;
var
  FS: TFileStream;
begin
  try
{$I-}
    FS := TFileStream.Create(Filename, FmOpenRead or FmShareDenyNone);
{$I+}
  except
    Result := -1;
    Exit;
  end;
  Result := FS.Size;
  FS.Free;
end;

function GetFileSizeByName(FileName: string): Int64;
var
  FindData: TWin32FindData;
  HFind: THandle;
begin
  Result := 0;
  HFind := FindFirstFile(PChar(FileName), FindData);
  if HFind <> INVALID_HANDLE_VALUE then
  begin
    Winapi.Windows.FindClose(HFind);
    if (FindData.DwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
      Result := Int64(FindData.NFileSizeHigh) * 2 * MaxInt + Int64(FindData.NFileSizeLow);
  end;
end;

function LongFileName(ShortName: string): string;
var
  SR: TSearchRec;
begin
  Result := '';
  if (Pos('\\', ShortName) + Pos('*', ShortName) + Pos('?', ShortName) <> 0) or
    (not FileExistsSafe(ShortName) and not DirectoryExists(ShortName)) or (Length(ShortName) < 4) then
  begin
    Result := ShortName;
    Exit;
  end;
  if Pos('~1', ShortName) = 0 then
  begin
    Result := ShortName;
    Exit;
  end;
  while FindFirst(ShortName, FaAnyFile, SR) = 0 do
  begin
    { next part as prefix }
    Result := '\' + SR.name + Result;
    System.SysUtils.FindClose(SR); { the SysUtils, not the WinProcs procedure! }
    { directory up (cut before '\') }
    ShortName := ExtractFileDir(ShortName);
    if Length(ShortName) <= 2 then
    begin
      Break; { ShortName contains drive letter followed by ':' }
    end;
  end;
  Result := AnsiUpperCase(ExtractFileDrive(ShortName)) + Result;
end;

function LongFileNameW(ShortName: string): string;
var
  SR: TSearchRec;
begin
  Result := '';
  if (Pos('\\', ShortName) + Pos('*', ShortName) + Pos('?', ShortName) <> 0) or
    (not FileExistsSafe(ShortName) and not DirectoryExists(ShortName)) or (Length(ShortName) < 4) then
  begin
    Result := ShortName;
    Exit;
  end;
  while FindFirst(ShortName, FaAnyFile, SR) = 0 do
  begin
    { next part as prefix }
    Result := '\' + SR.name + Result;
    System.SysUtils.FindClose(SR); { the SysUtils, not the WinProcs procedure! }
    { directory up (cut before '\') }
    ShortName := ExtractFileDir(ShortName);
    if Length(ShortName) <= 2 then
    begin
      Break; { ShortName contains drive letter followed by ':' }
    end;
  end;
  Result := AnsiUpperCase(ExtractFileDrive(ShortName)) + Result;
end;

function GetFileDescription(FileName: string; UnknownFileDescription: string): string;
var
  Reg: TRegistry;
  S: string;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKey(ExtractFileExt(FileName), False) then
    begin
      S := Reg.ReadString('');
      Reg.CloseKey;
      if Reg.OpenKey(S, False) then
        Result := Reg.ReadString('');
    end;
  finally
    F(Reg);
  end;
  if Result = '' then
    Result := UnknownFileDescription;
end;

function MrsGetFileType(StrFilename: string): string;
var
  FileInfo: TSHFileInfo;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    FillChar(FileInfo, SizeOf(FileInfo), #0);
    SHGetFileInfo(PWideChar(StrFilename), 0, FileInfo, SizeOf(FileInfo), SHGFI_TYPENAME);
    Result := FileInfo.SzTypeName;
  finally
    SetErrorMode(oldMode);
  end;
end;

procedure CreateBuffer(Files: TStrings; var P: TCharBuffer);
var
  I: Integer;
  S: string;
begin
  for I := 0 to Files.Count - 1 do
  begin
    if S = '' then
      S := Files[I]
    else
      S := S + #0 + Files[I];
  end;
  S := S + #0#0;
  SetLength(P, Length(S));
  for I := 1 to Length(S) do
    P[I - 1] := S[I];
end;

function CopyFilesSynch(Handle: Hwnd; Src: TStrings; Dest: string; Move: Boolean; AutoRename: Boolean): Integer;
const
  DE_SAMEFILE = $71;
var
  SHFileOpStruct: TSHFileOpStruct;
  SrcBuf: TCharBuffer;
begin
  Inc(CopyFilesSynchCount);
  try
    CreateBuffer(Src, SrcBuf);
    with SHFileOpStruct do
    begin
      Wnd := Handle;
      if Move then
        WFunc := FO_MOVE
      else
        WFunc := FO_COPY;
      PFrom := Pointer(SrcBuf);
      PTo := PWideChar(Dest);
      FFlags := FOF_ALLOWUNDO;
      if AutoRename then
        FFlags := FFlags or FOF_RENAMEONCOLLISION;
      FAnyOperationsAborted := False;
      HNameMappings := nil;
      LpszProgressTitle := nil;
    end;
    Result := SHFileOperation(SHFileOpStruct);
    if Result = DE_SAMEFILE then
    begin
      SHFileOpStruct.FFlags := SHFileOpStruct.FFlags or FOF_RENAMEONCOLLISION;
      Result := SHFileOperation(SHFileOpStruct);
    end;

    SrcBuf := nil;
  finally
    Dec(CopyFilesSynchCount);
  end;
end;

function DeleteFiles(Handle: HWnd; Files: TStrings; ToRecycle: Boolean): Integer;
var
  SHFileOpStruct: TSHFileOpStruct;
  Src: TCharBuffer;
begin
  CreateBuffer(Files, Src);
  with SHFileOpStruct do
  begin
    Wnd := Handle;
    WFunc := FO_DELETE;
    PFrom := Pointer(Src);
    PTo := nil;
    FFlags := 0;
    if ToRecycle then
      FFlags := FOF_ALLOWUNDO;
    FAnyOperationsAborted := False;
    HNameMappings := nil;
    LpszProgressTitle := nil;
  end;
  Result := SHFileOperation(SHFileOpStruct);
  Src := nil;
end;

function SilentDeleteFile(Handle: HWnd; FileName: string; ToRecycle: Boolean; HideErrors: Boolean = False): Integer;
var
  Files: TStrings;
begin
  Files := TStringList.Create;
  try
    Files.Add(FileName);
    Result := SilentDeleteFiles(Handle, Files, ToRecycle, HideErrors);
  finally
    F(Files);
  end;
end;

function SilentDeleteFiles(Handle: HWnd; Names: TStrings; ToRecycle: Boolean;
  HideErrors: Boolean = False): Integer;
var
  SHFileOpStruct: TSHFileOpStruct;
  Src: TCharBuffer;
begin
  CreateBuffer(Names, Src);
  with SHFileOpStruct do
  begin
    Wnd := Handle;
    WFunc := FO_DELETE;
    PFrom := Pointer(Src);
    PTo := nil;
    FFlags := FOF_NOCONFIRMATION;
    if HideErrors then
      FFlags := FFlags or FOF_SILENT or FOF_NOERRORUI;
    if ToRecycle then
      FFlags := FFlags or FOF_ALLOWUNDO;
    FAnyOperationsAborted := False;
    HNameMappings := nil;
    LpszProgressTitle := nil;
  end;
  Result := SHFileOperation(SHFileOpStruct);
  Src := nil;
end;

function GetNetworkDriveLabel(NetworkPath: string): string;
const
  EXPLORER_LABEL_PATH = 'Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\';
var
  Reg: TRegistry;
  S: String;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    S := StringReplace(NetworkPath, '\', '#', [rfReplaceAll]);
    if Reg.OpenKey(EXPLORER_LABEL_PATH + S, False) then
      Result := Reg.ReadString('_LabelFromReg');

    if Result = '' then
      Result := NetworkPath;
  finally
    F(Reg);
  end;
end;

function GetCDVolumeLabelEx(CDName: Char): string;
begin
  if GetDriveType(PChar(CDName + ':\')) <> DRIVE_REMOTE then
    Result := GetDriveVolumeLabel(AnsiChar(CDName))
  else
    Result := GetNetworkDriveLabel(GetNetDrivePath(CDName));
end;

function DriveState(DriveLetter: AnsiChar): TDriveState;
var
  Mask: string;
  SRec: TSearchRec;
  OldMode: Cardinal;
  RetCode: Integer;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Mask := Char(Driveletter) + ':\*.*';
  {$I-} { without exception }
    RetCode := FindFirst(Mask, FaAnyfile, SRec);
    FindClose(SRec);
  {$I+}
    case Retcode of
      0:
        Result := DS_DISK_WITH_FILES; { at least one file is found }
      -18:
        Result := DS_EMPTY_DISK; { empty disk  }
      -21:
        Result := DS_NO_DISK; { DOS ERROR_NOT_READY }
    else
      Result := DS_UNFORMATTED_DISK; { incorrect drive }
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

///
///Handle: Application.Handle
///
procedure Copy_Move(Handle: THandle; Copy: Boolean; FileList: TStrings);
var
  HGlobal, ShGlobal: THandle;
  DropFiles: PDropFiles;
  REff: Cardinal;
  DwEffect: ^Word;
  RSize, ILen, I: Integer;
  Files: string;
begin
  if (FileList.Count = 0) or (OpenClipboard(Handle) = False) then
    Exit;

  Files := '';
  // File1#0File2#0#0
  for I := 0 to FileList.Count - 1 do
    Files := Files + FileList[I] + #0;
  Files := Files + #0;
  ILen := Length(Files);

  try
    EmptyClipboard;
    RSize := SizeOf(TDropFiles) + SizeOf(Char) * ILen;
    HGlobal := GlobalAlloc(GMEM_SHARE or GMEM_MOVEABLE or GMEM_ZEROINIT, RSize);
    if HGlobal <> 0 then
    begin
      DropFiles := GlobalLock(HGlobal);
      DropFiles.PFiles := SizeOf(TDropFiles);
      DropFiles.FNC := False;
      DropFiles.FWide := True;

      Move(Files[1], (PByte(DropFiles) + SizeOf(TDropFiles))^, ILen * SizeOf(Char));

      GlobalUnlock(HGlobal);
      ShGlobal := SetClipboardData(CF_HDROP, HGlobal);
      if (ShGlobal <> 0) then
      begin
        HGlobal := GlobalAlloc(GMEM_MOVEABLE, SizeOf(DwEffect));
        if HGlobal <> 0 then
        begin
          DwEffect := GlobalLock(HGlobal);

          if Copy then
            DwEffect^ := DROPEFFECT_COPY
          else
            DwEffect^ := DROPEFFECT_MOVE;

          GlobalUnlock(HGlobal);

          REff := RegisterClipboardFormat(PWideChar('Preferred DropEffect')); // 'CFSTR_PREFERREDDROPEFFECT'));
          SetClipboardData(REff, HGlobal)
        end;
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

function Mince(PathToMince: string; InSpace: Integer): string;
{ ========================================================= }
// "C:\Program Files\Delphi\DDrop\TargetDemo\main.pas"
// "C:\Program Files\..\main.pas"
var
  Sl: TStringList;
  SHelp, SFile: string;
  IPos: Integer;

begin
  SHelp := PathToMince;
  IPos := Pos('\', SHelp);
  if IPos = 0 then
  begin
    Result := PathToMince;
  end else
  begin
    Sl := TStringList.Create;
    try
      // Decode string
      while IPos <> 0 do
      begin
        Sl.Add(Copy(SHelp, 1, (IPos - 1)));
        SHelp := Copy(SHelp, (IPos + 1), Length(SHelp));
        IPos := Pos('\', SHelp);
      end;
      if SHelp <> '' then
      begin
        Sl.Add(SHelp);
      end;
      // Encode string
      SFile := Sl[Sl.Count - 1];
      Sl.Delete(Sl.Count - 1);
      Result := '';
      while (Length(Result + SFile) < InSpace) and (Sl.Count <> 0) do
      begin
        Result := Result + Sl[0] + '\';
        Sl.Delete(0);
      end;
      if Sl.Count = 0 then
      begin
        Result := Result + SFile;
      end else
      begin
        Result := Result + '..\' + SFile;
      end;
    finally
      F(Sl);
    end;
  end;
end;

function WindowsCopyFile(FromFile, ToDir: string): Boolean;
var
  F: TShFileOpStruct;
begin
  F.Wnd := 0;
  F.WFunc := FO_COPY;
  FromFile := FromFile + #0;
  F.PFrom := Pchar(FromFile);
  ToDir := ToDir + #0;
  F.PTo := Pchar(ToDir);
  F.FFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  Result := ShFileOperation(F) = 0;
end;

function WindowsCopyFileSilent(FromFile, ToDir: string): Boolean;
var
  F: TShFileOpStruct;
begin
  F.Wnd := 0;
  F.WFunc := FO_COPY;
  FromFile := FromFile + #0;
  F.PFrom := Pchar(FromFile);
  ToDir := ToDir + #0;
  F.PTo := Pchar(ToDir);
  F.FFlags := FOF_SILENT or FOF_NOCONFIRMATION;
  Result := ShFileOperation(F) = 0;
end;

procedure DeleteDirectoryWithFiles(DirectoryName: string);
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  if Length(DirectoryName) < 4 then
    Exit;

  DirectoryName := IncludeTrailingBackslash(DirectoryName);
  Found := FindFirst(DirectoryName + '*.*', FaAnyFile, SearchRec);
  try
    while Found = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
      begin
        if FileExistsSafe(DirectoryName + SearchRec.Name) then
          DeleteFile(DirectoryName + SearchRec.name);

        if DirectoryExists(DirectoryName + SearchRec.name) then
          DeleteDirectoryWithFiles(DirectoryName + SearchRec.name);
      end;
      Found := System.SysUtils.FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;

  RemoveDir(DirectoryName);
end;

procedure GetDirectoresOfPath(Dir: string; Listing : TStrings);
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  Listing.Clear;

  Found := FindFirst(IncludeTrailingBackslash(Dir) + '*.*', FaDirectory, SearchRec);
  try
    while Found = 0 do
    begin
      if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
        if (SearchRec.Attr and FaDirectory <> 0) then
          Listing.Add(SearchRec.name);

      Found := System.SysUtils.FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;
end;

procedure GetFilesOfPath(Dir: string; Listing : TStrings);
var
  Found: Integer;
  SearchRec: TSearchRec;
begin
  Listing.Clear;
  Dir := IncludeTrailingBackslash(Dir);
  Found := FindFirst(Dir + '*.*', faAnyFile - FaDirectory, SearchRec);
  try
    while Found = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        if (SearchRec.Attr and FaDirectory = 0) then
          Listing.Add(Dir + SearchRec.name);

      Found := System.SysUtils.FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;
end;

procedure DelDir(Dir: string; Mask: string);
var
  FileName : string;
  Found: Integer;
  SearchRec: TSearchRec;
  FileExists, DirectoryExists : Boolean;
begin
  if Length(Dir) < 4 then
    Exit;

  Dir := IncludeTrailingBackSlash(Dir);

  Found := FindFirst(Dir + '*.*', FaAnyFile, SearchRec);
  try
    while Found = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        FileName := Dir + SearchRec.Name;
        FileExists := (SearchRec.Attr and FaDirectory = 0);
        DirectoryExists := (SearchRec.Attr and FaDirectory <> 0);
        if FileExists and ExtinMask(Mask, GetExt(FileName)) then
        begin
          FileSetAttr(FileName, 0);
          DeleteFile(FileName);
        end else if DirectoryExists then
          DelDir(FileName, Mask);
      end;
      if (SearchRec.Attr and FaDirectory <> 0) then
        RemoveDir(FileName);

      Found := System.SysUtils.FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;
  RemoveDir(Dir);
end;

function ReadTextFileInString(FileName: string): string;
var
  FS: TFileStream;
begin
  Result := '';
  if not FileExists(FileName) then
    Exit;
  try
    FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  except
    Exit;
  end;
  try
    SetLength(Result, FS.Size);
    try
      FS.Read(Result[1], FS.Size);
    except
      Exit;
    end;
  finally
    F(FS);
  end;
end;

function GetExt(Filename : string) : string;
var
  I, J: Integer;
  S: string;
begin
  J := 0;
  for I := Length(Filename) downto 1 do
  begin
    if Filename[I] = '.' then
    begin
      J := I;
      Break;
    end;
    if Filename[I] = '\' then
      Break;
  end;
  S := '';
  if J <> 0 then
  begin
    S := Copy(Filename, J + 1, Length(Filename) - J);
    for I := 1 to Length(S) do
      S[I] := Upcase(S[I]);
  end;
  Result := S;
end;

function ExtinMask(Mask: string; Ext: string): Boolean;
begin
  Result := False;
  if Mask = '||' then
  begin
    Result := True;
    Exit;
  end;
  if Ext = '' then
    Exit;
  mask := '|' + AnsiUpperCase(Mask) + '|';
  Ext := AnsiUpperCase(Ext);
  Result := Pos('|' + Ext + '|', Mask) > 0;
end;

function ProgramDir : string;
begin
  Result := IncludeTrailingBackSlash(ExtractFileDir(ParamStr(0)));
end;

function GetConvertedFileName(FileName, NewEXT  : string) : string;
var
  S, Dir: string;
  I: Integer;
begin
  Result := FileName;
  Dir := ExtractFileDir(Result);
  ChangeFileExt(Result, NewEXT);
  Result := Dir + GetFileNameWithoutExt(Result) + '.' + AnsiLowerCase(NewEXT);
  if not FileExists(Result) then
    Exit;
  S := Dir + ExtractFileName(Result);
  I := 1;
  while (FileExists(S)) do
  begin
    S := Dir + GetFileNameWithoutExt(Result) + ' (' + IntToStr(I) + ').' + NewEXT;
    Inc(I);
  end;
  Result := S;
end;

function GetConvertedFileNameWithDir(FileName, Dir, NewEXT  : string) : string;
var
  S: string;
  I: Integer;
begin
  Result := FileName;
  Dir := IncludeTrailingBackslash(Dir);
  ChangeFileExt(Result, NewEXT);
  Result := Dir + GetFileNameWithoutExt(Result) + '.' + AnsiLowerCase(NewEXT);
  if not FileExists(Result) then
    Exit;
  S := Dir + ExtractFileName(Result);
  I := 1;
  while (FileExists(S)) do
  begin
    S := Dir + GetFileNameWithoutExt(Result) + ' (' + IntToStr(I) + ').' + NewEXT;
    Inc(I);
  end;
  Result := S;
end;

function GetDriveVolumeLabel(CDName: AnsiChar): string;
var
  VolumeName,
  FileSystemName: array [0..MAX_PATH-1] of Char;
  VolumeSerialNo: DWord;
  MaxComponentLength,FileSystemFlags: Cardinal;
  OldMode: Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if GetVolumeInformation(PChar(CDName + ':\'), VolumeName, MAX_PATH, @VolumeSerialNo, MaxComponentLength, FileSystemFlags, FileSystemName, MAX_PATH) then
      Result := VolumeName
    else
      Result := CDName + ':\';
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetDirListing(Dir: String; Mask: string): TArray<string>;
var
  Found: Integer;
  SearchRec: TSearchRec;
  OldMode: Cardinal;

  function ExtInMask(Mask: string; Ext: string): Boolean;
  begin
    Result := Pos('|' + Ext + '|', Mask) <> -1;
  end;

  function GetExt(FileName: string): string;
  var
    S: string;
  begin
    S := ExtractFileExt(FileName);
    Result := AnsiUpperCase(Copy(S, 1, Length(S) - 1));
  end;

begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    SetLength(Result, 0);
    if Dir = '' then
      Exit;
    Dir := IncludeTrailingBackslash(Dir);
    Found := FindFirst(Dir + '*.*', FaAnyFile - FaDirectory, SearchRec);
    try
      while Found = 0 do
      begin
        if (SearchRec.name <> '.') and (SearchRec.name <> '..') then
          if ExtInMask(GetExt(SearchRec.name), Mask) then
          begin
            SetLength(Result, Length(Result) + 1);
            Result[Length(Result) - 1] := Dir + SearchRec.name;
          end;
        Found := System.SysUtils.FindNext(SearchRec);
      end;
    finally
      FindClose(SearchRec);
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetCommonDir(Dir1 { Common  dir } , Dir2 { Compare dir } : string): string;
var
  I, C: Integer;
begin
  if Dir1 = Dir2 then
  begin
    Result := Dir1;
  end else
  begin
    if Dir1 = Copy(Dir2, 1, Length(Dir1)) then
    begin
      Result := Dir1;
      Exit;
    end;
    C := Min(Length(Dir1), Length(Dir2));
    for I := 1 to C do
      if Dir1[I] <> Dir2[I] then
      begin
        C := I;
        Break;
      end;
    Result := ExtractFilePath(Copy(Dir1, 1, C - 1));
  end;
end;

function GetCommonDirectory(FileNames: TStrings): string;
var
  I: Integer;
  S, Temp, D: string;
  Files: TStrings;
begin
  Result := '';
  if FileNames.Count = 0 then
    Exit;
  Files := TStringList.Create;
  try
    Files.Assign(FileNames);

    for I := 0 to Files.Count - 1 do
      Files[I] := ExtractFilePath(Files[I]);

    S := AnsiLowerCase(Copy(Files[0], 1, 2));
    Temp := AnsiLowerCase(Files[0]);
    for I := 0 to Files.Count - 1 do
    begin
      Files[I] := AnsiLowerCase(Files[I]);
      if Length(Files[I]) < 2 then
        Exit;
      if S <> Copy(Files[I], 1, 2) then
        Exit;
      D := ExtractFilePath(Files[I]);
      if Length(Temp) > Length(D) then
        Temp := D;
    end;

    for I := 0 to Files.Count - 1 do
      Temp := GetCommonDir(Temp, Files[I]);

    Result := Temp;
  finally
    F(Files);
  end;
end;

end.
