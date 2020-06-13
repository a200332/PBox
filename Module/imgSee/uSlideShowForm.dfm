object frmSlideShow: TfrmSlideShow
  Left = 0
  Top = 0
  Caption = 'frmSlideShow'
  ClientHeight = 434
  ClientWidth = 798
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object tmrSlideShow: TTimer
    Interval = 3000
    OnTimer = tmrSlideShowTimer
    Left = 228
    Top = 120
  end
end
