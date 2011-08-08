unit uGraphicUtils;

interface

uses
  Windows, SysUtils, Classes, Graphics, Jpeg, Math, uConstants,
  uMemory, uBitmapUtils, Forms, Messages, uJpegUtils, RAWImage, pngimage,
  uPngUtils, GIFImage, GraphicsBaseTypes;

procedure BeginScreenUpdate(Hwnd: THandle);
procedure EndScreenUpdate(Hwnd: THandle; Erase: Boolean);
function MixColors(Color1, Color2: TColor; Percent: Integer): TColor;
function MakeDarken(BaseColor: TColor; Multiply: Extended): TColor; overload;
function MakeDarken(Color: TColor): TColor; overload;
function ColorDiv2(Color1, COlor2: TColor): TColor;
function ColorDarken(Color: TColor): TColor;
procedure AssignGraphic(Dest: TBitmap; Src: TGraphic);
procedure AssignToGraphic(Dest: TGraphic; Src: TBitmap);
procedure LoadImageX(Image: TGraphic; Bitmap: TBitmap; BackGround: TColor);

implementation

procedure BeginScreenUpdate(hwnd: THandle);
begin
  if (hwnd = 0) then
    hwnd := Application.MainForm.Handle;
  SendMessage(Hwnd, WM_SETREDRAW, 0, 0);
end;

procedure EndScreenUpdate(Hwnd: THandle; Erase: Boolean);
begin
  if (Hwnd = 0) then
    Hwnd := Application.MainForm.Handle;
  SendMessage(Hwnd, WM_SETREDRAW, 1, 0);
  RedrawWindow(Hwnd, nil, 0, { DW_FRAME + } RDW_INVALIDATE + RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
  if (Erase) then
    Windows.InvalidateRect(Hwnd, nil, True);
end;

function ColorDiv2(Color1, COlor2: TColor): TColor;
begin
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);
  Result := RGB((GetRValue(Color1) + GetRValue(Color2)) div 2, (GetGValue(Color1) + GetGValue(Color2)) div 2,
    (GetBValue(Color1) + GetBValue(Color2)) div 2);
end;

function ColorDarken(Color: TColor): TColor;
begin
  Color := ColorToRGB(Color);
  Result := RGB(Round(GetRValue(Color) / 1.2), (Round(GetGValue(Color) / 1.2)), (Round(GetBValue(Color) / 1.2)));
end;

function MakeDarken(BaseColor : TColor; Multiply : Extended) : TColor;
var
  R, G, B : Byte;
begin
  BaseColor := ColorToRGB(BaseColor);
  R := GetRValue(BaseColor);
  G := GetGValue(BaseColor);
  B := GetBValue(BaseColor);
  R := Byte(Round(R * Multiply));
  G := Byte(Round(G * Multiply));
  B := Byte(Round(B * Multiply));
  Result := RGB(R, G, B);
end;

function MakeDarken(Color: TColor): TColor;
begin
  Color := ColorToRGB(Color);
  Result := RGB(Round(0.75 * GetRValue(Color)), Round(0.75 * GetGValue(Color)), Round(0.75 * GetBValue(Color)));
end;

function MixColors(Color1, Color2: TColor; Percent: Integer): TColor;
var
  R, G, B: Byte;
  P: Extended;
begin
  Color1 := ColorToRGB(Color1);
  Color2 := ColorToRGB(Color2);
  P := (Percent / 100);
  R := Round(P * GetRValue(Color1) + (P - 1) * GetRValue(Color2));
  G := Round(P * GetGValue(Color1) + (P - 1) * GetGValue(Color2));
  B := Round(P * GetBValue(Color1) + (P - 1) * GetBValue(Color2));
  Result := RGB(R, G, B);
end;

procedure LoadGIFImage32bit(GIF : TGIFSubImage; Bitmap : TBitmap; BackGroundColorIndex : integer;
    BackGroundColor : TColor);
var
  I, J: Integer;
  P: PARGB;
  R, G, B: Byte;
begin
  BackGroundColor := ColorToRGB(BackGroundColor);
  R := GetRValue(BackGroundColor);
  G := GetGValue(BackGroundColor);
  B := GetBValue(BackGroundColor);
  Bitmap.PixelFormat := pf24bit;
  for I := 0 to GIF.Top - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := GIF.Top + GIF.Height to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to Bitmap.Width - 1 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := GIF.Top to GIF.Top + GIF.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := 0 to GIF.Left - 1 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := GIF.Top to GIF.Top + GIF.Height - 1 do
  begin
    P := Bitmap.ScanLine[I];
    for J := GIF.Left + GIF.Width - 1 to Bitmap.Width - 2 do
    begin
      P[J].R := R;
      P[J].G := G;
      P[J].B := B;
    end;
  end;
  for I := 0 to GIF.Height - 1 do
  begin
    P := Bitmap.ScanLine[I + GIF.Top];
    for J := 0 to GIF.Width - 1 do
    begin
      if GIF.Pixels[J, I] = BackGroundColorIndex then
      begin
        P[J + GIF.Left].R := R;
        P[J + GIF.Left].G := G;
        P[J + GIF.Left].B := B;
      end;
    end;
  end;
end;

procedure AssignGraphic(Dest: TBitmap; Src: TGraphic);
begin
  if ((Src is TBitmap) and (TBitmap(Src).PixelFormat = pf32Bit)) or ((Src is TPngImage) and (TPngImage(Src).TransparencyMode <> ptmNone)) then
    Dest.PixelFormat := pf32Bit
  else
    Dest.PixelFormat := pf24Bit;

  if Src is TJpegImage then
    AssignJpeg(Dest, TJpegImage(Src))
  else if Src is TRAWImage then
    Dest.Assign(TRAWImage(Src))
  else if Src is TBitmap then
    AssignBitmap(Dest, TBitmap(Src))
  else if (Src is TPngImage) and ((TPngImage(Src).Header.BitDepth = 8) or
    (TPngImage(Src).Header.BitDepth = 16)) then
  begin
    case TPngImage(Src).Header.ColorType of
      COLOR_GRAYSCALE:
        LoadPNGImage8BitWOTransparent(TPngImage(Src), Dest);
      COLOR_GRAYSCALEALPHA:
        LoadPNGImage8BitTransparent(TPngImage(Src), Dest);
      COLOR_PALETTE:
        LoadPNGImagePalette(TPngImage(Src), Dest);
      COLOR_RGB:
        LoadPNGImageWOTransparent(TPngImage(Src), Dest);
      COLOR_RGBALPHA:
        LoadPNGImageTransparent(TPngImage(Src), Dest);
      else
        Dest.Assign(Src);
    end;
  end else
    Dest.Assign(Src);
end;

procedure AssignToGraphic(Dest: TGraphic; Src: TBitmap);
begin
  if (Dest is TPngImage) and (Src.PixelFormat = pf32Bit) then
  begin
    SavePNGImageTransparent(TPngImage(Dest), Src);
  end else
    Dest.Assign(Src);
end;

procedure LoadImageX(Image: TGraphic; Bitmap: TBitmap; BackGround: TColor);
begin
  if Image is TGIFImage then
  begin
    if not(Image as TGIFImage).Images[0].Empty then
      if (Image as TGIFImage).Images[0].Transparent then
      begin
        Bitmap.Assign(Image);
        if (Image as TGIFImage).Images[0].GraphicControlExtension <> nil then
          LoadGIFImage32bit((Image as TGIFImage).Images[0], Bitmap, (Image as TGIFImage).Images[0].GraphicControlExtension.TransparentColorIndex, BackGround);
        Exit;
      end;
  end;
  AssignGraphic(Bitmap, Image);
end;

end.
