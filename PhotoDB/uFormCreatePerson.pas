unit uFormCreatePerson;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.Types,
  System.SysUtils,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Menus,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.AppEvnts,
  Vcl.Imaging.jpeg,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,

  Dmitry.Utils.System,
  Dmitry.Controls.Base,
  Dmitry.Controls.WatermarkedEdit,
  Dmitry.Controls.WatermarkedMemo,
  Dmitry.Controls.WebLinkList,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.WebLink,
  Dmitry.PathProviders,

  UnitDBDeclare,

  uFaceDetection,
  uPeopleRepository,
  uMemory,
  uMemoryEx,
  uBitmapUtils,
  uDBIcons,
  uThreadEx,
  uDBThread,
  uDBConnection,
  uDBContext,
  uDBEntities,
  uDBManager,
  uThreadForm,
  u2DUtils,
  uConstants,
  uEditorTypes,
  uFastLoad,
  uVCLHelpers,
  uDBClasses,
  uDBForm,
  uSettings,
  uExplorerPersonsProvider,
  uThemesUtils,
  uDialogUtils,
  uProgramStatInfo,
  uFormInterfaces,
  uCollectionEvents;

type
  TFormCreatePerson = class(TThreadForm)
    PbPhoto: TPaintBox;
    LbName: TLabel;
    BvSeparator: TBevel;
    WedName: TWatermarkedEdit;
    LbComments: TLabel;
    WmComments: TWatermarkedMemo;
    BtnOk: TButton;
    BtnCancel: TButton;
    WllGroups: TWebLinkList;
    LbGroups: TLabel;
    LbBirthDate: TLabel;
    DtpBirthDay: TDateTimePicker;
    LsExtracting: TLoadingSign;
    PmImageOptions: TPopupActionBar;
    MiLoadOtherImage: TMenuItem;
    LsAdding: TLoadingSign;
    AeMain: TApplicationEvents;
    GroupsImageList: TImageList;
    MiEditImage: TMenuItem;
    LsNameCheck: TLoadingSign;
    WlPersonNameStatus: TWebLink;
    TmrCkeckName: TTimer;
    ImOK: TImage;
    ImInvalid: TImage;
    ImWarning: TImage;
    WlEditImage: TWebLink;
    N1: TMenuItem;
    MiUseCurrentImage: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PbPhotoPaint(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnOkClick(Sender: TObject);
    procedure WedNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure WllGroupsDblClick(Sender: TObject);
    procedure AeMainMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure MiEditImageClick(Sender: TObject);
    procedure MiLoadOtherImageClick(Sender: TObject);
    procedure WedNameChange(Sender: TObject);
    procedure TmrCkeckNameTimer(Sender: TObject);
    procedure WedNameExit(Sender: TObject);
    procedure WlPersonNameStatusClick(Sender: TObject);
    procedure WlEditImageClick(Sender: TObject);
    procedure MiUseCurrentImageClick(Sender: TObject);
  private
    { Private declarations }
    FContext: IDBContext;
    FGroupsRepository: IGroupsRepository;
    FPeopleRepository: IPeopleRepository;
    FPicture: TBitmap;
    FDisplayImage: TBitmap;
    FOriginalFace: TFaceDetectionResultItem;
    FPerson: TPerson;
    FInfo: TMediaItem;
    FRelatedGroups: string;
    FReloadGroupsMessage: Cardinal;
    FIsImageChanged: Boolean;
    FIsEditMode: Boolean;
    FFormPersonSuggest: TDBForm;
    procedure CreatePerson(Info: TMediaItem; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap);
    function DoEditPerson(PersonID: Integer; NewAvatar: TBitmap): Boolean;
    procedure RecreateImage;
    procedure UpdateFaceArea(Face: TFaceDetectionResultItem);
    procedure LoadLanguage;
    procedure ReloadGroups;
    procedure FillImageList;
    procedure MarkPersonOnPhoto;
    procedure GroupClick(Sender: TObject);
    procedure CloseSuggestForm;
    procedure RealignControls;
  protected
    function GetFormID: string; override;
    procedure EnableControls(IsEnabled: Boolean);
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; params: TEventFields; Value: TEventValues);
    procedure AddPhoto;
    procedure OnMoving(var Msg: TWMMoving); message WM_MOVING;
    procedure WMActivateApp(var Msg: TMessage); message WM_ACTIVATEAPP;
  public
    { Public declarations }
    procedure UpdateNameStatus(PersonList: TPathItemCollection);
    procedure SelectOtherPerson(PersonID: Integer);
    property Person: TPerson read FPerson;
  end;

  TPersonExtractor = class(TDBThread)
  private
    FBitmap: TBitmap;
    FFaces: TFaceDetectionResult;
    FOwner: TFormCreatePerson;
    FFace: TFaceDetectionResultItem;
    procedure UpdatePicture;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TFormCreatePerson; AFace: TFaceDetectionResultItem; Src: TBitmap);
    destructor Destroy; override;
  end;

  TCheckNameThread = class(TThreadEx)
  private
    FName: string;
    FNewName: string;
    FPersons: TPathItemCollection;
    FEditPerson: Boolean;
    FContext: IDBContext;
  protected
    procedure Execute; override;
    procedure UpdateNameData;
  public
    constructor Create(AOwner: TFormCreatePerson; State: TGuid; Context: IDBContext; Name, NewName: string; EditPerson: Boolean);
    destructor Destroy; override;
  end;

procedure CreatePerson(Info: TMediaItem; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap; out Person: TPerson);
function EditPerson(PersonID: Integer; NewAvatar: TBitmap = nil): Boolean;

implementation

uses
  ImEditor,
  uDatabaseDirectoriesUpdater,
  uFormPersonSuggest;

{$R *.dfm}

procedure CreatePerson(Info: TMediaItem; OriginalFace, FaceInImage: TFaceDetectionResultItem; Bitmap: TBitmap; out Person: TPerson);
var
  FormCreatePerson: TFormCreatePerson;
begin
  Application.CreateForm(TFormCreatePerson, FormCreatePerson);
  try
    FormCreatePerson.CreatePerson(Info, OriginalFace, FaceInImage, Bitmap);
    Person := FormCreatePerson.Person;
  finally
    R(FormCreatePerson);
  end;
end;

function EditPerson(PersonID: Integer; NewAvatar: TBitmap = nil): Boolean;
var
  FormCreatePerson: TFormCreatePerson;
begin
  Application.CreateForm(TFormCreatePerson, FormCreatePerson);
  try
    Result := FormCreatePerson.DoEditPerson(PersonID, NewAvatar);
  finally
    R(FormCreatePerson);
  end;
end;

{ TFormCreatePerson }

procedure TFormCreatePerson.AeMainMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if msg.message = FReloadGroupsMessage then
    ReloadGroups;

  if (Msg.message = WM_MOUSEWHEEL) then
    WllGroups.PerformMouseWheel(Msg.wParam, Handled);
end;

procedure TFormCreatePerson.BtnCancelClick(Sender: TObject);
begin
  ModalResult := MB_OKCANCEL;
  Close;
end;

procedure TFormCreatePerson.AddPhoto;
var
  PersonArea: TPersonArea;
begin
  if Person <> nil then
  begin
    PersonArea := TPersonArea.Create(FInfo.ID, Person.ID, FOriginalFace);
    try
      FPeopleRepository.AddPersonForPhoto(Self, PersonArea);
      FOriginalFace.Data := PersonArea.Clone;
    finally
      F(PersonArea);
    end;
    Close;
  end;
end;

procedure TFormCreatePerson.BtnOkClick(Sender: TObject);
var
  EventValues: TEventValues;
  PersonID: Integer;

  procedure UpdateImage;
  var
    J: TJpegImage;
    B: TBitmap;
    W, H: Integer;
  begin
    J := TJPEGImage.Create;
    try
      B := TBitmap.Create;
      try
        W := FPicture.Width;
        H := FPicture.Height;
        ProportionalSize(250, 300, W, H);
        DoResize(W, H, FPicture, B);
        J.Assign(B);
        Person.Image := J;
      finally
        F(B);
      end;
    finally
      F(J);
    end;
  end;

  procedure UpdatePersonFields;
  begin
    FPerson.Name := WedName.Text;
    FPerson.Birthday := DtpBirthDay.Date;
    FPerson.Groups := FRelatedGroups;
    FPerson.Comment := WmComments.Text;
  end;

begin
  if not BtnOk.Enabled then
    Exit;

  EnableControls(False);

  //statistics
  ProgramStatistics.PersonUsed;

  if FIsEditMode then
  begin
    UpdatePersonFields;
    if FIsImageChanged then
      UpdateImage;
    FPeopleRepository.UpdatePerson(FPerson, FIsImageChanged);

    EventValues.ID := FPerson.ID;
    EventValues.FileName := FPerson.Name;
    EventValues.NewName := FPerson.Name;
    CollectionEvents.DoIDEvent(Self, FPerson.ID, [EventID_PersonChanged], EventValues);

    ModalResult := MB_OK;
    Close;
  end else
  begin
    F(FPerson);

    FPerson := TPerson.Create;
    UpdatePersonFields;
    UpdateImage;
    PersonID := FPeopleRepository.CreateNewPerson(Person);
    F(FPerson);
    FPerson := TPerson.Create;
    FPeopleRepository.FindPerson(PersonID, FPerson);

    if not FPerson.Empty then
    begin
      MarkPersonOnPhoto;

      EventValues.ID := FPerson.ID;
      EventValues.FileName := FPerson.Name;
      EventValues.NewName := FPerson.Name;
      CollectionEvents.DoIDEvent(Self, FPerson.ID, [EventID_PersonAdded], EventValues);
    end;
  end;
end;

procedure TFormCreatePerson.MarkPersonOnPhoto;
var
  FileInfo: TMediaItem;
begin
  if Person.ID > 0 then
  begin
    if FInfo.ID > 0 then
    begin
      AddPhoto;
    end else
    begin
      FileInfo := TMediaItem.Create;
      try
        FileInfo.FileName := FInfo.FileName;
        FileInfo.Include := True;
        FileInfo.Groups := FRelatedGroups;

        UpdaterStorage.AddFile(FileInfo, dtpHighAndSkipFilters);
        Exit;
      finally
        F(FileInfo);
      end;
    end;
  end;
end;

procedure TFormCreatePerson.SelectOtherPerson(PersonID: Integer);
begin
  if not FIsEditMode then
  begin
    EnableControls(False);
    FPerson := FPeopleRepository.GetPerson(PersonID, True);
    MarkPersonOnPhoto;
  end else
  begin
    EditPerson(PersonID);
  end;
end;

procedure TFormCreatePerson.ChangedDBDataByID(Sender: TObject; ID: Integer;
  params: TEventFields; Value: TEventValues);
begin
  if SetNewIDFileData in Params then
  begin
    if AnsiLowerCase(Value.FileName) = AnsiLowerCase(FInfo.FileName) then
    begin
      FInfo.ID := Value.ID;
      AddPhoto;
    end;
  end;

  if EventID_CancelAddingImage in Params then
  begin
    if (AnsiLowerCase(Value.NewName) = AnsiLowerCase(FInfo.FileName)) and (Value.ID > 0) then
    begin
      FInfo.ID := Value.ID;
      AddPhoto;
      Exit;
    end;

    if AnsiLowerCase(Value.FileName) = AnsiLowerCase(FInfo.FileName) then
      EnableControls(True);

  end;
end;

procedure TFormCreatePerson.CloseSuggestForm;
begin
  if FFormPersonSuggest <> nil then
    FFormPersonSuggest.Close;
end;

procedure TFormCreatePerson.MiEditImageClick(Sender: TObject);
var
  Editor: IImageEditor;
begin
  Editor := TImageEditor.Create(nil);
  if Editor.EditImage(FPicture) then
  begin
    FIsImageChanged := True;
    RecreateImage;
    Invalidate;
  end;
end;

function TFormCreatePerson.DoEditPerson(PersonID: Integer; NewAvatar: TBitmap): Boolean;
begin
  Result := False;
  FPerson := TPerson.Create;
  try
    FPeopleRepository.FindPerson(PersonID, FPerson);

    if FPerson.Empty then
      Exit;

    FRelatedGroups := Person.Groups;
    WedName.Text := Person.Name;
    DtpBirthDay.Date := Person.BirthDay;
    WmComments.Text := Person.Comment;
    FIsImageChanged := False;
    FIsEditMode := True;

    ReloadGroups;

    if NewAvatar <> nil then
    begin
      FPicture.Assign(NewAvatar);
      FIsImageChanged := True;
    end else
      FPicture.Assign(Person.Image);

    BtnOk.Enabled := True;
    RealignControls;
    RecreateImage;
    Caption := LF('Edit person: {0}', [FPerson.Name]);
    ShowModal;
  finally
    F(FPerson);
  end;
  Result := ModalResult = MB_OK;
end;

procedure TFormCreatePerson.EnableControls(IsEnabled: Boolean);
begin
  BtnOk.Enabled := IsEnabled;
  BtnCancel.Enabled := IsEnabled;
  WedName.Enabled := IsEnabled;
  DtpBirthDay.Enabled := IsEnabled;
  WmComments.Enabled := IsEnabled;
  LsAdding.Visible := not IsEnabled;
  WlPersonNameStatus.Enabled := IsEnabled;
end;

procedure TFormCreatePerson.CreatePerson(Info: TMediaItem; OriginalFace, FaceInImage: TFaceDetectionResultItem;
  Bitmap: TBitmap);
begin
  FIsEditMode := False;
  FPicture.Assign(Bitmap);
  FOriginalFace := OriginalFace;
  FInfo := Info.Copy;
  TPersonExtractor.Create(Self, FaceInImage, FPicture);
  RecreateImage;
  ReloadGroups;
  RealignControls;
  LsExtracting.Show;
  Caption := L('Create new person');
  ShowModal;
end;

procedure TFormCreatePerson.FormCreate(Sender: TObject);
begin
  FContext := DBManager.DBContext;
  FGroupsRepository := FContext.Groups;
  FPeopleRepository := FContext.People;
  FInfo := nil;
  FPerson := nil;
  FFormPersonSuggest := nil;
  FIsImageChanged := False;
  FIsEditMode := False;
  FPicture := TBitmap.Create;
  FDisplayImage := TBitmap.Create;
  LoadLanguage;
  PmImageOptions.Images := Icons.ImageList;
  MiLoadotherimage.ImageIndex := DB_IC_LOADFROMFILE;
  MiEditImage.ImageIndex := DB_IC_IMEDITOR;
  MiUseCurrentImage.ImageIndex := DB_IC_SLIDE_SHOW;
  CollectionEvents.RegisterChangesID(Self, ChangedDBDataByID);
  FReloadGroupsMessage := RegisterWindowMessage('CREATE_PERSON_RELOAD_GROUPS');
  FixFormPosition;

  WlEditImage.RefreshBuffer(True);
  WlEditImage.LoadFromResource('IMEDITOR');
  WlEditImage.Left := PbPhoto.Left + PbPhoto.Width div 2 - WlEditImage.Width div 2;
  WlPersonNameStatus.Left := LsNameCheck.Left;
end;

procedure TFormCreatePerson.FormDestroy(Sender: TObject);
begin
  CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataByID);
  F(FPicture);
  F(FFormPersonSuggest);
  F(FDisplayImage);
  F(FInfo);
  FContext := nil;
  FPeopleRepository := nil;
  FGroupsRepository := nil;
end;

procedure TFormCreatePerson.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;
    Close;
  end;
end;

function TFormCreatePerson.GetFormID: string;
begin
  Result := 'EditPerson';
end;

procedure TFormCreatePerson.LoadLanguage;
begin
  BeginTranslate;
  try
    LbName.Caption := L('Name') + ':';
    WedName.WatermarkText := L('Name of person');
    LbBirthDate.Caption := L('Birthday') + ':';
    LbGroups.Caption := L('Related groups') + ':';
    LbComments.Caption := L('Comment') + ':';
    WmComments.WatermarkText := L('Comment');
    BtnCancel.Caption := L('Cancel');
    BtnOk.Caption := L('Ok');
    MiLoadOtherImage.Caption := L('Load other image');
    MiEditImage.Caption := L('Edit image');
    WlEditImage.Text := L('Change picture');
    MiUseCurrentImage.Caption := L('Use current image');
  finally
    EndTranslate;
  end;
end;

procedure TFormCreatePerson.MiLoadOtherImageClick(Sender: TObject);
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    if GetImageFromUser(Bitmap, 250, 300) then
    begin
      FPicture.Assign(Bitmap);
      RecreateImage;
      Invalidate;
      FIsImageChanged := True;
    end;
  finally
    F(Bitmap);
  end;
end;

procedure TFormCreatePerson.OnMoving(var Msg: TWMMoving);
var
  P: TPoint;
begin
  P := Point(WedName.Left, WedName.Top + WedName.Height);
  P := ClientToScreen(P);
  if FFormPersonSuggest <> nil then
    TFormPersonSuggest(FFormPersonSuggest).UpdatePos(P);
end;

procedure TFormCreatePerson.PbPhotoPaint(Sender: TObject);
begin
  if FDisplayImage <> nil then
    PbPhoto.Canvas.Draw(PbPhoto.Width div 2 - FDisplayImage.Width div 2,
      PbPhoto.Height div 2 - FDisplayImage.Height div 2, FDisplayImage);
end;

procedure TFormCreatePerson.RealignControls;
const
  PaddingBottom = 6;

var
  Y: Integer;
begin
  Y := WedName.AfterTop(PaddingBottom);

  if WlPersonNameStatus.Visible then
  begin
    WlPersonNameStatus.Top := Y;
    LsNameCheck.Top := Y;
    Y := WlPersonNameStatus.AfterTop(PaddingBottom);
  end;

  LbBirthDate.Top := Y;
  Y := LbBirthDate.AfterTop(PaddingBottom);

  DtpBirthDay.Top := Y;
  Y := DtpBirthDay.AfterTop(PaddingBottom);

  LbGroups.Top := Y;
  Y := LbGroups.AfterTop(PaddingBottom);

  WllGroups.Top := Y;
  Y := WllGroups.AfterTop(PaddingBottom);

  LbComments.Top := Y;
  Y := LbComments.AfterTop(PaddingBottom);

  WmComments.Top := Y;
  WmComments.Height := BtnOk.Top - Y - PaddingBottom;
end;

procedure TFormCreatePerson.RecreateImage;
var
  B, SmallB: TBitmap;
  W, H: Integer;
begin
  B := TBitmap.Create;
  try
    B.PixelFormat := pf32bit;
    DrawShadowToImage(B, FPicture);
    W := B.Width;
    H := B.Height;
    ProportionalSize(PbPhoto.Width, PbPhoto.Height, W, H);
    SmallB := TBitmap.Create;
    try
      SmallB.PixelFormat := pf32Bit;
      DoResize(W, H, B, SmallB);
      F(FDisplayImage);
      FDisplayImage := TBitmap.Create;
      LoadBMPImage32bit(SmallB, FDisplayImage, Theme.WindowColor);
    finally
      F(SmallB);
    end;
  finally
    F(B);
  end;
end;

procedure TFormCreatePerson.UpdateFaceArea(Face: TFaceDetectionResultItem);
var
  B: TBitmap;
begin
  LsExtracting.Hide;

  if Face <> nil then
  begin
    B := TBitmap.Create;
    try
      B.SetSize(Face.Width, Face.Height);
      B.Canvas.CopyRect(Rect(0, 0, Face.Width, Face.Height), FPicture.Canvas, Face.Rect);
      Exchange(FPicture, B);
    finally
      F(B);
    end;
    RecreateImage;
    PbPhoto.Refresh;
  end;
end;

procedure TFormCreatePerson.UpdateNameStatus(PersonList: TPathItemCollection);
var
  P: TPoint;
begin
  LsNameCheck.Hide;
  WlPersonNameStatus.Left := LsNameCheck.Left;
  if PersonList.Count = 0 then
  begin
    WlPersonNameStatus.IconWidth := 16;
    WlPersonNameStatus.Icon := ImOK.Picture.Icon;
    WlPersonNameStatus.Text := L('Person name is unique!');
    WlPersonNameStatus.CanClick := False;
    WlPersonNameStatus.Refresh;
  end else
  begin
    if AnsiUpperCase(TPersonItem(PersonList[0]).PersonName) = AnsiUpperCase(WedName.Text) then
    begin
      WlPersonNameStatus.CanClick := True;
      WlPersonNameStatus.IconWidth := 16;
      WlPersonNameStatus.Icon := ImInvalid.Picture.Icon;
      WlPersonNameStatus.Text := FormatEx(L('Person name already in use!'), [PersonList.Count]);
      WlPersonNameStatus.Refresh;
    end else
    begin
      WlPersonNameStatus.CanClick := True;
      WlPersonNameStatus.Text := FormatEx(L('{0} person(s) are found with similar name!'), [PersonList.Count]);
      WlPersonNameStatus.IconWidth := 16;
      WlPersonNameStatus.Icon := ImWarning.Picture.Icon;
      WlPersonNameStatus.Refresh;
    end;
  end;
  WlPersonNameStatus.Show;

  if FFormPersonSuggest = nil then
    FFormPersonSuggest := TFormPersonSuggest.Create(Self);
  FFormPersonSuggest.Width := WedName.Width;
  P := Point(WedName.Left, WedName.Top + WedName.Height);
  P := ClientToScreen(P);
  TFormPersonSuggest(FFormPersonSuggest).LoadPersons(Self, P, PersonList);

  BtnOk.Enabled := (PersonList.Count = 0) or ((PersonList.Count > 0) and (TPersonItem(PersonList[0]).PersonName <> WedName.Text));

  RealignControls;
end;

procedure TFormCreatePerson.MiUseCurrentImageClick(Sender: TObject);
var
  FileName: string;
  Editor: IImageEditor;
  Bitmap: TBitmap;
begin
  FileName := Screen.CurrentImageFileName;

  if FileName <> '' then
  begin
    Editor := TImageEditor.Create(nil);
    try
      Bitmap := TBitmap.Create;
      try
        if Editor.EditFile(FileName, Bitmap) then
        begin
          KeepProportions(Bitmap, 250, 300);

          FPicture.Assign(Bitmap);
          RecreateImage;
          Invalidate;
          FIsImageChanged := True;
        end;
      finally
        F(Bitmap);
      end;
    finally
      Editor := nil;
    end;
  end;
end;

procedure TFormCreatePerson.WedNameChange(Sender: TObject);
begin
  if (FPerson <> nil) and (FPerson.Name = WedName.Text) then
    Exit;

  TmrCkeckName.Restart;
  BtnOk.Enabled := False;
end;

procedure TFormCreatePerson.WedNameExit(Sender: TObject);
begin
  if FFormPersonSuggest <> nil then
    FFormPersonSuggest.Hide;
end;

procedure TFormCreatePerson.WedNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    BtnOkClick(Sender);
  end;
end;

procedure TFormCreatePerson.WlEditImageClick(Sender: TObject);
var
  P: TPoint;
begin
  P := WlEditImage.ClientRect.TopLeft;
  P := WlEditImage.ClientToScreen(P);
  P.Y := P.Y + WlEditImage.Height;
  PmImageOptions.Popup(P.X, P.Y);
end;

procedure TFormCreatePerson.WllGroupsDblClick(Sender: TObject);
var
  KeyWords: string;
begin
  CloseSuggestForm;
  GroupsSelectForm.Execute(FRelatedGroups, KeyWords, True);
end;

procedure TFormCreatePerson.WlPersonNameStatusClick(Sender: TObject);
begin
  TmrCkeckNameTimer(Sender);
end;

procedure TFormCreatePerson.WMActivateApp(var Msg: TMessage);
begin
  if Msg.wParam = 0 then
    CloseSuggestForm;
end;

procedure TFormCreatePerson.ReloadGroups;
var
  I: Integer;
  FCurrentGroups: TGroups;
  WL: TWebLink;
  LblInfo: TStaticText;
begin
  FillImageList;
  WllGroups.Clear;

  FCurrentGroups := TGroups.CreateFromString(FRelatedGroups);
  try
    if FCurrentGroups.Count = 0 then
    begin
      LblInfo := TStaticText.Create(WllGroups);
      LblInfo.Parent := WllGroups;
      WllGroups.AddControl(LblInfo, True);
      LblInfo.Caption := L('There are no related groups');
    end;

    WL := WllGroups.AddLink(True);
    WL.Text := L('Edit related groups');
    WL.ImageList := GroupsImageList;
    WL.ImageIndex := 0;
    WL.Tag := -1;
    WL.OnClick := GroupClick;

    for I := 0 to FCurrentGroups.Count - 1 do
    begin
      WL := WllGroups.AddLink;
      WL.Text := FCurrentGroups[I].GroupName;
      WL.ImageList := GroupsImageList;
      WL.ImageIndex := I + 1;
      WL.Tag := I;
      WL.OnClick := GroupClick;
    end;
  finally
    F(FCurrentGroups);
  end;
  WllGroups.ReallignList;
end;

procedure TFormCreatePerson.TmrCkeckNameTimer(Sender: TObject);
var
  PName: string;
begin
  TmrCkeckName.Enabled := False;
  NewFormState;
  RealignControls;
  if WedName.Text <> '' then
  begin
    PName := '';
    if FPerson <> nil then
      PName := FPerson.Name;
    TCheckNameThread.Create(Self, StateID, FContext, PName, Trim(WedName.Text), FIsEditMode);
    LsNameCheck.Show;
    WlPersonNameStatus.IconWidth := 0;
    WlPersonNameStatus.Left := LsNameCheck.Left + LsNameCheck.Width + 3;
  end else
  begin
    WlPersonNameStatus.IconWidth := 16;
    WlPersonNameStatus.Icon := ImWarning.Picture.Icon;
    WlPersonNameStatus.Text := L('Person name is required!');
    WlPersonNameStatus.CanClick := False;
    WlPersonNameStatus.Refresh;
    CloseSuggestForm;
  end;
end;

procedure TFormCreatePerson.GroupClick(Sender: TObject);
var
  KeyWords: string;
  WL: TWebLink;
begin
  CloseSuggestForm;
  WL := TWebLink(Sender);
  if WL.Tag > -1 then
  begin
    GroupInfoForm.Execute(nil, WL.Text, False);
  end else
  begin
    GroupsSelectForm.Execute(FRelatedGroups, KeyWords);
    PostMessage(Handle, FReloadGroupsMessage, 0, 0);
  end;
end;

procedure TFormCreatePerson.FillImageList;
var
  I: Integer;
  Group: TGroup;
  SmallB: TBitmap;
  FCurrentGroups: TGroups;
begin
  GroupsImageList.Clear;
  SmallB := TBitmap.Create;
  try
    SmallB.PixelFormat := pf24bit;
    SmallB.Width := 16;
    SmallB.Height := 16;
    SmallB.Canvas.Pen.Color := Theme.PanelColor;
    SmallB.Canvas.Brush.Color := Theme.PanelColor;
    SmallB.Canvas.Rectangle(0, 0, 16, 16);
    DrawIconEx(SmallB.Canvas.Handle, 0, 0, Icons[DB_IC_GROUPS], 16, 16, 0, 0, DI_NORMAL);
    GroupsImageList.Add(SmallB, nil);
  finally
    F(SmallB);
  end;
  FCurrentGroups := TGroups.CreateFromString(FRelatedGroups);
  try
    for I := 0 to FCurrentGroups.Count - 1 do
    begin
      SmallB := TBitmap.Create;
      try
        SmallB.PixelFormat := pf24bit;
        SmallB.Canvas.Brush.Color := Theme.PanelColor;
        SmallB.SetSize(16, 16);
        Group := FGroupsRepository.GetByName(FCurrentGroups[I].GroupName, True);
        try

          if (Group <> nil) and (Group.GroupImage <> nil) and not Group.GroupImage.Empty then
          begin
            SmallB.Assign(Group.GroupImage);
            CenterBitmap24To32ImageList(SmallB, 16);
          end;

          GroupsImageList.Add(SmallB, nil);
        finally
          F(Group);
        end;
      finally
        F(SmallB);
      end;
    end;
  finally
    F(FCurrentGroups);
  end;
end;

{ TPersonExtractor }

constructor TPersonExtractor.Create(AOwner: TFormCreatePerson; AFace: TFaceDetectionResultItem; Src: TBitmap);
begin
  inherited Create(AOwner, False);
  FOwner := AOwner;
  FBitmap := TBitmap.Create;
  FBitmap.Assign(Src);
  FFace := AFace.Copy;
end;

destructor TPersonExtractor.Destroy;
begin
  F(FBitmap);
  F(FFace);
  inherited;
end;

procedure TPersonExtractor.Execute;
var
  W, H: Integer;
  RMp, AMp, RR: Double;
  SmallBitmap: TBitmap;
begin
  inherited;
  FreeOnTerminate := True;
  FFaces := TFaceDetectionResult.Create;
  try

    W := FBitmap.Width;
    H := FBitmap.Height;
    RMp := W * H;
    AMp := AppSettings.ReadInteger('Options', 'FaceDetectionSize', 3) * 100000;

    if RMp > AMp then
    begin
      RR := Sqrt(RMp / AMp);
      SmallBitmap := TBitmap.Create;
      try
        ProportionalSize(Round(W / RR), Round(H / RR), W, H);
        uBitmapUtils.QuickReduceWide(W, H, FBitmap, SmallBitmap);
        FaceDetectionManager.FacesDetection(SmallBitmap, 0, FFaces, 'haarcascade_head_and_shoulders.xml');
      finally
        F(SmallBitmap);
      end;
    end else
      FaceDetectionManager.FacesDetection(FBitmap, 0, FFaces, 'haarcascade_head_and_shoulders.xml');

    SynchronizeEx(UpdatePicture);
  finally
    F(FFaces);
  end;
end;

procedure TPersonExtractor.UpdatePicture;
var
  I: Integer;
begin
  for I := 0 to FFaces.Count - 1 do
    if RectIntersectWithRectPercent(FFaces[I].Rect, FFace.Rect) > 80 then
    begin
      FOwner.UpdateFaceArea(FFaces[I]);
      Exit;
    end;

  FOwner.UpdateFaceArea(nil);
end;

{ TCheckNameThread }

constructor TCheckNameThread.Create(AOwner: TFormCreatePerson; State: TGuid; Context: IDBContext; Name, NewName: string; EditPerson: Boolean);
begin
  inherited Create(AOwner, State);
  FContext := Context;
  FName := Name;
  FNewName := NewName;
  FPersons := TPathItemCollection.Create;
  FEditPerson := EditPerson;
end;

destructor TCheckNameThread.Destroy;
begin
  F(FPersons);
  inherited;
end;

procedure TCheckNameThread.Execute;
var
  I: Integer;
  SC: TSelectCommand;
  PC: TPersonCollection;
  PI: TPersonItem;
  SQL: string;
begin
  inherited;
  FreeOnTerminate := True;
  CoInitializeEx(nil, COM_MODE);
  try
    SQL := FormatEx('(SELECT *, (UCase(ObjectName) = UCase(:ObjectNameCheck)) AS NameCheck FROM {0})', [ObjectTableName]);
    SC := FContext.CreateSelect(SQL);
    try
      SC.AddCustomeParameter(TStringParameter.Create('ObjectNameCheck', FNewName));
      SC.AddParameter(TAllParameter.Create);
      SC.AddWhereParameter(TCustomConditionParameter.Create(FormatEx('ObjectName like "%{0}%"', [NormalizeDBStringLike(FNewName)])));
      if FEditPerson then
        SC.AddWhereParameter(TStringParameter.Create('ObjectName', FName, paNotEquals));
      
      SC.Order.Add(TOrderParameter.Create('NameCheck', False));
      SC.Order.Add(TOrderParameter.Create('ObjectName', False));
      SC.TopRecords := 5;
      SC.Execute;

      PC := TPersonCollection.Create;
      try
        PC.ReadFromDS(SC.DS);
        for I := 0 to PC.Count - 1 do
        begin
          PI := TPersonItem.CreateFromPath(cPersonsPath + '\' + PC[I].Name, PATH_LOAD_NO_IMAGE, 0);
          FPersons.Add(PI);
          PI.ReadFromPerson(PC[I], 0, 16);
        end;
        SynchronizeEx(UpdateNameData);
      finally
        F(PC);
      end;
    finally
      F(SC);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TCheckNameThread.UpdateNameData;
begin
  TFormCreatePerson(OwnerForm).UpdateNameStatus(FPersons);
end;

end.
