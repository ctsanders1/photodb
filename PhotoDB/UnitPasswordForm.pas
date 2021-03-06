unit UnitPasswordForm;

interface

uses
  System.UITypes,
  System.Types,
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Menus,
  Vcl.Clipbrd,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Data.DB,

  Dmitry.CRC32,
  Dmitry.Utils.System,
  Dmitry.Utils.Files,
  Dmitry.Controls.WatermarkedEdit,

  FormManegerUnit,
  GraphicCrypt,

  uConstants,
  uDBForm,
  uTranslate,
  uShellIntegration,
  uSettings,
  uMemory,
  uDatabaseDirectoriesUpdater,
  uFormInterfaces,
  uSessionPasswords;

type
  PasswordType = Integer;

const
  PASS_TYPE_IMAGE_FILE = 0;
  PASS_TYPE_IMAGE_BLOB = 1;
  PASS_TYPE_IMAGE_STENO = 2;
  PASS_TYPE_IMAGES_CRC = 3;

type
  TPassWordForm = class(TDBForm, IRequestPasswordForm)
    LbTitle: TLabel;
    BtCancel: TButton;
    BtOk: TButton;
    CbSavePassToSession: TCheckBox;
    CbSavePassPermanent: TCheckBox;
    CbDoNotAskAgain: TCheckBox;
    BtCancelForFiles: TButton;
    InfoListBox: TListBox;
    BtHideDetails: TButton;
    PmCopyFileList: TPopupActionBar;
    CopyText1: TMenuItem;
    LbInfo: TLabel;
    PmCloseAction: TPopupActionBar;
    CloseDialog1: TMenuItem;
    Skipthisfiles1: TMenuItem;
    EdPassword: TWatermarkedEdit;
    procedure FormCreate(Sender: TObject);
    procedure LoadLanguage;
    procedure BtOkClick(Sender: TObject);
    procedure EdPasswordKeyPress(Sender: TObject; var Key: Char);
    procedure BtCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure CopyText1Click(Sender: TObject);
    procedure BtCancelForFilesClick(Sender: TObject);
    procedure CloseDialog1Click(Sender: TObject);
    procedure Skipthisfiles1Click(Sender: TObject);
    procedure BtHideDetailsClick(Sender: TObject);
    procedure InfoListBoxMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure InfoListBoxDrawItem(Control: TWinControl; Index: Integer;
      aRect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FFileName: string;
    FPassword: string;
    DB: TField;
    UseAsk: Boolean;
    FCRC: Cardinal;
    FOpenedList: Boolean;
    DialogType: PasswordType;
    FSkip: Boolean;
    PassIcon: TIcon;
  protected
    function GetFormID : string; override;
    procedure LoadFileList(FileList: TStrings);
    procedure ReallignControlsEx;
    property Password: string read FPassword write FPassword;
    procedure CustomFormAfterDisplay; override;
    procedure InterfaceDestroyed; override;
  public
    { Public declarations }
    function ForImage(FileName: string): string;
    function ForImageEx(FileName: string; out AskAgain: Boolean): string;
    function ForBlob(DF: TField; FileName: string): string;
    function ForSteganoraphyFile(FileName: string; CRC: Cardinal) : string;
    function ForManyFiles(FileList: TStrings; CRC: Cardinal; var Skip: Boolean): string;
  end;

implementation

{$R *.dfm}

function TPassWordForm.ForImage(FileName: string): string;
begin
  FFileName := FileName;
  DB := nil;
  LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  UseAsk := False;
  DialogType := PASS_TYPE_IMAGE_FILE;
  ReallignControlsEx;
  ShowModal;
  Result := Password;
end;

function TPassWordForm.ForImageEx(FileName: string;
  out AskAgain: Boolean): string;
begin
  FFileName := FileName;
  DB := nil;
  UseAsk := True;
  DialogType := PASS_TYPE_IMAGE_FILE;
  ReallignControlsEx;
  LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  ShowModal;
  AskAgain := not CbDoNotAskAgain.Checked;
  Result := Password;
end;

function TPassWordForm.ForBlob(DF: TField; FileName: string): string;
begin
  FFileName := '';
  DB := DF;
  UseAsk := False;
  DialogType := PASS_TYPE_IMAGE_BLOB;
  ReallignControlsEx;
  LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  ShowModal;
  Result := Password;
end;

function TPassWordForm.ForManyFiles(FileList: TStrings; CRC: Cardinal;
  var Skip: Boolean): string;
begin
  FFileName := '';
  DB := nil;
  LbTitle.Caption := TA('Enter password for group of files (press "Show files" to see list) here:', 'Password');
  FCRC := CRC;
  DialogType := PASS_TYPE_IMAGES_CRC;
  UseAsk := False;
  ReallignControlsEx;
  LoadFileList(FileList);
  FSkip := Skip;
  ShowModal;
  Skip := FSkip;
  Result := Password;
end;

function TPassWordForm.ForSteganoraphyFile(FileName: string;
  CRC: Cardinal): string;
begin
  FFileName := FileName;
  DB := nil;
  UseAsk := False;
  FCRC := CRC;
  DialogType := PASS_TYPE_IMAGE_STENO;
  ReallignControlsEx;
  LbTitle.Caption := Format(TA('Enter password to file "%s" here:', 'Password'), [Mince(FileName, 30)]);
  ShowModal;
  Result := Password;
end;

procedure TPassWordForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TPassWordForm.FormCreate(Sender: TObject);
begin
  FOpenedList := False;
  ClientHeight := BtOk.Top + BtOk.Height + 5;
  CbSavePassToSession.Checked := AppSettings.Readbool('Options', 'AutoSaveSessionPasswords', True);
  CbSavePassPermanent.Checked := AppSettings.Readbool('Options', 'AutoSaveINIPasswords', False);
  LoadLanguage;
  Password := '';
  PassIcon := TIcon.Create;
  PassIcon.Handle := LoadIcon(HInstance, PWideChar('PASSWORD'));
end;

procedure TPassWordForm.FormDestroy(Sender: TObject);
begin
  F(PassIcon);
end;

procedure TPassWordForm.LoadLanguage;
begin
  BeginTranslate;
  try
    EdPassword.WatermarkText := L('Enter your password here');
    Caption := L('Password is required');
    LbTitle.Caption := L('Enter password to open file "%s" here:');
    BtCancel.Caption := L('Cancel');
    BtOk.Caption := L('OK');
    CbSavePassToSession.Caption := L('Save password for session');
    CbSavePassPermanent.Caption := L('Save password in settings');
    CbDoNotAskAgain.Caption := L('Don''t ask again');
    BtCancelForFiles.Caption := L('Show files');
    LbInfo.Caption := L('These files have the same password (hashes are equals)');
    CloseDialog1.Caption := L('Close');
    Skipthisfiles1.Caption := L('Skip these files');
    BtHideDetails.Caption := L('Hide list');
    CopyText1.Caption := L('Copy text');
  finally
    EndTranslate;
  end;
end;

procedure TPassWordForm.BtOkClick(Sender: TObject);

  function TEST: Boolean;
  var
    Crc, Crc2: Cardinal;
  begin
    Result := False;
    if (DialogType = PASS_TYPE_IMAGE_STENO) or (DialogType = PASS_TYPE_IMAGES_CRC) then
    begin
      //unicode password
      CalcStringCRC32(EdPassword.Text, Crc);
      //old-style pasword
      CalcAnsiStringCRC32(AnsiString(EdPassword.Text), Crc2);
      Result := (Crc = FCRC) or (Crc2 = FCRC);
      Exit;
    end;
    if FFileName <> '' then
      Result := ValidPassInCryptGraphicFile(FFileName, EdPassword.Text);
    if DB <> nil then
      Result := ValidPassInCryptBlobStreamJPG(DB, EdPassword.Text);
  end;

begin
  if TEST then
  begin
    Password := EdPassword.Text;
    if CbSavePassToSession.Checked then
      SessionPasswords.AddForSession(Password);
    if CbSavePassPermanent.Checked then
      SessionPasswords.SaveInSettings(Password);

    if CbSavePassToSession.Checked or CbSavePassPermanent.Checked then
      RecheckDirectoryOnDrive(ExtractFilePath(FFileName));

    Close;
  end else
    MessageBoxDB(Handle, L('Password is invalid!'), L('Error'), TD_BUTTON_OK, TD_ICON_ERROR);
end;

procedure TPassWordForm.EdPasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    if ShiftKeyDown then
    begin
      SessionPasswords.AddForSession(EdPassword.Text);
      Exit;
    end;
    Key := #0;
    BtOkClick(Sender);
  end;
  if Key = Char(VK_ESCAPE) then
  begin
    Password := '';
    Close;
  end;
end;

procedure TPassWordForm.BtCancelClick(Sender: TObject);
var
  P: TPoint;
begin
  if (DialogType = PASS_TYPE_IMAGES_CRC) then
  begin
    P.X := BtCancel.Left;
    P.Y := BtCancel.Top + BtCancel.Height;
    P := ClientToScreen(P);
    PmCloseAction.Popup(P.X, P.Y);
  end else
  begin
    Password := '';
    Close;
  end;
end;

procedure TPassWordForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
  begin
    Password := '';
    Close;
  end;
end;

function TPassWordForm.GetFormID: string;
begin
  Result := 'Password';
end;

procedure TPassWordForm.ReallignControlsEx;
begin
  if not UseAsk then
  begin
    CbDoNotAskAgain.Visible := False;
    BtCancel.Top := CbSavePassPermanent.Top + CbSavePassPermanent.Height + 3;
    BtOk.Top := CbSavePassPermanent.Top + CbSavePassPermanent.Height + 3;
    CbSavePassToSession.Enabled := CbSavePassToSession.Enabled and not(DialogType = PASS_TYPE_IMAGE_STENO) and not
      (DialogType = PASS_TYPE_IMAGES_CRC);
    CbSavePassPermanent.Enabled := CbSavePassPermanent.Enabled and not(DialogType = PASS_TYPE_IMAGE_STENO);
    CbDoNotAskAgain.Enabled := CbDoNotAskAgain.Enabled and not(DialogType = PASS_TYPE_IMAGE_STENO);

    if (DialogType = PASS_TYPE_IMAGES_CRC) then
      CbSavePassToSession.Checked := True;
    if (DialogType = PASS_TYPE_IMAGES_CRC) then
    begin
      LbTitle.Height := 50;
      EdPassword.Top := LbTitle.Top + LbTitle.Height + 3;
      CbSavePassToSession.Top := EdPassword.Top + EdPassword.Height + 5;
      CbSavePassPermanent.Top := CbSavePassToSession.Top + CbSavePassToSession.Height + 3;
      CbDoNotAskAgain.Top := CbSavePassPermanent.Top; // +CbSavePassPermanent.Height+3; //invisible
      BtCancel.Top := CbDoNotAskAgain.Top + CbDoNotAskAgain.Height + 3;
      BtOk.Top := CbDoNotAskAgain.Top + CbDoNotAskAgain.Height + 3;
      BtCancelForFiles.Top := CbDoNotAskAgain.Top + CbDoNotAskAgain.Height + 3;
      LbInfo.Top := BtCancelForFiles.Top + BtCancelForFiles.Height + 3;
      InfoListBox.Top := LbInfo.Top + LbInfo.Height + 3;
    end;
    ClientHeight := BtOk.Top + BtOk.Height + 3;
  end;
end;

procedure TPassWordForm.CopyText1Click(Sender: TObject);
begin
  TextToClipboard(InfoListBox.Items.Text);
end;

procedure TPassWordForm.CustomFormAfterDisplay;
begin
  inherited;
  if EdPassword <> nil then
    EdPassword.Refresh;
end;

procedure TPassWordForm.LoadFileList(FileList: TStrings);
begin
  InfoListBox.Items.Assign(FileList);

  BtCancelForFiles.Visible := True;
  InfoListBox.Visible := True;
  LbInfo.Visible := True;
  BtHideDetails.Visible := True;
  CbSavePassToSession.Enabled := False;
  CbDoNotAskAgain.Enabled := True;
end;

procedure TPassWordForm.BtCancelForFilesClick(Sender: TObject);
begin
  if FOpenedList then
  begin
    FOpenedList := False;
    ClientHeight := BtCancelForFiles.Top + BtCancelForFiles.Height + 3;
    InfoListBox.Visible := False;
    BtHideDetails.Visible := False;
    LbInfo.Visible := False;
  end else
  begin
    FOpenedList := True;
    ClientHeight := BtHideDetails.Top + BtHideDetails.Height + 3;
    InfoListBox.Visible := True;
    BtHideDetails.Visible := True;
    LbInfo.Visible := True;
  end;
end;

procedure TPassWordForm.CloseDialog1Click(Sender: TObject);
begin
  Password := '';
  Close;
end;

procedure TPassWordForm.Skipthisfiles1Click(Sender: TObject);
begin
  Password := '';
  FSkip := True;
  Close;
end;

procedure TPassWordForm.BtHideDetailsClick(Sender: TObject);
begin
  FOpenedList := False;
  ClientHeight := BtCancelForFiles.Top + BtCancelForFiles.Height + 3;
  InfoListBox.Visible := False;
  BtHideDetails.Visible := False;
  LbInfo.Visible := False;
end;

procedure TPassWordForm.InfoListBoxMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  Height := InfoListBox.Canvas.TextHeight('Iy') * 3 + 5;
end;

procedure TPassWordForm.InterfaceDestroyed;
begin
  inherited;
  Release;
end;

procedure TPassWordForm.InfoListBoxDrawItem(Control: TWinControl;
  Index: Integer; aRect: TRect; State: TOwnerDrawState);
var
  ListBox: TListBox;
begin
  ListBox := Control as TListBox;
  if OdSelected in State then
  begin
    ListBox.Canvas.Brush.Color := Theme.HighlightColor;
    ListBox.Canvas.Font.Color := Theme.HighlightTextColor;
  end else
  begin
    ListBox.Canvas.Brush.Color := Theme.ListColor;
    ListBox.Canvas.Font.Color := Theme.ListFontColor;
  end;
  // clearing rect
  ListBox.Canvas.Pen.Color := ListBox.Canvas.Brush.Color;
  ListBox.Canvas.Rectangle(ARect);

  ListBox.Canvas.Pen.Color := ClBlack;
  ListBox.Canvas.Font.Color := ClBlack;
  Text := ListBox.Items[index];

  DrawIconEx(ListBox.Canvas.Handle, ARect.Left, ARect.Top, PassIcon.Handle, 16, 16, 0, 0, DI_NORMAL);
  ARect.Left := ARect.Left + 20;
  DrawText(ListBox.Canvas.Handle, PWideChar(Text), Length(Text), ARect, DT_NOPREFIX + DT_LEFT + DT_WORDBREAK);

end;

initialization
  FormInterfaces.RegisterFormInterface(IRequestPasswordForm, TPassWordForm);

end.
