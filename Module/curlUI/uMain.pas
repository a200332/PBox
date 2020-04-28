unit uMain;
{$WARN UNIT_PLATFORM OFF}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.Win.Registry, System.IniFiles, System.Types, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.FileCtrl, Vcl.Clipbrd, Vcl.StdCtrls, db.uCommon;

type
  TfrmCurlUI = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { private declarations }
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmCurlUI;
  strParentModuleName     := '网络管理';
  strModuleName           := 'CurlUI';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmCurlUI.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
