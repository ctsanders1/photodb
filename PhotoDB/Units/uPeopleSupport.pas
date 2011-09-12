unit uPeopleSupport;

interface

uses
  SysUtils, Classes, DB, jpeg, uMemory, SyncObjs, uDBClasses, uPersonDB;

const
  PersonTableName = 'Persons';

type
  TPerson = class;

  TPersonCollection = class;

  TPersonArea = class;

  TPersonAreaCollection = class;

  TPersonManager = class(TObject)
  private
    FPeoples: TList;
    FSync: TCriticalSection;
    function GetAllPersons: TPersonCollection;
  public
    procedure InitDB;
    function FindPersone(PersonID: Integer): TPerson;
    function CreateNewPerson(Person: TPerson): Boolean;
    function DeletePerson(PersonID: Integer): Boolean;
    function UpdatePerson(Person: TPerson): Boolean;
    function GetPersonsOnImage(ImageID: Integer): TPersonCollection;
    function GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
    function AddPersonForPhoto(ImageID: Integer; PersonArea: TPersonArea): Boolean;
    function RemovePersonFromPhoto(ImageID: Integer; PersonID: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
    property AllPersons: TPersonCollection read GetAllPersons;
  end;

  TPersonCollection = class(TObject)
  private
    FList: TList;
    function GetCount: Integer;
    function GetPersonByIndex(Index: Integer): TPerson;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ReadFromDS(DS: TDataSet);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPerson read GetPersonByIndex; default;
  end;

  TPerson = class(TObject)
  private
    FID: Integer;
    FName: string;
    FImage: TJpegImage;
    FGroups: string;
    FBirthDay: TDateTime;
    FComment: string;
    FPhone: string;
    FAddress: string;
    FCompany: string;
    FJobTitle: string;
    FIMNumber: string;
    FEmail: string;
    FSex: Integer;
    procedure SetImage(const Value: TJpegImage);
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
    property ID: Integer read FID write FID;
    property Name: string read FName write FName;
    property BirthDay: TDateTime read FBirthDay write FBirthDay;
    property Image: TJpegImage read FImage write SetImage;
    property Groups: string read FGroups write FGroups;
    property Comment: string read FComment write FComment;
    property Phone: string read FPhone write FPhone;
    property Address: string read FAddress write FAddress;
    property Company: string read FCompany write FCompany;
    property JobTitle: string read FJobTitle write FJobTitle;
    property IMNumber: string read FIMNumber write FIMNumber;
    property Email: string read FEmail write FEmail;
    property Sex: Integer read FSex write FSex;
  end;

  TPersonArea = class
  private
    FX: Integer;
    FY: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FFullWidth: Integer;
    FFullHeight: Integer;
    FImageID: Integer;
    FPersonID: Integer;
  public
    procedure ReadFromDS(DS: TDataSet);
    procedure SaveToDS(DS: TDataSet);
  end;

  TPersonAreaCollection = class(TObject)
  private
    FList: TList;
    function GetAreaByIndex(Index: Integer): TPersonArea;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ReadFromDS(DS: TDataSet);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPersonArea read GetAreaByIndex; default;
  end;

function PersonManager: TPersonManager;

implementation

var
  FManager: TPersonManager = nil;

function PersonManager: TPersonManager;
begin
  if FManager = nil then
    FManager := TPersonManager.Create;

  Result := FManager;
end;

{ TPerson }

constructor TPerson.Create;
begin
  FID := 0;
  FName := '';
  FImage := nil;
  FGroups := '';
end;

destructor TPerson.Destroy;
begin
  F(FImage);
  inherited;
end;

procedure TPerson.ReadFromDS(DS: TDataSet);
begin

end;

procedure TPerson.SaveToDS(DS: TDataSet);
begin

end;

procedure TPerson.SetImage(const Value: TJpegImage);
begin
  F(FImage);
  FImage := TJpegImage.Create;
  FImage.Assign(Value);
end;

{ TPersonManager }

function TPersonManager.AddPersonForPhoto(ImageID: Integer;
  PersonArea: TPersonArea): Boolean;
begin

end;

constructor TPersonManager.Create;
begin
  FPeoples := TList.Create;
  FSync := TCriticalSection.Create;
end;

function TPersonManager.CreateNewPerson(Person: TPerson): Boolean;
var
  IC: TInsertCommand;
begin
  Result := False;

  IC := TInsertCommand.Create(PersonTableName);
  try
    IC.AddParameter(TStringParameter.Create('PersonName', Person.Name));
    IC.AddParameter(TStringParameter.Create('RelatedGroups', Person.Groups));
    IC.AddParameter(TDateTimeParameter.Create('BirthDate', Person.BirthDay));
    IC.AddParameter(TStringParameter.Create('PersonPhone', Person.Phone));
    IC.AddParameter(TStringParameter.Create('PersonAddress', Person.Address));
    IC.AddParameter(TStringParameter.Create('Company', Person.Company));
    IC.AddParameter(TStringParameter.Create('JobTitle', Person.JobTitle));
    IC.AddParameter(TStringParameter.Create('IMNumber', Person.IMNumber));
    IC.AddParameter(TStringParameter.Create('PersonEmail', Person.Email));
    IC.AddParameter(TIntegerParameter.Create('PersonSex', Person.Sex));
    IC.AddParameter(TStringParameter.Create('PersonComment', Person.Comment));
    IC.AddParameter(TJpegParameter.Create('PersonImage', Person.Image));
    IC.AddParameter(TDateTimeParameter.Create('CreateDate', Now));

    try
      IC.Execute;
    except
      Exit;
    end;

    Result := True;
  finally
    F(IC);
  end;
end;

function TPersonManager.DeletePerson(PersonID: Integer): Boolean;
var
  DC: TDeleteCommand;
begin
  Result := False;
  DC := TDeleteCommand.Create(PersonTableName);
  try
    DC.AddWhereParameter(TIntegerParameter.Create('PersonId', PersonID));
    try
      DC.Execute;
    except
      Exit;
    end;

    Result := True;
  finally
    F(DC);
  end;
end;

destructor TPersonManager.Destroy;
begin
  FreeList(FPeoples);
  F(FSync);
  inherited;
end;

function TPersonManager.FindPersone(PersonID: Integer): TPerson;
begin

end;

function TPersonManager.GetAllPersons: TPersonCollection;
begin

end;

function TPersonManager.GetAreasOnImage(ImageID: Integer): TPersonAreaCollection;
begin

end;

function TPersonManager.GetPersonsOnImage(ImageID: Integer): TPersonCollection;
begin

end;

procedure TPersonManager.InitDB;
begin
  if not CheckPersonTables(DatabaseManager.DBFile) then
  begin
    ADOCreatePersonsTable(DatabaseManager.DBFile);
    ADOCreatePersonMappingTable(DatabaseManager.DBFile);
  end;
end;

function TPersonManager.RemovePersonFromPhoto(ImageID,
  PersonID: Integer): Boolean;
begin

end;

function TPersonManager.UpdatePerson(Person: TPerson): Boolean;
var
  UC: TUpdateCommand;
begin
  Result := False;

  UC := TUpdateCommand.Create(PersonTableName);
  try
    UC.AddParameter(TStringParameter.Create('PersonName', Person.Name));
    UC.AddParameter(TStringParameter.Create('RelatedGroups', Person.Groups));
    UC.AddParameter(TDateTimeParameter.Create('BirthDate', Person.BirthDay));
    UC.AddParameter(TStringParameter.Create('PersonPhone', Person.Phone));
    UC.AddParameter(TStringParameter.Create('PersonAddress', Person.Address));
    UC.AddParameter(TStringParameter.Create('Company', Person.Company));
    UC.AddParameter(TStringParameter.Create('JobTitle', Person.JobTitle));
    UC.AddParameter(TStringParameter.Create('IMNumber', Person.IMNumber));
    UC.AddParameter(TStringParameter.Create('PersonEmail', Person.Email));
    UC.AddParameter(TIntegerParameter.Create('PersonSex', Person.Sex));
    UC.AddParameter(TStringParameter.Create('PersonComment', Person.Comment));
    UC.AddParameter(TJpegParameter.Create('PersonImage', Person.Image));

    UC.AddWhereParameter(TIntegerParameter.Create('PersonID', Person.ID));
    try
      UC.Execute;
    except
      Exit;
    end;

    Result := True;
  finally
    F(UC);
  end;
end;

{ TPersonCollection }

procedure TPersonCollection.Clear;
begin
  FreeList(FList, False);
end;

constructor TPersonCollection.Create;
begin
  FList := TList.Create;
end;

destructor TPersonCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TPersonCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPersonCollection.GetPersonByIndex(Index: Integer): TPerson;
begin
  Result := FList[Index];
end;

procedure TPersonCollection.ReadFromDS(DS: TDataSet);
begin
  Clear;
end;

{ TPersonAreaCollection }

procedure TPersonAreaCollection.Clear;
begin
  FreeList(FList, False);
end;

constructor TPersonAreaCollection.Create;
begin
  FList := TList.Create;
end;

destructor TPersonAreaCollection.Destroy;
begin
  FreeList(FList);
  inherited;
end;

function TPersonAreaCollection.GetAreaByIndex(Index: Integer): TPersonArea;
begin
  Result := FList[Index];
end;

function TPersonAreaCollection.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure TPersonAreaCollection.ReadFromDS(DS: TDataSet);
begin
  Clear;
end;

{ TPersonArea }

procedure TPersonArea.ReadFromDS(DS: TDataSet);
begin

end;

procedure TPersonArea.SaveToDS(DS: TDataSet);
begin

end;

end.
