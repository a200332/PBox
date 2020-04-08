object frmSQL: TfrmSQL
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #33258#23450#20041'SQL'#65306
  ClientHeight = 320
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object mmoSQL: TMemo
    Left = 8
    Top = 8
    Width = 593
    Height = 257
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 512
    Top = 276
    Width = 90
    Height = 33
    Caption = #25191#34892
    TabOrder = 1
    OnClick = btnOKClick
  end
end
