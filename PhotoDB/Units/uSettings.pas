unit uSettings;

interface

uses
  Windows, Classes, SysUtils, uMemory, uConstants, UnitINI;

type
  TSettings = class(TObject)
  private
    FRegistryCache: TDBRegistryCache;
    function GetDataBase: string;
  public
    constructor Create;
    destructor Destroy; override;
    function ReadProperty(Key, Name: string): string;
    procedure DeleteKey(Key: string);
    procedure WriteProperty(Key, Name, Value: string);
    procedure WriteBool(Key, Name: string; Value: Boolean);
    procedure WriteBoolW(Key, Name: string; Value: Boolean);
    procedure WriteInteger(Key, Name: string; Value: Integer);
    procedure WriteStringW(Key, Name, Value: string);
    procedure WriteString(Key, Name: string; Value: string);
    procedure WriteDateTime(Key, Name: string; Value: TDateTime);
    function ReadKeys(Key: string): TStrings;
    function ReadValues(Key: string): TStrings;
    function ReadBool(Key, Name: string; Default: Boolean): Boolean;
    function ReadRealBool(Key, Name: string; Default: Boolean): Boolean;
    function ReadboolW(Key, Name: string; Default: Boolean): Boolean;
    function ReadInteger(Key, Name: string; Default: Integer): Integer;
    function ReadString(Key, Name: string; Default: string = ''): string;
    function ReadStringW(Key, Name: string; Default: string = ''): string;
    function ReadDateTime(Key, Name: string; Default: TdateTime): TDateTime;
    procedure DeleteValues(Key: string);
    property DataBase: string read GetDataBase;
  end;

function Settings: TSettings;

implementation

var
  FSettings: TSettings = nil;

function Settings: TSettings;
begin
  if FSettings = nil then
    FSettings := TSettings.Create;

  Result := FSettings;
end;

function TSettings.Readbool(Key, Name: string; Default: Boolean): Boolean;
var
  Reg: TBDRegistry;
  Value: string;
begin
  Result := default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Value := AnsiLowerCase(Reg.ReadString(Name));
  if Value = 'true' then
    Result := True;
  if Value = 'false' then
    Result := False;
end;

function TSettings.ReadRealBool(Key, Name: string; Default : boolean): Boolean;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Result := Reg.ReadBool(Name);
end;

function TSettings.ReadboolW(Key, Name: string; Default : boolean): boolean;
var
  Reg : TBDRegistry;
  Value : string;
begin
  Result := Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Value := AnsiLowerCase(Reg.ReadString(Name));
  if Value = 'true' then
    Result := True;
  if Value = 'false' then
    Result := False;
end;

function TSettings.ReadInteger(Key, Name : string; Default : integer): integer;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Result := StrToIntDef(reg.ReadString(Name), Default);
end;

function TSettings.ReadDateTime(Key, Name : string; Default : TDateTime): TDateTime;
var
  Reg : TBDRegistry;
begin
  Result:=Default;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  if Reg.ValueExists(Name) then
    Result:=Reg.ReadDateTime(Name);
end;

function TSettings.ReadProperty(Key, Name: string): string;
var
  Reg : TBDRegistry;
begin
  Result := '';
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Result := Reg.ReadString(Name);
end;

function TSettings.ReadKeys(Key: string): TStrings;
var
  Reg : TBDRegistry;
begin
  Result:=TStringList.Create;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.GetKeyNames(Result);
end;

function TSettings.ReadValues(Key: string): TStrings;
var
  Reg : TBDRegistry;
begin
  Result := TStringList.Create;
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.GetValueNames(Result);
end;

procedure TSettings.DeleteValues(Key: string);
var
  Reg: TBDRegistry;
  I: Integer;
  Result: TStrings;
begin
  Reg := TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Result := TStringList.Create;
    Reg.OpenKey(GetRegRootKey + Key, True);
    Reg.GetValueNames(Result);
    for I := 0 to Result.Count - 1 do
      Reg.DeleteValue(Result[I]);
  finally
    F(Reg);
  end;
end;

constructor TSettings.Create;
begin
  FRegistryCache := TDBRegistryCache.Create;
end;

destructor TSettings.Destroy;
begin
  F(FRegistryCache);
  inherited;
end;

procedure TSettings.DeleteKey(Key: string);
var
  Reg : TBDRegistry;
begin
  Reg:=TBDRegistry.Create(REGISTRY_CURRENT_USER);
  try
    Reg.DeleteKey(GetRegRootKey+Key);
  finally;
    F(Reg);
  end;
end;

function TSettings.ReadString(Key, Name: string; Default: string = ''): string;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Result := Reg.ReadString(name);
  if Result = '' then
    Result := Default;
end;

function TSettings.ReadStringW(Key, Name: string; Default: string = ''): string;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Result := Reg.ReadString(Name);
  if Result = '' then
    Result := Default;
end;

procedure TSettings.WriteBool(Key, name: string; Value: Boolean);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  if Value then
    Reg.WriteString(name, 'True')
  else
    Reg.WriteString(name, 'False');
end;

procedure TSettings.WriteBoolW(Key, Name: string; Value: Boolean);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  if Value then
    Reg.WriteString(Name, 'True')
  else
    Reg.WriteString(Name, 'False');
end;

procedure TSettings.WriteInteger(Key, Name: string; Value: Integer);
var
  Reg: TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.WriteString(Name, IntToStr(Value));
end;

procedure TSettings.WriteProperty(Key, Name, Value: string);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Reg.WriteString(Name, Value);
end;

procedure TSettings.WriteString(Key, Name, Value: string);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.WriteString(Name, Value);
end;

procedure TSettings.WriteStringW(Key, Name, value: string);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot + Key);
  Reg.WriteString(Name, Value);
end;

procedure TSettings.WriteDateTime(Key, Name : String; Value: TDateTime);
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, GetRegRootKey + Key);
  Reg.WriteDateTime(Name, Value);
end;

function TSettings.GetDataBase: string;
var
  Reg : TBDRegistry;
begin
  Reg := FRegistryCache.GetSection(REGISTRY_CURRENT_USER, RegRoot);
  Result := Reg.ReadString('DBDefaultName');
end;

initialization

finalization

  F(FSettings);

end.