object frmDBView: TfrmDBView
  Left = 0
  Top = 0
  Caption = #25968#25454#24211#26597#30475#22120' v2.0'
  ClientHeight = 675
  ClientWidth = 1168
  Color = clBtnFace
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
    1168
    675)
  PixelsPerInch = 96
  TextHeight = 13
  object btnDBLink: TButton
    Left = 8
    Top = 9
    Width = 173
    Height = 38
    Caption = #25968#25454#24211#36830#25509
    DropDownMenu = pmDBType
    Style = bsSplitButton
    TabOrder = 0
    OnClick = btnDBLinkClick
  end
  object grpTables: TGroupBox
    Left = 8
    Top = 55
    Width = 173
    Height = 612
    Anchors = [akLeft, akTop, akBottom]
    Caption = #34920#21015#34920#65306
    TabOrder = 1
    object lstTables: TListBox
      Left = 2
      Top = 15
      Width = 169
      Height = 595
      Align = alClient
      BorderStyle = bsNone
      ItemHeight = 13
      TabOrder = 0
      OnClick = lstTablesClick
    end
  end
  object grpFieldType: TGroupBox
    Left = 187
    Top = 55
    Width = 258
    Height = 612
    Anchors = [akLeft, akTop, akBottom]
    Caption = #34920#32467#26500#65306
    TabOrder = 2
    object lvFieldType: TListView
      Left = 2
      Top = 15
      Width = 254
      Height = 595
      Align = alClient
      BorderStyle = bsNone
      Columns = <
        item
          Caption = #26174#31034
          Width = 40
        end
        item
          Caption = #23383#27573#21517#31216
          Width = 100
        end
        item
          Caption = #25968#25454#31867#22411
          Width = 90
        end>
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = lvFieldTypeClick
      OnDrawItem = lvFieldTypeDrawItem
    end
  end
  object lvData: TListView
    Left = 456
    Top = 62
    Width = 701
    Height = 605
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <>
    DoubleBuffered = True
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    ParentFont = False
    TabOrder = 3
    ViewStyle = vsReport
    OnData = lvDataData
  end
  object btnExportExcel: TButton
    Left = 1012
    Top = 9
    Width = 145
    Height = 38
    Anchors = [akTop, akRight]
    Caption = #23548#20986#21040' EXCEL'
    Enabled = False
    TabOrder = 4
    OnClick = btnExportExcelClick
  end
  object btnDataView: TButton
    Left = 187
    Top = 9
    Width = 258
    Height = 38
    Caption = #27983#35272#25968#25454
    Enabled = False
    TabOrder = 5
    OnClick = btnDataViewClick
  end
  object btnQuery: TButton
    Left = 456
    Top = 9
    Width = 145
    Height = 38
    Caption = #25968#25454#26597#35810
    Enabled = False
    TabOrder = 6
    OnClick = btnQueryClick
  end
  object conADO: TADOConnection
    Left = 68
    Top = 95
  end
  object qryTemp: TADOQuery
    Connection = conADO
    Parameters = <>
    Left = 68
    Top = 163
  end
  object qryData: TADOQuery
    Connection = conADO
    Parameters = <>
    Left = 68
    Top = 239
  end
  object dlgSaveExcel: TSaveDialog
    Filter = 'EXCEL(*.XLSX)|*.XLSX'
    Left = 1008
    Top = 148
  end
  object pmDBType: TPopupMenu
    Left = 72
    Top = 319
    object mniSqlite31: TMenuItem
      Caption = 'Sqlite3 '#25968#25454#24211
      OnClick = mniSqlite31Click
    end
  end
  object dlgOpenSqlite3DB: TOpenDialog
    Filter = 'Sqlite3(*.DB)|*.DB'
    Left = 1004
    Top = 96
  end
end
