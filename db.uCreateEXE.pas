unit db.uCreateEXE;
{
  ���� EXE ����
}

interface

uses Winapi.Windows, Winapi.ShellAPI, System.SysUtils, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls, Winapi.TlHelp32, db.uCommon;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; pg: TPageControl; ts: TTabSheet; lblInfo: TLabel; const UIShowStyle: TShowStyle);

implementation

var
  FstrFileValue       : string;
  FstrEXEFormClassName: string = '';
  FstrEXEFormTitleName: string = '';
  FPageControl        : TPageControl;
  FTabsheet           : TTabSheet;
  FlblInfo            : TLabel;
  FUIShowStyle        : TShowStyle;

  { �����Ƿ�ر� }
function CheckProcessExist(const intPID: DWORD): Boolean;
var
  hSnap: THandle;
  vPE  : TProcessEntry32;
begin
  Result     := False;
  hSnap      := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  vPE.dwSize := SizeOf(TProcessEntry32);
  if Process32First(hSnap, vPE) then
  begin
    while Process32Next(hSnap, vPE) do
    begin
      if vPE.th32ProcessID = intPID then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
  CloseHandle(hSnap);
end;

{ ���̹رպ󣬱�����λ }
procedure EndExeForm(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
var
  intPID: DWORD;
begin
  intPID := Application.MainForm.Tag;
  if intPID = 0 then
    Exit;

  if CheckProcessExist(intPID) then
    Exit;

  FlblInfo.Caption         := '';
  Application.MainForm.Tag := 0;

  if FUIShowStyle = ssButton then
    FPageControl.ActivePageIndex := 0
  else if FUIShowStyle = ssList then
    FPageControl.ActivePageIndex := 1;

  KillTimer(Application.MainForm.Handle, $2000);
end;

{ ���� EXE ���������Ƿ�ɹ����� }
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

    SetWindowPos(hEXEFormHandle, FTabsheet.Handle, 0, 0, FTabsheet.Width, FTabsheet.Height, SWP_NOZORDER OR SWP_NOACTIVATE);                               // ��� Dll �Ӵ���
    Winapi.Windows.SetParent(hEXEFormHandle, FTabsheet.Handle);                                                                                            // ���ø�����Ϊ TabSheet
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
    RemoveMenu(GetSystemMenu(hEXEFormHandle, False), 0, MF_BYPOSITION);                                                                                    // ɾ���ƶ��˵�
    SetWindowLong(hEXEFormHandle, GWL_STYLE, Integer(WS_CAPTION OR WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR WS_SYSMENU));           // $96C80000);                                                                        // $96000000
    SetWindowLong(hEXEFormHandle, GWL_EXSTYLE, Integer(WS_EX_LEFT OR WS_EX_LTRREADING OR WS_EX_DLGMODALFRAME OR WS_EX_WINDOWEDGE OR WS_EX_CONTROLPARENT)); // $00010000);                                                                              // $00010101
    ShowWindow(hEXEFormHandle, SW_SHOWNORMAL);                                                                                                             // ��ʾ����
    Application.MainForm.Height := Application.MainForm.Height + 1;
    Application.MainForm.Height := Application.MainForm.Height - 1;
    FPageControl.ActivePage     := FTabsheet;
    FlblInfo.Caption            := FstrFileValue.Split([';'])[0] + ' - ' + FstrFileValue.Split([';'])[1];
    KillTimer(Application.MainForm.Handle, $1000);
    SetTimer(Application.MainForm.Handle, $2000, 100, @EndExeForm);
  end;
end;

procedure PBoxRun_IMAGE_EXE(const strEXEFileName, strFileValue: String; pg: TPageControl; ts: TTabSheet; lblInfo: TLabel; const UIShowStyle: TShowStyle);
begin
  FPageControl  := pg;
  FTabsheet     := ts;
  FlblInfo      := lblInfo;
  FstrFileValue := strFileValue;
  FUIShowStyle  := UIShowStyle;

  FstrEXEFormClassName := strFileValue.Split([';'])[2];
  FstrEXEFormTitleName := strFileValue.Split([';'])[3];
  SetTimer(Application.MainForm.Handle, $1000, 100, @FindExeForm);

  { ���� EXE ���̣������ش��� }
  ShellExecute(Application.MainForm.Handle, 'Open', PChar(strEXEFileName), nil, nil, SW_HIDE);
end;

end.
