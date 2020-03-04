program PBox;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  Vcl.Forms,
  Vcl.StdCtrls,
  Data.Win.ADODB,
  DB.uBaseForm in 'db.uBaseForm.pas',
  DB.uCommon in 'db.uCommon.pas',
  DB.uCreateDelphiDll in 'db.uCreateDelphiDll.pas',
  DB.uCreateEXE in 'db.uCreateEXE.pas',
  DB.PBoxForm in 'db.PBoxForm.pas' {frmPBox} ,
  DB.ConfigForm in 'db.ConfigForm.pas' {frmConfig} ,
  DB.AddEXE in 'db.AddEXE.pas' {frmAddEXE} ,
  DB.DBConfig in 'db.DBConfig.pas' {DBConfig} ,
  DB.LoginForm in 'db.LoginForm.pas' {frmLogin};

{$R *.res}

var
  strLoginName: string         = '';
  AdoCNN      : TADOConnection = nil;

begin
  OnlyOneRunInstance;
  AdoCNN := TADOConnection.Create(nil);
  CheckLoginForm(strLoginName, AdoCNN);
  Application.Initialize;
  ReportMemoryLeaksOnShutdown   := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPBox, frmPBox);
  frmPBox.FAdoCNN          := AdoCNN;
  frmPBox.lblLogin.Caption := strLoginName;
  Application.Run;
  AdoCNN.Free;

end.
