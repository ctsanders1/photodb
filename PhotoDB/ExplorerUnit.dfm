object ExplorerForm: TExplorerForm
  Left = 221
  Top = 233
  Width = 1032
  Height = 782
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  AutoScroll = True
  Caption = 'DB Explorer'
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 300
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
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    1016
    744)
  PixelsPerInch = 96
  TextHeight = 13
  object SplLeftPanel: TSplitter
    Left = 140
    Top = 48
    Width = 5
    Height = 677
    Constraints.MaxWidth = 150
    ResizeStyle = rsUpdate
    OnCanResize = SplLeftPanelCanResize
    OnMoved = SplLeftPanelMoved
    ExplicitLeft = 150
    ExplicitTop = 47
    ExplicitHeight = 546
  end
  object BvSeparatorLeftPanel: TBevel
    Left = 145
    Top = 48
    Width = 1
    Height = 677
    Align = alLeft
    Shape = bsRightLine
    Style = bsRaised
    ExplicitLeft = 140
    ExplicitHeight = 545
  end
  object MainPanel: TPanel
    Left = 0
    Top = 48
    Width = 140
    Height = 677
    Align = alLeft
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    OnResize = MainPanelResize
    ExplicitHeight = 669
    object PcTasks: TPageControl
      Left = 0
      Top = 0
      Width = 140
      Height = 648
      ActivePage = TsInfo
      Align = alClient
      MultiLine = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnChange = PcTasksChange
      ExplicitHeight = 640
      object TsExplorer: TTabSheet
        Caption = 'Explorer'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PnResetFilter: TPanel
          Left = 0
          Top = 599
          Width = 132
          Height = 21
          Align = alBottom
          ParentBackground = False
          TabOrder = 0
          Visible = False
          OnResize = PnResetFilterResize
          object WlResetFilter: TWebLink
            Left = 31
            Top = 4
            Width = 64
            Height = 13
            Cursor = crHandPoint
            Text = 'WlResetFilter'
            OnClick = WlResetFilterClick
            ImageIndex = 0
            IconWidth = 0
            IconHeight = 0
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
      end
      object TsInfo: TTabSheet
        Caption = 'Info'
        ImageIndex = 2
        OnResize = TsInfoResize
        OnShow = TsInfoShow
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 612
        object PnInfoContainer: TPanel
          Left = 0
          Top = 0
          Width = 132
          Height = 620
          Align = alClient
          BevelOuter = bvNone
          ParentBackground = False
          TabOrder = 0
          ExplicitHeight = 612
          DesignSize = (
            132
            620)
          object LbEditComments: TLabel
            Tag = 2
            Left = 8
            Top = 494
            Width = 54
            Height = 13
            Caption = 'Comments:'
          end
          object LbEditKeywords: TLabel
            Tag = 2
            Left = 8
            Top = 416
            Width = 53
            Height = 13
            Caption = 'KeyWords:'
          end
          object ImHistogramm: TImage
            Left = 5
            Top = 182
            Width = 130
            Height = 105
            Anchors = [akLeft, akTop, akRight]
            Center = True
            Proportional = True
            Stretch = True
          end
          object LbHistogramImage: TLabel
            Left = 6
            Top = 163
            Width = 91
            Height = 13
            Caption = 'Histogramm image:'
          end
          object DimensionsLabel: TLabel
            Left = 8
            Top = 144
            Width = 78
            Height = 13
            Caption = 'DimensionsLabel'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object SizeLabel: TLabel
            Left = 92
            Top = 144
            Width = 44
            Height = 13
            Caption = 'SizeLabel'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object TypeLabel: TLabel
            Left = 6
            Top = 130
            Width = 49
            Height = 13
            Caption = 'TypeLabel'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            WordWrap = True
          end
          object NameLabel: TLabel
            Tag = 1
            Left = 7
            Top = 113
            Width = 62
            Height = 13
            Caption = 'NameLabel'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object ImPreview: TImage
            Left = 5
            Top = 3
            Width = 104
            Height = 104
            ParentCustomHint = False
            OnContextPopup = ImPreviewContextPopup
            OnDblClick = ImPreviewDblClick
          end
          object BtnSaveInfo: TButton
            Left = 62
            Top = 569
            Width = 73
            Height = 24
            Anchors = [akTop, akRight]
            Caption = 'BtnSaveInfo'
            Enabled = False
            TabOrder = 0
            OnClick = BtnSaveInfoClick
          end
          object MemComments: TMemo
            Tag = 1
            Left = 5
            Top = 513
            Width = 130
            Height = 50
            Anchors = [akLeft, akTop, akRight]
            ParentColor = True
            ScrollBars = ssVertical
            TabOrder = 1
            OnChange = MemCommentsChange
            OnEnter = MemCommentsEnter
          end
          object MemKeyWords: TMemo
            Tag = 1
            Left = 5
            Top = 435
            Width = 130
            Height = 50
            Anchors = [akLeft, akTop, akRight]
            ParentColor = True
            ScrollBars = ssVertical
            TabOrder = 2
            OnChange = MemKeyWordsChange
            OnEnter = MemKeyWordsEnter
          end
          object WllGroups: TWebLinkList
            Left = 5
            Top = 369
            Width = 130
            Height = 42
            HorzScrollBar.Visible = False
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            ParentBackground = True
            TabOrder = 3
            VerticalIncrement = 5
            HorizontalIncrement = 5
            LineHeight = 0
            PaddingTop = 2
            PaddingLeft = 2
          end
          object DteTime: TDateTimePicker
            Left = 5
            Top = 342
            Width = 130
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            Date = 38544.841692523150000000
            Time = 38544.841692523150000000
            ShowCheckbox = True
            Checked = False
            Color = clBtnFace
            DateFormat = dfLong
            Kind = dtkTime
            TabOrder = 4
            OnChange = DteTimeChange
            OnEnter = DteTimeEnter
          end
          object DteDate: TDateTimePicker
            Left = 5
            Top = 315
            Width = 130
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            Date = 38153.564945740740000000
            Time = 38153.564945740740000000
            ShowCheckbox = True
            Checked = False
            Color = clBtnFace
            DateFormat = dfLong
            TabOrder = 5
            OnChange = DteDateChange
            OnEnter = DteTimeEnter
          end
          object ReRating: TRating
            Left = 6
            Top = 293
            Width = 96
            Height = 16
            Cursor = crHandPoint
            ParentColor = False
            Color = clWhite
            Rating = 0
            RatingRange = 0
            OnChange = ReRatingChange
            Islayered = False
            Layered = 100
            OnMouseDown = ReRatingMouseDown
            ImageCanRegenerate = True
            CanSelectRange = False
          end
        end
      end
      object TsEXIF: TTabSheet
        Caption = 'EXIF'
        ImageIndex = 3
        TabVisible = False
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object VleExif: TValueListEditor
          Left = 0
          Top = 0
          Width = 132
          Height = 620
          Align = alClient
          DefaultColWidth = 70
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goColSizing, goRowSelect, goThumbTracking, goFixedHotTrack]
          TabOrder = 0
          OnDrawCell = VleExifDrawCell
          ColWidths = (
            70
            56)
        end
      end
      object TsDetailedSearch: TTabSheet
        Caption = 'Search'
        ImageIndex = 4
        TabVisible = False
        OnResize = TsDetailedSearchResize
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PnESContainer: TPanel
          Left = 0
          Top = 0
          Width = 132
          Height = 620
          Align = alClient
          BevelOuter = bvNone
          Ctl3D = True
          ParentBackground = False
          ParentCtl3D = False
          TabOrder = 0
          DesignSize = (
            132
            620)
          object BvRating: TBevel
            Left = 3
            Top = 75
            Width = 126
            Height = 2
            Anchors = [akLeft, akTop, akRight]
            Shape = bsBottomLine
          end
          object BvPersons: TBevel
            Left = 4
            Top = 130
            Width = 126
            Height = 2
            Anchors = [akLeft, akTop, akRight]
            Shape = bsBottomLine
          end
          object BvGroups: TBevel
            Left = 4
            Top = 185
            Width = 126
            Height = 2
            Anchors = [akLeft, akTop, akRight]
            Shape = bsBottomLine
          end
          object PnExtendedSearch: TPanel
            Left = 0
            Top = 3
            Width = 132
            Height = 25
            Anchors = [akLeft, akTop, akRight]
            BevelInner = bvLowered
            BevelOuter = bvSpace
            ParentBackground = False
            TabOrder = 0
            object SbExtendedSearchMode: TSpeedButton
              Left = 2
              Top = 2
              Width = 30
              Height = 21
              Align = alLeft
              Constraints.MaxWidth = 30
              Constraints.MinWidth = 30
              Flat = True
              PopupMenu = PmSearchMode
              OnClick = SbSearchModeClick
              ExplicitLeft = 699
              ExplicitTop = 1
              ExplicitHeight = 24
            end
            object SbExtendedSearchStart: TSpeedButton
              Left = 110
              Top = 2
              Width = 20
              Height = 21
              Align = alRight
              Flat = True
              OnClick = SbDoSearchClick
              ExplicitLeft = 160
              ExplicitTop = 1
              ExplicitHeight = 23
            end
            object PnExtendedSearchEditPlace: TPanel
              Left = 32
              Top = 2
              Width = 78
              Height = 21
              Align = alClient
              BevelOuter = bvNone
              ParentBackground = False
              TabOrder = 0
              DesignSize = (
                78
                21)
              object EdExtendedSearchText: TWatermarkedEdit
                Left = 2
                Top = 4
                Width = 73
                Height = 17
                Anchors = [akLeft, akTop, akRight]
                BevelEdges = []
                BevelInner = bvNone
                BevelOuter = bvNone
                BorderStyle = bsNone
                TabOrder = 0
                OnKeyPress = WedSearchKeyPress
                WatermarkText = 'Search in directory'
              end
            end
          end
          object WlSearchRatingFrom: TWebLink
            Left = 7
            Top = 31
            Width = 100
            Height = 16
            Cursor = crHandPoint
            Text = 'WlSearchRatingFrom'
            OnClick = WlSearchRatingFromClick
            ImageIndex = 0
            IconWidth = 0
            UseEnterColor = False
            EnterColor = clBlack
            EnterBould = False
            TopIconIncrement = 0
            UseSpecIconSize = True
            HightliteImage = False
            StretchImage = True
            CanClick = True
          end
          object WlSearchRatingFromValue: TWebLink
            Left = 111
            Top = 31
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnClick = WlSearchRatingFromClick
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
          object WlSearchRatingToValue: TWebLink
            Left = 102
            Top = 53
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnClick = WlSearchRatingToClick
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
          object WlSearchRatingTo: TWebLink
            Left = 8
            Top = 53
            Width = 88
            Height = 16
            Cursor = crHandPoint
            Text = 'WlSearchRatingTo'
            OnClick = WlSearchRatingToClick
            ImageIndex = 0
            IconWidth = 0
            UseEnterColor = False
            EnterColor = clBlack
            EnterBould = False
            TopIconIncrement = 0
            UseSpecIconSize = True
            HightliteImage = False
            StretchImage = True
            CanClick = True
          end
          object WllExtendedSearchPersons: TWebLinkList
            Left = 2
            Top = 83
            Width = 130
            Height = 41
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            ParentBackground = True
            TabOrder = 5
            VerticalIncrement = 5
            HorizontalIncrement = 5
            LineHeight = 0
            PaddingTop = 0
            PaddingLeft = 0
          end
          object WllExtendedSearchGroups: TWebLinkList
            Left = 2
            Top = 138
            Width = 130
            Height = 41
            Anchors = [akLeft, akTop, akRight]
            BevelEdges = []
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            ParentBackground = True
            TabOrder = 6
            VerticalIncrement = 5
            HorizontalIncrement = 5
            LineHeight = 0
            PaddingTop = 0
            PaddingLeft = 0
          end
          object WlExtendedSearchDateFrom: TWebLink
            Left = 3
            Top = 193
            Width = 159
            Height = 16
            Cursor = crHandPoint
            Text = 'WlExtendedSearchDateFrom'
            OnClick = WlExtendedSearchDateFromClick
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
          object WlExtendedSearchDateTo: TWebLink
            Left = 3
            Top = 215
            Width = 147
            Height = 16
            Cursor = crHandPoint
            Text = 'WlExtendedSearchDateTo'
            OnClick = WlExtendedSearchDateFromClick
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
          object WlExtendedSearchSortDescending: TWebLink
            Left = 5
            Top = 237
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnClick = WlExtendedSearchSortDescendingClick
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
          object WlExtendedSearchSortBy: TWebLink
            Left = 26
            Top = 238
            Width = 123
            Height = 13
            Cursor = crHandPoint
            PopupMenu = PmESSorting
            Text = 'WlExtendedSearchSortBy'
            OnClick = WlExtendedSearchSortByClick
            ImageIndex = 0
            IconWidth = 0
            IconHeight = 0
            UseEnterColor = False
            EnterColor = clBlack
            EnterBould = False
            TopIconIncrement = 0
            UseSpecIconSize = True
            HightliteImage = False
            StretchImage = True
            CanClick = True
          end
          object WlExtendedSearchOptions: TWebLink
            Left = 3
            Top = 259
            Width = 21
            Height = 16
            Cursor = crHandPoint
            OnContextPopup = WlExtendedSearchOptionsContextPopup
            PopupMenu = PmESOptions
            OnClick = WlExtendedSearchOptionsClick
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
          object BtnSearch: TButton
            Left = 45
            Top = 257
            Width = 87
            Height = 24
            Anchors = [akTop, akRight]
            Caption = 'BtnSearch'
            ImageMargins.Left = 3
            TabOrder = 12
            OnClick = SbDoSearchClick
          end
        end
      end
    end
    object PnShelf: TPanel
      Left = 0
      Top = 648
      Width = 140
      Height = 29
      Align = alBottom
      ParentBackground = False
      TabOrder = 1
      Visible = False
      ExplicitTop = 640
      object WlGoToShelf: TWebLink
        Left = 5
        Top = 6
        Width = 82
        Height = 16
        Cursor = crHandPoint
        Text = 'WlGoToShelf'
        OnClick = WlGoToShelfClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = False
        CanClick = True
      end
    end
  end
  object CoolBarTop: TCoolBar
    Left = 0
    Top = 0
    Width = 1016
    Height = 21
    AutoSize = True
    BandBorderStyle = bsNone
    BandMaximize = bmNone
    Bands = <
      item
        Control = ToolBarMain
        ImageIndex = -1
        MinHeight = 21
        Width = 1016
      end>
    EdgeBorders = []
    FixedOrder = True
    object ToolBarMain: TToolBar
      Left = 0
      Top = 0
      Width = 1016
      Height = 21
      ButtonHeight = 19
      ButtonWidth = 12
      Color = clInactiveCaption
      EdgeInner = esNone
      EdgeOuter = esNone
      GradientEndColor = 11319229
      List = True
      ParentColor = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      OnMouseMove = ToolBarMainMouseMove
      object TbBack: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuBack
        ImageIndex = 0
        Style = tbsDropDown
        OnClick = SpeedButton1Click
        OnMouseDown = TbBackMouseDown
      end
      object TbForward: TToolButton
        Left = 27
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuForward
        ImageIndex = 2
        Style = tbsDropDown
        OnClick = SpeedButton2Click
        OnMouseDown = TbForwardMouseDown
      end
      object TbUp: TToolButton
        Left = 54
        Top = 0
        AutoSize = True
        ImageIndex = 1
        OnClick = SpeedButton3Click
      end
      object ToolButton4: TToolButton
        Left = 66
        Top = 0
        Width = 8
        Caption = 'ToolButton3'
        ImageIndex = 10
        Style = tbsSeparator
      end
      object TbCut: TToolButton
        Left = 74
        Top = 0
        AutoSize = True
        DropdownMenu = PmCut
        ImageIndex = 3
        Style = tbsDropDown
        OnClick = CutClick
      end
      object TbCopy: TToolButton
        Left = 101
        Top = 0
        AutoSize = True
        DropdownMenu = PmCopy
        ImageIndex = 4
        Style = tbsDropDown
        OnClick = CopyClick
      end
      object TbPaste: TToolButton
        Left = 128
        Top = 0
        AutoSize = True
        ImageIndex = 5
        OnClick = PasteClick
      end
      object ToolButton17: TToolButton
        Left = 140
        Top = 0
        Width = 8
        Caption = 'ToolButton17'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object TbDelete: TToolButton
        Left = 148
        Top = 0
        AutoSize = True
        ImageIndex = 6
        OnClick = TbDeleteClick
      end
      object ToolButton10: TToolButton
        Left = 160
        Top = 0
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object ToolButtonView: TToolButton
        Left = 168
        Top = 0
        AutoSize = True
        DropdownMenu = PmListViewType
        ImageIndex = 7
        Style = tbsDropDown
        OnClick = ToolButtonViewClick
      end
      object TbSort: TToolButton
        Left = 195
        Top = 0
        AutoSize = True
        Caption = 'TbSort'
        ImageIndex = 15
        Style = tbsDropDown
        Visible = False
      end
      object TbSearch: TToolButton
        Left = 222
        Top = 0
        AutoSize = True
        ImageIndex = 10
        OnClick = TbSearchClick
      end
      object TbPreview: TToolButton
        Tag = 1
        Left = 234
        Top = 0
        AutoSize = True
        ImageIndex = 12
        OnClick = TbPreviewClick
      end
      object TbImport: TToolButton
        Left = 246
        Top = 0
        AutoSize = True
        ImageIndex = 13
        OnClick = TbImportClick
      end
      object ToolButton11: TToolButton
        Left = 258
        Top = 0
        Width = 8
        Caption = 'ToolButton11'
        ImageIndex = 7
        Style = tbsSeparator
      end
      object TbZoomOut: TToolButton
        Left = 266
        Top = 0
        AutoSize = True
        ImageIndex = 8
        OnClick = TbZoomOutClick
      end
      object TbZoomIn: TToolButton
        Left = 278
        Top = 0
        AutoSize = True
        DropdownMenu = PopupMenuZoomDropDown
        ImageIndex = 9
        Style = tbsDropDown
        OnClick = TbZoomInClick
      end
      object ToolButton20: TToolButton
        Left = 305
        Top = 0
        Width = 8
        Caption = 'ToolButton20'
        ImageIndex = 13
        Style = tbsSeparator
      end
      object TbDatabase: TToolButton
        Left = 313
        Top = 0
        AutoSize = True
        DropdownMenu = PmDBList
        ImageIndex = 15
        Style = tbsDropDown
        Visible = False
        OnClick = TbDatabaseClick
      end
      object TbOptions: TToolButton
        Left = 340
        Top = 0
        AutoSize = True
        Caption = 'Options'
        DropdownMenu = PmOptions
        ImageIndex = 11
        Style = tbsDropDown
        OnClick = Options1Click
      end
      object ToolButton1: TToolButton
        Left = 367
        Top = 0
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 13
        Style = tbsSeparator
      end
      object TbHelp: TToolButton
        Left = 375
        Top = 0
        AutoSize = True
        DropdownMenu = PmHelp
        ImageIndex = 14
        Style = tbsDropDown
        OnClick = TbHelpClick
      end
    end
  end
  object LsMain: TLoadingSign
    Left = 983
    Top = 49
    Width = 20
    Height = 20
    DisableStyles = True
    Visible = False
    Active = True
    FillPercent = 70
    Anchors = [akTop, akRight]
    SignColor = clBlack
    MaxTransparencity = 255
  end
  object PnNavigation: TPanel
    Left = 0
    Top = 21
    Width = 1016
    Height = 27
    Align = alTop
    AutoSize = True
    BevelEdges = [beBottom]
    ParentColor = True
    TabOrder = 3
    object BvSeparatorAddress: TBevel
      Left = 825
      Top = 1
      Width = 2
      Height = 25
      Align = alRight
      Shape = bsRightLine
      ExplicitLeft = 668
      ExplicitTop = 6
    end
    object BvSeparatorSearch: TBevel
      Left = 60
      Top = 1
      Width = 2
      Height = 25
      Align = alLeft
      Shape = bsRightLine
      ExplicitTop = 2
    end
    object slSearch: TSplitter
      Left = 827
      Top = 1
      Height = 25
      Align = alRight
      Beveled = True
      ResizeStyle = rsUpdate
      OnCanResize = slSearchCanResize
      ExplicitLeft = 668
      ExplicitTop = 6
    end
    object PnSearch: TPanel
      Left = 830
      Top = 1
      Width = 185
      Height = 25
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object SbSearchMode: TSpeedButton
        Left = 0
        Top = 0
        Width = 30
        Height = 25
        Align = alLeft
        Constraints.MaxWidth = 30
        Constraints.MinWidth = 30
        Flat = True
        PopupMenu = PmSearchMode
        OnClick = SbSearchModeClick
        ExplicitLeft = 699
        ExplicitTop = 1
        ExplicitHeight = 24
      end
      object SbDoSearch: TSpeedButton
        Left = 165
        Top = 0
        Width = 20
        Height = 25
        Align = alRight
        Flat = True
        OnClick = SbDoSearchClick
        ExplicitLeft = 160
        ExplicitTop = 1
        ExplicitHeight = 23
      end
      object PnSearchEditPlace: TPanel
        Left = 30
        Top = 0
        Width = 135
        Height = 25
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          135
          25)
        object WedSearch: TWatermarkedEdit
          Left = 2
          Top = 4
          Width = 130
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          BevelEdges = []
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          TabOrder = 0
          OnEnter = WedSearchEnter
          OnKeyPress = WedSearchKeyPress
          WatermarkText = 'Search in directory'
        end
      end
    end
    object StAddress: TStaticText
      AlignWithMargins = True
      Left = 4
      Top = 6
      Width = 53
      Height = 17
      Margins.Top = 5
      Align = alLeft
      Alignment = taCenter
      Caption = '  Address:'
      TabOrder = 1
    end
    object PePath: TPathEditor
      Left = 62
      Top = 1
      Width = 763
      Height = 25
      DoubleBuffered = False
      ParentDoubleBuffered = False
      Align = alClient
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
      OnUserChange = PePathChange
      OnUpdateItem = PePathUpdateItem
      LoadingText = 'Loading...'
      GetSystemIcon = PePathGetSystemIcon
      CanBreakLoading = False
      OnBreakLoading = TbStopClick
      OnImageContextPopup = PePathImageContextPopup
      OnContextPopup = PePathContextPopup
      GetItemIconEvent = PePathGetItemIconEvent
      OnlyFileSystem = False
      HideExtendedButton = False
      ShowBorder = False
    end
  end
  object PnContent: TPanel
    Left = 146
    Top = 48
    Width = 870
    Height = 677
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 4
    ExplicitHeight = 669
    object SplRightPanel: TSplitter
      Left = 507
      Top = 33
      Width = 5
      Height = 611
      ResizeStyle = rsUpdate
      Visible = False
      OnCanResize = SplRightPanelCanResize
      ExplicitHeight = 580
    end
    object PnFilter: TPanel
      Left = 0
      Top = 644
      Width = 870
      Height = 33
      Align = alBottom
      TabOrder = 0
      Visible = False
      object LbFilter: TLabel
        Left = 38
        Top = 9
        Width = 28
        Height = 13
        Caption = 'Filter:'
      end
      object LbFilterInfo: TLabel
        Left = 400
        Top = 9
        Width = 139
        Height = 13
        Caption = 'Sorry, but phrase not found!'
        Visible = False
      end
      object ImFilterWarning: TImage
        Left = 380
        Top = 8
        Width = 16
        Height = 16
        Picture.Data = {
          055449636F6E0000010001001010000001002000680400001600000028000000
          1000000020000000010020000000000040040000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000001D1505146B842650C0D6
          4175D3F93969CFF21536A5BF0004505F00000E03000000000000000000000000
          0000000000000000000000000000000000002F3F2851C7EB7EB9FDFFA7D3FFFF
          BDDFFFFFBADBFFFF94C1FEFF568EF1FF0D229BC400000E110000000000000000
          00000000000000000000000000002C28204DCFF4619EFBFF73AEFDFF9EC9FEFF
          FFFFFFFFFFFFFFFF86B5FCFF5C96F9FF3C79F4FF061A9AC400000E0300000000
          000000000000000000000000041A9AB82469F4FF3A7FF7FF4B8EF9FF7FB1FCFF
          FFFFFFFFFFFFFFFF649BF9FF3476F5FF1E5FF2FF0E47E8FF0002506300000000
          0000000000000000AAAAD61A0A36D2FF1457F1FF1960F3FF216AF4FF6197F8FF
          FFFFFFFFFFFFFFFF4680F6FF1659F1FF114FF0FF0C44EDFF0215AEC400000000
          0000000000000000AAAAD64C0A3FE8FF0F4BEFFF205DF1FF356FF3FF6B97F7FF
          FFFFFFFFFFFFFFFF5987F5FF2E63F1FF134AEEFF083AEBFF021EC4F600000000
          0000000000000000AAAAD6550636EAFF1F4FEEFF4973F2FF4B77F3FF799BF7FF
          FFFFFFFFFFFFFFFF688CF5FF4871F2FF4167F0FF0934E9FF001BC6FF00000000
          0000000000000000AAAAD6330122D9FF4869F0FF5B7CF2FF5D7EF3FF87A1F7FF
          FFFFFFFFFFFFFFFF7893F5FF5B79F2FF5975F1FF2A4DECFF0118B9DD00000000
          0000000000000000AAAAB8030116B9E65F79F1FF6E86F3FF6F87F3FF7890F4FF
          94A7F8FF94A6F8FF758CF3FF6F86F3FF718BF4FF4776F3FF020E7C9400000000
          000000000000000000000000000351685178EBFF88A1F7FF869DF6FFA4B5F9FF
          FFFFFFFFFFFFFFFF9CB1F9FF8BA9F9FF90B6FBFF2D5FD2F200001D1F00000000
          00000000000000000000000000000E0109198D9D7BACF4FFA4C7FDFFAFCCFDFF
          D5E7FFFFD6E8FFFFAFD2FEFFA8D3FEFF568DDFF900055E4F0000000000000000
          0000000000000000000000000000000000000E01040E65713F6CCBED7FBCF5FF
          98D4FFFF95D3FFFF6DA5E9FF264AB8D100003D3A000000000000000000000000
          0000000000000000000000000000000000000000000000005555630855558145
          555BB6685558A461555581310000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000FFFF0000FFFF0000F00F0000E0070000C0030000C003000080030000
          80030000800300008003000080030000C0030000C0070000E00F0000F83F0000
          FFFF0000}
        Visible = False
      end
      object WedFilter: TWatermarkedEdit
        Left = 72
        Top = 6
        Width = 150
        Height = 21
        TabOrder = 0
        OnChange = WedFilterChange
        OnKeyPress = WedFilterKeyPress
        WatermarkText = 'Filter content'
      end
      object ImbCloseFilter: TImButton
        Left = 4
        Top = 6
        Width = 21
        Height = 21
        ImageNormal.Data = {
          07544269746D6170DE070000424DDE0700000000000042040000280000001500
          00001500000001001000030000009C0300000000000000000000000100000000
          0000007C0000E00300001F000000000000000000800000800000008080008000
          00008000800080800000C0C0C000C0DCC000F0CAA60033000000000033003300
          330033330000161616001C1C1C002222220029292900555555004D4D4D004242
          420039393900807CFF005050FF009300D600FFECCC00C6D6EF00D6E7E70090A9
          AD0000FF330000006600000099000000CC000033000000333300003366000033
          99000033CC000033FF00006600000066330000666600006699000066CC000066
          FF00009900000099330000996600009999000099CC000099FF0000CC000000CC
          330000CC660000CC990000CCCC0000CCFF0000FF660000FF990000FFCC0033FF
          0000FF00330033006600330099003300CC003300FF00FF330000333333003333
          6600333399003333CC003333FF00336600003366330033666600336699003366
          CC003366FF00339900003399330033996600339999003399CC003399FF0033CC
          000033CC330033CC660033CC990033CCCC0033CCFF0033FF330033FF660033FF
          990033FFCC0033FFFF00660000006600330066006600660099006600CC006600
          FF00663300006633330066336600663399006633CC006633FF00666600006666
          330066666600666699006666CC00669900006699330066996600669999006699
          CC006699FF0066CC000066CC330066CC990066CCCC0066CCFF0066FF000066FF
          330066FF990066FFCC00CC00FF00FF00CC009999000099339900990099009900
          CC009900000099333300990066009933CC009900FF0099660000996633009933
          6600996699009966CC009933FF009999330099996600999999009999CC009999
          FF0099CC000099CC330066CC660099CC990099CCCC0099CCFF0099FF000099FF
          330099CC660099FF990099FFCC0099FFFF00CC00000099003300CC006600CC00
          9900CC00CC0099330000CC333300CC336600CC339900CC33CC00CC33FF00CC66
          0000CC66330099666600CC669900CC66CC009966FF00CC990000CC993300CC99
          6600CC999900CC99CC00CC99FF00CCCC0000CCCC3300CCCC6600CCCC9900CCCC
          CC00CCCCFF00CCFF0000CCFF330099FF6600CCFF9900CCFFCC00CCFFFF00CC00
          3300FF006600FF009900CC330000FF333300FF336600FF339900FF33CC00FF33
          FF00FF660000FF663300CC666600FF669900FF66CC00CC66FF00FF990000FF99
          3300FF996600FF999900FF99CC00FF99FF00FFCC0000FFCC3300FFCC6600FFCC
          9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF9900FFFFCC006666FF0066FF
          660066FFFF00FF666600FF66FF00FFFF66002100A5005F5F5F00777777008686
          860096969600CBCBCB00B2B2B200D7D7D700DDDDDD00E3E3E300EAEAEA00F1F1
          F100F8F8F800F0FBFF00A4A0A000808080000000FF0000FF000000FFFF00FF00
          0000FF00FF00FFFF0000FFFFFF009E0D1D5BFF7FFF7FFF7FFF7FFF7FFF7FFF7F
          FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FDF7B1D5B7D0D00001D5B5A770559
          A150C254C254C254C254C254C254C254C158A158A158A058A05880588054E354
          59771D5B0000DF7B2565E264E364046504650465046504690469036903690269
          0269E168E168C068C068A060E354FF7F0000FF7FC16C036D256D456D466D4671
          467146714571457144714371237122710171E070E070A0688054FF7F0000FF7F
          E26C247146716771677167716771677166716671657144754375437522750175
          E070C0688054FF7F0000FF7F036D457167718871167BFF7F8871887187718771
          867565756475FF7FF47A21750171C0688058FF7F0000FF7F036D667188718971
          FF7FFF7FFF7FA8718871877186756575FF7FFF7FFF7F22750171E168A058FF7F
          0000FF7F247167718971A971AA71FF7FFF7FFF7FA87187718675FF7FFF7FFF7F
          437522750271E26CA158FF7F0000FF7F25718871A971AA71AA71AA71FF7FFF7F
          FF7F8771FF7FFF7FDE7F44754375237123710269C158FF7F0000FF7F4671A971
          CA71CA71CA75AA71A971FF7FFF7FFF7FFF7FFF7F447144712371237123710369
          C258FF7F0000FF7F6671AA71CA75CB75CA71AA71A9718871FF7FFF7FFF7F4571
          447144712371237124712469C254FF7F0000FF7F6771CB75CB75CB75CB71AA71
          A971FF7FFF7FFF7FFF7FFF7F447124712471247124712469C354FF7F0000FF7F
          8871EC75EC75EC75CB75AA71FF7FFF7FFF7F6771FF7FFF7FFF7F247124712471
          45712569E354FF7F0000FF7F88710D760D76EC75CB75FF7FFF7FFF7F88716771
          6671FF7FFF7FFF7F2471457145712569E354FF7F0000FF7FA9710D762E760D76
          FF7FFF7FFF7FA9718871687167714671FF7FFF7FFF7F4571456D2569E354FF7F
          0000FF7FAA714F764F762E76387BFF7FCB71AA71A9718871687167716771FF7F
          F57A4671466D2569E354FF7F0000FF7FCB75717691764F762E760D76EC75EB75
          CB71AA71AA71A971A97188718771677146712569C354FF7F0000FF7FEC75B27A
          B37A71764F762E760D760D76EC75EC75EC75CB75CB75AA71A971887166712569
          C254FF7F0000FF7F2E769276927A70762E760D760D76EC75EC75EB75EB75CB75
          CA71AA71A9718771467104692659DF7B00001D5B9B7F2E76EC75CA71A9718971
          8871887167716771677167714671467146712571036D46697A771D5B00007C0D
          1D5BDF7BFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F
          FF7FFF7F1D5B3A0D0000}
        ImageEnter.Data = {
          07544269746D6170DE070000424DDE0700000000000042040000280000001500
          00001500000001001000030000009C0300000000000000000000000100000000
          0000007C0000E00300001F000000000000000000800000800000008080008000
          00008000800080800000C0C0C000C0DCC000F0CAA60033000000000033003300
          330033330000161616001C1C1C002222220029292900555555004D4D4D004242
          420039393900807CFF005050FF009300D600FFECCC00C6D6EF00D6E7E70090A9
          AD0000FF330000006600000099000000CC000033000000333300003366000033
          99000033CC000033FF00006600000066330000666600006699000066CC000066
          FF00009900000099330000996600009999000099CC000099FF0000CC000000CC
          330000CC660000CC990000CCCC0000CCFF0000FF660000FF990000FFCC0033FF
          0000FF00330033006600330099003300CC003300FF00FF330000333333003333
          6600333399003333CC003333FF00336600003366330033666600336699003366
          CC003366FF00339900003399330033996600339999003399CC003399FF0033CC
          000033CC330033CC660033CC990033CCCC0033CCFF0033FF330033FF660033FF
          990033FFCC0033FFFF00660000006600330066006600660099006600CC006600
          FF00663300006633330066336600663399006633CC006633FF00666600006666
          330066666600666699006666CC00669900006699330066996600669999006699
          CC006699FF0066CC000066CC330066CC990066CCCC0066CCFF0066FF000066FF
          330066FF990066FFCC00CC00FF00FF00CC009999000099339900990099009900
          CC009900000099333300990066009933CC009900FF0099660000996633009933
          6600996699009966CC009933FF009999330099996600999999009999CC009999
          FF0099CC000099CC330066CC660099CC990099CCCC0099CCFF0099FF000099FF
          330099CC660099FF990099FFCC0099FFFF00CC00000099003300CC006600CC00
          9900CC00CC0099330000CC333300CC336600CC339900CC33CC00CC33FF00CC66
          0000CC66330099666600CC669900CC66CC009966FF00CC990000CC993300CC99
          6600CC999900CC99CC00CC99FF00CCCC0000CCCC3300CCCC6600CCCC9900CCCC
          CC00CCCCFF00CCFF0000CCFF330099FF6600CCFF9900CCFFCC00CCFFFF00CC00
          3300FF006600FF009900CC330000FF333300FF336600FF339900FF33CC00FF33
          FF00FF660000FF663300CC666600FF669900FF66CC00CC66FF00FF990000FF99
          3300FF996600FF999900FF99CC00FF99FF00FFCC0000FFCC3300FFCC6600FFCC
          9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF9900FFFFCC006666FF0066FF
          660066FFFF00FF666600FF66FF00FFFF66002100A5005F5F5F00777777008686
          860096969600CBCBCB00B2B2B200D7D7D700DDDDDD00E3E3E300EAEAEA00F1F1
          F100F8F8F800F0FBFF00A4A0A000808080000000FF0000FF000000FFFF00FF00
          0000FF00FF00FFFF0000FFFFFF007E01DE4ADF7BFF7FFF7FFF7FFF7FFF7FFF7F
          FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FDF7BDE4A3E010000DE4A7A7B4869
          E564E564066506650665066526692669266D266D266D266D266D256D05694865
          7A7BDE4A0000DF7B6975267527754875487569756975697589798A79AA79AA79
          AA79A979A97D8879677926714865DF7B0000FF7F267D487D697D8A7D8A7D8A7D
          AB7DCB7DCC7DEC7D0C7E0C7E0C7E0C7EEB7DCA7DA87D47790569FF7F0000FF7F
          277D697D8A7DAB7DAB7DCB7DCC7DED7D0D7E2E7E4E7E4E7E4E7E4D7E2C7E0B7E
          CA7D8879056DFF7F0000FF7F477D8A7DAB7DCC7D187FFF7FED7D0D7E2E7E4F7E
          6F7E6F7E8F7EFF7F587F2C7EEA7D8879266DFF7F0000FF7F487DAA7DCC7DCC7D
          FF7FFF7FFF7F0E7E2F7E4F7E6F7E8F7EFF7FFF7FFF7F2C7EEB7DA979266DFF7F
          0000FF7F697DAB7DCC7DED7DED7DFF7FFF7FFF7F4F7E4F7E6F7EFF7FFF7FFF7F
          4E7E2D7E0B7EA979266DFF7F0000FF7F697DCC7DED7DEE7D0E7E0E7EFF7FFF7F
          FF7F4F7EFF7FFF7FFE7F4D7E4D7E2C7EEB7DAA79276DFF7F0000FF7F8A7DED7D
          0E7E0E7E0E7E0E7E0E7EFF7FFF7FFF7FFF7FFF7F2D7E2D7E0C7E0C7EEB7DAA79
          2769FF7F0000FF7FAB7DEE7D0E7E0F7E0E7E0E7E0E7E0E7EFF7FFF7FFF7F0D7E
          0C7EEC7DEB7DEB7DCB7DAA792769FF7F0000FF7FAB7D0E7E2F7E2F7E2F7E0E7E
          0E7EFF7FFF7FFF7FFF7FFF7FCB7DCB7DCB7DCB7DCB7D8A792769FF7F0000FF7F
          CC7D2F7E507E307E2F7E0E7EFF7FFF7FFF7FCC7DFF7FFF7FFF7FAA7DAA7DAA7D
          AA7D8A792765FF7F0000FF7FCC7D507E517E507E307EFF7FFF7FFF7FED7DCC7D
          AB7DFF7FFF7FFF7F8A7D8A7D8A7D89792765FF7F0000FF7FED7D717E727E717E
          FF7FFF7FFF7F0E7EED7DCC7DAB7DAB7DFF7FFF7FFF7F8A7D8A7D69752765FF7F
          0000FF7FEE7D927E937E727E5A7FFF7F2F7E0E7EED7DED7DCC7DAB7DAB7DFF7F
          177F8A7D8A7D69752765FF7F0000FF7F0E7EB47ED47EB37E727E717E507E2F7E
          2F7E0E7E0E7EED7DED7DCC7DCC7DAB7D8A7D69750665FF7F0000FF7F307ED57E
          F67ED47E937E727E717E517E507E307E2F7E2F7E0E7EEE7DED7DCC7DAA7D6975
          0665FF7F0000DF7B507EB47ED57EB37E727E717E517E507E307E2F7E2F7E0E7E
          0E7EED7DCC7DAB7D8A7D48756969DF7B0000BD4A9C7F507E2F7E0E7EED7DED7D
          CC7DCC7DCB7DAB7DAB7DAB7D8A7D8A7D8A7D697D487D8A757A7BBD4A00005C01
          BD4ADF7BFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F
          FF7FDF7BBD4AF9000000}
        ImageClick.Data = {
          07544269746D6170DE070000424DDE0700000000000042040000280000001500
          00001500000001001000030000009C0300000000000000000000000100000000
          0000007C0000E00300001F000000000000000000800000800000008080008000
          00008000800080800000C0C0C000C0DCC000F0CAA60033000000000033003300
          330033330000161616001C1C1C002222220029292900555555004D4D4D004242
          420039393900807CFF005050FF009300D600FFECCC00C6D6EF00D6E7E70090A9
          AD0000FF330000006600000099000000CC000033000000333300003366000033
          99000033CC000033FF00006600000066330000666600006699000066CC000066
          FF00009900000099330000996600009999000099CC000099FF0000CC000000CC
          330000CC660000CC990000CCCC0000CCFF0000FF660000FF990000FFCC0033FF
          0000FF00330033006600330099003300CC003300FF00FF330000333333003333
          6600333399003333CC003333FF00336600003366330033666600336699003366
          CC003366FF00339900003399330033996600339999003399CC003399FF0033CC
          000033CC330033CC660033CC990033CCCC0033CCFF0033FF330033FF660033FF
          990033FFCC0033FFFF00660000006600330066006600660099006600CC006600
          FF00663300006633330066336600663399006633CC006633FF00666600006666
          330066666600666699006666CC00669900006699330066996600669999006699
          CC006699FF0066CC000066CC330066CC990066CCCC0066CCFF0066FF000066FF
          330066FF990066FFCC00CC00FF00FF00CC009999000099339900990099009900
          CC009900000099333300990066009933CC009900FF0099660000996633009933
          6600996699009966CC009933FF009999330099996600999999009999CC009999
          FF0099CC000099CC330066CC660099CC990099CCCC0099CCFF0099FF000099FF
          330099CC660099FF990099FFCC0099FFFF00CC00000099003300CC006600CC00
          9900CC00CC0099330000CC333300CC336600CC339900CC33CC00CC33FF00CC66
          0000CC66330099666600CC669900CC66CC009966FF00CC990000CC993300CC99
          6600CC999900CC99CC00CC99FF00CCCC0000CCCC3300CCCC6600CCCC9900CCCC
          CC00CCCCFF00CCFF0000CCFF330099FF6600CCFF9900CCFFCC00CCFFFF00CC00
          3300FF006600FF009900CC330000FF333300FF336600FF339900FF33CC00FF33
          FF00FF660000FF663300CC666600FF669900FF66CC00CC66FF00FF990000FF99
          3300FF996600FF999900FF99CC00FF99FF00FFCC0000FFCC3300FFCC6600FFCC
          9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF9900FFFFCC006666FF0066FF
          660066FFFF00FF666600FF66FF00FFFF66002100A5005F5F5F00777777008686
          860096969600CBCBCB00B2B2B200D7D7D700DDDDDD00E3E3E300EAEAEA00F1F1
          F100F8F8F800F0FBFF00A4A0A000808080000000FF0000FF000000FFFF00FF00
          0000FF00FF00FFFF0000FFFFFF007E01FE52DF7BFF7FFF7FFF7FFF7FFF7FFF7F
          FF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FDF7BFD523E010000FE525A772659
          E35CE35CE35CE35CE35CE360E360E36003610361036103610361036103616765
          7A7BFD520000DF7B064DC354E35CE35CE35CE35CE35CE3600361036103610461
          0465046504650465046103616765DF7B0000FF7FA244C354E35CE35CE35CE360
          E360036103610361046504652465246524652465246504610361FF7F0000FF7F
          A244C354E35CE35CE35CE35CE360036103610361046524652465246524652465
          246504650361FF7F0000FF7FA244C354E35CE35C6865706EE360036103610461
          0465246524659172A9692465246504650361FF7F0000FF7FA244C354E35CE35C
          706E706E706E036103610461046524659172917291722465246504650361FF7F
          0000FF7FA240C354E35CE35CE35C706E706E706E036103610465717271729172
          24652465246504650361FF7F0000FF7FA240C350E35CE35CE35CE35C706E706E
          716E0361717271724F72246524652465046503610361FF7F0000FF7F823CC250
          E358E35CE35CE35CE35C706E706E716E71727172046504652465046504650361
          0361FF7F0000FF7F8238C24CE358E35CE35CE35CE35CE35C706E706E716E0361
          036104610461036103610361E360FF7F0000FF7F8238C24CC358E358E35CE35C
          E35C506E706E706E706E716E036103610361036103610361E360FF7F0000FF7F
          8134A248C354C358C358E35C506E506E506EE35C706E706E706E036103610361
          0361E360E360FF7F0000FF7F8130A248C350C354C358506E506E506EE35CE35C
          E35C706E706E706EE360E360E360E360E35CFF7F0000FF7F6130A244C250C254
          506A506A506EC35CE35CE35CE35CE35C706E706E706EE35CE360E35CE35CFF7F
          0000FF7F612CA240C24CC250475D506AC358C358E35CE35CE35CE35CE35C706E
          6865E35CE35CE35CE35CFF7F0000FF7F612CA240A248C24CC250C254C354C358
          E358E35CE35CE35CE35CE35CE35CE35CE35CE35CE35CFF7F0000FF7F612C823C
          A244A248A24CC250C250C354C354C358E358E358E35CE35CE35CE35CE35CE35C
          E35CFF7F0000DF7BC5308134823CA23CA240A244A244A248C24CC24CC250C350
          C350C354C354C354C354C3542659DF7B0000FD525A6FC530612C612C612C8130
          8134823482388238823CA240A240A244A244A244A244064D7A77FD5200005C01
          FD52DF7BFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7FFF7F
          FF7FDF7BFD52F9000000}
        ImageDisabled.Data = {
          07544269746D6170DE070000424DDE0700000000000042040000280000001500
          00001500000001001000030000009C0300000000000000000000000100000000
          0000007C0000E00300001F000000000000000000800000800000008080008000
          00008000800080800000C0C0C000C0DCC000F0CAA60033000000000033003300
          330033330000161616001C1C1C002222220029292900555555004D4D4D004242
          420039393900807CFF005050FF009300D600FFECCC00C6D6EF00D6E7E70090A9
          AD0000FF330000006600000099000000CC000033000000333300003366000033
          99000033CC000033FF00006600000066330000666600006699000066CC000066
          FF00009900000099330000996600009999000099CC000099FF0000CC000000CC
          330000CC660000CC990000CCCC0000CCFF0000FF660000FF990000FFCC0033FF
          0000FF00330033006600330099003300CC003300FF00FF330000333333003333
          6600333399003333CC003333FF00336600003366330033666600336699003366
          CC003366FF00339900003399330033996600339999003399CC003399FF0033CC
          000033CC330033CC660033CC990033CCCC0033CCFF0033FF330033FF660033FF
          990033FFCC0033FFFF00660000006600330066006600660099006600CC006600
          FF00663300006633330066336600663399006633CC006633FF00666600006666
          330066666600666699006666CC00669900006699330066996600669999006699
          CC006699FF0066CC000066CC330066CC990066CCCC0066CCFF0066FF000066FF
          330066FF990066FFCC00CC00FF00FF00CC009999000099339900990099009900
          CC009900000099333300990066009933CC009900FF0099660000996633009933
          6600996699009966CC009933FF009999330099996600999999009999CC009999
          FF0099CC000099CC330066CC660099CC990099CCCC0099CCFF0099FF000099FF
          330099CC660099FF990099FFCC0099FFFF00CC00000099003300CC006600CC00
          9900CC00CC0099330000CC333300CC336600CC339900CC33CC00CC33FF00CC66
          0000CC66330099666600CC669900CC66CC009966FF00CC990000CC993300CC99
          6600CC999900CC99CC00CC99FF00CCCC0000CCCC3300CCCC6600CCCC9900CCCC
          CC00CCCCFF00CCFF0000CCFF330099FF6600CCFF9900CCFFCC00CCFFFF00CC00
          3300FF006600FF009900CC330000FF333300FF336600FF339900FF33CC00FF33
          FF00FF660000FF663300CC666600FF669900FF66CC00CC66FF00FF990000FF99
          3300FF996600FF999900FF99CC00FF99FF00FFCC0000FFCC3300FFCC6600FFCC
          9900FFCCCC00FFCCFF00FFFF3300CCFF6600FFFF9900FFFFCC006666FF0066FF
          660066FFFF00FF666600FF66FF00FFFF66002100A5005F5F5F00777777008686
          860096969600CBCBCB00B2B2B200D7D7D700DDDDDD00E3E3E300EAEAEA00F1F1
          F100F8F8F800F0FBFF00A4A0A000808080000000FF0000FF000000FFFF00FF00
          0000FF00FF00FFFF0000FFFFFF007F011C325C3A5C3E5C3E5C3E5C3E5C3E5C3E
          5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3A1C323E0100003C323B3AD735
          B635B635B635B635B635B635B635B635B635B635B635B635B635B635B635D635
          3B3A1C3200005C3AD739D639D639D639D739D739D739D739D639D639D639D639
          D639D639D639B639B639B635D6355C3A00005C3ED639D639D739D739D739D739
          D739D739D739D739D739D639D639D639D639D639D639B639B6355C3E00005C3E
          D639D739D739D739F739F739F739F739F739D739D739D739D639D639D639D639
          D639B639B6355C3E00005C3ED639D739D739F7399A52794AF739F739F739F739
          F739D739D739584A9952D639D639D639B6355C3E00005C3ED639D739F739F739
          794A794A794AF739F739F739F739F739594A594A584AD639D639D639B6355C3E
          00005C3ED739F739F739F839F839794A794A794AF739F739F739794A594A594A
          D639D639D639D639B6355C3E00005C3ED739F739F839F839F839F839794A794A
          794AF739794A794A794ED639D639D639D639D639B6355C3E00005C3ED739F839
          F839F839F839F839F839794A794A794A794A594AD739D639D639D639D639D639
          B6355C3E00005C3ED739F839F839F839F839F839F839F739794A794A594AD739
          D739D639D639D639D739D639D6355C3E00005C3ED739F839F839F839F839F839
          F839794A794A794A594A594AD739D739D639D739D739D739D6355C3E00005C3E
          F739F839F839F839F839F839794A794A794AD739594A594A594AD739D739D739
          D739D739D6355C3E00005C3EF739F839F839F839F8397A4A7A4A794AF739F739
          D739594A594A594AD739D739D739D739D6355C3E00005C3EF839183A183AF839
          7A4A7A4A7A4AF839F739F739D739D739594A594A594AD739D739D739D6355C3E
          00005C3EF839193A193A183A9A527A4AF839F839F839F739F739D739D739594A
          9A52D739D739D739D6355C3E00005C3EF839193A193A193A183AF839F839F839
          F839F839F839F839F839F739F739D739D739D739D6355C3E00005C3EF839193A
          193E193A193A183A183AF839F839F839F839F839F839F839F839F739D739D739
          B6355C3E00005C3AF839193A193A193A193A183AF839F839F839F839F839F839
          F839F839F739F739D739D639D7355C3A00001B325B3EF839F839F839F839F739
          F739F739F739F739F739D739D739D739D739D739D639D7393B3A1B3200005C01
          1B325C3A5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E5C3E
          5C3E5C3A1B32D9000000}
        OnClick = ImbCloseFilterClick
        Transparent = False
        View = DmIm_Close
        Enabled = True
        ShowCaption = False
        Caption = 'Close'
        FontNormal.Charset = DEFAULT_CHARSET
        FontNormal.Color = clWindowText
        FontNormal.Height = -11
        FontNormal.Name = 'Tahoma'
        FontNormal.Style = []
        FontEnter.Charset = DEFAULT_CHARSET
        FontEnter.Color = clWindowText
        FontEnter.Height = -11
        FontEnter.Name = 'Tahoma'
        FontEnter.Style = []
        PixelsBetweenPictureAndText = 10
        FadeDelay = 10
        FadeSteps = 20
        Defaultcolor = clBtnFace
        Animations = [ImSt_Normal, ImSt_Enter, ImSt_Click, ImSt_Disabled]
        AnimatedShow = False
        Autosetimage = True
        Usecoolfont = False
        Coolcolor = clBlack
        CoolColorSize = 3
        VirtualDraw = False
      end
      object CbFilterMatchCase: TCheckBox
        Left = 230
        Top = 8
        Width = 140
        Height = 17
        Caption = 'Match case'
        TabOrder = 2
        OnClick = WedFilterChange
      end
    end
    object PnInfo: TPanel
      Left = 0
      Top = 0
      Width = 870
      Height = 33
      Align = alTop
      BevelEdges = [beBottom]
      Color = clYellow
      ParentBackground = False
      TabOrder = 1
      Visible = False
      OnResize = PnInfoResize
      DesignSize = (
        870
        33)
      object SbCloseHelp: TSpeedButton
        Left = 832
        Top = 5
        Width = 23
        Height = 22
        Anchors = [akTop, akRight]
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3DEDFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF1E1CE2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          4744EF4E4BF23F3DEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2321E4312F
          E81E1CE2FFFFFFFFFFFFFFFFFF4F4CF45754F66361F85754F63F3DEDFFFFFFFF
          FFFFFFFFFFFFFFFF2B29E64240EE4B49F6312FE81E1CE2FFFFFFFFFFFF5754F6
          5B59F66361F8706DFD5754F64240EEFFFFFFFFFFFF3533EB4744EF6666FF4B49
          F62F2CE72321E4FFFFFFFFFFFFFFFFFF5754F65B59F66361F87371FF5B59F642
          40EE3C39EC4F4CF46666FF4F4CF43533EB2B29E6FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF5B59F65B59F66361F87371FF7371FF706DFD6D6BFF5654F73F3DED312F
          E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5B59F65B59F67875FF58
          55FF5855FF7371FF4744EF3C39ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF5B59F67D7BFF5D5AFF5855FF7371FF4744EFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8706DFD807DFF7D
          7BFF7D7BFF7875FF5B59F64744EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF6D6BFA7875FF8581FF7371FF6361F8605DF86D6BFA7875FF605DF84744
          EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7371FF7D7BFF8986FF7D7BFF6D6BFA63
          61F8605DF8605DF86D6BFA7D7BFF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF
          7875FF807DFF807DFF7371FF6D6BFAFFFFFFFFFFFF605DF8605DF86D6BFA7D7B
          FF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF7875FF7875FF706DFDFFFFFFFF
          FFFFFFFFFFFFFFFF605DF86361F86D6BFA4F4CF44E4BF2FFFFFFFFFFFFFFFFFF
          FFFFFF7875FF7875FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF605DF85B59
          F65754F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8FFFFFFFFFFFFFFFFFF}
        OnClick = SbCloseHelpClick
        ExplicitLeft = 696
      end
      object WlLearnMoreLink: TWebLink
        Left = 240
        Top = 8
        Width = 189
        Height = 16
        Cursor = crHandPoint
        Text = 'Learn more about creating persons'
        OnClick = WlLearnMoreLinkClick
        ImageIndex = 0
        UseEnterColor = False
        EnterColor = clBlack
        EnterBould = False
        TopIconIncrement = 0
        Icon.Data = {
          0000010001001010000001002000680400001600000028000000100000002000
          0000010020000000000040040000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000D3690044D3690044D369
          0044D36900440000000000000000000000000000000000000000000000000000
          0000000000000000000000000000D3690044D76B00E6D97F20FFD98E37FFD88E
          37FFD87F20FFD76B00E6D3690044000000000000000000000000000000000000
          00000000000000000000D66A00CEE07C14FFE9B463FFF6C46DFFF6C56EFFF6C5
          6EFFF2C877FFE7B463FFDD801DFFD66A00CE0000000000000000000000000000
          000000000000D66A00CEE48924FFF2BA63FFF3BD66FFFCEFD9FFFFFFFFFFFCEF
          D9FFF3BE67FFF3BD66FFEEBF6DFFE48924FFD66A00CE00000000000000000000
          0000D3690044E07D16FFEFB15AFFF0B45DFFF0B65FFFFBEDD7FFFFFFFFFFFBED
          D7FFF1B861FFF0B65FFFF0B45DFFEFB15AFFDF7910FFD3690044000000000000
          0000D76B00E6E9A046FFECAB53FFEDAD56FFEEAF58FFF4CE98FFF7D8ACFFF5CF
          98FFEEB15AFFEEAF58FFEDAD56FFECAB53FFE7993CFFD76B00E600000000D369
          0044DE760DFFE8A048FFE9A34CFFEAA64EFFEBA851FFF9E4C9FFFFFFFFFFFBEF
          DFFFECAA52FFEBA851FFEAA64FFFEAA44CFFE8A049FFDD7309FFD3690044D369
          0044DF7C17FFE69941FFE79C44FFE89F47FFE8A149FFF0BF83FFFFFFFFFFFFFF
          FFFFF7DCBBFFE9A754FFE89F47FFE79C44FFE69941FFDE7710FFD3690044D369
          0044DF7E1BFFE39139FFE4943CFFE5963EFFE59840FFECB371FFECB371FFFDF9
          F3FFFFFFFFFFF8E5CFFFE5973EFFE4943CFFE39139FFDD760EFFD3690044D369
          0044DD730BFFDF8930FFE18C35FFEFC08FFFFFFFFFFFFFFFFFFFE9A863FFF3D0
          ABFFFFFFFFFFFFFFFFFFE39441FFE39340FFE08B35FFDD730CFFD36900440000
          0000D76C04E6DD822AFFE18F3EFFE4994EFFFDF8F3FFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFF7DFC7FFE4994EFFE3984EFFDF8835FFD76B00E6000000000000
          0000D3690044DC7615FFE2954DFFE29751FFE7A769FFF3D3B5FFF8E6D5FFF8E7
          D6FFF0C9A3FFE59F5CFFE49E5DFFE49E5DFFDC7717FFD3690070000000000000
          000000000000D66B03CEDE8330FFE5A063FFE5A264FFE6A366FFE6A468FFE6A5
          6AFFE6A66BFFE6A76DFFE7A86EFFE19043FFD66A00CE00000000000000000000
          00000000000000000000D66B03CEDF832BFFE6A76DFFE9AF7BFFE9B07CFFE9B1
          7EFFEAB280FFE7AB74FFDF852FFFD66A00CE0000000000000000000000000000
          0000000000000000000000000000D3690044D66D05E6DD791AFFDF822AFFDF82
          2AFFDD7A1BFFD66D05E6D3690044000000000000000000000000000000000000
          00000000000000000000000000000000000000000000D3690044D3690044D369
          0044D3690044000000000000000000000000000000000000000000000000FC3F
          0000F00F0000E0070000C0030000800100008001000000000000000000000000
          0000000000008001000080010000C0030000E0070000F00F0000FC3F0000}
        UseSpecIconSize = True
        HightliteImage = False
        StretchImage = True
        CanClick = True
      end
    end
    object PnRight: TPanel
      Left = 512
      Top = 33
      Width = 358
      Height = 611
      Align = alClient
      Constraints.MinWidth = 100
      TabOrder = 2
      Visible = False
      ExplicitHeight = 603
      DesignSize = (
        358
        611)
      object SbCloseRightPanel: TSpeedButton
        Left = 325
        Top = 1
        Width = 20
        Height = 20
        Anchors = [akTop, akRight]
        Flat = True
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          1800000000000003000000000000000000000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3DEDFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF1E1CE2FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          4744EF4E4BF23F3DEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2321E4312F
          E81E1CE2FFFFFFFFFFFFFFFFFF4F4CF45754F66361F85754F63F3DEDFFFFFFFF
          FFFFFFFFFFFFFFFF2B29E64240EE4B49F6312FE81E1CE2FFFFFFFFFFFF5754F6
          5B59F66361F8706DFD5754F64240EEFFFFFFFFFFFF3533EB4744EF6666FF4B49
          F62F2CE72321E4FFFFFFFFFFFFFFFFFF5754F65B59F66361F87371FF5B59F642
          40EE3C39EC4F4CF46666FF4F4CF43533EB2B29E6FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF5B59F65B59F66361F87371FF7371FF706DFD6D6BFF5654F73F3DED312F
          E8FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5B59F65B59F67875FF58
          55FF5855FF7371FF4744EF3C39ECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF5B59F67D7BFF5D5AFF5855FF7371FF4744EFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8706DFD807DFF7D
          7BFF7D7BFF7875FF5B59F64744EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF6D6BFA7875FF8581FF7371FF6361F8605DF86D6BFA7875FF605DF84744
          EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7371FF7D7BFF8986FF7D7BFF6D6BFA63
          61F8605DF8605DF86D6BFA7D7BFF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF
          7875FF807DFF807DFF7371FF6D6BFAFFFFFFFFFFFF605DF8605DF86D6BFA7D7B
          FF605DF84744EFFFFFFFFFFFFFFFFFFF7875FF7875FF7875FF706DFDFFFFFFFF
          FFFFFFFFFFFFFFFF605DF86361F86D6BFA4F4CF44E4BF2FFFFFFFFFFFFFFFFFF
          FFFFFF7875FF7875FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF605DF85B59
          F65754F6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFF6361F8FFFFFFFFFFFFFFFFFF}
        OnClick = SbCloseRightPanelClick
      end
      object PcRightPreview: TPageControl
        Left = 1
        Top = 1
        Width = 356
        Height = 609
        ActivePage = TsMediaPreview
        Align = alClient
        TabOrder = 0
        OnChange = PcRightPreviewChange
        ExplicitHeight = 601
        object TsMediaPreview: TTabSheet
          Caption = 'TsMediaPreview'
          ImageIndex = 1
          OnResize = TsMediaPreviewResize
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 573
          object PnRightPreview: TPanel
            Left = 0
            Top = 0
            Width = 348
            Height = 581
            Align = alClient
            BevelOuter = bvNone
            DoubleBuffered = True
            FullRepaint = False
            ParentBackground = False
            ParentDoubleBuffered = False
            TabOrder = 0
            ExplicitHeight = 573
            DesignSize = (
              348
              581)
            object ToolBarPreview: TToolBar
              Left = 75
              Top = 547
              Width = 263
              Height = 22
              Align = alNone
              Anchors = [akLeft, akBottom]
              AutoSize = True
              ButtonWidth = 33
              DoubleBuffered = True
              GradientEndColor = 11319229
              Images = ImlPreview
              ParentDoubleBuffered = False
              TabOrder = 0
              Transparent = False
              Wrapable = False
              ExplicitTop = 539
              object TbPreviewPrevious: TToolButton
                Left = 0
                Top = 0
                Caption = 'TbPreviewPrevious'
                ImageIndex = 3
                OnClick = TbPreviewPreviousClick
              end
              object TbPreviewNext: TToolButton
                Left = 33
                Top = 0
                ImageIndex = 3
                OnClick = TbPreviewNextClick
              end
              object TbPreviewNavigationSeparator: TToolButton
                Left = 66
                Top = 0
                Width = 8
                Caption = 'TbPreviewNavigationSeparator'
                ImageIndex = 3
                Style = tbsSeparator
              end
              object TbPreviewRotateCCW: TToolButton
                Left = 74
                Top = 0
                ImageIndex = 0
                OnClick = TbPreviewRotateCCWClick
              end
              object TbPreviewRotateCW: TToolButton
                Left = 107
                Top = 0
                Caption = 'TbPreviewRotateCW'
                ImageIndex = 1
                OnClick = TbPreviewRotateCWClick
              end
              object TbPreviewRotateSeparator: TToolButton
                Left = 140
                Top = 0
                Width = 8
                ImageIndex = 2
                Style = tbsSeparator
              end
              object TbPreviewRating: TToolButton
                Left = 148
                Top = 0
                ImageIndex = 3
                OnClick = TbPreviewRatingClick
              end
              object TbPreviewRatingSeparator: TToolButton
                Left = 181
                Top = 0
                Width = 8
                ImageIndex = 3
                Style = tbsSeparator
              end
              object TbPreviewInfo: TToolButton
                Left = 189
                Top = 0
                ImageIndex = 3
                Style = tbsCheck
                OnClick = TbPreviewInfoClick
              end
              object TbPreviewInfoSeparator: TToolButton
                Left = 222
                Top = 0
                Width = 8
                Caption = 'TbPreviewInfoSeparator'
                ImageIndex = 3
                Style = tbsSeparator
              end
              object TbPreviewOpen: TToolButton
                Left = 230
                Top = 0
                ImageIndex = 2
                OnClick = SlideShowLinkClick
              end
            end
            object WlFaceCount: TWebLink
              Left = 24
              Top = 552
              Width = 41
              Height = 13
              Cursor = crHandPoint
              Anchors = [akLeft, akBottom]
              Text = 'Faces: 2'
              Visible = False
              ImageIndex = -1
              IconWidth = 0
              IconHeight = 0
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = True
              CanClick = True
              ExplicitTop = 544
            end
            object WllPersonsPreview: TWebLinkList
              Left = 0
              Top = 494
              Width = 340
              Height = 33
              HorzScrollBar.Visible = False
              BevelEdges = []
              BevelInner = bvNone
              BevelOuter = bvNone
              BorderStyle = bsNone
              ParentBackground = True
              TabOrder = 2
              VerticalIncrement = 5
              HorizontalIncrement = 5
              LineHeight = 0
              PaddingTop = 2
              PaddingLeft = 2
              HorCenter = True
            end
            object LsDetectingFaces: TLoadingSign
              Left = 3
              Top = 550
              Width = 18
              Height = 18
              Visible = False
              Active = True
              FillPercent = 60
              Color = clBtnFace
              ParentColor = False
              Anchors = [akLeft, akBottom]
              SignColor = clBlack
              MaxTransparencity = 255
              ExplicitTop = 542
            end
          end
        end
        object TsGeoLocation: TTabSheet
          Caption = 'TsGeoLocation'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PnGeoSearch: TPanel
            Left = 0
            Top = 546
            Width = 348
            Height = 35
            Align = alBottom
            TabOrder = 0
            DesignSize = (
              348
              35)
            object SbDoSearchLocation: TSpeedButton
              Left = 329
              Top = 5
              Width = 23
              Height = 22
              Anchors = [akTop, akRight]
              Flat = True
              OnClick = SbDoSearchLocationClick
              ExplicitLeft = 25
            end
            object WedGeoSearch: TWatermarkedEdit
              Left = 5
              Top = 6
              Width = 320
              Height = 21
              Anchors = [akLeft, akTop, akRight]
              TabOrder = 0
              OnKeyDown = WedGeoSearchKeyDown
              WatermarkText = 'Search location'
            end
          end
          object PnGeoTop: TPanel
            Left = 0
            Top = 0
            Width = 348
            Height = 33
            Align = alTop
            BevelEdges = [beBottom]
            ParentBackground = False
            TabOrder = 1
            OnResize = PnInfoResize
            object WlSaveLocation: TWebLink
              Left = 5
              Top = 8
              Width = 97
              Height = 16
              Cursor = crHandPoint
              Enabled = False
              Text = 'WlSaveLocation'
              OnClick = WlSaveLocationClick
              ImageIndex = 0
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = False
              CanClick = True
            end
            object WlPanoramio: TWebLink
              Left = 218
              Top = 8
              Width = 83
              Height = 16
              Cursor = crHandPoint
              Text = 'WlPanoramio'
              OnClick = WlPanoramioClick
              ImageIndex = 0
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = False
              CanClick = True
            end
            object WlDeleteLocation: TWebLink
              Left = 108
              Top = 8
              Width = 104
              Height = 16
              Cursor = crHandPoint
              Enabled = False
              Text = 'WlDeleteLocation'
              OnClick = WlDeleteLocationClick
              ImageIndex = 0
              UseEnterColor = False
              EnterColor = clBlack
              EnterBould = False
              TopIconIncrement = 0
              UseSpecIconSize = True
              HightliteImage = True
              StretchImage = False
              CanClick = True
            end
          end
        end
      end
    end
    object PnListView: TPanel
      Left = 0
      Top = 33
      Width = 507
      Height = 611
      Align = alLeft
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 3
      ExplicitHeight = 603
      object StatusBarMain: TStatusBar
        Left = 0
        Top = 591
        Width = 507
        Height = 20
        Panels = <
          item
            Width = 200
          end
          item
            Width = 500
          end>
        Visible = False
        ExplicitTop = 583
      end
    end
  end
  object PnSelectDatePopup: TPanel
    Left = 751
    Top = 365
    Width = 174
    Height = 204
    TabOrder = 5
    Visible = False
    object McDateSelectPopup: TMonthCalendar
      Left = 6
      Top = 8
      Width = 162
      Height = 163
      Date = 41177.596083171290000000
      TabOrder = 0
      OnKeyDown = McDateSelectPopupKeyDown
    end
    object BtnSelectDatePopup: TButton
      Left = 94
      Top = 174
      Width = 75
      Height = 25
      Caption = 'Select'
      TabOrder = 1
      OnClick = BtnSelectDatePopupClick
    end
    object BtnSelectDatePopupReset: TButton
      Left = 6
      Top = 174
      Width = 75
      Height = 25
      Caption = 'Reset'
      TabOrder = 2
      OnClick = BtnSelectDatePopupClick
    end
  end
  object RtPopupRating: TRating
    Left = 751
    Top = 343
    Width = 96
    Height = 16
    Cursor = crHandPoint
    Visible = False
    Rating = 0
    RatingRange = 0
    OnRating = RtPopupRatingRating
    Islayered = False
    Layered = 100
    ImageCanRegenerate = True
    CanSelectRange = False
  end
  object PnBottomToolBar: TPanel
    Left = 0
    Top = 725
    Width = 1016
    Height = 19
    Align = alBottom
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 7
    ExplicitTop = 717
    object ToolBarBottom: TToolBar
      Left = 0
      Top = 0
      Width = 1016
      Height = 19
      Align = alBottom
      AutoSize = True
      ButtonHeight = 19
      ButtonWidth = 100
      EdgeInner = esNone
      GradientEndColor = 11319229
      List = True
      ParentShowHint = False
      ShowCaptions = True
      ShowHint = True
      TabOrder = 0
      Transparent = True
      Wrapable = False
      OnResize = CoolBarBottomResize
      object TbbCreateObject: TToolButton
        Left = 0
        Top = 0
        AutoSize = True
        Caption = 'TbbCreateObject'
        ImageIndex = 9
        Visible = False
        OnClick = TbbCreateObjectClick
      end
      object TbbPlay: TToolButton
        Left = 99
        Top = 0
        AutoSize = True
        Caption = 'TbbPlay'
        ImageIndex = 0
        OnClick = SlideShowLinkClick
      end
      object TbbEncrypt: TToolButton
        Left = 153
        Top = 0
        AutoSize = True
        Caption = 'TbbEncrypt'
        ImageIndex = 1
        OnClick = EncryptLinkClick
      end
      object TbbShare: TToolButton
        Left = 224
        Top = 0
        AutoSize = True
        Caption = 'TbbShare'
        DropdownMenu = PmShareAdditionalTasks
        ImageIndex = 9
        Style = tbsTextButton
        OnClick = WlShareClick
      end
      object TbbGeo: TToolButton
        Left = 286
        Top = 0
        AutoSize = True
        Caption = 'TbbGeo'
        ImageIndex = 6
        OnClick = WlGeoLocationClick
      end
      object TbbResize: TToolButton
        Left = 339
        Top = 0
        AutoSize = True
        Caption = 'TbbResize'
        ImageIndex = 2
        OnClick = Resize1Click
      end
      object TbbConvert: TToolButton
        Left = 404
        Top = 0
        AutoSize = True
        Caption = 'TbbConvert'
        ImageIndex = 10
        OnClick = Convert1Click
      end
      object TbbCrop: TToolButton
        Left = 477
        Top = 0
        AutoSize = True
        Caption = 'TbbCrop'
        ImageIndex = 3
        OnClick = WlCropClick
      end
      object TbbEditor: TToolButton
        Left = 534
        Top = 0
        AutoSize = True
        Caption = 'TbbEditor'
        ImageIndex = 5
        OnClick = ImageEditorLinkClick
      end
      object TbbPrint: TToolButton
        Left = 596
        Top = 0
        AutoSize = True
        Caption = 'TbbPrint'
        ImageIndex = 4
        OnClick = PrintLinkClick
      end
      object TbBottomFileActionsSeparator: TToolButton
        Left = 652
        Top = 0
        Width = 8
        ImageIndex = 9
        Style = tbsSeparator
      end
      object TbbOpenDirectory: TToolButton
        Left = 660
        Top = 0
        AutoSize = True
        Caption = 'TbbOpenDirectory'
        DropdownMenu = PmLocations
        ImageIndex = 9
        Style = tbsDropDown
        OnClick = TbbOpenDirectoryClick
      end
      object TbbRename: TToolButton
        Left = 779
        Top = 0
        AutoSize = True
        Caption = 'TbbRename'
        ImageIndex = 7
        OnClick = Rename1Click
      end
      object TbbProperties: TToolButton
        Left = 852
        Top = 0
        AutoSize = True
        Caption = 'TbbProperties'
        ImageIndex = 8
        OnClick = PropertiesLinkClick
      end
      object TbbClear: TToolButton
        Left = 935
        Top = 0
        AutoSize = True
        Caption = 'TbbClear'
        ImageIndex = 9
        Visible = False
        OnClick = TbbClearClick
      end
    end
  end
  object SizeImageList: TImageList
    Height = 102
    Width = 102
    Left = 200
    Top = 240
  end
  object PmItemPopup: TPopupActionBar
    AutoHotkeys = maManual
    OnPopup = PmItemPopupPopup
    Left = 360
    Top = 96
    object Open1: TMenuItem
      Caption = 'Open'
      OnClick = Open1Click
    end
    object SlideShow1: TMenuItem
      Caption = 'Show'
      OnClick = SlideShow1Click
    end
    object NewWindow1: TMenuItem
      Caption = 'New Window'
      Visible = False
      OnClick = NewWindow1Click
    end
    object Shell1: TMenuItem
      Caption = 'Shell'
      OnClick = Shell1Click
    end
    object DBitem1: TMenuItem
      Caption = 'DBitem'
      OnClick = DBitem1Click
      object TMenuItem
      end
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      ShortCut = 16451
      OnClick = CopyClick
    end
    object Cut2: TMenuItem
      Caption = 'Cut'
      ShortCut = 16472
      OnClick = CutClick
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      ShortCut = 46
      OnClick = Delete1Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object Rename1: TMenuItem
      Caption = 'Rename'
      ShortCut = 113
      OnClick = Rename1Click
    end
    object New1: TMenuItem
      Caption = 'New'
      Visible = False
      object Directory1: TMenuItem
        Caption = 'Directory'
      end
      object TextFile1: TMenuItem
        Caption = 'Text File'
      end
    end
    object Refresh1: TMenuItem
      Caption = 'Refresh'
      ShortCut = 116
      OnClick = Refresh1Click
    end
    object RefreshID1: TMenuItem
      Caption = 'Refresh ID'
      OnClick = RefreshID1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ImageEditor2: TMenuItem
      Caption = 'Image Editor'
      OnClick = ImageEditor2Click
    end
    object Print1: TMenuItem
      Caption = 'Print'
      ShortCut = 16464
      OnClick = PrintLinkClick
    end
    object Resize1: TMenuItem
      Caption = 'Resize'
      ShortCut = 16466
      OnClick = Resize1Click
    end
    object Rotate1: TMenuItem
      Caption = 'Rotate Image'
      object AsEXIF1: TMenuItem
        Caption = 'By EXIF'
        OnClick = AsEXIF1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object RotateCCW1: TMenuItem
        Caption = 'Rotate CCW'
        OnClick = RotateCCW1Click
      end
      object RotateCW1: TMenuItem
        Caption = 'Rotate CW'
        OnClick = RotateCW1Click
      end
      object Rotateon1801: TMenuItem
        Caption = 'Rotate on 180*'
        OnClick = Rotateon1801Click
      end
    end
    object SetasDesktopWallpaper1: TMenuItem
      Caption = 'Set as Desktop Wallpaper'
      object Stretch1: TMenuItem
        Caption = 'Stretch'
        OnClick = Stretch1Click
      end
      object Center1: TMenuItem
        Caption = 'Center'
        OnClick = Center1Click
      end
      object Tile1: TMenuItem
        Caption = 'Tile'
        OnClick = Tile1Click
      end
    end
    object Othertasks1: TMenuItem
      Caption = 'Other tasks'
      object Convert1: TMenuItem
        Caption = 'Convert'
        OnClick = Convert1Click
      end
      object ExportImages1: TMenuItem
        Caption = 'Export Images'
        OnClick = ExportImages1Click
      end
      object Copywithfolder1: TMenuItem
        Caption = 'Copy with folder'
        OnClick = Copywithfolder1Click
      end
    end
    object MakeFolderViewer2: TMenuItem
      Caption = 'Make FolderViewer'
      OnClick = MakeFolderViewer2Click
    end
    object StenoGraphia1: TMenuItem
      Caption = 'StenoGraphia'
      object AddHiddenInfo1: TMenuItem
        Caption = 'Add Hidden Info'
        OnClick = AddHiddenInfo1Click
      end
      object ExtractHiddenInfo1: TMenuItem
        Caption = 'Extract Hidden Info'
        OnClick = ExtractHiddenInfo1Click
      end
    end
    object MiShare: TMenuItem
      Caption = 'Share'
      ShortCut = 16467
      OnClick = WlShareClick
    end
    object MiDisplayOnMap: TMenuItem
      Caption = 'Display on map'
      ShortCut = 16461
      OnClick = MiDisplayOnMapClick
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object MiShelf: TMenuItem
      Caption = 'Add to shelf'
      ShortCut = 16465
      OnClick = MiShelfClick
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object EnterPassword1: TMenuItem
      Caption = 'Enter Password'
      OnClick = EnterPassword1Click
    end
    object CryptFile1: TMenuItem
      Caption = 'Crypt File'
      ShortCut = 24645
      OnClick = CryptFile1Click
    end
    object ResetPassword1: TMenuItem
      Caption = 'Reset Password'
      ShortCut = 24644
      OnClick = ResetPassword1Click
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object AddFile1: TMenuItem
      Caption = 'Add File'
      OnClick = AddFile1Click
    end
    object MiImportImages: TMenuItem
      Caption = 'Import Images'
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object MapCD1: TMenuItem
      Caption = 'Map CD'
      Visible = False
      OnClick = MapCD1Click
    end
    object Properties1: TMenuItem
      Caption = 'Properties'
      OnClick = Properties1Click
    end
  end
  object PmListPopup: TPopupActionBar
    OnPopup = PmListPopupPopup
    Left = 360
    Top = 480
    object OpenInNewWindow1: TMenuItem
      Caption = 'Open In New Window'
      OnClick = OpenInNewWindow1Click
    end
    object N6: TMenuItem
      Caption = '-'
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      ShortCut = 16470
      OnClick = PasteClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object Addfolder1: TMenuItem
      Caption = 'Add Folder'
      OnClick = Addfolder1Click
    end
    object MakeNew1: TMenuItem
      Caption = 'Make New'
      object Directory2: TMenuItem
        Caption = 'Directory'
        OnClick = MakeNewFolder1Click
      end
      object TextFile2: TMenuItem
        Caption = 'Text File'
        OnClick = TextFile2Click
      end
    end
    object MakeFolderViewer1: TMenuItem
      Caption = 'Make FolderViewer'
      OnClick = MakeFolderViewer1Click
    end
    object ShowUpdater1: TMenuItem
      Caption = 'Show Updater'
      OnClick = ShowUpdater1Click
    end
    object Refresh2: TMenuItem
      Caption = 'Refresh'
      ShortCut = 116
      OnClick = Refresh2Click
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      ShortCut = 16449
      OnClick = SelectAll1Click
    end
    object N19: TMenuItem
      Caption = '-'
    end
    object Sortby1: TMenuItem
      Caption = 'Sort by'
      object Nosorting1: TMenuItem
        Tag = -1
        Caption = 'No Sorting'
        OnClick = FileName1Click
      end
      object FileName1: TMenuItem
        Caption = 'File Name'
        OnClick = FileName1Click
      end
      object Rating1: TMenuItem
        Tag = 1
        Caption = 'Rating'
        OnClick = FileName1Click
      end
      object Size1: TMenuItem
        Tag = 2
        Caption = 'Size'
        OnClick = FileName1Click
      end
      object Type1: TMenuItem
        Tag = 3
        Caption = 'Type'
        OnClick = FileName1Click
      end
      object Modified1: TMenuItem
        Tag = 4
        Caption = 'Modified'
        OnClick = FileName1Click
      end
      object Number1: TMenuItem
        Tag = 5
        Caption = 'Number'
        OnClick = FileName1Click
      end
    end
    object SetFilter1: TMenuItem
      Caption = 'Set Filter'
      ShortCut = 16454
      OnClick = SetFilter1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Exit2: TMenuItem
      Caption = 'Exit'
      OnClick = Exit2Click
    end
  end
  object HintTimer: TTimer
    Enabled = False
    OnTimer = HintTimerTimer
    Left = 536
    Top = 200
  end
  object SaveWindowPos1: TSaveWindowPos
    SetOnlyPosition = False
    RootKey = HKEY_CURRENT_USER
    Key = 'Software\Positions\Noname'
    Left = 200
    Top = 104
  end
  object AeMain: TApplicationEvents
    OnMessage = AeMainMessage
    Left = 769
    Top = 112
  end
  object PmTreeView: TPopupActionBar
    Left = 361
    Top = 144
    object MiTreeViewOpenInNewWindow: TMenuItem
      Caption = 'Open in new window'
      OnClick = MiTreeViewOpenInNewWindowClick
    end
    object MiTreeViewRefresh: TMenuItem
      Caption = 'Refresh'
      OnClick = MiTreeViewRefreshClick
    end
  end
  object ToolBarNormalImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 200
    Top = 436
  end
  object PopupMenuBack: TPopupActionBar
    Images = ImPathDropDownMenu
    OnPopup = PopupMenuBackPopup
    Left = 360
    Top = 436
  end
  object PopupMenuForward: TPopupActionBar
    Images = ImPathDropDownMenu
    OnPopup = PopupMenuForwardPopup
    Left = 360
    Top = 388
  end
  object DragTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = DragTimerTimer
    Left = 536
    Top = 348
  end
  object ToolBarDisabledImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 201
    Top = 196
  end
  object DropFileTargetMain: TDropFileTarget
    DragTypes = [dtCopy, dtMove]
    OnEnter = DropFileTargetMainEnter
    OnLeave = DropFileTargetMainLeave
    OnDrop = DropFileTargetMainDrop
    MultiTarget = True
    AutoRegister = False
    OptimizedMove = True
    Left = 656
    Top = 200
  end
  object DropFileSourceMain: TDropFileSource
    DragTypes = [dtCopy, dtMove, dtLink]
    Images = DragImageList
    ShowImage = True
    Left = 656
    Top = 152
  end
  object DragImageList: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Height = 102
    Width = 102
    Left = 200
    Top = 288
  end
  object DropFileTargetFake: TDropFileTarget
    DragTypes = []
    OptimizedMove = True
    Left = 656
    Top = 104
  end
  object PmDragMode: TPopupActionBar
    Left = 360
    Top = 192
    object Copy4: TMenuItem
      Caption = 'Copy'
      OnClick = Copy4Click
    end
    object Move1: TMenuItem
      Caption = 'Move'
      OnClick = Copy4Click
    end
    object N15: TMenuItem
      Caption = '-'
    end
    object Cancel1: TMenuItem
      Caption = 'Cancel'
    end
  end
  object SelectTimer: TTimer
    Enabled = False
    Interval = 55
    OnTimer = SelectTimerTimer
    Left = 535
    Top = 300
  end
  object CloseTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = CloseTimerTimer
    Left = 536
    Top = 392
  end
  object RatingPopupMenu: TPopupActionBar
    Left = 361
    Top = 336
    object N00: TMenuItem
      Caption = '0'
      ShortCut = 16432
      OnClick = N05Click
    end
    object N01: TMenuItem
      Tag = 1
      Caption = '1'
      ShortCut = 16433
      OnClick = N05Click
    end
    object N02: TMenuItem
      Tag = 2
      Caption = '2'
      ShortCut = 16434
      OnClick = N05Click
    end
    object N03: TMenuItem
      Tag = 3
      Caption = '3'
      ShortCut = 16435
      OnClick = N05Click
    end
    object N04: TMenuItem
      Tag = 4
      Caption = '4'
      ShortCut = 16436
      OnClick = N05Click
    end
    object N05: TMenuItem
      Tag = 5
      Caption = '5'
      ShortCut = 16437
      OnClick = N05Click
    end
  end
  object PmListViewType: TPopupActionBar
    Left = 360
    Top = 288
    object Thumbnails1: TMenuItem
      Caption = 'Thumbnails'
      Checked = True
      GroupIndex = 1
      RadioItem = True
      OnClick = Thumbnails1Click
    end
    object Tile2: TMenuItem
      Caption = 'Tile'
      GroupIndex = 1
      RadioItem = True
      OnClick = Tile2Click
    end
    object Icons1: TMenuItem
      Caption = 'Icons'
      GroupIndex = 1
      RadioItem = True
      OnClick = Icons1Click
    end
    object List1: TMenuItem
      Caption = 'List'
      GroupIndex = 1
      RadioItem = True
      OnClick = List1Click
    end
    object SmallIcons1: TMenuItem
      Caption = 'Small Icons'
      GroupIndex = 1
      RadioItem = True
      OnClick = SmallIcons1Click
    end
    object Grid1: TMenuItem
      Caption = 'Grid'
      GroupIndex = 1
      RadioItem = True
      Visible = False
      OnClick = Grid1Click
    end
  end
  object BigIconsImageList: TImageList
    ColorDepth = cd32Bit
    Height = 32
    Width = 32
    Left = 200
    Top = 336
  end
  object SmallIconsImageList: TImageList
    ColorDepth = cd32Bit
    Left = 200
    Top = 384
  end
  object BigImagesTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = BigImagesTimerTimer
    Left = 538
    Top = 251
  end
  object PopupMenuZoomDropDown: TPopupActionBar
    OnPopup = PopupMenuZoomDropDownPopup
    Left = 362
    Top = 242
  end
  object SearchImageList: TImageList
    Height = 18
    Width = 18
    Left = 201
    Top = 152
  end
  object PmSearchMode: TPopupActionBar
    AutoPopup = False
    Images = ImSearchMode
    OnPopup = PmSearchModePopup
    Left = 360
    Top = 576
    object Searchfiles1: TMenuItem
      Caption = 'Search files'
      ImageIndex = 0
      OnClick = Searchfiles1Click
    end
    object SearchfileswithEXIF1: TMenuItem
      Caption = 'Search files (with EXIF)'
      ImageIndex = 1
      OnClick = SearchfileswithEXIF1Click
    end
    object Searchincollection1: TMenuItem
      Caption = 'Search in collection'
      ImageIndex = 2
      OnClick = Searchincollection1Click
    end
  end
  object ImSearchMode: TImageList
    ColorDepth = cd32Bit
    Left = 200
    Top = 536
  end
  object ImPathDropDownMenu: TImageList
    ColorDepth = cd32Bit
    Left = 200
    Top = 488
  end
  object PmPathMenu: TPopupActionBar
    Left = 360
    Top = 528
    object MiCopyAddress: TMenuItem
      Caption = 'Copy Address'
      OnClick = MiCopyAddressClick
    end
    object MiEditAddress: TMenuItem
      Caption = 'Edit address'
      OnClick = MiEditAddressClick
    end
  end
  object TmrDelayedStart: TTimer
    Enabled = False
    OnTimer = TmrDelayedStartTimer
    Left = 536
    Top = 488
  end
  object TmrCheckItemVisibility: TTimer
    Enabled = False
    Interval = 250
    OnTimer = TmrCheckItemVisibilityTimer
    Left = 536
    Top = 536
  end
  object ImGroups: TImageList
    ColorDepth = cd32Bit
    Left = 201
    Top = 584
  end
  object ImlBottomToolBar: TImageList
    ColorDepth = cd32Bit
    Left = 288
    Top = 596
  end
  object ImExtendedSearchGroups: TImageList
    ColorDepth = cd32Bit
    Left = 288
    Top = 452
  end
  object PmSelectPerson: TPopupActionBar
    Images = ImFacePopup
    OnPopup = PmSelectPersonPopup
    Left = 448
    Top = 96
    object MiPreviousSelections: TMenuItem
      Caption = 'Previous selections:'
      Enabled = False
    end
    object MiPreviousSelectionsSeparator: TMenuItem
      Caption = '-'
    end
    object MiOtherPersons: TMenuItem
      Caption = 'Other Persons'
      ImageIndex = 1
      OnClick = MiOtherPersonsClick
    end
  end
  object ImFacePopup: TImageList
    ColorDepth = cd32Bit
    BkColor = 15790320
    Left = 288
    Top = 152
  end
  object ImExtendedSearchPersons: TImageList
    ColorDepth = cd32Bit
    Left = 288
    Top = 500
  end
  object PmESSorting: TPopupActionBar
    OnPopup = PmESSortingPopup
    Left = 449
    Top = 144
    object MiESSortByID: TMenuItem
      Caption = 'Sort by ID'
      Checked = True
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByName: TMenuItem
      Tag = 1
      Caption = 'Sort by Name'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByDate: TMenuItem
      Tag = 2
      Caption = 'Sort by Date'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByRating: TMenuItem
      Tag = 3
      Caption = 'Sort by Rating'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByFileSize: TMenuItem
      Tag = 4
      Caption = 'Sort by FileSize'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
    object MiESSortByImageSize: TMenuItem
      Tag = 5
      Caption = 'Sort by Image Size'
      GroupIndex = 2
      RadioItem = True
      OnClick = MiESSortByImageSizeClick
    end
  end
  object PmESPerson: TPopupActionBar
    Left = 449
    Top = 192
    object MiESPersonFindPictures: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiESPersonFindPicturesClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object MiESPersonRemoveFromList: TMenuItem
      Caption = 'Remove from list'
      OnClick = MiESPersonRemoveFromListClick
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object MiESPersonProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiESPersonPropertiesClick
    end
  end
  object PmESGroup: TPopupActionBar
    Left = 449
    Top = 240
    object MiESGroupFindPictures: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiESGroupFindPicturesClick
    end
    object MenuItem2: TMenuItem
      Caption = '-'
    end
    object MiESGroupRemove: TMenuItem
      Caption = 'Remove from list'
      OnClick = MiESGroupRemoveClick
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
    object MiESGroupProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiESGroupPropertiesClick
    end
  end
  object PmESOptions: TPopupActionBar
    OnPopup = PmESOptionsPopup
    Left = 449
    Top = 288
    object MiESShowHidden: TMenuItem
      Caption = 'Show hidden images'
      OnClick = MiESShowHiddenClick
    end
    object MiESShowPrivate: TMenuItem
      Caption = 'Show private images'
      OnClick = MiESShowPrivateClick
    end
  end
  object TmrSearchResultsCount: TTimer
    Enabled = False
    OnTimer = TmrSearchResultsCountTimer
    Left = 537
    Top = 586
  end
  object TmHideStatusBar: TTimer
    Enabled = False
    OnTimer = TmHideStatusBarTimer
    Left = 536
    Top = 152
  end
  object PmInfoGroup: TPopupActionBar
    Left = 449
    Top = 336
    object MiInfoGroupFind: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiInfoGroupFindClick
    end
    object MiInfoGroupSplitter1: TMenuItem
      Caption = '-'
    end
    object MiInfoGroupRemove: TMenuItem
      Caption = 'Remove from list'
      OnClick = MiInfoGroupRemoveClick
    end
    object MiInfoGroupSplitter2: TMenuItem
      Caption = '-'
    end
    object MiInfoGroupProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiInfoGroupPropertiesClick
    end
  end
  object PmPreviewPersonItem: TPopupActionBar
    Left = 449
    Top = 384
    object MiPreviewPersonFind: TMenuItem
      Caption = 'Find pictures'
      OnClick = MiPreviewPersonFindClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object MiPreviewPersonUpdateAvatar: TMenuItem
      Caption = 'Update avatar'
      OnClick = MiPreviewPersonUpdateAvatarClick
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object MiPreviewPersonProperties: TMenuItem
      Caption = 'Properties'
      OnClick = MiPreviewPersonPropertiesClick
    end
  end
  object ImlPreview: TImageList
    ColorDepth = cd32Bit
    Left = 288
    Top = 548
  end
  object TmrReloadTreeView: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TmrReloadTreeViewTimer
    Left = 536
    Top = 440
  end
  object PmShareAdditionalTasks: TPopupActionBar
    OnGetControlClass = PmShareAdditionalTasksGetControlClass
    Left = 448
    Top = 432
    object MiShareImageAndGetUrl: TMenuItem
      Caption = 'MiShareImageAndGetUrl'
      OnClick = MiShareImageAndGetUrlClick
    end
  end
  object PmHelp: TPopupActionBar
    OnPopup = PmHelpPopup
    Left = 448
    Top = 480
    object MiActivation: TMenuItem
      Caption = 'MiActivation'
      OnClick = MiActivationClick
    end
    object MiAbout: TMenuItem
      Caption = 'MiAbout'
      OnClick = MiAboutClick
    end
    object MiHomePage: TMenuItem
      Caption = 'MiHomePage'
      OnClick = MiHomePageClick
    end
    object MiAuthorEmail: TMenuItem
      Caption = 'MiAuthorEmail'
      OnClick = MiAuthorEmailClick
    end
    object MiCheckUpdates: TMenuItem
      Caption = 'MiCheckUpdates'
      OnClick = MiCheckUpdatesClick
    end
  end
  object PmOptions: TPopupActionBar
    OnPopup = PmOptionsPopup
    Left = 448
    Top = 528
    object MiUpdater: TMenuItem
      Caption = 'MiUpdater'
      OnClick = MiUpdaterClick
    end
    object MiCDActionsSeparator: TMenuItem
      Caption = '-'
    end
    object MiCDExport: TMenuItem
      Caption = 'MiCDExport'
      OnClick = MiCDExportClick
    end
    object MiCDMapping: TMenuItem
      Caption = 'MiCDMapping'
      OnClick = MiCDMappingClick
    end
    object MiCollectionsSeparator: TMenuItem
      Caption = '-'
    end
    object MiCollections: TMenuItem
      Caption = 'MiCollections'
      OnClick = EditDatabasesClick
    end
  end
  object ImDBList: TImageList
    ColorDepth = cd32Bit
    Left = 289
    Top = 200
  end
  object PmDBList: TPopupActionBar
    Images = ImDBList
    Left = 448
    Top = 576
  end
  object PmLocations: TPopupActionBar
    Images = ImLocations
    OnPopup = PmLocationsPopup
    OnGetControlClass = PmShareAdditionalTasksGetControlClass
    Left = 656
    Top = 272
  end
  object ImLocations: TImageList
    ColorDepth = cd32Bit
    Left = 656
    Top = 320
  end
  object PmCopy: TPopupActionBar
    OnPopup = PmCopyPopup
    Left = 816
    Top = 224
    object MiCopyTo: TMenuItem
      Caption = 'MiCopyTo'
      OnClick = CopyToLinkClick
    end
  end
  object PmCut: TPopupActionBar
    OnPopup = PmCutPopup
    Left = 816
    Top = 272
    object MiCutTo: TMenuItem
      Caption = 'MiCutTo'
      OnClick = MoveToLinkClick
    end
  end
end
