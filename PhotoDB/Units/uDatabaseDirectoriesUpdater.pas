unit uDatabaseDirectoriesUpdater;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  Generics.Defaults,
  Generics.Collections,
  System.SyncObjs,
  System.SysUtils,
  System.Classes,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Utils.System,

  CommonDBSupport,
  UnitUpdateDBObject,
  UnitINI,
  UnitDBDeclare,

  uConstants,
  uRuntime,
  uMemory,
  uGUIDUtils,
  uInterfaces,
  uAssociations,
  uDBAdapter,
  uDBThread,
  wfsU,
  uGOM,
  uSettings;

type
  TDatabaseDirectory = class(TDataObject)
  private
    FPath: string;
    FName: string;
    FIcon: string;
    FSortOrder: Integer;
  public
    constructor Create(Path, Name, Icon: string; SortOrder: Integer);
    function Clone: TDataObject; override;
    procedure Assign(Source: TDataObject); override;
    property Path: string read FPath write FPath;
    property Name: string read FName write FName;
    property Icon: string read FIcon write FIcon;
    property SortOrder: Integer read FSortOrder write FSortOrder;
  end;

  TDatabaseDirectoriesUpdater = class(TDBThread)
  private
    FQuery: TDataSet;
    FThreadID: TGUID;
    FSkipExtensions: string;
    FAddRawFiles: Boolean;
    function IsDirectoryChangedOnDrive(Directory: string; ItemSizes: TList<Int64>; Items: TList<string>): Boolean;
    procedure AddItemsToDatabase(Items: TList<string>);
    function GetIsValidThread: Boolean;
    function CanAddFileAutomatically(FileName: string): Boolean;
    property IsValidThread: Boolean read GetIsValidThread;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  IUserDirectoriesWatcher = interface
    ['{ED4EF3E3-43A6-4D86-A40D-52AA1DFAD299}']
    procedure Execute;
  end;

  TUserDirectoriesWatcher = class(TInterfacedObject, IUserDirectoriesWatcher, IDirectoryWatcher)
  private
    FWatchers: TList<TWachDirectoryClass>;
    FState: TGUID;
    procedure StartWatch;
    procedure StopWatch;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute;
    procedure DirectoryChanged(Sender: TObject; SID: TGUID; pInfo: TInfoCallBackDirectoryChangedArray);
    procedure TerminateWatcher(Sender: TObject; SID: TGUID; Folder: string);
  end;

implementation

var
  DirectoriesScanID: TGUID = '{00000000-0000-0000-0000-000000000000}';

procedure FillDatabaseDirectories(FolderList: TList<TDatabaseDirectory>);
const
  UpdaterDirectoriesFormat = '\Updater\Databases\{0}';

var
  Reg: TBDRegistry;
  DBPrefix, FName, FPath, FIcon: string;
  I, SortOrder: Integer;
  S: TStrings;
  DD: TDatabaseDirectory;

begin
  FolderList.Clear;

  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    DBPrefix := ExtractFileName(dbname) + IntToStr(StringCRC(dbname));

    Reg.OpenKey(GetRegRootKey + FormatEx(UpdaterDirectoriesFormat, [DBPrefix]), True);
    S := TStringList.Create;
    try
      Reg.GetKeyNames(S);

      for I := 0 to S.Count - 1 do
      begin
        Reg.CloseKey;
        Reg.OpenKey(GetRegRootKey + FormatEx(UpdaterDirectoriesFormat, [DBPrefix]) + S[I], True);

        FName := '';
        FPath := '';
        FIcon := '';
        SortOrder := 0;
        if Reg.ValueExists('Path') then
          FPath := Reg.ReadString('Path');
        if Reg.ValueExists('Icon') then
          FIcon := Reg.ReadString('Icon');
        if Reg.ValueExists('SortOrder') then
          SortOrder := Reg.ReadInteger('SortOrder');

        if (S[I] <> '') and (FPath <> '') then
        begin
          DD := TDatabaseDirectory.Create(S[I], FPath, FIcon, SortOrder);
          FolderList.Add(DD);
        end;
      end;
    finally
      F(S);
    end;
  finally
    F(Reg);
  end;

  DD := TDatabaseDirectory.Create('D:\dmitry\my pictures\photoes', 'TEST', '', 0);
  FolderList.Add(DD);

  FolderList.Sort(TComparer<TDatabaseDirectory>.Construct(
     function (const L, R: TDatabaseDirectory): Integer
     begin
       Result := L.SortOrder - R.SortOrder;
     end
  ));
end;

{ TDatabaseDirectory }

procedure TDatabaseDirectory.Assign(Source: TDataObject);
var
  DD: TDatabaseDirectory;
begin
  DD := Source as TDatabaseDirectory;
  Self.Path := DD.Path;
  Self.Name := DD.Name;
  Self.Icon := DD.Icon;
  Self.SortOrder := DD.SortOrder;
end;

function TDatabaseDirectory.Clone: TDataObject;
begin
  Result := TDatabaseDirectory.Create(Path, Name, Icon, SortOrder);
end;

constructor TDatabaseDirectory.Create(Path, Name, Icon: string; SortOrder: Integer);
begin
  Self.Path := Path;
  Self.Name := Name;
  Self.Icon := Icon;
  Self.SortOrder := SortOrder;
end;
  
{ TDatabaseDirectoriesUpdater }

function TDatabaseDirectoriesUpdater.CanAddFileAutomatically(
  FileName: string): Boolean;
var
  Ext: string;
begin
  if not FAddRawFiles and IsRAWImageFile(FileName) then
    Exit(False);

  if FSkipExtensions <> '' then
  begin
    Ext := AnsiLowerCase(ExtractFileExt(FileName));
    if FSkipExtensions.IndexOf(AnsiLowerCase(Ext)) > 0 then
      Exit(False);
  end;

  Exit(True);
end;

constructor TDatabaseDirectoriesUpdater.Create;
begin
  inherited Create(nil, False);
  FThreadID := GetGUID;
  DirectoriesScanID := FThreadID;

  FSkipExtensions := AnsiLowerCase(Settings.ReadString('Updater', 'SkipExtensions'));
  FAddRawFiles := Settings.ReadBool('Updater', 'AddRawFiles', False);

  FQuery := GetQuery(True);
end;

destructor TDatabaseDirectoriesUpdater.Destroy;
begin
  FreeDS(FQuery);
  inherited;
end;

procedure TDatabaseDirectoriesUpdater.Execute;
var
  FolderList: TList<TDatabaseDirectory>;
  DD: TDatabaseDirectory;
  Directories: TQueue<string>;
  Items: TList<string>;
  ItemSizes: TList<Int64>;
  Found: Integer;
  OldMode: Cardinal;
  SearchRec: TSearchRec;
  Dir: string;
begin
  inherited;
  FreeOnTerminate := True;

  CoInitializeEx(nil, COM_MODE);
  try

    Directories := TQueue<string>.Create;
    Items := TList<string>.Create;
    ItemSizes := TList<Int64>.Create;
    OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
    try

      //list of directories to scan
      FolderList := TList<TDatabaseDirectory>.Create;
      try
        FillDatabaseDirectories(FolderList);
        for DD in FolderList do
          Directories.Enqueue(DD.Path);

      finally
        FreeList(FolderList);
      end;

      while Directories.Count > 0 do
      begin
        if DBTerminating or not IsValidThread then
          Break;

        Dir := Directories.Dequeue;

        Dir := IncludeTrailingBackslash(Dir);

        ItemSizes.Clear;
        Items.Clear;
        Found := FindFirst(Dir + '*.*', faDirectory, SearchRec);
        try
          while Found = 0 do
          begin
            if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            begin
              if (faDirectory and SearchRec.Attr = 0) and IsGraphicFile(SearchRec.Name) and CanAddFileAutomatically(SearchRec.Name) then
              begin
                ItemSizes.Add(SearchRec.Size);
                Items.Add(Dir + SearchRec.Name);
              end;

              if faDirectory and SearchRec.Attr <> 0 then
                Directories.Enqueue(Dir + SearchRec.Name);
            end;
            Found := System.SysUtils.FindNext(SearchRec);
          end;
        finally
          FindClose(SearchRec);
        end;

        if IsDirectoryChangedOnDrive(Dir, ItemSizes, Items) and IsValidThread then
          AddItemsToDatabase(Items);
      end;

    finally
      SetErrorMode(OldMode);
      F(ItemSizes);
      F(Items);
      F(Directories);
    end;
  finally
    CoUninitialize;
  end;
end;

function TDatabaseDirectoriesUpdater.GetIsValidThread: Boolean;
begin
  Result := FThreadID = DirectoriesScanID;
end;

function TDatabaseDirectoriesUpdater.IsDirectoryChangedOnDrive(
  Directory: string; ItemSizes: TList<Int64>; Items: TList<string>): Boolean;
var
  I, J: Integer;
  DA: TDBAdapter;
  FileName: string;
begin
  SetSQL(FQuery, 'Select ID, FileSize, Name FROM $DB$ WHERE FolderCRC = ' + IntToStr(GetPathCRC(Directory, False)));
  if TryOpenCDS(FQuery) then
  begin
    if not FQuery.IsEmpty then
    begin
      FQuery.First;
      DA := TDBAdapter.Create(FQuery);
      try
        for I := 1 to FQuery.RecordCount do
        begin
          FileName := AnsiLowerCase(Directory + DA.Name);

          for J := Items.Count - 1 downto 0 do
            if(AnsiLowerCase(Items[J]) = FileName) and (ItemSizes[J] = DA.FileSize) then
            begin
              Items.Delete(J);
              ItemSizes.Delete(J);
            end;

          FQuery.Next;
        end;

      finally
        F(DA);
      end;
    end;

    Exit(Items.Count > 0);

  end else
    Exit(True);
end;

procedure TDatabaseDirectoriesUpdater.AddItemsToDatabase(Items: TList<string>);
var
  FileName: string;
begin
  for FileName in Items do
    UpdaterDB.AddFile(FileName, True);
end;

{ TUserDirectoriesWatcher }

constructor TUserDirectoriesWatcher.Create;
begin
  FWatchers := TList<TWachDirectoryClass>.Create;
  GOM.AddObj(Self);
end;

destructor TUserDirectoriesWatcher.Destroy;
begin
  StopWatch;
  FreeList(FWatchers);
  GOM.RemoveObj(Self);
  inherited;
end;

procedure TUserDirectoriesWatcher.Execute;
begin
  inherited;
  StartWatch;
  TDatabaseDirectoriesUpdater.Create;
end;

procedure TUserDirectoriesWatcher.StartWatch;
var
  Watch: TWachDirectoryClass;
  FolderList: TList<TDatabaseDirectory>;
  DD: TDatabaseDirectory;
begin
  StopWatch;
  FState := GetGUID;

  //list of directories to watch
  FolderList := TList<TDatabaseDirectory>.Create;
  try
    FillDatabaseDirectories(FolderList);
    for DD in FolderList do
    begin
      Watch := TWachDirectoryClass.Create;
      FWatchers.Add(Watch);
      Watch.Start(DD.Path, Self, Self, FState, True);
    end;

  finally
    FreeList(FolderList);
  end;
end;

procedure TUserDirectoriesWatcher.StopWatch;
var
  I: Integer;
begin
  for I := 0 to FWatchers.Count - 1 do
    FWatchers[I].StopWatch;
  
  FreeList(FWatchers, False);
end;

procedure TUserDirectoriesWatcher.DirectoryChanged(Sender: TObject; SID: TGUID;
  pInfo: TInfoCallBackDirectoryChangedArray);
begin
  if FState = SID then
  begin

  end;
end;

procedure TUserDirectoriesWatcher.TerminateWatcher(Sender: TObject; SID: TGUID;
  Folder: string);
begin
  //do nothing
end;

end.

