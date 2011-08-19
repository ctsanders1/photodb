unit uShellThumbnails;

interface

uses
  Windows, Classes, Graphics, uMemory, uWinThumbnails, pngimage, SyncObjs,
  uPngUtils, GraphicsCool, uResources, uBitmapUtils;

function ExtractVideoThumbnail(FileName: string; MaxSize: Integer; Bitmap: TBitmap): Boolean;

implementation

var
  FullVideoPicture: TPNGImage = nil;
  FVideoPictureLock: TCriticalSection = nil;

procedure DrawVideoImageBig(Bitmap: TBitmap; W, H: Integer);
var
  Bit32: TBitmap;
begin
  FVideoPictureLock.Enter;
  try
    if FullVideoPicture = nil then
      FullVideoPicture := GetFilmStripImage;
  finally
    FVideoPictureLock.Leave;
  end;

  if FullVideoPicture = nil then
    Exit;

  Bit32 := TBitmap.Create;
  try
    FVideoPictureLock.Enter;
    try
      LoadPNGImageTransparent(FullVideoPicture, Bit32);
    finally
      FVideoPictureLock.Leave;
    end;
    StretchCoolW32(0, 0, W, H, Rect(0, 0, Bit32.Width, Bit32.Height), Bit32, Bitmap, 1);
  finally
    F(Bit32);
   end;
end;

function ExtractVideoThumbnail(FileName: string; MaxSize: Integer; Bitmap: TBitmap): Boolean;
const
  ImageRealWidth = 0.98;
  ImageRealHeight = 0.76;
var
  Thumb: TBitmap;
begin
  Result := False;
  Thumb := TBitmap.Create;
  try
    Thumb.Handle := ExtractThumbnail(FileName, Round(MaxSize * ImageRealWidth), Round(MaxSize * ImageRealHeight));
    if not Thumb.Empty then
    begin
      Bitmap.PixelFormat := pf32bit;
      DrawVideoImageBig(Bitmap, Round(Thumb.Width / ImageRealWidth), Round(Thumb.Height / ImageRealHeight));
      StretchCoolW32(Bitmap.Width div 2 - Thumb.Width div 2, Bitmap.Height div 2 - Thumb.Height div 2, Thumb.Width, Thumb.Height,
        Rect(0, 0, Thumb.Width, Thumb.Height), Thumb, Bitmap, 1);
      Result := True;
    end;
  finally
    F(Thumb);
  end;
end;

initialization

  FVideoPictureLock := TCriticalSection.Create;

finalization

  F(FVideoPictureLock);
  F(FullVideoPicture);

end.