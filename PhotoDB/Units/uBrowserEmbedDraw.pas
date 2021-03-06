unit uBrowserEmbedDraw;

interface

uses
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.OleCtrls,

  MSHTML,

  ExplorerTypes,

  uConstants,
  uMemory,
  uBitmapUtils;

type
  _HTML_PAINT_XFORM = packed record
    eM11: Single;
    eM12: Single;
    eM21: Single;
    eM22: Single;
    eDx: Single;
    eDy: Single;
  end;

  P_HTML_PAINT_DRAW_INFO = ^_HTML_PAINT_DRAW_INFO;
  _HTML_PAINT_DRAW_INFO = packed record
    rcViewport: tagRECT;
    hrgnUpdate: Pointer;
    xform: _HTML_PAINT_XFORM;
  end;

  PtagRECT = ^tagRECT;

  _HTML_PAINTER_INFO = packed record
    lFlags: Integer;
    lZOrder: Integer;
    iidDrawObject: TGUID;
    rcExpand: tagRECT;
  end;

  tagSIZE = packed record
    cx: Integer;
    cy: Integer;
  end;

  IHTMLPaintSite = interface(IUnknown)
    ['{3050F6A7-98B5-11CF-BB82-00AA00BDCE0B}']
    function InvalidatePainterInfo: HResult; stdcall;
    function InvalidateRect(prcInvalid: PtagRECT): HResult; stdcall;
    function InvalidateRegion(var rgnInvalid: Pointer): HResult; stdcall;
    function GetDrawInfo(lFlags: Integer;
      out pDrawInfo: _HTML_PAINT_DRAW_INFO): HResult; stdcall;
    function TransformGlobalToLocal(ptGlobal: tagPOINT;
      out pptLocal: tagPOINT): HResult; stdcall;
    function TransformLocalToGlobal(ptLocal: tagPOINT;
      out pptGlobal: tagPOINT): HResult; stdcall;
    function GetHitTestCookie(out plCookie: Integer): HResult; stdcall;
  end;

  IHTMLPainter = interface(IUnknown)
    ['{3050F6A6-98B5-11CF-BB82-00AA00BDCE0B}']
    function Draw(rcBounds: tagRECT; rcUpdate: tagRECT; lDrawFlags: Integer;
      hdc: hdc; pvDrawObject: Pointer): HResult; stdcall;
    function onresize(size: tagSIZE): HResult; stdcall;
    function GetPainterInfo(out pInfo: _HTML_PAINTER_INFO): HResult; stdcall;
    function HitTestPoint(pt: tagPOINT; out pbHit: Integer;
      out plPartID: Integer): HResult; stdcall;
  end;

  TElementBehavior = class(TInterfacedObject, IElementBehavior, IHTMLPainter)
  private
    FPaintSite: IHTMLPaintSite;
    FExplorer: TCustomExplorerForm;
  public
    constructor Create(Explorer: TCustomExplorerForm);
    { IElementBehavior }
    function Init(const pBehaviorSite: IElementBehaviorSite): HResult; stdcall;
    function Notify(lEvent: Integer; var pVar: OleVariant): HResult; stdcall;
    function Detach: HResult; stdcall;
    { IHTMLPainter }
    function Draw(rcBounds: tagRECT; rcUpdate: tagRECT; lDrawFlags: Integer;
      hdc: hdc; pvDrawObject: Pointer): HResult; stdcall;
    function onresize(size: tagSIZE): HResult; stdcall;
    function GetPainterInfo(out pInfo: _HTML_PAINTER_INFO): HResult; stdcall;
    function HitTestPoint(pt: tagPOINT; out pbHit: Integer;
      out plPartID: Integer): HResult; stdcall;
  end;

  TElementBehaviorFactory = class(TInterfacedObject, IElementBehaviorFactory)
  private
    FElemBehavior: IElementBehavior;
  public
    constructor Create(Owner: TCustomExplorerForm);
    destructor Destroy; override;
    function FindBehavior(const bstrBehavior: WideString;
      const bstrBehaviorUrl: WideString; const pSite: IElementBehaviorSite;
      out ppBehavior: IElementBehavior): HResult; stdcall;
  end;

implementation

{ TElementBehaviorFactory }

constructor TElementBehaviorFactory.Create(Owner: TCustomExplorerForm);
begin
  FElemBehavior := TElementBehavior.Create(Owner);
end;

destructor TElementBehaviorFactory.Destroy;
begin
  FElemBehavior := nil;
  inherited;
end;

function TElementBehaviorFactory.FindBehavior(const bstrBehavior,
  bstrBehaviorUrl: WideString; const pSite: IElementBehaviorSite;
  out ppBehavior: IElementBehavior): HResult;
begin
  ppBehavior := FElemBehavior;
  Result := S_OK;
end;

{ TElementBehavior }

function TElementBehavior.Draw(rcBounds, rcUpdate: tagRECT; lDrawFlags: Integer;
  hdc: hdc; pvDrawObject: Pointer): HResult;
var
  G: TGraphic;
  W, H: Integer;
  B, Bitmap, SB: TBitmap;
begin
  { Draw embed object }
  Bitmap := TBitmap.Create;
  try
    FExplorer.GetCurrentImage(MapImageWidth, MapImageHeight, G);
    try
      if G <> nil then
      begin
        Bitmap.PixelFormat := pf24Bit;
        W := rcBounds.Right - rcBounds.Left;
        H := rcBounds.Bottom - rcBounds.Top;
        Bitmap.SetSize(W, H);
        FillColorEx(Bitmap, clWhite);

        if G is TIcon then
          Bitmap.Canvas.Draw(W div 2 - G.Width div 2, H div 2 - G.Height div 2, G);

        if G is TBitmap then
        begin
          B := TBitmap(G);
          if B.PixelFormat = pf24Bit then
          begin
            SB := TBitmap.Create;
            try
              KeepProportions(B, W - 4, H - 4);
              G := B;
              DrawShadowToImage(SB, B);

              DrawImageEx32To24(Bitmap, SB, W div 2 - SB.Width div 2, H div 2 - SB.Height div 2);
            finally
              F(SB);
            end;
          end;
          if B.PixelFormat = pf32Bit then
            DrawImageEx32To24(Bitmap, B, W div 2 - B.Width div 2, H div 2 - B.Height div 2);

        end;

        with rcBounds do
          BitBlt(hdc, Left, Top, W, H, Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
      end;
    finally
      F(G);
    end;
  finally
    F(Bitmap);
  end;
  Result := S_OK;
end;

function TElementBehavior.GetPainterInfo(out pInfo: _HTML_PAINTER_INFO): HResult;
{const
  HTMLPAINTER_OPAQUE = $00000001;
  HTMLPAINT_ZORDER_WINDOW_TOP = $00000008;    }
begin
  with pInfo do
  begin
    lFlags := HTMLPAINTER_OPAQUE;
    lZOrder := HTMLPAINT_ZORDER_REPLACE_ALL;
    FillChar(rcExpand, SizeOf(TRect), 0);
  end;
  Result := S_OK;
end;

function TElementBehavior.HitTestPoint(pt: tagPOINT; out pbHit,
  plPartID: Integer): HResult;
begin
  { Dummy }
  Result := E_NOTIMPL;
end;

function TElementBehavior.onresize(size: tagSIZE): HResult;
begin
  Result := S_OK;
end;

constructor TElementBehavior.Create(Explorer: TCustomExplorerForm);
begin
  FExplorer := Explorer;
end;

function TElementBehavior.Detach: HResult;
begin
  if Assigned(FPaintSite) then
    FPaintSite.InvalidateRect(nil);
  Result := S_OK;
end;

function TElementBehavior.Init(
  const pBehaviorSite: IElementBehaviorSite): HResult;
begin
  Result := pBehaviorSite.QueryInterface(IHTMLPaintSite, FPaintSite);
  if Assigned(FPaintSite) then
    FPaintSite.InvalidateRect(nil);
end;

function TElementBehavior.Notify(lEvent: Integer;
  var pVar: OleVariant): HResult;
begin
  Result := E_NOTIMPL;
end;

end.
