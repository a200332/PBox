object frmSnapScreen: TfrmSnapScreen
  Left = 0
  Top = 0
  Caption = #23631#24149#25130#22270
  ClientHeight = 576
  ClientWidth = 981
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    981
    576)
  PixelsPerInch = 96
  TextHeight = 13
  object btnGDI: TButton
    Left = 8
    Top = 8
    Width = 151
    Height = 41
    Caption = 'GDI '#25130#22270' (WIN7 - WIN10)'
    TabOrder = 0
    OnClick = btnGDIClick
  end
  object btnDX: TButton
    Left = 165
    Top = 8
    Width = 151
    Height = 41
    Caption = 'DX '#25130#22270' (WIN7 - WIN10)'
    TabOrder = 1
    OnClick = btnDXClick
  end
  object scrlbxSnapScreen: TScrollBox
    Left = 8
    Top = 60
    Width = 965
    Height = 508
    HorzScrollBar.Smooth = True
    HorzScrollBar.Tracking = True
    VertScrollBar.Smooth = True
    VertScrollBar.Tracking = True
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clGray
    ParentColor = False
    TabOrder = 2
    object imgSnap: TImage
      Left = 0
      Top = 0
      Width = 306
      Height = 161
      AutoSize = True
    end
  end
  object btnDXGI: TButton
    Left = 322
    Top = 8
    Width = 151
    Height = 41
    Caption = 'DXGI '#25130#22270' (WIN8 - WIN10)'
    TabOrder = 3
    OnClick = btnDXGIClick
  end
  object btnSaveFile: TButton
    Left = 822
    Top = 8
    Width = 151
    Height = 41
    Anchors = [akTop, akRight]
    Caption = #22270#20687#20445#23384
    TabOrder = 4
    OnClick = btnSaveFileClick
  end
  object tmrPos: TTimer
    Left = 428
    Top = 204
  end
  object dlgSaveSnap: TSaveDialog
    Filter = 'BMP|*.BMP|JPG|*.JPG|PNG|*.PNG'
    Left = 424
    Top = 136
  end
end
