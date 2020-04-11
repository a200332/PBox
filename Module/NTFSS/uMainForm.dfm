object frmNTFSS: TfrmNTFSS
  Left = 0
  Top = 0
  Caption = 'NTFS '#25991#20214#25628#32034
  ClientHeight = 686
  ClientWidth = 1129
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  DesignSize = (
    1129
    686)
  PixelsPerInch = 96
  TextHeight = 13
  object lblFilter: TLabel
    Left = 8
    Top = 13
    Width = 39
    Height = 13
    Caption = #26597#25214#65306
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object lblSearchTip: TLabel
    Left = 456
    Top = 12
    Width = 9
    Height = 16
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -16
    Font.Name = #23435#20307
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lvData: TListView
    Left = 8
    Top = 40
    Width = 1113
    Height = 638
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #24207#21015
        Width = 100
      end
      item
        Caption = #25991#20214#21517#31216
        Width = 150
      end
      item
        Caption = #25991#20214#36335#24452
        Width = 500
      end
      item
        Caption = #21019#24314#26102#38388
        Width = 150
      end
      item
        Caption = #20462#25913#26102#38388
        Width = 150
      end>
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #23435#20307
    Font.Style = []
    GridLines = True
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnData = lvDataData
  end
  object srchbxFilter: TSearchBox
    Left = 60
    Top = 8
    Width = 281
    Height = 21
    TabOrder = 1
    Visible = False
  end
  object tmrStart: TTimer
    OnTimer = tmrStartTimer
    Left = 72
    Top = 116
  end
end
