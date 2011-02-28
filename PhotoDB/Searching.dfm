object SearchForm: TSearchForm
  Left = 459
  Top = 60
  ActiveControl = ShowDateOptionsLink
  Caption = 'Search'
  ClientHeight = 715
  ClientWidth = 805
  Color = clBtnFace
  Constraints.MinHeight = 180
  Constraints.MinWidth = 310
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    805
    715)
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 180
    Top = 25
    Height = 690
    MinSize = 135
    OnCanResize = Splitter1CanResize
    ExplicitHeight = 615
  end
  object PnLeft: TPanel
    Left = 0
    Top = 25
    Width = 180
    Height = 690
    Align = alLeft
    ParentColor = True
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    object PropertyPanel: TPanel
      Left = 1
      Top = 397
      Width = 178
      Height = 326
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 4
      Visible = False
      DesignSize = (
        178
        326)
      object Label2: TLabel
        Left = 8
        Top = 0
        Width = 24
        Height = 13
        Caption = 'Ident'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object Label8: TLabel
        Tag = 2
        Left = 8
        Top = 16
        Width = 34
        Height = 13
        Caption = 'Rating:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object Label4: TLabel
        Left = 8
        Top = 124
        Width = 20
        Height = 13
        Caption = 'Size'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object Label6: TLabel
        Tag = 2
        Left = 8
        Top = 139
        Width = 52
        Height = 13
        Caption = 'Comments:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object Label5: TLabel
        Tag = 2
        Left = 8
        Top = 231
        Width = 54
        Height = 14
        Caption = 'KeyWords:'
        Font.Charset = EASTEUROPE_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object RatingEdit: TRating
        Left = 8
        Top = 32
        Width = 96
        Height = 16
        Cursor = crHandPoint
        PopupMenu = PopupMenu5
        Rating = 2
        RatingRange = 0
        OnChange = Memo1Change
        Islayered = False
        Layered = 100
        OnMouseDown = RatingEditMouseDown
        ImageCanRegenerate = True
        CanSelectRange = False
      end
      object Memo2: TMemo
        Tag = 1
        Left = 8
        Top = 155
        Width = 167
        Height = 70
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Times New Roman'
        Font.Style = [fsItalic]
        ParentColor = True
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 5
        OnChange = Memo1Change
        OnDblClick = SetComent1Click
        OnKeyDown = Memo1KeyDown
      end
      object Memo1: TMemo
        Tag = 1
        Left = 8
        Top = 247
        Width = 167
        Height = 50
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Times New Roman'
        Font.Style = [fsItalic]
        Lines.Strings = (
          '<data>')
        ParentColor = True
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 6
        OnChange = Memo1Change
        OnKeyDown = Memo1KeyDown
        OnKeyPress = Memo1KeyPress
      end
      object Save: TButton
        Left = 110
        Top = 301
        Width = 65
        Height = 17
        Anchors = [akTop, akRight]
        Caption = 'Save'
        TabOrder = 7
        OnClick = SaveClick
      end
      object DateTimePicker1: TDateTimePicker
        Tag = 1
        Left = 8
        Top = 50
        Width = 167
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BevelEdges = []
        BevelInner = bvNone
        BevelOuter = bvNone
        Date = 38153.582815208330000000
        Time = 38153.582815208330000000
        Color = clBtnFace
        DateFormat = dfLong
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = True
        ParentFont = False
        PopupMenu = PopupMenu3
        TabOrder = 1
        OnChange = Memo1Change
      end
      object IsDatePanel: TPanel
        Left = 8
        Top = 50
        Width = 167
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvLowered
        Caption = '<no date>'
        ParentColor = True
        PopupMenu = PopupMenu3
        TabOrder = 4
        OnDblClick = IsDatePanelDblClick
      end
      object PanelValueIsDateSets: TPanel
        Left = 8
        Top = 50
        Width = 167
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvLowered
        Caption = '<value not sets>'
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = True
        ParentCtl3D = False
        ParentFont = False
        PopupMenu = PopupMenu7
        TabOrder = 3
        Visible = False
        OnDblClick = PanelValueIsDateSetsDblClick
      end
      object DateTimePicker4: TDateTimePicker
        Tag = 1
        Left = 8
        Top = 75
        Width = 167
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Date = 38548.001314189820000000
        Time = 38548.001314189820000000
        Color = clBtnFace
        Kind = dtkTime
        ParentColor = True
        PopupMenu = PopupMenu11
        TabOrder = 2
        OnChange = Memo1Change
      end
      object IsTimePanel: TPanel
        Left = 8
        Top = 75
        Width = 167
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvLowered
        Caption = '<no time>'
        ParentColor = True
        PopupMenu = PopupMenu11
        TabOrder = 8
        OnDblClick = IsTimePanelDblClick
      end
      object PanelValueIsTimeSets: TPanel
        Left = 8
        Top = 75
        Width = 167
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        BevelInner = bvLowered
        Caption = '<value not sets>'
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = True
        ParentCtl3D = False
        ParentFont = False
        PopupMenu = PopupMenu10
        TabOrder = 9
        Visible = False
        OnDblClick = PanelValueIsTimeSetsDblClick
      end
      object ComboBoxSelGroups: TComboBoxExDB
        Left = 8
        Top = 100
        Width = 167
        Height = 22
        ItemsEx = <>
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        PopupMenu = PopupMenu4
        TabOrder = 10
        Text = 'ComboBoxSelGroups'
        OnDblClick = ComboBox1_DblClick
        OnDropDown = ComboBox1DropDown
        OnSelect = ComboBox1_Select
        Images = GroupsImageList
        DropDownCount = 10
        ShowDropDownMenu = True
        LastItemIndex = 0
        ShowEditIndex = -1
      end
    end
    object ExplorerPanel: TPanel
      Left = 1
      Top = 723
      Width = 178
      Height = 15
      Align = alClient
      ParentColor = True
      TabOrder = 3
      Visible = False
    end
    object SearchPanelB: TPanel
      Left = 1
      Top = 396
      Width = 178
      Height = 1
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      ParentShowHint = False
      PopupMenu = PopupMenu1
      ShowHint = True
      TabOrder = 2
      DesignSize = (
        178
        1)
      object Label7: TLabel
        Left = 8
        Top = 2
        Width = 30
        Height = 13
        Caption = 'Result'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object PbProgress: TDmProgress
        Left = 8
        Top = 18
        Width = 167
        Height = 18
        Anchors = [akLeft, akTop, akRight]
        MaxValue = 100
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Text = 'Progress... (&%%)'
        BorderColor = 38400
        CoolColor = 38400
        Color = clBlack
        View = dm_pr_cool
        Inverse = False
      end
    end
    object pnDateRange: TPanel
      Left = 1
      Top = 177
      Width = 178
      Height = 219
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      Visible = False
      DesignSize = (
        178
        219)
      object elvDateRange: TEasyListview
        Left = 8
        Top = 0
        Width = 167
        Height = 217
        Anchors = [akLeft, akTop, akRight, akBottom]
        Ctl3D = True
        EditManager.Font.Charset = DEFAULT_CHARSET
        EditManager.Font.Color = clWindowText
        EditManager.Font.Height = -11
        EditManager.Font.Name = 'MS Shell Dlg 2'
        EditManager.Font.Style = []
        UseDockManager = False
        DragManager.AutoScroll = False
        DragManager.MouseButton = []
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Shell Dlg 2'
        Font.Style = []
        GroupFont.Charset = DEFAULT_CHARSET
        GroupFont.Color = clWindowText
        GroupFont.Height = -11
        GroupFont.Name = 'MS Shell Dlg 2'
        GroupFont.Style = []
        Header.Columns.Items = {
          0600000001000000110000005445617379436F6C756D6E53746F726564FFFECE
          00060000008008000101000100000000000001A4000000FFFFFF1F0001000000
          00000000000000000000000000000000}
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'MS Shell Dlg 2'
        Header.Font.Style = []
        PaintInfoGroup.BandFullWidth = True
        PaintInfoGroup.MarginBottom.CaptionIndent = 4
        ParentCtl3D = False
        ParentFont = False
        Scrollbars.HorzEnabled = False
        ShowGroupMargins = True
        Selection.AlphaBlend = True
        Selection.AlphaBlendSelRect = True
        Selection.EnableDragSelect = True
        Selection.FullCellPaint = True
        Selection.FullItemPaint = True
        Selection.FullRowSelect = True
        Selection.InactiveBorderColor = clHighlight
        Selection.InactiveColor = clHighlight
        Selection.InactiveTextColor = clHighlightText
        Selection.MouseButton = [cmbLeft, cmbRight]
        Selection.MultiSelect = True
        Selection.UseFocusRect = False
        TabOrder = 0
        View = elsReport
        OnItemClick = elvDateRangeItemClick
        OnItemSelectionChanged = elvDateRangeItemSelectionChanged
        OnMouseDown = elvDateRangeMouseDown
        OnResize = elvDateRangeResize
      end
      object dblDate: TDBLoading
        Left = 61
        Top = 72
        Width = 63
        Height = 64
        LineColor = clBlack
        Active = False
        OnDrawBackground = dblDateDrawBackground
      end
      object lsDate: TLoadingSign
        Left = 140
        Top = 3
        Width = 16
        Height = 16
        Visible = False
        Active = True
        FillPercent = 50
        Color = clBtnFace
        ParentColor = False
        Anchors = [akTop, akRight]
        SignColor = clBlack
      end
    end
    object SearchPanelA: TPanel
      Left = 1
      Top = 1
      Width = 178
      Height = 176
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      OnContextPopup = SearchPanelAContextPopup
      DesignSize = (
        178
        176)
      object Label1: TLabel
        Left = 10
        Top = 5
        Width = 54
        Height = 13
        Caption = 'Search text'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
        PopupMenu = InsertSpesialQueryPopupMenu
      end
      object Image3: TImage
        Left = 145
        Top = 74
        Width = 16
        Height = 16
        OnClick = Image3Click
      end
      object Image5: TImage
        Left = 80
        Top = 8
        Width = 16
        Height = 16
        Picture.Data = {
          055449636F6E0000010001001010000001002000680400001600000028000000
          1000000020000000010020000000000040040000000000000000000000000000
          000000000101006E0000006D0000001300000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000100B08AB18110DE60100009A0000002F00000001000000080000000C
          0000000000000000000000000000000000000000000000000000000000000000
          00000000050302477F5C47FE3B2A20F6040302BD000000560909093E02020293
          0000005400000010000000000000000000000000000000000000000000000000
          000000000000000035261DC4C58F70FF6C4E3CFD0B0806D9191919AA878887FA
          3C3D3DDC0404049F0000004B0000000D00000000000000000000000000000000
          000000000000000005030243926A53FEC89271FF9B7158FF231913ED555454E8
          E8E8E9FFA5A5A5F9343434D702020297000000430000000A0000000000000000
          00000000000000000000000033241CC1C89171FFC89271FFBB886AFF4E392DFB
          888685FEFEFEFEFFEEEEEEFF999999F72B2B2BD2010101900000003B00000007
          00000000000000000000000005030240906951FEC89271FFC89271FFC89271FF
          7D5B46FF7E7975FFF8F8F8FFFEFFFFFFE9E9E9FF8D8D8DF5232423CD00000087
          0000002E00000000000000000000000330221ACFC89171FFC89271FFC89271FF
          C89271FFA87A5FFF5E5149FFE1E0DFFFFFFFFFFFFFFFFFFFE3E3E3FF808080F1
          1B1B1B770000000000000000000000253B2A21E7C89271FFC89271FFC89271FF
          C89272FF986E56FF685E58FFEDECECFFFFFFFFFFFEFEFEFFD4D4D4FE676868B2
          1212122B00000000000000030504028B9B7057FFC89271FFC89271FFC58F6FFF
          6B4E3DFF94908EFFFDFDFDFFFFFFFFFFDBDBDBFE747475BF1919193A00000000
          0000000000000000000000273D2C22E8C89271FFC89271FFB08064FF3F3026F7
          9C9B9AFEFEFFFFFFE2E2E2FE828282CC1F1F1F46000000000000000000000000
          00000000000000030604038E9D7259FFC89271FF89634DFE18110CB7646363DF
          E2E2E2FE8E8E8ED6262526540000000100000000000000000000000000000000
          0000000000000028402E23EABF8B6CFF573F30F10805045C1C1C1C4A7C7C7CDD
          2D2D2D6101010103000000000000000000000000000000000000000000000000
          000000000604037F7C5A45FE2B1F18CA03020124000000000505050C00000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000100B08AD100B08890000000500000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000009000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000001FFF000001FF0000007F0000801F000080070000C0010000C0000000
          C0000000C000000080030000800F0000001F0000007F00000BFF00001FFF0000
          7FFF0000}
        Visible = False
      end
      object Image6: TImage
        Left = 104
        Top = 8
        Width = 16
        Height = 16
        Picture.Data = {
          055449636F6E0000010001001010000001002000680400001600000028000000
          1000000020000000010020000000000040040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000130000006D
          0101006E00000000000000000000000000000000000000000000000000000000
          00000000000000000000000C00000008000000010000002F0100009A18110DE6
          100B08AB00000000000000000000000000000000000000000000000000000000
          0000001000000054020202930909093E00000056040302BD3B2A20F67F5C47FE
          0503024700000000000000000000000000000000000000000000000D0000004B
          0404049F3C3D3DDC878887FA191919AA0B0806D96C4E3CFDC58F70FF35261DC4
          000000000000000000000000000000000000000A0000004302020297343434D7
          A5A5A5F9E8E8E9FF555454E8231913ED9B7158FFC89271FF926A53FE05030243
          0000000000000000000000070000003B010101902B2B2BD2999999F7EEEEEEFF
          FEFEFEFF888685FE4E392DFBBB886AFFC89271FFC89171FF33241CC100000000
          000000000000002E00000087232423CD8D8D8DF5E9E9E9FFFEFFFFFFF8F8F8FF
          7E7975FF7D5B46FFC89271FFC89271FFC89271FF906951FE0503024000000000
          000000001B1B1B77808080F1E3E3E3FFFFFFFFFFFFFFFFFFE1E0DFFF5E5149FF
          A87A5FFFC89271FFC89271FFC89271FFC89171FF30221ACF0000000300000000
          000000001212122B676868B2D4D4D4FEFEFEFEFFFFFFFFFFEDECECFF685E58FF
          986E56FFC89272FFC89271FFC89271FFC89271FF3B2A21E70000002500000000
          0000000000000000000000001919193A747475BFDBDBDBFEFFFFFFFFFDFDFDFF
          94908EFF6B4E3DFFC58F6FFFC89271FFC89271FF9B7057FF0504028B00000003
          00000000000000000000000000000000000000001F1F1F46828282CCE2E2E2FE
          FEFFFFFF9C9B9AFE3F3026F7B08064FFC89271FFC89271FF3D2C22E800000027
          0000000000000000000000000000000000000000000000000000000126252654
          8E8E8ED6E2E2E2FE646363DF18110CB789634DFEC89271FF9D7259FF0604038E
          0000000300000000000000000000000000000000000000000000000000000000
          010101032D2D2D617C7C7CDD1C1C1C4A0805045C573F30F1BF8B6CFF402E23EA
          0000002800000000000000000000000000000000000000000000000000000000
          0000000000000000000000000505050C00000000030201242B1F18CA7C5A45FE
          0604037F00000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000000000000005100B0889
          100B08AD00000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000009FFF80000FF800000FE000000F8010000E00100008003000000030000
          0003000000030000C0010000F0010000F8000000FE000000FFD00000FFF80000
          FFFE0000}
        Visible = False
      end
      object RtgQueryRating: TRating
        Left = 8
        Top = 74
        Width = 96
        Height = 16
        Cursor = crHandPoint
        Rating = 0
        RatingRange = 0
        OnChange = SearchEditChange
        Islayered = False
        Layered = 100
        ImageCanRegenerate = True
        CanSelectRange = True
      end
      object TwbPrivate: TTwButton
        Left = 105
        Top = 74
        Width = 16
        Height = 16
        Cursor = crHandPoint
        Hint = 'Show private photos'
        Icon.Data = {
          0000010001001010000001002000680400001600000028000000100000002000
          0000010020000000000040040000000000000000000000000000000000000000
          0000000000000000000000000000000000000000310800044231000410310000
          0021000000180000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000008100008737B0824C6C61020
          8CAD000010630000003100000000000000000000000000000000000000000000
          000000000000000000000000310800085A5A081863840008295A00003973185D
          F7F71041CEE70000187300000021000000000000000000000000000000000000
          00000000000000000000000000000808CE4A1038FFD64279F7FF182CA5CE0055
          DEF7088AFFFF08188CBD00000039000000000000000000000000000000000000
          0000000000000000000000000000000000000000AD10103CE7C62186FFFF088A
          D6FF0092E7FF0830BDE700000842000000000000000000000000000000000000
          00000000000000000000000000000000000008041829080C528C4A6DADFF6386
          84FF185984FF001C84EF0000006B000000180000000000000000000000000000
          00000000000000000000000000004A4D428C94928CFF73756BF7CEC7B5FFC6BA
          A5FF737573FF949AA5FF63615AE7080808730000001000000000000000000000
          0000000000000000000018181852B5B6B5F7DEDFD6FF8C8A94FF5A5DA5FF5A5D
          ADFF84829CFFC6C3B5FFB5B6B5FF212421BD0000004200000010000000000000
          0000000000003130315A9C9A9CFFB5B2ADFF9C9EBDFF3134E7FF0004FFFF0004
          FFFF080CEFFF5251ADFFBDBAADFFADAAA5FF393839C600000039000000000000
          00000000000073757384C6C7C6FFB5B6BDFF3134D6FF3938FFFF4A49FFFF4245
          FFFF5A59FFFF5A59EFFF8C8EBDFFFFFBEFFF848684F70000004A000000000000
          000000000000393C395A949694F7A5A6BDFF2120DEFF5251FFFF5255FFFF5251
          FFFF7371FFFF9492F7FF8486D6FFE7E3D6FF4A494AC600000031000000000000
          0000000000007375739CC6C3BDFFBDBEBDFF4241C6FF4241F7FF5A59FFFF5251
          FFFF4A49FFFF3130D6FFC6C3E7FFF7F7F7FF6B696BE700000039000000000000
          00000000000052555242949694DE9C9E94FFADAEBDFF4245C6FF3134D6FF292C
          DEFF2928CEFF8486C6FFC6C7BDFFCECFCEFF4A494AAD00000008000000000000
          000000000000000000005A5D5A42B5B2B5F7D6D3CEFFC6C7C6FFA5A6C6FFADAA
          CEFFDEDFE7FFFFFBF7FFB5B2B5FF292C29940000000800000000000000000000
          00000000000000000000000000007B7D7B848C8A8CD66B6D6BCEDEDFD6FFD6D3
          C6FF94928CE7B5B6B5E7636163B5000400210000000000000000000000000000
          000000000000000000000000000000000000393C3908424142217375738C5255
          529C21202131525152211014100800000000000000000000000000000000F83F
          0000F81F0000E00F0000F00F0000F80F0000F8070000F0030000E0010000C001
          0000C0010000C0010000C0010000C0010000E0030000F0070000F80F0000}
        Color = clBtnFace
        ParentColor = False
        OnlyMainImage = True
        OnChange = SearchEditChange
        IsLayered = False
        Layered = 100
        ImageCanRegenerate = True
      end
      object ShowDateOptionsLink: TWebLink
        Left = 8
        Top = 156
        Width = 113
        Height = 16
        Cursor = crHandPoint
        Text = 'Show Date Options'
        OnClick = ShowDateOptionsLinkClick
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
      object SortLink: TWebLink
        Left = 8
        Top = 138
        Width = 68
        Height = 16
        Cursor = crHandPoint
        PopupMenu = SortingPopupMenu
        Text = 'Sort by ID'
        OnClick = Image4_Click
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
      object ComboBoxSearchGroups: TComboBoxExDB
        Left = 8
        Top = 94
        Width = 167
        Height = 38
        ItemsEx = <>
        Style = csExDropDownList
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        OnDropDown = ComboBoxSearchGroupsDropDown
        OnSelect = ComboBoxSearchGroupsSelect
        Images = SearchGroupsImageList
        ShowDropDownMenu = True
        LastItemIndex = 0
        ShowEditIndex = -1
      end
      object SearchEdit: TComboBoxExDB
        Left = 8
        Top = 24
        Width = 167
        Height = 22
        AutoCompleteOptions = []
        ItemsEx = <>
        Anchors = [akLeft, akTop, akRight]
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentCtl3D = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnChange = SearchEditChange
        OnDropDown = SearchEditDropDown
        OnKeyPress = Edit1_KeyPress
        OnSelect = SearchEditSelect
        Images = SearchImageList
        DropDownCount = 10
        ShowDropDownMenu = True
        LastItemIndex = 0
        OnEnterDown = DoSearchNow
        ShowEditIndex = -1
        OnGetAdditionalImage = SearchEditGetAdditionalImage
        StartText = 'Enter your query here'
        DefaultIcon.Data = {
          0000010001001010000001002000680400001600000028000000100000002000
          0000010020000000000040040000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000855
          2121002C00730030087B00280873001800630000003921412918000000000000
          000042382110291C083121080052290C006B290C006B1808005A211008100092
          08CE10C329FF29D74AFF39E763FF42E76BFF31CB52FF108A21DE082800946B28
          08ADAD5529E7D67542FFE78252FFDE7942FFD66131FFC64110FF210C006B009A
          10D618C331FF29C752FF39B69CFF4AB6C6FF39BE8CFF29D752FF10B621FFCE61
          31FFE78252FFDE8A5AFFF7A673FFE78A5AFFD66D39FFCE4D18FF310C006B0079
          108410AA31FF185563FF42B2DEFF4AB6FFFF4AB6FFFF29BE4AFF10AE21FFCE61
          31FFD6794AFFDEB29CFFF7A673FFE78E5AFFDE6D39FFC64918FF391C0839185D
          635A106952FF184D73FF319AEFFF319AEFFF39A6EFFF187552FF21515AFFD65D
          31FFD67D52FFFFEBD6FFDE8A52FFE78252FFD66939FF6B24089C00000000185D
          6B42214D7BFF214D73FF107DCEFF1886D6FF1079B5FF215163FF21456BEF9430
          08B59C7563FF3186BDFF317DB5FFA55939FF6B28089400000000000000002165
          7B08214D73F7215173FF218EDEFF2996EFFF299AEFFF215584FF18385AD62951
          63181886D6F72992E7FF2992E7FF1875BDF71820213100000000000000000000
          000021456BAD29557BFF319EF7FF39A6FFFF39A6FFFF2971ADFF1024319C185D
          8C5A31A2F7FF31A2F7FF31A2F7FF31A2F7FF0024398400000000000000000000
          000018416373315984FF39A2EFFF42B2FFFF4AB2FFFF2979B5FF1028394A1061
          9C734AB2FFFF42AEFFFF42AEFFFF39A2EFFF08385AAD00000000000000000000
          000029598C4A39658CFF318AC6FF4ABAFFFF52BAFFFF295984F7103C5A181069
          A55A42AEFFFF42AEFFFF2175B5FF295584FF0820319400000000000000000000
          00002965940839618CE742719CFF3979B5FF397DB5FF1028398C00000000216D
          A50818517BE7427DADFF426994FF31618CFF0824393100000000000000000000
          000000000000295D8C29315D84BD39658CDE214D737B00000000000000000000
          000010598C21185584AD29618CC610385A520000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FFFF
          0000FFFF00000180000000000000000000000000000000010000000300000003
          000080030000800300008003000081030000C3870000FFFF0000FFFF0000}
      end
      object WlStartStop: TWebLink
        Left = 8
        Top = 50
        Width = 133
        Height = 16
        Cursor = crHandPoint
        ParentColor = False
        Color = clBtnFace
        Text = 'Search (999999 Result)'
        ImageIndex = 0
        IconWidth = 16
        IconHeight = 16
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        ImageCanRegenerate = True
        UseSpecIconSize = True
      end
      object LsSearchResults: TLoadingSign
        Left = 147
        Top = 52
        Width = 16
        Height = 16
        Visible = False
        Active = True
        FillPercent = 50
        SignColor = clBlack
      end
      object TwlIncludeAllImages: TTwButton
        Left = 123
        Top = 74
        Width = 16
        Height = 16
        Cursor = crHandPoint
        Hint = 'Show private photos'
        Icon.Data = {
          0000010001001010000001002000680400001600000028000000100000002000
          0000010020000000000040040000000000000000000000000000000000000000
          000000000000E2ECF913AAC8ED55AAC8ED55AAB4C00500000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000AAC8ED3F43B4F1FF1678D7FF001E431500000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000AAC8ED3F43B4F1FF1678D7FF001E431500000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000AAC8ED3F43B4F1FF1678D7FF001E431500000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000AAC8ED3F43B4F1FF1678D7FF001E43150000000000000000F3D8
          AA55E5A840FFE5A840FFE5A840FFE5A840FFC2B9AA0C00000000000000000000
          000000000000AAC8ED3F43B4F1FF1678D7FF001E431500000000F3D8AA55E5A8
          40FFFEFCF1FFFEFCF1FFFEFCF1FFE5A840FFF3D8AA5500000000000000000000
          000000000000AAC8ED3F43B4F1FF1678D7FF001E4315F3D8AA55E5A840FFFEFC
          F1FFFFF7CAFFFFF6C4FFFEFCF1FFE5A840FFF3D8AA5500000000000000000000
          000000000000CFD0CA48E5A840FFE5A840FFE5A840FFE5A840FFFEFCF1FFFFF2
          BEFFFFF1BAFFFFF1BAFFFEFCF1FFE5A840FFF3D8AA5500000000000000000000
          000000000000F3D8AA55E5A840FFFEFCF1FFFEFCF1FFFFF9E4FFFFECB7FFFFE8
          A8FFFFE8A8FFFFE8A8FFFEFCF1FFE5A840FFF3D8AA5500000000000000000000
          000000000000F3D8AA55E5A840FFFEFCF1FFFFDD97FFFFDB8FFFFFDB8FFFFFDB
          8FFFFFDB8FFFFFDB8FFFFEFCF1FFE5A840FFF3D8AA5500000000000000000000
          000000000000F3D8AA55E5A840FFFEFCF1FFFFCB72FFFFCB72FFFFCB72FFFFD9
          95FFFFD995FFFFDEA4FFFFE0AAFFE5A840FFF3D8AA5500000000000000000000
          000000000000F3D8AA55E5A840FFFEFCF1FFFFC76AFFFFC76AFFFFC76CFFFFC7
          6AFFFFC76AFFE5A840FFE5A840FFE5A840FFF3D8AA5500000000000000000000
          000000000000F3D8AA55E5A840FFFEFCF1FFFFC76AFFFFC76AFFFFC76AFFEBBE
          71F0E5A840FFF3D8AA55F3D8AA55F3D8AA550000000000000000000000000000
          000000000000F3D8AA55E5A840FFFEFCF1FFFFC76AFFFFC76AFFFFC76AFFE5A8
          40FFF3D8AA550000000000000000000000000000000000000000000000000000
          000000000000F3D8AA55E5A840FFE5A840FFE5A840FFE5A840FFE5A840FFF3D8
          AA55000000000000000000000000000000000000000000000000000000000000
          000000000000F5F0E70FF1D7AB48F3D8AA55F3D8AA3FE1CDAA5AF3D8AA550000
          000000000000000000000000000000000000000000000000000000000000C3FF
          0000C3FF0000C3FF0000C3FF0000C3030000C2030000C0030000C0030000C003
          0000C0030000C0030000C0030000C0070000C03F0000C07F0000C0FF0000}
        OnlyMainImage = True
        OnChange = SearchEditChange
        IsLayered = False
        Layered = 100
        ImageCanRegenerate = True
      end
    end
  end
  object BackGroundSearchPanel: TPanel
    Tag = 1
    Left = 183
    Top = 25
    Width = 622
    Height = 690
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvNone
    ParentBackground = False
    ParentColor = True
    TabOrder = 1
    Visible = False
    OnResize = BackGroundSearchPanelResize
    object ImageSearchWait: TImage
      Left = 200
      Top = 176
      Width = 128
      Height = 128
      Enabled = False
      Proportional = True
      Transparent = True
    end
    object LabelBackGroundSearching: TLabel
      Tag = 112
      Left = 168
      Top = 304
      Width = 201
      Height = 89
      Alignment = taCenter
      AutoSize = False
      BiDiMode = bdLeftToRight
      Caption = 'Please, wait until searching in progress...'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Times New Roman'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
      Transparent = True
      WordWrap = True
    end
    object ImageAllGroups: TImage
      Left = 16
      Top = 304
      Width = 33
      Height = 33
      Picture.Data = {
        055449636F6E0000010001002020000001002000A81000001600000028000000
        2000000040000000010020000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000060000001D0000002B0000002F0000002F0000002E
        0000002A000000240000001C0000001400000009000000030000000000000000
        000000000000000000000000000000000000000100000003000000080000000F
        000000180000001E000000240000002500000025000000230000001A00000009
        00000000010B000E01360278035308C0086210CF0B6515D20E6718D20D5E16CB
        094E10BE043907AC00280198000F00780000005A000000410000002700000010
        0000000200000000000000070000001D000000350B010050240A00703A12008E
        491901A3561F04B25C2205BA5A2004BA5A1F03BB491801AC1D0A008500000045
        0000000F0366077D08A916FF10BE24FF1BC933FF26D342FF31DB50FF38E05AFF
        3DE062FF40DE65FF3AD25DFF2CB647FC1B8F2CEC0B6012CF022B03A50005006D
        0000003914060047351100826B2809BB8D3C15DBAE5426F4C36637FFD17343FF
        D97949FFDC7747FFD96F3FFFD36334FFCE5728FFC34619FFAB390BFC3813009F
        0000002504840CB80AB91DFF14BB29FF1EC337FF29CB45FF33D453FF3EE162FF
        44E562FF4BEC6DFF53F47BFF54F87FFF48EE72FF35DA57FF20BE38FF057D14E7
        2E2D02C3A53811EAC55728FFD96F40FFE18152FFE88E60FFEA9466FFE89465FF
        E58F60FFDF8658FFDA7A4CFFD46C3FFFCE5E31FFC84E23FFCC4417FF642105C2
        0000002804840CB40CB91EFF16BD2CFF21C53BFF2DD849FF39DF58FF31BE57FF
        35A883FF3CAC92FF3BB281FF3BC165FF40DB5EFF3DDF62FF2CD24BFF17CB34FF
        1B9715FFC4592BFFDB6B40FFDB7A4CFFE1885AFFE59162FFEA9C6CFFEB9F70FF
        E8996AFFE38D5FFFDD8053FFD77244FFCF6436FFC85227FFCB4519FF682207C0
        00000026047A09910DB61FFF18BE2EFF22C93CFF27A052FF2FC04FFF35A889FF
        5CBCFFFF5CBFFFFF58BBFEFF4FB2DDFF36A38BFF31CA4EFF2FD24DFF1CC435FF
        05AD1AFFAB5F28FFDD6B41FFDB7D4FFFE48E5FFFBC6538FFDB9061FFF5B281FF
        EDA473FFE79466FFDF8557FFD87648FFD1673AFFCA5629FFCA471AFF5E1F03B8
        0000001F026C01480BAD17FA18C82DFF1F9C47FF203576FF227E4DFF3BADADFF
        55B9FFFF51B7FFFF53B9FFFF57BDFFFF52B3FAFF2AB254FF2EDA47FF1AC635FF
        0DA517FFB45E2AFFDB6D42FFDF8355FFD57A48FFCDA08AFFD19068FFF7B684FF
        EFA777FFE89768FFE08759FFD97749FFD1673BFFCB572AFFC64618FF4E1A019C
        0000000F094D1F0A0B7D1DCA15CD25FF1E7456FF253F7EFF1C6A4EFF3DABC8FF
        4CB1FFFF4BB1FFFF4CB2FFFF4FB4FFFF4AADF0FF28B350FF28B749FF12C52EFF
        24881DFFCA5630FFD66C3FFFDF7F50FFC56C3EFFF7F1ECFFD3A48CFFE0925EFF
        F0A979FFE69565FFDF8557FFD87547FFD06639FFCE572BFFAD3D0FF81F0A004D
        00000001000000001A395FBC129B2BFF1E6E58FF27457DFF1B5460FF38A1E2FF
        41A7FBFF44AAFCFF46ACFFFF47AEFFFF41A9E6FF22A547FF234D6DFF116E4AFF
        2B5247FFCA5432FFD66B3DFFD36D3DFFC98561FFFFF7EAFFF4E1D1FFC37246FF
        E79767FFE38F61FFDC8153FFD57144FFD26438FFC85021FF5B1F039800000009
        00000000000000001F406CB91F4E62FF1D5160FF274C79FF224F79FF2E94E3FF
        298FDAFF2489D1FF288AD2FF3798E8FF36A0D8FF1B943CFF264C76FF1F457BFF
        38425FFFCD5425FFD46739FFC65D2EFFE4A880FFFFE6C1FFFFE4C0FFE7B287FF
        D26B35FFE58758FFD9794CFFD76E41FFD05C2CFF842E06BF0A03001B00000000
        00000000000000001D3F649C294E7CFF274C79FF285077FF234D78FF1574B7FF
        157AC0FF187DC8FF167BC3FF1672B9FF1C7C94FF1B6E46FF284A7CFF235281FF
        2F3C53EB9E3609DECD5B2CFFCB5D2BFFDAB38EFF789AA7FF3D82ACFF4D8FB5FF
        7C6E67FFC75E2BFFE07444FFCB5C2CFF842E08B21B08001C0000000000000000
        00000000000000001B3C606E285178FF29527AFF2A517AFF244C74FF1B78C0FF
        278FE0FF278DDBFF278EDDFF258EDFFF136C9DFF214160FF2B537EFF2A547EFF
        143250CF320D004AA42F029C9F5029F1337FB0FF097CD3FF1683D7FF1482D6FF
        0C80D3FF3D596DFFA43E10EF621E038E0F04000D000000000000000000000000
        000000000000000019385B2E274D75FC2C557EFF2C537CFF264E76FF227FC9FF
        2D96E6FF2C92E2FF2C92E2FF2E94E3FF2B93E5FF1C507EFF2C4F75FF2D5781FF
        122B45BD0000001B030D1405175D8DCD1C8DE3FF2A91E0FF298FDDFF2A8FDDFF
        2A91E2FF1A8DE1FF0E3855CA0000004600000005000000000000000000000000
        00000000000000001736580222466CCE2E5680FF2E557EFF274F77FF2683CCFF
        359DEEFF3399E9FF3399E9FF3399E9FF35A0F1FF2374B3FF284A6EFF2D557FFF
        0E1C2D970000000600395A55218EDEFF3298E8FF2F95E4FF2F95E5FF2F95E5FF
        2F95E4FF3299EBFF197DC3FC001019870000001F000000000000000000000000
        0000000000000000000000001D3E637E2F5780FF315881FF27517BFF2C8DDAFF
        3CA3F5FF3AA0F0FF3AA0F0FF3AA0F0FF3CA4F7FF2F8DD7FF264F76FF2A4D75FA
        05090E67000000000B6399A3379FF0FF379CECFF369CECFF369CECFF369CECFF
        369CECFF379DEDFF349DEEFF04395AC100000035000000000000000000000000
        000000000000000000000000193A5F3E2E547CF9355C85FF28537FFF3499EAFF
        43AAFBFF41A7F9FF41A7F9FF41A7F9FF43AAFEFF389CE7FF285781FF223F5EE0
        0101013700121C0A197EC1CE41A7FBFF3DA3F4FF3DA3F4FF3DA3F4FF3DA3F4FF
        3DA3F4FF3CA2F4FF40A9FEFF145F92DF0001024C000000030000000000000000
        00000000000000000000000018375B1C2A4F75DE386089FF29537DFF3595E0FF
        4AB2FFFF47ADFFFF47ADFFFF47ADFFFF49B0FFFF3FA2E9FF295883FF122538AC
        0000000E002840152588CDD949B0FFFF44AAFCFF44AAFCFF44AAFCFF44AAFCFF
        45ABFCFF48AFFFFF4DBAFFFF227BB9ED00070D60000000060000000000000000
        0000000000000000000000001735580C2A4D73CD3C648EFF31557CFF3086C8FF
        4DB7FFFF4BB1FFFF4BB1FFFF4BB1FFFF4DB5FFFF3F9FE5FF244D75FF08101B74
        00000002005486152787C8D94EB5FFFF48AEFFFF49AFFFFF49AFFFFF4BB1FFFF
        47B0FFFF3598E0FF2E85C1FF186599F2000C1463000000050000000000000000
        00000000000000000000000000000000274970B63F6892FF3A5E84FF2B6FA7FF
        4EB8FFFF4FB4FFFF4DB3FFFF4DB3FFFF51BBFFFF3A8CC8FF213F5FF102040647
        00000000005081081E7FBDC853BBFFFF4DB3FFFF4DB3FFFF4FB5FFFF41ABF9FF
        1D77B7FF184472FF32537CFF1A4668EC00070D51000000010000000000000000
        0000000000000000000000000000000020416684416992FF41688FFF2D5B87FF
        40A4E8FF56C1FFFF52BCFFFF54BCFFFF52BCFFFF346B98FF1D344FCA00000020
        0000000000000000085E92963B9EE1FF47B1FDFF43ACF8FF329CE8FF196FACFF
        214A77FF375680FF436A94FF144060D900020431000000000000000000000000
        0000000000000000000000000000000017385C2D385F86FA48719BFF43688FFF
        2B6698FF409BD9FF3D82B8FF48A5E2FF3F87BCFF33567CFE0B18256F00000003
        000000000000000000446D390E4673FC20679FFF2172A9FF286B9CFF3A628CFF
        3C5E8AFF3F648DFF37628DFF04273D9E0000000C000000000000000000000000
        000000000000000000000000000000000000000022446891487099FF527CA6FF
        4E759DFF446B93FF446990FF3E6790FF416891FF1C3551B00001021400000000
        00000000000000000000000009426B95355883FF5D82ABFF6E98C0FF557DA7FF
        4D739DFF4A729CFF184D73E7000A113600000000000000000000000000000000
        00000000000000000000000000000000000000001635580B26486DA4466D95FF
        5781ABFF5A83ACFF517AA4FF446A93FF1F3B5AA902080E180000000000000000
        0000000000000000000000000041680909456E9333638DF94B77A0FF517CA5FF
        4F80A9FF1F5A83E2001A2C4C0000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000016365A041C3D6157
        294B70A62D5075BD26486CA211253D5501050906000000000000000000000000
        00000000000000000000000000000000000000000040683E07446C82104B7297
        083F6376000F1923000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8007E0010000800000000000
        0000000000000000000000000000000000000000800000018000000380000007
        8000000F8000000F8000000FC000800FC0000007C0000007C0000007E0010007
        E001800FE001800FF003C01FF007C03FF80FF07FFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFF}
      Visible = False
    end
  end
  object CoolBar1: TCoolBar
    Left = 0
    Top = 0
    Width = 805
    Height = 25
    AutoSize = True
    Bands = <
      item
        Control = TbMain
        ImageIndex = -1
        MinHeight = 21
        Width = 799
      end>
    object TbMain: TToolBar
      Left = 11
      Top = 0
      Width = 790
      Height = 21
      ButtonHeight = 19
      ButtonWidth = 57
      Caption = 'TbMain'
      List = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      object TbSearch: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'Search'
        ImageIndex = 2
        OnClick = DoSearchNow
      end
      object ToolButton15: TToolButton
        Left = 12
        Top = 0
        Width = 8
        Caption = 'ToolButton15'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object TbStopOperation: TToolButton
        Left = 20
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = TbStopOperationClick
      end
      object ToolButton6: TToolButton
        Left = 32
        Top = 0
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object TbSort: TToolButton
        Left = 40
        Top = 0
        AutoSize = True
        Caption = 'Sorting'
        DropdownMenu = SortingPopupMenu
        ImageIndex = 4
      end
      object ToolButton8: TToolButton
        Left = 52
        Top = 0
        Width = 8
        Caption = 'ToolButton8'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object TbZoomOut: TToolButton
        Left = 60
        Top = 0
        AutoSize = True
        Caption = 'Zoom Out'
        ImageIndex = 0
        OnClick = TbZoomOutClick
      end
      object TbZoomIn: TToolButton
        Left = 72
        Top = 0
        AutoSize = True
        Caption = 'Zoom in'
        DropdownMenu = PopupMenuZoomDropDown
        ImageIndex = 1
        Style = tbsDropDown
        OnClick = TbZoomInClick
      end
      object ToolButton11: TToolButton
        Left = 105
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object TbGroups: TToolButton
        Left = 113
        Top = 0
        AutoSize = True
        Caption = 'Groups'
        ImageIndex = 4
        OnClick = GroupsManager1Click
      end
      object ToolButton7: TToolButton
        Left = 125
        Top = 0
        Width = 8
        Caption = 'ToolButton7'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object TbSave: TToolButton
        Left = 133
        Top = 0
        AutoSize = True
        Caption = 'Save'
        ImageIndex = 2
        OnClick = SaveResults1Click
      end
      object TbLoad: TToolButton
        Left = 145
        Top = 0
        AutoSize = True
        Caption = 'Load'
        ImageIndex = 3
        OnClick = LoadResults1Click
      end
      object ToolButton13: TToolButton
        Left = 157
        Top = 0
        Width = 8
        Caption = 'ToolButton13'
        ImageIndex = 5
        Style = tbsSeparator
      end
      object TbExplorer: TToolButton
        Left = 165
        Top = 0
        Caption = 'Explorer'
        ImageIndex = 4
        OnClick = TbExplorerClick
      end
    end
  end
  object LsData: TLoadingSign
    Left = 775
    Top = 30
    Width = 16
    Height = 16
    Visible = False
    Active = True
    FillPercent = 50
    Color = clBtnFace
    ParentColor = False
    Anchors = [akTop, akRight]
    SignColor = clBlack
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\DolphinImagesDB\Search'
    Left = 224
    Top = 56
  end
  object HintTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = HintTimerTimer
    Left = 352
    Top = 56
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 448
    Top = 56
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 320
    Top = 56
    object DoSearchNow1: TMenuItem
      Caption = 'Do Search Now'
      OnClick = DoSearchNow
    end
    object Panels1: TMenuItem
      Caption = 'Panels'
      object Properties1: TMenuItem
        Caption = 'Properties'
        Checked = True
        RadioItem = True
        OnClick = Properties1Click
      end
      object Explorer2: TMenuItem
        Caption = 'Explorer'
        RadioItem = True
        OnClick = Explorer2Click
      end
    end
  end
  object PopupMenu3: TPopupMenu
    OnPopup = PopupMenu3Popup
    Left = 480
    Top = 56
    object Datenotexists1: TMenuItem
      Caption = 'Date not exists'
      OnClick = Datenotexists1Click
    end
    object DateExists1: TMenuItem
      Caption = 'Date Exists'
      OnClick = DateExists1Click
    end
    object Datenotsets1: TMenuItem
      Caption = 'Date not sets'
      OnClick = Datenotsets1Click
    end
  end
  object PopupMenu4: TPopupMenu
    OnPopup = PopupMenu4Popup
    Left = 224
    Top = 88
    object EditGroups1: TMenuItem
      Caption = 'Edit Groups'
      OnClick = ComboBox1_DblClick
    end
    object GroupsManager1: TMenuItem
      Caption = 'Groups Manager'
      OnClick = GroupsManager1Click
    end
  end
  object PopupMenu5: TPopupMenu
    OnPopup = PopupMenu5Popup
    Left = 257
    Top = 88
    object Ratingnotsets1: TMenuItem
      Caption = 'Rating not sets'
      OnClick = Ratingnotsets1Click
    end
  end
  object PopupMenu6: TPopupMenu
    OnPopup = PopupMenu6Popup
    Left = 288
    Top = 88
    object SetComent1: TMenuItem
      Caption = 'Set Coment'
      OnClick = SetComent1Click
    end
    object Comentnotsets1: TMenuItem
      Caption = 'Coment not sets'
      OnClick = Comentnotsets1Click
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object MenuItem2: TMenuItem
      Caption = 'Select All'
      OnClick = MenuItem2Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Cut1: TMenuItem
      Caption = 'Cut'
      OnClick = Cut1Click
    end
    object Copy2: TMenuItem
      Caption = 'Copy'
      OnClick = Copy2Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object Undo1: TMenuItem
      Caption = 'Undo'
      OnClick = Undo1Click
    end
  end
  object PopupMenu7: TPopupMenu
    OnPopup = PopupMenu7Popup
    Left = 322
    Top = 88
    object Setvalue1: TMenuItem
      Caption = 'Set value'
      OnClick = PanelValueIsDateSetsDblClick
    end
  end
  object ImageList1: TImageList
    Height = 102
    Width = 102
    Left = 479
  end
  object HelpTimer: TTimer
    Enabled = False
    OnTimer = HelpTimerTimer
    Left = 513
    Top = 56
  end
  object PopupMenu8: TPopupMenu
    OnPopup = PopupMenu8Popup
    Left = 354
    Top = 88
    object OpeninExplorer1: TMenuItem
      Caption = 'Open in Explorer'
      OnClick = OpeninExplorer1Click
    end
    object AddFolder1: TMenuItem
      Caption = 'Add Folder'
      OnClick = AddFolder1Click
    end
    object View2: TMenuItem
      Caption = 'View'
      OnClick = View2Click
    end
    object Hide1: TMenuItem
      Caption = 'Hide'
      Visible = False
      OnClick = Hide1Click
    end
  end
  object DropFileSource1: TDropFileSource
    DragTypes = [dtCopy, dtLink]
    Images = DragImageList
    ShowImage = True
    AllowAsyncTransfer = True
    Left = 290
    Top = 128
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Height = 102
    Width = 102
    Left = 258
    Top = 128
  end
  object DropFileTarget1: TDropFileTarget
    DragTypes = []
    AutoRegister = False
    OptimizedMove = True
    AllowAsyncTransfer = True
    Left = 322
    Top = 128
  end
  object QuickGroupsSearch: TPopupMenu
    Images = GroupsImageList
    Left = 384
    Top = 88
  end
  object SortingPopupMenu: TPopupMenu
    OnPopup = SortingPopupMenuPopup
    Left = 361
    Top = 128
    object SortbyID1: TMenuItem
      Caption = 'Sort by ID'
      Checked = True
      GroupIndex = 2
      RadioItem = True
      OnClick = SortbyID1Click
    end
    object SortbyName1: TMenuItem
      Tag = 1
      Caption = 'Sort by Name'
      GroupIndex = 2
      RadioItem = True
      OnClick = SortbyName1Click
    end
    object SortbyDate1: TMenuItem
      Tag = 2
      Caption = 'Sort by Date'
      GroupIndex = 2
      RadioItem = True
      OnClick = SortbyDate1Click
    end
    object SortbyRating1: TMenuItem
      Tag = 3
      Caption = 'Sort by Rating'
      GroupIndex = 2
      RadioItem = True
      OnClick = SortbyRating1Click
    end
    object SortbyFileSize1: TMenuItem
      Tag = 4
      Caption = 'Sort by FileSize'
      GroupIndex = 2
      RadioItem = True
      OnClick = SortbyFileSize1Click
    end
    object SortbySize1: TMenuItem
      Tag = 5
      Caption = 'Sort by Size'
      GroupIndex = 2
      RadioItem = True
      Visible = False
      OnClick = SortbySize1Click
    end
    object SortbyCompare1: TMenuItem
      Tag = 6
      Caption = 'Sort by Compare'
      GroupIndex = 2
      RadioItem = True
      Visible = False
      OnClick = SortbyCompare1Click
    end
    object N5: TMenuItem
      Caption = '-'
      GroupIndex = 3
    end
    object Increment1: TMenuItem
      Caption = 'Increment'
      Checked = True
      GroupIndex = 3
      RadioItem = True
      OnClick = Increment1Click
    end
    object Decremect1: TMenuItem
      Caption = 'Decremect'
      GroupIndex = 3
      RadioItem = True
      OnClick = Decremect1Click
    end
  end
  object GroupsImageList: TImageList
    Left = 641
  end
  object InsertSpesialQueryPopupMenu: TPopupMenu
    Left = 521
    Top = 88
  end
  object HidePanelTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = HidePanelTimerTimer
    Left = 489
    Top = 128
  end
  object PopupMenu10: TPopupMenu
    OnPopup = PopupMenu7Popup
    Left = 386
    Top = 56
    object Setvalue2: TMenuItem
      Caption = 'Set value'
      OnClick = PanelValueIsTimeSetsDblClick
    end
  end
  object PopupMenu11: TPopupMenu
    OnPopup = PopupMenu11Popup
    Left = 416
    Top = 56
    object Timenotexists1: TMenuItem
      Caption = 'Time not exists'
      OnClick = Timenotexists1Click
    end
    object TimeExists1: TMenuItem
      Caption = 'Time Exists'
      OnClick = TimeExists1Click
    end
    object Timenotsets1: TMenuItem
      Caption = 'Time not sets'
      OnClick = Timenotsets1Click
    end
  end
  object SelectTimer: TTimer
    Enabled = False
    Interval = 55
    OnTimer = SelectTimerTimer
    Left = 456
    Top = 88
  end
  object DropFileTarget2: TDropFileTarget
    DragTypes = [dtCopy, dtLink]
    OnDrop = DropFileTarget2Drop
    OptimizedMove = True
    Left = 393
    Top = 128
  end
  object ScriptListPopupMenu: TPopupMenu
    Left = 256
    Top = 56
  end
  object ScriptMainMenu: TMainMenu
    Left = 289
    Top = 56
  end
  object RatingPopupMenu1: TPopupMenu
    Left = 425
    Top = 128
    object N00: TMenuItem
      Caption = '0'
      OnClick = N05Click
    end
    object N01: TMenuItem
      Tag = 1
      Caption = '1'
      OnClick = N05Click
    end
    object N02: TMenuItem
      Tag = 2
      Caption = '2'
      OnClick = N05Click
    end
    object N03: TMenuItem
      Tag = 3
      Caption = '3'
      OnClick = N05Click
    end
    object N04: TMenuItem
      Tag = 4
      Caption = '4'
      OnClick = N05Click
    end
    object N05: TMenuItem
      Tag = 5
      Caption = '5'
      OnClick = N05Click
    end
  end
  object BigImagesTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = BigImagesTimerTimer
    Left = 417
    Top = 88
  end
  object SearchGroupsImageList: TImageList
    AllocBy = 1
    Height = 32
    Masked = False
    ShareImages = True
    Width = 32
    Left = 225
    Top = 128
  end
  object SearchImageList: TImageList
    Left = 569
  end
  object ToolBarImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 657
    Top = 144
  end
  object DisabledToolBarImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 657
    Top = 97
  end
  object PopupMenuZoomDropDown: TPopupMenu
    OnPopup = PopupMenuZoomDropDownPopup
    Left = 489
    Top = 89
  end
  object TmrSearchResultsCount: TTimer
    Enabled = False
    OnTimer = TmrSearchResultsCountTimer
    Left = 129
    Top = 26
  end
  object TmrQueryHintClose: TTimer
    Enabled = False
    Interval = 3000
    Left = 161
    Top = 26
  end
end
