unit UnitBigImagesSize;

interface

uses
  Windows,
  Messages,
  System.SysUtils,
  System.Math,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Dmitry.Controls.Base,
  Dmitry.Controls.WebLink,

  UnitDBDeclare,
  UnitDBCommon,

  uGraphicUtils,
  uDBForm,
  uDBIcons,
  uConstants;

type
  TBigImagesSizeForm = class(TDBForm)
    TrbImageSize: TTrackBar;
    Panel1: TPanel;
    RgPictureSize: TRadioGroup;
    LnkClose: TWebLink;
    TimerActivate: TTimer;
    procedure LnkCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RgPictureSizeClick(Sender: TObject);
    procedure TrbImageSizeChange(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure TimerActivateTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    LockChange : boolean;
    FCallBack: TCallBackBigSizeProc;
    FOwner: TForm;
    TimerActivated: Boolean;
    procedure LoadLanguage;
  protected
    function GetFormID : string; override;
  public
    { Public declarations }
    BigThSize: Integer;
    Destroying: Boolean;
    procedure Execute(AOwner: TForm; APictureSize: Integer; CallBack: TCallBackBigSizeProc);
    procedure SetRadioButtonSize;
  end;

var
  BigImagesSizeForm: TBigImagesSizeForm;

implementation

{$R *.dfm}

procedure TBigImagesSizeForm.LoadLanguage;
begin
  BeginTranslate;
  try
    Caption := L('Thumbnails size');
    RgPictureSize.Caption := L('Size') + ':';
    LnkClose.Text := L('Close');
    RgPictureSize.Items[0] := Format( L('%dx%d pixels'), [BigThSize,BigThSize]);
  finally
    EndTranslate;
  end;
end;

procedure TBigImagesSizeForm.LnkCloseClick(Sender: TObject);
begin
  if Destroying then
    Exit;
  Destroying := True;
  Release;
end;

procedure TBigImagesSizeForm.FormCreate(Sender: TObject);
begin
  FCallBack := nil;

  LnkClose.LoadFromHIcon(Icons[DB_IC_DELETE_INFO]);

  RgPictureSize.HandleNeeded;
  RgPictureSize.DoubleBuffered := True;
  RgPictureSize.Buttons[0].DoubleBuffered := True;

  TimerActivated := False;
  Destroying := False;
  LoadLanguage;
  LnkClose.LoadImage;
  LnkClose.Left := ClientWidth - TrbImageSize.Width - LnkClose.Width - 5;
  LockChange := False;
end;

procedure TBigImagesSizeForm.RgPictureSizeClick(Sender: TObject);
begin
  if LockChange or (not Assigned(FCallBack)) then
    Exit;

  case RgPictureSize.ItemIndex of
    0: BigThSize := TrbImageSize.Position * 10 + 40;
    1: BigThSize := 300;
    2: BigThSize := 250;
    3: BigThSize := 200;
    4: BigThSize := 150;
    5: BigThSize := 100;
    6: BigThSize := 85;
  end;

  FCallBack(Self, BigThSize, BigThSize);
  LockChange := True;
  TrbImageSize.Position := 50 - (BigThSize div 10 - 4);
  LockChange := False;
end;

procedure TBigImagesSizeForm.SetRadioButtonSize;
begin
  case BigThSize of
    85:  RgPictureSize.ItemIndex := 6;
    100: RgPictureSize.ItemIndex := 5;
    150: RgPictureSize.ItemIndex := 4;
    200: RgPictureSize.ItemIndex := 3;
    250: RgPictureSize.ItemIndex := 2;
    300: RgPictureSize.ItemIndex := 1;
  else
    RgPictureSize.ItemIndex := 0;
  end;
end;

procedure TBigImagesSizeForm.TrbImageSizeChange(Sender: TObject);
begin
  BeginScreenUpdate(RgPictureSize.Buttons[0].Handle);
  try
    if LockChange then
      Exit;

    LockChange := True;
    RgPictureSize.ItemIndex := 0;
    BigThSize := Max((50 - TrbImageSize.Position) * 10 + 80, 85);
    RgPictureSize.Buttons[0].Caption := Format(L('%dx%d pixels'), [BigThSize, BigThSize]);

    FCallBack(Self, BigThSize, BigThSize);
  finally
    EndScreenUpdate(RgPictureSize.Buttons[0].Handle, False);
    LockChange := False;
  end;
end;

procedure TBigImagesSizeForm.Execute(aOwner: TForm; aPictureSize : integer;
  CallBack: TCallBackBigSizeProc);
var
  p: TPoint;
begin
  GetCursorPos(p);

  p.X := p.X - 12;

  LockChange := True;
  BigThSize := aPictureSize;
  TrbImageSize.Position := 50 - (BigThSize div 10 - 8);
  p.y := p.y - 10 - Round((TrbImageSize.Height - 20) * TrbImageSize.Position / TrbImageSize.Max);

  if p.y < 0 then
  begin
    Left := p.X;
    p.X := 10;
    p.y := 10 + Round((TrbImageSize.Height - 20) * TrbImageSize.Position / TrbImageSize.Max);
    Top := 0;
    p := ClientToScreen(p);
    SetCursorPos(p.X, p.y);
  end else
  begin
    Left := p.X;
    Top := p.y - GetSystemMetrics(SM_CYFRAME) - GetSystemMetrics(SM_CYCAPTION)
      div 2;
  end;

  SetRadioButtonSize;

  LockChange := False;
  RgPictureSize.Items[0] := Format(L('%dx%d pixels'), [BigThSize, BigThSize]);
  FCallBack := CallBack;
  fOwner := aOwner;
  Show;
end;

procedure TBigImagesSizeForm.FormDeactivate(Sender: TObject);
begin
  if not TimerActivated then
    Exit;
  if Destroying then
    Exit;
  Destroying := True;
  Release;
end;

procedure TBigImagesSizeForm.TimerActivateTimer(Sender: TObject);
begin
  TimerActivate.Enabled := False;
  TimerActivated := True;
end;

procedure TBigImagesSizeForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
   Deactivate;
end;

procedure TBigImagesSizeForm.FormShow(Sender: TObject);
var
  p : TPoint;
begin
  ActivateApplication(Self.Handle);
  GetCursorPos(p);
  TrbImageSize.SetFocus;
  if GetAsyncKeystate(VK_MBUTTON) <> 0 then
    Exit;
  if GetAsyncKeystate(VK_LBUTTON) <> 0 then
    mouse_event(MOUSEEVENTF_LEFTDOWN, P.X, P.Y, 0, 0);
end;

function TBigImagesSizeForm.GetFormID: string;
begin
  Result := 'ThumbnailsSize';
end;

end.
