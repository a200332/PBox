unit uWaittingForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, db.uCommon;

type
  TfrmWaitting = class(TForm)
    lblTip: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowWaittingForm;
procedure FreeWaittingForm;

implementation

var
  frmWaitting: TfrmWaitting;

procedure ShowWaittingForm;
var
  fMain: TForm;
begin
  if frmWaitting = nil then
    frmWaitting := TfrmWaitting.Create(nil);

  fMain            := GetMainFormApplication.MainForm;
  frmWaitting.Left := fMain.Left + (fMain.Width - frmWaitting.Width) div 2;
  frmWaitting.Top  := fMain.Top + (fMain.Height - frmWaitting.Height) div 2;
  frmWaitting.Show;
  DelayTime(100);
end;

procedure FreeWaittingForm;
begin
  frmWaitting.Close;
  frmWaitting := nil;
end;
{$R *.dfm}

procedure TfrmWaitting.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
