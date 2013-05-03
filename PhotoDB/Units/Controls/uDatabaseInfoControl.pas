unit uDatabaseInfoControl;

interface

uses
  Generics.Collections,
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ActiveX,
  System.Math,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Imaging.jpeg,
  Vcl.Imaging.PngImage,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,

  Dmitry.Utils.System,
  Dmitry.Graphics.LayeredBitmap,
  Dmitry.Controls.LoadingSign,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,

  uRuntime,
  uMemory,
  uResources,
  uTranslateUtils,
  uJpegUtils,
  uBitmapUtils,
  uIconUtils,
  uSettings,
  uFormInterfaces,
  uDBManager,
  uDBContext,
  uDatabaseDirectoriesUpdater,
  uDBForm,
  uThreadForm,
  uThreadTask,
  uCollectionEvents,
  uLinkListEditorDatabases;

type
  TDatabaseInfoControl = class(TPanel)
  private
    FImage: TImage;
    FDatabaseName: TWebLink;
    FLsMain: TLoadingSign;
    FInfoLabel: TLabel;
    FSeparator: TBevel;
    FSelectImage: TImage;
    FCheckTimer: TTimer;
    FMinimized: Boolean;
    FOnSelectClick: TNotifyEvent;
    FInfo: TDatabaseInfo;
    FMediaCountReady: Boolean;
    FMediaCount: Integer;
    FCollectionPicture: TGraphic;
    FIsUpdatingCollection: Boolean;
    FCurrentFileName: string;
    FIsCustomImage: Boolean;
    procedure DoAlignInfo;
    procedure LoadImagesCount;
    procedure LoadColectionImage;
    procedure ShowDatabaseProperties;
    procedure SelectDatabaseClick(Sender: TObject);
    procedure CheckTimerOnTimer(Sender: TObject);
    procedure ImageClick(Sender: TObject);
    procedure DatabaseNameOnClick(Sender: TObject);
    procedure ChangedDBDataByID(Sender: TObject; ID: Integer; Params: TEventFields; Value: TEventValues);
  protected
    function L(StringToTranslate: string): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadControl(Info: TDatabaseInfo);
    property OnSelectClick: TNotifyEvent read FOnSelectClick write FOnSelectClick;
  end;

implementation

{ TDatabaseInfoControl }

procedure TDatabaseInfoControl.ChangedDBDataByID(Sender: TObject; ID: Integer;
  Params: TEventFields; Value: TEventValues);
var
  Bit, Bitmap: TBitmap;
begin
  if (SetNewIDFileData in Params) or (EventID_FileProcessed in Params) then
  begin
    if FCurrentFileName <> Value.FileName then
    begin
      FCurrentFileName := Value.FileName;
      Bit := TBitmap.Create;
      try
        Bit.PixelFormat := pf24bit;
        AssignJpeg(Bit, Value.JPEGImage);
        ApplyRotate(Bit, Value.Rotation);

        KeepProportions(Bit, FImage.Width - 4, FImage.Height - 4);

        Bitmap := TBitmap.Create;
        try
          DrawShadowToImage(Bitmap, Bit);

          Bitmap.AlphaFormat := afDefined;
          FImage.Picture.Graphic := Bitmap;
          FIsCustomImage := True;
        finally
          F(Bitmap);
        end;
      finally
        F(Bit);
      end;
    end;
  end;

  if FMediaCountReady then
  begin
    if [SetNewIDFileData] * Params <> [] then
    begin
      Inc(FMediaCount);
      FInfoLabel.Caption := NumberToShortNumber(FMediaCount);
    end;

    if [EventID_Param_Delete] * Params <> [] then
    begin
      Dec(FMediaCount);
      FInfoLabel.Caption := NumberToShortNumber(FMediaCount);
    end;
  end;
end;

procedure TDatabaseInfoControl.CheckTimerOnTimer(Sender: TObject);
var
  ActualUpdatingCollection: Boolean;
begin
  ActualUpdatingCollection := (UserDirectoryUpdaterCount > 0) or (UpdaterStorage.ActiveItemsCount > 0);

  if FIsUpdatingCollection <> ActualUpdatingCollection then
  begin
    FIsUpdatingCollection := ActualUpdatingCollection;
    DoAlignInfo;
  end;

  if FIsCustomImage and not ActualUpdatingCollection then
    LoadColectionImage;
end;

constructor TDatabaseInfoControl.Create(AOwner: TComponent);
begin
  inherited;
  StyleElements := [seFont, seClient, seBorder];
  ParentBackground := False;
  BevelOuter := bvNone;
  FMediaCountReady := False;
  FMediaCount := 0;
  FCollectionPicture := nil;
  CollectionEvents.RegisterChangesID(Self, ChangedDBDataByID);
  FIsUpdatingCollection := True;
  FCurrentFileName := '';
  FIsCustomImage := False;
end;

destructor TDatabaseInfoControl.Destroy;
begin
  F(FInfo);
  F(FCollectionPicture);
  CollectionEvents.UnRegisterChangesID(Self, ChangedDBDataByID);
  inherited;
end;

procedure TDatabaseInfoControl.DoAlignInfo;
var
  L: Integer;
  ShowLoadingSign: Boolean;
begin
  FMinimized := Height < 36;

  ShowLoadingSign := not FMediaCountReady or FIsUpdatingCollection;

  DisableAlign;
  try

    FDatabaseName.Text := FInfo.Title;
    FDatabaseName.RefreshBuffer(True);
    FInfoLabel.Caption := '';

    FImage.Height := Height - 2;
    FImage.Width := FImage.Height;

    LoadColectionImage;
    if not FMinimized then
    begin
      FDatabaseName.Left := FImage.Left + FImage.Width + 3;
      FDatabaseName.Top := Height div 2 - (FDatabaseName.Height + 2 + FLsMain.Height) div 2;

      if ShowLoadingSign then
      begin
        FLsMain.Left := FImage.Left + FImage.Width + 3;
        FLsMain.Top := FDatabaseName.Top + FDatabaseName.Height + 3;
        FLsMain.Visible := True;
      end else
      begin
        FLsMain.Left := FImage.Left + FImage.Width - FLsMain.Width;
        FLsMain.Visible := False;
      end;

      FInfoLabel.Visible := True;
      FInfoLabel.Top := FLsMain.Top + FLsMain.Height div 2 - FInfoLabel.Height div 2;
      FInfoLabel.Left := FLsMain.Left + FLsMain.Height + 3;
    end else
    begin
      FInfoLabel.Visible := False;
      FInfoLabel.Left := 0;

      if ShowLoadingSign then
      begin
        FLsMain.Left := FImage.Left + FImage.Width + 3;
        FLsMain.Top := Height div 2 - FLsMain.Height div 2;
        FLsMain.Visible := True;
      end else
      begin
        FLsMain.Left := FImage.Left + FImage.Width - FLsMain.Width;
        FLsMain.Visible := False;
      end;

      FDatabaseName.Left := FLsMain.Left + FLsMain.Width + 3;
      FDatabaseName.Top := Height div 2 - FDatabaseName.Height div 2;
    end;

    L := Max(FDatabaseName.Left + FDatabaseName.Width, FInfoLabel.Left + FInfoLabel.Width);
    FSeparator.Left := L + 3;
    FSeparator.Height := Height;

    FSelectImage.Left := FSeparator.Left + FSeparator.Width;
    FSelectImage.Height := Height;

    Width := FSelectImage.Width + FSelectImage.Left + 2;

    if not FMediaCountReady then
      LoadImagesCount
    else
      FInfoLabel.Caption := NumberToShortNumber(FMediaCount);

  finally
    EnableAlign;
  end;
end;

procedure TDatabaseInfoControl.DatabaseNameOnClick(Sender: TObject);
begin
  ShowDatabaseProperties;
end;

procedure TDatabaseInfoControl.ImageClick(Sender: TObject);
begin
  if FIsUpdatingCollection and (FCurrentFileName <> '') then
  begin
    Viewer.ShowImageInDirectoryEx(FCurrentFileName);
    Viewer.Show;
    Viewer.Restore;
  end else
    ShowDatabaseProperties;
end;

procedure TDatabaseInfoControl.LoadControl(Info: TDatabaseInfo);
var
  PNG: TPngImage;
begin
  F(FInfo);
  FInfo := TDatabaseInfo(Info.Clone);
  FMediaCountReady := False;
  FIsUpdatingCollection := True;

  DisableAlign;
  try
    if FImage = nil then
    begin
      FImage := TImage.Create(Self);
      FImage.Parent := Self;
      FImage.Top := 1;
      FImage.Left := 1;
      FImage.Center := True;
      FImage.Cursor := crHandPoint;
      FImage.OnClick := ImageClick;

      FDatabaseName := TWebLink.Create(Self);
      FDatabaseName.Parent := Self;
      FDatabaseName.IconWidth := 0;
      FDatabaseName.IconHeight := 0;
      FDatabaseName.Font.Size := 11;
      FDatabaseName.OnClick := DatabaseNameOnClick;

      FLsMain := TLoadingSign.Create(Self);
      FLsMain.Parent := Self;
      FLsMain.Width := 16;
      FLsMain.Height := 16;
      FLsMain.FillPercent := 50;
      FLsMain.Active := True;

      FInfoLabel := TLabel.Create(Self);
      FInfoLabel.Parent := Self;
      FInfoLabel.Caption := '';

      FSeparator := TBevel.Create(Self);
      FSeparator.Parent := Self;
      FSeparator.Width := 2;
      FSeparator.Top := 0;

      FSelectImage := TImage.Create(Self);
      FSelectImage.Parent := Self;
      PNG := GetNavigateDownImage;
      try
        FSelectImage.Picture.Graphic := PNG;
      finally
        F(PNG);
      end;
      FSelectImage.Width := 20;
      FSelectImage.Center := True;
      FSelectImage.Cursor := crHandPoint;
      FSelectImage.OnClick := SelectDatabaseClick;

      FCheckTimer := TTimer.Create(Self);
      FCheckTimer.Interval := 1000;
      FCheckTimer.Enabled := True;
      FCheckTimer.OnTimer := CheckTimerOnTimer;
    end;

    DoAlignInfo;
  finally
    EnableAlign;
  end;
end;

function TDatabaseInfoControl.L(StringToTranslate: string): string;
begin
  Result := TDBForm(Owner).L(StringToTranslate);
end;

procedure TDatabaseInfoControl.LoadColectionImage;
var
  IconFileName: string;
  LB: TLayeredBitmap;
  Ico: HIcon;
  IconSize: Integer;
  BigToolBar: Boolean;
begin
  IconFileName := FInfo.Icon;
  if IconFileName = '' then
    IconFileName := Application.ExeName + ',0';

  BigToolBar := not AppSettings.Readbool('Options', 'UseSmallToolBarButtons', False);

  IconSize := IIF(BigToolBar, 32, 16);

  Ico := ExtractSmallIconByPath(IconFileName, BigToolBar);
  try
    LB := TLayeredBitmap.Create;
    try
      LB.LoadFromHIcon(Ico, IconSize, IconSize);

      F(FCollectionPicture);
      Exchange(FCollectionPicture, LB);
    finally
      F(LB);
    end;
  finally
    DestroyIcon(Ico);
  end;

  FImage.Picture.Graphic := FCollectionPicture;
  FIsCustomImage := False;
end;

procedure TDatabaseInfoControl.LoadImagesCount;
begin
  TThreadTask<IDBContext>.Create(TThreadForm(Self.Owner), DBManager.DBContext, False,
    procedure(Thread: TThreadTask<IDBContext>; Data: IDBContext)
    var
      MediaRepository: IMediaRepository;
      MediaCount: Integer;
    begin
      CoInitialize(nil);
      try
        MediaRepository := Data.Media;
        MediaCount := MediaRepository.GetCount;
        Thread.SynchronizeTask(
          procedure
          begin
            FMediaCountReady := True;
            FMediaCount := MediaCount;
            DoAlignInfo;
          end
        );
      finally
        CoUninitialize;
      end;
    end
  );
end;

procedure TDatabaseInfoControl.SelectDatabaseClick(Sender: TObject);
begin
  if Assigned(FOnSelectClick) then
    FOnSelectClick(Self);
end;

procedure TDatabaseInfoControl.ShowDatabaseProperties;
var
  Editor: ILinkEditor;
begin
  Editor := TLinkListEditorDatabases.Create(TDBForm(Self.Owner));
  try
    if FormLinkItemEditor.Execute(L('Edit collection'), FInfo, Editor) then
      DBManager.UpdateUserCollection(FInfo, -1);

  finally
    Editor := nil;
  end;
end;

end.