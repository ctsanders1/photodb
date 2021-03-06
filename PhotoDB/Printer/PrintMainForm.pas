unit PrintMainForm;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Classes,
  System.Math,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Themes,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.ImgList,
  Vcl.Printers,
  Vcl.Imaging.jpeg,

  ScrollingImage,
  ScrollingImageAddons,
  UnitPrinterTypes,

  UnitDBFileDialogs,
  GraphicCrypt,
  Menus,
  EasyListview,
  MPCommonUtilities,
  MPCommonObjects,

  Dmitry.Utils.Files,
  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,
  Dmitry.Controls.SaveWindowPos,

  uCDMappingTypes,
  uConstants,
  uMemory,
  uDBForm,
  uVCLHelpers,
  uTranslate,
  uShellIntegration,
  uResources,
  uListViewUtils,
  uThemesUtils,
  uSettings,
  uProgramStatInfo,
  uFormInterfaces,
  uSessionPasswords;

type
  TPrintForm = class(TDBForm)
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    PageSetupDialog1: TPageSetupDialog;
    ToolsPanel: TPanel;
    BottomPanel: TPanel;
    OkButtonPanel: TPanel;
    BtnPrint: TButton;
    BtnCancel: TButton;
    RightPanel: TPanel;
    ImlFormatPreviews: TImageList;
    FastScrollingImage1: TFastScrollingImage;
    Panel1: TPanel;
    ScrollingImageNavigator1: TScrollingImageNavigator;
    ZoomInLink: TWebLink;
    ZoomOutLink: TWebLink;
    FullSizeLink: TWebLink;
    FitToSizeLink: TWebLink;
    Panel2: TPanel;
    BtnAddPrinter: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    CbPageNumber: TComboBox;
    StatusBar1: TStatusBar;
    Panel3: TPanel;
    EdWidth: TEdit;
    Label4: TLabel;
    ComboBox2: TComboBox;
    EdHeight: TEdit;
    CbUseCustomSize: TCheckBox;
    Label3: TLabel;
    CbCropImage: TCheckBox;
    RadioGroup1: TRadioGroup;
    TerminateTimes: TTimer;
    SaveWindowPos1: TSaveWindowPos;
    PmCopyToFile: TPopupActionBar;
    CopyToFile1: TMenuItem;
    ImCurrentFormat: TImage;
    Label5: TLabel;
    WlGeneratePreview: TWebLink;
    StHintText: TStaticText;
    LvMain: TEasyListview;
    procedure BtnAddPrinterClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ALvMainDblClick(Sender: TObject);
    procedure FullSizeLinkClick(Sender: TObject);
    procedure ZoomOutLinkClick(Sender: TObject);
    procedure ZoomInLinkClick(Sender: TObject);
    procedure FitToSizeLinkClick(Sender: TObject);
    procedure BtnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CbPageNumberClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TerminateTimesTimer(Sender: TObject);
    procedure PmCopyToFilePopup(Sender: TObject);
    procedure CopyToFile1Click(Sender: TObject);
    procedure CbUseCustomSizeClick(Sender: TObject);
    procedure ComboBox2KeyPress(Sender: TObject; var Key: Char);
    procedure EdWidthExit(Sender: TObject);
    procedure EdHeightExit(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FastScrollingImage1Resize(Sender: TObject);
    procedure LvMainDblClick(Sender: TCustomEasyListview;
      Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState;
      var Handled: Boolean);
  private
    { Private declarations }
    PreviewSID: string;
    FFiles: TStrings;
    CountPerPage: Integer;
    Pages: Integer;
    FCurrentFormat: TPrintSampleSizeOne;
    VirtualBitmap: TBitmap;
    function FormatToText(FormatIndex: TPrintSampleSizeOne): string;
    procedure DoGenerateSample;
    procedure AddSampleImage(SampleImageType: TPrintSampleSizeOne);
    procedure SetPreviewImage(Bitmap: TBitmap; SID : String);
    function GetSampleType : TPrintSampleSizeOne;
    procedure LoadLanguage;
    function SizeToPixels(Pixels: TXSize): TXSize;
    function PixelsToSize(Pixels: TXSize): TXSize;
  protected
    { Protected declarations }
    function GetFormID: string; override;
  public
    { Public declarations }
    FStatusProgress: TProgressBar;
    procedure Execute(PrintFiles: TStrings); overload;
    procedure Execute(var VirtualFile: TBitmap); overload;
  end;

function GetPrintForm(Files: TStrings): TPrintForm; overload;
function GetPrintForm(var Picture: TBitmap): TPrintForm; overload;

implementation

uses
  UnitGeneratorPrinterPreview,
  PrinterProgress;

{$R *.dfm}

function GetPrintForm(Files: TStrings) : TPrintForm;
var
  Form: TCustomForm;
  Handle: THandle;
  I: Integer;
begin
  Result := nil;
  try
    Application.CreateForm(TPrintForm, Result);
    for I := 0 to Files.Count - 1 do
      Files[I] := ProcessPath(Files[I]);
    Result.Execute(Files);
  except
    on E: Exception do
    begin
      Form := Screen.ActiveForm;
      if Form = nil then
        Form := Application.MainForm;
      Handle := 0;
      if Form <> nil then
        Handle := Form.Handle;
      MessageBoxDB(Handle, Format(TA('Unable to open printer form: %s', 'Printer'), [E.message]), TA('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
    end;
  end;
end;

function GetPrintForm(var Picture: TBitmap): TPrintForm;
begin
  Result := nil;
  if Picture.Empty then
    Exit;
  Application.CreateForm(TPrintForm, Result);
  Result.Execute(Picture);
  Picture := nil;
end;

function TPrintForm.FormatToText(FormatIndex: TPrintSampleSizeOne): string;
begin
  Result := '';
  case FormatIndex of
    TPSS_FullSize:
      Result := L('Full size');
    TPSS_C35:
      Result := L('35 photos on page');
    TPSS_20X25C1:
      Result := L('20x25 sm. 1 photo');
    TPSS_13X18C1:
      Result := L('13x18 sm. 1 photo');
    TPSS_13X18C2:
      Result := L('13x18 sm. 2 photos');
    TPSS_10X15C1:
      Result := L('10x15 sm. 1 photo');
    TPSS_10X15C2:
      Result := L('10x15 sm. 2 photos');
    TPSS_10X15C3:
      Result := L('10x15 sm. 3 photos');
    TPSS_9X13C1:
      Result := L('9x13 sm. 1 photo');
    TPSS_9X13C2:
      Result := L('9x13 sm. 2 photos');
    TPSS_9X13C4:
      Result := L('9x13 sm. 4 photos');
    TPSS_C9:
      Result := L('9 photos on page');
    TPSS_4X6C4:
      Result := L('4x6 sm. 1 photo in 4 copies');
    TPSS_3X4C6:
      Result := L('3x4 sm. 1 photo in 6 copies');
  end;
end;

procedure TPrintForm.AddSampleImage(SampleImageType: TPrintSampleSizeOne);
var
  NewImage: TBitmap;
  SampleImage: TBitmap;
  Item: TEasyItem;
  Options: TGenerateImageOptions;
  PrinterPattern: TJpegImage;
begin
  ImlFormatPreviews.Width := LvMain.Width - GetSystemMetrics(SM_CXVSCROLL) - 32;
  ImlFormatPreviews.Height := Round(ImlFormatPreviews.Width * Printer.PageHeight / Printer.PageWidth);
  LvMain.CellSizes.Thumbnail.Width := ImlFormatPreviews.Width + 30;
  LvMain.CellSizes.Thumbnail.Height := ImlFormatPreviews.Height + 40;
  SampleImage := TBitmap.Create;
  try
    SampleImage.PixelFormat := pf24bit;
    PrinterPattern := GetPrinterPatternImage;
    try
      SampleImage.Assign(PrinterPattern);
    finally
      F(PrinterPattern);
    end;
    Item := LvMain.Items.Add;
    Item.ImageIndex := -1;
    Item.Caption := FormatToText(SampleImageType);
    Options.CropImages := False;
    Options.FreeCenterSize := False;
    Options.VirtualImage := False;
    Options.Image := nil;
    NewImage := GenerateImage(False, ImlFormatPreviews.Width, ImlFormatPreviews.Height, SampleImage, nil, SampleImageType, Options);
    try
      ImlFormatPreviews.Add(NewImage, nil);
      Item.ImageIndex := ImlFormatPreviews.Count - 1;
      Item.Data := TObject(SampleImageType);
    finally
      F(NewImage);
    end;
  finally
    F(SampleImage);
  end;
end;

procedure TPrintForm.BtnAddPrinterClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'rundll32.exe' ,'shell32.dll,SHHelpShortcuts_RunDLL AddPrinter','', SW_SHOWNORMAL);
end;

procedure TPrintForm.Button2Click(Sender: TObject);
begin
  if PrinterSetupDialog1.Execute then
  begin
    DoGenerateSample;
    BtnPrint.Enabled := False;
    ImCurrentFormat.Picture.Graphic := nil;
  end;
end;

procedure TPrintForm.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TPrintForm.DoGenerateSample;
var
  PixInInch, PageSizeMm: TXSize;
  SamplePage: TBitmap;

  PaperSize: TPaperSize;
begin
  PixInInch := GetPixelsPerInch;
  PageSizeMm.Width := InchToCm(Printer.PageWidth * 10 / PixInInch.Width);
  PageSizeMm.Height := InchToCm(Printer.PageHeight * 10 / PixInInch.Height);
  SamplePage := TBitmap.Create;
  try
    SamplePage.PixelFormat := Pf24bit;
    SamplePage.Width := Printer.PageWidth;
    SamplePage.Height := Printer.PageHeight;
    PaperSize := GetPaperSize;
    LvMain.Items.Clear;

    case PaperSize of
      TPS_A4:
        begin
          AddSampleImage(TPSS_FullSize);
          if VirtualBitmap = nil then
            AddSampleImage(TPSS_C35);
        AddSampleImage(TPSS_20X25C1);
        if FFiles.Count > 1 then
          AddSampleImage(TPSS_13X18C2);
        AddSampleImage(TPSS_13X18C1);
        AddSampleImage(TPSS_10X15C1);
        if FFiles.Count > 1 then
          AddSampleImage(TPSS_10X15C2);
        if FFiles.Count > 2 then
          AddSampleImage(TPSS_10X15C3);
        AddSampleImage(TPSS_9X13C1);
        if FFiles.Count > 1 then
          AddSampleImage(TPSS_9X13C2);
        if FFiles.Count > 2 then
          AddSampleImage(TPSS_9X13C4);
        if VirtualBitmap = nil then
          AddSampleImage(TPSS_C9);
        AddSampleImage(TPSS_4X6C4);
        AddSampleImage(TPSS_3X4C6);
      end;

      TPS_B5:
        begin
          AddSampleImage(TPSS_FullSize);
          AddSampleImage(TPSS_13X18C1);
          if FFiles.Count > 1 then
            AddSampleImage(TPSS_13X18C2);
          AddSampleImage(TPSS_10X15C1);
          if FFiles.Count > 1 then
            AddSampleImage(TPSS_10X15C2);
          AddSampleImage(TPSS_9X13C1);
          if FFiles.Count > 1 then
            AddSampleImage(TPSS_9X13C2);
          if VirtualBitmap = nil then
            AddSampleImage(TPSS_C9);
          AddSampleImage(TPSS_4X6C4);
          AddSampleImage(TPSS_3X4C6);
        end;

      TPS_CAN13X18:
        begin
          AddSampleImage(TPSS_FullSize);
          AddSampleImage(TPSS_13X18C1);
          AddSampleImage(TPSS_10X15C1);
          AddSampleImage(TPSS_9X13C1);
          AddSampleImage(TPSS_4X6C4);
          AddSampleImage(TPSS_3X4C6);
        end;

      TPS_CAN10X15:
        begin
          AddSampleImage(TPSS_FullSize);
          AddSampleImage(TPSS_10X15C1);
          AddSampleImage(TPSS_9X13C1);
        end;

      TPS_CAN9X13:
        begin
          AddSampleImage(TPSS_FullSize);
          AddSampleImage(TPSS_9X13C1);
        end;

      TPS_OTHER:
        begin
          AddSampleImage(TPSS_FullSize);
        end;
    end;

  finally
    F(SamplePage);
  end;
end;

procedure TPrintForm.FormCreate(Sender: TObject);
var
  Ico: TIcon;
begin
  LoadLanguage;

  SetLVSelection(LvMain, False, [cmbLeft]);

  if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
    LvMain.ShowThemedBorder := False;

  FastScrollingImage1.Color := Theme.WindowColor;

  FFiles := TStringList.Create;
  LvMain.DoubleBuffered := True;
  VirtualBitmap := nil;

  FStatusProgress := StatusBar1.CreateProgressBar(0);
  FStatusProgress.Hide;

  Ico := TIcon.Create;
  try
    Ico.Handle := LoadIcon(HInstance, 'DOIT');
    WlGeneratePreview.Icon := Ico;
  finally
    F(Ico);
  end;
  SaveWindowPos1.Key := RegRoot + 'PrintForm';
  SaveWindowPos1.SetPosition;
end;

procedure TPrintForm.ALvMainDblClick(Sender: TObject);
var
  Item: TEasyItem;
  SampleType: TPrintSampleSizeOne;
  Files: TStrings;
  I, Incr: Integer;
  Bitmap: TBitmap;
  Options: TGenerateImageOptions;
begin

  Item := LvMain.Selection.First;
  if Item = nil then
    Item := LvMain.Items[0];
  SampleType := TPrintSampleSizeOne(Item.Data);
  PreviewSID := GetCID;
  StHintText.Hide;
  Bitmap := TBitmap.Create;
  try
    ImlFormatPreviews.GetBitmap(Item.ImageIndex, Bitmap);
    ImCurrentFormat.Picture.Graphic := Bitmap;
    ImCurrentFormat.Repaint;
  finally
    F(Bitmap);
  end;
  FCurrentFormat := SampleType;

  Caption := L('Print photos') + '  [' + FormatToText(SampleType) + ']';

  case SampleType of
    TPSS_FullSize:
      CountPerPage := 1;
    TPSS_C35:
      CountPerPage := 35;
    TPSS_20X25C1:
      CountPerPage := 1;
    TPSS_13X18C1:
      CountPerPage := 1;
    TPSS_13X18C2:
      CountPerPage := 2;
    TPSS_10X15C1:
      CountPerPage := 1;
    TPSS_10X15C2:
      CountPerPage := 2;
    TPSS_10X15C3:
      CountPerPage := 3;
    TPSS_9X13C1:
      CountPerPage := 1;
    TPSS_9X13C2:
      CountPerPage := 2;
    TPSS_9X13C4:
      CountPerPage := 4;
    TPSS_C9:
      CountPerPage := 9;
    TPSS_4X6C4:
      CountPerPage := 1;
    TPSS_3X4C6:
      CountPerPage := 1;
  end;
  if CbUseCustomSize.Checked then
    CountPerPage := 1;

  Files := TStringList.Create;
  try
    Pages := (FFiles.Count div CountPerPage);
    if (FFiles.Count - Pages * CountPerPage) > 0 then
      Inc(Pages);
    CbPageNumber.Text := '1';
    CbPageNumber.Items.Clear;
    for I := 1 to Pages do
      CbPageNumber.Items.Add(IntToStr(I));

    Incr := StrToIntDef(CbPageNumber.Text, 1);
    Incr := Min(Pages, Incr);
    Incr := Max(1, Incr);
    Incr := (Incr - 1) * CountPerPage;
    for I := 1 to CountPerPage do
      if FFiles.Count >= I + Incr then
        Files.Add(FFiles[I + Incr - 1]);
    if (Files.Count = 0) and (VirtualBitmap = nil) then
      Exit;

    Options.CropImages := CbCropImage.Checked;
    Options.FreeCenterSize := CbUseCustomSize.Checked;
    Options.FreeWidthPx := Round(SizeToPixels(XSize(StrToFloatDef(EdWidth.Text, 1), 0)).Width);
    Options.FreeHeightPx := Round(SizeToPixels(XSize(0, StrToFloatDef(EdHeight.Text, 1))).Height);
    if Options.FreeCenterSize then
      SampleType := TPSS_CUSTOM;

    TGeneratorPrinterPreview.Create(False, Self, PreviewSID, SampleType, Files, SetPreviewImage, False, Options, 0,
      VirtualBitmap <> nil, VirtualBitmap, False);

  finally
    F(Files);
  end;
  Button2.Enabled := False;
  BtnCancel.Enabled := False;
  BtnPrint.Enabled := False;
  LvMain.Enabled := False;
  CbPageNumber.Enabled := False;
  ZoomInLink.Enabled := False;
  ZoomOutLink.Enabled := False;
  WlGeneratePreview.Enabled := False;
  FitToSizeLink.Enabled := False;
  FullSizeLink.Enabled := False;
  ZoomInLink.SetDefault;
  ZoomOutLink.SetDefault;
  FitToSizeLink.SetDefault;
  FullSizeLink.SetDefault;
end;

procedure TPrintForm.SetPreviewImage(Bitmap: TBitmap; SID: String);
begin
  if PreviewSID = SID then
  begin
    FastScrollingImage1.Picture := Bitmap;

    FastScrollingImage1.AutoZoomImage := True;
    FastScrollingImage1.AutoShrinkImage := True;

    FastScrollingImage1.Resize;
    Bitmap.Free;
    Button2.Enabled := True;
    BtnCancel.Enabled := True;
    if not CbUseCustomSize.Checked then
      LvMain.Enabled := True;
    RadioGroup1.Enabled := True;
    CbPageNumber.Enabled := True;
    BtnPrint.Enabled := True;
    ZoomInLink.Enabled := True;
    ZoomOutLink.Enabled := True;
    FitToSizeLink.Enabled := True;
    FullSizeLink.Enabled := True;
    WlGeneratePreview.Enabled := True;
    ZoomInLink.SetDefault;
    ZoomOutLink.SetDefault;
    FitToSizeLink.SetDefault;
    FullSizeLink.SetDefault;
  end;
end;

procedure TPrintForm.FullSizeLinkClick(Sender: TObject);
begin
  FastScrollingImage1.AutoZoomImage := False;
  FastScrollingImage1.AutoShrinkImage := False;
  FastScrollingImage1.Zoom := 100;
  FastScrollingImage1.Resize;
end;

procedure TPrintForm.ZoomOutLinkClick(Sender: TObject);
begin
  FastScrollingImage1.AutoZoomImage := False;
  FastScrollingImage1.AutoShrinkImage := False;
  FastScrollingImage1.Zoom := FastScrollingImage1.Zoom / 1.2;
end;

procedure TPrintForm.ZoomInLinkClick(Sender: TObject);
begin
  FastScrollingImage1.AutoZoomImage := False;
  FastScrollingImage1.AutoShrinkImage := False;
  FastScrollingImage1.Zoom := FastScrollingImage1.Zoom * 1.2;
end;

procedure TPrintForm.FitToSizeLinkClick(Sender: TObject);
begin
  FastScrollingImage1.AutoZoomImage := True;
  FastScrollingImage1.AutoShrinkImage := True;
  FastScrollingImage1.Resize;
end;

procedure TPrintForm.BtnPrintClick(Sender: TObject);
var
  Options: TGenerateImageOptions;
begin
  //statistics
  ProgramStatistics.PrinterUsed;

  if RadioGroup1.ItemIndex = 0 then
  begin
    Printer.BeginDoc;
    Printer.Canvas.Draw(0, 0, FastScrollingImage1.Picture);
    Printer.EndDoc;
    Close;
  end else
  begin
    Options.CropImages := CbCropImage.Checked;
    Options.FreeCenterSize := CbUseCustomSize.Checked;
    TGeneratorPrinterPreview.Create(False, Self, PreviewSID, GetSampleType, FFiles, SetPreviewImage, True, Options,
      CountPerPage, VirtualBitmap <> nil, VirtualBitmap, True);
    VirtualBitmap := nil;
    Close;
  end;
end;

procedure TPrintForm.Execute(PrintFiles: TStrings);
var
  I: Integer;
begin
  VirtualBitmap := nil;
  FFiles.Assign(PrintFiles);

  for I := FFiles.Count - 1 downto 0 do
    if ValidCryptGraphicFile(FFiles[I]) then
      if SessionPasswords.FindForFile(FFiles[I]) = '' then
        FFiles.Delete(I);

  if FFiles.Count = 0 then
  begin
    Close;
    Exit;
  end;
  DoGenerateSample;
  ShowModal;
end;

procedure TPrintForm.FormDestroy(Sender: TObject);
begin
  F(VirtualBitmap);
  F(FFiles);
  SaveWindowPos1.SavePosition;
end;

procedure TPrintForm.CbPageNumberClick(Sender: TObject);
var
  Files: TStrings;
  I, Incr: Integer;
  SampleType: TPrintSampleSizeOne;
  Options: TGenerateImageOptions;
begin
  SampleType := GetSampleType;
  PreviewSID := GetCID;
  Files := TStringList.Create;
  try
    Incr := StrToIntDef(CbPageNumber.Text, 1);
    Incr := Min(Pages, Incr);
    Incr := Max(1, Incr);
    Incr := (Incr - 1) * CountPerPage;
    for I := 1 to CountPerPage do
      if FFiles.Count >= I + Incr then
        Files.Add(FFiles[I + Incr - 1]);

    if Files.Count = 0 then
      Exit;
    Options.CropImages := CbCropImage.Checked;
    Options.FreeCenterSize := CbUseCustomSize.Checked;
    Options.FreeWidthPx := Round(SizeToPixels(XSize(StrToFloatDef(EdWidth.Text, 1), 0)).Width);
    Options.FreeHeightPx := Round(SizeToPixels(XSize(0, StrToFloatDef(EdHeight.Text, 1))).Height);
    if Options.FreeCenterSize then
      SampleType := TPSS_CUSTOM;
    TGeneratorPrinterPreview.Create(False, Self, PreviewSID, SampleType, Files, SetPreviewImage, False, Options, 0,
      VirtualBitmap <> nil, VirtualBitmap, False);

  finally
    F(Files);
  end;
  LvMain.Enabled := False;
  CbPageNumber.Enabled := False;
  ZoomInLink.Enabled := False;
  ZoomOutLink.Enabled := False;
  FitToSizeLink.Enabled := False;
  FullSizeLink.Enabled := False;
  ZoomInLink.SetDefault;
  ZoomOutLink.SetDefault;
  FitToSizeLink.SetDefault;
  FullSizeLink.SetDefault;
end;

procedure TPrintForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TerminateTimes.Enabled := True;
end;

procedure TPrintForm.TerminateTimesTimer(Sender: TObject);
begin
  TerminateTimes.Enabled := False;
  Release;
end;

function TPrintForm.GetFormID: string;
begin
  Result := 'Printer';
end;

function TPrintForm.GetSampleType: TPrintSampleSizeOne;
begin
  Result := FCurrentFormat;
end;

procedure TPrintForm.PmCopyToFilePopup(Sender: TObject);
begin
  CopyToFile1.Visible := BtnPrint.Enabled;
end;

procedure TPrintForm.CopyToFile1Click(Sender: TObject);
var
  Image: TGraphic;
  SavePictureDialog: DBSavePictureDialog;
  FileName: string;
begin
  SavePictureDialog := DBSavePictureDialog.Create;
  try
    SavePictureDialog.Filter := 'JPEG Image File (*.jpg;*.jpeg)|*.jpg;*.jpeg|Bitmaps (*.bmp)|*.bmp';
    SavePictureDialog.FilterIndex := 1;
    if SavePictureDialog.Execute then
    begin
      FileName := SavePictureDialog.FileName;
      case SavePictureDialog.GetFilterIndex of
        1:
          begin
            JpegOptionsForm.Execute;
            if (GetExt(FileName) <> 'JPG') and (GetExt(FileName) <> 'JPEG') then
              FileName := FileName + '.jpg';
            if FileExistsSafe(FileName) then
              if ID_OK <> MessageBoxDB(Handle, Format(L('File "%s" already exists! Do you want to replace it?'), [FileName]), L('Warning'),
                TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
                Exit;
            Image := TJPEGImage.Create;
            try
              Image.Assign(FastScrollingImage1.Picture);
              (Image as TJPEGImage).ProgressiveEncoding := True;
              (Image as TJPEGImage).CompressionQuality := AppSettings.ReadInteger('', 'JPEGCompression', 75);
              (Image as TJPEGImage).ProgressiveEncoding := AppSettings.ReadBool('', 'JPEGProgressiveMode', False);
              Image.SaveToFile(FileName);
            finally
              F(Image);
            end;
          end;
        2:
          begin
            if (GetExt(FileName) <> 'BMP') then
              FileName := FileName + '.bmp';
            if ID_OK <> MessageBoxDB(Handle, Format(L('File "%s" already exists! Do you want to replace it?'), [FileName]), L('Warning'),
              TD_BUTTON_OKCANCEL, TD_ICON_WARNING) then
              Exit;
            Image := TBitmap.Create;
            try
              Image.Assign(FastScrollingImage1.Picture);
              Image.SaveToFile(FileName);
            finally
              F(Image);
            end;
          end;
      end;
    end;
  finally
    F(SavePictureDialog);
  end;
end;

procedure TPrintForm.LoadLanguage;
begin
  BeginTranslate;
  try
    BtnAddPrinter.Caption := L('Add printer');
    Button2.Caption := L('Printer setup');
    ZoomOutLink.Text := L('Zoom out');
    ZoomInLink.Text := L('Zoom in');
    FullSizeLink.Text := L('Full size');
    FitToSizeLink.Text := L('Fit to window');
    BtnCancel.Caption := L('Close');
    BtnPrint.Caption := L('Print');
    Caption := L('Print photos');
    Label5.Caption := L('Current format') + ':';
    RadioGroup1.Caption := L('Print pages')+ ':';
    RadioGroup1.Items[0] := L('Only this page');
    RadioGroup1.Items[1] := L('All pages');
    CopyToFile1.Caption := L('Copy to file');
    CbCropImage.Caption := L('Crop photos');
    CbUseCustomSize.Caption := L('Use custom size');
    Label3.Caption := L('Custom size') + ':';
    Label2.Caption := L('Page') + ':';
    Label1.Caption := L('Print layouts') + ':';
    WlGeneratePreview.Text := L('Generate preview');
    StHintText.Caption := L('Choose a format to print the list on the left and double-click on the selected format');
  finally
    EndTranslate;
  end;
end;

procedure TPrintForm.LvMainDblClick(Sender: TCustomEasyListview;
  Button: TCommonMouseButton; MousePos: TPoint; ShiftState: TShiftState;
  var Handled: Boolean);
begin
  ALvMainDblClick(Sender);
end;

procedure TPrintForm.CbUseCustomSizeClick(Sender: TObject);
begin
  EdWidth.Enabled := CbUseCustomSize.Checked;
  EdHeight.Enabled := CbUseCustomSize.Checked;
  ComboBox2.Enabled := CbUseCustomSize.Checked;
  LvMain.Enabled := not CbUseCustomSize.Checked;
end;

procedure TPrintForm.Execute(var VirtualFile: TBitmap);
begin
  FFiles.Clear;
  Pointer(VirtualBitmap) := Pointer(VirtualFile);
  DoGenerateSample;
  ShowModal;
end;

function TPrintForm.SizeToPixels(Pixels: TXSize): TXSize;
begin
  if AnsiLowerCase(ComboBox2.Text) = 'px' then
    Result := Pixels;
  if AnsiLowerCase(ComboBox2.Text) = 'mm' then
    Result := MmToPix(XSize(Pixels.Width, Pixels.Height));
  if AnsiLowerCase(ComboBox2.Text) = 'sm' then
    Result := MmToPix(XSize(Pixels.Width * 10, Pixels.Height * 10));
  if AnsiLowerCase(ComboBox2.Text) = 'in' then
    Result := MmToPix(XSize(InchToCm(Pixels.Width) * 10, InchToCm(Pixels.Height) * 10));
  if Result.Width > Printer.PageWidth then
    Result.Width := Printer.PageWidth;
  if Result.Height > Printer.PageHeight then
    Result.Height := Printer.PageHeight;
end;

procedure TPrintForm.ComboBox2KeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;

function TPrintForm.PixelsToSize(Pixels: TXSize): TXSize;
begin
  if AnsiLowerCase(ComboBox2.Text) = 'px' then
    Result := Pixels;
  if AnsiLowerCase(ComboBox2.Text) = 'mm' then
    Result := PixToSm(XSize(Pixels.Width * 10, Pixels.Height * 10));
  if AnsiLowerCase(ComboBox2.Text) = 'sm' then
    Result := PixToSm(Pixels);
  if AnsiLowerCase(ComboBox2.Text) = 'in' then
    Result := PixToIn(Pixels);
end;

function FloatToStrX(Value: Extended; Numbers : integer): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended,
    ffGeneral, Numbers, 0));
end;

procedure TPrintForm.EdWidthExit(Sender: TObject);
var
  Size: TXSize;
  Text: string;
begin
  if EdWidth.Tag = 1 then
    Exit;
  EdWidth.Tag := 1;
  Text := EdWidth.Text;
  if EdWidth.Text[Length(EdWidth.Text)] = FormatSettings.DecimalSeparator then
    Text := Text + '0';
  Size := SizeToPixels(XSize(StrToFloatDef(Text, 1), 0));
  Size := PixelsToSize(Size);
  EdWidth.Text := FloatToStrX(Size.Width, 4);
  EdWidth.Tag := 0;
end;

procedure TPrintForm.EdHeightExit(Sender: TObject);
var
  Size: TXSize;
  Text: string;
begin
  if EdHeight.Tag = 1 then
    Exit;
  EdHeight.Tag := 1;
  Text := EdHeight.Text;
  if EdHeight.Text[Length(EdHeight.Text)] = FormatSettings.DecimalSeparator then
    Text := Text + '0';
  Size := SizeToPixels(XSize(0, StrToFloatDef(Text, 1)));
  Size := PixelsToSize(Size);
  EdHeight.Text := FloatToStrX(Size.Height, 4);
  EdHeight.Tag := 0;
end;

procedure TPrintForm.ComboBox2Change(Sender: TObject);
begin
  EdWidthExit(Sender);
  EdHeightExit(Sender);
end;

procedure TPrintForm.FastScrollingImage1Resize(Sender: TObject);
begin
  StHintText.Left := ToolsPanel.Width + FastScrollingImage1.Width div 2 - StHintText.Width div 2;
  StHintText.Top := FastScrollingImage1.Height div 2 - StHintText.Height div 2;
end;

initialization

end.
