object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #20851#20110
  ClientHeight = 253
  ClientWidth = 369
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 32
    Top = 32
    Width = 39
    Height = 13
    Caption = #21517#31216#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl2: TLabel
    Left = 32
    Top = 59
    Width = 39
    Height = 13
    Caption = #29256#26412#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 113
    Top = 86
    Width = 230
    Height = 13
    Caption = #22522#20110' Dll '#21160#24577#24211#31383#20307#30340#27169#22359#21270#24320#21457#24179#21488
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl4: TLabel
    Left = 113
    Top = 113
    Width = 189
    Height = 13
    Caption = 'Copyright (C) 2020, dbyoung'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl5: TLabel
    Left = 32
    Top = 140
    Width = 39
    Height = 13
    Caption = #20027#39029#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl6: TLabel
    Left = 32
    Top = 168
    Width = 65
    Height = 13
    Caption = #30005#23376#37038#20214#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl7: TLabel
    Left = 113
    Top = 32
    Width = 35
    Height = 13
    Caption = 'PBox '
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl8: TLabel
    Left = 113
    Top = 59
    Width = 21
    Height = 13
    Caption = '2.0'
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl9: TLabel
    Left = 32
    Top = 86
    Width = 39
    Height = 13
    Caption = #21151#33021#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object lbl10: TLabel
    Left = 32
    Top = 113
    Width = 39
    Height = 13
    Caption = #29256#26435#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
  end
  object btn2: TButton
    Left = 256
    Top = 200
    Width = 98
    Height = 37
    Caption = #20851#38381
    ModalResult = 1
    TabOrder = 0
  end
  object lnklblWebAddress: TLinkLabel
    Left = 113
    Top = 140
    Width = 85
    Height = 17
    Hint = 'https://blog.csdn.net/dbyoung'
    Caption = '<a href="https://blog.csdn.net/dbyoung">dbyoung '#30340#21338#23458'</a>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnLinkClick = lnklblWebAddressLinkClick
  end
  object lnklbl1: TLinkLabel
    Left = 113
    Top = 168
    Width = 85
    Height = 17
    Hint = 'dbyoung@sina.com'
    Caption = '<a href="mailto:dbyoung@sina.com">dbyoung '#30340#37038#31665'</a>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnLinkClick = lnklbl1LinkClick
  end
end
