unit uMediaRepository;

interface

uses
  Generics.Collections,
  System.SysUtils,

  Dmitry.CRC32,
  Dmitry.Utils.System,

  UnitDBDeclare,

  uConstants,
  uMemory,
  uDBClasses,
  uDBConnection,
  uDBContext,
  uDBEntities,
  uCollectionEvents;

type
  TMediaRepository = class(TInterfacedObject, IMediaRepository)
  private
    FContext: IDBContext;
  public
    constructor Create(Context: IDBContext);
    destructor Destroy; override;
    function GetIdByFileName(FileName: string): Integer;
    function GetFileNameById(ID: Integer): string;
    procedure SetFileNameById(ID: Integer; FileName: string);
    procedure SetAccess(ID, Access: Integer);
    procedure SetRotate(ID, Rotate: Integer);
    procedure SetRating(ID, Rating: Integer);
    procedure SetAttribute(ID, Attribute: Integer);
    procedure DeleteFromCollection(FileName: string; ID: Integer);
    procedure DeleteFromCollectionEx(IDs: TList<Integer>);
    procedure PermanentlyDeleteFromCollectionEx(IDs: TList<Integer>);
    procedure DeleteDirectoryFromCollection(DirectoryName: string);
    function GetCount: Integer;
    function GetMenuItemByID(ID: Integer): TMediaItem;
    function GetMenuItemsByID(ID: Integer): TMediaItemCollection;
    function GetMenuInfosByUniqId(UniqId: string): TMediaItemCollection;
    procedure UpdateMediaInfosFromDB(Info: TMediaItemCollection);
    function UpdateMediaFromDB(Media: TMediaItem; LoadThumbnail: Boolean): Boolean;
    function GetTopImagesWithPersons(MinDate: TDateTime; MaxItems: Integer): TMediaItemCollection;
    procedure IncMediaCounter(ID: Integer);
    procedure UpdateLinks(ID: Integer; NewLinks: string);
    procedure RefreshImagesCache;
  end;

implementation

{ TMediaRepository }

constructor TMediaRepository.Create(Context: IDBContext);
begin
  FContext := Context;
end;

destructor TMediaRepository.Destroy;
begin
  FContext := nil;
  inherited;
end;

procedure TMediaRepository.DeleteDirectoryFromCollection(DirectoryName: string);
var
  UC: TUpdateCommand;
  SC: TSelectCommand;
  EventInfo: TEventValues;
  MediaItem: TMediaItem;
begin
  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', Integer(GetPathCRC(DirectoryName, False))));
    SC.AddWhereParameter(TStringParameter.Create('FFileName', AnsiLowerCase(DirectoryName) + '%', paLike));

    if SC.Execute > 0 then
    begin

      UC := FContext.CreateUpdate(ImageTable);
      try
        UC.AddParameter(TDateTimeParameter.Create('DateUpdated', Now));
        UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_deleted));

        UC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', Integer(GetPathCRC(DirectoryName, False))));
        UC.AddWhereParameter(TStringParameter.Create('FFileName', AnsiLowerCase(DirectoryName) + '%', paLike));

        UC.Execute;

        while not SC.DS.Eof do
        begin
          MediaItem := TMediaItem.CreateFromDS(SC.DS);
          try
            EventInfo.ID := MediaItem.ID;
            CollectionEvents.DoIDEvent(nil, MediaItem.ID, [EventID_Param_Delete], EventInfo);
          finally
            F(MediaItem);
          end;

          SC.DS.Next;
        end;
      finally
        F(UC);
      end;
    end;
  finally
    F(SC);
  end;
end;

procedure TMediaRepository.DeleteFromCollection(FileName: string; ID: Integer);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddParameter(TDateTimeParameter.Create('DateUpdated', Now));
    UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_deleted));

    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.Execute;

    EventInfo.ID := ID;
    EventInfo.FileName := FileName;
    CollectionEvents.DoIDEvent(nil, ID, [EventID_Param_Delete], EventInfo);
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.DeleteFromCollectionEx(IDs: TList<Integer>);
var
  I: Integer;
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  for I := 0 to IDs.Count - 1 do
  begin
    UC := FContext.CreateUpdate(ImageTable);
    try
      UC.AddParameter(TDateTimeParameter.Create('DateUpdated', Now));
      UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_deleted));
      UC.AddWhereParameter(TIntegerParameter.Create('ID', IDs[I]));

      UC.Execute;

      EventInfo.ID := IDs[I];
      CollectionEvents.DoIDEvent(nil, IDs[I], [EventID_Param_Delete], EventInfo);
    finally
      F(UC);
    end;
  end;
end;

procedure TMediaRepository.PermanentlyDeleteFromCollectionEx(IDs: TList<Integer>);
var
  I: Integer;
  DC: TDeleteCommand;
  EventInfo: TEventValues;
begin
  for I := 0 to IDs.Count - 1 do
  begin
    DC := FContext.CreateDelete(ImageTable);
    try
      DC.AddWhereParameter(TIntegerParameter.Create('ID', IDs[I]));

      DC.Execute;

      EventInfo.ID := IDs[I];
      CollectionEvents.DoIDEvent(nil, IDs[I], [EventID_Param_Delete], EventInfo);
    finally
      F(DC);
    end;
  end;
end;

function TMediaRepository.GetCount: Integer;
var
  SC: TSelectCommand;
begin
  Result := 0;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TCustomFieldParameter.Create('COUNT(*) AS ITEMS_COUNT'));
    SC.AddWhereParameter(TCustomConditionParameter.Create(FormatEx('Attr <> {0}', [Db_attr_deleted])));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('ITEMS_COUNT').AsInteger;
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetFileNameById(ID: Integer): string;
var
  SC: TSelectCommand;
begin
  Result := '';

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TStringParameter.Create('FFileName'));
    SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('FFileName').AsString;
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetIdByFileName(FileName: string): Integer;
var
  SC: TSelectCommand;
begin
  Result := 0;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TIntegerParameter.Create('ID'));

    SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', Integer(GetPathCRC(FileName, True))));
    SC.AddWhereParameter(TStringParameter.Create('FFileName', AnsiLowerCase(FileName), paEquals));

    if SC.Execute > 0 then
      Result := SC.DS.FieldByName('ID').AsInteger;
  finally
    F(SC);
  end;
end;

procedure TMediaRepository.SetAccess(ID, Access: Integer);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Access', Access));
    UC.Execute;

    EventInfo.ID := ID;
    EventInfo.Access := Access;
    CollectionEvents.DoIDEvent(nil, ID, [EventID_Param_Access], EventInfo);
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetAttribute(ID, Attribute: Integer);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Attr', Attribute));
    UC.Execute;

    EventInfo.ID := ID;
    EventInfo.Attr := Attribute;
    CollectionEvents.DoIDEvent(nil, ID, [EventID_Param_Attr], EventInfo);
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetFileNameById(ID: Integer; FileName: string);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(FileName, True)));
    UC.AddParameter(TStringParameter.Create('FFileName', AnsiLowerCase(FileName)));
    UC.AddParameter(TStringParameter.Create('Name', ExtractFileName(FileName)));
    UC.AddParameter(TIntegerParameter.Create('Attr', Db_attr_norm));

    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetRating(ID, Rating: Integer);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Rating', Rating));
    UC.Execute;

    EventInfo.ID := ID;
    EventInfo.Rating := Rating;
    CollectionEvents.DoIDEvent(nil, ID, [EventID_Param_Rating], EventInfo);
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.SetRotate(ID, Rotate: Integer);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  UC := FContext.CreateUpdate(ImageTable);
  try
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    UC.AddParameter(TIntegerParameter.Create('Rotated', Rotate));
    UC.Execute;

    EventInfo.ID := ID;
    EventInfo.Rotation := Rotate;
    CollectionEvents.DoIDEvent(nil, ID, [EventID_Param_Rotate], EventInfo);
  finally
    F(UC);
  end;
end;

function TMediaRepository.GetMenuItemByID(ID: Integer): TMediaItem;
var
  SC: TSelectCommand;
begin
  Result := nil;
  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create);
    SC.AddWhereParameter(TIntegerParameter.Create('ID', ID));

    if SC.Execute > 0 then
      Result := TMediaItem.CreateFromDS(SC.DS);
  finally
    F(SC);
  end;
end;

function TMediaRepository.GetMenuItemsByID(ID: Integer): TMediaItemCollection;
var
  MediaItem: TMediaItem;
begin
  Result := TMediaItemCollection.Create;
  MediaItem := GetMenuItemByID(ID);
  if MediaItem <> nil then
    Result.Add(MediaItem);
end;

function TMediaRepository.GetTopImagesWithPersons(MinDate: TDateTime;
  MaxItems: Integer): TMediaItemCollection;
var
  SQL: string;
  MediaItem: TMediaItem;
  SC: TSelectCommand;
  DFormatSettings: TFormatSettings;
begin
  Result := TMediaItemCollection.Create;
  SC := FContext.CreateSelect(ImageTable);
  try

    SQL := 'SELECT TOP {3} * FROM                                                     ' +
           '  (SELECT IM1.* from {0} AS IM1                                           ' +
           '   LEFT JOIN                                                              ' +
           '     (SELECT DISTINCT Im.ID, Im.Rating FROM {0} im                        ' +
           '      INNER JOIN {1} OM on Im.Id = OM.ImageId) AS IR on IR.ID = IM1.ID    ' +
           '   WHERE DateToAdd > #{2}#                                                ' +
           '   ORDER BY [IM1].[ID] ASC) AS Result                                 ';

    DFormatSettings := FormatSettings;
    DFormatSettings.DateSeparator := '/';

    SQL := FormatEx(SQL, [ImageTable, ObjectMappingTableName, FormatDateTime('dd/mm/yyyy', MinDate, DFormatSettings), MaxItems]);

    if SC.ExecuteSQL(SQL, True) > 0 then
    begin
      while not SC.DS.Eof do
      begin
        MediaItem := TMediaItem.Create;
        MediaItem.ReadFromDS(SC.DS);
        Result.Add(MediaItem);

        SC.DS.Next;
      end;
    end;
  finally
    F(SC);
  end;
end;

procedure TMediaRepository.IncMediaCounter(ID: Integer);
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable, True);
  try
    UC.AddParameter(TCustomFieldParameter.Create('[ViewCount] = [ViewCount] + 1'));
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.RefreshImagesCache;
var
  UC: TUpdateCommand;
begin
  UC := FContext.CreateUpdate(ImageTable, True);
  try
    UC.AddParameter(TDateTimeParameter.Create('DateUpdated', EncodeDate(1900, 1, 1)));
    UC.AddWhereParameter(TCustomConditionParameter.Create('1=1'));
    UC.Execute;
  finally
    F(UC);
  end;
end;

procedure TMediaRepository.UpdateLinks(ID: Integer; NewLinks: string);
var
  UC: TUpdateCommand;
  EventInfo: TEventValues;
begin
  UC := FContext.CreateUpdate(ImageTable, True);
  try
    UC.AddParameter(TStringParameter.Create('Links', NewLinks));
    UC.AddWhereParameter(TIntegerParameter.Create('ID', ID));
    UC.Execute;

    EventInfo.ID := ID;
    EventInfo.Links := NewLinks;
    CollectionEvents.DoIDEvent(nil, ID, [EventID_Param_Links], EventInfo);
  finally
    F(UC);
  end;
end;

function TMediaRepository.GetMenuInfosByUniqId(UniqId: string): TMediaItemCollection;
var
  SC: TSelectCommand;
  MediaItem: TMediaItem;
begin
  Result := TMediaItemCollection.Create;

  SC := FContext.CreateSelect(ImageTable);
  try
    SC.AddParameter(TAllParameter.Create);

    SC.AddWhereParameter(TIntegerParameter.Create('StrThCrc', StringCRC(UniqId)));
    SC.AddWhereParameter(TStringParameter.Create('StrTh', UniqId));

    if SC.Execute > 0 then
    begin
      while not SC.DS.Eof do
      begin
        MediaItem := TMediaItem.CreateFromDS(SC.DS);
        Result.Add(MediaItem);

        SC.DS.Next;
      end;
      Result.Position := 0;
    end;

  finally
    F(SC);
  end;
end;

procedure TMediaRepository.UpdateMediaInfosFromDB(Info: TMediaItemCollection);
var
  I, J: Integer;
  SC: TSelectCommand;
  MediaItem: TMediaItem;
begin
  for I := 0 to Info.Count - 1 do
  begin
    if not Info[I].InfoLoaded then
    begin
      SC := FContext.CreateSelect(ImageTable);
      try
        //todo: don't select images
        SC.AddParameter(TAllParameter.Create);

        SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(Info[I].FileName, True)));

        if SC.Execute > 0 then
        begin
          while not SC.DS.Eof do
          begin
            MediaItem := TMediaItem.CreateFromDS(SC.DS);

            for J := I to Info.Count - 1 do
            begin
              if AnsiLowerCase(Info[I].FileName) = MediaItem.FileName then
                Info[I].Assign(MediaItem);
            end;

            SC.DS.Next;
          end;

        end;
      finally
        F(SC);
      end;
    end;
  end;
end;

function TMediaRepository.UpdateMediaFromDB(Media: TMediaItem; LoadThumbnail: Boolean): Boolean;
var
  SC: TSelectCommand;
begin
  Result := False;

  SC := FContext.CreateSelect(ImageTable);
  try
    if Media.ID > 0 then
      SC.AddWhereParameter(TIntegerParameter.Create('ID', Media.ID))
    else
    begin
      SC.AddWhereParameter(TIntegerParameter.Create('FolderCRC', GetPathCRC(Media.FileName, True)));
      SC.AddWhereParameter(TStringParameter.Create('Name', ExtractFileName(Media.FileName)));
    end;
    SC.AddParameter(TAllParameter.Create());

    if SC.Execute > 0 then
    begin
      Media.ReadFromDS(SC.DS);
      if LoadThumbnail then
        Media.LoadImageFromDS(SC.DS);

      Media.Tag := EXPLORER_ITEM_IMAGE;
    end;
  finally
    F(SC);
  end;
end;

end.
