object FormSelectLocation: TFormSelectLocation
  Left = 0
  Top = 0
  Caption = 'FormSelectLocation'
  ClientHeight = 540
  ClientWidth = 508
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    508
    540)
  PixelsPerInch = 96
  TextHeight = 13
  object PePath: TPathEditor
    Left = 0
    Top = 476
    Width = 508
    Height = 25
    Align = alTop
    SeparatorImage.Data = {
      9E020000424D9E0200000000000036000000280000000B0000000E0000000100
      2000000000006802000000000000000000000000000000000000000000000000
      0000898989058A8A890500000000000000000000000000000000000000000000
      000000000000000000008A8A8B058A8A8ACC8A8A89CC8A8A8B05000000000000
      0000000000000000000000000000000000000000000089898997898989FF8889
      89FF8A8A89CC8989890500000000000000000000000000000000000000000000
      00008A8A8A038A8A8ABC8A8B8BFF898989FF888989CC89898905000000000000
      000000000000000000000000000000000000888989038A8A89BC8A8A8AFF8A8A
      89FF8A8A89CC8A8A890500000000000000000000000000000000000000000000
      000089898903898989BC8A8A89FF8A8A8AFF8A8A8ACC8A8A8A05000000000000
      0000000000000000000000000000000000008A8A8A03898A8ADC898989FF8989
      89FF8A8A8ACC8989890100000000000000000000000000000000000000008989
      8947898989FF898989FF8A8B8BFF898989380000000000000000000000000000
      000000000000898989478A8A8AFF898989FF8A8A8AFF89898938000000000000
      00000000000000000000000000008A8A8A448A8A8AFF898A89FF8A8A8BFF8989
      893B00000000000000000000000000000000000000008A8A8A448A8A89FF8A8A
      8AFF8A8A8AFF8889893B00000000000000000000000000000000000000000000
      00008989893E898989FF8A8A8AFF8A8A8A3E0000000000000000000000000000
      0000000000000000000000000000000000008989893E8989893E000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000}
    OnChange = PePathChange
    LoadingText = 'Loading...'
    CanBreakLoading = False
    OnlyFileSystem = False
    HideExtendedButton = True
    ShowBorder = True
  end
  object PnExplorer: TPanel
    Left = 0
    Top = 0
    Width = 508
    Height = 476
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
  end
  object BtnCancel: TButton
    Left = 345
    Top = 507
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnCancel'
    TabOrder = 2
    OnClick = BtnCancelClick
  end
  object BtnOk: TButton
    Left = 426
    Top = 507
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'BtnOk'
    TabOrder = 3
    OnClick = BtnOkClick
  end
end
