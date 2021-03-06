object BigImagesSizeForm: TBigImagesSizeForm
  Left = 192
  Top = 114
  BorderStyle = bsToolWindow
  Caption = 'BigImagesSizeForm'
  ClientHeight = 176
  ClientWidth = 158
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TrbImageSize: TTrackBar
    Left = 0
    Top = 0
    Width = 45
    Height = 176
    Align = alLeft
    Max = 50
    Min = 1
    Orientation = trVertical
    Position = 1
    TabOrder = 0
    OnChange = TrbImageSizeChange
  end
  object Panel1: TPanel
    Left = 45
    Top = 0
    Width = 113
    Height = 176
    Align = alClient
    TabOrder = 1
    object RgPictureSize: TRadioGroup
      Left = 1
      Top = 1
      Width = 111
      Height = 144
      Align = alTop
      Caption = 'Big Images Size:'
      ItemIndex = 1
      Items.Strings = (
        'Other (215x215)'
        '300x300'
        '250x250'
        '200x200'
        '150x150'
        '100x100'
        '85x85')
      TabOrder = 0
      OnClick = RgPictureSizeClick
    end
    object LnkClose: TWebLink
      Left = 48
      Top = 151
      Width = 47
      Height = 16
      Cursor = crHandPoint
      Text = 'Close'
      OnClick = LnkCloseClick
      ImageIndex = 0
      UseEnterColor = False
      EnterColor = clBlack
      EnterBould = False
      TopIconIncrement = 0
      UseSpecIconSize = True
      HightliteImage = False
      StretchImage = True
      CanClick = True
    end
  end
  object TimerActivate: TTimer
    Interval = 200
    OnTimer = TimerActivateTimer
    Left = 32
    Top = 24
  end
end
