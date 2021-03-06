unit uFormInterfaces;

interface

uses
  Generics.Collections,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.ExtCtrls,
  Vcl.Imaging.Jpeg,
  Data.DB,

  UnitDBDeclare,

  Dmitry.Controls.WebLink,
  Dmitry.PathProviders,

  uMemory,
  uDBForm,
  uRuntime,
  uDBEntities;

type
  IFormInterface = interface
    ['{24769E47-FE80-4FF7-81CC-F8E6C8AA77EC}']
    procedure Show;
    procedure Restore;
  end;

  IImageSource = interface(IInterface)
    ['{382D130E-5746-4A6D-9C15-B2EEEF089F44}']
    function GetImage(FileName: string; Bitmap: TBitmap; var Width: Integer; var Height: Integer): Boolean;
  end;

  IViewerForm = interface(IFormInterface)
    ['{951665C9-EDA5-44BD-B833-B5543B58DF04}']
    function ShowImage(Sender: TObject; FileName: string): Boolean;
    function ShowImages(Sender: TObject; Info: TMediaItemCollection): Boolean;
    function ShowImageInDirectory(FileName: string; ShowPrivate: Boolean): Boolean;
    function ShowImageInDirectoryEx(FileName: string): Boolean;
    function NextImage: Boolean;
    function PreviousImage: Boolean;
    function Pause: Boolean;
    function TogglePause: Boolean;
    function CloseActiveView: Boolean;

    function CurrentFullImage: TBitmap;
    procedure DrawTo(Canvas: TCanvas; X, Y: Integer);
    function ShowPopup(X, Y: Integer): Boolean;

    function GetImagesCount: Integer;
    function GetIsFullScreenNow: Boolean;
    function GetIsSlideShowNow: Boolean;
    function GetImageIndex: Integer;
    procedure SetImageIndex(Value: Integer);
    function GetImageByIndex(Index: Integer): TMediaItem;
    procedure UpdateImageInfo(Info: TMediaItem);

    property ImagesCount: Integer read GetImagesCount;
    property ImageIndex: Integer read GetImageIndex write SetImageIndex;
    property IsFullScreenNow: Boolean read GetIsFullScreenNow;
    property IsSlideShowNow: Boolean read GetIsSlideShowNow;
    property Images[Index: Integer]: TMediaItem read GetImageByIndex;
  end;

  IImageEditor = interface(IFormInterface)
    ['{0C5858BC-AF84-4941-AE8A-B0DF594DA7BF}']
    function EditFile(Image: string; BitmapOut: TBitmap): Boolean;
    function EditImage(Image: TBitmap): Boolean;
    procedure Close;
  end;

  IAboutForm = interface(IFormInterface)
    ['{319D1068-3734-4229-9264-8922123F31C0}']
    procedure Execute;
  end;

  IActivationForm = interface(IFormInterface)
    ['{B2742B2F-4210-4A48-B45E-54AEAD63062F}']
    procedure Execute;
  end;

  IOptionsForm = interface(IFormInterface)
    ['{5B8A57BA-3FCB-489C-A849-753BDA0D1356}']
  end;

  IRequestPasswordForm = interface(IFormInterface)
    ['{7710EB12-321A-44B1-B72A-FD238C450ACD}']
    function ForImage(FileName: string): string;
    function ForImageEx(FileName: string; out AskAgain: Boolean): string;
    function ForBlob(DF: TField; FileName: string): string;
    function ForSteganoraphyFile(FileName: string; CRC: Cardinal) : string;
    function ForManyFiles(FileList: TStrings; CRC: Cardinal; var Skip: Boolean): string;
  end;

  IBatchProcessingForm = interface(IFormInterface)
    ['{DEF35564-F0E4-46DD-A323-8FC6ABF19E3D}']
    procedure ExportImages(Owner: TDBForm; List: TMediaItemCollection);
    procedure ResizeImages(Owner: TDBForm; List: TMediaItemCollection);
    procedure ConvertImages(Owner: TDBForm; List: TMediaItemCollection);
    procedure RotateImages(Owner: TDBForm; List: TMediaItemCollection; DefaultRotate: Integer; StartImmediately: Boolean);
  end;

  IJpegOptionsForm = interface(IFormInterface)
    ['{C1F4BB58-77A8-4AF0-A9FD-196470D5AD7D}']
    procedure Execute(Section: string = '');
  end;

  ISelectSourceForm = interface(IFormInterface)
    ['{1945B6CD-8BA1-4D0B-B4CE-F57291FA5419}']
    procedure Execute;
  end;

  IImportForm = interface(IFormInterface)
    ['{64D665EF-5407-410D-8B4B-E18CE9F35FC3}']
    procedure FromDevice(DeviceName: string);
    procedure FromDrive(DriveLetter: Char);
    procedure FromFolder(Folder: string);
  end;

  IStringPromtForm = interface(IFormInterface)
    ['{190CD270-05BA-45D6-9013-079177BCC2D3}']
    function Query(Caption, Text: String; var UserString: string): Boolean;
  end;

  IEncryptForm = interface(IFormInterface)
    ['{FB0EA46F-E184-4E16-9F8A-0B4300ED1CFD}']
    function QueryPasswordForFile(FileName: string): TEncryptImageOptions;
    procedure Encrypt(Owner: TDBForm; Text: string; Info: TMediaItemCollection);
    procedure Decrypt(Owner: TDBForm; Info: TMediaItemCollection);
  end;

  ISteganographyForm = interface(IFormInterface)
    ['{617ABA0A-1313-4319-9F20-7C75737D49FE}']
    procedure HideData(InitialFileName: string);
    procedure ExtractData(InitialFileName: string);
  end;

  IShareForm = interface(IFormInterface)
    ['{2DF99576-6806-4735-90C9-434F2248B1A9}']
    procedure Execute(Owner: TDBForm; Info: TMediaItemCollection);
  end;

  IShareLinkForm = interface(IFormInterface)
    ['{25917009-223C-4012-8443-79E14C52C290}']
    procedure Execute(Owner: TDBForm; Info: TMediaItemCollection);
  end;

  IGroupCreateForm = interface(IFormInterface)
    ['{9F17471D-49EC-42B4-95B4-D09526D4B0AE}']
    procedure CreateGroup;
    procedure CreateFixedGroup(GroupName, GroupCode: string);
    procedure CreateGroupByCodeAndImage(GroupCode: string; Image: TJpegImage; out Created: Boolean; out GroupName: string);
  end;

  IGroupInfoForm = interface(IFormInterface)
    ['{F590F498-C6BB-4FB1-8571-5B9D21A63A6B}']
    procedure Execute(AOwner: TForm; Group: TGroup; CloseOwner: Boolean); overload;
    procedure Execute(AOwner: TForm; Group: string; CloseOwner: Boolean); overload;
  end;

  IGroupsSelectForm = interface(IFormInterface)
    ['{541139AB-E20A-41AA-A15A-A063A65C1328}']
    procedure Execute(var Groups: TGroups; var KeyWords: string; CanNew: Boolean = True); overload;
    procedure Execute(var Groups: string; var KeyWords: string; CanNew: Boolean = True); overload;
  end;

  ICollectionAddItemForm = interface(IFormInterface)
    ['{29D8DB10-F2B2-4E1C-ABDA-BCAF9CAC5FDC}']
    procedure Execute(Info: TMediaItem);
  end;

  ICDExportForm = interface(IFormInterface)
    ['{72359017-3ABA-4C8F-ACB0-FB2D37798CB4}']
    procedure Execute;
  end;

  ICDMapperForm = interface(IFormInterface)
    ['{B45F759D-40DD-4BA5-BA24-950389A5CB3A}']
    procedure Execute;
  end;

  ISelectLocationForm = interface(IFormInterface)
    ['{B3298299-4966-42ED-93F4-98C5790D1675}']
    function Execute(Title, StartPath: string; out PathItem: TPathItem; AllowVirtualItems: Boolean): Boolean;
  end;

  IBackgroundTaskStatusForm = interface(IFormInterface)
    ['{22AFC874-9408-45C1-9F83-04F490B928F1}']
    function ShowModal: Integer;
    procedure SetProgress(Max, Position: Int64);
    procedure SetText(Text: string);
    procedure CloseForm;
  end;

  IFormSelectDuplicateDirectories = interface(IFormInterface)
    ['{80EA9FEA-2958-4CB4-84C9-7D729C054618}']
    function Execute(DirectoriesInfo: TList<string>): string;
  end;

  TListElementType = (leWebLink, leInfoLabel);
  TListElements = TDictionary<TListElementType, TControl>;

  ILinkItemSelectForm = interface;

  TProcessActionLinkProcedure = reference to procedure(Action: string; WebLink: TWebLink);
  TAddActionProcedure = reference to procedure(Actions: array of string; ProcessActionLink: TProcessActionLinkProcedure);

  IFormLinkItemEditorData = interface
    procedure ApplyChanges;
    function GetEditorData: TDataObject;
    function GetEditorPanel: TPanel;
    function GetTopPanel: TPanel;
    property EditorData: TDataObject read GetEditorData;
    property EditorPanel: TPanel read GetEditorPanel;
    property TopPanel: TPanel read GetTopPanel;
  end;

  ILinkEditor = interface
    procedure SetForm(Form: IFormLinkItemEditorData);
    procedure CreateNewItem(Sender: ILinkItemSelectForm; var Data: TDataObject; Verb: string; Elements: TListElements);
    procedure CreateEditorForItem(Sender: ILinkItemSelectForm; Data: TDataObject; EditorData: IFormLinkItemEditorData);
    procedure UpdateItemFromEditor(Sender: ILinkItemSelectForm; Data: TDataObject; EditorData: IFormLinkItemEditorData);
    procedure FillActions(Sender: ILinkItemSelectForm; AddActionProc: TAddActionProcedure);
    function OnDelete(Sender: ILinkItemSelectForm; Data: TDataObject; Editor: TPanel): Boolean;
    function OnApply(Sender: ILinkItemSelectForm): Boolean;
  end;

  ILinkItemSelectForm = interface(IFormInterface)
    ['{92517237-BEFB-4033-BD56-3974E650E954}']
    function Execute(ListWidth: Integer; Title: string; Data: TList<TDataObject>; Editor: ILinkEditor): Boolean;
    function GetDataList: TList<TDataObject>;
    property DataList: TList<TDataObject> read GetDataList;
  end;

  IFormLinkItemEditor = interface(IFormInterface)
    ['{EBFFA2F7-FF90-4425-B217-916E70F8399C}']
     function Execute(Title: string; Data: TDataObject; Editor: ILinkEditor): Boolean;
  end;

  IFormCollectionPreviewSettings =  interface(IFormInterface)
    ['{AC28FCD4-E07B-4FC5-BB42-03E91989457B}']
    function Execute(CollectionFileName: string): Boolean;
  end;

  IFullScreenControl = interface(IFormInterface)
    ['{09079B22-272B-4474-B5F1-8E6CACAD7AD8}']
    procedure Hide;
    procedure Close;
    procedure Pause;
    procedure Play;
    function HasMouse: Boolean;
    procedure MoveToForm(Form: TDBForm);
    procedure SetButtonsEnabled(Value: Boolean);
    procedure SetPlayEnabled(Value: Boolean);
  end;

  ISlideShowForm = interface(IFormInterface)
    ['{CFB4A1D1-08D4-4F16-9ACB-05BD2EBC0B29}']
    procedure Next;
    procedure Previous;
    procedure Pause;
    procedure Play;
    procedure Execute;
    procedure Close;
    procedure DisableControl;
    procedure EnableControl;
  end;

  IFullScreenImageForm = interface(IFormInterface)
    ['{531EDB91-3324-4982-86CC-F15840D3E3EE}']
    procedure DrawImage(Image: TBitmap);
    procedure Pause;
    procedure Play;
    procedure Close;
    procedure DisableControl;
    procedure EnableControl;
  end;

type
  TFormInterfaces = class(TObject)
  private
    FFormInterfaces: TDictionary<TGUID, TComponentClass>;
    FFormInstances: TDictionary<TGUID, TForm>;
    FCreationList: TList<TGUID>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterFormInterface(Intf: TGUID; FormClass: TComponentClass);
    function CreateForm<T: IInterface>(): T;
    function GetSingleForm<T: IInterface>(CreateNew: Boolean): T;
    function GetSingleFormInstance<TFormClass: TForm>(Intf: TGUID; CreateNew: Boolean): TFormClass;
    procedure RemoveSingleInstance(FormInstance: TForm);
  end;

function FormInterfaces: TFormInterfaces;

function Viewer: IViewerForm;
function CurrentViewer: IViewerForm;
function AboutForm: IAboutForm;
function ActivationForm: IActivationForm;
function OptionsForm: IOptionsForm;
function RequestPasswordForm: IRequestPasswordForm;
function BatchProcessingForm: IBatchProcessingForm;
function JpegOptionsForm: IJpegOptionsForm;
function SelectSourceForm: ISelectSourceForm;
function ImportForm: IImportForm;
function StringPromtForm: IStringPromtForm;
function EncryptForm: IEncryptForm;
function SteganographyForm: ISteganographyForm;
function ShareForm: IShareForm;
function ShareLinkForm: IShareLinkForm;
function GroupsSelectForm: IGroupsSelectForm;
function GroupInfoForm: IGroupInfoForm;
function GroupCreateForm: IGroupCreateForm;
function CollectionAddItemForm: ICollectionAddItemForm;
function CDExportForm: ICDExportForm;
function CDMapperForm: ICDMapperForm;
function SelectLocationForm: ISelectLocationForm;
function LinkItemSelectForm: ILinkItemSelectForm;
function BackgroundTaskStatusForm: IBackgroundTaskStatusForm;
function CollectionPreviewSettings: IFormCollectionPreviewSettings;
function FormLinkItemEditor: IFormLinkItemEditor;
function FormSelectDuplicateDirectories: IFormSelectDuplicateDirectories;

function FullScreenControl: IFullScreenControl;
function FullScreenImageForm: IFullScreenImageForm;
function SlideShowForm: ISlideShowForm;

implementation

var
  FFormInterfaces: TFormInterfaces = nil;

function FormInterfaces: TFormInterfaces;
begin
  if FFormInterfaces = nil then
    FFormInterfaces := TFormInterfaces.Create;

  Result := FFormInterfaces;
end;

function Viewer: IViewerForm;
begin
  Result := FormInterfaces.GetSingleForm<IViewerForm>(True);
end;

function CurrentViewer: IViewerForm;
begin
  Result := FormInterfaces.GetSingleForm<IViewerForm>(False);
end;

function AboutForm: IAboutForm;
begin
  Result := FormInterfaces.GetSingleForm<IAboutForm>(True);
end;

function ActivationForm: IActivationForm;
begin
  Result := FormInterfaces.GetSingleForm<IActivationForm>(True);
end;

function OptionsForm: IOptionsForm;
begin
  Result := FormInterfaces.GetSingleForm<IOptionsForm>(True);
end;

function RequestPasswordForm: IRequestPasswordForm;
begin
  Result := FormInterfaces.CreateForm<IRequestPasswordForm>();
end;

function BatchProcessingForm: IBatchProcessingForm;
begin
  Result := FormInterfaces.CreateForm<IBatchProcessingForm>();
end;

function JpegOptionsForm: IJpegOptionsForm;
begin
  Result := FormInterfaces.GetSingleForm<IJpegOptionsForm>(True);
end;

function SelectSourceForm: ISelectSourceForm;
begin
  Result := FormInterfaces.CreateForm<ISelectSourceForm>();
end;

function ImportForm: IImportForm;
begin
  Result := FormInterfaces.CreateForm<IImportForm>();
end;

function StringPromtForm: IStringPromtForm;
begin
  Result := FormInterfaces.CreateForm<IStringPromtForm>();
end;

function EncryptForm: IEncryptForm;
begin
  Result := FormInterfaces.CreateForm<IEncryptForm>();
end;

function SteganographyForm: ISteganographyForm;
begin
  Result := FormInterfaces.CreateForm<ISteganographyForm>();
end;

function ShareForm: IShareForm;
begin
  Result := FormInterfaces.CreateForm<IShareForm>();
end;

function ShareLinkForm: IShareLinkForm;
begin
  Result := FormInterfaces.CreateForm<IShareLinkForm>();
end;

function GroupsSelectForm: IGroupsSelectForm;
begin
  Result := FormInterfaces.CreateForm<IGroupsSelectForm>();
end;

function GroupInfoForm: IGroupInfoForm;
begin
  Result := FormInterfaces.CreateForm<IGroupInfoForm>();
end;

function GroupCreateForm: IGroupCreateForm;
begin
  Result := FormInterfaces.CreateForm<IGroupCreateForm>();
end;

function CollectionAddItemForm: ICollectionAddItemForm;
begin
  Result := FormInterfaces.CreateForm<ICollectionAddItemForm>();
end;

function CDExportForm: ICDExportForm;
begin
  Result := FormInterfaces.GetSingleForm<ICDExportForm>(True);
end;

function CDMapperForm: ICDMapperForm;
begin
  Result := FormInterfaces.GetSingleForm<ICDMapperForm>(True);
end;

function SelectLocationForm: ISelectLocationForm;
begin
  Result := FormInterfaces.CreateForm<ISelectLocationForm>();
end;

function LinkItemSelectForm: ILinkItemSelectForm;
begin
  Result := FormInterfaces.CreateForm<ILinkItemSelectForm>();
end;

function BackgroundTaskStatusForm: IBackgroundTaskStatusForm;
begin
  Result := FormInterfaces.CreateForm<IBackgroundTaskStatusForm>();
end;

function CollectionPreviewSettings: IFormCollectionPreviewSettings;
begin
  Result := FormInterfaces.CreateForm<IFormCollectionPreviewSettings>();
end;

function FormLinkItemEditor: IFormLinkItemEditor;
begin
  Result := FormInterfaces.CreateForm<IFormLinkItemEditor>();
end;

function FullScreenControl: IFullScreenControl;
begin
  Result := FormInterfaces.CreateForm<IFullScreenControl>();
end;

function FullScreenImageForm: IFullScreenImageForm;
begin
  Result := FormInterfaces.CreateForm<IFullScreenImageForm>();
end;

function SlideShowForm: ISlideShowForm;
begin
  Result := FormInterfaces.CreateForm<ISlideShowForm>();
end;

function FormSelectDuplicateDirectories: IFormSelectDuplicateDirectories;
begin
  Result := FormInterfaces.CreateForm<IFormSelectDuplicateDirectories>();
end;

{ TFormInterfaces }

constructor TFormInterfaces.Create;
begin
  FFormInterfaces := TDictionary<TGUID, TComponentClass>.Create;
  FFormInstances := TDictionary<TGUID, TForm>.Create;
  FCreationList := TList<TGUID>.Create;
end;

destructor TFormInterfaces.Destroy;
begin
  F(FFormInterfaces);
  F(FFormInstances);
  F(FCreationList);
  inherited;
end;

function TFormInterfaces.CreateForm<T>: T;
var
  G: TGUID;
  F: TForm;
begin
  G := GetTypeData(TypeInfo(T))^.Guid;
  Application.CreateForm(FFormInterfaces[G], F);

  F.GetInterface(G, Result);
end;

function TFormInterfaces.GetSingleFormInstance<TFormClass>(Intf: TGUID; CreateNew: Boolean): TFormClass;
begin
  if FFormInstances.ContainsKey(Intf) then
    Exit(FFormInstances[Intf] as TFormClass);

  if not CreateNew then
    Exit(nil);

  if GetCurrentThreadId <> MainThreadID then
    raise Exception.Create('Can''t create form using child thread!');

  Application.CreateForm(FFormInterfaces[Intf], Result);
  FFormInstances.Add(Intf, Result);
end;

function TFormInterfaces.GetSingleForm<T>(CreateNew: Boolean): T;
var
  G: TGUID;
  Form: TForm;
begin
  G := GetTypeData(TypeInfo(T))^.Guid;

  if FCreationList.Contains(G) then
    Exit(T(nil));

  if not FFormInstances.ContainsKey(G) then
  begin
    if not CreateNew then
      Exit(nil);

    if GetCurrentThreadId <> MainThreadID then
      raise Exception.Create('Can''t create form using child thread!');

    FCreationList.Add(G);
    try
      Application.CreateForm(FFormInterfaces[G], Form);
      FFormInstances.Add(G, Form);
    finally
      FCreationList.Remove(G);
    end;
  end;

  FFormInstances[G].GetInterface(G, Result);
end;

procedure TFormInterfaces.RegisterFormInterface(Intf: TGUID; FormClass: TComponentClass);
begin
  FFormInterfaces.Add(Intf, FormClass);
end;

procedure TFormInterfaces.RemoveSingleInstance(FormInstance: TForm);
var
  Pair: TPair<TGUID, TForm>;
begin
  for Pair in FFormInstances do
    if Pair.Value = FormInstance then
    begin
      FFormInstances.Remove(Pair.Key);
      Break;
    end;
end;

initialization
finalization
  F(FFormInterfaces);

end.

