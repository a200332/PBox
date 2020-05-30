unit db.uCreateDelphiDll;
{
  创建 Delphi DLL 窗体
}

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, Vcl.Controls, Data.Win.ADODB, db.uCommon;

{ 运行 DELPHI DLL 窗体 }
procedure PBoxRun_DelphiDll(var DllForm: TForm; const strPEFileName: String; tsDllForm: TTabSheet; ADOCNN: TADOConnection; OnDelphiDllFormDestroyCallback: TNotifyEvent);

{ 关闭 DELPHI DLL 窗体 }
procedure CloseDelphiDllForm;

implementation

var
  FOnDelphiDllFormDestroyCallback: TNotifyEvent = nil;
  FhDelphiFormDll                : THandle      = 0;
  FbDelphiFormDllDestory         : Boolean      = False;

  { 关闭 DELPHI DLL 窗体 }
procedure CloseDelphiDllForm;
begin
  if FhDelphiFormDll = 0 then
    Exit;

  { 发送关闭 Delphi Dll 窗体消息 }
  PostMessage(FhDelphiFormDll, WM_SYSCOMMAND, SC_CLOSE, 0);

  { 等待窗体关闭 }
  while True do
  begin
    Application.ProcessMessages;
    if FbDelphiFormDllDestory then
      Break
  end;
end;

{ 时时检查，Delphi Dll 窗体是否关闭了，如果关闭了，变量复位 }
procedure tmrCheckDelphiFormDllDestory(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  if not IsWindowVisible(FhDelphiFormDll) then
  begin
    KillTimer(Application.MainForm.Handle, $3000);
    FOnDelphiDllFormDestroyCallback(nil);
    FbDelphiFormDllDestory := True;
    FhDelphiFormDll        := 0;
  end;
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
procedure PBoxRun_DelphiDll(var DllForm: TForm; const strPEFileName: String; tsDllForm: TTabSheet; ADOCNN: TADOConnection; OnDelphiDllFormDestroyCallback: TNotifyEvent);
var
  hLib                             : HMODULE;
  ShowDllForm                      : Tdb_ShowDllForm_Plugins_Delphi;
  frm                              : TFormClass;
  strParamModuleName, strModuleName: PAnsiChar;
  strIconFileName                  : PAnsiChar;
begin
  hLib        := LoadLibrary(PChar(strPEFileName));
  ShowDllForm := GetProcAddress(hLib, c_strDllExportName);
  ShowDllForm(frm, strParamModuleName, strModuleName, strIconFileName);
  DllForm                         := frm.Create(nil);
  DllForm.BorderIcons             := [biSystemMenu];
  DllForm.Position                := poDesigned;
  DllForm.BorderStyle             := bsSingle;
  DllForm.Color                   := clWhite;
  DllForm.Anchors                 := [akLeft, akTop, akRight, akBottom];
  DllForm.Tag                     := hLib;                                                                                 // 将 hLib 放在 DllForm 的 tag 中，卸载时需要用到
  FhDelphiFormDll                 := DllForm.Handle;                                                                       // 保存下窗体句柄
  FOnDelphiDllFormDestroyCallback := OnDelphiDllFormDestroyCallback;                                                       // Dll 窗体销毁时，回调主窗体事件
  CheckDllFormDatabase(DllForm, ADOCNN);                                                                                   // 数据库检查
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除移动菜单
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除大小菜单
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除最小化菜单
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除最大化菜单
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除分割线菜单
  SetWindowPos(DllForm.Handle, tsDllForm.Handle, 0, 0, tsDllForm.Width, tsDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // 最大化 Dll 子窗体
  Winapi.Windows.SetParent(DllForm.Handle, tsDllForm.Handle);                                                              // 设置父窗体为 TabSheet
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // 删除移动菜单
  DllForm.Show;                                                                                                            // 显示 Dll 子窗体
  tsDllForm.PageControl.ActivePage := tsDllForm;                                                                           // 激活窗口
  FbDelphiFormDllDestory           := False;                                                                               // Delphi DLL 窗体是否销毁了
  SetTimer(Application.MainForm.Handle, $3000, 100, @tmrCheckDelphiFormDllDestory);                                        // 定时检查 Delphi DLL 窗体是否被销毁了
end;

end.
