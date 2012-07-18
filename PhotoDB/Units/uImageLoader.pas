unit uImageLoader;

interface

uses
  SysUtils,
  Windows,
  Classes,
  DateUtils,
  Graphics,
  Vcl.Imaging.PngImage,
  Math,
  uConstants,
  uMemory,
  GraphicEx,
  uTiffImage,
  RAWImage,
  CCR.Exif,
  uExifUtils,
  uICCProfile,
  GraphicCrypt,
  uAssociations,
  uGraphicUtils,
  CCR.Exif.XMPUtils,
  uPortableDeviceUtils,
  UnitDBDeclare,
  UnitDBKernel,
  uSettings,
  uBitmapUtils,
  uJpegUtils,
  uSysUtils,
  uTranslate,
  uFormInterfaces,
  uPNGUtils;

type
  TImageLoadFlag = (ilfGraphic, ilfICCProfile, ilfEXIF, ilfFullRAW, ilfHalfRawSize, ilfPassword, ilfAskUserPassword, ilfThrowError, ilfDontUpdateInfo);
  TImageLoadFlags = set of TImageLoadFlag;

  TImageLoadBitmapFlag = (ilboFreeGraphic, ilboFullBitmap, ilboAddShadow, ilboRotate, ilboApplyICCProfile, ilboDrawAttributes, ilboQualityResize);
  TImageLoadBitmapFlags = set of TImageLoadBitmapFlag;

  ILoadImageInfo = interface
    ['{8FA3C77A-70D6-4873-9F50-DA1F450A5FF9}']
    function ExtractGraphic: TGraphic;
    function ExtractFullBitmap: TBitmap;
    function GetImageTotalPages: Integer;
    function GetRotation: Integer;
    function AppllyICCProfile(Bitmap: TBitmap): Boolean;
    function UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
    function UpdateImageInfo(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
    function GenerateBitmap(Info: TDBPopupMenuInfoRecord; Width, Height: Integer; PixelFormat: TPixelFormat; BackgroundColor: TColor; Flags: TImageLoadBitmapFlags): TBitmap;
    function SaveWithExif(Graphic: TGraphic; FileName: string): Boolean;
    function TryUpdateExif(MS: TMemoryStream; Graphic: TGraphic): Boolean;
    function GetGraphicWidth: Integer;
    function GetGraphicHeight: Integer;
    function GetIsImageEncrypted: Boolean;
    function GetPassword: string;
    function GetHasExifHeader: Boolean;
    function GetExifData: TExifData;
    property ImageTotalPages: Integer read GetImageTotalPages;
    property Rotation: Integer read GetRotation;
    property GraphicWidth: Integer read GetGraphicWidth;
    property GraphicHeight: Integer read GetGraphicHeight;
    property IsImageEncrypted: Boolean read GetIsImageEncrypted;
    property Password: string read GetPassword;
    property HasExifHeader: Boolean read GetHasExifHeader;
    property ExifData: TExifData read GetExifData;
  end;

  TLoadImageInfo = class(TInterfacedObject, ILoadImageInfo)
  private
    FGraphic: TGraphic;
    FFullBitmap: TBitmap;
    FImageTotalPages: Integer;
    FRotation: Integer;
    FICCProfileName: string;
    FIsImageEncrypted: Boolean;
    FPassword: string;
    FMSICC: TMemoryStream;
    FExifData: TExifData;
    FGraphicWidth: Integer;
    FGraphicHeight: Integer;
  public
    constructor Create(AGraphic: TGraphic; AImageTotalPages: Integer; ARotation: Integer;
      AICCProfileName: string; MSICC: TMemoryStream; AFExifData: TExifData; AIsImageEncrypted: Boolean; APassword: string);
    destructor Destroy; override;
    function ExtractGraphic: TGraphic;
    function ExtractFullBitmap: TBitmap;
    function GetImageTotalPages: Integer;
    function GetRotation: Integer;
    function GetGraphicWidth: Integer;
    function GetGraphicHeight: Integer;
    function GetIsImageEncrypted: Boolean;
    function GetPassword: string;
    function GetHasExifHeader: Boolean;
    function GetExifData: TExifData;
    function AppllyICCProfile(Bitmap: TBitmap): Boolean;
    function UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
    function UpdateImageInfo(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
    function GenerateBitmap(Info: TDBPopupMenuInfoRecord; Width, Height: Integer; PixelFormat: TPixelFormat; BackgroundColor: TColor; Flags: TImageLoadBitmapFlags): TBitmap;
    function SaveWithExif(Graphic: TGraphic; FileName: string): Boolean;
    function TryUpdateExif(MS: TMemoryStream; Graphic: TGraphic): Boolean;
  end;

type
  TStreamHelper = class helper for TStream
  public
    function CopyFromEx(Source: TStream; Count: Int64; MaxBufSize: Integer): Int64;
  end;

function LoadImageFromPath(Info: TDBPopupMenuInfoRecord; LoadPage: Integer; Password: string; Flags: TImageLoadFlags;
  out ImageInfo: ILoadImageInfo; Width: Integer = 0; Height: Integer = 0): Boolean;

implementation

function DisplayProfileName: string;
begin
  Result := Settings.ReadString('Options', 'DisplayICCProfileName', DEFAULT_ICC_DISPLAY_PROFILE);
  if Result = '-' then
    Result := '';
end;

function LoadImageFromPath(Info: TDBPopupMenuInfoRecord; LoadPage: Integer; Password: string; Flags: TImageLoadFlags;
  out ImageInfo: ILoadImageInfo; Width: Integer = 0; Height: Integer = 0): Boolean;
var
  FS: TFileStream;
  S: TStream;
  GraphicClass: TGraphicClass;
  TiffImage: TTiffImage;
  PngImage: TPngImage;
  Graphic: TGraphic;
  EXIFRotation,
  ImageTotalPages, I, J: Integer;
  ExifData: TExifData;
  MSICC: TMemoryStream;
  XMPICCProperty: TXMPProperty;
  XMPICCPrifile: string;
  IsImageEncrypted: Boolean;
  LoadOnlyExif: Boolean;
  OldMode: Cardinal;
begin
  Result := False;
  ImageInfo := nil;
  ImageTotalPages := 0;
  EXIFRotation := DB_IMAGE_ROTATE_0;
  IsImageEncrypted := False;

  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try

    GraphicClass := TFileAssociations.Instance.GetGraphicClass(ExtractFileExt(Info.FileName));
    if GraphicClass = nil then
      Exit(False);

    MSICC := nil;
    if (GraphicClass = TRAWImage) and not (ilfFullRAW in Flags) then
      S := nil
    else
      S := TMemoryStream.Create;
    try
      if (ilfGraphic in Flags) then
      begin
        if not IsDevicePath(Info.FileName) then
        begin
          FS := TFileStream.Create(Info.FileName, fmOpenRead or fmShareDenyNone);
          try
            IsImageEncrypted := ValidCryptGraphicStream(FS);
            Info.Encrypted := IsImageEncrypted;
            if Info.Encrypted then
            begin
              if ilfPassword in Flags then
                Password := DBKernel.FindPasswordForCryptImageFile(Info.FileName);

              if (Password = '') and (ilfAskUserPassword in flags) then
                TThread.Synchronize(nil,
                  procedure
                  begin
                    Password := RequestPasswordForm.ForImage(Info.FileName);
                  end
                );

              if (Password = '') and (ilfThrowError in Flags) then
                raise Exception.Create(FormatEx(TA('Can''t decrypt image "{0}"', 'Image'), [Info.FileName]));

              if S = nil then
                S := TMemoryStream.Create;
              DecryptStreamToStream(FS, S, Password);
            end else
            begin
              if (GraphicClass = TRAWImage) and not (ilfFullRAW in Flags) then
              begin
                S := FS;
                FS := nil;
              end else
                S.CopyFromEx(FS, FS.Size, 1024 * 1024);
            end;
          finally
            F(FS);
          end;
        end else
        begin
          if S = nil then
            S := TMemoryStream.Create;
          ReadStreamFromDevice(Info.FileName, S);
        end;
      end;

      LoadOnlyExif := (ilfEXIF in Flags) and not (ilfGraphic in Flags);

      if ((S <> nil) and (S.Size > 0)) or LoadOnlyExif then
      begin
        if Flags * [ilfICCProfile, ilfEXIF] <> [] then
        begin
          if not LoadOnlyExif then
            S.Seek(0, soFromBeginning);

          ExifData := TExifData.Create(nil);
          try
            if LoadOnlyExif then
              ExifData.LoadFromFileEx(Info.FileName, False)
            else
              ExifData.LoadFromGraphic(S);

            if not ExifData.Empty then
            begin
              if not (ilfDontUpdateInfo in Flags) then
              begin
                Info.HasExifHeader := True;
                if (ExifData.DateTime > 0) and (YearOf(ExifData.DateTime) >= 1900) then
                begin
                  Info.Date := DateOf(ExifData.DateTime);
                  Info.Time := TimeOf(ExifData.DateTime);
                end;
              end;

              if (ilfEXIF in Flags) then
                EXIFRotation := ExifOrientationToRatation(Ord(ExifData.Orientation));

              if (ilfICCProfile in Flags) then
              begin
                if (ExifData.ColorSpace = csTagMissing) or (ExifData.ColorSpace = csUncalibrated)
                  or (ExifData.ColorSpace = csICCProfile) then
                begin
                  if ExifData.HasICCProfile then
                  begin
                    MSICC := TMemoryStream.Create;
                    ExifData.ExtractICCProfile(MSICC);
                  end;
                  if MSICC = nil then
                  begin
                    XMPICCProperty := ExifData.XMPPacket.Schemas[xsPhotoshop].Properties['ICCProfile'];
                    if XMPICCProperty <> nil then
                      XMPICCPrifile := XMPICCProperty.ReadValue();
                  end;
                end;
              end;
            end;

            if (ilfGraphic in Flags) then
            begin
              Graphic := GraphicClass.Create;
              try
                InitGraphic(Graphic);
                if (Graphic is TRAWImage) then
                begin
                   TRAWImage(Graphic).IsPreview := not (ilfFullRAW in Flags);
                   if TRAWImage(Graphic).IsPreview then
                     TRAWImage(Graphic).PreviewSize := Max(Width, Height);
                   if (ilfHalfRawSize in Flags) then
                     TRAWImage(Graphic).HalfSizeLoad := True;
                end;

                if not (ilfDontUpdateInfo in flags) and (Info.ID = 0) and not IsDevicePath(Info.FileName) then
                begin
                  Info.Rotation := -10 * EXIFRotation;

                  if (Graphic is TRAWImage) and not (ilfFullRAW in Flags) then
                    Info.Rotation := ExifDisplayButNotRotate(Info.Rotation);
                end;

                S.Seek(0, soFromBeginning);
                if (Graphic is TTiffImage) then
                begin
                  TiffImage := TTiffImage(Graphic);
                  TiffImage.LoadFromStreamEx(S, LoadPage);
                  ImageTotalPages := TiffImage.Pages;
                end else
                  Graphic.LoadFromStream(S);

                if not Graphic.Empty then
                begin

                  //load ICC profile from PNG image
                  if (Graphic is TPngImage) and (ilfICCProfile in Flags) and (MSICC = nil) then
                    ApplyPNGIccProfile(TPngImage(Graphic), DisplayProfileName);

                  ImageInfo := TLoadImageInfo.Create(
                    Graphic,
                    ImageTotalPages,
                    EXIFRotation,
                    XMPICCPrifile,
                    MSICC,
                    ExifData,
                    IsImageEncrypted,
                    Password);
                  ExifData := nil;
                  MSICC := nil;
                  Graphic := nil;
                  Result := True;
                end else
                begin
                  if (Graphic = nil) and (ilfThrowError in Flags) then
                    raise Exception.Create(FormatEx(TA('Can''t load image "{0}"', 'Image'), [Info.FileName]));
                end;
              finally
                F(Graphic);
              end;
            end else
            begin
              ImageInfo := TLoadImageInfo.Create(
                nil,
                ImageTotalPages,
                EXIFRotation,
                XMPICCPrifile,
                MSICC,
                ExifData,
                IsImageEncrypted,
                Password);
              ExifData := nil;
              MSICC := nil;
              Result := True;
            end;

          finally
            F(ExifData);
          end;
        end;
      end;
    finally
      F(S);
      F(MSICC);
    end;
  finally
    SetErrorMode(OldMode);
  end;
end;

{ TLoadImageInfo }

function TLoadImageInfo.AppllyICCProfile(Bitmap: TBitmap): Boolean;
begin
  Result := False;
  if (Bitmap <> nil) and not Bitmap.Empty and (Bitmap.PixelFormat = pf24Bit) then
  begin
    if (FMSICC <> nil) and (FMSICC.Size > 0) then
      Result := ConvertBitmapToDisplayICCProfile(Self, Bitmap, FMSICC.Memory, FMSICC.Size, '', DisplayProfileName);

    if not Result and (FICCProfileName <> '') then
      Result := ConvertBitmapToDisplayICCProfile(Self, Bitmap, nil, 0, FICCProfileName, DisplayProfileName);
  end;
end;

constructor TLoadImageInfo.Create(AGraphic: TGraphic; AImageTotalPages,
  ARotation: Integer; AICCProfileName: string; MSICC: TMemoryStream;
  AFExifData: TExifData; AIsImageEncrypted: Boolean; APassword: string);
begin
  FGraphic := AGraphic;
  FFullBitmap := nil;
  FImageTotalPages := AImageTotalPages;
  FRotation := ARotation;
  FICCProfileName := AICCProfileName;
  FMSICC := MSICC;
  FExifData := AFExifData;
  FGraphicWidth := 0;
  FGraphicHeight := 0;
  FIsImageEncrypted := AIsImageEncrypted;
  FPassword := APassword;
  if FGraphic <> nil then
  begin
    FGraphicWidth := FGraphic.Width;
    FGraphicHeight := FGraphic.Height;
  end;
end;

destructor TLoadImageInfo.Destroy;
begin
  F(FExifData);
  F(FMSICC);
  F(FGraphic);
  F(FFullBitmap);
  inherited;
end;

function TLoadImageInfo.ExtractFullBitmap: TBitmap;
begin
  Result := FFullBitmap;
  FFullBitmap := nil;
end;

function TLoadImageInfo.ExtractGraphic: TGraphic;
begin
  Result := FGraphic;
  FGraphic := nil;
end;

function TLoadImageInfo.GenerateBitmap(Info: TDBPopupMenuInfoRecord; Width, Height: Integer;
  PixelFormat: TPixelFormat; BackgroundColor: TColor; Flags: TImageLoadBitmapFlags): TBitmap;
var
  B, B32: TBitmap;
  W, H: Integer;
begin
  Result := nil;
  if FGraphic = nil then
    Exit(nil);

  B := TBitmap.Create;
  try
    if (Width > 0) and (Height > 0) and not (ilboFullBitmap in Flags) then
      JPEGScale(FGraphic, Width, Height);

    AssignGraphic(B, FGraphic);
    if ilboFreeGraphic in Flags then
      F(FGraphic);

    Exchange(B, Result);
  finally
    F(B);
  end;

  if (Result <> nil) and (PixelFormat = pf24bit) then
  begin
    if Result.PixelFormat = pf32bit then
    begin
      B := TBitmap.Create;
      try
        LoadBMPImage32bit(Result, B, BackgroundColor);
        Exchange(B, Result);
      finally
        F(B);
      end;
    end
    else
      Result.PixelFormat := pf24Bit;
  end;

  if (Result <> nil) and (PixelFormat <> pf24bit) and (PixelFormat <> pf32bit) then
    Result.PixelFormat := pf24Bit;

  if (Result <> nil) and (Width > 0) and (Height > 0) then
  begin
    B := TBitmap.Create;
    try
      B.PixelFormat := Result.PixelFormat;
      W := Result.Width;
      H := Result.Height;
      ProportionalSize(Width, Height, W, H);
      if ilboQualityResize in Flags then
        StretchEx(W, H, sfLanczos3, 0, Result, B)
      else
        DoResize(W, H, Result, B);

      if ilboFullBitmap in Flags then
      begin
        FFullBitmap := Result;
        Result := nil;
      end;

      Exchange(B, Result);
    finally
      F(B);
    end;
  end;

  if ilboRotate in Flags then
    ApplyRotate(Result, Info.Rotation);

  if ilboApplyICCProfile in Flags then
    AppllyICCProfile(Result);

  if (ilboAddShadow in Flags) then
  begin
    B32 := TBitmap.Create;
    try
      DrawShadowToImage(B32, Result);
      B32.AlphaFormat := afDefined;
      if (Result.PixelFormat = pf24bit) then
        LoadBMPImage32bit(B32, Result, BackgroundColor)
      else
        Exchange(B32, Result);
    finally
      F(B32);
    end;
  end;
end;

function TLoadImageInfo.GetExifData: TExifData;
begin
  Result := FExifData;
end;

function TLoadImageInfo.GetGraphicHeight: Integer;
begin
  Result := FGraphicHeight;
end;

function TLoadImageInfo.GetGraphicWidth: Integer;
begin
  Result := FGraphicWidth;
end;

function TLoadImageInfo.GetHasExifHeader: Boolean;
begin
  Result := not FExifData.Empty;
end;

function TLoadImageInfo.GetImageTotalPages: Integer;
begin
  Result := FImageTotalPages;
end;

function TLoadImageInfo.GetIsImageEncrypted: Boolean;
begin
  Result := FIsImageEncrypted;
end;

function TLoadImageInfo.GetPassword: string;
begin
  Result := FPassword;
end;

function TLoadImageInfo.GetRotation: Integer;
begin
  Result := FRotation;
end;

function TLoadImageInfo.SaveWithExif(Graphic: TGraphic;
  FileName: string): Boolean;
begin
  if not FExifData.Empty then
  begin
    FExifData.BeginUpdate;
    try
      FExifData.Orientation := toTopLeft;
      FExifData.ExifImageWidth := Graphic.Width;
      FExifData.ExifImageHeight := Graphic.Height;
      FExifData.Thumbnail := nil;
      Graphic.SaveToFile(FileName);
      FExifData.SaveToGraphic(FileName);
    finally
      FExifData.EndUpdate;
    end;
  end else
    Graphic.SaveToFile(FileName);

  Result := True;
end;

function TLoadImageInfo.TryUpdateExif(MS: TMemoryStream;
  Graphic: TGraphic): Boolean;
begin
  Result := False;
  if (FExifData <> nil) and not FExifData.Empty then
  begin
    FixEXIFForJpegStream(FExifData, MS, Graphic.Width, Graphic.Height);
    Result := True;
  end;
end;

function TLoadImageInfo.UpdateImageGeoInfo(Info: TDBPopupMenuInfoRecord): Boolean;
begin
  Result := False;
  if FExifData <> nil then
    Result := UpdateImageGeoInfoFromExif(Info, FExifData);
end;

function TLoadImageInfo.UpdateImageInfo(Info: TDBPopupMenuInfoRecord; IsDBValues: Boolean = True; LoadGroups: Boolean = False): Boolean;
begin
  Result := False;
  if FExifData <> nil then
    Result := UpdateImageRecordFromExifData(Info, FExifData, IsDBValues, LoadGroups);
end;

{ TStreamHelper }

function TStreamHelper.CopyFromEx(Source: TStream; Count: Int64; MaxBufSize: Integer): Int64;
var
  BufSize, N: Integer;
  Buffer: PByte;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;


end.