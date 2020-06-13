object frmImageSee: TfrmImageSee
  Left = 0
  Top = 0
  Caption = 'imgSee v2.0'
  ClientHeight = 694
  ClientWidth = 1249
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pgcSee: TPageControl
    Left = 0
    Top = 0
    Width = 1249
    Height = 694
    ActivePage = tsView
    Align = alClient
    Style = tsButtons
    TabOrder = 0
    object tsBrowse: TTabSheet
      Caption = #22270#20687#27983#35272
      DesignSize = (
        1241
        663)
      object shltrvwImage: TShellTreeView
        Left = 12
        Top = 3
        Width = 373
        Height = 646
        ObjectTypes = [otFolders]
        Root = 'rfMyComputer'
        UseShellImages = True
        Anchors = [akLeft, akTop, akBottom]
        AutoRefresh = False
        Ctl3D = False
        Indent = 19
        ParentColor = False
        ParentCtl3D = False
        RightClickSelect = True
        ShowRoot = False
        TabOrder = 0
        OnChange = shltrvwImageChange
      end
      object scrlbxSee: TScrollBox
        Left = 400
        Top = 3
        Width = 831
        Height = 646
        VertScrollBar.Smooth = True
        VertScrollBar.Tracking = True
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelInner = bvNone
        BevelOuter = bvNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 1
      end
    end
    object tsView: TTabSheet
      Caption = #22270#20687#26597#30475
      ImageIndex = 1
      object scrlbxView: TScrollBox
        Left = 0
        Top = 0
        Width = 1241
        Height = 663
        HorzScrollBar.Smooth = True
        HorzScrollBar.Tracking = True
        VertScrollBar.Tracking = True
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
        object imgView: TImage
          Left = -2
          Top = -2
          Width = 105
          Height = 105
          AutoSize = True
          PopupMenu = pmView
          OnDblClick = imgViewDblClick
        end
      end
    end
  end
  object mmMain: TMainMenu
    AutoHotkeys = maManual
    Left = 112
    Top = 272
    object N1: TMenuItem
      Caption = #25991#20214
      object N2: TMenuItem
        Caption = #25171#24320
      end
    end
  end
  object pmView: TPopupMenu
    AutoHotkeys = maManual
    Left = 112
    Top = 188
    object mniFitSize: TMenuItem
      Caption = #23454#38469#22823#23567
    end
    object mniLine01: TMenuItem
      Caption = '-'
    end
    object mniPirorImage: TMenuItem
      Tag = 120
      Caption = #19978#19968#24352
      OnClick = mniPirorImageClick
    end
    object mniNextImage: TMenuItem
      Tag = -120
      Caption = #19979#19968#24352
      OnClick = mniPirorImageClick
    end
    object mniFirstImage: TMenuItem
      Caption = #31532#19968#24352
      OnClick = mniFirstImageClick
    end
    object mniBottomImage: TMenuItem
      Caption = #26368#26411#24352
      OnClick = mniBottomImageClick
    end
    object mniLine02: TMenuItem
      Caption = '-'
    end
    object mniSlideShow: TMenuItem
      Caption = #24187#28783#29255#26174#31034
      OnClick = mniSlideShowClick
    end
  end
end
