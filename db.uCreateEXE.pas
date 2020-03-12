unit db.uCreateEXE;
{
  创建 EXE 窗体
}

interface

uses Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls, db.uCommon;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; ts: TTabSheet; lblInfo: TLabel; OnPEProcessDestroyCallback: TNotifyEvent);

implementation

var
  FstrFileValue              : string;
  FstrEXEFormClassName       : string = '';
  FstrEXEFormTitleName       : string = '';
  FTabsheet                  : TTabSheet;
  FlblInfo                   : TLabel;
  FOnPEProcessDestroyCallback: TNotifyEvent;

  { 进程关闭后，变量复位 }
procedure EndExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  intPID: DWORD;
begin
  intPID := Application.MainForm.Tag;
  if intPID = 0 then
    Exit;

  if CheckProcessExist(intPID) then
    Exit;

  KillTimer(Application.MainForm.Handle, $2000);
  FOnPEProcessDestroyCallback(nil);
end;

{ 查找 EXE 的主窗体是否成功创建 }
procedure FindExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  hEXEFormHandle: THandle;
  intPID        : DWORD;
begin
  if (Trim(FstrEXEFormClassName) = '') and (Trim(FstrEXEFormTitleName) <> '') then
    hEXEFormHandle := FindWindow(nil, PChar(FstrEXEFormTitleName))
  else if (Trim(FstrEXEFormClassName) <> '') and (Trim(FstrEXEFormTitleName) = '') then
    hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), nil)
  else
    hEXEFormHandle := FindWindow(PChar(FstrEXEFormClassName), PChar(FstrEXEFormTitleName));

  if hEXEFormHandle <> 0 then
  begin
    GetWindowThreadProcessId(hEXEFormHandle, intPID);
    Application.MainForm.Tag := intPID;

    SetWindowPos(hEXEFormHandle, FTabsheet.Handle, 0, 0, FTabsheet.Width, FTabsheet.Height, SWP_NOZORDER OR SWP_NOACTIVATE);                               // 最大化 Dll 子窗体
    Winapi.Windows.SetParent(hEXEFormHandle, FTabsheet.Handle);                                                                                            // 设置父窗体为 TabSheet
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // 删除移动菜单
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // 删除移动菜单
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // 删除移动菜单
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // 删除移动菜单
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // 删除移动菜单
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // 删除移动菜单
    SetWindowLong(hEXEFormHandle, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU));           // $96C80000);                                                                        // $96000000
    SetWindowLong(hEXEFormHandle, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)); // $00010000);                                                                              // $00010101
    ShowWindow(hEXEFormHandle, SW_SHOWNORMAL);                                                                                                             // 显示窗体
    Application.MainForm.Height      := Application.MainForm.Height + 1;
    Application.MainForm.Height      := Application.MainForm.Height - 1;
    FTabsheet.PageControl.ActivePage := FTabsheet;
    FlblInfo.Caption                 := FstrFileValue.Split([';'])[0] + ' - ' + FstrFileValue.Split([';'])[1];
    KillTimer(Application.MainForm.Handle, $1000);
    SetTimer(Application.MainForm.Handle, $2000, 100, @EndExeForm);
  end;
end;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; ts: TTabSheet; lblInfo: TLabel; OnPEProcessDestroyCallback: TNotifyEvent);
begin
  FTabsheet                   := ts;
  FlblInfo                    := lblInfo;
  FstrFileValue               := strFileValue;
  FOnPEProcessDestroyCallback := OnPEProcessDestroyCallback;

  FstrEXEFormClassName := strFileValue.Split([';'])[2];
  FstrEXEFormTitleName := strFileValue.Split([';'])[3];
  SetTimer(Application.MainForm.Handle, $1000, 100, @FindExeForm);

  { 删除插件配置文件中关于窗体位置的配置信息 }
  CheckPlugInConfigSize;

  { 创建 EXE 进程，并隐藏窗体 }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

end.
