object FormManager: TFormManager
  Left = 248
  Top = 180
  Caption = 'FormManager'
  ClientHeight = 146
  ClientWidth = 229
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object AevMain: TApplicationEvents
    OnMessage = AevMainMessage
    Left = 16
    Top = 8
  end
end
