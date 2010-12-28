unit RedEyeToolUnit;

interface

uses
  Windows,ToolsUnit, WebLink, Classes, Controls, Graphics, StdCtrls,
  GraphicsCool, Math, SysUtils, ImageHistoryUnit, Effects, ComCtrls,
  GraphicsBaseTypes, Language, CustomSelectTool, Dialogs, UnitDBKernel,
  EffectsLanguage, uDBGraphicTypes, uMemory;

type
  TRedEyeToolPanelClass = class(TCustomSelectToolClass)
  private
    { Private declarations }
    EffectSizeScroll: TTrackBar;
    EffectSizelabel: TLabel;
    FRedEyeEffectSize: Integer;
    FEyeColorLabel: TLabel;
    FEyeColor: TComboBox;
    FCustomColor: TColor;
    FCustomColorDialog: TColorDialog;
    FLoading: Boolean;
    procedure SetRedEyeEffectSize(const Value: Integer);
  public
    { Public declarations }
    class function ID: string; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoEffect(Bitmap: TBitmap; Rect: TRect; FullImage: Boolean); override;
    procedure EffectSizeScrollChange(Sender: TObject);
    procedure DoBorder(Bitmap: TBitmap; ARect: TRect); override;
    procedure EyeColorChange(Sender: TObject);
    procedure DoSaveSettings(Sender: TObject); override;
    procedure SetProperties(Properties: string); override;
    procedure ExecuteProperties(Properties: string; OnDone: TNotifyEvent); override;
    property RedEyeEffectSize: Integer read FRedEyeEffectSize write SetRedEyeEffectSize;
  end;

implementation

{ TRedEyeToolPanelClass }

procedure FixRedEyes(Image: TBitmap; Rect: TRect; RedEyeEffectSize: Integer; EyeColorIntex: Integer;
  CustomColor: TColor);
var
  Ih, Iw, H, W, Ix, Iy, I, J: Integer;
  X, Lay, R: Extended;
  Histogramm: T255IntArray;
  C, Cc, Nc: Integer;
  Count: Int64;
  Rx: T255ByteArray;
  Rct: TRect;
  Xdp: TArPARGB;
  Xc, Yc, Mx, My, XMx, XMy, T, Rb, Re: Integer;
  GR, Gray: Byte;
  Rn, Cn: Integer;
  Xx: array [0 .. 255] of Integer;
  EyeR, EyeG, EyeB: Byte;

  procedure ReplaceRedA(var RGB: TRGB; Rx, Gx, Bx: Byte; L: Byte); inline;
  begin
    RGB.R := (Rx * RGB.R * L div 255 + RGB.R * (255 - L)) shr 8;
    RGB.G := (Gx * RGB.G * L div 255 + RGB.G * (255 - L)) shr 8;
    RGB.B := (Bx * RGB.B * L div 255 + RGB.B * (255 - L)) shr 8;
  end;

begin

  case EyeColorIntex of
    0:
      begin
        EyeR := $00;
        EyeG := $AA;
        EyeB := $60;
      end;
    1:
      begin
        EyeR := $00;
        EyeG := $80;
        EyeB := $FF;
      end;
    2:
      begin
        EyeR := $80;
        EyeG := $60;
        EyeB := $00;
      end;
    3:
      begin
        EyeR := $10;
        EyeG := $10;
        EyeB := $10;
      end;
    4:
      begin
        EyeR := $80;
        EyeG := $80;
        EyeB := $80;
      end;
    5:
      begin
        EyeR := GetRValue(CustomColor);
        EyeG := GetGValue(CustomColor);
        EyeB := GetBValue(CustomColor);
      end;
  else
    begin
      EyeR := $00;
      EyeG := $00;
      EyeB := $00;
    end;
  end;

  Rct.Top := Min(Rect.Top, Rect.Bottom);
  Rct.Bottom := Max(Rect.Top, Rect.Bottom);
  Rct.Left := Min(Rect.Left, Rect.Right);
  Rct.Right := Max(Rect.Left, Rect.Right);
  Rect := Rct;

  for I := 0 to 30 do
    Xx[I] := 255;

  for I := 30 to 255 do
    Xx[I] := Round(800 / (Sqrt(Sqrt(Sqrt(I - 29)))));

  SetLength(Xdp, Image.Height);
  for I := 0 to Image.Height - 1 do
    Xdp[I] := Image.ScanLine[I];

  C := 0;
  Cc := 1;
  Histogramm := GistogrammRW(Image, Rect, Count);
  for I := 255 downto 1 do
  begin
    Inc(C, Histogramm[I]);
    if (C > Count div 10) or (Histogramm[I] > 10) then
    begin
      Cc := I;
      Break;
    end;
  end;

  for I := 0 to 255 do
  begin
    Rx[I] := Min(255, Round((255 / Cc) * I));
  end;
  C := Round(Cc * RedEyeEffectSize / 100);

  Mx := 0;
  My := 0;
  XMx := 0;
  XMy := 0;

  for I := Rect.Left to Rect.Right do
    for J := Rect.Top to Rect.Bottom do
      if (I >= 0) and (J >= 0) and (I < Image.Width - 1) and (J < Image.Height - 1) then
      begin
        T := Xdp[J, I].R - Max(Xdp[J, I].G, Xdp[J, I].B);
        if T > C then
        begin
          XMx := XMx + T * I;
          Mx := Mx + T;

          XMy := XMy + T * J;
          My := My + T;
        end;
      end;
  if (Mx = 0) or (My = 0) then
    Exit;
  Xc := Round(XMx / Mx);
  Yc := Round(XMy / My);
  Ih := (Rect.Bottom - Rect.Top) div 2;
  H := Ih + Rect.Top;
  Iw := (Rect.Right - Rect.Left) div 2;
  W := Iw + Rect.Left;
  for I := Rect.Left to Rect.Right do
  begin
    Ix := I - W;
    if Iw * Iw = 0 then
      Exit;
    if (Ih * Ih) - ((Ih * Ih) / (Iw * Iw)) * (Ix * Ix) > 0 then
      Iy := Round(Sqrt((Ih * Ih) - ((Ih * Ih) / (Iw * Iw)) * (Ix * Ix)))
    else
      Continue;
    for J := H - Iy to H + Iy do
    begin
      if (I >= 0) and (J >= 0) and (I < Image.Width - 1) and (J < Image.Height - 1) then
      begin
        GR := (Xdp[J, I].R * 77 + Xdp[J, I].G * 151 + Xdp[J, I].B * 28) shr 8;
        Rn := Xx[GR];
        Cn := Math.Max(Xdp[J, I].R - Max(Xdp[J, I].G, Xdp[J, I].B), 0);
        Cn := Min(255, Round(Cn * Rn / 255));
        if Xdp[J, I].R - Max(Xdp[J, I].G, Xdp[J, I].B) > C then
          if Xdp[J, I].R / (Xdp[J, I].R + Xdp[J, I].G + Xdp[J, I].B) > 0.40 then
            ReplaceRedA(Xdp[J, I], EyeR, EyeG, EyeB, Cn);
      end;
    end;
  end;
end;

constructor TRedEyeToolPanelClass.Create(AOwner: TComponent);
begin
  inherited;
  FLoading := True;
  EffectSizelabel := TLabel.Create(Self);
  EffectSizelabel.Left := 8;
  EffectSizelabel.Top := EditHeight.Top + EditHeight.Height + 5;
  EffectSizelabel.Caption := TEXT_MES_RED_EYE_EFFECT_SIZE_F;
  EffectSizelabel.Parent := Self;

  EffectSizeScroll := TTrackBar.Create(AOwner);
  EffectSizeScroll.Top := EffectSizelabel.Top + EffectSizelabel.Height + 5;
  EffectSizeScroll.Width := 150;
  EffectSizeScroll.Left := 8;
  EffectSizeScroll.Max := 100;
  EffectSizeScroll.Min := 5;
  EffectSizeScroll.OnChange := EffectSizeScrollChange;
  EffectSizeScroll.Position := 50;
  EffectSizeScroll.Parent := AOwner as TWinControl;

  FEyeColorLabel := TLabel.Create(AOwner);
  FEyeColorLabel.Left := 8;
  FEyeColorLabel.Top := EffectSizeScroll.Top + EffectSizeScroll.Height + 5;
  FEyeColorLabel.Parent := Self;
  FEyeColorLabel.Caption := TEXT_MES_EYE_COLOR + ':';

  FEyeColor := TComboBox.Create(AOwner);
  FEyeColor.Left := 8;
  FEyeColor.Top := FEyeColorLabel.Top + FEyeColorLabel.Height + 5;
  FEyeColor.Width := 150;
  FEyeColor.OnChange := EyeColorChange;
  FEyeColor.Style := CsDropDownList;
  FEyeColor.Parent := AOwner as TWinControl;
  FEyeColor.Items.Add(TEXT_MES_COLOR_GREEN);
  FEyeColor.Items.Add(TEXT_MES_COLOR_BLUE);
  FEyeColor.Items.Add(TEXT_MES_COLOR_BROWN);
  FEyeColor.Items.Add(TEXT_MES_COLOR_BLACK);
  FEyeColor.Items.Add(TEXT_MES_COLOR_GRAY);
  FEyeColor.Items.Add(TEXT_MES_COLOR_CUSTOM);

  FEyeColor.ItemIndex := 1;
  FCustomColor := $0;
  FCustomColorDialog := TColorDialog.Create(AOwner);

  EffectSizeScroll.Position := DBKernel.ReadInteger('Editor', 'RedEyeToolSize', 50);
  FEyeColor.ItemIndex := DBKernel.ReadInteger('Editor', 'RedEyeColor', 0);
  FCustomColor := DBKernel.ReadInteger('Editor', 'RedEyeColorCustom', 0);

  SaveSettingsLink.Top := FEyeColor.Top + FEyeColor.Height + 15;
  MakeItLink.Top := SaveSettingsLink.Top + SaveSettingsLink.Height + 5;
  CloseLink.Top := MakeItLink.Top + MakeItLink.Height + 5;
  FLoading := False;
end;

destructor TRedEyeToolPanelClass.Destroy;
begin
  F(EffectSizeScroll);
  F(EffectSizelabel);
  F(FCustomColorDialog);
  F(FEyeColor);
  inherited;
end;

procedure TRedEyeToolPanelClass.DoEffect(Bitmap: TBitmap; Rect: TRect; FullImage: Boolean);
begin
  FixRedEyes(Bitmap, Rect, FRedEyeEffectSize, FEyeColor.ItemIndex, FCustomColor);
end;

procedure TRedEyeToolPanelClass.DoBorder(Bitmap: TBitmap; ARect: TRect);
var
  Nn, H2, W2, W, H, I, Ii, J: Integer;
  Rct: TRect;
  Dd: Extended;
  Xdp: TArPARGB;

  procedure Border(I, J: Integer; var RGB: TRGB);
  begin
    if Odd((I + J) div 3) then
    begin
      RGB.R := RGB.R div 5;
      RGB.G := RGB.G div 5;
      RGB.B := RGB.B div 5;
    end else
    begin
      RGB.R := RGB.R xor $FF;
      RGB.G := RGB.G xor $FF;
      RGB.B := RGB.B xor $FF;
    end;
  end;

begin
 Rct.Top:=Min(aRect.Top,aRect.Bottom);
 Rct.Bottom:=Max(aRect.Top,aRect.Bottom);
 Rct.Left:=Min(aRect.Left,aRect.Right);
 Rct.Right:=Max(aRect.Left,aRect.Right);
 aRect:=Rct;
 w:=Rct.Right-Rct.Left;
 h:=Rct.Bottom-Rct.Top;
 SetLength(Xdp,Bitmap.height);
 for i:=0 to Bitmap.Height-1 do
 Xdp[i]:=Bitmap.ScanLine[i];

 i:=Min(Bitmap.Height-1,Max(0,aRect.Top));
 if i=aRect.Top then
 for j:=0 to Bitmap.Width-1 do
 begin
  if (j>aRect.Left) and (j<aRect.Right) then
  begin
   Border(i,j,Xdp[i,j]);
  end;
 end;

 i:=Min(Bitmap.Height-1,Max(0,aRect.Bottom));
 if i=aRect.Bottom then
 for j:=0 to Bitmap.Width-1 do
 begin
  if (j>aRect.Left) and (j<aRect.Right) then
  begin
   Border(i,j,Xdp[i,j]);
  end;
 end;

 for i:=Max(0,aRect.Top) to Min(aRect.Bottom-1,Bitmap.Height-1) do
 begin
  j:=Max(0,Min(Bitmap.Width-1,aRect.Left));
  if j=aRect.Left then
  Border(i,j,Xdp[i,j]);
 end;
 for i:=Max(0,aRect.Top) to Min(aRect.Bottom-1,Bitmap.Height-1) do
 begin
  j:=Min(Bitmap.Width-1,Max(0,aRect.Right));
  if j=aRect.Right then
  Border(i,j,Xdp[i,j]);
 end;


 if w*h=0 then exit;
 w2:=w div 2;
 h2:=h div 2;
 if w2*h2=0 then exit;
 dd:=min(1/w2,1/h2);
 nn:=Round(2*pi/dd);
 for ii:=1 to nn do
 begin
  i:=aRect.Left+w2+Round((w/2)*cos(dd*ii));
  j:=aRect.Top+h2+Round((h/2)*sin(dd*ii));
  if (i>=0) and (j>=0) and (i<Bitmap.Width-1) and (j<Bitmap.Height-1) then
  Border(i,j,Xdp[j,i]);
 end;

end;

procedure TRedEyeToolPanelClass.EffectSizeScrollChange(Sender: TObject);
begin
  FRedEyeEffectSize := EffectSizeScroll.Position;
  EffectSizelabel.Caption := Format(TEXT_MES_RED_EYE_EFFECT_SIZE_F, [EffectSizeScroll.Max - EffectSizeScroll.Position]);
  if Assigned(FProcRecteateImage) then
    FProcRecteateImage(Self);
end;

procedure TRedEyeToolPanelClass.SetRedEyeEffectSize(const Value: Integer);
begin
  FRedEyeEffectSize := Value;
end;

procedure TRedEyeToolPanelClass.EyeColorChange(Sender: TObject);
begin
 FCustomColorDialog.Color:=FCustomColor;
 if FEyeColor.ItemIndex=5 then
 if not FLoading then
 if FCustomColorDialog.Execute then
 begin
  FCustomColor:=FCustomColorDialog.Color;
 end else FEyeColor.ItemIndex:=0;
 EffectSizeScrollChange(Sender);
end;

procedure TRedEyeToolPanelClass.DoSaveSettings(Sender: TObject);
begin
 DBKernel.WriteInteger('Editor','RedEyeToolSize',EffectSizeScroll.Position);
 DBKernel.WriteInteger('Editor','RedEyeColor',FEyeColor.ItemIndex);
 DBKernel.WriteInteger('Editor','RedEyeColorCustom',FCustomColor);
end;

class function TRedEyeToolPanelClass.ID: string;
begin
 Result:='{3D2B384F-F4EB-457C-A11C-BDCE1C20FFFF}';
end;

procedure TRedEyeToolPanelClass.SetProperties(Properties: String);
begin

end;

procedure TRedEyeToolPanelClass.ExecuteProperties(Properties: String;
  OnDone: TNotifyEvent);
begin

end;

end.
