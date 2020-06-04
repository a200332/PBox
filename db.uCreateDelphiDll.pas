unit db.uCreateDelphiDll;
{
  ���� Delphi DLL ����
}

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, SysUtils, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, Vcl.Controls, Data.Win.ADODB, db.uCommon;

{ ���� DELPHI DLL ���� }
procedure PBoxRun_DelphiDll(const strPEFileName: String; tsDllForm: TTabSheet; ADOCNN: TADOConnection; OnDelphiDllFormDestroyCallback: TNotifyEvent);

{ ���û��������������ǿ�ƹر� DELPHI DLL ���� }
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

{ DLL �����ͷ���ϣ��ͷ���Դ��������λ }
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

{ ���û��������������ǿ�ƹر� DELPHI DLL ����ʱ }
procedure FreeDelphiDllForm;
begin
  if FhDelphiFormDll = 0 then
    Exit;

  { ���͹ر� Delphi DLL ������Ϣ }
  PostMessage(FhDelphiFormDll, WM_SYSCOMMAND, SC_CLOSE, 0);

  { �ȴ�����ر� }
  while True do
  begin
    Application.ProcessMessages;
    if FreeAndRest then
      Break;
  end;
end;

{ �û�����������˹رհ�ťʱ����ʱʱ��飬Delphi DLL �����Ƿ�ر��ˣ�����ر��ˣ�������λ }
procedure tmrCheckDelphiFormDllDestory(hWnd: hWnd; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
begin
  FreeAndRest;
end;

{ �ҽ� ADOCNN }
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

{ ���� DELPHI DLL ���� }
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
  FhDelphiFormDll                 := FDelphiDllForm.Handle;                                                                       // �����´�����
  FOnDelphiDllFormDestroyCallback := OnDelphiDllFormDestroyCallback;                                                              // Dll ��������ʱ���ص��������¼�
  CheckDllFormDatabase(FDelphiDllForm, ADOCNN);                                                                                   // ���ݿ���
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����С�˵�
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����С���˵�
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����󻯲˵�
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ָ��߲˵�
  SetWindowPos(FDelphiDllForm.Handle, tsDllForm.Handle, 0, 0, tsDllForm.Width, tsDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� Dll �Ӵ���
  Winapi.Windows.SetParent(FDelphiDllForm.Handle, tsDllForm.Handle);                                                              // ���ø�����Ϊ TabSheet
  RemoveMenu(GetSystemMenu(FDelphiDllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ƶ��˵�
  FDelphiDllForm.Show;                                                                                                            // ��ʾ Dll �Ӵ���
  tsDllForm.PageControl.ActivePage := tsDllForm;                                                                                  // �����
  FbDelphiFormDllDestory           := False;                                                                                      // Delphi DLL �����Ƿ�������
  SetTimer(Application.MainForm.Handle, $3000, 100, @tmrCheckDelphiFormDllDestory);                                               // ��ʱ��� Delphi DLL �����Ƿ�������
end;

end.
