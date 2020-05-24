object frmSpider: TfrmSpider
  Left = 0
  Top = 0
  Caption = #29228#34411' --- '#29228#21462#24444#23736#32593#22721#32440
  ClientHeight = 629
  ClientWidth = 1193
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnDestroy = FormDestroy
  DesignSize = (
    1193
    629)
  PixelsPerInch = 96
  TextHeight = 13
  object imgVW: TImage
    Left = 779
    Top = 8
    Width = 406
    Height = 613
    Anchors = [akTop, akRight, akBottom]
    Stretch = True
    ExplicitHeight = 555
  end
  object mmoLog: TMemo
    Left = 8
    Top = 8
    Width = 760
    Height = 613
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    PopupMenu = pmLog
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object pmLog: TPopupMenu
    Left = 176
    Top = 192
  end
  object idhtpDown: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 176
    Top = 140
  end
  object tmrDown: TTimer
    OnTimer = tmrDownTimer
    Left = 176
    Top = 80
  end
end
