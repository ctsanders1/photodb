unit uAssociations;

interface

uses
  generics.Collections,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.SyncObjs,
  System.Win.Registry,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg,
  {$IFDEF PHOTODB}
  GraphicEx,
  GifImage,
  uRAWImage,
  uTiffImage,
  uAnimatedJPEG,
  uFreeImageImage,
  {$ENDIF}
  uMemory,
  uTranslate,
  uStringUtils;

{$IF DEFINED(UNINSTALL) OR DEFINED(INSTALL)}
const
  TTIFFImage = nil;
  TPSDGraphic = nil;
  TGIFImage = nil;
  TRAWImage = nil;
  TRLAGraphic = nil;
  TAutodeskGraphic = nil;
  TPPMGraphic = nil;
  TTargaGraphic = nil;
  TPCXGraphic = nil;
  TSGIGraphic = nil;
  TPCDGraphic = nil;
  TPSPGraphic = nil;
  TCUTGraphic = nil;
  TEPSGraphic = nil;
  TAnimatedJPEG = nil;
  TFreeImageImage = nil;
{$IFEND}

type
  TAssociation = class(TObject)

  end;

  TAssociationState = (
    TAS_NOT_INSTALLED, TAS_INSTALLED_OTHER, TAS_PHOTODB_HANDLER, TAS_PHOTODB_DEFAULT, TAS_UNINSTALL
  );

  TFileAssociation = class(TAssociation)
  private
    FDescription: string;
    function GetDescription: string;
  public
    Extension : string;
    ExeParams : string;
    Group: Integer;
    State: TAssociationState;
    GraphicClass: TGraphicClass;
    CanSave: Boolean;
    property Description: string read GetDescription write FDescription;
  end;

  TInstallAssociationCallBack = procedure(Current, Total: Integer; var Terminate: Boolean) of object;

  TFileAssociations = class(TObject)
  private
    FAssociations : TList;
    FFullFilter: string;
    FExtensionList: string;
    FChanged: Boolean;
    FSync: TCriticalSection;
    constructor Create;
    procedure AddFileExtension(Extension, Description: string; Group: Integer; GraphicClass: TGraphicClass; CanSave: Boolean = False); overload;
    procedure AddFileExtension(Extension, Description, ExeParams : string; Group: Integer; GraphicClass: TGraphicClass; CanSave: Boolean = False); overload;
    procedure FillList;
    function GetAssociations(Index: Integer): TFileAssociation;
    function GetCount: Integer;
    function GetAssociationByExt(Ext : string): TFileAssociation;
    function GetFullFilter: string;
    function GetExtensionList: string;
    procedure UpdateCache;
  public
    class function Instance: TFileAssociations;
    destructor Destroy; override;
    function GetCurrentAssociationState(Extension: string): TAssociationState;
    function GetFilter(ExtList: string; UseGroups: Boolean; ForOpening: Boolean; AdditionalExtInfo: TDictionary<string, string> = nil): string;
    function GetExtendedFullFilter(UseGroups: Boolean; ForOpening: Boolean; AdditionalExtInfo: TDictionary<string, string>): string;
    function GetGraphicClass(Ext: String): TGraphicClass;
    function IsConvertableExt(Ext: String): Boolean;
    function GetGraphicClassExt(GraphicClass: TGraphicClass): string;
    property Associations[Index: Integer]: TFileAssociation read GetAssociations; default;
    property Exts[Ext: string]: TFileAssociation read GetAssociationByExt;
    property Count: Integer read GetCount;
    property FullFilter: string read GetFullFilter;
    property ExtensionList: string read GetExtensionList;
  end;

const
  EXT_ASSOCIATION_PREFIX = 'PhotoDB';
  ASSOCIATION_PREVIOUS = 'PhotoDB_PreviousAssociation';
  ASSOCIATION_PHOTODB_FILE_EXT = 'PhotoDB_Owner';
  ASSOCIATION_ADD_HANDLER_COMMAND = 'PhotoDBView';
  ASSOCIATION_PATH = '\Software\Classes\';

function InstallGraphicFileAssociations(FileName: string; CallBack: TInstallAssociationCallBack): Boolean;
function InstallGraphicFileAssociationsFromParamStr(FileName, Parameters: string): Boolean;
function AssociationStateToCheckboxState(AssociationState: TAssociationState; Update: Boolean): TCheckBoxState;
function CheckboxStateToAssociationState(CheckBoxState: TCheckBoxState): TAssociationState;
function CheckboxStateToString(CheckBoxState: TCheckBoxState): string;
function IsGraphicFile(FileName: string): Boolean;
function IsRAWImageFile(FileName: String): Boolean;
function CanShareVideo(FileName: string): Boolean;

implementation

var
  FInstance: TFileAssociations = nil;
  FGlobalSync: TCriticalSection = nil;

function AssociationStateToCheckboxState(AssociationState : TAssociationState; Update: Boolean) : TCheckBoxState;
begin
  if not Update then
  begin
    case AssociationState of
      TAS_INSTALLED_OTHER,
      TAS_PHOTODB_HANDLER:
        Result := cbGrayed;
      TAS_NOT_INSTALLED,
      TAS_PHOTODB_DEFAULT:
        Result := cbChecked;
      else
        raise Exception.Create('Invalid AssociationState');
    end;
  end else
  begin
    case AssociationState of
      TAS_INSTALLED_OTHER:
        Result := cbUnchecked;
      TAS_PHOTODB_HANDLER:
        Result := cbGrayed;
      TAS_NOT_INSTALLED,
      TAS_PHOTODB_DEFAULT:
        Result := cbChecked;
      else
        raise Exception.Create('Invalid AssociationState');
    end;
  end;
end;

function CheckboxStateToAssociationState(CheckBoxState: TCheckBoxState): TAssociationState;
begin
  case CheckBoxState of
    cbUnchecked:
      Result := TAS_INSTALLED_OTHER;
    cbGrayed:
      Result := TAS_PHOTODB_HANDLER;
    cbChecked:
      Result := TAS_PHOTODB_DEFAULT;
    else
      raise Exception.Create('Invalid CheckBoxState');
  end;
end;

function StringToAssociationState(State: string): TAssociationState;
begin
  if State = 'o' then
    Result := TAS_INSTALLED_OTHER
  else if State = 'h' then
    Result := TAS_PHOTODB_HANDLER
  else if State = 'c' then
    Result := TAS_PHOTODB_DEFAULT
  else
    raise Exception.Create('Invalid State');
end;

function CheckboxStateToString(CheckBoxState: TCheckBoxState): string;
begin
  case CheckBoxState of
    cbUnchecked:
      Result := 'o';
    cbGrayed:
      Result := 'h';
    cbChecked:
      Result := 'c';
    else
      raise Exception.Create('Invalid CheckBoxState');
  end;
end;

procedure UnregisterPhotoDBAssociation(Ext: string; Full: Boolean);
var
  Reg: TRegistry;
  ShellPath, ExtensionHandler, PreviousHandler : string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.OpenKey(ASSOCIATION_PATH + Ext, True);
    ExtensionHandler := Reg.ReadString('');
    PreviousHandler := Reg.ReadString(ASSOCIATION_PREVIOUS);
    Reg.CloseKey;

    if ExtensionHandler <> '' then
    begin
      ShellPath := ASSOCIATION_PATH + ExtensionHandler + '\Shell\';
      //unregister view menu item
      if Reg.KeyExists(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND + '\Command') then
        Reg.DeleteKey(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND + '\Command');
      if Reg.KeyExists(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND) then
        Reg.DeleteKey(ShellPath + ASSOCIATION_ADD_HANDLER_COMMAND);

      if StartsText(AnsiLowerCase(EXT_ASSOCIATION_PREFIX) + '.', AnsiLowerCase(ExtensionHandler)) then
      begin
        //if open with photodb then delete default association
        if Reg.KeyExists(ShellPath + 'Open\Command') then
          Reg.DeleteKey(ShellPath + 'Open\Command');
        if Reg.KeyExists(ShellPath + 'Open') then
          Reg.DeleteKey(ShellPath + 'Open');
      end;
    end;

    Reg.OpenKey(ASSOCIATION_PATH + Ext, True);
    if PreviousHandler <> '' then
    begin
      if not StartsText(AnsiLowerCase(EXT_ASSOCIATION_PREFIX) + '.', AnsiLowerCase(PreviousHandler)) then
        Reg.WriteString('', PreviousHandler)
      else
        Reg.WriteString('', '');
    end;

    ExtensionHandler := Reg.ReadString('');
    if StartsText(AnsiLowerCase(EXT_ASSOCIATION_PREFIX) + '.', AnsiLowerCase(ExtensionHandler)) then
      Reg.DeleteValue('');

    Reg.DeleteValue(ASSOCIATION_PREVIOUS);

    if Reg.ValueExists(ASSOCIATION_PHOTODB_FILE_EXT) then
    begin       
      Reg.CloseKey;
      Reg.DeleteKey(ASSOCIATION_PATH + Ext);
    end else
      Reg.CloseKey;
  finally
    F(Reg);
  end;

  if Full then
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + Ext);
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + Ext);
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.DeleteKey(ASSOCIATION_PATH + EXT_ASSOCIATION_PREFIX + Ext);
    finally
      F(Reg);
    end;
  end;
end;

function InstallGraphicFileAssociationsFromParamStr(FileName, Parameters: string): Boolean;
var
  I: Integer;
  P: Integer;
  SL: TStringList;
  S, Ext, State: string;
  Association: TFileAssociation;
begin
  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.StrictDelimiter := True;
    SL.DelimitedText := Parameters;

    for I := 0 to SL.Count - 1 do
    begin
      S := SL[I];
      P := Pos(':', S);
      if P > 0 then
      begin
        Ext := Copy(S, 1, P - 1);
        Delete(S, 1, P);
        State := S;

        Association := TFileAssociations.Instance.Exts[Ext];
        if Association = nil then
          Continue;

        Association.State := StringToAssociationState(State);
      end;
    end;
  finally
    F(SL);
  end;
  Result := InstallGraphicFileAssociations(FileName, nil);
end;

function InstallGraphicFileAssociations(FileName: string; CallBack: TInstallAssociationCallBack): Boolean;
var
  Reg: TRegistry;
  I: Integer;
  S, Ext: string;
  B, C: Boolean;
  Terminate, KeyAlreadyExists: Boolean;
  CurrectAssociation: TAssociationState;
begin
  Terminate := False;

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    //The HKEY_CLASSES_ROOT subtree is a view formed by merging:
    // HKEY_CURRENT_USER\Software\Classes
    // and HKEY_LOCAL_MACHINE\Software\Classes
    for I := 0 to TFileAssociations.Instance.Count - 1 do
    begin
      if Assigned(CallBack) then
        CallBack(I, TFileAssociations.Instance.Count, Terminate);

      if Terminate then
        Break;
      Ext := TFileAssociations.Instance[I].Extension;

      CurrectAssociation := TFileAssociations.Instance.GetCurrentAssociationState(Ext);

      case TFileAssociations.Instance[I].State of
        TAS_UNINSTALL:
          UnregisterPhotoDBAssociation(Ext, True);
        TAS_NOT_INSTALLED,
        TAS_INSTALLED_OTHER:
          case CurrectAssociation of
            TAS_PHOTODB_HANDLER:
              UnregisterPhotoDBAssociation(Ext, False);
            TAS_PHOTODB_DEFAULT:
              UnregisterPhotoDBAssociation(Ext, True);
          end;
        TAS_PHOTODB_DEFAULT:
          begin
            KeyAlreadyExists := Reg.KeyExists(ASSOCIATION_PATH + Ext);
            if Reg.OpenKey(ASSOCIATION_PATH + Ext, True) then
            begin
              if not KeyAlreadyExists then
                Reg.WriteBool(ASSOCIATION_PHOTODB_FILE_EXT, True);
              S := Reg.ReadString('');
              Reg.CloseKey;
              B := False;
              if S = '' then
                B := True;
              if not B then
              begin
                Reg.OpenKey(ASSOCIATION_PATH + S + '\Shell\Open\Command', False);
                B := Reg.ReadString('') = '';
                Reg.CloseKey;
              end;
              if B then
              begin
                Reg.OpenKey(ASSOCIATION_PATH + Ext, True);
                Reg.WriteString('', 'PhotoDB' + Ext);
                Reg.CloseKey;
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext, True);
                Reg.WriteString('', TFileAssociations.Instance[I].Description);
                Reg.CloseKey;
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\Shell\Open\Command', True);
                Reg.WriteString('', Format('"%s" "%%1"', [FileName]));
                Reg.CloseKey;
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\DefaultIcon', True);
                Reg.WriteString('', Filename + ',0');
                Reg.CloseKey;
              end else
              begin
                Reg.OpenKey(ASSOCIATION_PATH + Ext, True);
                S := Reg.ReadString('');
                if not StartsText('PhotoDB', S) then
                  Reg.WriteString('PhotoDB_PreviousAssociation', S);
                Reg.WriteString('', 'PhotoDB' + Ext);
                Reg.CloseKey;
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext, True);
                Reg.WriteString('', TFileAssociations.Instance[I].Description);
                Reg.CloseKey;
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\Shell\Open\Command', True);
                Reg.WriteString('', Format('"%s" "%%1"', [Filename]));
                Reg.CloseKey;
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\DefaultIcon', True);
                Reg.WriteString('', Filename + ',0');
                Reg.CloseKey;
              end;
            end;
          end;
        TAS_PHOTODB_HANDLER:
          begin
            KeyAlreadyExists := Reg.KeyExists(ASSOCIATION_PATH + Ext);
            if Reg.OpenKey(ASSOCIATION_PATH + Ext, True) then
            begin
              if not KeyAlreadyExists then
                Reg.WriteBool(ASSOCIATION_PHOTODB_FILE_EXT, True);
              S := Reg.ReadString('');
              Reg.CloseKey;
              C := False;
              B := True;
              if S = '' then
                C := True;
              if not C then
              begin
                Reg.OpenKey(ASSOCIATION_PATH + S + '\Shell\Open\Command', False);
                B :=  Reg.ReadString('') = '';
                Reg.CloseKey;
              end;
              if B then
              begin
                Reg.OpenKey(ASSOCIATION_PATH + Ext, True);
                Reg.WriteString('', 'PhotoDB' + Ext);
                Reg.CloseKey;
              end;
              if B then
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\Shell\' + ASSOCIATION_ADD_HANDLER_COMMAND, True)
              else
                Reg.OpenKey(ASSOCIATION_PATH + S + '\Shell\' + ASSOCIATION_ADD_HANDLER_COMMAND, True);
              Reg.WriteString('', TA('View with PhotoDB', 'System'));
              Reg.CloseKey;
              if B then
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\Shell\' + ASSOCIATION_ADD_HANDLER_COMMAND + '\Command', True)
              else
                Reg.OpenKey(ASSOCIATION_PATH + S + '\Shell\' + ASSOCIATION_ADD_HANDLER_COMMAND + '\Command', True);
              Reg.WriteString('', Format('"%s" "%%1"', [Filename]));
              if B then
              begin
                Reg.OpenKey(ASSOCIATION_PATH + 'PhotoDB' + Ext + '\DefaultIcon', True);
                Reg.WriteString('', Filename + ',0');
              end;
              Reg.CloseKey;
          end;
        end;
      end;
    end;
  finally
    F(Reg);
  end;
  Result := True;
end;

function IsGraphicFile(FileName: string): Boolean;
begin
  Result := Pos('|' + AnsiLowerCase(ExtractFileExt(FileName)) + '|', TFileAssociations.Instance.ExtensionList) > 0;
end;

{ TFileAssociation }

function TFileAssociation.GetDescription: string;
begin
  Result := TA(FDescription, 'Associations');
end;

{ TFileAssociations }

class function TFileAssociations.Instance: TFileAssociations;
begin
  FGlobalSync.Enter;
  try
    if FInstance = nil then
      FInstance := TFileAssociations.Create;

    Result := FInstance;
  finally
    FGlobalSync.Leave;
  end;
end;

function TFileAssociations.IsConvertableExt(Ext: String): Boolean;
var
  I: Integer;
  Association: TFileAssociation;
begin
  FSync.Enter;
  try
    Result := False;
    Ext := AnsiLowerCase(Ext);
    for I := 0 to Count - 1 do
    begin
      Association := Self[I];
      if Association.Extension = Ext then
      begin
        Result := Association.CanSave;
        Exit;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TFileAssociations.AddFileExtension(Extension, Description, ExeParams: string; Group: Integer; GraphicClass: TGraphicClass; CanSave: Boolean = False);
var
  Ext : TFileAssociation;
begin
  FChanged := True;
  Ext := TFileAssociation.Create;
  Ext.Extension := Extension;
  Ext.ExeParams := ExeParams;
  Ext.Description := Description;
  Ext.Group := Group;
  Ext.GraphicClass := GraphicClass;
  Ext.CanSave := CanSave;
  FAssociations.Add(Ext);
end;

procedure TFileAssociations.AddFileExtension(Extension, Description: string; Group: Integer; GraphicClass: TGraphicClass; CanSave: Boolean = False);
begin
  AddFileExtension(Extension, Description, '', Group, GraphicClass, CanSave);
end;

constructor TFileAssociations.Create;
begin
  FSync := TCriticalSection.Create;
  FAssociations := TList.Create;
  FillList;
end;

destructor TFileAssociations.Destroy;
begin
  FreeList(FAssociations);
  F(FSync);
  inherited;
end;

procedure TFileAssociations.FillList;
begin
  FSync.Enter;
  try

    AddFileExtension('.jfif', 'JPEG Images', 0, TJpegImage);
    AddFileExtension('.jpg', 'JPEG Images', 0, TJpegImage, True);
    AddFileExtension('.jpe', 'JPEG Images', 0, TJpegImage);
    AddFileExtension('.jpeg', 'JPEG Images', 0, TJpegImage);
    AddFileExtension('.thm', 'JPEG Images', 0, TJpegImage);

    AddFileExtension('.tiff', 'TIFF images', 1, TTiffImage, True);
    AddFileExtension('.tif', 'TIFF images', 1, TTiffImage);

    AddFileExtension('.psd', 'Photoshop Images', 2, TPSDGraphic);
    AddFileExtension('.pdd', 'Photoshop Images', 2, TPSDGraphic);

    AddFileExtension('.gif', 'Animated images', 3, TGIFImage, True);

    AddFileExtension('.png', 'Portable network graphic images', 4, TPngImage, True);

    AddFileExtension('.bmp', 'Standard Windows bitmap images', 5, TBitmap, True);
    AddFileExtension('.rle', 'Standard Windows bitmap images', 5, TBitmap);
    AddFileExtension('.dib', 'Standard Windows bitmap images', 5, TBitmap);

    AddFileExtension('.3fr', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.arw', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.bay', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.cap', 'Camera RAW Images', 6, TRAWImage);

    AddFileExtension('.cine', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.cr2', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.crw', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.cs1', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.dc2', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.dcr', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.drf', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.dsc', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.dng', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.erf', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.fff', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.ia', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.iiq', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.k25', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.kc2', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.kdc', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.mdc', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.mef', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.mos', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.mrw', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.nef', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.nrw', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.orf', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.pef', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.xxx', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.ptx', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.pxn', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.qtk', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.raf', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.raw', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.rdc', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.rw2', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.rwl', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.rwz', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.sr2', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.srf', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.srw', 'Camera RAW Images', 6, TRAWImage);
    AddFileExtension('.sti', 'Camera RAW Images', 6, TRAWImage);

    AddFileExtension('.rla', 'SGI Wavefront images', 7, TRLAGraphic);
    AddFileExtension('.rpf', 'SGI Wavefront images', 7, TRLAGraphic);

    AddFileExtension('.pic', 'Autodesk images files', 8, TAutodeskGraphic);
    AddFileExtension('.cel', 'Autodesk images files', 8, TAutodeskGraphic);

    AddFileExtension('.ppm', 'Portable pixel/gray map images', 9, TPPMGraphic);
    AddFileExtension('.pgm', 'Portable pixel/gray map images', 9, TPPMGraphic);
    AddFileExtension('.pbm', 'Portable pixel/gray map images', 9, TPPMGraphic);

    AddFileExtension('.fax', 'GFI fax images', 10, TTiffImage);

    AddFileExtension('.tga', 'Truevision images', 11, TTargaGraphic, True);
    AddFileExtension('.vst', 'Truevision images', 11, TTargaGraphic);
    AddFileExtension('.icb', 'Truevision images', 11, TTargaGraphic);
    AddFileExtension('.vda', 'Truevision images', 11, TTargaGraphic);
    AddFileExtension('.win', 'Truevision images', 11, TTargaGraphic);

    AddFileExtension('.pcc', 'ZSoft Paintbrush images', 12, TPCXGraphic);
    AddFileExtension('.pcx', 'ZSoft Paintbrush images', 12, TPCXGraphic);

    AddFileExtension('.sgi', 'SGI images', 13, TSGIGraphic);
    AddFileExtension('.rgba', 'SGI images', 13, TSGIGraphic);
    AddFileExtension('.rgb', 'SGI images', 13, TSGIGraphic);
    AddFileExtension('.bw', 'SGI images', 13, TSGIGraphic);

    AddFileExtension('.pcd', 'Kodak Photo-CD images', 14, TPCDGraphic);

    AddFileExtension('.psp', 'Paintshop Pro images', 15, TPSPGraphic);

    AddFileExtension('.cut', 'Dr. Halo images', 16, TCUTGraphic);
    AddFileExtension('.pal', 'Dr. Halo images', 16, TCUTGraphic);

    AddFileExtension('.jps', 'JPEG 3D Images', 17, TAnimatedJPEG);
    AddFileExtension('.mpo', 'JPEG 3D Images', 17, TAnimatedJPEG);

    AddFileExtension('.jp2', 'JPEG 2000 Images', 18, TFreeImageImage);
    AddFileExtension('.j2k', 'JPEG 2000 Images', 18, TFreeImageImage);
    AddFileExtension('.jpf', 'JPEG 2000 Images', 18, TFreeImageImage);
    AddFileExtension('.jpx', 'JPEG 2000 Images', 18, TFreeImageImage);
    AddFileExtension('.jpm', 'JPEG 2000 Images', 18, TFreeImageImage);
    AddFileExtension('.mj2', 'JPEG 2000 Images', 18, TFreeImageImage);

    AddFileExtension('.dds', 'DirectDraw Surface graphics', 19, TFreeImageImage);

    AddFileExtension('.exr', 'HDR Images', 20, TFreeImageImage);
    AddFileExtension('.hdr', 'HDR Images', 20, TFreeImageImage);

    AddFileExtension('.iff', 'Amiga IFF Graphic', 20, TFreeImageImage);

    AddFileExtension('.jng', 'JPEG Network Graphic', 21, TFreeImageImage);

   // AddFileExtension('.xbm', 'X11 Bitmap Graphic', 22, TFreeImageImage);
    //AddFileExtension('.xpm', 'X11 Bitmap Graphic', 22, TFreeImageImage);

    //AddFileExtension('.mng', 'Multiple Network Graphic', 21, TFreeImageImage);
    //AddFileExtension('.eps', 'Encapsulated Postscript images', 18, TEPSGraphic);
  finally
    FSync.Leave;
  end;
end;

function TFileAssociations.GetAssociationByExt(
  Ext: string): TFileAssociation;
var
  I : Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Self[I].Extension = Ext then
    begin
      Result := Self[I];
      Exit;
    end;
  end;
end;

function TFileAssociations.GetAssociations(Index: Integer): TFileAssociation;
begin
  Result := FAssociations[Index];
end;

function TFileAssociations.GetCount: Integer;
begin
  Result := FAssociations.Count;
end;

function TFileAssociations.GetCurrentAssociationState(
  Extension: string): TAssociationState;
var
  Reg: TRegistry;
  AssociationHandler, AssociationCommand : string;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;

    Reg.OpenKey(Extension, False);
    AssociationHandler := Reg.ReadString('');
    Reg.CloseKey;

    Reg.OpenKey(AssociationHandler + '\shell\open\command', False);
    AssociationCommand := Reg.ReadString('');
    Reg.CloseKey;

    if AssociationCommand = '' then
    begin
      Reg.CloseKey;
      Reg.OpenKey(AssociationHandler + '\shell\' + ASSOCIATION_ADD_HANDLER_COMMAND + '\command', False);
      AssociationCommand := Reg.ReadString('');
      if Pos('photodb.exe', AnsiLowerCase(AssociationCommand)) > 0 then
        Result := TAS_PHOTODB_HANDLER
      else
        Result := TAS_NOT_INSTALLED;
    end else
    begin
      if Pos('photodb.exe', AnsiLowerCase(AssociationCommand)) > 0 then
        Result := TAS_PHOTODB_DEFAULT
      else begin
        Reg.CloseKey;
        Reg.OpenKey(AssociationHandler + '\shell\' + ASSOCIATION_ADD_HANDLER_COMMAND + '\command', False);
        AssociationCommand := Reg.ReadString('');
        if Pos('photodb.exe', AnsiLowerCase(AssociationCommand)) > 0 then
          Result := TAS_PHOTODB_HANDLER
        else
          Result := TAS_INSTALLED_OTHER;
      end;
    end;

  finally
    F(Reg);
  end;
end;

function TFileAssociations.GetExtensionList: string;
begin
  FSync.Enter;
  try
    if FChanged then
    begin
      UpdateCache;
      FChanged := False;
    end;
    Result := FExtensionList;
  finally
    FSync.Leave;
  end;
end;

function TFileAssociations.GetExtendedFullFilter(UseGroups, ForOpening: Boolean; AdditionalExtInfo: TDictionary<string, string>): string;
var
  Association: TFileAssociation;
  AllExtensions: TStrings;
  I: Integer;
  OldGroup: Integer;
begin
  AllExtensions := TStringList.Create;
  try
    OldGroup := -1;
    for I := 0 to Self.Count - 1 do
    begin
      Association := Self[I];
      if OldGroup <> Association.Group then
        AllExtensions.Add(Association.Extension);

      OldGroup := Association.Group;
    end;

    Result := GetFilter(JoinList(AllExtensions, '|'), True, True, AdditionalExtInfo) + '|';
  finally
    F(AllExtensions);
  end;
end;

function TFileAssociations.GetFilter(ExtList: string; UseGroups,
  ForOpening: Boolean; AdditionalExtInfo: TDictionary<string, string> = nil): string;
var
  I, J: Integer;
  ResultList,
  EList,
  AllExtList,
  RequestExts, AdditionalExts: TStrings;
  Association: TFileAssociation;
  AGroup: Integer;
  AExt, ADesc: string;
  Pair: TPair<string, string>;
begin
  FSync.Enter;
  try
    ResultList := TStringList.Create;
    try

      EList := TStringList.Create;
      RequestExts := TStringList.Create;
      AllExtList := TStringList.Create;
      try
        SplitString(ExtList, '|', RequestExts);

        if AdditionalExtInfo <> nil then
          for Pair in AdditionalExtInfo do
            RequestExts.Add(Pair.Key);

        for I := 0 to RequestExts.Count - 1 do
        begin
          AGroup := -1;
          EList.Clear;
          Association := Self.Exts[RequestExts[I]];
          if Association = nil then
          begin
            if AdditionalExtInfo = nil then
              Continue;

            AExt := RequestExts[I];
            ADesc := AdditionalExtInfo[AExt];
          end else
          begin
            AGroup := Association.Group;
            AExt := Association.Extension;
            ADesc := Association.Description;
          end;

          if UseGroups then
          begin
            if Association <> nil then
              for J := 0 to Self.Count - 1 do
                if Self[J].Group = AGroup then
                  EList.Add('*' + Self[J].Extension);

            if Association = nil then
            begin
              AdditionalExts := TStringList.Create;
              try
                SplitString(AExt, ',', AdditionalExts);
                for J := 0 to AdditionalExts.Count - 1 do
                  EList.Add('*' + AdditionalExts[J])
              finally
                F(AdditionalExts);
              end;
            end;

          end else
          begin
            if Association <> nil then
              EList.Add('*' + AExt);
          end;

          ResultList.Add(Format('%s (%s)|%s',
                    [TA(ADesc, 'Associations'),
                    JoinList(EList, ','),
                    JoinList(EList, ';')]));

          if ForOpening then
            AllExtList.AddStrings(EList);
        end;

        if ForOpening and (RequestExts.Count > 1) then
        begin
          ResultList.Insert(0, Format('%s (%s)|%s',
                    [TA('All supported formats', 'Associations'),
                    JoinList(AllExtList, ','),
                    JoinList(AllExtList, ';')]));
        end;

      finally
        F(RequestExts);
        F(EList);
        F(AllExtList);
      end;

      Result := JoinList(ResultList, '|');
    finally
      F(ResultList);
    end;
  finally
    FSync.Leave;
  end;
end;

procedure TFileAssociations.UpdateCache;
var
  Association: TFileAssociation;
  AllExtensions: TStrings;
  I: Integer;
  OldGroup: Integer;
begin
  AllExtensions := TStringList.Create;
  FExtensionList := '';
  try
    OldGroup := -1;
    for I := 0 to Self.Count - 1 do
    begin
      Association := Self[I];
      if I <> 0 then
        FExtensionList := FExtensionList + '|';

      FExtensionList := FExtensionList + Association.Extension;

      if OldGroup <> Association.Group then
        AllExtensions.Add(Association.Extension);

      OldGroup := Association.Group;
    end;

    FExtensionList := '|' + FExtensionList + '|';
    FFullFilter := GetFilter(JoinList(AllExtensions, '|'), True, True) + '|';
  finally
    F(AllExtensions);
  end;
end;

function TFileAssociations.GetFullFilter: string;
begin
  FSync.Enter;
  try
    if FChanged then
    begin
      UpdateCache;
      FChanged := False;
    end;
    Result := FFullFilter;
  finally
    FSync.Leave;
  end;
end;

function TFileAssociations.GetGraphicClass(Ext: String): TGraphicClass;
var
  I: Integer;
  Association: TFileAssociation;
begin
  FSync.Enter;
  try
    Result := nil;
    Ext := AnsiLowerCase(Ext);
    for I := 0 to Count - 1 do
    begin
      Association := Self[I];
      if Association.Extension = Ext then
      begin
        Result := Association.GraphicClass;
        Exit;
      end;
    end;
  finally
    FSync.Leave;
  end;
end;

function TFileAssociations.GetGraphicClassExt(
  GraphicClass: TGraphicClass): string;
var
  I: Integer;
  Association: TFileAssociation;
begin
  FSync.Enter;
  try
    Result := '';
    for I := 0 to Count - 1 do
    begin
      Association := Self[I];
      if (Association.GraphicClass = GraphicClass) and Association.CanSave then
      begin
        Result := Association.Extension;
        Exit;
      end;
    end;

    if Result = '' then
      for I := 0 to Count - 1 do
      begin
        Association := Self[I];
        if (Association.GraphicClass = GraphicClass) then
        begin
          Result := Association.Extension;
          Exit;
        end;
      end;

    if Result = '' then
      Result := '.' + GraphicExtension(GraphicClass);
  finally
    FSync.Leave;
  end;
end;

function IsRAWImageFile(FileName: string): Boolean;
begin
  Result := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(FileName)) = TRAWImage;
end;

function CanShareVideo(FileName: string): Boolean;
var
  Ext: string;
begin
  Ext := AnsiLowerCase(ExtractFileExt(FileName));
  Result := False;
  Result := Result or (Ext = '.3gp2');
  Result := Result or (Ext = '.3gpp');
  Result := Result or (Ext = '.3gp');
  Result := Result or (Ext = '.3g2');
  Result := Result or (Ext = '.avi');
  Result := Result or (Ext = '.mov');
  Result := Result or (Ext = '.mp4');
  Result := Result or (Ext = '.mpeg');
  Result := Result or (Ext = '.mpeg4');
  Result := Result or (Ext = '.asf');
  Result := Result or (Ext = '.wmv');
end;

initialization
  FGlobalSync := TCriticalSection.Create;

finalization
  F(FInstance);
  F(FGlobalSync);

end.
