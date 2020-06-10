unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.D3DX9, Winapi.Direct3D9, System.SysUtils, System.Classes, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage,
  Execute.DesktopDuplicationAPI, db.uCommon;

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
    pmGDI: TPopupMenu;
    mniGDIRect: TMenuItem;
    mniGDIWindow: TMenuItem;
    procedure btnGDIClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSaveFileClick(Sender: TObject);
    procedure btnDXClick(Sender: TObject);
    procedure btnDXGIClick(Sender: TObject);
    procedure mniGDIWindowClick(Sender: TObject);
    procedure tmrPosTimer(Sender: TObject);
  private
    FSnapType     : TSnapType;
    FDuplication  : TDesktopDuplicationWrapper;
    FcvsGDIWindow : TCanvas;
    FintBackHandle: THandle;
    FrctBackForm  : TRect;
    { 注册热键 }
    procedure RegHotkey;
    { 销毁热键 }
    procedure FreeHotkey;
    procedure ClearFormRect;
    procedure imgPos;
  protected
    { 热键相应消息 }
    procedure WMHOTKEY(var Msg: TWMHOTKEY); message wm_hotkey;
  public
    procedure Snap(const x1, y1, x2, y2: Integer);
    { GDI 截图 }
    procedure SnapGDI(const x1, y1, x2, y2: Integer);
    { DX 截图 }
    procedure SnapDX(const x1, y1, x2, y2: Integer);
    { DXGI 截图 }
    procedure SnapDXGI(const x1, y1, x2, y2: Integer);
    procedure HideMainForm;
    procedure ShowMainForm;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

uses uFullScreen;

const
  c_intHotkeyID = 11223344;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSnapScreen;
  strParentModuleName     := '图形图像';
  strModuleName           := '屏幕截图';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmSnapScreen.HideMainForm;
begin
  GetMainFormApplication.MainForm.WindowState := wsMinimized;
end;

procedure TfrmSnapScreen.ShowMainForm;
begin
  GetMainFormApplication.MainForm.WindowState := wsNormal;
end;

procedure TfrmSnapScreen.btnDXClick(Sender: TObject);
begin
  FSnapType := stDX;
  ShowFullScreen(Handle);
  HideMainForm;
end;

procedure TfrmSnapScreen.btnDXGIClick(Sender: TObject);
begin
  FSnapType := stDXGI;
  ShowFullScreen(Handle);
  HideMainForm;
end;

procedure TfrmSnapScreen.btnGDIClick(Sender: TObject);
begin
  FSnapType := stGDI;
  ShowFullScreen(Handle);
  HideMainForm;
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

procedure TfrmSnapScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DeleteDC(FcvsGDIWindow.Handle);
  FcvsGDIWindow.Free;
  FDuplication.Free;
  Action := caFree;
end;

procedure TfrmSnapScreen.FormCreate(Sender: TObject);
begin
  FDuplication         := TDesktopDuplicationWrapper.create;
  btnDXGI.Enabled      := Win32MajorVersion > 6;
  FcvsGDIWindow        := TCanvas.create;
  FcvsGDIWindow.Handle := GetDC(0);
end;

{ 注册热键 }
procedure TfrmSnapScreen.RegHotkey;
begin
  RegisterHotKey(Handle, c_intHotkeyID, 0, VK_ESCAPE)
end;

{ 销毁热键 }
procedure TfrmSnapScreen.FreeHotkey;
begin
  UnRegisterHotKey(Handle, c_intHotkeyID);
end;

procedure TfrmSnapScreen.ClearFormRect;
begin
  FcvsGDIWindow.Pen.Mode := pmNotXor;
  FcvsGDIWindow.Rectangle(FrctBackForm);
  InvalidateRect(FintBackHandle, FrctBackForm, True);
end;

procedure TfrmSnapScreen.tmrPosTimer(Sender: TObject);
var
  pt  : TPoint;
  hwnd: Cardinal;
  rct : TRect;
begin
  tmrPos.Enabled := False;
  GetCursorPos(pt);
  hwnd := WindowFromPoint(pt);
  GetWindowRect(hwnd, rct);
  try
    if (rct.Left = 0) and (rct.Right = 0) then
      Exit;

    if FintBackHandle = hwnd then
      Exit;

    ClearFormRect;
    FcvsGDIWindow.Pen.Style   := psSolid;
    FcvsGDIWindow.Pen.Color   := clRed;
    FcvsGDIWindow.Pen.Width   := 2;
    FcvsGDIWindow.Brush.Style := bsClear;
    FcvsGDIWindow.Rectangle(rct);
  finally
    FintBackHandle := hwnd;
    FrctBackForm   := rct;
    tmrPos.Enabled := True;
  end;
end;

{ 热键相应消息 }
procedure TfrmSnapScreen.WMHOTKEY(var Msg: TWMHOTKEY);
begin
  if Msg.HotKey = c_intHotkeyID then
  begin
    tmrPos.Enabled := False;
    FreeHotkey;
    SetSystemCursor(Screen.Cursors[0], OCR_NORMAL);
    SystemParametersinfo(SPI_SETCURSORS, 0, nil, SPIF_SENDCHANGE);
    ShowMainForm;
  end;
end;

procedure TfrmSnapScreen.mniGDIWindowClick(Sender: TObject);
begin
  SetSystemCursor(Screen.Cursors[0], OCR_HAND);
  HideMainForm;
  tmrPos.Enabled := True;
  RegHotkey;
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

procedure TfrmSnapScreen.imgPos;
begin
  if (imgSnap.Picture.Bitmap.Width < imgSnap.Parent.Width) and (imgSnap.Picture.Bitmap.Height < imgSnap.Parent.Height) then
  begin
    imgSnap.Left := (imgSnap.Parent.Width - imgSnap.Width) div 2;
    imgSnap.Top  := (imgSnap.Parent.Height - imgSnap.Height) div 2;
  end
  else
  begin
    imgSnap.Left := 0;
    imgSnap.Top  := 0;
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
    bmpSnap.Width       := abs(x2 - x1);
    bmpSnap.Height      := abs(y2 - y1);
    bmpSnap.Canvas.CopyRect(bmpSnap.Canvas.ClipRect, cvsTemp, Rect(x1, y1, x2, y2));
    imgSnap.Picture.Bitmap.Assign(bmpSnap);
    imgPos;
  finally
    DeleteDC(cvsTemp.Handle);
    cvsTemp.Free;
    bmpSnap.Free;
  end;
end;

{ DX 截图 }
procedure TfrmSnapScreen.SnapDX(const x1, y1, x2, y2: Integer);
var
  hr                : HRESULT;
  pD3D              : IDirect3D9;
  D3DPP             : D3DPRESENT_PARAMETERS;
  Mode              : TD3DDisplayMode;
  surf              : IDirect3DSurface9;
  pD3DDevice        : IDirect3DDevice9;
  rct               : TRect;
  strTempBmpFileName: String;
begin
  pD3D := Direct3DCreate9(D3D_SDK_VERSION);
  if pD3D = nil then
  begin
    MessageBox(Handle, '获取 DX9 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  zeromemory(@D3DPP, Sizeof(D3DPRESENT_PARAMETERS));
  D3DPP.Windowed         := True;
  D3DPP.SwapEffect       := D3DSWAPEFFECT_DISCARD;
  D3DPP.BackBufferFormat := D3DFMT_UNKNOWN;
  hr                     := pD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Handle, D3DCREATE_SOFTWARE_VERTEXPROCESSING, @D3DPP, pD3DDevice);
  if Failed(hr) then
  begin
    MessageBox(Handle, '获取 DX9 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  { 多个显示屏咋办？ }
  hr := pD3DDevice.GetDisplayMode(0, Mode);
  if Failed(hr) then
  begin
    MessageBox(Handle, '获取 DX9 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  hr := pD3DDevice.CreateOffscreenPlainSurface(Mode.Width, Mode.Height, D3DFMT_A8R8G8B8, D3DPOOL_SCRATCH, surf, nil);
  if Failed(hr) then
  begin
    MessageBox(Handle, '获取 DX9 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  hr := pD3DDevice.GetFrontBufferData(0, surf);
  if Failed(hr) then
  begin
    MessageBox(Handle, '获取 DX9 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  rct                := Rect(x1, y1, x2, y2);
  strTempBmpFileName := TPath.GetTempPath + 'tmp.bmp';
  hr                 := D3DXSaveSurfaceToFile(PChar(strTempBmpFileName), D3DXIFF_BMP, surf, nil, @rct);
  if Failed(hr) then
  begin
    MessageBox(Handle, '获取 DX9 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  imgSnap.Picture.LoadFromFile(strTempBmpFileName);
  imgPos;
  DeleteFile(strTempBmpFileName);
end;

{ DXGI 截图 }
procedure TfrmSnapScreen.SnapDXGI(const x1, y1, x2, y2: Integer);
var
  bmpTemp: TBitmap;
  bmpSnap: TBitmap;
begin
  if FDuplication = nil then
  begin
    MessageBox(Handle, '获取 DXGI 接口失败，无法截图', c_strTitle, MB_ICONQUESTION or MB_OK);
    Exit;
  end;

  if FDuplication.GetFrame then
  begin
    bmpTemp := TBitmap.create;
    bmpSnap := TBitmap.create;
    try
      FDuplication.DrawFrame(bmpTemp);
      bmpSnap.PixelFormat := pf32bit;
      bmpSnap.Width       := abs(x2 - x1);
      bmpSnap.Height      := abs(y2 - y1);
      bmpSnap.Canvas.CopyRect(bmpSnap.Canvas.ClipRect, bmpTemp.Canvas, Rect(x1, y1, x2, y2));
      imgSnap.Picture.Bitmap.Assign(bmpSnap);
    finally
      bmpTemp.Free;
      bmpSnap.Free;
    end;
  end;

end;

end.
