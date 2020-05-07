unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, {$IFDEF DX12} DX12.D3D11, DX12.D3DCommon, DX12.DXGI, DX12.DXGI1_2, {$ELSE} Winapi.D3D11, Winapi.D3DCommon, Winapi.DXGI, Winapi.DXGI1_2, {$ENDIF} System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.Win.Registry, System.IniFiles, System.Types, System.IOUtils,
  Vcl.Graphics, Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, Vcl.Clipbrd, Vcl.StdCtrls, Vcl.Imaging.jpeg, db.uCommon;

type
  TfrmP2PChat = class(TForm)
    tmrSnap: TTimer;
    grpLogin: TGroupBox;
    btnShowLoginForm: TSpeedButton;
    edtUserName: TEdit;
    lblUserName: TLabel;
    lblUserPass: TLabel;
    edtUserPass: TEdit;
    btnLogin: TButton;
    pnlPID: TPanel;
    lblPID: TLabel;
    edtID: TEdit;
    btnCopy: TButton;
    grpChat: TGroupBox;
    grpFriends: TGroupBox;
    btnShowFriends: TSpeedButton;
    pnlChat: TPanel;
    pgcChat: TPageControl;
    chkAutoLogin: TCheckBox;
    ts1: TTabSheet;
    scrlbxScreen: TScrollBox;
    imgScreen: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrSnapTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnShowLoginFormClick(Sender: TObject);
    procedure btnShowFriendsClick(Sender: TObject);
  private
    FBmpBackup   : TBitmap;
    FBmpScreen   : TBitmap;
    FbDXGIDesktop: Boolean;
    FDevice      : ID3D11Device;
    FContext     : ID3D11DeviceContext;
    FFeatureLevel: TD3D_FEATURE_LEVEL;
    FOutput      : {$IFDEF DX12} TDXGI_OUTPUT_DESC {$ELSE} TDXGIOutputDesc {$ENDIF};
    FDuplicate   : IDXGIOutputDuplication;
    function CreateDuplicateOutput: Boolean;
    procedure HideLoginGroup;
    procedure SnapScreen_DXGI;
    procedure SnapScreen_GDI;
    procedure SendScreen(const bmp: TBitmap);
    { 屏幕是否发生改变 }
    function ScreenChange(const bmp: TBitmap): Boolean;
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmP2PChat;
  strParentModuleName     := '网络管理';
  strModuleName           := 'P2P聊天';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

type
  TMyBitamp = class(TBitmap)

  end;

  TMyBitmapImage = class(TBitmapImage)

  end;

procedure TfrmP2PChat.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FBmpBackup.Free;
  FBmpScreen.Free;
  Action := caFree;
end;

procedure TfrmP2PChat.FormCreate(Sender: TObject);
begin
  FBmpBackup             := TBitmap.Create;
  FBmpScreen             := TBitmap.Create;
  FBmpScreen.PixelFormat := pf32bit;
  FBmpBackup.PixelFormat := pf32bit;

  FbDXGIDesktop := CreateDuplicateOutput;
  HideLoginGroup;
end;

procedure TfrmP2PChat.btnShowFriendsClick(Sender: TObject);
begin
  if btnShowFriends.Caption = '>' then
  begin
    btnShowFriends.Left    := btnShowFriends.Parent.Width - btnShowFriends.Width - 2;
    grpFriends.Visible     := False;
    btnShowFriends.Hint    := '显示好友列表';
    btnShowFriends.Caption := '<';
    pnlChat.Width          := pnlChat.Parent.Width - btnShowFriends.Width - 8;
  end
  else
  begin
    btnShowFriends.Left    := btnShowFriends.Parent.Width - 313;
    grpFriends.Visible     := True;
    btnShowFriends.Hint    := '隐藏好友列表';
    btnShowFriends.Caption := '>';
    pnlChat.Width          := pnlChat.Parent.Width - 320;
  end;
end;

procedure TfrmP2PChat.HideLoginGroup;
begin
  btnShowLoginForm.Left    := 2;
  btnShowLoginForm.Hint    := '显示登录框';
  grpLogin.Visible         := False;
  btnShowLoginForm.Caption := '>';
  grpChat.Left             := 2 + btnShowLoginForm.Left + btnShowLoginForm.Width;
  grpChat.Width            := Width - 362 + grpLogin.Width + 16;
end;

procedure TfrmP2PChat.btnShowLoginFormClick(Sender: TObject);
begin
  if btnShowLoginForm.Caption = '<' then
  begin
    HideLoginGroup;
  end
  else
  begin
    btnShowLoginForm.Left    := 313;
    btnShowLoginForm.Hint    := '隐藏登录框';
    grpLogin.Visible         := True;
    btnShowLoginForm.Caption := '<';
    grpChat.Left             := btnShowLoginForm.Left + btnShowLoginForm.Width + 2;
    grpChat.Width            := Width - 362 + 10;
  end;
end;

function TfrmP2PChat.CreateDuplicateOutput: Boolean;
var
  intRet     : Integer;
  GI         : IDXGIDevice;
  GA         : IDXGIAdapter;
  GO         : IDXGIOutput;
  DXGIOutput1: IDXGIOutput1;
begin
  Result := False;
{$IFDEF DX12}
  intRet := D3D11CreateDevice(nil, D3D_DRIVER_TYPE_HARDWARE, 0, Ord(D3D11_CREATE_DEVICE_SINGLETHREADED), nil, 0, D3D11_SDK_VERSION, FDevice, FFeatureLevel, @FContext);
{$ELSE}
  intRet := D3D11CreateDevice(nil, D3D_DRIVER_TYPE_HARDWARE, 0, Ord(D3D11_CREATE_DEVICE_SINGLETHREADED), nil, 0, D3D11_SDK_VERSION, FDevice, FFeatureLevel, FContext);
{$ENDIF}
  if Failed(intRet) then
    Exit;

  intRet := FDevice.QueryInterface(IID_IDXGIDevice, GI);
  if Failed(intRet) then
    Exit;

  intRet := GI.GetParent(IID_IDXGIAdapter, Pointer(GA));
  if Failed(intRet) then
    Exit;

  intRet := GA.EnumOutputs(0, GO);
  if Failed(intRet) then
    Exit;

  intRet := GO.GetDesc(FOutput);
  if Failed(intRet) then
    Exit;

  intRet := GO.QueryInterface(IID_IDXGIOutput1, DXGIOutput1);
  if Failed(intRet) then
    Exit;

  intRet := DXGIOutput1.DuplicateOutput(FDevice, FDuplicate);
  if Failed(intRet) then
    Exit;

  Result := True;
end;

procedure TfrmP2PChat.SnapScreen_DXGI;
var
  intRet   : Integer;
  FrameInfo: {$IFDEF DX12} TDXGI_OUTDUPL_FRAME_INFO {$ELSE}DXGI_OUTDUPL_FRAME_INFO {$ENDIF};
  Resource : IDXGIResource;
  Texture  : ID3D11Texture2D;
  Desc     : TD3D11_TEXTURE2D_DESC;
  Copy     : ID3D11Texture2D;
  ScreenRes: TD3D11_MAPPED_SUBRESOURCE;
begin
  if FDuplicate = nil then
    Exit;

  intRet := FDuplicate.AcquireNextFrame(10, FrameInfo, Resource);
  if Failed(intRet) then
    Exit;

  try
    if (FrameInfo.TotalMetadataBufferSize <= 0) then
      Exit;

    intRet := Resource.QueryInterface(IID_ID3D11Texture2D, Texture);
    if Failed(intRet) then
      Exit;

    Texture.GetDesc(Desc);
    Desc.BindFlags      := 0;
    Desc.CPUAccessFlags := Ord(D3D11_CPU_ACCESS_READ) or Ord(D3D11_CPU_ACCESS_WRITE);
    Desc.Usage          := D3D11_USAGE_STAGING;
    Desc.MiscFlags      := 0;
    intRet              := FDevice.CreateTexture2D(Desc, nil, Copy);
    if Failed(intRet) then
      Exit;

    FContext.CopyResource(Copy, Texture);
    FContext.Map(Copy, 0, D3D11_MAP_READ_WRITE, 0, ScreenRes);
    try
      FBmpScreen.Width  := Desc.Width;
      FBmpScreen.Height := Desc.Height;
      SetBitmapBits(FBmpScreen.Handle, Desc.Width * Desc.Height * 4, ScreenRes.PData);
      SendScreen(FBmpScreen);
    finally
      Texture := nil;
    end;
  finally
    FDuplicate.ReleaseFrame();
  end;
end;

{ 比较位图差异 }
function SameAsBmp(const bmp1, bmp2: TBitmap): Boolean;
var
  p1, p2: PByte;
begin
  p1     := TMyBitmapImage(TMyBitamp(bmp1).FImage).FDIB.dsBm.bmBits;
  p2     := TMyBitmapImage(TMyBitamp(bmp2).FImage).FDIB.dsBm.bmBits;
  Result := CompareMem(p1, p2, TMyBitmapImage(TMyBitamp(bmp1).FImage).FDIB.dsBm.bmWidthBytes * TMyBitmapImage(TMyBitamp(bmp1).FImage).FDIB.dsBm.bmHeight);
end;

{ 屏幕是否发生改变 }
function TfrmP2PChat.ScreenChange(const bmp: TBitmap): Boolean;
  procedure BackupBmp;
  begin
    { 备份位图 }
    FBmpBackup.Width  := bmp.Width;
    FBmpBackup.Height := bmp.Height;
    FBmpBackup.Assign(bmp);
    Result := True;
  end;

begin
  Result := False;

  if FBmpBackup.Handle = 0 then
  begin
    { 备份位图 }
    BackupBmp;
  end
  else
  begin
    { 比较位图差异 }
    if not SameAsBmp(FBmpBackup, bmp) then
    begin
      { 备份位图 }
      BackupBmp;
    end;
  end;
end;

procedure TfrmP2PChat.SnapScreen_GDI;
var
  memDC    : HDC;
  tmpCanvas: TCanvas;
begin
  memDC := GetDC(0);
  try
    tmpCanvas         := TCanvas.Create;
    tmpCanvas.Handle  := memDC;
    FBmpScreen.Width  := tmpCanvas.ClipRect.Width;
    FBmpScreen.Height := tmpCanvas.ClipRect.Height;
    FBmpScreen.Canvas.CopyRect(FBmpScreen.Canvas.ClipRect, tmpCanvas, tmpCanvas.ClipRect);
    if ScreenChange(FBmpScreen) then
      SendScreen(FBmpScreen);
  finally
    DeleteDC(memDC);
  end;
end;

procedure TfrmP2PChat.tmrSnapTimer(Sender: TObject);
begin
  tmrSnap.Enabled := False;
  try
    if FbDXGIDesktop then
      SnapScreen_DXGI
    else
      SnapScreen_GDI;
  finally
    tmrSnap.Enabled := True;
  end;
end;

procedure TfrmP2PChat.SendScreen(const bmp: TBitmap);
var
  jpeg: TJPEGImage;
begin
  jpeg := TJPEGImage.Create;
  try
    jpeg.CompressionQuality := 30;
    jpeg.Assign(bmp);
    imgScreen.Picture.Assign(jpeg);
  finally
    jpeg.Free;
  end;
end;

end.
