object FormSizeResizer: TFormSizeResizer
  Left = 366
  Top = 205
  Caption = 'Change Image'
  ClientHeight = 515
  ClientWidth = 394
  Color = clBtnFace
  Constraints.MinHeight = 540
  Constraints.MinWidth = 410
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  DesignSize = (
    394
    515)
  PixelsPerInch = 96
  TextHeight = 13
  object LbInfo: TLabel
    Left = 8
    Top = 8
    Width = 378
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'You can resize you image(s) and convert they in other graphic fo' +
      'rmat, which you can select in combobox follow:'
    WordWrap = True
    ExplicitWidth = 429
  end
  object PbImage: TPaintBox
    Left = 8
    Top = 56
    Width = 377
    Height = 183
    Anchors = [akLeft, akTop, akRight, akBottom]
    OnContextPopup = PbImageContextPopup
    OnPaint = PbImagePaint
    ExplicitHeight = 184
  end
  object BtOk: TButton
    Left = 311
    Top = 484
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Enabled = False
    TabOrder = 6
    OnClick = BtOkClick
  end
  object BtCancel: TButton
    Left = 230
    Top = 484
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = BtCancelClick
  end
  object BtSaveAsDefault: TButton
    Left = 8
    Top = 484
    Width = 153
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Save settings as default'
    TabOrder = 2
    OnClick = BtSaveAsDefaultClick
  end
  object EdImageName: TEdit
    Left = 38
    Top = 270
    Width = 318
    Height = 21
    TabStop = False
    Anchors = [akLeft, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = 'Image Name'
    OnEnter = EdImageNameEnter
  end
  object LsMain: TLoadingSign
    Left = 358
    Top = 63
    Width = 28
    Height = 28
    Active = True
    FillPercent = 50
    Anchors = [akTop, akRight]
    SignColor = clHighlight
    MaxTransparencity = 255
  end
  object PrbMain: TDmProgress
    Left = 8
    Top = 246
    Width = 378
    Height = 18
    Visible = False
    Anchors = [akLeft, akRight, akBottom]
    Position = 0
    MinValue = 0
    MaxValue = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 16711808
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Text = 'Progress... (&%%)'
    BorderColor = 38400
    CoolColor = 38400
    Color = clBlack
    View = dm_pr_cool
    Inverse = False
  end
  object PnOptions: TPanel
    Left = 0
    Top = 300
    Width = 394
    Height = 182
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      394
      182)
    object LbSizeSeparator: TLabel
      Left = 329
      Top = 84
      Width = 6
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'X'
      Enabled = False
    end
    object CbWatermark: TCheckBox
      Left = 8
      Top = 0
      Width = 115
      Height = 17
      Caption = 'Add watermark'
      TabOrder = 0
      OnClick = CbWatermarkClick
    end
    object CbConvert: TCheckBox
      Left = 8
      Top = 28
      Width = 118
      Height = 17
      Caption = 'Convert:'
      TabOrder = 2
      OnClick = CbConvertClick
    end
    object DdConvert: TComboBox
      Left = 128
      Top = 27
      Width = 146
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 3
      OnChange = DdConvertChange
    end
    object BtJPEGOptions: TButton
      Left = 280
      Top = 26
      Width = 106
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'JPEG Optinons'
      DoubleBuffered = False
      ParentDoubleBuffered = False
      TabOrder = 4
      OnClick = BtJPEGOptionsClick
    end
    object DdRotate: TComboBox
      Left = 128
      Top = 54
      Width = 146
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 5
      OnChange = DdRotateChange
    end
    object CbRotate: TCheckBox
      Left = 8
      Top = 56
      Width = 118
      Height = 17
      Caption = 'Rotate:'
      TabOrder = 6
      OnClick = CbRotateClick
    end
    object CbResize: TCheckBox
      Left = 8
      Top = 84
      Width = 118
      Height = 17
      Caption = 'Resize:'
      TabOrder = 7
      OnClick = CbResizeClick
    end
    object DdResizeAction: TComboBox
      Left = 128
      Top = 81
      Width = 146
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 20
      Enabled = False
      TabOrder = 8
      OnChange = DdResizeActionChange
    end
    object EdWidth: TEdit
      Left = 280
      Top = 81
      Width = 41
      Height = 21
      Anchors = [akTop, akRight]
      Enabled = False
      TabOrder = 9
      Text = '1024'
      OnExit = EdWidthExit
      OnKeyPress = EdHeightKeyPress
    end
    object EdHeight: TEdit
      Left = 345
      Top = 81
      Width = 41
      Height = 21
      Anchors = [akTop, akRight]
      Enabled = False
      TabOrder = 10
      Text = '768'
      OnExit = EdWidthExit
      OnKeyPress = EdHeightKeyPress
    end
    object CbAspectRatio: TCheckBox
      Left = 128
      Top = 110
      Width = 258
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Preserve aspect ratio'
      Checked = True
      State = cbChecked
      TabOrder = 11
      OnClick = CbAspectRatioClick
    end
    object CbAddSuffix: TCheckBox
      Left = 128
      Top = 128
      Width = 258
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Add filename suffix'
      Checked = True
      State = cbChecked
      TabOrder = 12
    end
    object BtChangeDirectory: TButton
      Left = 367
      Top = 151
      Width = 19
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '...'
      TabOrder = 13
      OnClick = BtChangeDirectoryClick
    end
    object BtWatermarkOptions: TButton
      Left = 116
      Top = 0
      Width = 158
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'Watermark Optinons'
      DoubleBuffered = False
      Enabled = False
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = BtWatermarkOptionsClick
    end
    object PeSavePath: TPathEditor
      Left = 10
      Top = 151
      Width = 351
      Height = 25
      DoubleBuffered = False
      ParentDoubleBuffered = False
      Anchors = [akLeft, akTop, akRight]
      LoadingText = 'Loading...'
      CanBreakLoading = False
      OnlyFileSystem = True
      HideExtendedButton = True
      ShowBorder = True
    end
  end
  object WlBack: TWebLink
    Left = 8
    Top = 268
    Width = 29
    Height = 24
    Cursor = crHandPoint
    Anchors = [akLeft, akBottom]
    Enabled = False
    OnClick = WlBackClick
    ImageIndex = 0
    IconWidth = 24
    IconHeight = 24
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    Icon.Data = {
      0000010001001818000001002000880900001600000028000000180000003000
      0000010020000000000060090000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F9F89277F9F893B0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000001F0A1805802CDE309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000001F0A080A8331C93B9E5AFF309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000A8230B443A261FF96D6AAFF309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000D6E
      2C943E9E5CFFB6EFCAFFABDFBBFF309650FF309650FF309650FF309650FF3096
      50FF309650FF309650FF309650FF309650FF0000000000000000000000000000
      000000000000000000000000000000000000000000000000000011722F74389A
      57FFC8F0D6FF5EEF97FFE2F9E9FFAFDFBEFFABDFBBFFA7DFB8FFA3DFB6FF9FDF
      B3FF9BDFB1FF97DFAEFF94DFABFF309650FF0000000000000000000000000000
      000000000000000000000000000000000000000000001375325B329752FFD7EF
      DFFF65F19BFF5FF097FFF7FFF9FFF2FFF6FFEDFFF2FFE7FFEFFFE2FFEBFFDDFF
      E8FFD8FFE4FFD3FFE1FFCEFFDDFF309650FF0000000000000000000000000000
      00000000000000000000000000000000000016672F422D954EFFD3E9DAFF87F4
      B1FF55EF91FF54EF90FF64F09AFF60F098FF5CF095FF58EF93FF54EE90FF50EE
      8EFF4DED8CFF81F4ADFFD7FFE4FF309650FF0000000000000000000000000000
      0000000000000000000000000000185B2D311F8D42F9C4E0CDFFABF8C8FF61F1
      99FF5DF197FF5AF094FF56F092FF52EF8FFF4FEE8DFF4BEE8AFF47ED88FF43EC
      86FF40EC83FF7CF3AAFFE1FFEAFF309650FF0000000000000000000000000000
      00000000000000000000195E2E261A8B3EF4B2D7BEFFCCFBDEFF6EF3A1FF6AF3
      9FFF66F29CFF63F29AFF5FF197FF5BF095FF57F093FF54EF90FF50EF8EFF4CEE
      8BFF49ED89FF85F4B0FFEBFFF1FF309650FF0000000000000000000000000000
      0000000000000000000016893BE599CBA9FFE5FDEEFF7EF6ABFF76F5A7FF73F4
      A4FF6FF4A2FF6BF3A0FF68F29DFF64F29BFF60F198FF5CF196FF59F093FF55EF
      91FF51EF8FFF8EF4B6FFF5FFF8FF309650FF0000000000000000000000000000
      0000000000000000000016893BE599CBA9FFDCFDE8FF85F7B0FF7FF6ADFF7CF6
      AAFF78F5A8FF74F4A5FF70F4A3FF6DF3A0FF69F39EFF65F29CFF62F199FF5EF1
      97FF5AF094FF96F5BBFFFDFFFEFF309650FF0000000000000000000000000000
      00000000000000000000195E2E261A8B3EF4B2D7BEFFCAFCDCFF88F8B2FF84F7
      B0FF80F7ADFF7DF6ABFF79F5A9FF75F5A6FF72F4A4FF6EF3A1FF6AF39FFF66F2
      9CFF63F29AFF9BF6BFFFFFFFFFFF309650FF0000000000000000000000000000
      0000000000000000000000000000185B2D311F8D42F9C4E0CDFFB7FBD1FF8DF9
      B5FF89F8B3FF86F7B1FF82F7AEFF7EF6ACFF7AF6A9FF76F5A7FF73F4A4FF6FF4
      A2FF6CF3A0FFA1F7C2FFFFFFFFFF309650FF0000000000000000000000000000
      00000000000000000000000000000000000016672F422D954EFFD2E9D9FFAAFB
      C8FF92F9B9FF8EF9B6FF8AF8B4FF87F8B1FF83F7AFFF7FF6ADFF7CF6AAFF78F5
      A8FF74F5A5FFA6F8C5FFFFFFFFFF309650FF0000000000000000000000000000
      000000000000000000000000000000000000000000001375325B329752FFD7EF
      DFFFA4FBC4FFA4FBC4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF309650FF0000000000000000000000000000
      000000000000000000000000000000000000000000000000000011722F74389A
      57FFD3F2DEFFADFCCAFFF3F9F5FFBFDFC9FFBFDFC9FFBFDFC9FFBFDFC9FFBFDF
      C9FFBFDFC9FFBFDFC9FFBFDFC9FF309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000D6E
      2C94409E5EFFD2F2DDFFBFDFC9FF309650FF309650FF309650FF309650FF3096
      50FF309650FF309650FF309650FF309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000A8230B447A264FFAFD6BBFF309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000001F0A080B8331C9409E5EFF309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000001F0A1805802CDE309650FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F9F89277F9F893B0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFE7FF00FFC7FF00FF87FF00FF87FF00FF000700FE000700FC000700F800
      0700F0000700E0000700E0000700E0000700E0000700F0000700F8000700FC00
      0700FE000700FF000700FF87FF00FF87FF00FFC7FF00FFE7FF00FFFFFF00}
    UseSpecIconSize = True
    HightliteImage = True
    StretchImage = True
    CanClick = True
  end
  object WlNext: TWebLink
    Left = 357
    Top = 268
    Width = 29
    Height = 24
    Cursor = crHandPoint
    Anchors = [akRight, akBottom]
    Enabled = False
    OnClick = WlNextClick
    ImageIndex = 0
    IconWidth = 24
    IconHeight = 24
    UseEnterColor = False
    EnterColor = clBlack
    EnterBould = False
    TopIconIncrement = 0
    Icon.Data = {
      0000010001001818000001002000880900001600000028000000180000003000
      0000010020000000000060090000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F9F893B7F9F89270000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF05802CDE001F0A1800000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF3B9E5AFF0A8331C9001F0A08000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF96D6AAFF43A261FF0A8230B4000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF309650FF309650FF309650FF309650FF3096
      50FF309650FF309650FF309650FFABDFBBFFB6EFCAFF3E9E5CFF0D6E2C940000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF94DFABFF97DFAEFF9BDFB1FF9FDFB3FFA3DF
      B6FFA7DFB8FFABDFBBFFAFDFBEFFE2F9E9FF5EEF97FFC8F0D6FF389A57FF1172
      2F74000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FFCEFFDDFFD3FFE1FFD8FFE4FFDDFFE8FFE2FF
      EBFFE7FFEFFFEDFFF2FFF2FFF6FFF7FFF9FF5FF097FF65F19BFFD7EFDFFF3297
      52FF1375325B0000000000000000000000000000000000000000000000000000
      00000000000000000000309650FFD7FFE4FF81F4ADFF4DED8CFF50EE8EFF54EE
      90FF58EF93FF5CF095FF60F098FF64F09AFF54EF90FF55EF91FF87F4B1FFD3E9
      DAFF2D954EFF16672F4200000000000000000000000000000000000000000000
      00000000000000000000309650FFE1FFEAFF7CF3AAFF40EC83FF43EC86FF47ED
      88FF4BEE8AFF4FEE8DFF52EF8FFF56F092FF5AF094FF5DF197FF61F199FFABF8
      C8FFC4E0CDFF1F8D42F9185B2D31000000000000000000000000000000000000
      00000000000000000000309650FFEBFFF1FF85F4B0FF49ED89FF4CEE8BFF50EF
      8EFF54EF90FF57F093FF5BF095FF5FF197FF63F29AFF66F29CFF6AF39FFF6EF3
      A1FFCCFBDEFFB2D7BEFF1A8B3EF4195E2E260000000000000000000000000000
      00000000000000000000309650FFF5FFF8FF8EF4B6FF51EF8FFF55EF91FF59F0
      93FF5CF196FF60F198FF64F29BFF68F29DFF6BF3A0FF6FF4A2FF73F4A4FF76F5
      A7FF7EF6ABFFE5FDEEFF99CBA9FF16893BE50000000000000000000000000000
      00000000000000000000309650FFFDFFFEFF96F5BBFF5AF094FF5EF197FF62F1
      99FF65F29CFF69F39EFF6DF3A0FF70F4A3FF74F4A5FF78F5A8FF7CF6AAFF7FF6
      ADFF85F7B0FFDCFDE8FF99CBA9FF16893BE50000000000000000000000000000
      00000000000000000000309650FFFFFFFFFF9BF6BFFF63F29AFF66F29CFF6AF3
      9FFF6EF3A1FF72F4A4FF75F5A6FF79F5A9FF7DF6ABFF80F7ADFF84F7B0FF88F8
      B2FFCAFCDCFFB2D7BEFF1A8B3EF4195E2E260000000000000000000000000000
      00000000000000000000309650FFFFFFFFFFA1F7C2FF6CF3A0FF6FF4A2FF73F4
      A4FF76F5A7FF7AF6A9FF7EF6ACFF82F7AEFF86F7B1FF89F8B3FF8DF9B5FFB7FB
      D1FFC4E0CDFF1F8D42F9185B2D31000000000000000000000000000000000000
      00000000000000000000309650FFFFFFFFFFA6F8C5FF74F5A5FF78F5A8FF7CF6
      AAFF7FF6ADFF83F7AFFF87F8B1FF8AF8B4FF8EF9B6FF92F9B9FFAAFBC8FFD2E9
      D9FF2D954EFF16672F4200000000000000000000000000000000000000000000
      00000000000000000000309650FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA4FBC4FFA4FBC4FFD7EFDFFF3297
      52FF1375325B0000000000000000000000000000000000000000000000000000
      00000000000000000000309650FFBFDFC9FFBFDFC9FFBFDFC9FFBFDFC9FFBFDF
      C9FFBFDFC9FFBFDFC9FFBFDFC9FFF3F9F5FFADFCCAFFD3F2DEFF389A57FF1172
      2F74000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF309650FF309650FF309650FF309650FF3096
      50FF309650FF309650FF309650FFBFDFC9FFD2F2DDFF409E5EFF0D6E2C940000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FFAFD6BBFF47A264FF0A8230B4000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF409E5EFF0B8331C9001F0A08000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000309650FF05802CDE001F0A1800000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F9F893B7F9F89270000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFE7FF00FFE3FF00FFE1FF00FFE1FF00E000FF00E0007F00E0003F00E000
      1F00E0000F00E0000700E0000700E0000700E0000700E0000F00E0001F00E000
      3F00E0007F00E000FF00FFE1FF00FFE1FF00FFE3FF00FFE7FF00FFFFFF00}
    UseSpecIconSize = True
    HightliteImage = True
    StretchImage = True
    CanClick = True
  end
  object ImlWatermarkPatterns: TImageList
    Left = 48
    Top = 192
  end
  object TmrPreview: TTimer
    Interval = 200
    OnTimer = TmrPreviewTimer
    Left = 128
    Top = 192
  end
  object SwpMain: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 192
    Top = 192
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 272
    Top = 192
  end
end
