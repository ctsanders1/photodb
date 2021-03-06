unit uListViewUtils;

interface

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  System.Math,
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ComCtrls,
  Vcl.Themes,

  Dmitry.Utils.System,
  Dmitry.Graphics.LayeredBitmap,

  EasyListview,
  UnitBitmapImageList,

  uMemory,
  uDBDrawing,
  uDBEntities,
  uGraphicUtils,
  uConstants,
  uRuntime,
  uSettings,
  uDBIcons,
  uThemesUtils,
  uBitmapUtils;

type
  TEasyCollectionItemX = class(TEasyCollectionItem)
  public
    function GetDisplayRect : TRect;
  end;

  {$HINTS OFF}
  TEasySelectionManagerX = class(TEasyOwnedPersistent)
  private
    FAlphaBlend: Boolean;
    FAlphaBlendSelRect: Boolean;
    FBlendAlphaImage: Byte;
    FBlendAlphaSelRect: Byte;
    FBlendAlphaTextRect: Byte;
    FBlendColorIcon: TColor;
    FBlendColorSelRect: TColor;
    FBlendIcon: Boolean;
    FBlurAlphaBkGnd: Boolean;
    FBorderColor: TColor;
    FBorderColorSelRect: TColor;
    FColor: TColor;
    FCount: Integer;
    FFocusedColumn: TEasyColumn;
    FFocusedItem: TEasyItem;
    FAnchorItem: TEasyItem;
    FFocusedGroup: TEasyGroup;
    FEnabled: Boolean;
    FForceDefaultBlend: Boolean;
    FFullCellPaint: Boolean;
    FFullItemPaint: Boolean;
    FFullRowSelect: Boolean;
    FGradient: Boolean;
    FGradientColorBottom: TColor;
    FGradientColorTop: TColor;
    FGroupSelections: Boolean;
    FGroupSelectUpdateCount: Integer;
    FInactiveBorderColor: TColor;
    FInactiveColor: TColor;
    FInactiveTextColor: TColor;
    FItemsToggled: Integer;
    FMouseButton: TCommonMouseButtons;
    FMultiChangeCount: Integer;
    FMultiSelect: Boolean;
    FPopupMode: Boolean;
    FRectSelect: Boolean; // A Click-Shift Select will use the Rectangle of the click and the Anchor Item vs. Selecting all from the Anchor Item Index to the selected Item index
    FResizeGroupOnFocus: Boolean; // If true and a focused caption will overlap next group, the group is resized to fit focused caption
    FRoundRect: Boolean;
    FRoundRectRadius: Byte;
    FTextColor: TColor;
    FUseFocusRect: Boolean;
  public
    property AGradientColorBottom: TColor write FGradientColorBottom;
    property AGradientColorTop: TColor write FGradientColorTop;
    property ATextColor: TColor write FTextColor;
    property AInactiveTextColor: TColor write FInactiveTextColor;
  end;
  {$HINTS ON}

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView: Integer = 0): TEasyItem;
procedure ItemRectArray(Item: TEasyItem; tmHeight: integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);
function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer; Image : TGraphic): TEasyItem;
function GetListViewHeaderHeight(ListView: TListView): Integer;
procedure SetLVThumbnailSize(ListView: TEasyListView; ImageSize: Integer);
procedure SetListViewColors(ListView: TEasyListView);
procedure SetLVSelection(ListView: TEasyListView; Multiselect: Boolean; MouseButton: TCommonMouseButtons = []);
procedure DrawDBListViewItem(ListView: TEasylistView; ACanvas: TCanvas; Item: TEasyItem;
                             ARect: TRect; BImageList: TBitmapImageList; var Y: Integer;
                             ShowInfo: Boolean; Info: TMediaItem;
                             CanAddImages: Boolean; CustomInfo: string = ''; Options: TDrawAttributesOptions = []);

procedure CreateDragImage(Bitmap: TGraphic; DragImageList: TImageList; Font: TFont; FileName: string); overload;
procedure CreateDragImage(ListView: TEasyListView; DImageList: TImageList; SImageList: TBitmapImageList; Caption : string;
                          DragPoint: TPoint; var SpotX, SpotY: Integer); overload;
procedure CreateDragImageEx(ListView: TEasyListView; DImageList: TImageList; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor: TColor; Font: TFont; Caption: string); overload;
procedure CreateDragImageEx(ListView: TEasyListView; DImageList: TImageList; SImageList : TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor: TColor; Font: TFont; Caption: string;
  DragPoint: TPoint; var SpotX, SpotY: Integer); overload;
procedure EnsureSelectionInListView(EasyListview: TEasyListview; ListItem: TEasyItem;
  Shift: TShiftState; X, Y: Integer; var ItemSelectedByMouseDown: Boolean;
  var ItemByMouseDown: Boolean);
procedure RightClickFix(EasyListview: TEasyListview; Button: TMouseButton; Shift: TShiftState; Item: TEasyItem; ItemByMouseDown, ItemSelectedByMouseDown : Boolean);
procedure CreateMultiselectImage(ListView: TEasyListView; ResultImage: TBitmap; SImageList: TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor: TColor; Font : TFont; Width, Height: Integer; OnlyImages: Boolean = False);
procedure FixListViewText(ACanvas: TCanvas; Item: TEasyItem; Include: Boolean);
procedure DrawLVBitmap32MMX(ListView: TEasylistView; ACanvas: TCanvas; Graphic: TBitmap; X: Integer; var Y: Integer; Opacity: Byte = 255);

const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK + DT_CENTER;

implementation

uses
  UnitPropeccedFilesSupport;

procedure FixListViewText(ACanvas: TCanvas; Item: TEasyItem; Include: Boolean);
var
  C: TColor;
begin
  if Item.Selected then
    C := Theme.GradientText//StyleServices.GetStyleFontColor(sfListItemTextSelected)
  else
    C := StyleServices.GetStyleFontColor(sfListItemTextNormal);
  if not Include then
    ACanvas.Font.Color := ColorDiv2(Theme.ListViewColor, C)
  else
    ACanvas.Font.Color := C;
end;

procedure DrawLVBitmap32MMX(ListView: TEasylistView; ACanvas: TCanvas; Graphic: TBitmap; X: Integer; var Y: Integer; Opacity: Byte = 255);
begin
  //this method is more compatible (xp with custom theme can work bad with MPCommonUtilities.AlphaBlend
  //ACanvas.Draw calls DrawTransparent method that calls Windows.AlphaBlend and should work good on any version of windows
  Graphic.AlphaFormat := afDefined;
  ACanvas.Draw(X, Y, Graphic, Opacity);
end;

type
  TGraphicEx = class(TGraphic);

procedure DrawDBListViewItem(ListView: TEasylistView; ACanvas: TCanvas; Item: TEasyItem;
                             ARect: TRect; BImageList: TBitmapImageList; var Y: Integer;
                             ShowInfo: Boolean; Info: TMediaItem; CanAddImages: Boolean; CustomInfo: string = '';
                             Options: TDrawAttributesOptions = []);
const
  DrawTextOpt = DT_NOPREFIX + DT_WORDBREAK;
  RoundRadius = 5;

var
  Graphic: TGraphic;
  W, H, BPP: Integer;
  ImageW, ImageH, OriginalRating: Integer;
  X: Integer;
  TempBmp, B: TBitmap;
  TempBmpShadow: TBitmap;
  RectArray: TEasyRectArrayObject;
  ColorFrom, ColorTo, ColorFromOriginal, ColorToOriginal: TColor;
  SelectionRect, R: TRect;
  DIB: TDIBSection;
  piconinfo: TIconInfo;
begin
  OriginalRating := 0;

  ACanvas.Font.Color := Theme.ListViewFontColor;
  Graphic := BImageList[Item.ImageIndex].Graphic;

  if (Graphic = nil) or Graphic.Empty then
    Exit;

  W := ARect.Right - ARect.Left;
  H := ARect.Bottom - ARect.Top + 4;
  ImageW := Graphic.Width;
  ImageH := Graphic.Height;
  ProportionalSize(W, H, ImageW, ImageH);

  X := ARect.Left + W div 2 - ImageW div 2;
  Y := ARect.Bottom - ImageH;

  ColorFromOriginal := ListView.Selection.GradientColorTop;
  ColorToOriginal := ListView.Selection.GradientColorBottom;

  if (Info <> nil) then
  begin
    OriginalRating := Info.Rating;
    Info.Include := Info.Include or (Info.ID = 0);
    if not Info.Include then
    begin
      TEasySelectionManagerX(ListView.Selection).AGradientColorTop := $A0FFFF;
      TEasySelectionManagerX(ListView.Selection).AGradientColorBottom := $A0FFFF;
    end;
  end;

  try
    if (Info <> nil) and (esosHotTracking in Item.State) and not (daoNonImage in Options) then
    begin
      if (Info.Rating = 0) and (not FolderView or (Info.ID > 0)) and CanAddImages then
        Info.Rating := -1;

      if not Item.Selected then
      begin
        Item.ItemRectArray(nil, ACanvas, RectArray);

        //HACK!
        ColorFrom := ListView.Selection.GradientColorTop;
        ColorTo := ListView.Selection.GradientColorBottom;

        TEasySelectionManagerX(ListView.Selection).AGradientColorTop := ColorDiv2(ColorDiv2(ColorDiv2(ColorFrom, ListView.Color), ListView.Color), ListView.Color);
        TEasySelectionManagerX(ListView.Selection).AGradientColorBottom := ColorDiv2(ColorDiv2(ColorDiv2(ColorTo, ListView.Color ), ListView.Color), ListView.Color);

        Item.View.PaintSelectionRect(Item, nil, Item.Caption, RectArray, ACanvas, RectArray.BoundsRect, True);

        //HACK!
        TEasySelectionManagerX(ListView.Selection).AGradientColorTop := ColorFrom;
        TEasySelectionManagerX(ListView.Selection).AGradientColorBottom := ColorTo;
      end;
    end;
    if (Info <> nil) and not Info.Include and Item.Selected then
    begin
      Item.ItemRectArray(nil, ACanvas, RectArray);
      Item.View.PaintSelectionRect(Item, nil, Item.Caption, RectArray, ACanvas, RectArray.BoundsRect, True);
    end;

    TempBmp := nil;
    TempBmpShadow := nil;
    try
      if (Graphic is TBitmap) and
        ((TBitmap(Graphic).Width > W) or (TBitmap(Graphic).Height > H)) then
      begin
        TempBmp := TBitmap.Create;
        ProportionalSizeA(W, H, ImageW, ImageH);
        StretchCool(ImageW, ImageH, TBitmap(Graphic), TempBmp);
        Graphic := TempBmp;
      end;

      if (Graphic is TBitmap) and (TBitmap(Graphic).PixelFormat = pf24Bit) then
      begin
        TempBmpShadow := TBitmap.Create;
        DrawShadowToImage(TempBmpShadow, TBitmap(Graphic));
        Graphic := TempBmpShadow;
        TBitmap(Graphic).Handle;
      end;
      if (CustomInfo <> '') and (Graphic is TBitmap) then
      begin
        if TBitmap(Graphic).PixelFormat = pf32Bit then
        begin
          R := Rect(6, TBitmap(Graphic).Height - 22, TBitmap(Graphic).Width, TBitmap(Graphic).Height - 3);
          TBitmap(Graphic).Canvas.Font := ListView.Font;
          DrawText(TBitmap(Graphic).Canvas.Handle, PChar(CustomInfo), Length(CustomInfo), R, DrawTextOpt or DT_CALCRECT);
          SelectionRect := R;
          InflateRect(SelectionRect, 3, 3);

          DrawRoundGradientVert(TBitmap(Graphic), SelectionRect,
            ListView.Selection.GradientColorBottom, ListView.Selection.GradientColorTop,
            ListView.Selection.Color, RoundRadius);
          DrawText32Bit(TBitmap(Graphic), CustomInfo, ListView.Font, R, DrawTextOpt);
          TBitmap(Graphic).Handle;
        end;
      end;
      if (Graphic is TBitmap) and (TBitmap(Graphic).PixelFormat = pf32Bit) then
      begin
        DrawLVBitmap32MMX(ListView, ACanvas, TBitmap(Graphic), X, Y, IIF(daoSemiTransparent in Options, 127, 255));
      end else
      begin
        if not (daoSemiTransparent in Options) then
          ACanvas.StretchDraw(Rect(X, Y, X + ImageW, Y + ImageH), Graphic)
        else
        begin
          if Graphic is TIcon then
          begin
            if GetIconInfo(TIcon(Graphic).Handle, piconinfo) then
            begin
              try
                GetObject(piconinfo.hbmColor, SizeOf(DIB), @DIB);
                if (DIB.dsBm.bmWidth > 16) and (DIB.dsBm.bmHeight > 16) then
                begin
                  B := TBitmap.Create;
                  try
                    B.Handle := piconinfo.hbmColor;
                    B.MaskHandle := piconinfo.hbmMask;

                    BPP := GetDeviceCaps(ACanvas.Handle, BITSPIXEL) * GetDeviceCaps(ACanvas.Handle, PLANES);
                    if BPP >= 16 then
                    begin
                      B.PixelFormat := pf32Bit;
                      B.AlphaFormat := afDefined;
                    end;

                    TGraphicEx(B).DrawTransparent(ACanvas, Rect(X, Y, X + ImageW, Y + ImageH), 127);
                  finally
                    F(B);
                  end;
                end;
              finally
                DeleteObject(piconinfo.hbmMask);
                DeleteObject(piconinfo.hbmColor);
              end;
            end;

          end else
            TGraphicEx(Graphic).DrawTransparent(ACanvas, Rect(X, Y, X + ImageW, Y + ImageH), 127);
        end;
      end;

    finally
      F(TempBmp);
      F(TempBmpShadow);
    end;

  finally
    if (Info <> nil) and not Info.Include then
    begin
      TEasySelectionManagerX(ListView.Selection).AGradientColorTop := ColorFromOriginal;
      TEasySelectionManagerX(ListView.Selection).AGradientColorBottom := ColorToOriginal;
    end;
  end;

  if (Info <> nil) and (ProcessedFilesCollection.ExistsFile(Info.FileName) <> nil) then
    DrawIconEx(ACanvas.Handle, X + 2, ARect.Bottom - 20, Icons[DB_IC_RELOADING], 16, 16, 0, 0, DI_NORMAL);

  if ShowInfo and (Info <> nil) then
    DrawAttributesEx(ACanvas.Handle, Max(ARect.Left, ARect.Right - 100), Max(ARect.Top, Y - 16), Info, Options);

  if (Info <> nil) then
    Info.Rating := OriginalRating;
end;

procedure CreateDragImage(Bitmap: TGraphic; DragImageList: TImageList; Font: TFont; FileName: string);
var
  BitmapImageList: TBitmapImageList;
  DragImage: TBitmap;
begin
  BitmapImageList := TBitmapImageList.Create;
  try
    DragImage := TBitmap.Create;
    try
      DragImage.Assign(Bitmap);
      BitmapImageList.AddBitmap(DragImage, False);
      if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
        Font.Color := Theme.GradientText;
      CreateDragImageEx(nil, DragImageList, BitmapImageList, Theme.GradientFromColor,
        Theme.GradientToColor, Theme.HighlightColor, Font, ExtractFileName(FileName));
    finally
      F(DragImage);
    end;
  finally
    F(BitmapImageList);
  end;
end;

procedure CreateDragImage(ListView: TEasyListview; DImageList: TImageList;
  SImageList: TBitmapImageList; Caption: string; DragPoint: TPoint;
  var SpotX, SpotY: Integer);
begin
  CreateDragImageEx(ListView, DImageList, SImageList,
    ListView.Selection.GradientColorBottom, ListView.Selection.GradientColorTop,
    ListView.Selection.Color, ListView.Font, Caption, DragPoint, SpotX, SpotY);
end;

procedure CreateDragImageEx(ListView: TEasyListview; DImageList: TImageList; SImageList: TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor: TColor; Font: TFont; Caption: string);
var
  X, Y: Integer;
  Point: TPoint;
begin
  CreateDragImageEx(ListView, DImageList, SImageList, GradientFrom, GradientTo, SelectionColor,
    Font, Caption, Point, X, Y);
end;

procedure DrawSelectionCount(Bitmap: TBitmap; ItemsSelected: Integer; Font: TFont; RoundRadius: Integer);
var
  AFont: TFont;
  W, H: Integer;
  R: TRect;
begin
  AFont := TFont.Create;
  try
    AFont.Assign(Font);
    AFont.Style := [fsBold];
    AFont.Size := AFont.Size + 2;
    AFont.Color := Theme.GradientText;
    W := Bitmap.Canvas.TextWidth(IntToStr(ItemsSelected));
    H := Bitmap.Canvas.TextHeight(IntToStr(ItemsSelected));
    Inc(W, 10);
    Inc(H, 10);
    R := Rect(5, 5, 5 + W, 5 + H);
    DrawRoundGradientVert(Bitmap, R, Theme.GradientFromColor, Theme.GradientToColor, Theme.HighlightColor, RoundRadius);
    DrawText32Bit(Bitmap, IntToStr(ItemsSelected), AFont, R, DT_CENTER or DT_VCENTER);
  finally
    AFont.Free;
  end;
end;

procedure CreateMultiselectImage(ListView: TEasyListView; ResultImage: TBitmap; SImageList: TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor: TColor; Font: TFont; Width, Height: Integer; OnlyImages: Boolean = False);
var
  SelCount: Integer;
  SelectedItem: TEasyItem;
  Items: array of TEasyItem;
  MaxH, MaxW, I, N, FSelCount, ItemsSelected, ImageW, ImageH: Integer;
  Graphic: TGraphic;
  DX, DY, DMax: Extended;
  TmpImage, SelectedImage: TBitmap;
  LBitmap: TLayeredBitmap;
  FocusedItem: TEasyItem;

  function LastSelected : TEasyItem;
  var
    Item: TEasyItem;
  begin
    Result := nil;
    Item := ListView.Selection.First;
    while Item <> nil do
    begin
      Result := Item;
      Item := ListView.Selection.Next(Result);
    end;
  end;

const
  MaxItems = 5;
  ImagePadding = 10;
  RoundRadius = 8;

begin
  SetLength(Items, 0);
  if ListView <> nil then
  begin
    ItemsSelected := ListView.Selection.Count;
    FSelCount := Min(MaxItems, ItemsSelected);

    SelectedItem := ListView.Selection.First;
    FocusedItem := nil;
    if ListView.Selection.FocusedItem <> nil then
      if ListView.Selection.FocusedItem.Selected then
        FocusedItem := ListView.Selection.FocusedItem;

    if FocusedItem = nil then
      FocusedItem := LastSelected;

    for I := 1 to FSelCount do
    begin
      if FocusedItem <> SelectedItem then
      begin
        if Length(Items) = FSelCount - 1 then
          Break;

        if SelectedItem <> nil then
        begin
          SetLength(Items, Length(Items) + 1);
          Items[Length(Items) - 1] := SelectedItem;
        end;
      end;
      SelectedItem := ListView.Selection.Next(SelectedItem);
    end;
    if FocusedItem <> nil then
    begin
      SetLength(Items, Length(Items) + 1);
      Items[Length(Items) - 1] := FocusedItem;
    end;
    FSelCount := Length(Items);
  end else begin
    ItemsSelected := SImageList.Count;
    FSelCount := Min(MaxItems, ItemsSelected);
  end;

  N := 0;

  MaxH := 0;
  MaxW := 0;
  for I := 1 to Length(Items) do
  begin

    if ListView <> nil then
      Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
    else
      Graphic := SImageList[I - 1].Graphic;

    MaxH := Max(MaxH, N + Graphic.Height);
    MaxW := Max(MaxW, N + Graphic.Width);
  end;

  DX := MaxW / (Width - FSelCount * (ImagePadding - 1));
  DY := MaxH / (Height  - FSelCount * (ImagePadding - 1));

  ResultImage.SetSize(Width, Height);
  FillTransparentColor(ResultImage, ClBlack, 0);

  N := 0;

  for I := 1 to FSelCount do
  begin
    if ListView <> nil then
      Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
    else
      Graphic := SImageList[I - 1].Graphic;

    if Graphic is TBitmap then
    begin
      ImageW := Graphic.Width;
      ImageH := Graphic.Height;
      ProportionalSize(Round(ImageW / DX), Round(ImageH / DY), ImageW, ImageH);
      if TBitmap(Graphic).PixelFormat = pf24bit then
      begin
        SelectedImage := TBitmap.Create;
        try
          TmpImage := TBitmap.Create;
          try
            DoResize(ImageW, ImageH, Graphic as TBitmap, TmpImage);
            DrawShadowToImage(SelectedImage, TmpImage);
            DrawImageEx32(ResultImage, SelectedImage, N, N);
          finally
            F(TmpImage);
          end;
        finally
          F(SelectedImage);
        end;
      end else if TBitmap(Graphic).PixelFormat = pf32bit then
      begin
        TmpImage := TBitmap.Create;
        try
          TmpImage.PixelFormat := pf32bit;
          DoResize(ImageW, ImageH, Graphic as TBitmap, TmpImage);
          DrawImageEx32(ResultImage, TmpImage, N, N);
        finally
          F(TmpImage);
        end;
      end;
    end else if Graphic is TIcon then
    begin
      LBitmap := TLayeredBitmap.Create;
      try
        LBitmap.LoadFromHIcon(TIcon(Graphic).Handle, TIcon(Graphic).Height, TIcon(Graphic).Width);
        DrawImageEx32(ResultImage, LBitmap, N, N);
      finally
        F(LBitmap);
      end;
    end;
    Inc(N, ImagePadding);
  end;

  DrawSelectionCount(ResultImage, ItemsSelected, Font, RoundRadius);
  ResultImage.TransparentMode := tmFixed;
  ResultImage.AlphaFormat := afDefined;
end;

procedure CreateDragImageEx(ListView: TEasyListview; DImageList: TImageList; SImageList: TBitmapImageList;
  GradientFrom, GradientTo, SelectionColor: TColor; Font: TFont; Caption: string; DragPoint: TPoint;
  var SpotX, SpotY: Integer);
var
  DragImage, TempImage: TBitmap;
  SelCount: Integer;
  SelectedItem: TEasyItem;
  I, N, MaxH, MaxW, ImH, ImW, FSelCount, ItemsSelected: Integer;
  W, H: Integer;
  ImageW, ImageH, X, Y: Integer;
  Graphic: TGraphic;
  ARect, R, SelectionRect: TRect;
  LBitmap: TLayeredBitmap;
  Items: array of TEasyItem;
  EasyRect: TEasyRectArrayObject;

const
  ImageMoveLength = 7;
  ImagePadding = 10;
  RoundRadius = 8;
  MaxItems = 6;

begin
  TempImage := TBitmap.Create;
  try
    TempImage.PixelFormat := pf32bit;

    SetLength(Items, 0);
    if ListView <> nil then
    begin
      ItemsSelected := ListView.Selection.Count;
      FSelCount := Min(MaxItems, ItemsSelected);

      SelectedItem := ListView.Selection.First;

      for I := 1 to FSelCount do
      begin
        if ListView.Selection.FocusedItem <> SelectedItem then
        begin
          SetLength(Items, Length(Items) + 1);
          Items[Length(Items) - 1] := SelectedItem;
        end;
        SelectedItem := ListView.Selection.Next(SelectedItem);
      end;
      SetLength(Items, Length(Items) + 1);
      Items[Length(Items) - 1] := ListView.Selection.FocusedItem;
      FSelCount := Length(Items);
    end else begin
      ItemsSelected := SImageList.Count;
      FSelCount := Min(MaxItems, ItemsSelected);
    end;

    MaxH := 50;
    MaxW := 50;
    N := ImagePadding - ImageMoveLength;
    for I := 1 to FSelCount do
    begin
      Inc(N, ImageMoveLength);

      if ListView <> nil then
        Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
      else
        Graphic := SImageList[I - 1].Graphic;

      MaxH := Max(MaxH, N + Graphic.Height);
      MaxW := Max(MaxW, N + Graphic.Width);
    end;
    Inc(MaxH, ImagePadding);
    Inc(MaxW, ImagePadding);

    R := Rect(3, MaxH + 3, MaxW, 1000);
    TempImage.Canvas.Font := Font;

    if StyleServices.Enabled and TStyleManager.IsCustomStyleActive then
      Font.Color := Theme.GradientText;

    DrawText(TempImage.Canvas.Handle, PChar(Caption), Length(Caption), R, DrawTextOpt or DT_CALCRECT);

    TempImage.SetSize(Max(MaxW, R.Right + 3), Max(MaxH, R.Bottom) + 5 * 2);
    FillTransparentColor(TempImage, clBlack, 1);
    SelectionRect := Rect(0, 0, TempImage.Width, TempImage.Height);

    DrawRoundGradientVert(TempImage, SelectionRect, GradientFrom, GradientTo, SelectionColor, RoundRadius);
    R.Right := TempImage.Width;
    DrawText32Bit(TempImage, Caption, Font, R, DrawTextOpt);

    N := ImagePadding - ImageMoveLength;

    for I := 1 to FSelCount do
    begin
      Inc(N, ImageMoveLength);
      if ListView <> nil then
        Graphic := SImageList[Items[I - 1].ImageIndex].Graphic
      else
        Graphic := SImageList[I - 1].Graphic;

      if Graphic is TBitmap then
      begin
        if TBitmap(Graphic).PixelFormat = pf24bit then
        begin
          DragImage := TBitmap.Create;
          try
            DrawShadowToImage(DragImage, Graphic as TBitmap, 1);
            DrawImageEx32(TempImage, DragImage, N, N);
          finally
            F(DragImage);
          end;
        end else if TBitmap(Graphic).PixelFormat = pf32bit then
        begin
          DrawImageEx32(TempImage, Graphic as TBitmap, N, N);
        end;
      end else if Graphic is TIcon then
      begin
        LBitmap := TLayeredBitmap.Create;
        try
          LBitmap.LoadFromHIcon(TIcon(Graphic).Handle, TIcon(Graphic).Height, TIcon(Graphic).Width);
          DrawImageEx32(TempImage, LBitmap, N, N);
        finally
          F(LBitmap);
        end;
      end;
    end;

    if ItemsSelected > 1 then
      DrawSelectionCount(TempImage, ItemsSelected, Font, RoundRadius);

    if ListView <> nil then
    begin
      Graphic := SImageList.Items[ListView.Selection.FocusedItem.ImageIndex].Graphic;

      ListView.Selection.FocusedItem.ItemRectArray(nil, ListView.Canvas, EasyRect);
      ARect := EasyRect.IconRect;

      W := ARect.Right - ARect.Left;
      H := ARect.Bottom - ARect.Top;
      ImageW := Graphic.Width;
      ImageH := Graphic.Height;
      ProportionalSize(W, H, ImageW, ImageH);

      X := ARect.Left + W div 2 - ImageW div 2;
      Y := ARect.Bottom - ImageH;

      SpotX := Min(MaxW, Max(1, DragPoint.X + N - X));
      SpotY := Min(MaxH, Max(1, DragPoint.Y + N - Y + ListView.Scrollbars.ViewableViewportRect.Top));
    end;

    DImageList.Clear;

    DImageList.SetSize(TempImage.Width, TempImage.Height);
    DImageList.Add(TempImage, nil);
  finally
    F(TempImage);
  end;
end;

procedure SetListViewColors(ListView: TEasyListView);
begin
  ListView.Font.Name := 'Tahoma';
  if StyleServices.Enabled then
  begin
    ListView.Color := StyleServices.GetStyleColor(scListView);

    ListView.Selection.GradientColorTop := Theme.GradientFromColor;
    ListView.Selection.GradientColorBottom := Theme.GradientToColor;
    ListView.Selection.TextColor := Theme.GradientText;

    ListView.Selection.InactiveTextColor := StyleServices.GetStyleFontColor(sfListItemTextSelected);
    ListView.Selection.Color := StyleServices.GetSystemColor(clHighlight);
    ListView.Selection.InactiveColor := Theme.GradientToColor;
    ListView.Selection.BorderColor := StyleServices.GetSystemColor(clHighlight);
    ListView.Selection.InactiveBorderColor := StyleServices.GetSystemColor(clHighlight);
    ListView.Selection.BlendColorSelRect := StyleServices.GetSystemColor(clHighlight);
    ListView.Selection.BorderColorSelRect := StyleServices.GetSystemColor(clHighlight);
    ListView.Font.Color := StyleServices.GetStyleFontColor(sfListItemTextNormal);
    ListView.HotTrack.Color := StyleServices.GetStyleFontColor(sfListItemTextHot);
    ListView.GroupFont.Color := StyleServices.GetStyleFontColor(sfListItemTextNormal);
  end else
  begin
    ListView.Selection.GradientColorBottom := clGradientActiveCaption;
    ListView.Selection.GradientColorTop := clGradientInactiveCaption;
    ListView.Selection.TextColor := clWindowText;
    ListView.HotTrack.Color := clWindowText;
    ListView.Font.Color := clWindowText;
    ListView.GroupFont.Color := ClWindowText;
  end;
end;

procedure SetLVSelection(ListView: TEasyListView; Multiselect: Boolean; MouseButton: TCommonMouseButtons = []);
begin
  ListView.Selection.MouseButton := MouseButton;
  ListView.Selection.AlphaBlend := True;
  ListView.Selection.AlphaBlendSelRect := True;
  if Multiselect then
  begin
    ListView.Selection.MultiSelect := True;
    ListView.Selection.RectSelect := True;
    ListView.Selection.EnableDragSelect := True;
  end;
  ListView.Selection.FullItemPaint := True;
  ListView.Selection.Gradient := True;
  SetListViewColors(ListView);

  ListView.Selection.RoundRect := True;
  ListView.Selection.UseFocusRect := False;

  ListView.PaintInfoItem.ShowBorder := False;
  ListView.HotTrack.Cursor := crArrow;
  ListView.HotTrack.Enabled := AppSettings.Readbool('Options', 'UseHotSelect', True);
end;

procedure SetLVThumbnailSize(ListView: TEasyListView; ImageSize: Integer);
const
  LVWidthBetweenItems = 20;
  MarginRight = 0;
  MarginLeft = 0;
var
  ColumnCount, ThWidth, WndWidth: Integer;
  Metrics: TTextMetric;
begin

  WndWidth := ListView.ClientWidth - 1;
  if not ListView.Scrollbars.VertBarVisible then
    WndWidth := WndWidth - GetSystemMetrics(SM_CYVSCROLL);

  ThWidth := ImageSize + ListView.PaintInfoItem.Border * 4;

  ColumnCount := WndWidth div ThWidth;
  if ColumnCount = 0 then
    Inc(ColumnCount);

  GetTextMetrics(ListView.Canvas.Handle, Metrics);

  ListView.CellSizes.Thumbnail.Width := WndWidth div ColumnCount;
  ListView.CellSizes.Thumbnail.Height := ImageSize + Metrics.tmHeight * 2 + ListView.PaintInfoItem.Border * 3;
  ListView.Selection.RoundRect := True;
  if ListView.View = elsThumbnail then
    ListView.Selection.RoundRectRadius := Min(10, ImageSize div 10)
  else
    ListView.Selection.RoundRectRadius := 5;
end;

function GetListViewHeaderHeight(ListView: TListView): Integer;
var
  Header_Handle: HWND;
  WindowPlacement: TWindowPlacement;
begin
  Header_Handle := ListView_GetHeader(ListView.Handle);
  FillChar(WindowPlacement, SizeOf(WindowPlacement), 0);
  WindowPlacement.Length := SizeOf(WindowPlacement);
  GetWindowPlacement(Header_Handle, @WindowPlacement);
  Result  := WindowPlacement.rcNormalPosition.Bottom - WindowPlacement.rcNormalPosition.Top;
end;

procedure ItemRectArray(Item: TEasyItem; tmHeight : integer; var RectArray: TEasyRectArrayObject; ListView : Integer = 0);
var
  PositionIndex: Integer;
begin
  if Assigned(Item) then
  begin
    if not Item.Initialized then
      Item.Initialized := True;
      PositionIndex := 0;

    if PositionIndex > -1 then
    begin
      FillChar(RectArray, SizeOf(RectArray), #0);
      try
        RectArray.BoundsRect := TEasyCollectionItemX(Item).GetDisplayRect;
        if ListView = 0 then
          InflateRect(RectArray.BoundsRect, -Item.Border, -Item.Border);

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.IconRect := RectArray.BoundsRect;
        RectArray.IconRect.Bottom := RectArray.IconRect.Bottom - tmHeight * 2;

        // Calculate area that the Checkbox may be drawn
        RectArray.CheckRect.Top := RectArray.IconRect.Bottom;
        RectArray.CheckRect.Left := RectArray.BoundsRect.Left;
        RectArray.CheckRect.Bottom := RectArray.BoundsRect.Bottom;
        RectArray.CheckRect.Right := RectArray.CheckRect.Left;

        // Calcuate the Bounds of the Cell that is allowed to be drawn in
        // **********
        RectArray.LabelRect.Left := RectArray.CheckRect.Right + Item.CaptionIndent;
        RectArray.LabelRect.Top := RectArray.IconRect.Bottom + 1;
        RectArray.LabelRect.Right := RectArray.BoundsRect.Right;
        RectArray.LabelRect.Bottom := RectArray.BoundsRect.Bottom;

        // Calcuate the Text rectangle based on the current text
        // **********
        RectArray.TextRect := RectArray.LabelRect;
        // Leave room for a small border between edge of the selection rect and text
        if ListView = 0 then
          InflateRect(RectArray.TextRect, -2, -2);

      finally
      end;
    end
  end
end;

function ItemByPointImage(EasyListview: TEasyListview; ViewportPoint: TPoint; ListView: Integer = 0): TEasyItem;
var
  I: Integer;
  R: TRect;
  RectArray: TEasyRectArrayObject;
  ACanvas: TCanvas;
  Metrics: TTextMetric;
  Item: TEasyItem;
begin
  Result := nil;
  I := 0;
  R := EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X := ViewportPoint.X + R.Left;
  ViewportPoint.Y := ViewportPoint.Y + R.Top;
  ACanvas := EasyListview.Canvas;
  GetTextMetrics(ACanvas.Handle, Metrics);

  while not Assigned(Result) and (I < EasyListview.Items.Count) do
  begin
    Item := EasyListview.Items[I];
    if Item.OwnerGroup.Expanded then
    begin
      ItemRectArray(Item, Metrics.TmHeight, RectArray);

      if PtInRect(RectArray.BoundsRect, ViewportPoint) then
        Result := Item;
    end;

    Inc(I);
  end
end;

function ItemByPointStar(EasyListview: TEasyListview; ViewportPoint: TPoint; PictureSize : Integer; Image : TGraphic): TEasyItem;
var
  I: Integer;
  R: TRect;
  RectArray: TEasyRectArrayObject;
  T, L, A, B, W, H, Y: Integer;
  ImageW, ImageH : Integer;
  Item: TEasyItem;
begin
  Result := nil;
  I := 0;
  R := EasyListview.Scrollbars.ViewableViewportRect;
  ViewportPoint.X := ViewportPoint.X + R.Left;
  ViewportPoint.Y := ViewportPoint.Y + R.Top;
  while not Assigned(Result) and (I < EasyListview.Items.Count) do
  begin
    Item := EasyListview.Items[I];
    if Item.OwnerGroup.Expanded and Item.Visible then
    begin
      Item.ItemRectArray(EasyListview.Header.FirstColumn, EasyListview.Canvas, RectArray);
      A := EasyListview.CellSizes.Thumbnail.Width - 35;
      B := 0;

      W := RectArray.IconRect.Right - RectArray.IconRect.Left;
      H := RectArray.IconRect.Bottom - RectArray.IconRect.Top;
      ImageW := Image.Width;
      ImageH := Image.Height;
      ProportionalSize(W, H, ImageW, ImageH);
      Y := RectArray.IconRect.Bottom - ImageH;

      T := Max(RectArray.IconRect.Top, Y - 20);
      L := RectArray.IconRect.Left;
      R := Rect(A + L, B + T, A + 22 + L, B + T + 18);
      if PtInRect(R, ViewportPoint) then
        Result := Item;
    end;
    Inc(I)
  end
end;

procedure EnsureSelectionInListView(EasyListview: TEasyListview; ListItem : TEasyItem;
  Shift: TShiftState; X, Y: Integer; var ItemSelectedByMouseDown : Boolean;
  var ItemByMouseDown : Boolean);
var
  R: TRect;
  I: Integer;
begin
  R := EasyListview.Scrollbars.ViewableViewportRect;
  if (ListItem <> nil) and ListItem.SelectionHitPt(Point(X + R.Left, Y + R.Top), EshtClickSelect) then
  begin

    ItemSelectedByMouseDown := False;
    if not ListItem.Selected then
    begin
      if [SsCtrl, SsShift] * Shift = [] then
        for I := 0 to EasyListview.Items.Count - 1 do
          if EasyListview.Items[I].Selected then
            if ListItem <> EasyListview.Items[I] then
              EasyListview.Items[I].Selected := False;
      if [SsShift] * Shift <> [] then
        EasyListview.Selection.SelectRange(ListItem, EasyListview.Selection.FocusedItem, False, False)
      else
      begin
        ItemSelectedByMouseDown := True;
        ListItem.Selected := True;
        ListItem.Focused := True;
      end;
    end else
      ItemByMouseDown := True;

    ListItem.Focused := True;
  end;
end;

procedure RightClickFix(EasyListview: TEasyListview; Button: TMouseButton; Shift: TShiftState; Item : TEasyItem; ItemByMouseDown, ItemSelectedByMouseDown : Boolean);
var
  I: Integer;
begin
  if Item <> nil then
    if Item.Selected and (Button = MbLeft) then
    begin
      if (Shift = []) and Item.Selected then
        if ItemByMouseDown then
        begin
          for I := 0 to EasyListview.Items.Count - 1 do
            if EasyListview.Items[I].Selected then
              if Item <> EasyListview.Items[I] then
                EasyListview.Items[I].Selected := False;
        end;
      if not(EbcsDragSelecting in EasyListview.States) then
        if ([SsCtrl] * Shift <> []) and not ItemSelectedByMouseDown then
          Item.Selected := False;
    end;
end;

{ TEasyCollectionItemX }

function TEasyCollectionItemX.GetDisplayRect: TRect;
begin
  Result := DisplayRect;
end;

end.
