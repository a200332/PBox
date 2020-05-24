unit uFullScreen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, db.uCommon;

type
  TfrmFullScreen = class(TForm)
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    Fcvs       : TCanvas;
    FbMouseDown: Boolean;
    FptOld     : TPoint;
    Fpt1, Fpt2 : TPoint;
    procedure DrawRect(const pt1, pt2: TPoint);
    procedure ClearCanvas;
  end;

procedure ShowFullScreen(DllManFormHandle: THandle);

implementation

{$R *.dfm}

uses uMain;

var
  frmFullScreen: TfrmFullScreen = nil;
  FDllMainForm : TfrmSnapScreen;

procedure ShowFullScreen(DllManFormHandle: THandle);
begin
  frmFullScreen := TfrmFullScreen.Create(nil);
  with frmFullScreen do
  begin
    FDllMainForm := TfrmSnapScreen(GetInstanceFromhWnd(DllManFormHandle));
    FbMouseDown  := False;
    Fcvs         := TCanvas.Create;
    Fcvs.Handle  := GetDC(0);
    Fpt1.X       := 0;
    Fpt1.Y       := 0;
    Fpt2.X       := 0;
    Fpt2.Y       := 0;
    Top          := 0;
    Left         := 0;
    Width        := Screen.DesktopWidth;
    Height       := Screen.DesktopHeight;
    // FormStyle    := fsStayOnTop;
    Show;
  end;
end;

procedure TfrmFullScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DeleteDC(Fcvs.Handle);
  Fcvs.Free;
  Action := caFree;
end;

procedure TfrmFullScreen.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
  begin
    Close;
    FDllMainForm.Show;
  end;
end;

procedure TfrmFullScreen.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  FbMouseDown := True;
//  GetCursorPos(FptOld);
end;

procedure TfrmFullScreen.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
//  if not FbMouseDown then
//    Exit;
//
//  GetCursorPos(pt);
//  DrawRect(FptOld, pt);
end;

procedure TfrmFullScreen.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
//  FbMouseDown := False;
//  GetCursorPos(pt);
//  DrawRect(FptOld, pt);
//
//  ClearCanvas;
//  Close;
//  FDllMainForm.Snap(FptOld.X, FptOld.Y, pt.X, pt.Y);
//  FDllMainForm.Show;
end;

procedure TfrmFullScreen.ClearCanvas;
begin
  if Fpt2.Y = 0 then
    Exit;

  Fcvs.Pen.Mode := pmNotXor;
  Fcvs.Rectangle(Rect(Fpt1.X, Fpt1.Y, Fpt2.X, Fpt2.Y));
end;

procedure TfrmFullScreen.DrawRect(const pt1, pt2: TPoint);
begin
  ClearCanvas;
  Fcvs.Pen.Color   := clBlack;
  Fcvs.Pen.Width   := 4;
  Fcvs.Brush.Style := bsClear;
  Fcvs.Rectangle(Rect(pt1.X, pt1.Y, pt2.X, pt2.Y));
  Fpt1 := pt1;
  Fpt2 := pt2;
end;

end.
