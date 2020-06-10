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
    ActivePage = tsBrowse
    Align = alClient
    TabOrder = 0
    object tsBrowse: TTabSheet
      Caption = #22270#20687#27983#35272
      DesignSize = (
        1241
        666)
      object shltrvwImage: TShellTreeView
        Left = 12
        Top = 3
        Width = 373
        Height = 649
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
        Height = 649
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
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object scrlbxView: TScrollBox
        Left = 0
        Top = 0
        Width = 1241
        Height = 666
        HorzScrollBar.Smooth = True
        HorzScrollBar.Tracking = True
        VertScrollBar.Tracking = True
        Align = alClient
        TabOrder = 0
        object imgView: TImage
          Left = -2
          Top = -2
          Width = 105
          Height = 105
          AutoSize = True
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
end
