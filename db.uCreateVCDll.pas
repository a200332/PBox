unit db.uCreateVCDll;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, db.uCommon, HookUtils;

{ ���� VC DLL ���� }
procedure PBoxRun_VCDll(const strVCDllFileName: String; pgAll: TPageControl; tsDll: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle; OnVCDllFormDestroyCallback: TNotifyEvent);

{ ���� VC Dialog Dll ���� }
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

  { ��� dll �У��� Dll �����ȡ���㣬�������ɷǼ���״̬ }
function NewDllFormProc(hWnd: THandle; msg: UINT; wParam: Cardinal; lParam: Cardinal): Integer; stdcall;
begin
  { ����Ӵ����ȡ����ʱ������������ }
  if msg = WM_ACTIVATE then
  begin
    if Application.MainForm <> nil then
    begin
      SendMessage(Application.MainForm.Handle, WM_NCACTIVATE, Integer(True), 0);
    end;
  end;

  { ��ֹ�����ƶ� }
  if msg = WM_SYSCOMMAND then
  begin
    if wParam = SC_MOVE + 2 then
    begin
      wParam := 0;
    end;
  end;

  { ����ԭ���Ļص����� }
  Result := CallWindowProc(FOldWndProc, hWnd, msg, wParam, lParam);
end;

function _CreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { ��ָ���� VC ���� }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (CompareText(lpClassName, FstrVCDialogDllClassName) = 0) and (CompareText(lpWindowName, FstrVCDialogDllWindowName) = 0) then
  begin
    { ���� VC Dlll ���� }
    FPage.ActivePageIndex := 2;
    Result                := FOld_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp);
    Application.Tag       := Result;                                                                                       // ������ VC Dll ������
    Winapi.Windows.SetParent(Result, FTabDllForm.Handle);                                                                  // ���ø�����Ϊ TabSheet
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                            // ɾ���ƶ��˵�
    SetWindowPos(Result, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� Dll �Ӵ���
    FOldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                            // ��� DLL �����ȡ����ʱ�������嶪ʧ���������
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                          // ���� DLL ������Ϣ
    PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                         // ����������
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
      { ������ٵ� Dll��������ǰ���ݵ� Dll����ʾ VC Dll �Ѿ������٣�����û�� Dll Form ��Ҫ������ }
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

{ ���� VC DLL ���� }
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

  { ��ȡ���� }
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

  { ���� VC Dialog Dll ģ̬���� }
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

{ ���� VC Dialog Dll ���� }
procedure FreeVCDialogDllForm(hWnd: THandle; const bExit: Boolean = False);
begin
  if hWnd = 0 then
    Exit;

  { �Ƿ��˳����� }
  if bExit then
    Application.Tag := 0;

  { �ر� VC Dialog Dll ���� }
  SetWindowLong(hWnd, GWL_WNDPROC, LongInt(FOldWndProc));
  PostMessage(hWnd, WM_SYSCOMMAND, SC_CLOSE, 0);
end;

end.
