unit uBox;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Themes,
  Dmitry.Controls.WebLink;

type
  TBox = class(TPanel)
  private
    FIsHovered: Boolean;
    FIsSelected: Boolean;
    procedure SetIsHovered(const Value: Boolean);
    procedure SetIsSelected(const Value: Boolean);
  protected
    procedure Paint; override;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    procedure UpdateSubControls;
    property IsHovered: Boolean read FIsHovered write SetIsHovered;
    property IsSelected: Boolean read FIsSelected write SetIsSelected;
  end;

implementation

{ TBox }

constructor TBox.Create(AOwner: TComponent);
begin
  FIsHovered := False;
  FIsSelected := False;
  inherited;
end;

procedure TBox.Paint;
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
  VerticalAlignments: array[TVerticalAlignment] of Longint = (DT_TOP, DT_BOTTOM, DT_VCENTER);
var
  Rect: TRect;
  LColor: TColor;
  LStyle: TCustomStyleServices;
  LDetails: TThemedElementDetails;
  TopColor, BottomColor: TColor;
  BaseColor, BaseTopColor, BaseBottomColor: TColor;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := BaseTopColor;
    if Bevel = bvLowered then
      TopColor := BaseBottomColor;
    BottomColor := BaseBottomColor;
    if Bevel = bvLowered then
      BottomColor := BaseTopColor;
  end;

begin
  Rect := GetClientRect;

  BaseColor := Color;
  BaseTopColor := clBtnHighlight;
  BaseBottomColor := clBtnShadow;
  LStyle := StyleServices;
  if LStyle.Enabled then
  begin
    LDetails := LStyle.GetElementDetails(tpPanelBackground);
    if LStyle.GetElementColor(LDetails, ecFillColor, LColor) and (LColor <> clNone) then
      BaseColor := LColor;
    LDetails := LStyle.GetElementDetails(tpPanelBevel);
    if LStyle.GetElementColor(LDetails, ecEdgeHighLightColor, LColor) and (LColor <> clNone) then
      BaseTopColor := LColor;
    if LStyle.GetElementColor(LDetails, ecEdgeShadowColor, LColor) and (LColor <> clNone) then
      BaseBottomColor := LColor;
  end;

  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  if not (LStyle.Enabled and (csParentBackground in ControlStyle)) then
    Frame3D(Canvas, Rect, BaseColor, BaseColor, BorderWidth)
  else
    InflateRect(Rect, -Integer(BorderWidth), -Integer(BorderWidth));
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    if FIsSelected or IsHovered then
    begin
      Brush.Color := StyleServices.GetSystemColor(clHighlight);
      FillRect(Rect);
    end else
    begin
      Brush.Color := StyleServices.GetStyleColor(scPanel);
      FillRect(Rect);
    end;
  end;
end;

procedure TBox.SetIsHovered(const Value: Boolean);
begin
  FIsHovered := Value;
  UpdateSubControls;
  Invalidate;
end;

procedure TBox.SetIsSelected(const Value: Boolean);
begin
  FIsSelected := Value;
  UpdateSubControls;
  Invalidate;
end;

procedure TBox.UpdateSubControls;
var
  WL: TWebLink;
  I: Integer;
begin
  for I := 0 to ControlCount - 1 do
    if Controls[I] is TWebLink then
    begin
      WL := TWebLink(Controls[I]);
      if IsHovered or IsSelected then
      begin
        WL.Color := StyleServices.GetSystemColor(clHighlight);
        WL.Font.Color := StyleServices.GetSystemColor(clHighlightText);
      end else
      begin
        WL.Color := StyleServices.GetStyleColor(scPanel);
        WL.Font.Color := StyleServices.GetStyleFontColor(sfPanelTextNormal);
      end;
    end;
end;

procedure TBox.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

end.
