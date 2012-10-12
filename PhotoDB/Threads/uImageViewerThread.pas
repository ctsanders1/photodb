unit uImageViewerThread;

interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.SysUtils,
  Vcl.Graphics,
  Vcl.Imaging.PngImage,

  UnitDBDeclare,
  UnitDBKernel,
  RAWImage,
  GraphicCrypt,

  uMemory,
  uConstants,
  uThreadForm,
  uLogger,
  uIImageViewer,
  uDBThread,
  uImageLoader,
  uPortableDeviceUtils,
  uBitmapUtils,
  uGraphicUtils,
  uPNGUtils,
  uJpegUtils,
  uSettings,
  uFaceDetection,
  uFaceDetectionThread;

type
  TImageViewerThread = class(TDBThread)
  private
    FOwnerControl: IImageViewer;
    FThreadId: TGUID;
    FInfo: TDBPopupMenuInfoRecord;
    FDisplaySize: TSize;
    FIsPreview: Boolean;
    FPageNumber: Integer;
    FTotalPages: Integer;
    FRealWidth: Integer;
    FRealHeight: Integer;
    FRealZoomScale: Double;
    FIsTransparent: Boolean;

    //TODO; remove
    FTransparentColor: TColor;

    FGraphic: TGraphic;
    FBitmap: TBitmap;
    procedure SetStaticImage;
    procedure SetAnimatedImageAsynch;
  protected
    procedure Execute; override;
  public
    constructor Create(OwnerForm: TThreadForm; OwnerControl: IImageViewer; ThreadId: TGUID;
     Info: TDBPopupMenuInfoRecord; DisplaySize: TSize; IsPreview: Boolean; PageNumber: Integer);
    destructor Destroy; override;
  end;

implementation

{ TImageViewerThread }

constructor TImageViewerThread.Create(OwnerForm: TThreadForm;
  OwnerControl: IImageViewer; ThreadId: TGUID; Info: TDBPopupMenuInfoRecord;
  DisplaySize: TSize; IsPreview: Boolean; PageNumber: Integer);
begin
  if Info = nil then
    raise EArgumentNilException.Create('Info is nil!');

  inherited Create(OwnerForm, False);

  FOwnerControl := OwnerControl;
  FThreadId := ThreadId;
  FInfo := Info.Copy;
  FDisplaySize := DisplaySize;
  FIsPreview := IsPreview;
  FPageNumber := PageNumber;

  //TODO: remove
  FTransparentColor := Theme.PanelColor;
end;

destructor TImageViewerThread.Destroy;
begin
  F(FInfo);
  inherited;
end;

procedure TImageViewerThread.Execute;
var
  Password: string;
  LoadFlags: TImageLoadFlags;
  ImageInfo: ILoadImageInfo;
  PNG: TPNGImage;
begin
  FreeOnTerminate := True;
  CoInitialize(nil);
  try
    try

      Password := '';
      FTotalPages := 1;
      FRealZoomScale := 0;
      FIsTransparent := False;

      if not IsDevicePath(FInfo.FileName) and ValidCryptGraphicFile(FInfo.FileName) then
      begin
        Password := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
        if Password = '' then
        begin
          //TODO:
          Exit;
        end;
      end;


      FGraphic := nil;
      ImageInfo := nil;
      try

        LoadFlags := [ilfGraphic, ilfICCProfile, ilfPassword, ilfEXIF, ilfUseCache];

        try
          if not LoadImageFromPath(FInfo, FPageNumber, Password, LoadFlags, ImageInfo, FDisplaySize.cx, FDisplaySize.cy) then
          begin
            //TODO: SetNOImageAsynch;
            Exit;
          end;

          FTotalPages := ImageInfo.ImageTotalPages;

          FGraphic := ImageInfo.ExtractGraphic;
        except
          on e: Exception do
          begin
            EventLog(e);
            //TODO: SetNOImageAsynch;
            Exit;
          end;
        end;

        FRealWidth := FGraphic.Width;
        FRealHeight := FGraphic.Height;
        if FIsPreview then
          JPEGScale(FGraphic, FDisplaySize.cx, FDisplaySize.cy);

        FRealZoomScale := 1;
        if FGraphic.Width <> 0 then
          FRealZoomScale := FRealWidth / FGraphic.Width;
        if FGraphic is TRAWImage then
          FRealZoomScale := TRAWImage(FGraphic).Width / TRAWImage(FGraphic).GraphicWidth;

        if IsAnimatedGraphic(FGraphic) then
        begin
          SynchronizeEx(SetAnimatedImageAsynch);
        end else
        begin
          FBitmap := TBitmap.Create;
          try
            try
              if FGraphic is TPNGImage then
              begin
                FIsTransparent := True;
                PNG := (FGraphic as TPNGImage);
                if PNG.TransparencyMode <> ptmNone then
                  LoadPNGImage32bit(PNG, FBitmap, FTransparentColor)
                else
                  AssignGraphic(FBitmap, FGraphic);
              end else
              begin
                if (FGraphic is TBitmap) then
                begin
                  if PSDTransparent then
                  begin
                    if (FGraphic as TBitmap).PixelFormat = pf32bit then
                    begin
                      FIsTransparent := True;
                      LoadBMPImage32bit(FGraphic as TBitmap, FBitmap, FTransparentColor);
                    end else
                      AssignGraphic(FBitmap, FGraphic);
                  end else
                    AssignGraphic(FBitmap, FGraphic);
                end else
                  AssignGraphic(FBitmap, FGraphic);
              end;
              FBitmap.PixelFormat := pf24bit;
            except
              //TODO: SetNOImageAsynch;
              Exit;
            end;

            ImageInfo.AppllyICCProfile(FBitmap);

            ApplyRotate(FBitmap, FInfo.Rotation);

            if not SynchronizeEx(SetStaticImage) then
              F(FBitmap);

          finally
            F(FBitmap);
          end;
        end;
      finally
        //TODO:
        {if Settings.Readbool('FaceDetection', 'Enabled', True) and FaceDetectionManager.IsActive then
        begin
          if CanDetectFacesOnImage(FInfo.FileName, Graphic) then
          begin
            SynchronizeEx(ShowLoadingSign);
            FaceDetectionDataManager.RequestFaceDetection(FOwnerControl, Graphic, FInfo);
          end else
            FinishDetectionFaces;
        end else
          FinishDetectionFaces;}
        F(FGraphic);
      end;
    except
      on Ex: Exception do
        EventLog(Ex);
    end;
  finally
    CoUninitialize;
  end;
end;

procedure TImageViewerThread.SetAnimatedImageAsynch;
begin
  if IsEqualGUID(FOwnerControl.ActiveThreadId, FThreadId) then
  begin
    {ViewerForm.RealImageHeight := FRealHeight;
    ViewerForm.RealImageWidth := FRealWidth;
    ViewerForm.RealZoomInc := FRealZoomScale;
    if FIsNewDBInfo then
      ViewerForm.UpdateInfo(FSID, FInfo);
    ViewerForm.SetFullImageState(FFullImage, FBeginZoom, 1, 0);
    ViewerForm.SetAnimatedImage(Graphic);   }
    FOwnerControl.SetAnimatedImage(FGraphic, FRealWidth, FRealHeight, FInfo.Rotation, FRealZoomScale);
    Pointer(FGraphic) := nil;
  end;
end;

procedure TImageViewerThread.SetStaticImage;
begin
  if IsEqualGUID(FOwnerControl.ActiveThreadId, FThreadId) then
  begin
    {ViewerForm.Item.Encrypted := FIsEncrypted;
    if FIsNewDBInfo then
      ViewerForm.UpdateInfo(FSID, FInfo);
    ViewerForm.Item.Width := FRealWidth;
    ViewerForm.Item.Height := FRealHeight;
    ViewerForm.SetFullImageState(FFullImage, FBeginZoom, FPages, FPage);
    ViewerForm.SetStaticImage(Bitmap, FTransparent);}

    FOwnerControl.SetStaticImage(FBitmap, FRealWidth, FRealHeight, FInfo.Rotation, FRealZoomScale);

    FBitmap := nil;
  end else
    F(FBitmap);
end;

end.