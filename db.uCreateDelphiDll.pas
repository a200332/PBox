unit db.uCreateDelphiDll;
{
  创建 Delphi DLL 窗体
}

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, SysUtils, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, Vcl.Controls, Data.Win.ADODB, db.uCommon;

{ 运行 DELPHI DLL 窗体 }
procedure PBoxRun_DelphiDll(const strPEFileName: String; tsDllForm: TTabSheet; ADOCNN: TADOConnection; OnDelphiDllFormDestroyCallback: TNotifyEvent);

{ 非用户触发，程序调用强制关闭 DELPHI DLL 窗体 }
procedure FreeDelphiDllForm;

implementation

var
  FOnDelphiDllFormDestroyCallback: TNotifyEvent = nil;
  FhDelphiFormDll                : THandle      = 0;
  FbDelphiFormDllDestory         : Boolean      = False;
  FhDelphiDllModule              : HMODULE      = 0;
  FDelphiDllForm                 : TForm        = nil;

procedure DLog(const strLog: String);
begin
  OutputDebugString(PChar(Format('%s  %s', [FormatDateTime('YYYY-MM-DD hh:mm:ss', Now), strLog])));
end;

{ DLL 窗体释放完毕，释放资源并变量复位 }
function FreeAndRest: Boolean;
begin
  Result := False;
  if not IsWindowVisible(FhDelphiFormDll) then
  begin
    KillTimer(Application.MainForm.Handle, $3000);
    FreeLibrary(FhDelphiDllModule);
    g_bCreateNewDllForm := False;
    FOnDelphiDllFormDestroyCallback(nil);
    FDelphiDllForm         := nil;
    FbDelphiFormDllDestory := True;
    FhDelphiFormDll        := 0;
    Result                 := True;
  end;
end;

{ 非用户触发，程序调用强制关闭 DELPHI DLL 窗体时 }
procedure FreeDelphiDllForm;
begin
  if FhDelphiFormDll = 0 then
    Exit;

  { 发送关闭 Delphi DLL 窗体消息 }
  PostMessage(FhDelphiFormDll, WM_SYSCOMMAND, SC_CLOSE, 0);

  { 等待窗体关闭 }
  while True do
  begin
    Application.ProcessMessages;
    if FreeAndRest then
      Break;
  end;
end;

{ 用户触发，点击了关闭按钮时，需时时检查，Delphi DLL 窗体是否关闭了，如果关闭了，变量复位 }
procedure tmrCheckDelphiFormDllDestory(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  FreeAndRest;
end;

{ 挂接 ADOCNN }
procedure CheckDllFormDatabase(DllForm: TForm; ADOCNN: TADOConnection);
var
  I: Integer;
begin
  if not ADOCNN.Connected then
    Exit;

  for I := 0 to DllForm.ComponentCount - 1 do
  begin
    if DllForm.Components[I] is TADOQuery then
    begin
      TADOQuery(DllForm.Components[I]).Connection := ADOCNN;
    end;
  end;
end;

{ 运行 DELPHI DLL 窗体 }
procedure PBoxRun_DelphiDll(const strPEFileName: String; tsDllForm: TTabSheet; ADOCNN: TADOConnection; OnDelphiDllFormDestroyCallback: TNotifyEvent);
var
  ShowDllForm                      : Tdb_ShowDllForm_Plugins_Delphi;
  frm                              : TFormClass;
  strParamModuleName, strModuleName: PAnsiChar;
  strIconFileName                  : PAnsiChar;
begin
  FhDelphiDllModule := LoadLibrary(PChar(strPEFileName));
  ShowDllForm       := GetProcAddress(FhDelphiDllModule, c_strDllExportName);
  ShowDllForm(frm, strParamModuleName, strModuleName, strIconFileName);
  FDelphiDllForm                  := frm.Create(nil);
  FDelphiDllForm.BorderIcons      := [biSystemMenu];
  FDelphiDllForm.Position         := poDesigned;
  FDelphiDllForm.BorderStyle      := bsSingle;
  FDelphiDllForm.Color            := clWhite;
  FDelphiDllForm.Anchors          := [akLeft, akTop, akRight, akBottom];
  FhDelphiFormDll                 := FDelphiDllForm.Handle;                                                                       // 保存下窗体句柄
  FOnDelphiDllFormDestroyCallback := OnDelphiDllFormDestroyCallback;                                                              // Dll 窗体销毁时，回调主窗体事件
  CheckDllFormDatabase(FDelphiDllForm, ADOCNN);                                                                                   // 数据库检查
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除移动菜单
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除大小菜单
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除最小化菜单
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除最大化菜单
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除分割线菜单
  SetWindowPos(FDelphiDllForm.Handle, tsDllForm.Handle, 0, 0, tsDllForm.Width, tsDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(FDelphiDllForm.Handle, tsDllForm.Handle);                                                              // 设置父窗体为 TabSheet
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除移动菜单
  FDelphiDllForm.Show;                                                                                                            // 显示 Dll 子窗体
  tsDllForm.PageControl.ActivePage := tsDllForm;                                                                                  // 激活窗口
  FbDelphiFormDllDestory           := False;                                                                                      // Delphi DLL 窗体是否销毁了
  SetTimer(Application.MainForm.Handle, $3000, 100, @tmrCheckDelphiFormDllDestory);                                               // 定时检查 Delphi DLL 窗体是否被销毁了
end;

end.
