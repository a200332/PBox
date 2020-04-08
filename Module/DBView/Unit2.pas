unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmSQL = class(TForm)
    mmoSQL: TMemo;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
  private
    FbResult: Boolean;
  public
    { Public declarations }
  end;

function ShowQryForm(var strSQL: string): Boolean;

implementation

{$R *.dfm}

function ShowQryForm(var strSQL: string): Boolean;
begin
  with TfrmSQL.Create(nil) do
  begin
    FbResult := False;
    ShowModal;
    strSQL := mmoSQL.Lines.Text;
    Result := FbResult;
    Free;
  end;
end;

procedure TfrmSQL.btnOKClick(Sender: TObject);
begin
  FbResult := True;
  Close;
end;

end.
