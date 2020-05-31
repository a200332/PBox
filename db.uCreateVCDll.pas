unit db.uCreateVCDll;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, db.uCommon, HookUtils;

{ 运行 VC DLL 窗体 }
procedure PBoxRun_VCDll(const strVCDllFileName: String; pgAll: TPageControl; tsDll: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle; OnVCDllFormDestroyCallback: TNotifyEvent);

{ 销毁 VC Dialog Dll 窗体 }
procedure FreeVCDialogDllForm(hWnd: THandle; const bExit: Boolean = False);

implementation

var
  FOld_CreateWindowExW     : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
  FstrVCDialogDllClassName : String = '';
  FstrVCDialogDllWindowName: String = '';
  FPage                    : TPageControl;
  FTabDllForm              : TTabSheet;
  FOldWndProc              : Pointer = nil;
  FstrCreateDllFileName    : String  = '';
  FhVCDlgDllFormModule     : HMODULE;

  { 解决 dll 中，当 Dll 窗体获取焦点，主窗体变成非激活状态 }
function NewDllFormProc(hWnd: THandle; msg: UINT; wParam: Cardinal; lParam: Cardinal): Integer; stdcall;
begin
  { 如果子窗体获取焦点时，激活主窗体 }
  if msg = WM_ACTIVATE then
  begin
    if Application.MainForm <> nil then
    begin
      SendMessage(Application.MainForm.Handle, WM_NCACTIVATE, Integer(True), 0);
    end;
  end;

  { 禁止窗体移动 }
  if msg = WM_SYSCOMMAND then
  begin
    if wParam = SC_MOVE + 2 then
    begin
      wParam := 0;
    end;
  end;

  { 调用原来的回调过程 }
  Result := CallWindowProc(FOldWndProc, hWnd, msg, wParam, lParam);
end;

function _CreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { 是指定的 VC 窗体 }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (CompareText(lpClassName, FstrVCDialogDllClassName) = 0) and (CompareText(lpWindowName, FstrVCDialogDllWindowName) = 0) then
  begin
    { 创建 VC Dlll 窗体 }
    FPage.ActivePageIndex := 2;
    Result                := FOld_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp);
    Application.Tag       := Result;                                                                                       // 保存下 VC Dll 窗体句柄
    Winapi.Windows.SetParent(Result, FTabDllForm.Handle);                                                                  // 设置父窗体为 TabSheet
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // 删除移动菜单
    SetWindowPos(Result, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
    FOldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                            // 解决 DLL 窗体获取焦点时，主窗体丢失焦点的问题
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                          // 拦截 DLL 窗体消息
    PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                         // 激活主窗体
    UnHook(@FOld_CreateWindowExW);                                                                                         // UNHOOK
    FOld_CreateWindowExW := nil;                                                                                           // UNHOOK
  end
  else
  begin
    Result := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

procedure FreeVCDlgDllForm(const strVCDllFileName: String; lblInfo: TLabel; const uiShowStyle: TShowStyle);
begin
  FreeLibrary(FhVCDlgDllFormModule);
  FstrVCDialogDllClassName  := '';
  FstrVCDialogDllWindowName := '';

  if Application.Tag = 0 then
  begin
    Application.MainForm.Close;
  end
  else
  begin
    if CompareText(strVCDllFileName, FstrCreateDllFileName) = 0 then
    begin
      { 如果销毁的 Dll，正是先前备份的 Dll，表示 VC Dll 已经被销毁，并且没有 Dll Form 需要创建； }
      Application.Tag       := 0;
      FstrCreateDllFileName := '';
      lblInfo.Caption       := '';
      if uiShowStyle = ssButton then
        FPage.ActivePageIndex := 0
      else if uiShowStyle = ssList then
        FPage.ActivePageIndex := 1;
    end
    else
    begin

    end;
  end;
end;

{ 运行 VC DLL 窗体 }
procedure PBoxRun_VCDll(const strVCDllFileName: String; pgAll: TPageControl; tsDll: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle; OnVCDllFormDestroyCallback: TNotifyEvent);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  vct                              : TVCDllType;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
begin
  if CompareText(FstrCreateDllFileName, strVCDllFileName) = 0 then
    Exit;

  FPage                 := pgAll;
  FTabDllForm           := tsDll;
  FstrCreateDllFileName := strVCDllFileName;

  { 获取参数 }
  hDll := LoadLibrary(PChar(strVCDllFileName));
  try
    ShowVCDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowVCDllForm(vct, strParamModuleName, strModuleName, strIconFileName, strClassName, strWindowName, False);
    FstrVCDialogDllClassName  := String(strClassName);
    FstrVCDialogDllWindowName := String(strWindowName);
    case vct of
      vtDialog:
        @FOld_CreateWindowExW := HookProcInModule(user32, 'CreateWindowExW', @_CreateWindowExW);
      vtMFC:
        ;
    end;
  finally
    FreeLibrary(hDll);
  end;

  { 加载 VC Dialog Dll 模态窗体 }
  if vct = vtDialog then
  begin
    FhVCDlgDllFormModule := LoadLibrary(PChar(strVCDllFileName));
    try
      ShowVCDllForm := GetProcAddress(FhVCDlgDllFormModule, c_strDllExportName);
      ShowVCDllForm(vct, strParamModuleName, strModuleName, strIconFileName, strClassName, strWindowName, True);
    finally
      FreeVCDlgDllForm(strVCDllFileName, lblInfo, uiShowStyle);
    end;
  end;
end;

{ 销毁 VC Dialog Dll 窗体 }
procedure FreeVCDialogDllForm(hWnd: THandle; const bExit: Boolean = False);
begin
  if hWnd = 0 then
    Exit;

  { 是否退出程序 }
  if bExit then
    Application.Tag := 0;

  { 关闭 VC Dialog Dll 窗体 }
  SetWindowLong(hWnd, GWL_WNDPROC, LongInt(FOldWndProc));
  PostMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
