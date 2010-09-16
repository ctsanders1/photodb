unit UnitHintCeator;

interface

uses
  Windows, Messages, SysUtils, Classes, ExtCtrls, JPEG, DB,
  Graphics, Controls, Forms, GIFImage, GraphicEx, Math, UnitDBCommonGraphics,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, RAWImage,
  GraphicCrypt, UnitDBCommon, ImageConverting, uGOM,
  uMemory, SyncObjs, dolphin_db, UnitDBKernel;

type
  HintCeator = class(TThread)
  private
    { Private declarations }
    Fbmp, Fb: Tbitmap;
    Graphic: TGraphic;
    Fh, Fw: Integer;
    FOriginalWidth: Integer;
    FOriginalHeight: Integer;
    FSelfItem: TObject;
    BooleanResult: Boolean;
    ValidImages: Integer;
    GIF: TGIFImage;
    BitmapParam: TBitmap;

    FStateID: TGUID;
    FInfo : TDBPopupMenuInfoRecord;
    FOwner : TForm;
    FHintCheckProc : THintCheckFunction;
    FPoint : TPoint;
    function CheckThreadState: Boolean;
    procedure CheckThreadStateSync;
    procedure DoShowHint;
    procedure GIFDraw;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner : TForm; AStateID : TGUID; AInfo : TDBPopupMenuInfoRecord;
      Point : TPoint; HintCheckProc : THintCheckFunction);
  end;

  THintManager = class(TObject)
  private
    FStateID : TGUID;
    FSync : TCriticalSection;
    FHints : TList;
    constructor Create;
  public
    destructor Destroy; override;
    class function Instance : THintManager;
    procedure CreateHintWindow(Owner : TForm; Info : TDBPopupMenuInfoRecord;
      Point : TPoint; HintCheckProc : THintCheckFunction);
    procedure NewState;
    procedure RegisterHint(HintWindow : TForm);
    procedure UnRegisterHint(HintWindow : TForm);
    procedure CloseHint;
    function HintAtPoint(Point : TPoint) : TForm;
  end;

implementation

uses UnitImHint;

var
  HintManager : THintManager = nil;

{ HintcCeator }

constructor HintCeator.Create(AOwner : TForm; AStateID : TGUID; AInfo : TDBPopupMenuInfoRecord;
                              Point : TPoint; HintCheckProc : THintCheckFunction);
begin
  inherited Create(False);
  FOwner := AOwner;
  FStateID := AStateID;
  FInfo := AInfo;
  FPoint := Point;
  FHintCheckProc := HintCheckProc;
  Graphic := nil;
end;

procedure HintCeator.Execute;
var
  PNG : TPNGGraphic;
  GraphicClass : TGraphicClass;
  I : Integer;
  Crypted : Boolean;
  FilePass: string;
  Bitmap : TBitmap;
begin
  FreeOnTerminate := True;

  if not FileExists(FInfo.FileName) then
    Exit;

  GraphicClass := GetGraphicClass(ExtractFileExt(FInfo.FileName), False);
  if GraphicClass = nil then
    Exit;

  Graphic := GraphicClass.Create;
  try
    Crypted := False;
    FilePass := '';
    if ValidCryptGraphicFile(FInfo.FileName) then
    begin
      FilePass := DBKernel.FindPasswordForCryptImageFile(FInfo.FileName);
      if FilePass = '' then
        Exit;
    end;

    if not CheckThreadState then
      Exit;

    FInfo.FileSize := GetFileSizeByName(FInfo.FileName);

    if not CheckThreadState then
      Exit;

    if Crypted then
    begin
      F(Graphic);
      Graphic := DeCryptGraphicFile(FInfo.FileName, FilePass);
      if Graphic = nil then
        Exit;
    end else
    begin
      if Graphic is TRAWImage then
      begin
        if not (Graphic as TRAWImage).LoadThumbnailFromFile(FInfo.FileName, ThHintSize, ThHintSize) then
          Graphic.LoadFromFile(FInfo.FileName);
      end else
        Graphic.LoadFromFile(FInfo.FileName);
    end;

    if not CheckThreadState then
      Exit;

    FOriginalWidth := Graphic.Width;
    FOriginalHeight := Graphic.Height;

    if (Graphic is TGifImage) and (TGifImage(Graphic).Images.Count > 0) then
    begin
      Synchronize(DoShowHint);
      Exit;
    end else
    begin
      JPEGScale(Graphic, ThHintSize, ThHintSize);
      Bitmap := TBitmap.Create;
      try
        Bitmap.PixelFormat := pf24Bit;
        Bitmap.Assign(Graphic);
        F(Graphic);
        FW := Bitmap.Width;
        FH := Bitmap.Height;
        ProportionalSize(ThHintSize, ThHintSize, FW, FH);

      finally
        Bitmap.Free;
      end;
    end;

  finally
    F(Graphic);
  end;

{
  fb.Width:=fw;
  fb.Height:=fh;
  If Max(FOriginalWidth,FOriginalHeight)>ThHintSize then
  begin
   fbmp:=Tbitmap.create;
   fbmp.PixelFormat:=pf24bit;
   fbmp.Width:=G.Width;
   fbmp.height:=G.height;
   if G is TGIFImage then
   begin
    GIF:=G as TGIFImage;
    BitmapParam:=fbmp;
    Synchronize(GIFDraw);
   end;
   if G is TPNGGraphic then
   begin
    PNG:=(G as TPNGGraphic);
    if PNG.PixelFormat=pf32bit then
    begin
     LoadPNGImage32bit(PNG,fbmp,Theme_MainColor);
    end else
      AssignGraphic(FBMP, G);
   end;

   if not (G is TPNGGraphic) and not (G is TGIFImage) then
   begin
    if (G is TBitmap) then
    begin
     if not (G is TPSDGraphic) or PSDTransparent then
     begin
      if (G as TBitmap).PixelFormat=pf32bit then
      begin
       LoadBMPImage32bit(G as TBitmap,fbmp,Theme_MainColor);
      end else AssignGraphic(FBMP, G);
     end else AssignGraphic(FBMP, G);
    end else AssignGraphic(FBMP, G);
   end;
   DoResize(fw,fh,fbmp,fb);
   fbmp.free;
  end else
  begin
   if G is TGIFImage then
   begin
    fb.PixelFormat:=pf24bit;
    fb.Width:=G.Width;
    fb.height:=G.height;
    GIF:=G as TGIFImage;
    BitmapParam:=fb;
    Synchronize(GIFDraw);
   end;
   if G is TPNGGraphic then
   begin
    PNG:=(G as TPNGGraphic);
    if PNG.PixelFormat=pf32bit then
    begin
     fb:=Tbitmap.create;
     fb.PixelFormat:=pf24bit;
     fb.Width:=G.Width;
     fb.height:=G.height;
     LoadPNGImage32bit(PNG,fb,Theme_MainColor);
    end else
      AssignGraphic(FB, G);
   end;
   if not (G is TPNGGraphic) and not (G is TGIFImage) then
   begin
    if (G is TBitmap) then
    begin
     if (G as TBitmap).PixelFormat=pf32bit then
     begin
      LoadBMPImage32bit(G as TBitmap,fb,Theme_MainColor);
     end else AssignGraphic(FB, G);
    end else AssignGraphic(FB, G);
   end;
  end;
  ApplyRotate(fb, FInfo.Rotation);
  //Synchronize(DrawHintInfo);
  if not CheckThreadState then
    exit;
  Synchronize(ok);
 end;  }

end;

procedure HintCeator.GIFDraw;
var
  i : integer;
  FTransparent : Boolean;
begin
 BitmapParam.Canvas.Pen.Color:=Theme_MainColor;
 BitmapParam.Canvas.Brush.Color:=Theme_MainColor;
 BitmapParam.Canvas.Rectangle(0,0,BitmapParam.Width,BitmapParam.Height);
 for i:=0 to GIF.Images.Count-1 do
 if not GIF.Images[i].Empty then
 begin
  FTransparent:=GIF.Images[i].Transparent;
  GIF.Images[i].Draw(BitmapParam.Canvas,Rect(0,0,GIF.Width,GIF.Height),FTransparent,false);
  break;
 end;
end;

function HintCeator.CheckThreadState: boolean;
begin
  Synchronize(CheckThreadStateSync);
  Result := BooleanResult;
end;

procedure HintCeator.CheckThreadStateSync;
begin
  if GOM.IsObj(FOwner) then
    BooleanResult := FHintCheckProc(FInfo);
end;

procedure HintCeator.DoShowHint;
var
  ImHint : TImHint;
begin
  if FB <> nil then
  begin
    Graphic:= FB;
    FB := nil;
  end;
  Application.CreateForm(TImHint, ImHint);
  ImHint.Execute(FOwner, Graphic, FOriginalWidth, FOriginalHeight, FInfo, FPoint, FHintCheckProc);
end;

{ THintManager }

procedure THintManager.CloseHint;
var
  I : Integer;
begin
  for I := 0 to FHints.Count - 1 do
    TForm(FHints[I]).Close;
end;

constructor THintManager.Create;
begin
  FHints := TList.Create;
  FSync := TCriticalSection.Create;
end;

procedure THintManager.CreateHintWindow(Owner: TForm;
  Info: TDBPopupMenuInfoRecord; Point: TPoint; HintCheckProc : THintCheckFunction);
begin
  FSync.Enter;
  try
    NewState;
    HintCeator.Create(Owner, FStateID, Info, Point, HintCheckProc);
  finally
    FSync.Leave;
  end;
end;

destructor THintManager.Destroy;
begin
  FSync.Free;
  FHints.Free;
  inherited;
end;

function THintManager.HintAtPoint(Point: TPoint): TForm;
var
  I : Integer;
  R : TRect;
  HintWindow : TForm;
begin
  Result := nil;
  for I := 0 to FHints.Count - 1 do
  begin
    HintWindow := FHints[I];
    R := Rect(HintWindow.Left, HintWindow.Top, HintWindow.Left + HintWindow.Width, HintWindow.Top + HintWindow.Height);
    if PtInRect(R, Point) then
    begin
      Result := HintWindow;
      Exit;
    end;
  end;
end;

class function THintManager.Instance: THintManager;
begin
  if HintManager = nil then
    HintManager := THintManager.Create;

  Result := HintManager;
end;

procedure THintManager.NewState;
begin
  FSync.Enter;
  try
    CreateGUID(FStateID);
  finally
    FSync.Leave;
  end;
end;

procedure THintManager.RegisterHint(HintWindow: TForm);
begin
  FHints.Add(HintWindow);
end;

procedure THintManager.UnRegisterHint(HintWindow: TForm);
begin
  FHints.Remove(HintWindow);
end;

end.
