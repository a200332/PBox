unit db.DonateForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

type
  TfrmDonate = class(TForm)
    lbl1: TLabel;
    img1: TImage;
    img2: TImage;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowDonateForm;

implementation

{$R *.dfm}

procedure ShowDonateForm;
begin
  with TfrmDonate.Create(nil) do
  begin
    Position := poScreenCenter;
    ShowModal;
    Free;
  end;
end;

end.
