unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.IOUtils, System.Types, System.Diagnostics, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.ExtCtrls, Vcl.Menus, System.JSON, SynSQLite3Static, mORMotSQLite3, SynSQLite3, SynCommons, SynTable, mORMot, db.uCommon;

type
  TfrmNTFSS = class(TForm)
    lvData: TListView;
    lblFilter: TLabel;
    lblSearchTip: TLabel;
    srchbxFilter: TSearchBox;
    tmrStart: TTimer;
    pmFile: TPopupMenu;
    mniOpenFile: TMenuItem;
    mniOpenPath: TMenuItem;
    mniFileAttr: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrStartTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvDataData(Sender: TObject; Item: TListItem);
    procedure mniOpenFileClick(Sender: TObject);
    procedure mniOpenPathClick(Sender: TObject);
    procedure mniFileAttrClick(Sender: TObject);
  private
    FDatabase     : TSQLDataBase;
    FstrDBFileName: String;
    FhRootHandle  : THandle;
    FbFinished    : Boolean;
    FbTerminated01: Boolean;
    FbTerminated02: Boolean;
    FintCount     : UInt64;
    FchrDriver    : Char;
    { NTFS �����ļ����� }
    procedure SearchFileNTFS;
    { ��ȡ�ļ���Ϣ }
    procedure GetUSNFileInfo(UsnInfo: PUSN);
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmNTFSS;
  strParentModuleName     := 'ϵͳ����';
  strModuleName           := 'NTFS�ļ�����';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmNTFSS.FormResize(Sender: TObject);
begin
  if lblSearchTip.Caption <> '' then
    lblSearchTip.Left := (lblSearchTip.Parent.Width - lblSearchTip.Width) div 2;
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
  FDatabase.DBClose;
  FDatabase.Free;
  if FileExists(FstrDBFileName) then
    DeleteFile(FstrDBFileName);

  Action := caFree;
end;

const
  c_strTableName = 'NTFS';
  c_strAllData   =                                                                                                                                                                                //
    ' WITH RECURSIVE temptable(FILEID, FILEPID, FILENAME) AS ' +                                                                                                                                  //
    ' ( ' +                                                                                                                                                                                       //
    '	 select FILEID, FILEPID, FILENAME from NTFS where FILEPID = 1407374883553285 ' +                                                                                                            //
    '	 union all ' +                                                                                                                                                                              //
    '	 select a.FILEID, a.FILEPID, convert(varchar(255), convert(varchar(255), b.FILENAME) + ''\'' + a.FILENAME ) as FILENAME  from NTFS  a inner join temptable  b on (a.FILEPID = b.FILEID) ' + //
    ' ) ' +                                                                                                                                                                                       //
    ' select RowID, * from temptable';

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
  FstrDBFileName   := TPath.GetTempPath + 'ntfs.db';
  if FileExists(FstrDBFileName) then
    DeleteFile(FstrDBFileName);

  { ���� Sqlite ���ݿ� }
  FDatabase := TSQLDataBase.Create(FstrDBFileName);
  FDatabase.Execute(PAnsiChar(AnsiString('CREATE TABLE ' + c_strTableName + ' ([Driver] VARCHAR(1), [FileID] INTEGER NULL, [FilePID] INTEGER NULL, [IsDir] INTEGER NULL, [FileName] VARCHAR (255), [FullName] VARCHAR (255));'))); // ������ṹ

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
      FDatabase.TransactionBegin();        // ��������
      Timer        := TStopwatch.StartNew; // ��ʱ��ʼ
      FhRootHandle := hRootHandle;
      FbFinished   := False;
      FchrDriver   := strDriver[1];
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

      { �ļ�������� }
      FDatabase.Commit;
      Caption := Caption + '; ' + Format('���� %s ��ʱ %d ��', [strDriver, Timer.ElapsedMilliseconds div 1000]);
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
  Caption              := 'NTFS �ļ�����';
end;

{ ��ȡ�ļ���Ϣ }
procedure TfrmNTFSS.GetUSNFileInfo(UsnInfo: PUSN);
var
  intFileID  : UInt64;
  intFilePID : UInt64;
  strFileName: String;
  strFullPath: String;
  strSQL     : String;
  intDir     : Integer;
begin
  intFileID   := UsnInfo^.FileReferenceNumber;
  intFilePID  := UsnInfo^.ParentFileReferenceNumber;
  strFileName := PWideChar(Integer(UsnInfo) + UsnInfo^.FileNameOffset);
  strFileName := Copy(strFileName, 1, UsnInfo^.FileNameLength div 2);
  intDir      := Integer(UsnInfo^.FileAttributes and FILE_ATTRIBUTE_DIRECTORY = FILE_ATTRIBUTE_DIRECTORY);
  strFullPath := '';
  Inc(FintCount);
  strSQL := 'INSERT INTO ' + c_strTableName + ' (Driver, FileID, FilePID, IsDir, FileName) VALUES(' + QuotedStr(FchrDriver) + ', ' + UIntToStr(intFileID) + ', ' + UIntToStr(intFilePID) + ', ' + IntToStr(intDir) + ', ' + QuotedStr(String((strFileName))) + ')';
  FDatabase.Execute(RawUTF8(strSQL));
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
      GetUSNFileInfo(UsnInfo);

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

procedure TfrmNTFSS.lvDataData(Sender: TObject; Item: TListItem);
var
  strJson: RawUTF8;
begin
  if Item = nil then
    Exit;

  Item.Caption := Format('%.10u', [Item.Index + 1]);
  strJson      := FDatabase.ExecuteNoExceptionUTF8(RawUTF8(Format('select FileName from NTFS where RowID = %u', [Item.Index + 1])));
  Item.SubItems.Add(string(strJson));
end;

procedure TfrmNTFSS.mniFileAttrClick(Sender: TObject);
begin
  //
end;

procedure TfrmNTFSS.mniOpenFileClick(Sender: TObject);
begin
  //
end;

procedure TfrmNTFSS.mniOpenPathClick(Sender: TObject);
begin
  //
end;

end.
