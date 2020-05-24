unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, db.uCommon;

type
  TfrmSnapScreen = class(TForm)
    btnGDI: TButton;
    btnDX: TButton;
    tmrPos: TTimer;
    scrlbxSnapScreen: TScrollBox;
    imgSnap: TImage;
    procedure btnGDIClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FintBackTop, FintBackLeft: Integer;
  public
    procedure Snap(const x1, y1, x2, y2: Integer);
    procedure ShowDllMainForm;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

uses uFullScreen;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSnapScreen;
  strParentModuleName     := 'Í¼ÐÎÍ¼Ïñ';
  strModuleName           := 'ÆÁÄ»½ØÍ¼';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmSnapScreen.btnGDIClick(Sender: TObject);
begin
  ShowFullScreen(Handle);
  FintBackTop                          := GetMainFormApplication.MainForm.Top;
  FintBackLeft                         := GetMainFormApplication.MainForm.Left;
  GetMainFormApplication.MainForm.Top  := -10000;
  GetMainFormApplication.MainForm.Left := -10000;
end;

procedure TfrmSnapScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmSnapScreen.ShowDllMainForm;
begin
  GetMainFormApplication.MainForm.Top  := FintBackTop;
  GetMainFormApplication.MainForm.Left := FintBackLeft;
end;

procedure TfrmSnapScreen.Snap(const x1, y1, x2, y2: Integer);
var
  cvs: TCanvas;
  bmp: TBitmap;
begin
  cvs := TCanvas.Create;
  bmp := TBitmap.Create;
  try
    cvs.Handle      := GetDC(0);
    bmp.PixelFormat := pf32bit;
    bmp.Width       := Abs(x2 - x1);
    bmp.Height      := Abs(y2 - y1);
    bmp.Canvas.CopyRect(bmp.Canvas.ClipRect, cvs, Rect(x1, y1, x2, y2));
    imgSnap.Picture.Bitmap.Assign(bmp);
  finally
    DeleteDC(cvs.Handle);
    cvs.Free;
    bmp.Free;
  end;
end;

end.
