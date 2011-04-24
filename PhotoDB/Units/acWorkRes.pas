(***********************************************************************
* ������: acLib - ���������� ��� Delphi                                *
* Copyright (c) Alex & Co 2004,...                                     *
************************************************************************
  ������:   acWorkRes.pas
  ��������: ������������ ������ madRes.pas �������� � ���������� ��������
            Mathias Rauen. ��������� ����������� � ����������� ��������
            � ��������� Icon � Bitmap ��� ������ ������� ����� �������
            � �������� �������������.
  �����:    ��������� �.�.
  ������:   1.10.14  21.07.04
            - ���� ������� ��� ���������, ������� ������ �����������
              madRes � ������ 1.0h.
            1.10.14  21.07.04
            - ��������� ������� "LoadFileResourceW" - ������� ������
              ����� � �������.
            - ��������� ������� "LoadFileResource" - ������� ������
              ����� � ������� ��� ������� �����.
            - ��������� ������� "SaveFileResourceW" - ������� ����������
              ����� �� ��������.
            - ��������� ������� "SaveFileResource" - ������� ����������
              ����� �� �������� ��� ������� �����.
            - ��������� ������� "SaveFileToDiscW" - ���������� �������
              ����� ����� �� ����.
            - ��������� ������� "LoadFileToResourceW" - ����������
              ������� � ���� ����� �� ����.
            1.04.07  19.07.04
            - ��������� ������� "PWideToString" - ��������������
              PWideChar � String.
            - ���������� ������ � ������� "SaveIconToDiscW", �������
              ��������� �� ��������� �������� ��������� Win9x.
            1.03.05  17.04.04
            - ��������� ������� "StringToPWide" - �������������� String
              � PWideChar.
            1.02.04  16.04.04
            - ���������� ������ � ������� "GetNameIcon".
            - ��������� ������� "SaveIconToDiscW" - ���������� ������
              �� ����.
            1.01.02  11.04.04
            - ��������� ������� "GetNameIcon" - ������� ���������� ���-
              ����� ������ �� �� ������.
            1.00.01  09.04.04
            - ������ ������.
************************************************************************)

// ***************************************************************
//  madRes.pas                version:  1.0h  �  date: 2004-04-11
//  -------------------------------------------------------------
//  resource functions for both NT and 9x families
//  -------------------------------------------------------------
//  Copyright (C) 1999 - 2004 www.madshi.net, All Rights Reserved
// ***************************************************************

// 2004-04-11 1.0h (1) "CompareString" replaced by "madStrings.CompareStr"
//                 (2) GetResourceW checks for "update = 0" now
// 2004-03-08 1.0g (1) CompareString(LANG_ENGLISH) fixes sort order (czech OS)
//                 (2) force file time touch, when resources are changed
// 2003-11-10 1.0f (1) checksum field in the PE header is now set up correctly
//                 (2) CodePage field in the resource headers stays 0 now
//                 (3) ImageDebugDirectory handling improved (Microsoft linker)
// 2003-06-09 1.0e (1) language was not treated correctly
//                 (2) cleaning up the internal trees contained a little bug
// 2002-11-07 1.0d (1) UpdateResource raised AV (only inside IDE) when update=0
//                 (2) PImageSectionHeader.PointerToLinenumbers/Relocations
//                     is corrected now (if necessary)
// 2002-10-17 1.0c (1) some debug structures were not updated correctly
//                 (2) resources must be sorted alphabetically
// 2002-10-12 1.0b CreateFileW is not supported in 9x, of course (dumb me)
// 2002-10-11 1.0a (1) the resource data was not always aligned correctly
//                 (2) the virtual size of the res section was sometimes wrong
//                 (3) data given into UpdateResourceW is buffered now
//                 (4) added some icon and bitmap specific functions
// 2002-10-10 1.0  initial release

//                 (2) force file time touch, when resources are changed
// 2003-11-10 1.0f (1) checksum field in the PE header is now set up correctly
//                 (2) CodePage field in the resource headers stays 0 now
//                 (3) ImageDebugDirectory handling improved (Microsoft linker)
// 2003-06-09 1.0e (1) language was not treated correctly
//                 (2) cleaning up the internal trees contained a little bug
// 2002-11-07 1.0d (1) UpdateResource raised AV (only inside IDE) when update=0
//                 (2) PImageSectionHeader.PointerToLinenumbers/Relocations
//                     is corrected now (if necessary)
// 2002-10-17 1.0c (1) some debug structures were not updated correctly
//                 (2) resources must be sorted alphabetically
// 2002-10-12 1.0b CreateFileW is not supported in 9x, of course (dumb me)
// 2002-10-11 1.0a (1) the resource data was not always aligned correctly
//                 (2) the virtual size of the res section was sometimes wrong
//                 (3) data given into UpdateResourceW is buffered now
//                 (4) added some icon and bitmap specific functions
// 2002-10-10 1.0  initial release

unit acWorkRes;

interface

{$DEFINE UNICODE}

uses Windows;

// ***************************************************************
// first of all clone the official win32 APIs

function BeginUpdateResourceW (fileName       : PWideChar;
                               delExistingRes : bool   ; Write : boolean = true  ) : dword; stdcall;

function EndUpdateResourceW (update  : dword;
                             discard : bool ) : bool; stdcall;

function UpdateResourceW (update   : dword;
                          type_    : PWideChar;
                          name     : PWideChar;
                          language : word;
                          data     : pointer;
                          size     : dword    ) : bool; stdcall;

// ***************************************************************

// get the raw data of the specified resource
function GetResourceW (update   : dword;
                       type_    : PWideChar;
                       name     : PWideChar;
                       language : word;
                       var data : pointer;
                       var size : dword    ) : bool; stdcall;

// ***************************************************************

// icon specific types and functions

type
  // structure of icon group resources
  TPIconGroup = ^TIconGroup;
  TIconGroup = packed record
    reserved  : word;
    type_     : word;  // 1 = icon
    itemCount : word;
    items     : array [0..maxInt shr 4 - 1] of packed record
                  width     : byte;  // in pixels
                  height    : byte;
                  colors    : byte;  // 0 for 256+ colors
                  reserved  : byte;
                  planes    : word;
                  bitCount  : word;
                  imageSize : dword;
                  id        : word;  // id of linked RT_ICON resource
                end;
  end;

  // structure of ico file header
  TPIcoHeader = ^TIcoHeader;
  TIcoHeader = packed record
    reserved  : word;
    type_     : word;  // 1 = icon
    itemCount : word;
    items     : array [0..maxInt shr 4 - 1] of packed record
                  width     : byte;   // in pixels
                  height    : byte;
                  colors    : byte;   // 0 for 256+ colors
                  reserved  : byte;
                  planes    : word;
                  bitCount  : word;
                  imageSize : dword;
                  offset    : dword;  // data offset in ico file
                end;
  end;

// get the specified icon group resource header
function GetIconGroupResourceW (update        : dword;
                                name          : PWideChar;
                                language      : word;
                                var iconGroup : TPIconGroup) : bool; stdcall;

// save the specified icon group resource to an ico file
function SaveIconGroupResourceW (update   : dword;
                                 name     : PWideChar;
                                 language : word;
                                 icoFile  : PWideChar) : bool; stdcall;

// load the specified ico file into the resources
// if the icon group with the specified already exists, it gets fully replaced
function LoadIconGroupResourceW (update   : dword;
                                 name     : PWideChar;
                                 language : word;
                                 icoFile  : PWideChar) : bool;  stdcall;

// delete the whole icon group including all referenced icons
function DeleteIconGroupResourceW (update   : dword;
                                   name     : PWideChar;
                                   language : word     ) : bool; stdcall;

// ***************************************************************
// bitmap specific functions

// save the specified bitmap resource to a bmp file
function SaveBitmapResourceW (update   : dword;
                              name     : PWideChar;
                              language : word;
                              bmpFile  : PWideChar) : bool; stdcall;

// load the specified bmp file into the resources
function LoadBitmapResourceW (update   : dword;
                              name     : PWideChar;
                              language : word;
                              bmpFile  : PWideChar) : bool; stdcall;

// ***************************************************************

////////////////////////////////// Alx ///////////////////////////
var
  notLang: Boolean = False; // ���������� �������� ����� � �������
                            // ������������� ��������� � ������� �
                            // �������� �. �. ��� ���� �������� �
                            // 99.99% ������� ������ �����


function GetImageNtHeaders(module: dword) : PImageNtHeaders;

function IntToHexEx(value    : integer;
                    minLen   : integer = 1;
                    fillChar : char    = '0') : string; overload;

// same as SysUtils.CompareStr, but supports ['�', '�', ...]
//function CompareStr(const s1, s2: string) : integer; assembler;

function SaveIconGroupResource(update:  dword;
                               name:    PWideChar;
                               icoFile: PWideChar) : bool; stdcall;

function GetNameIcon(update: dword; ind: Integer) : PWideChar; stdcall;
// ������� ���������� �������� ������ �� �� ������

function SaveIconToDiscW(exeFile: PWideChar; ind: Word; icoFile: PWideChar): BOOL; stdcall;
// ���������� ������ �� ����
// exeFile - ���� � �����, � ������� ���������� ������
// ind     - ������ ������
// icoFile - ���� � ����� ��� ���������� ������

function LoadFileResourceW(update: dword; type_, name: PWideChar; language: word; aFile: PWideChar) : bool; stdcall;
// ������� ������ ����� � �������

function LoadFileResource (update: dword; type_, name, aFile: PWideChar) : bool; stdcall;
// ������� ������ ����� � ������� ��� ������� �����

function SaveFileResourceW(update: dword; type_, name: PWideChar; language: word; aFile: PWideChar) : bool; stdcall;
// ������� ���������� ����� �� ��������

function SaveFileResource (update: dword; type_, name, aFile: PWideChar) : bool; stdcall;
// ������� ���������� ����� �� �������� ��� ������� �����

function SaveFileToDiscW(exeFile, type_, name, aFile: PWideChar): BOOL; stdcall;
// ���������� ������� ����� ����� �� ����
// exeFile - ���� � �����, � ������� ���������� ����
// type_   - ��� ������� (�������� �������)
// name    - ��� ������� (�������� �������)
// aFile   - ���� � ����� ��� ���������� �������
// ������ �������������:
// SaveFileToDiscW('e:\Temp\Project1.exe', 'JPEG', 'MYJPEG', 'e:\Temp\Untitled-21.jpg')

function LoadFileToResourceW(exeFile, type_, name, aFile: PWideChar): BOOL; stdcall;
// ���������� ������� � ���� ����� �� ����
// exeFile - ���� � �����, � ������� �������� ����������� ���� ����
// type_   - ��� ������� (�������� �������)
// name    - ��� ������� (�������� �������)
// aFile   - ���� � �����, ������� ����� ��������� � ������
// LoadFileToResourceW('e:\Temp\Project1.exe', 'JPEG', 'MYJPEG', 'e:\Temp\Untitled-21.jpg')

function StringToPWide(sStr: AnsiString): PWideChar;
// �������������� String � PWideChar

function PWideToString(pw: PWideChar): string;
// �������������� PWideChar � String

function CreateFileX(fileName: PWideChar; write, create: boolean) : dword;

//////////////////////////////////////////////////////////////////

var DontShrinkResourceSection : boolean = false;

implementation

uses
  SysUtils;

// ***************************************************************

type
  // Windows internal types
  TAImageSectionHeader = array [0..maxInt shr 6 - 1] of TImageSectionHeader;

  TImageResourceDirectoryEntry = packed record
    NameOrID     : dword;
    OffsetToData : dword;
  end;
  PImageResourceDirectoryEntry = ^TImageResourceDirectoryEntry;

  TImageResourceDirectory = packed record
    Characteristics      : DWORD;
    timeDateStamp        : DWORD;
    majorVersion         : Word;
    minorVersion         : Word;
    numberOfNamedEntries : Word;
    numberOfIdEntries    : Word;
    entries              : array [0..maxInt shr 4 - 1] of TImageResourceDirectoryEntry;
  end;
  PImageResourceDirectory = ^TImageResourceDirectory;

  TImageResourceDataEntry = packed record
    OffsetToData : DWORD;
    Size         : DWORD;
    CodePage     : DWORD;
    Reserved     : DWORD;
  end;
  PImageResourceDataEntry = ^TImageResourceDataEntry;

  // madRes internal types
  TPPResItem = ^TPResItem;
  TPResItem = ^TResItem;
  TResItem = packed record
    id      : Integer;
    name    : WideString;
    child   : TPResItem;
    next    : TPResItem;
    strBuf  : Pointer;  // temporare memory buffer for item data < 32kb
    case isDir: Boolean of
      true  : (attr       : dword;
               time       : dword;
               majorVer   :  word;
               minorVer   :  word;
               namedItems : dword;
               idItems    : dword);
      false : (data       : pointer;
               size       : dword;
               fileBuf    : dword;  // temporare file buffer for item data >= 32kb
               codePage   : dword;
               reserved   : dword);
  end;
  TDAPResItem = array of TPResItem;

  TResourceHandle = record
    fh   : dword;
    map  : dword;
    buf  : pointer;
    nh   : PImageNtHeaders;
    tree : TPResItem;
  end;
  TPResourceHandle = ^TResourceHandle;

// ***************************************************************

// round up the value to the next align boundary
function Align(value, align: dword) : dword;
begin
  result := ((value + align - 1) div align) * align;
end;

// move file contents, can make smaller or bigger
// if moving is necessary, the file mapping must be temporarily undone
function MoveFileContents(fh, pos: dword; dif: integer; var map: dword; var buf: pointer) : boolean;
var moveSize : dword;

  procedure CloseHandles;
  begin
    UnmapViewOfFile(buf);
    CloseHandle(map);
  end;

  function OpenHandles : boolean;
  begin
    map := CreateFileMapping(fh, nil, PAGE_READWRITE, 0, 0, nil);
    buf := MapViewOfFile(map, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    result := buf <> nil;
  end;

  function CheckPos : boolean;
  begin
    result := true;
    if pos > GetFileSize(fh, nil) then begin
      if dif < 0 then
        CloseHandles;
      SetFilePointer(fh, pos, nil, FILE_BEGIN);
      SetEndOfFile(fh);
      if dif < 0 then
        result := OpenHandles;
    end;
    moveSize := GetFileSize(fh, nil) - pos;
  end;

  procedure SetSize;
  begin
    SetFilePointer(fh, integer(GetFileSize(fh, nil)) + dif, nil, FILE_BEGIN);
    SetEndOfFile(fh);
  end;

  procedure MoveIt;
  begin
    Move(pointer(dword(buf) + pos)^, pointer(int64(dword(buf) + pos) + dif)^, moveSize);
  end;

begin
  result := false;
  if dif > 0 then begin
    CloseHandles;
    CheckPos;
    SetSize;
    if OpenHandles then begin
      MoveIt;
      result := true;
    end;
  end else
    if CheckPos then begin
      MoveIt;
      CloseHandles;
      SetSize;
      result := OpenHandles;
    end;
end;

// get a pointer tree of all available resources
function GetResTree(module, resOfs, virtResOfs: dword) : TPResItem;

  function ParseResEntry(nameOrID, offsetToData: dword) : TPResItem;

    function GetResourceNameFromId(name: dword) : wideString;
    var wc : PWideChar;
        i1 : integer;
    begin
      wc := pointer(module + resOfs + name);
      SetLength(result, word(wc[0]));
      for i1 := 1 to Length(result) do
        result[i1] := wc[i1];
    end;

  var irs  : PImageResourceDirectory;
      i1   : integer;
      irde : PImageResourceDataEntry;
      ppri : ^TPResItem;
  begin
    New(result);
    ZeroMemory(result, sizeOf(result^));
    with result^ do begin
      isDir := offsetToData and $80000000 <> 0;
      if nameOrID and $80000000 <> 0 then
           name := GetResourceNameFromId(nameOrID and (not $80000000))
      else id   := nameOrID;
      if isDir then begin
        dword(irs) := module + resOfs + offsetToData and (not $80000000);
        attr       := irs^.Characteristics;
        time       := irs^.timeDateStamp;
        majorVer   := irs^.majorVersion;
        minorVer   := irs^.minorVersion;
        namedItems := irs^.numberOfNamedEntries;
        idItems    := irs^.numberOfIdEntries;
        ppri := @child;
        for i1 := 0 to irs^.numberOfNamedEntries + irs^.numberOfIdEntries - 1 do begin
          ppri^ := ParseResEntry(irs^.entries[i1].NameOrID, irs^.entries[i1].OffsetToData);
          ppri := @ppri^^.next;
        end;
      end else begin
        dword(irde) := module + resOfs + offsetToData;
        size     := irde^.Size;
        codePage := irde^.CodePage;
        reserved := irde^.Reserved;
        data     := pointer(module + irde^.OffsetToData - (virtResOfs - resOfs));
      end;
    end;
  end;

begin
  result := ParseResEntry(0, $80000000);
end;

// returns a unique temp file name with full path
function GetTempFile(res: TPResItem) : string;
var arrCh : array [0..MAX_PATH] of char;
begin
  if GetTempPath(MAX_PATH, arrCh) > 0 then
       result := string(arrCh) + '\'
  else result := '';
  result := result + '$mad$res' + IntToHexEx(GetCurrentProcessID, 8) + IntToHexEx(dword(res)) + '$';
end;

// totally free the pointer tree
procedure DelResTree(var res: TPResItem);
var res2 : TPResItem;
begin
  while res <> nil do begin
    DelResTree(res^.child);
    res2 := res;
    res := res^.next;
    if (not res2^.isDir) and (res2^.fileBuf <> 0) then begin
      CloseHandle(res2^.fileBuf);
      DeleteFile(pchar(GetTempFile(res2)));
    end;
    if res2.strBuf <> nil then
      FreeMem(res2.strBuf);
    Dispose(res2);
  end;
end;

// calculate how big the resource section has to be for the current tree
// returned is the value for the structure, name and data sections
procedure CalcResSectionSize(res: TPResItem; var ss, ns, ds: dword);
var res2 : TPResItem;
begin
  with res^ do
    if isDir then begin
      inc(ss, 16 + (namedItems + idItems) * sizeOf(TImageResourceDirectoryEntry));
      res2 := res^.child;
      while res2 <> nil do begin
        if res2^.name <> '' then
          inc(ns, Length(res2^.name) * 2 + 2);
        CalcResSectionSize(res2, ss, ns, ds);
        res2 := res2^.next;
      end;
    end else begin
      inc(ss, sizeOf(TImageResourceDataEntry));
      inc(ds, Align(res^.size, 4));
    end;
end;

// creates the whole resource section in a temporare buffer
function CreateResSection(virtResOfs: dword; res: TPResItem; var buf: pointer; ss, ns, ds: dword) : boolean;
var sp, np, dp : dword;
    fh         : dword;
    map        : dword;
    s1         : string;

  procedure Store(res: TPResItem);
  var c1   : dword;
      i1   : integer;
      res2 : TPResItem;
      wc   : PWideChar;
  begin
    if res^.isDir then begin
      with PImageResourceDirectory(dword(buf) + sp)^ do begin
        inc(sp, 16 + (res^.namedItems + res.idItems) * sizeOf(TImageResourceDirectoryEntry));
        Characteristics      := res^.attr;
        timeDateStamp        := res^.time;
        majorVersion         := res^.majorVer;
        minorVersion         := res^.minorVer;
        numberOfNamedEntries := res^.namedItems;
        numberOfIdEntries    := res^.idItems;
        c1 := 0;
        res2 := res^.child;
        while res2 <> nil do begin
          if c1 < res^.namedItems then begin
            entries[c1].NameOrID := np or $80000000;
            wc := pointer(dword(buf) + np);
            word(wc[0]) := Length(res2^.name);
            for i1 := 1 to Length(res2^.name) do
              wc[i1] := res2^.name[i1];
            inc(np, Length(res2^.name) * 2 + 2);
          end else
            entries[c1].NameOrID := res2^.id;
          if res2^.isDir then
               entries[c1].OffsetToData := sp or $80000000
          else entries[c1].OffsetToData := sp;
          Store(res2);
          inc(c1);
          res2 := res2^.next;
        end;
      end;
    end else
      with PImageResourceDataEntry(dword(buf) + sp)^ do begin
        inc(sp, sizeOf(TImageResourceDataEntry));
        OffsetToData := dp + virtResOfs;
        Size         := res^.size;
        CodePage     := res^.codePage;
        Reserved     := res^.reserved;
        if res^.data <> nil then
          Move(res^.data^, pointer(dword(buf) + dp)^, Size)
        else
          if res^.strBuf <> nil then
            Move(res^.strBuf^, pointer(dword(buf) + dp)^, Size)
          else
            if res^.fileBuf <> 0 then begin
              SetFilePointer(res^.fileBuf, 0, nil, FILE_BEGIN);
              ReadFile(res^.fileBuf, pointer(dword(buf) + dp)^, Size, c1, nil);
            end;
        inc(dp, Align(Size, 4));
      end;
  end;

begin
  result := false;
  sp := 0;
  np := ss;
  dp := Align(ss + ns, 4);
  if ss + ns + ds > 0 then begin
    s1 := GetTempFile(res);
    fh := CreateFile(pchar(s1), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS, 0, 0);
    if fh <> INVALID_HANDLE_VALUE then begin
      SetFilePointer(fh, Align(ss + ns, 4) + ds, nil, FILE_BEGIN);
      SetEndOfFile(fh);
      map := CreateFileMapping(fh, nil, PAGE_READWRITE, 0, 0, nil);
      if map <> 0 then begin
        buf := MapViewOfFile(map, FILE_MAP_ALL_ACCESS, 0, 0, 0);
        if buf <> nil then begin
          ZeroMemory(buf, Align(ss + ns, 4) + ds);
          Store(res);
        end;
        CloseHandle(map);
      end;
      CloseHandle(fh);
    end;
    DeleteFile(pchar(s1));
  end;
end;

// returns a specific child folder, if it can be found
function FindDir(tree: TPResItem; name: PWideChar) : TPPResItem;
var ws : wideString;
begin
  result := @tree^.child;
  if dword(name) and $FFFF0000 <> 0 then begin
    ws := name;
    while (result^ <> nil) and ((not result^^.isDir) or (result^^.name <> ws) ) do
      result := @result^^.next;
  end else
    while (result^ <> nil) and ((not result^^.isDir) or (result^^.name <> '') or (result^^.id <> integer(name))) do
      result := @result^^.next;
end;

// returns a specific child data item, if it can be found
function FindItem(tree: TPResItem; language: word) : TPPResItem;
begin
  result := @tree^.child;
  if not notLang then
    while (result^ <> nil) and (result^^.isDir or (result^^.id <> language)) do
      result := @result^^.next
  else
    while (result^ <> nil) and (result^^.isDir ) do
      result := @result^^.next;
end;

// ***************************************************************

function CreateFileX(fileName: PWideChar; write, create: boolean) : dword;
var c1, c2, c3 : dword;
begin
  if write then begin
    c1 := GENERIC_READ or GENERIC_WRITE;
    c2 := 0;
  end else begin
    c1 := GENERIC_READ;
    c2 := FILE_SHARE_READ or FILE_SHARE_WRITE;
  end;
  if create then c3 := CREATE_ALWAYS
  else           c3 := OPEN_EXISTING;
  if GetVersion and $80000000 = 0 then
       result := CreateFileW(fileName,                            c1, c2, nil, c3, 0, 0)
  else result := CreateFileA(pansichar(ansistring(wideString(fileName))), c1, c2, nil, c3, 0, 0);
end;

function BeginUpdateResourceW(fileName: PWideChar; delExistingRes: bool; Write : boolean = true) : dword; stdcall;
var rh  : TPResourceHandle;
    ash : ^TAImageSectionHeader;
    c1  : dword;
    i1  : integer;
    FileMappingAccess : Cardinal;  
    FileMapAccess : Cardinal;
begin
  result := 0;
  New(rh);
  ZeroMemory(rh, sizeOf(rh^));
  if Write then FileMappingAccess:=PAGE_READWRITE else FileMappingAccess:=PAGE_READONLY;

  if Write then FileMapAccess:=FILE_MAP_ALL_ACCESS else FileMapAccess:=FILE_MAP_READ;

  with rh^ do begin
    fh := CreateFileX(fileName, Write, false);
    if fh <> dword(-1) then begin
      map := CreateFileMapping(fh, nil, FileMappingAccess, 0, 0, nil);
      if map <> 0 then begin
        buf := MapViewOfFile(map, FileMapAccess, 0, 0, 0);
        if buf <> nil then begin
          nh := GetImageNtHeaders(dword(buf));
          if nh <> nil then begin
            SetLastError(ERROR_FILE_NOT_FOUND);
            dword(ash) := dword(nh) + sizeOf(nh^);
            for i1 := 0 to nh^.FileHeader.NumberOfSections - 1 do
              if ash[i1].VirtualAddress = nh^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress then begin
                if delExistingRes then begin
                  New(tree);
                  ZeroMemory(tree, sizeOf(tree^));
                  tree^.isDir := true;
                end else
                  tree := GetResTree(dword(buf), ash[i1].PointerToRawData, ash[i1].VirtualAddress);
                result := dword(rh);
                break;
              end;
          end;
        end;
      end;
    end;
    if result = 0 then begin
      c1 := GetLastError;
      EndUpdateResourceW(dword(rh), true);
      SetLastError(c1);
    end;
  end;
end;

procedure CalcCheckSum(baseAddress: pointer; size: dword);
var nh : PImageNtHeaders;
    i1 : dword;
    c1 : dword;
begin
  nh := GetImageNtHeaders(dword(baseAddress));
  nh^.OptionalHeader.CheckSum := 0;
  c1 := 0;
  for i1 := 0 to (size - 1) div 2 do begin
  	c1 := c1 + word(baseAddress^);
    if c1 and $ffff0000 <> 0 then
      c1 := c1 and $ffff + c1 shr 16;
    inc(dword(baseAddress), 2);
  end;
  c1 := word(c1 and $ffff + c1 shr 16);
  nh^.OptionalHeader.CheckSum := c1 + size;
end;

function EndUpdateResourceW(update: dword; discard: bool) : bool; stdcall;
var rh             : TPResourceHandle absolute update;
    ash            : ^TAImageSectionHeader;
    ss, ns, ds     : dword;
    storeBuf       : pointer;
    i1, i2, i3, i4 : integer;
    pidb           : PImageDebugDirectory;
begin
  result := true;
  if update <> 0 then
    try
      with rh^ do begin
        if not discard then begin
          result := false;
          dword(ash) := dword(nh) + sizeOf(nh^);
          for i1 := 0 to nh^.FileHeader.NumberOfSections - 1 do
            if ash[i1].VirtualAddress = nh^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress then begin
              ss := 0;
              ns := 0;
              ds := 0;
              CalcResSectionSize(tree, ss, ns, ds);
              CreateResSection(nh^.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE].VirtualAddress, tree, storeBuf, ss, ns, ds);
              i2 := int64(Align(Align(ss + ns, 4) + ds, nh^.OptionalHeader.FileAlignment)) - int64(ash[i1].SizeOfRawData);
              if (i2 < 0) and DontShrinkResourceSection then
                i2 := 0;
              if (i2 <> 0) and (not MoveFileContents(fh, ash[i1].PointerToRawData + ash[i1].SizeOfRawData, i2, map, buf)) then
                break;
              nh := GetImageNtHeaders(dword(buf));
              dword(ash) := dword(nh) + sizeOf(nh^);
              with nh^.OptionalHeader, DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE] do begin
                inc(nh^.OptionalHeader.SizeOfInitializedData, i2);
                i3 := int64(Align(Align(ss + ns, 4) + ds, SectionAlignment)) - Align(Size, SectionAlignment);
                ash[i1].SizeOfRawData    := Align(Align(ss + ns, 4) + ds, FileAlignment);
                ash[i1].Misc.VirtualSize := Align(ss + ns, 4) + ds;
                Size := Align(ss + ns, 4) + ds;
                inc(SizeOfImage, i3);
                for i4 := 0 to nh^.FileHeader.NumberOfSections - 1 do
                  if ash[i4].VirtualAddress > VirtualAddress then begin
                    inc(ash[i4].VirtualAddress, i3);
                    inc(ash[i4].PointerToRawData, i2);
                    if ash[i4].PointerToLinenumbers > ash[i1].PointerToRawData then
                      inc(ash[i4].PointerToLinenumbers, i2);
                    if ash[i4].PointerToRelocations > ash[i1].PointerToRawData then
                      inc(ash[i4].PointerToRelocations, i2);
                  end;
                for i4 := low(DataDirectory) to high(DataDirectory) do
                  if DataDirectory[i4].VirtualAddress > VirtualAddress then
                    inc(DataDirectory[i4].VirtualAddress, i3);
                pidb := nil;
                if DataDirectory[IMAGE_DIRECTORY_ENTRY_DEBUG].Size > 0 then
                  for i4 := 0 to nh^.FileHeader.NumberOfSections - 1 do
                    if (DataDirectory[IMAGE_DIRECTORY_ENTRY_DEBUG].VirtualAddress >= ash[i4].VirtualAddress) and
                       ( (i4 = nh^.FileHeader.NumberOfSections - 1) or
                         (DataDirectory[IMAGE_DIRECTORY_ENTRY_DEBUG].VirtualAddress < ash[i4 + 1].VirtualAddress) ) then begin
                      pidb := pointer(dword(buf) + ash[i4].PointerToRawData +
                                      DataDirectory[IMAGE_DIRECTORY_ENTRY_DEBUG].VirtualAddress -
                                      ash[i4].VirtualAddress);
                      break;
                    end;
                if pidb <> nil then begin
                  i4 := DataDirectory[IMAGE_DIRECTORY_ENTRY_DEBUG].Size;
                  if i4 mod sizeOf(TImageDebugDirectory) = 0 then
                    i4 := i4 div sizeOf(TImageDebugDirectory);
                  for i4 := 1 to i4 do begin
                    if pidb^.PointerToRawData > ash[i1].PointerToRawData then begin
                      if pidb^.PointerToRawData <> 0 then
                        inc(pidb^.PointerToRawData, i2);
                      if pidb^.AddressOfRawData <> 0 then
                        inc(pidb^.AddressOfRawData, i3);
                    end;
                    inc(pidb);
                  end;
                end;
              end;
              Move(storeBuf^, pointer(dword(buf) + ash[i1].PointerToRawData)^, Align(ss + ns, 4) + ds);
              UnmapViewOfFile(storeBuf);
              DeleteFile(pchar(GetTempFile(tree)));
              i2 := Align(Align(ss + ns, 4) + ds, nh^.OptionalHeader.FileAlignment) - (Align(ss + ns, 4) + ds);
              if i2 > 0 then
                ZeroMemory(pointer(dword(buf) + ash[i1].PointerToRawData + Align(ss + ns, 4) + ds), i2);
              result := true;
              break;
            end;
          CalcCheckSum(buf, GetFileSize(fh, nil));
        end;
        DelResTree(tree);
        UnmapViewOfFile(buf);
        CloseHandle(map);
        if SetFilePointer(fh, 0, nil, FILE_END) <> $ffffffff then
          SetEndOfFile(fh);
        CloseHandle(fh);
      end;
      Dispose(rh);
    except result := false end;
end;

function UpdateResourceW(update: dword; type_, name: PWideChar; language: word; data: pointer; size: dword) : bool; stdcall;

  procedure SetData(item: TPResItem);
  var c1 : dword;
  begin
    item^.id       := language;
    item^.data     := nil;
    item^.size     := size;
    item^.codePage := 0;//language;
    //load all resources to memory!
    {if size > 32 * 1024 then begin
      item^.fileBuf := CreateFile(pchar(GetTempFile(item)), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS, 0, 0);
      if item^.fileBuf <> INVALID_HANDLE_VALUE then
           WriteFile(item^.fileBuf, data^, size, c1, nil)
      else item^.fileBuf := 0;
    end else}
    begin
      GetMem(item^.strBuf, size);
      CopyMemory(item^.strBuf, data, size);
    end;
  end;

  function AddItem(tree: TPResItem) : TPResItem;
  var ppr1 : TPPResItem;
  begin
    ppr1 := @tree^.child;
    while (ppr1^ <> nil) and (ppr1^^.id < language) do
      ppr1 := @ppr1^^.next;
    New(result);
    ZeroMemory(result, sizeOf(result^));
    result^.next := ppr1^;
    ppr1^        := result;
    SetData(result);
    inc(tree^.idItems);
  end;

  function AddDir(tree: TPResItem; name: PWideChar) : TPResItem;
  var ppr1 : TPPResItem;
      s1   : string;
  begin
    New(result);
    ZeroMemory(result, sizeOf(result^));
    result^.isDir := true;
    ppr1 := @tree^.child;
    if dword(name) and $FFFF0000 = 0 then begin
      while (ppr1^ <> nil) and ((ppr1^^.name <> '') or (ppr1^^.id < integer(name))) do
        ppr1 := @ppr1^.next;
      result^.id := integer(name);
      inc(tree^.idItems);
    end else begin
      s1 := wideString(name);
      while (ppr1^ <> nil) and (ppr1^^.name <> '') and
            (CompareStr(ppr1^^.name, s1) < 0) do
        ppr1 := @ppr1^.next;
      result^.name := name;
      inc(tree^.namedItems);
    end;
    result^.next := ppr1^;
    ppr1^        := result;
  end;

  procedure DelItem(const items: array of TPPResItem);
  var pr1 : TPResItem;
      i1  : integer;
  begin
    for i1 := 0 to Length(items) - 2 do begin
      if items[i1]^.name = '' then
           dec(items[i1 + 1]^.idItems   )
      else dec(items[i1 + 1]^.namedItems);
      pr1 := items[i1]^;
      items[i1]^ := items[i1]^^.next;
      if (not pr1^.isDir) and (pr1^.fileBuf <> 0) then begin
        CloseHandle(pr1^.fileBuf);
        DeleteFile(pchar(GetTempFile(pr1)));
      end;
      if pr1.strBuf <> nil then
        FreeMem(pr1.strBuf);
      Dispose(pr1);
      if items[i1 + 1]^.idItems + items[i1 + 1]^.namedItems > 0 then
        break;
    end;
  end;

var ppr1, ppr2, ppr3 : TPPResItem;
begin
  result := true;
  if update <> 0 then
    try
      with TPResourceHandle(update)^ do begin
        ppr1 := FindDir(tree, type_);
        if ppr1^ <> nil then begin
          ppr2 := FindDir(ppr1^, name);
          if ppr2^ <> nil then begin
            ppr3 := FindItem(ppr2^, language);
            if ppr3^ <> nil then begin
              if data <> nil then
                SetData(ppr3^)
              else
                DelItem([ppr3, ppr2, ppr1, @tree]);
            end else
              if data <> nil then
                AddItem(ppr2^)
              else
                if language = 0 then
                  DelItem([ppr2, ppr1, @tree]);
          end else
            if data <> nil then
              AddItem(AddDir(ppr1^, name))
            else
              if (language = 0) and (name = nil) then
                DelItem([ppr1, @tree]);
        end else
          if data <> nil then
            AddItem(AddDir(AddDir(tree, type_), name));
      end;
    except result := false end;
end;

// ***************************************************************

function GetResourceW(update: dword; type_, name: PWideChar; language: word; var data: pointer; var size: dword) : bool; stdcall;
var res1 : TPResItem;
begin
  result := false;
  data   := nil;
  size   := 0;
  try
    if update <> 0 then
      with TPResourceHandle(update)^ do begin
        res1 := FindDir(tree, type_)^;
        if res1 <> nil then begin
          res1 := FindDir(res1, name)^;
          if res1 <> nil then begin
            res1 := FindItem(res1, language)^;
            result := res1 <> nil;
            if result then begin
              data := res1^.data;
              size := res1^.size;
            end;
          end;
        end;
      end;
  except result := false end;
end;

// ***************************************************************

function GetIconGroupResourceW(update: dword; name: PWideChar; language: word; var iconGroup: TPIconGroup) : bool; stdcall;
var c1 : dword;
begin
  result := GetResourceW(update, PWideChar(RT_GROUP_ICON), name, language, pointer(iconGroup), c1);
end;

function SaveIconGroupResourceW(update: dword; name: PWideChar; language: word; icoFile: PWideChar) : bool; stdcall;
var ig     : TPIconGroup;
    fh     : dword;
    ih     : TPIcoHeader;
    id     : pointer;
    i1     : integer;
    c1, c2 : dword;
    p1     : pointer;
begin
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  result := false;
  if GetIconGroupResourceW(update, name, language, ig) then begin
    fh := CreateFileX(icoFile, true, true);
    if fh <> INVALID_HANDLE_VALUE then
      try
        c2 := 0;
        for i1 := 0 to ig^.itemCount - 1 do
          inc(c2, ig^.items[i1].imageSize);
        ih := nil;
        id := nil;
        try
          GetMem(ih, 6 + 16 * ig^.itemCount);
          GetMem(id, c2);
          Move(ig^, ih^, 4);
          ih^.itemCount := 0;
          c1 := dword(id);
          for i1 := 0 to ig^.itemCount - 1 do begin
            Move(ig^.items[i1], ih^.items[ih^.itemCount], 14);
            if GetResourceW(update, PWideChar(RT_ICON), PWideChar(ig^.items[i1].id), language, p1, c2) then begin
              ih^.items[ih^.itemCount].offset := c1 - dword(id);
              Move(p1^, pointer(c1)^, ig^.items[i1].imageSize);
              inc(c1, ig^.items[i1].imageSize);
              inc(ih^.itemCount);
            end;
          end;
          for i1 := 0 to ih^.itemCount - 1 do
            inc(ih^.items[i1].offset, 6 + 16 * ih^.itemCount);
          result := (ih^.itemCount > 0) and
                    WriteFile(fh, ih^, 6 + 16 * ih^.itemCount, c2, nil) and
                    WriteFile(fh, id^, c1 - dword(id),         c2, nil);
        finally
          FreeMem(ih);
          FreeMem(id);
        end;
      finally CloseHandle(fh) end;
  end;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
end;

function LoadIconGroupResourceW(update: dword; name: PWideChar; language: word; icoFile: PWideChar) : bool; stdcall;

  function FindFreeID(var sid: integer) : integer;
  var pr1 : TPResItem;
  begin
    with TPResourceHandle(update)^ do begin
      pr1 := FindDir(tree, PWideChar(RT_ICON))^;
      if pr1 <> nil then begin
        pr1 := pr1^.child;
        while true do begin
          while (pr1 <> nil) and ((pr1^.name <> '') or (pr1^.id <> sid)) do
            pr1 := pr1^.next;
          if pr1 <> nil then
               inc(sid)
          else break;
        end;
      end;
      result := sid;
    end;
  end;

var ico    : TPIcoHeader;
    fh     : dword;
    c1, c2 : dword;
    ig     : TPIconGroup;
    ids    : array of integer;
    i1     : integer;
    sid    : integer;  // smallest id
begin
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  result := false;
  fh := CreateFileX(icoFile, false, false);
  if fh <> INVALID_HANDLE_VALUE then
    try
      c1 := GetFileSize(fh, nil);
      GetMem(ico, c1);
      try
        if ReadFile(fh, pointer(ico)^, c1, c2, nil) and (c1 = c2) then begin
          if GetIconGroupResourceW(update, name, language, ig) then begin
            SetLength(ids, ig^.itemCount);
            sid := maxInt;
            for i1 := 0 to high(ids) do begin
              ids[i1] := ig^.items[i1].id;
              if ids[i1] < sid then
                sid := ids[i1];
            end;
          end else
            sid := 50;
          DeleteIconGroupResourceW(update, name, language);
          GetMem(ig, 6 + 14 * ico^.itemCount);
          try
            Move(ico^, ig^, 6);
            for i1 := 0 to ico^.itemCount - 1 do begin
              Move(ico^.items[i1], ig^.items[i1], 14);
              if i1 < length(ids) then
                   ig^.items[i1].id := ids[i1]
              else ig^.items[i1].id := FindFreeID(sid);
              if not UpdateResourceW(update, PWideChar(RT_ICON), PWideChar(ig^.items[i1].id), language,
                                     pointer(dword(ico) + ico^.items[i1].offset), ico^.items[i1].imageSize) then
                exit;
            end;
            result := UpdateResourceW(update, PWideChar(RT_GROUP_ICON), name, language, ig, 6 + 14 * ig^.itemCount);
          finally FreeMem(ig) end;
        end;
      finally FreeMem(ico) end;
    finally CloseHandle(fh) end;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
end;

function DeleteIconGroupResourceW(update: dword; name: PWideChar; language: word) : bool; stdcall;
var ig : TPIconGroup;
    i1 : integer;
begin
{$IFOPT R+}
{$DEFINE CKRANGE}
{$R-}
{$ENDIF}
  if GetIconGroupResourceW(update, name, language, ig) then begin
    result := UpdateResourceW(update, PWideChar(RT_GROUP_ICON), name, language, nil, 0);
    if result then
      for i1 := 0 to ig^.itemCount - 1 do
        result := UpdateResourceW(update, PWideChar(RT_ICON), PWideChar(ig^.items[i1].id), language, nil, 0) and result;
  end else
    result := true;
{$IFDEF CKRANGE}
{$UNDEF CKRANGE}
{$R+}
{$ENDIF}
end;

// ***************************************************************

function SaveBitmapResourceW(update: dword; name: PWideChar; language: word; bmpFile: PWideChar) : bool; stdcall;
var bfh    : TBitmapFileHeader;
    p1     : pointer;
    c1, c2 : dword;
    fh     : dword;
begin
  result := false;
  if GetResourceW(update, PWideChar(RT_BITMAP), name, language, p1, c1) then begin
    pansichar(@bfh.bfType)[0] := 'B';
    pansichar(@bfh.bfType)[1] := 'M';
    bfh.bfSize      := sizeOf(bfh) + c1;
    bfh.bfReserved1 := 0;
    bfh.bfReserved2 := 0;
    bfh.bfOffBits   := sizeOf(TBitmapFileHeader) + sizeOf(TBitmapInfoHeader);
    if PBitmapInfo(p1)^.bmiHeader.biBitCount <= 8 then
      inc(bfh.bfOffBits, 4 shl PBitmapInfo(p1)^.bmiHeader.biBitCount);
    fh := CreateFileX(bmpFile, true, true);
    if fh <> INVALID_HANDLE_VALUE then
      try
        WriteFile(fh, bfh, sizeOf(bfh), c2, nil);
        WriteFile(fh, p1^, c1,          c2, nil);
        result := true;
      finally CloseHandle(fh) end;
  end;
end;

function LoadBitmapResourceW(update: dword; name: PWideChar; language: word; bmpFile: PWideChar) : bool; stdcall;
var bmp    : pointer;
    c1, c2 : dword;
    fh     : dword;
begin
  result := false;
  fh := CreateFileX(bmpFile, false, false);
  if fh <> INVALID_HANDLE_VALUE then
    try
      c1 := GetFileSize(fh, nil) - sizeOf(TBitmapFileHeader);
      GetMem(bmp, c1);
      try
        SetFilePointer(fh, sizeOf(TBitmapFileHeader), nil, FILE_BEGIN);
        result := ReadFile(fh, pointer(bmp)^, c1, c2, nil) and (c1 = c2) and
                  UpdateResourceW(update, PWideChar(RT_BITMAP), name, language, bmp, c1);
      finally FreeMem(bmp) end;
    finally CloseHandle(fh) end;
end;

//////////////////////////////// Alx ////////////////////////////////

function SaveIconGroupResource (update   : dword;
                                name     : PWideChar;
                                icoFile  : PWideChar) : bool; stdcall;
begin
  notLang:= True;
  try
    Result:= SaveIconGroupResourceW(update, name, LANG_NEUTRAL, icoFile);
  finally
    notLang:= False;
  end;
end;

function GetNameIcon(update: dword; ind: Integer) : PWideChar; stdcall;
// ������� ���������� �������� ������ �� �� ������
var
  res1 : TPResItem;
  res2 : TPPResItem;
  n: Integer;
begin
  result:= '';
  try
    with TPResourceHandle(update)^ do begin
      res1 := FindDir(tree, PWideChar(RT_GROUP_ICON))^;
      if res1 <> nil then begin
        res2:= @res1^.child;
        for n:= 0 to ind-1 do res2:= @res2^^.next;
        if res2^^.name = '' then
          Result:= PWideChar(res2^^.id)
        else
          Result:= PWideChar(WideString(res2^^.name));
      end;
    end;
  except
    result:= '';
  end;
end;

function SaveIconToDiscW(exeFile: PWideChar; ind: Word; icoFile: PWideChar): BOOL; stdcall;
// ���������� ������ �� ����
// exeFile - ���� � �����, � ������� ���������� ������
// ind     - ������ ������
// icoFile - ���� � ����� ��� ���������� ������
const
  tmpFile = 'tmp.tmp';
var
  hUpdateRes: THandle;
  Buffer: array [0..MAX_PATH] of Char;
begin
  Result:= False;
  if Windows.GetTempPath(SizeOf(Buffer), Buffer) > 0 then
    // ����������� ��������, ��� ���� ����� �� ��������� ������ ��
    // �������� ������� ����, ����� ���� ��������
// alx 20.07.04 if CopyFileW(exeFile, PWideChar(WideString(Buffer + tmpFile)), False) then try
    if CopyFile(PChar(PWideToString(exeFile)), PWideChar(Buffer + tmpFile), False) then try
      exeFile:= PWideChar(WideString(Buffer + tmpFile));
      hUpdateRes:= BeginUpdateResourceW(exeFile, False);
      if hUpdateRes <> 0 then
        if SaveIconGroupResource(hUpdateRes, GetNameIcon(hUpdateRes, ind), icoFile) then
          Result:= EndUpdateResourceW(hUpdateRes, False);
    finally
      DeleteFileW(exeFile);
    end;
end;

function LoadFileResourceW(update: dword; type_, name: PWideChar; language: word; aFile: PWideChar) : bool; stdcall;
// ������� ������ ����� � �������
var
  f      : pointer;
  c1, c2 : dword;
  fh     : dword;
begin
  Result:= False;
  fh:= CreateFileX(aFile, False, False);
  if fh <> INVALID_HANDLE_VALUE then try
    c1:= GetFileSize(fh, nil);
    GetMem(f, c1);
    try
      Result:= ReadFile(fh, pointer(f)^, c1, c2, nil) and (c1 = c2) and
               UpdateResourceW(update, type_, name, language, f, c1);
    finally
      FreeMem(f)
    end;
  finally
    CloseHandle(fh)
  end;
end;

function LoadFileResource (update: dword; type_, name, aFile: PWideChar) : bool; stdcall;
// ������� ������ ����� � ������� ��� ������� �����
begin
  notLang:= True;
  try
    Result:= LoadFileResourceW(update, type_, name, LANG_NEUTRAL, aFile);
  finally
    notLang:= False;
  end;
end;

function SaveFileResourceW(update: dword; type_, name: PWideChar; language: word; aFile: PWideChar): bool; stdcall;
// ������� ���������� ����� �� ��������
var
  p1     : pointer;
  c1, c2 : dword;
  fh     : dword;
begin
  Result:= False;
  if GetResourceW(update, type_, name, language, p1, c1) then begin
    fh:= CreateFileX(aFile, True, True);
    if fh <> INVALID_HANDLE_VALUE then try
      WriteFile(fh, p1^, c1, c2, nil);
      Result:= True;
    finally
      CloseHandle(fh);
    end;
  end;
end;

function SaveFileResource (update: dword; type_, name, aFile: PWideChar) : bool; stdcall;
// ������� ���������� ����� �� �������� ��� ������� �����
begin
  notLang:= True;
  try
    Result:= SaveFileResourceW(update, type_, name, LANG_NEUTRAL, aFile);
  finally
    notLang:= False;
  end;
end;

function SaveFileToDiscW(exeFile, type_, name, aFile: PWideChar): BOOL; stdcall;
// ���������� ������� ����� ����� �� ����
// exeFile - ���� � �����, � ������� ���������� ����
// type_   - ��� ������� (�������� �������)
// name    - ��� ������� (�������� �������)
// aFile   - ���� � ����� ��� ���������� �������
// SaveFileToDiscW('e:\Temp\Project1.exe', 'JPEG', 'MYJPEG', 'e:\Temp\Untitled-21.jpg')
const
  tmpFile = 'tmp.tmp';
var
  hUpdateRes: THandle;
  Buffer: array [0..MAX_PATH] of Char;
begin
  Result:= False;
  if Windows.GetTempPath(SizeOf(Buffer), Buffer) > 0 then
    // ����������� ��������, ��� ���� ����� �� ��������� ������ ��
    // �������� ������� ����, ����� ���� ��������
    if CopyFile(PChar(PWideToString(exeFile)), PWideChar(Buffer + tmpFile), False) then try
      exeFile:= PWideChar(WideString(Buffer + tmpFile));
      hUpdateRes:= BeginUpdateResourceW(exeFile, False);
      if hUpdateRes <> 0 then
        if SaveFileResource(hUpdateRes, type_, name, aFile) then
          Result:= EndUpdateResourceW(hUpdateRes, False);
    finally
      DeleteFileW(exeFile);
    end;
end;

function LoadFileToResourceW(exeFile, type_, name, aFile: PWideChar): BOOL; stdcall;
// ���������� ������� � ���� ����� �� ����
// exeFile - ���� � �����, � ������� �������� ����������� ���� ����
// type_   - ��� ������� (�������� �������)
// name    - ��� ������� (�������� �������)
// aFile   - ���� � �����, ������� ����� ��������� � ������
// LoadFileToResourceW('e:\Temp\Project1.exe', 'JPEG', 'MYJPEG', 'e:\Temp\Untitled-21.jpg')
var
  hUpdateRes: THandle;
begin
  Result:= False;
  hUpdateRes:= BeginUpdateResourceW(exeFile, False);
  if hUpdateRes <> 0 then if LoadFileResource(hUpdateRes, type_, name, aFile) then
    Result:= EndUpdateResourceW(hUpdateRes, False);
end;

function StringToPWide(sStr: AnsiString): PWideChar;
// �������������� String � PWideChar
var
  pw: PWideChar;
  iSize: integer;
  iNewSize: integer;
begin
  iSize:= Length(sStr) + 1;
  iNewSize:= iSize * 2;
  pw:= AllocMem(iNewSize);
  MultiByteToWideChar(CP_ACP, 0, PAnsiChar(sStr), iSize, pw, iNewSize);
  Result:= pw;
end;

function PWideToString(pw: PWideChar): string;
// �������������� PWideChar � String
{$IFNDEF UNICODE}
var
  p: PAnsiChar;
  iLen: Integer;
{$ENDIF}
begin
{$IFDEF UNICODE}
  Result := string(pw);
{$ENDIF}
{$IFNDEF UNICODE}
  iLen:= lstrlenw(pw) + 1;
  GetMem(p, iLen);
  try
    WideCharToMultiByte(CP_ACP, 0, pw, iLen, p, iLen * 2, nil, nil);
    Result := string(p);
  finally
    FreeMem(p, iLen);
  end;
{$ENDIF}
end;

////////////////////////////// madTools /////////////////////////////

const
  // PE header constants
  CENEWHDR = $003C;  // offset of new EXE header
  CEMAGIC  = $5A4D;  // old EXE magic id:  'MZ'
  CPEMAGIC = $4550;  // NT portable executable

function GetImageNtHeaders(module: dword) : PImageNtHeaders;
begin
  result := nil;
  try
    if word(pointer(module)^) = CEMAGIC then begin
      result := pointer(module + dword(pointer(module + CENEWHDR)^));
      if result^.signature <> CPEMAGIC then
        result := nil;
    end;
  except result := nil end;
end;
/////////////////////////// madStrings //////////////////////////////

const
  maxCard        = high(cardinal);

function RetDelete(const str : string;
                   index     : cardinal;
                   count     : cardinal = maxCard) : string;
begin
  result := str;
  Delete(result, index, count);
end;

procedure _FillStr(var str: string; fillLen: integer; addLeft: boolean; fillChar: Char);
var s1 : string;
I: Integer;
begin
  if fillLen > 0 then begin
    SetLength(s1, fillLen);
    for I := 1 to fillLen do
      s1[I] := fillChar;
    if addLeft then begin
      if CharInSet(fillChar, ['0'..'9']) and (str <> '') and (str[1] = '-') then
           str := '-' + s1 + RetDelete(str, 1, 1)
      else str := s1 + str;
    end else str := str + s1;
  end;
end;

function IntToHex(value: integer) : string; overload;
var c1, c2, c3 : cardinal;
begin
  if value <> 0 then begin
    c3 := cardinal(value);
    SetLength(result, 8);
    c1 := 8;
    repeat
      c2 := c3 mod $10;
      c3 := c3 div $10;
      if c2 > 9 then result[c1] := chr(ord('a') + c2 - $A)
      else           result[c1] := chr(ord('0') + c2 -  0);
      dec(c1);
    until c3 = 0;
    if c1 > 0 then begin
      Move(result[c1 + 1], result[1], 8 - c1);
      SetLength(result, 8 - c1);
    end;
  end else result := '0';
end;

function IntToHexEx(value    : integer;
                    minLen   : integer = 1;
                    fillChar : char = '0') : string; overload;
begin
  result := IntToHex(value);
  if (minLen < 0) or CharInSet(fillChar, ['0'..'9','A'..'F','a'..'f']) then begin
    _FillStr(result, abs(minLen) - Length(result), minLen > 0, fillChar);
    result := '$' + result;
  end else begin
    result := '$' + result;
    _FillStr(result, abs(minLen) - Length(result) + 1, true, fillChar);
  end;
end;

end.
