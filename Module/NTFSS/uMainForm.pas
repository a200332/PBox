unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.IOUtils, System.Types, System.Diagnostics, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.WinXCtrls, Vcl.ExtCtrls, Vcl.Menus, SynSQLite3Static, mORMotSQLite3, SynSQLite3, SynCommons, SynTable, mORMot, db.uCommon;

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
    FstrTableName : String;
    FhRootHandle  : THandle;
    FbFinished    : Boolean;
    FbTerminated01: Boolean;
    FbTerminated02: Boolean;
    FintCount     : UInt64;
    { NTFS 磁盘文件搜索 }
    procedure SearchFileNTFS;
    { 获取文件信息 }
    procedure GetUSNFileInfo(UsnInfo: PUSN);
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmNTFSS;
  strParentModuleName     := '系统管理';
  strModuleName           := 'NTFS 文件搜索';
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
  if FileExists(FstrDBFileName) then
    DeleteFile(FstrDBFileName);

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
  I          : Integer;
  lstTable   : TStringList;
  strSQL     : String;
begin
  tmrStart.Enabled := False;
  FbTerminated01   := False;
  FbTerminated02   := False;
  lstTable         := TStringList.Create;
  FintCount        := 0;
  FstrDBFileName   := TPath.GetTempPath + 'ntfs.db';
  if FileExists(FstrDBFileName) then
    DeleteFile(FstrDBFileName);

  { 创建 Sqlite 数据库 }
  FDatabase := TSQLDataBase.Create(FstrDBFileName);

  lstDriver := TDirectory.GetLogicalDrives;
  for strDriver in lstDriver do
  begin
    { 判断是否是 NTFS 格式磁盘 }
    if not GetVolumeInformation(PChar(strDriver), nil, 0, nil, intLen, sysFlags, strNTFS, 256) then
      Continue;

    if not SameText(strNTFS, 'NTFS') then
      Continue;

    { NTFS 磁盘文件搜索 }
    hRootHandle := CreateFile(PChar('\\.\' + strDriver[1] + strDriver[2]), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
    if hRootHandle = ERROR_INVALID_HANDLE then
      Continue;

    try
      lblSearchTip.Caption := Format('正在搜索 %s 盘，请稍候······', [strDriver]);
      lblSearchTip.Left    := (lblSearchTip.Parent.Width - lblSearchTip.Width) div 2;
      FstrTableName        := strDriver[1] + '_Table';
      lstTable.Add(FstrTableName);                                                                                                                                                                                  // NTFS 磁盘列表
      FDatabase.Execute(PAnsiChar(AnsiString('CREATE TABLE ' + FstrTableName + ' ([ID] INTEGER PRIMARY KEY, [FileID] INTEGER NULL, [FilePID] INTEGER NULL,[FileName] VARCHAR (255), [FullName] VARCHAR (255));'))); // 创建表结构
      FDatabase.Execute('BEGIN TRANSACTION;');                                                                                                                                                                      // 开启事务
      Timer        := TStopwatch.StartNew;                                                                                                                                                                          // 计时开始
      FhRootHandle := hRootHandle;
      FbFinished   := False;
      TThread.CreateAnonymousThread(SearchFileNTFS).Start;

      { 等待文件搜索完毕 }
      while True do
      begin
        Application.ProcessMessages;

        { 程序中止运行 }
        if FbTerminated01 then
        begin
          FbTerminated02 := True;
          close;
          Exit;
        end;

        if FbFinished then
          Break
      end;

      { 文件搜索完毕 }
      FDatabase.Execute('COMMIT TRANSACTION;');
      Caption := Caption + '; ' + Format('搜索 %s 用时 %d 秒', [strDriver, Timer.ElapsedMilliseconds div 1000]);
    finally
      CloseHandle(hRootHandle);
    end;
  end;

  { 全部搜索完毕 }
  lblSearchTip.Caption := '';
  FbTerminated02       := True;
  lblFilter.Visible    := True;
  srchbxFilter.Visible := True;
  lvData.Items.Count   := FintCount;
  strSQL               := '';
  for I                := 0 to lstTable.Count - 1 do
  begin
    strSQL := strSQL + 'select * from ' + lstTable.Strings[I] + ' union all ';
  end;
  strSQL := LeftStr(strSQL, Length(strSQL) - 11);
  FDatabase.Execute(PAnsiChar(AnsiString(strSQL)));
  lstTable.Free;
  Caption := Caption + '; ' + Format('总记录数：%u', [FintCount]);
end;

{ 获取文件信息 }
procedure TfrmNTFSS.GetUSNFileInfo(UsnInfo: PUSN);
var
  intFileID  : UInt64;
  intFilePID : UInt64;
  strFileName: String;
  strFullPath: String;
  strSQL     : String;
begin
  intFileID   := UsnInfo^.FileReferenceNumber;
  intFilePID  := UsnInfo^.ParentFileReferenceNumber;
  strFileName := PWideChar(Integer(UsnInfo) + UsnInfo^.FileNameOffset);
  strFullPath := '';
  Inc(FintCount);
  strSQL := 'INSERT INTO ' + FstrTableName + ' (FileName, FileID, FilePID) VALUES(' + QuotedStr(strFileName) + ', ' + UIntToStr(intFileID) + ', ' + UIntToStr(intFilePID) + ')';
  FDatabase.Execute(PAnsiChar(AnsiString(strSQL)));
end;

{ NTFS 磁盘文件搜索,此函数是在线程中运行，所以不要有界面操作 }
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
  { 初始化USN日志文件 }
  if not DeviceIoControl(FhRootHandle, FSCTL_CREATE_USN_JOURNAL, @cjd, Sizeof(cjd), nil, 0, dwRet, nil) then
    Exit;

  { 获取USN日志基本信息 }
  if not DeviceIoControl(FhRootHandle, FSCTL_QUERY_USN_JOURNAL, nil, 0, @ujd, Sizeof(ujd), dwRet, nil) then
    Exit;

  { 枚举USN日志文件中的所有记录 }
  int64Size                         := Sizeof(Int64);
  BufferIn.StartFileReferenceNumber := 0;
  BufferIn.LowUsn                   := 0;
  BufferIn.HighUsn                  := ujd.NextUsn;
  while DeviceIoControl(FhRootHandle, FSCTL_ENUM_USN_DATA, @BufferIn, Sizeof(BufferIn), @BufferOut, BUF_LEN, dwRet, nil) do
  begin
    { 程序中止运行 }
    if FbTerminated01 then
      Break;

    { 找到第一个 USN 记录 }
    UsnInfo := PUSN(Integer(@(BufferOut)) + int64Size);
    while dwRet > 60 do
    begin
      { 程序中止运行 }
      if FbTerminated01 then
        Break;

      { 获取文件信息 }
      GetUSNFileInfo(UsnInfo);

      { 获取下一个 USN 记录 }
      if UsnInfo.RecordLength > 0 then
        Dec(dwRet, UsnInfo.RecordLength)
      else
        Break;

      UsnInfo := PUSN(Cardinal(UsnInfo) + UsnInfo.RecordLength);
    end;
    Move(BufferOut, BufferIn, int64Size);
  end;

  { 删除USN日志文件信息 }
  djd.UsnJournalID := ujd.UsnJournalID;
  djd.DeleteFlags  := USN_DELETE_FLAG_DELETE;
  DeviceIoControl(FhRootHandle, FSCTL_DELETE_USN_JOURNAL, @djd, Sizeof(djd), nil, 0, dwRet, nil);

  { 搜索完毕 }
  FbFinished := True;
end;

procedure TfrmNTFSS.lvDataData(Sender: TObject; Item: TListItem);
begin
  Item.Caption := Format('%.10u', [Item.Index + 1]);
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
