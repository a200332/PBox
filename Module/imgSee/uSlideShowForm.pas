unit uSlideShowForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, PicShow, db.uCommon, Vcl.ExtCtrls;

type
  TfrmSlideShow = class(TForm)
    tmrSlideShow: TTimer;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrSlideShowTimer(Sender: TObject);
    procedure imgDBLClick(Sender: TObject);
  private
    PicShow  : TPicShow;
    Pictures : TStringList;
    FintIndex: Integer;
    FintCount: Integer;
  end;

procedure ShowSlideImage(const strFolder: string);

implementation

uses uMainForm;

{$R *.dfm}

var
  frm: TfrmSlideShow;

procedure ShowSlideImage(const strFolder: string);
var
  rct      : TRect;
  lstStyles: TStringList;
begin
  rct := GetMainFormApplication.MainForm.Monitor.WorkareaRect;

  frm := TfrmSlideShow.Create(nil);
  with frm do
  begin
    BorderStyle := bsNone;
    Top         := rct.Top;
    Left        := rct.Left;
    Width       := rct.Width;
    Height      := rct.Height;
    FormStyle   := fsStayOnTop;

    lstStyles           := TStringList.Create;
    PicShow             := TPicShow.Create(frm);
    PicShow.Parent      := frm;
    PicShow.Align       := alClient;
    PicShow.BgMode      := bmNone;
    PicShow.Threaded    := True;
    PicShow.Stretch     := True;
    PicShow.Manual      := False;
    PicShow.Step        := 5;
    PicShow.Delay       := 30;
    PicShow.ExactTiming := True;
    PicShow.OnDblClick  := imgDBLClick;
    PicShow.GetStyleNames(lstStyles);
    FintCount := lstStyles.Count;
    lstStyles.Free;

    Pictures := TStringList.Create;
    TfrmImageSee.GetAllImage(strFolder, Pictures);
    ShowCursor(False);
    frm.Show;

    FintIndex := 0;
    PicShow.Picture.LoadFromFile(Pictures.Strings[FintIndex]);
    PicShow.Execute;
  end;
end;

procedure TfrmSlideShow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrSlideShow.Enabled := False;
  ShowCursor(True);
  Pictures.Free;
  PicShow.Free;
  Action := caFree;
end;

procedure TfrmSlideShow.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmSlideShow.imgDBLClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSlideShow.tmrSlideShowTimer(Sender: TObject);
begin
  Inc(FintIndex);
  if FintIndex >= Pictures.Count - 1 then
    FintIndex := 0;

  PicShow.Style := Random(FintCount);
  PicShow.Picture.LoadFromFile(Pictures.Strings[FintIndex]);
  PicShow.Execute;
end;

end.
