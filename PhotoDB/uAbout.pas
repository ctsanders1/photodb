unit uAbout;

interface

uses
  win32crc, UnitDBKernel, Searching, Windows, Messages, SysUtils,
  Variants, Classes, Graphics, Controls, Forms, ExtCtrls, StdCtrls,
  ImButton, Dialogs, jpeg, DmProgress, psAPI, uConstants, uTime,
  UnitDBCommonGraphics, uResources, pngimage, ComCtrls, WebLink, LoadingSign,
  uMemory, uTranslate, uRuntime, uActivationUtils, uDBForm,
  UnitInternetUpdate, uInternetUtils, ShellApi, Dolphin_DB;

type
  TAboutForm = class(TDBForm)
    ImageLogo: TImage;
    ImbClose: TImButton;
    BtShowActivationForm: TButton;
    MemoInfo: TRichEdit;
    MemoRegistrationInfo: TRichEdit;
    LsUpdates: TLoadingSign;
    LnkGoToWebSite: TWebLink;
    procedure ImbCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Grayscale(var Image : TBitmap);
    procedure Execute(Wait : boolean = false);
    procedure BtShowActivationFormClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure LnkGoToWebSiteGetBackGround(Sender: TObject; X, Y, W, H: Integer;
      Bitmap: TBitmap);
    procedure LnkGoToWebSiteClick(Sender: TObject);
  private
    { Private declarations }
    FBackground: TBitmap;
    FUpdateInfo: TUpdateInfo;
    procedure WMMouseDown(var s : Tmessage); message WM_LBUTTONDOWN;
    procedure LoadLanguage;
    procedure UpdateCkeckComplete(Sender : TObject; Info : TUpdateInfo);
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    procedure LoadRegistrationData;
  end;

procedure ShowAbout;

implementation

uses uActivation;

{$R *.dfm}

procedure ShowAbout;
var
  AboutForm : TAboutForm;
begin
  Application.CreateForm(TAboutForm, AboutForm);
  try
    AboutForm.Execute;
  finally
    R(AboutForm);
  end;
end;

{ TAboutForm }

function TAboutForm.GetFormID: string;
begin
  Result := 'About';
end;

procedure TAboutForm.GrayScale(var Image : TBitmap);
begin
  UnitDBCommonGraphics.GrayScale(Image);
end;

procedure TAboutForm.WMMouseDown(var s: TMessage);
begin
  Perform(WM_NCLBUTTONDOWN, HTCaption, s.lparam);
end;

procedure TAboutForm.ImbCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
var
  Logo : TPngImage;
begin
  LoadLanguage;
  LnkGoToWebSite.Left := LsUpdates.Left - LnkGoToWebSite.Width - 5;
  DoubleBuffered := True;
  MemoInfo.Brush.Style := BsClear;
  SetWindowLong(MemoInfo.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT);
  MemoRegistrationInfo.Brush.Style := BsClear;
  SetWindowLong(MemoRegistrationInfo.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT);

  FBackground := TBitmap.Create;
  Logo := GetLogoPicture;
  try
    FBackground.Assign(Logo);
    FBackground.PixelFormat := pf24bit;
    ImageLogo.Picture.Graphic := FBackground;
  finally
    F(Logo);
  end;

  BtShowActivationForm.Caption := L('Open activation form');
  if DBKernel <> nil then
    BtShowActivationForm.Visible := DBkernel.ProgramInDemoMode
  else
    BtShowActivationForm.Visible := False;

  MemoInfo.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Licenses\License' + TTranslateManager.Instance.Language + '.txt');

  FUpdateInfo.InfoAvaliable := False;
  TInternetUpdate.Create(Self, False, UpdateCkeckComplete);
end;

procedure TAboutForm.Execute;
begin
  if FolderView then
  begin
    BtShowActivationForm.Visible := False;
    MemoRegistrationInfo.Clear;
    MemoRegistrationInfo.Lines.Add(Format(L('Standalone database created using "%s". In this program many features are disabled and these features are available in the full version.'), [ProductName]));
    ShowModal;
    Exit;
  end;

  LoadRegistrationData;
  ShowModal;
end;

procedure TAboutForm.BtShowActivationFormClick(Sender: TObject);
begin
  ShowActivationDialog;
end;

procedure TAboutForm.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormDblClick(Sender: TObject);
begin
  if not FolderView then
    ShowActivationDialog;
end;

procedure TAboutForm.FormDestroy(Sender: TObject);
begin
  F(FBackground);
end;

procedure TAboutForm.LnkGoToWebSiteClick(Sender: TObject);
begin
  if FUpdateInfo.InfoAvaliable then
    ShellExecute(Handle, 'open', PChar(FUpdateInfo.UrlToDownload), nil, nil, SW_NORMAL)
  else
    ShellExecute(Handle, 'open', PChar(ResolveLanguageString(HomePageURL)), nil, nil, SW_NORMAL);
  Close;
end;

procedure TAboutForm.LnkGoToWebSiteGetBackGround(Sender: TObject; X, Y, W,
  H: Integer; Bitmap: TBitmap);
begin
  Bitmap.Width := W;
  Bitmap.Height := H;
  if FBackground <> nil then
    Bitmap.Canvas.CopyRect(Rect(0, 0, W, H), FBackground.Canvas, Rect(X, Y, X + W, Y + H));
end;

procedure TAboutForm.LoadLanguage;
begin
  BeginTranslate;
  try
    LnkGoToWebSite.Text := L('Checking updates...');
  finally
    EndTranslate;
  end;
end;

procedure TAboutForm.LoadRegistrationData;
var
  S, Code: string;
  N: Cardinal;
begin
  MemoRegistrationInfo.Clear;
  MemoRegistrationInfo.Lines.Add(L('Program code') + ':');
  S := GetIdeDiskSerialNumber;
  CalcStringCRC32(S, N);
  N := N xor $6357A302; // v2.2
  S := Inttohex(N, 8);
  CalcStringCRC32(S, N);
{$IFDEF ENGL}
  N := N xor $1459EF12;
{$ENDIF}
{$IFDEF RUS}
  N := N xor $762C90CA; // v2.2
{$ENDIF}
  Code := S + Inttohex(N, 8);
  MemoRegistrationInfo.Lines.Add(Code);
  MemoRegistrationInfo.Lines.Add('');
  MemoRegistrationInfo.Lines.Add(L('The program is registered to'));
  MemoRegistrationInfo.Lines.Add('');
  if DBkernel.ProgramInDemoMode then
    MemoRegistrationInfo.Lines.Add(L('This program isn''t activated.'))
  else
    MemoRegistrationInfo.Lines.Add(DBkernel.ReadRegName);
end;

procedure TAboutForm.UpdateCkeckComplete(Sender: TObject; Info: TUpdateInfo);
begin
  FUpdateInfo := Info;
  LsUpdates.Visible := False;
  if not Info.InfoAvaliable then
  begin
    LnkGoToWebSite.Text := L('Can not check updates!');
  end else
  begin
    LnkGoToWebSite.Text := Format(L('New version (%s) is avaliable!'), [ReleaseToString(Info.Release)]);
  end;
  LnkGoToWebSite.Left := LsUpdates.Left + LsUpdates.Width - LnkGoToWebSite.Width;
  LnkGoToWebSite.Refresh;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Close;
end;

end.
