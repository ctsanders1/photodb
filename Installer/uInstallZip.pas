unit uInstallZip;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Zlib, uInstallTypes, uMemory, Classes, SysUtils, Math;

function AddFileToStream(Stream : TStream; FileName : string) : Boolean;
function ExtractStreamFromStorage(Src : TStream; Dest : TStream; FileName : string; CallBack : TExtractFileCallBack) : Boolean;
function ExtractFileFromStorage(Src : TStream; FileName : string; CallBack : TExtractFileCallBack) : Boolean;
function AddDirectoryToStream(Src : TStream; DirectoryName : string) : Boolean;
function ExtractDirectoryFromStorage(Src : TStream; DirectoryPath : string; CallBack : TExtractFileCallBack) : Boolean;
procedure FillFileList(Src : TStream; FileList : TStrings; out OriginalFilesSize : Int64);
function ReadFileContent(Src : TStream; FileName : string) : string;
function ExtractFileEntry(Src : TStream; FileName : string; var Entry : TZipEntryHeader) : Boolean;
function GetObjectSize(Src : TStream; FileName : string) : Int64;

implementation

procedure FillFileName(var Header : TZipEntryHeader; FileName : string);
var
  I : Integer;
begin
  FileName := ExtractFileName(FileName);
  if Length(FileName) > MaxFileNameLength then
    raise Exception.Create('FileName is too long!');

  Header.FileNameLength := Length(FileName);
  for I := 0 to MaxFileNameLength do
    Header.FileName[I] := FileName[I + 1];
end;

function ExtractFileNameFromHeader(Header : TZipEntryHeader) : string;
var
  I : Integer;
begin
  SetLength(Result, Header.FileNameLength);
  for I := 0 to Header.FileNameLength - 1 do
    Result[I + 1] := Header.FileName[I];
end;

function AddFileToStream(Stream : TStream; FileName : string) : Boolean;
var
  FS : TFileStream;
  MS : TmemoryStream;
  Compression : TCompressionStream;
  EntryHeader : TZipEntryHeader;
begin
  Result := True;
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    MS := TMemoryStream.Create;
    try
      Compression := TCompressionStream.Create(clMax, MS);
      try
        FS.Seek(0, soFromBeginning);
        Compression.CopyFrom(FS, FS.Size);
        F(Compression);

        FillChar(EntryHeader, SizeOf(EntryHeader), #0);
        FillFileName(EntryHeader, FileName);
        EntryHeader.FileOriginalSize := FS.Size;
        EntryHeader.FileCompressedSize := MS.Size;
        EntryHeader.IsDirectory := False;
        EntryHeader.ChildsCount := 0;
        Stream.Write(EntryHeader, SizeOf(EntryHeader));

        MS.Seek(0, soFromBeginning);
        Stream.CopyFrom(MS, MS.Size);
      finally
        F(Compression);
      end;
    finally
      F(MS);
    end;
  finally
    F(FS);
  end;
end;

function ExtractFileFromStorage(Src : TStream; FileName : string; CallBack : TExtractFileCallBack) : Boolean;
var
  FS : TFileStream;
begin
  Result := True;
  FS := TFileStream.Create(FileName, fmCreate);
  try
    ExtractStreamFromStorage(Src, FS, ExtractFileName(FileName), CallBack);
  finally
    F(FS);
  end;
end;

function ExtractStreamFromStorage(Src : TStream; Dest : TStream; FileName : string; CallBack : TExtractFileCallBack) : Boolean;
var
  EntryHeader : TZipEntryHeader;
  Decompression : TDecompressionStream;
  SizeToCopy, CopyedSize : Integer;
  Terminated : Boolean;
begin
  Result := False;
  Src.Seek(0, soFromBeginning);
  CopyedSize := 0;
  Terminated := False;

  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    try
      if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(FileName) then
      begin
        Decompression := TDecompressionStream.Create(Src);
        try
          while CopyedSize < EntryHeader.FileOriginalSize do
          begin
            SizeToCopy := Min(EntryHeader.FileOriginalSize - CopyedSize, ReadBufferSize);
            Dest.CopyFrom(Decompression, SizeToCopy);
            Inc(CopyedSize, SizeToCopy);
            if Assigned(CallBack) then
              CallBack(CopyedSize, EntryHeader.FileOriginalSize, Terminated);

            if Terminated then
              Exit;
          end;
        finally
          F(Decompression);
        end;
        Result := True;
        Exit;
      end;

    finally
      Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
    end;
  end;
end;

function AddDirectoryToStream(Src : TStream; DirectoryName : string) : Boolean;
var
  Files : TStrings;
  I, Found : Integer;
  SearchRec: TSearchRec;
  EntryHeader : TZipEntryHeader;
  TotalSize : Int64;
begin
  Result := True;
  Files := TStringList.Create;
  TotalSize := 0;
  DirectoryName := IncludeTrailingBackslash(DirectoryName);
  try
    Found := FindFirst(DirectoryName + '*.*', FaAnyFile - faDirectory - faHidden, SearchRec);
    while Found = 0 do
    begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        Files.Add(DirectoryName + SearchRec.Name);
        Inc(TotalSize, SearchRec.Size);
      end;

      Found := SysUtils.FindNext(SearchRec);
    end;
    FindClose(SearchRec);

    FillChar(EntryHeader, SizeOf(EntryHeader), #0);
    FillFileName(EntryHeader, ExcludeTrailingBackslash(DirectoryName));
    EntryHeader.FileOriginalSize := TotalSize;
    EntryHeader.FileCompressedSize := 0;
    EntryHeader.IsDirectory := True;
    EntryHeader.ChildsCount := Files.Count;
    Src.Write(EntryHeader, SizeOf(EntryHeader));

    for I := 0 to Files.Count - 1 do
      AddFileToStream(Src, Files[I]);

  finally
    F(Files);
  end;
end;

function ExtractDirectoryFromStorage(Src : TStream; DirectoryPath : string; CallBack : TExtractFileCallBack) : Boolean;
var
  I : Integer;
  EntryHeader : TZipEntryHeader;
  Decompression : TDecompressionStream;
  Dest : TFileStream;
  DirectoryName : string;
  FDoneBytes,
  FTotalBytes : Int64;
  Terminate : Boolean;
begin
  Result := False;
  Terminate := False;
  FDoneBytes := 0;
  Src.Seek(0, soFromBeginning);
  DirectoryPath := IncludeTrailingBackslash(DirectoryPath);
  DirectoryName := ExtractFileName(ExcludeTrailingBackslash(DirectoryPath));
  CreateDir(DirectoryPath);

  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    try
      if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(DirectoryName) then
      begin
        FTotalBytes := EntryHeader.FileOriginalSize;
        for I := 1 to EntryHeader.ChildsCount do
        begin
          Src.Read(EntryHeader, SizeOf(EntryHeader));
          Decompression := TDecompressionStream.Create(Src);
          try
            Dest := TFileStream.Create(DirectoryPath + ExtractFileNameFromHeader(EntryHeader), fmCreate);
            try
              Dest.CopyFrom(Decompression, EntryHeader.FileOriginalSize);
              Inc(FDoneBytes, Dest.Size);

              if Assigned(CallBack) then
                CallBack(FDoneBytes, FTotalBytes, Terminate);

              if Terminate then
                Exit;
            finally
              F(Dest);
            end;
          finally
            F(Decompression);
          end;
        end;
        Result := True;
        Exit;
      end;

    finally
      Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
    end;
  end;
end;

procedure FillFileList(Src : TStream; FileList : TStrings; out OriginalFilesSize : Int64);
var
  EntryHeader : TZipEntryHeader;
begin
  OriginalFilesSize := 0;
  Src.Seek(0, soFromBeginning);
  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    if not EntryHeader.IsDirectory then
    begin
      FileList.Add(ExtractFileNameFromHeader(EntryHeader));
      Inc(OriginalFilesSize, EntryHeader.FileOriginalSize);
    end;
    Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
  end;
end;

function ReadFileContent(Src : TStream; FileName : string) : string;
var
  MS : TMemoryStream;
  SR : TStreamReader;
begin
  Result := '';
  MS := TMemoryStream.Create;
  try
    if ExtractStreamFromStorage(Src, MS, FileName, nil) then
    begin
      if MS.Size > 0 then
      begin
        MS.Seek(0, soFromBeginning);
        SR := TStreamReader.Create(MS);
        try
          Result := SR.ReadToEnd;
        finally
          F(SR);
        end;
      end;
    end;
  finally
    F(MS);
  end;
end;

function ExtractFileEntry(Src : TStream; FileName : string; var Entry : TZipEntryHeader) : Boolean;
begin
  Result := False;
  Src.Seek(0, soFromBeginning);
  while Src.Read(Entry, SizeOf(Entry)) = SizeOf(Entry) do
  begin
    if AnsiLowerCase(ExtractFileNameFromHeader(Entry)) = AnsiLowerCase(FileName) then
    begin
      Result := True;
      Exit;
    end;
    Src.Seek(Entry.FileCompressedSize, soFromCurrent);
  end;
end;

function GetObjectSize(Src : TStream; FileName : string) : Int64;
var
  EntryHeader : TZipEntryHeader;
  I : Integer;
begin
  Result := 0;
  Src.Seek(0, soFromBeginning);
  while Src.Read(EntryHeader, SizeOf(EntryHeader)) = SizeOf(EntryHeader) do
  begin
    if AnsiLowerCase(ExtractFileNameFromHeader(EntryHeader)) = AnsiLowerCase(FileName) then
    begin
      if not EntryHeader.IsDirectory then
        Result := EntryHeader.FileOriginalSize
      else
      begin
        for I := 1 to EntryHeader.ChildsCount do
        begin
          Src.Read(EntryHeader, SizeOf(EntryHeader));
          Inc(Result, EntryHeader.FileOriginalSize);
          Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
        end;
      end;
      Exit;
    end;
    Src.Seek(EntryHeader.FileCompressedSize, soFromCurrent);
  end;
end;

end.