object frmP2PChat: TfrmP2PChat
  Left = 0
  Top = 0
  Caption = 'P2P'#32842#22825
  ClientHeight = 702
  ClientWidth = 1347
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    1347
    702)
  PixelsPerInch = 96
  TextHeight = 13
  object btnShowLoginForm: TSpeedButton
    Left = 313
    Top = 17
    Width = 23
    Height = 22
    Hint = #38544#34255#30331#24405#26694
    Caption = '<'
    Flat = True
    ParentShowHint = False
    ShowHint = True
    OnClick = btnShowLoginFormClick
  end
  object grpLogin: TGroupBox
    Left = 8
    Top = 12
    Width = 305
    Height = 678
    Anchors = [akLeft, akTop, akBottom]
    Caption = #30331#24405#65306
    TabOrder = 0
    object lblUserName: TLabel
      Left = 12
      Top = 36
      Width = 60
      Height = 13
      Caption = #30331#24405#21517#31216#65306
    end
    object lblUserPass: TLabel
      Left = 12
      Top = 68
      Width = 60
      Height = 13
      Caption = #30331#24405#23494#30721#65306
    end
    object edtUserName: TEdit
      Left = 78
      Top = 33
      Width = 207
      Height = 21
      TabOrder = 0
    end
    object edtUserPass: TEdit
      Left = 78
      Top = 65
      Width = 207
      Height = 21
      TabOrder = 1
    end
    object btnLogin: TButton
      Left = 163
      Top = 96
      Width = 122
      Height = 33
      Caption = #30331#24405
      TabOrder = 2
    end
    object pnlPID: TPanel
      Left = 0
      Top = 126
      Width = 294
      Height = 444
      BevelOuter = bvNone
      Caption = 'pnlPID'
      ShowCaption = False
      TabOrder = 3
      Visible = False
      object lblPID: TLabel
        Left = 9
        Top = 24
        Width = 50
        Height = 13
        Caption = #29992#25143' ID'#65306
      end
      object edtID: TEdit
        Left = 75
        Top = 48
        Width = 207
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
      object btnCopy: TButton
        Left = 160
        Top = 280
        Width = 122
        Height = 33
        Caption = #22797#21046#21040#21098#20999#26495
        TabOrder = 1
      end
    end
    object chkAutoLogin: TCheckBox
      Left = 78
      Top = 92
      Width = 67
      Height = 17
      Caption = #33258#21160#30331#24405
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
  end
  object grpChat: TGroupBox
    Left = 338
    Top = 12
    Width = 1001
    Height = 678
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = #32842#22825
    TabOrder = 1
    DesignSize = (
      1001
      678)
    object btnShowFriends: TSpeedButton
      Left = 688
      Top = 20
      Width = 23
      Height = 22
      Hint = #38544#34255#22909#21451#26694
      Anchors = [akTop, akRight]
      Caption = '>'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnShowFriendsClick
      ExplicitLeft = 531
    end
    object grpFriends: TGroupBox
      Left = 713
      Top = 15
      Width = 286
      Height = 661
      Align = alRight
      Caption = #22909#21451#21015#34920#65306
      TabOrder = 0
    end
    object pnlChat: TPanel
      Left = 6
      Top = 20
      Width = 681
      Height = 655
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvNone
      Caption = 'pnlChat'
      Ctl3D = False
      ParentCtl3D = False
      ShowCaption = False
      TabOrder = 1
      object pgcChat: TPageControl
        Left = 0
        Top = 0
        Width = 681
        Height = 655
        ActivePage = ts1
        Align = alClient
        TabHeight = 20
        TabOrder = 0
        TabWidth = 100
        object ts1: TTabSheet
          Caption = #24352#19977
          object scrlbxScreen: TScrollBox
            Left = 0
            Top = 0
            Width = 673
            Height = 625
            HorzScrollBar.Smooth = True
            HorzScrollBar.Tracking = True
            VertScrollBar.Smooth = True
            VertScrollBar.Tracking = True
            Align = alClient
            TabOrder = 0
            object imgScreen: TImage
              Left = 0
              Top = 0
              Width = 105
              Height = 105
              AutoSize = True
            end
          end
        end
      end
    end
  end
  object tmrSnap: TTimer
    OnTimer = tmrSnapTimer
    Left = 736
    Top = 164
  end
end
