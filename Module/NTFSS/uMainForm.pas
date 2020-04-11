unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IOUtils, System.Types, System.Diagnostics, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.ExtCtrls, SynSQLite3Static, SynSQLite3, SynCommons, db.uCommon;

type
  TfrmNTFSS = class(TForm)
    lvData: TListView;
    lblFilter: TLabel;
    lblSearchTip: TLabel;
    srchbxFilter: TSearchBox;
    tmrStart: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrStartTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvDataData(Sender: TObject; Item: TListItem);
  private
    FhRootHandle  : THandle;
    FstrDriver    : String;
    FbFinished    : Boolean;
    FbTerminated01: Boolean;
    FbTerminated02: Boolean;
    FSLDB         : TSQLite3LibraryStatic;
    FDB           : TSQLite3DB;
    FintCount     : UInt64;
    { NTFS �����ļ����� }
    procedure SearchFileNTFS;
    { ��ȡ�ļ���Ϣ }
    procedure GetUSNFileInfo(UsnInfo: PUSN; const strDriver: string);
    { ���� Sqlite ���ݿ� }
    procedure CreateSqliteDB;
    { ���� Sqlite ��ṹ }
    procedure CreateSqliteTable(const strTableName: string);
    { �� Sqlite ��������� }
    procedure InsertDataSqlite(const strTableName: string; const strFileName: String; const intFileID, intFilePID: UInt64);
    { ɾ�� Sqlite ���ݿ� }
    procedure DeleteSqlite;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmNTFSS;
  strParentModuleName     := 'ϵͳ����';
  strModuleName           := 'NTFS �ļ�����';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

{ ���� Sqlite ���ݿ� }
procedure TfrmNTFSS.CreateSqliteDB;
var
  strDBFileName: String;
begin
  strDBFileName := ChangeFileExt(ParamStr(0), '.db');
  if FileExists(strDBFileName) then
    DeleteFile(strDBFileName);

  FSLDB := TSQLite3LibraryStatic.Create;
  FSLDB.open_v2(PUTF8Char(AnsiString(strDBFileName)), &FDB, SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE or SQLITE_OPEN_NOMUTEX or SQLITE_OPEN_SHAREDCACHE, nil);
end;

{ ���� Sqlite ��ṹ }
procedure TfrmNTFSS.CreateSqliteTable(const strTableName: string);
var
  strDBFileName: String;
  strSQL       : string;
begin
  strDBFileName := ChangeFileExt(ParamStr(0), '.db');
  if not FileExists(strDBFileName) then
    CreateSqliteDB;

  strSQL := 'CREATE TABLE ' + strTableName + ' ([ID] INTEGER PRIMARY KEY, [FileName] VARCHAR (255), [FileID] INTEGER NULL, [FilePID] INTEGER NULL, [CreateTime] DateTime, [ModifyTime] DateTime, [FullName] VARCHAR (255));';
  FSLDB.Execute(FDB, PAnsiChar(AnsiString(strSQL)), nil, nil, nil);
end;

{ �� Sqlite ��������� }
procedure TfrmNTFSS.InsertDataSqlite(const strTableName: string; const strFileName: String; const intFileID, intFilePID: UInt64);
var
  strSQL: string;
begin
  strSQL := 'INSERT INTO ' + strTableName + ' (FileName, FileID, FilePID) VALUES(' + QuotedStr(strFileName) + ', ' + UIntToStr(intFileID) + ', ' + UIntToStr(intFilePID) + ')';
  FSLDB.Execute(FDB, PAnsiChar(AnsiString(strSQL)), nil, nil, nil);
end;

{ ɾ�� Sqlite ���ݿ� }
procedure TfrmNTFSS.DeleteSqlite;
var
  strDBFileName: String;
begin
  if FSLDB <> nil then
  begin
    FSLDB.close(FDB);
    FSLDB.Free;
  end;

  strDBFileName := ChangeFileExt(ParamStr(0), '.db');
  if FileExists(strDBFileName) then
    DeleteFile(strDBFileName);
end;

procedure TfrmNTFSS.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not FbTerminated02 then
  begin
    FbTerminated01 := True;
    CanClose       := False;
    Exit;
  end;

  CanClose := True;
end;

procedure TfrmNTFSS.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DeleteSqlite;
  Action := caFree;
end;

procedure TfrmNTFSS.tmrStartTimer(Sender: TObject);
var
  lstDriver  : System.Types.TStringDynArray;
  strDriver  : String;
  hRootHandle: THandle;
  intLen     : DWORD;
  sysFlags   : DWORD;
  strNTFS    : array [0 .. 255] of Char;
  Timer      : TStopwatch;
begin
  tmrStart.Enabled := False;
  FbTerminated01   := False;
  FbTerminated02   := False;
  FintCount        := 0;

  CreateSqliteDB;
  lstDriver := TDirectory.GetLogicalDrives;
  for strDriver in lstDriver do
  begin
    { �ж��Ƿ��� NTFS ��ʽ���� }
    if not GetVolumeInformation(PChar(strDriver), nil, 0, nil, intLen, sysFlags, strNTFS, 256) then
      Continue;

    if not SameText(strNTFS, 'NTFS') then
      Continue;

    { NTFS �����ļ����� }
    hRootHandle := CreateFile(PChar('\\.\' + strDriver[1] + strDriver[2]), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    if hRootHandle = ERROR_INVALID_HANDLE then
      Continue;

    try
      lblSearchTip.Caption := Format('�������� %s �̣����Ժ򡤡���������', [strDriver]);
      lblSearchTip.Left    := (lblSearchTip.Parent.Width - lblSearchTip.Width) div 2;
      CreateSqliteTable(strDriver[1] + '_Table');
      FSLDB.Execute(FDB, 'BEGIN TRANSACTION;', nil, nil, nil);
      Timer        := TStopwatch.StartNew;
      FhRootHandle := hRootHandle;
      FstrDriver   := strDriver;
      FbFinished   := False;
      TThread.CreateAnonymousThread(SearchFileNTFS).Start;

      { �ȴ��ļ�������� }
      while True do
      begin
        Application.ProcessMessages;

        { ������ֹ���� }
        if FbTerminated01 then
        begin
          FbTerminated02 := True;
          close;
          Exit;
        end;

        if FbFinished then
          Break
      end;

      FSLDB.Execute(FDB, 'COMMIT TRANSACTION;', nil, nil, nil);
      Caption := Caption + '; ' + Format('���� %s ��ʱ %d ��', [strDriver, Timer.Elapsed.Seconds]);
    finally
      CloseHandle(hRootHandle);
    end;
  end;

  { ȫ��������� }
  lblSearchTip.Caption := '';
  FbTerminated02       := True;
  lblFilter.Visible    := True;
  srchbxFilter.Visible := True;
  lvData.Items.Count   := FintCount;
  Caption              := Caption + '; ' + Format('�ܼ�¼����%u', [FintCount]);
end;

procedure TfrmNTFSS.FormResize(Sender: TObject);
begin
  if lblSearchTip.Caption <> '' then
    lblSearchTip.Left := (lblSearchTip.Parent.Width - lblSearchTip.Width) div 2;
end;

{ NTFS �����ļ�����,�˺��������߳������У����Բ�Ҫ�н������ }
procedure TfrmNTFSS.SearchFileNTFS;
var
  cjd      : CREATE_USN_JOURNAL_DATA;
  ujd      : USN_JOURNAL_DATA;
  djd      : DELETE_USN_JOURNAL_DATA;
  dwRet    : DWORD;
  int64Size: Integer;
  BufferOut: array [0 .. BUF_LEN - 1] of Char;
  BufferIn : MFT_ENUM_DATA;
  UsnInfo  : PUSN;
begin
  { ��ʼ��USN��־�ļ� }
  if not DeviceIoControl(FhRootHandle, FSCTL_CREATE_USN_JOURNAL, @cjd, Sizeof(cjd), nil, 0, dwRet, nil) then
    Exit;

  { ��ȡUSN��־������Ϣ }
  if not DeviceIoControl(FhRootHandle, FSCTL_QUERY_USN_JOURNAL, nil, 0, @ujd, Sizeof(ujd), dwRet, nil) then
    Exit;

  { ö��USN��־�ļ��е����м�¼ }
  int64Size                         := Sizeof(Int64);
  BufferIn.StartFileReferenceNumber := 0;
  BufferIn.LowUsn                   := 0;
  BufferIn.HighUsn                  := ujd.NextUsn;
  while DeviceIoControl(FhRootHandle, FSCTL_ENUM_USN_DATA, @BufferIn, Sizeof(BufferIn), @BufferOut, BUF_LEN, dwRet, nil) do
  begin
    { ������ֹ���� }
    if FbTerminated01 then
      Break;

    { �ҵ���һ�� USN ��¼ }
    UsnInfo := PUSN(Integer(@(BufferOut)) + int64Size);
    while dwRet > 60 do
    begin
      { ������ֹ���� }
      if FbTerminated01 then
        Break;

      { ��ȡ�ļ���Ϣ }
      GetUSNFileInfo(UsnInfo, FstrDriver);

      { ��ȡ��һ�� USN ��¼ }
      if UsnInfo.RecordLength > 0 then
        Dec(dwRet, UsnInfo.RecordLength)
      else
        Break;

      UsnInfo := PUSN(Cardinal(UsnInfo) + UsnInfo.RecordLength);
    end;
    Move(BufferOut, BufferIn, int64Size);
  end;

  { ɾ��USN��־�ļ���Ϣ }
  djd.UsnJournalID := ujd.UsnJournalID;
  djd.DeleteFlags  := USN_DELETE_FLAG_DELETE;
  DeviceIoControl(FhRootHandle, FSCTL_DELETE_USN_JOURNAL, @djd, Sizeof(djd), nil, 0, dwRet, nil);

  { ������� }
  FbFinished := True;
end;

{ ��ȡ�ļ���Ϣ }
procedure TfrmNTFSS.GetUSNFileInfo(UsnInfo: PUSN; const strDriver: string);
var
  strTableName : String;
  intFileID    : UInt64;
  intFilePID   : UInt64;
  strFileName  : String;
  strCreateTime: string;
  strModifyTime: String;
  strFullPath  : String;
begin
  strTableName  := FstrDriver[1] + '_Table';
  intFileID     := UsnInfo^.FileReferenceNumber;
  intFilePID    := UsnInfo^.ParentFileReferenceNumber;
  strFileName   := PWideChar(Integer(UsnInfo) + UsnInfo^.FileNameOffset);
  strCreateTime := '';
  strModifyTime := '';
  strFullPath   := '';
  Inc(FintCount);
  InsertDataSqlite(strTableName, strFileName, intFileID, intFilePID);
end;

procedure TfrmNTFSS.lvDataData(Sender: TObject; Item: TListItem);
begin
  Item.Caption := Format('%.10u', [Item.Index]);
end;

end.
