unit db.uCreateVCDll;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, db.uCommon, HookUtils;

{ ���� VC DLL ���� }
procedure PBoxRun_VCDll(const strVCDllFileName: String; pgAll: TPageControl; tsDll: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle; OnVCDllFormDestroyCallback: TNotifyEvent);

{ ���� VC DLL ���� }
procedure FreeVCDllForm(const bExit: Boolean = False);

implementation

function CreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hInstance: HINST; lpParam: Pointer): hWnd; stdcall; external user32 name 'CreateWindowExW';

var
  FOld_CreateWindowExW     : function(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
  FstrVCDialogDllClassName : String = '';
  FstrVCDialogDllWindowName: String = '';
  FPage                    : TPageControl;
  FTabDllForm              : TTabSheet;
  FOldWndProc              : Pointer = nil;
  FstrCreateDllFileName    : String  = '';
  FhVCDllModule            : HMODULE;
  Fvct                     : TVCDllType;
  FlblInfo                 : TLabel;
  FuiShowStyle             : TShowStyle;
  FbExit                   : Boolean = False;

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

function HookCreateWindowExW(dwExStyle: DWORD; lpClassName: LPCWSTR; lpWindowName: LPCWSTR; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer; hWndParent: hWnd; hMenu: hMenu; hins: HINST; lpp: Pointer): hWnd; stdcall;
begin
  { ��ָ���� VC ���� }
  if (lpClassName <> nil) and (lpWindowName <> nil) and (lpWindowName <> '') and (SameText(lpWindowName, FstrVCDialogDllWindowName)) and (SameText(lpWindowName, FstrVCDialogDllWindowName)) then
  begin
    { ���� VC Dlll ���� }
    FPage.ActivePageIndex := 2;                                                                                                               //
    Result                := FOld_CreateWindowExW($00010101, lpClassName, lpWindowName, $96C80000, 0, 0, 0, 0, hWndParent, hMenu, hins, lpp); //
    Application.Tag       := Result;                                                                                                          // ������ VC Dll ������
    Winapi.Windows.SetParent(Result, FTabDllForm.Handle);                                                                                     // ���ø�����Ϊ TabSheet
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                               // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                               // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                               // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                               // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                               // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(Result, False), 0, MF_BYPOSITION);                                                                               // ɾ���ƶ��˵�
    SetWindowPos(Result, FTabDllForm.Handle, 0, 0, FTabDllForm.Width, FTabDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE);                    // ��� Dll �Ӵ���
    FOldWndProc := Pointer(GetWindowlong(Result, GWL_WNDPROC));                                                                               // ��� DLL �����ȡ����ʱ�������嶪ʧ���������
    SetWindowLong(Result, GWL_WNDPROC, LongInt(@NewDllFormProc));                                                                             // ���� DLL ������Ϣ
    PostMessage(Application.MainForm.Handle, WM_NCACTIVATE, 1, 0);                                                                            // ����������
    UnHook(@FOld_CreateWindowExW);                                                                                                            // UNHOOK
    FOld_CreateWindowExW := nil;                                                                                                              // UNHOOK
  end
  else
  begin
    Result := FOld_CreateWindowExW(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hins, lpp);
  end;
end;

{ ���� VC DLL ���� }
procedure PBoxRun_VCDll(const strVCDllFileName: String; pgAll: TPageControl; tsDll: TTabSheet; lblInfo: TLabel; const uiShowStyle: TShowStyle; OnVCDllFormDestroyCallback: TNotifyEvent);
var
  hDll                             : HMODULE;
  ShowVCDllForm                    : Tdb_ShowDllForm_Plugins_VCForm;
  strParamModuleName, strModuleName: PAnsiChar;
  strClassName, strWindowName      : PAnsiChar;
  strIconFileName                  : PAnsiChar;
begin
  if CompareText(FstrCreateDllFileName, strVCDllFileName) = 0 then
    Exit;

  FPage                 := pgAll;
  FTabDllForm           := tsDll;
  FlblInfo              := lblInfo;
  FuiShowStyle          := uiShowStyle;
  FstrCreateDllFileName := strVCDllFileName;
  FbExit                := False;

  { ��ȡ���� }
  hDll := LoadLibrary(PChar(strVCDllFileName));
  try
    ShowVCDllForm := GetProcAddress(hDll, c_strDllExportName);
    ShowVCDllForm(Fvct, strParamModuleName, strModuleName, strIconFileName, strClassName, strWindowName, False);
    FstrVCDialogDllClassName  := String(strClassName);
    FstrVCDialogDllWindowName := String(strWindowName);
    @FOld_CreateWindowExW     := HookProcInModule(user32, 'CreateWindowExW', @HookCreateWindowExW);
  finally
    FreeLibrary(hDll);
  end;

  { ���� VC Dialog Dll ģ̬���� }
  if Fvct = vtDialog then
  begin
    FhVCDllModule := LoadLibrary(PChar(strVCDllFileName));
    ShowVCDllForm := GetProcAddress(FhVCDllModule, c_strDllExportName);
    ShowVCDllForm(Fvct, strParamModuleName, strModuleName, strIconFileName, strClassName, strWindowName, True);
    FreeLibrary(FhVCDllModule);

    { �Ƿ��˳����� }
    if FbExit then
      Application.MainForm.Close;
  end;

  { ���� VC MFC Dll ģ̬���� }
  if Fvct = vtMFC then
  begin
    FhVCDllModule := LoadLibrary(PChar(strVCDllFileName));
    ShowVCDllForm := GetProcAddress(FhVCDllModule, c_strDllExportName);
    ShowVCDllForm(Fvct, strParamModuleName, strModuleName, strIconFileName, strClassName, strWindowName, True);
  end;
end;

{ ���� VC DLL ���� }
procedure FreeVCDllForm(const bExit: Boolean = False);
var
  db_ShowDllForm_Free: procedure;
begin
  FbExit := bExit;

  { �ͷŴ��� }
  db_ShowDllForm_Free := GetProcAddress(FhVCDllModule, 'db_ShowDllForm_Free');
  db_ShowDllForm_Free;

  { ȫ�ֱ�����λ }
  FstrVCDialogDllClassName  := '';
  FstrVCDialogDllWindowName := '';
  FstrCreateDllFileName     := '';
  Application.Tag           := 0;

  { ���滹ԭ }
  FlblInfo.Caption := '';
  if FuiShowStyle = ssButton then
    FPage.ActivePageIndex := 0
  else if FuiShowStyle = ssList then
    FPage.ActivePageIndex := 1;
end;

end.
