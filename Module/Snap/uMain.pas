unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, {$IFDEF DX12} DX12.D3D11, DX12.D3DCommon, DX12.DXGI, DX12.DXGI1_2, {$ELSE} Winapi.D3D11, Winapi.D3DX9, Winapi.Direct3D9, Winapi.D3DCommon, Winapi.DXGI, Winapi.DXGI1_2, {$ENDIF} System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, db.uCommon;

type
  TSnapType = (stGDI, stDX, stDXGI);

type
  TfrmSnapScreen = class(TForm)
    btnGDI: TButton;
    btnDX: TButton;
    tmrPos: TTimer;
    scrlbxSnapScreen: TScrollBox;
    imgSnap: TImage;
    btnDXGI: TButton;
    btnSaveFile: TButton;
    dlgSaveSnap: TSaveDialog;
    procedure btnGDIClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveFileClick(Sender: TObject);
    procedure btnDXClick(Sender: TObject);
    procedure btnDXGIClick(Sender: TObject);
  private
    FSnapType                : TSnapType;
    FintBackTop, FintBackLeft: Integer;
    FDevice                  : ID3D11Device;
    FContext                 : ID3D11DeviceContext;
    FFeatureLevel            : TD3D_FEATURE_LEVEL;
    FOutput                  : {$IFDEF DX12} TDXGI_OUTPUT_DESC {$ELSE} TDXGIOutputDesc {$ENDIF};
    FDuplicate               : IDXGIOutputDuplication;
    FbGetDuplicateScreen     : Boolean;
    function CreateDuplicateOutput: Boolean;
  public
    procedure Snap(const x1, y1, x2, y2: Integer);
    { GDI 截图 }
    procedure SnapGDI(const x1, y1, x2, y2: Integer);
    { DX 截图 }
    procedure SnapDX(const x1, y1, x2, y2: Integer);
    { DXGI 截图 }
    procedure SnapDXGI(const x1, y1, x2, y2: Integer);
    procedure ShowDllMainForm;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

uses uFullScreen;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSnapScreen;
  strParentModuleName     := '图形图像';
  strModuleName           := '屏幕截图';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmSnapScreen.btnDXClick(Sender: TObject);
begin
  FSnapType := stDX;
end;

procedure TfrmSnapScreen.btnDXGIClick(Sender: TObject);
begin
  FSnapType := stDXGI;
end;

procedure TfrmSnapScreen.btnGDIClick(Sender: TObject);
begin
  FSnapType := stGDI;
  ShowFullScreen(Handle);
  FintBackTop                          := GetMainFormApplication.MainForm.Top;
  FintBackLeft                         := GetMainFormApplication.MainForm.Left;
  GetMainFormApplication.MainForm.Top  := -10000;
  GetMainFormApplication.MainForm.Left := -10000;
end;

procedure TfrmSnapScreen.btnSaveFileClick(Sender: TObject);
begin
  if imgSnap.Picture.Bitmap.Handle = 0 then
    Exit;

  if not dlgSaveSnap.Execute then
    Exit;

  if dlgSaveSnap.FilterIndex = 1 then
  begin
    imgSnap.Picture.SaveToFile(dlgSaveSnap.FileName + '.bmp');
  end
  else if dlgSaveSnap.FilterIndex = 2 then
  begin
    with TJPEGImage.create do
    begin
      CompressionQuality := 80;
      Assign(imgSnap.Picture.Bitmap);
      SaveToFile(dlgSaveSnap.FileName + '.jpg');
      Free;
    end;
  end
  else
  begin
    with TPngImage.create do
    begin
      Assign(imgSnap.Picture.Bitmap);
      SaveToFile(dlgSaveSnap.FileName + '.png');
      Free;
    end;
  end;
end;

function TfrmSnapScreen.CreateDuplicateOutput: Boolean;
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

procedure TfrmSnapScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmSnapScreen.FormCreate(Sender: TObject);
begin
  btnDXGI.Enabled := Win32MajorVersion > 6;
end;

procedure TfrmSnapScreen.ShowDllMainForm;
begin
  GetMainFormApplication.MainForm.Top  := FintBackTop;
  GetMainFormApplication.MainForm.Left := FintBackLeft;
end;

procedure TfrmSnapScreen.Snap(const x1, y1, x2, y2: Integer);
begin
  case FSnapType of
    stGDI:
      SnapGDI(x1, y1, x2, y2);
    stDX:
      SnapDX(x1, y1, x2, y2);
    stDXGI:
      SnapDXGI(x1, y1, x2, y2);
  end;
end;

{ GDI 截图 }
procedure TfrmSnapScreen.SnapGDI(const x1, y1, x2, y2: Integer);
var
  cvsTemp: TCanvas;
  bmpSnap: TBitmap;
begin
  bmpSnap := TBitmap.create;
  cvsTemp := TCanvas.create;
  try
    cvsTemp.Handle      := GetDC(0);
    bmpSnap.PixelFormat := pf32bit;
    bmpSnap.width       := abs(x2 - x1);
    bmpSnap.height      := abs(y2 - y1);
    bmpSnap.Canvas.CopyRect(bmpSnap.Canvas.ClipRect, cvsTemp, Rect(x1, y1, x2, y2));
    imgSnap.Picture.Bitmap.Assign(bmpSnap);
  finally
    DeleteDC(cvsTemp.Handle);
    cvsTemp.Free;
    bmpSnap.Free;
  end;
end;

{ DX 截图 }
procedure TfrmSnapScreen.SnapDX(const x1, y1, x2, y2: Integer);
var
  hr        : HRESULT;
  pD3D      : IDirect3D9;
  D3DPP     : D3DPRESENT_PARAMETERS;
  mode      : TD3DDisplayMode;
  surf      : IDirect3DSurface9;
  pD3DDevice: IDirect3DDevice9;
  rct       : TRect;
begin
  pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  if pD3D = nil then
  begin
    Exit;
  end;

  D3DPP.Windowed         := True;
  D3DPP.SwapEffect       := D3DSWAPEFFECT_DISCARD;
  D3DPP.BackBufferFormat := D3DFMT_UNKNOWN;
  hr                     := pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Handle, D3DCREATE_SOFTWARE_VERTEXPROCESSING, @D3DPP, pD3DDevice);
  if Failed(hr) then
  begin
    Exit;
  end;

  hr := pD3DDevice.GetDisplayMode(0, mode);
  if Failed(hr) then
  begin
    Exit;
  end;

  hr := pD3DDevice.CreateOffscreenPlainSurface(mode.width, mode.height, D3DFMT_A8R8G8B8, D3DPOOL_SYSTEMMEM, surf, nil);
  if Failed(hr) then
  begin
    Exit;
  end;

  hr := pD3DDevice.GetFrontBufferData(9, surf);
  if Failed(hr) then
  begin
    surf._Release;
    Exit;
  end;

  rct := Rect(x1, y1, x2, y2);
  hr  := D3DXSaveSurfaceToFile('c:\tmp.bmp', D3DXIFF_BMP, surf, nil, @rct);
  if Failed(hr) then
  begin
    surf._Release;
    Exit;
  end;

  imgSnap.Picture.LoadFromFile('c:\tmp.bmp');
  DeleteFile('c:\tmp.bmp');
  surf._Release;
  pD3DDevice._Release;
  pD3D._Release;
end;

{ DXGI 截图 }
procedure TfrmSnapScreen.SnapDXGI(const x1, y1, x2, y2: Integer);
var
  intRet   : Integer;
  FrameInfo: {$IFDEF DX12} TDXGI_OUTDUPL_FRAME_INFO {$ELSE}DXGI_OUTDUPL_FRAME_INFO {$ENDIF};
  Resource : IDXGIResource;
  Texture  : ID3D11Texture2D;
  Desc     : TD3D11_TEXTURE2D_DESC;
  Copy     : ID3D11Texture2D;
  ScreenRes: TD3D11_MAPPED_SUBRESOURCE;
  bmpTemp  : TBitmap;
  bmpSnap  : TBitmap;
begin
  if not FbGetDuplicateScreen then
    FbGetDuplicateScreen := CreateDuplicateOutput;

  if not FbGetDuplicateScreen then
  begin
    MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  if FDuplicate = nil then
  begin
    MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  intRet := FDuplicate.AcquireNextFrame(10, FrameInfo, Resource);
  if Failed(intRet) then
  begin
    MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  try
    if (FrameInfo.TotalMetadataBufferSize <= 0) then
    begin
      MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
      Exit;
    end;

    intRet := Resource.QueryInterface(IID_ID3D11Texture2D, Texture);
    if Failed(intRet) then
    begin
      MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
      Exit;
    end;

    Texture.GetDesc(Desc);
    Desc.BindFlags      := 0;
    Desc.CPUAccessFlags := Ord(D3D11_CPU_ACCESS_READ) or Ord(D3D11_CPU_ACCESS_WRITE);
    Desc.Usage          := D3D11_USAGE_STAGING;
    Desc.MiscFlags      := 0;
    intRet              := FDevice.CreateTexture2D(Desc, nil, Copy);
    if Failed(intRet) then
    begin
      MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
      Exit;
    end;

    FContext.CopyResource(Copy, Texture);
    FContext.Map(Copy, 0, D3D11_MAP_READ_WRITE, 0, ScreenRes);
    try
      bmpTemp := TBitmap.create;
      bmpSnap := TBitmap.create;
      try
        bmpTemp.PixelFormat := pf32bit;
        bmpSnap.PixelFormat := pf32bit;
        bmpSnap.width       := abs(x2 - x1);
        bmpSnap.height      := abs(y2 - y1);
        bmpTemp.width       := Desc.width;
        bmpTemp.height      := Desc.height;
        SetBitmapBits(bmpTemp.Handle, Desc.width * Desc.height * 4, ScreenRes.PData);
        bmpSnap.Canvas.CopyRect(bmpSnap.Canvas.ClipRect, bmpTemp.Canvas, Rect(x1, y1, x2, y2));
        imgSnap.Picture.Bitmap.Assign(bmpSnap);
      finally
        bmpTemp.Free;
        bmpSnap.Free;
      end;
    finally
      Texture := nil;
    end;
  finally
    FDuplicate.ReleaseFrame();
  end;
end;

end.
