unit db.uCreateDelphiDll;
{
  ���� Delphi DLL ����
}

interface

uses Winapi.Windows, Winapi.Messages, System.Classes, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, Vcl.Controls, Data.Win.ADODB, db.uCommon;

{ ���� DELPHI DLL ���� }
procedure PBoxRun_DelphiDll(var DllForm: TForm; const strPEFileName: String; tsDllForm: TTabSheet; ADOCNN: TADOConnection; OnDelphiDllFormDestroyCallback: TNotifyEvent);

{ �ر� DELPHI DLL ���� }
procedure CloseDelphiDllForm;

implementation

var
  FOnDelphiDllFormDestroyCallback: TNotifyEvent = nil;
  FhDelphiFormDll                : THandle      = 0;
  FbDelphiFormDllDestory         : Boolean      = False;

  { �ر� DELPHI DLL ���� }
procedure CloseDelphiDllForm;
begin
  if FhDelphiFormDll = 0 then
    Exit;

  { ���͹ر� Delphi Dll ������Ϣ }
  PostMessage(FhDelphiFormDll, WM_SYSCOMMAND, SC_CLOSE, 0);

  { �ȴ�����ر� }
  while True do
  begin
    Application.ProcessMessages;
    if FbDelphiFormDllDestory then
      Break
  end;
end;

{ ʱʱ��飬Delphi Dll �����Ƿ�ر��ˣ�����ر��ˣ�������λ }
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
  DllForm.Tag                     := hLib;                                                                                 // �� hLib ���� DllForm �� tag �У�ж��ʱ��Ҫ�õ�
  FhDelphiFormDll                 := DllForm.Handle;                                                                       // �����´�����
  FOnDelphiDllFormDestroyCallback := OnDelphiDllFormDestroyCallback;                                                       // Dll ��������ʱ���ص��������¼�
  CheckDllFormDatabase(DllForm, ADOCNN);                                                                                   // ���ݿ���
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ƶ��˵�
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����С�˵�
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����С���˵�
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ����󻯲˵�
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ָ��߲˵�
  SetWindowPos(DllForm.Handle, tsDllForm.Handle, 0, 0, tsDllForm.Width, tsDllForm.Height, SWP_NOZORDER OR SWP_NOACTIVATE); // ��� Dll �Ӵ���
  Winapi.Windows.SetParent(DllForm.Handle, tsDllForm.Handle);                                                              // ���ø�����Ϊ TabSheet
  RemoveMenu(GetSystemMenu(DllForm.Handle, False), 0, MF_BYPOSITION);                                                      // ɾ���ƶ��˵�
  DllForm.Show;                                                                                                            // ��ʾ Dll �Ӵ���
  tsDllForm.PageControl.ActivePage := tsDllForm;                                                                           // �����
  FbDelphiFormDllDestory           := False;                                                                               // Delphi DLL �����Ƿ�������
  SetTimer(Application.MainForm.Handle, $3000, 100, @tmrCheckDelphiFormDllDestory);                                        // ��ʱ��� Delphi DLL �����Ƿ�������
end;

end.
