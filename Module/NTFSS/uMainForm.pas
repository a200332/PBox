unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShlObj, Winapi.ShellAPI, Winapi.ActiveX, System.SysUtils, System.StrUtils, System.Variants, System.Classes, System.IOUtils, System.Types, System.Diagnostics, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
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
    mniLine01: TMenuItem;
    mniDeleteFile: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrStartTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvDataData(Sender: TObject; Item: TListItem);
    procedure mniOpenFileClick(Sender: TObject);
    procedure mniOpenPathClick(Sender: TObject);
    procedure mniFileAttrClick(Sender: TObject);
    procedure srchbxFilterInvokeSearch(Sender: TObject);
    procedure mniDeleteFileClick(Sender: TObject);
  private
    FDatabase     : TSQLDataBase;
    FstrDBFileName: String;
    FhRootHandle  : THandle;
    FbFinished    : Boolean;
    FbTerminated01: Boolean;
    FbTerminated02: Boolean;
    FchrDriver    : Char;
    FDriverList   : TStringList;
    FintSearchType: Integer;
    FstrArr       : TRawUTF8DynArray;
    FbSearch      : Boolean;
    { NTFS 磁盘文件搜索 }
    procedure SearchFileNTFS;
    { 获取文件信息 }
    procedure GetUSNFileInfo(UsnInfo: PUSN);
    { 获取文件全路径名称 }
    procedure GetFileFullName(var intCount: UInt64);
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

uses uWaittingForm;

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmNTFSS;
  strParentModuleName     := '系统管理';
  strModuleName           := 'NTFS文件搜索';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

const
  c_strTableName           = 'NTFS';
  c_strTempResultTableName = 'TempTable';

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

  FDriverList.Free;
  Action := caFree;
end;

{ 获取文件全路径名称 }
procedure TfrmNTFSS.GetFileFullName(var intCount: UInt64);
const
  c_RootID     = $5000000000005;
  c_strAllData =                                                                                                                                            //
    ' with recursive ' +                                                                                                                                    //
    ' %s(FILEID, FILEPID, IsDir, FILENAME) AS ' +                                                                                                           //
    '( ' +                                                                                                                                                  //
    ' select FILEID, FILEPID, IsDir, FILENAME from NTFS where FILEPID = %u and Driver=%s ' +                                                                //
    ' union all ' +                                                                                                                                         //
    ' select a.FILEID, a.FILEPID, a.IsDir,  b.FileName || ''\'' || a.FILENAME from NTFS  a inner join %s  b on (a.FILEPID = b.FILEID) where a.Driver=%s ' + //
    ' ) ' +                                                                                                                                                 //
    ' select %s || FILENAME as FileName from %s order by IsDir desc, FileName ';
var
  strSQL   : String;
  strDriver: String;
  strAll   : string;
  strTemp  : String;
  I        : Integer;
  strCount : RawUTF8;
begin
  strAll := '';
  for I  := 0 to FDriverList.Count - 1 do
  begin
    strDriver := FDriverList.Strings[I];
    strSQL    := Format(c_strAllData, ['tb_' + strDriver, c_RootID, QuotedStr(strDriver), 'tb_' + strDriver, QuotedStr(strDriver), QuotedStr(strDriver + ':\'), 'tb_' + strDriver]);
    strTemp   := Format('t%d', [I]);
    strAll    := strAll + ' select ' + strTemp + '.FileName from ( ' + strSQL + ') as ' + strTemp + ' union ';
  end;

  if System.SysUtils.Trim(strAll) <> '' then
  begin
    strAll := LeftStr(strAll, Length(strAll) - 7);
    strAll := 'create table ' + c_strTempResultTableName + ' as select * from (' + strAll + ') ';
    FDatabase.Execute(RawUTF8(strAll));
    strCount := FDatabase.ExecuteNoExceptionUTF8(RawUTF8('select count(*) from ' + c_strTempResultTableName));
    intCount := StrToUInt64(string(strCount));
  end;
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
  intCount   : UInt64;
begin
  tmrStart.Enabled := False;
  FbTerminated01   := False;
  FbTerminated02   := False;
  FbSearch         := False;
  FDriverList      := TStringList.Create;
  FstrDBFileName   := TPath.GetTempPath + 'ntfs.db';
  if FileExists(FstrDBFileName) then
    DeleteFile(FstrDBFileName);

  { 创建 Sqlite 数据库 }
  FDatabase := TSQLDataBase.Create(FstrDBFileName);
  FDatabase.Execute(PAnsiChar(AnsiString('CREATE TABLE ' + c_strTableName + ' ([Driver] VARCHAR(1), [FileID] INTEGER NULL, [FilePID] INTEGER NULL, [IsDir] INTEGER NULL, [FileName] VARCHAR (255), [FullName] VARCHAR (255));'))); // 创建表结构

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
      FDatabase.TransactionBegin();        // 开启事务
      Timer        := TStopwatch.StartNew; // 计时开始
      FhRootHandle := hRootHandle;
      FbFinished   := False;
      FchrDriver   := strDriver[1];
      FDriverList.Add(FchrDriver);
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
      FDatabase.Commit;
      Caption := Caption + '; ' + Format('搜索 %s 用时 %d 秒', [strDriver, Timer.ElapsedMilliseconds div 1000]);
    finally
      CloseHandle(hRootHandle);
    end;
  end;

  { 全部搜索完毕，获取文件全路径名称 }
  lblSearchTip.Caption := '正在排序文件，请稍候······';
  lblSearchTip.Left    := (lblSearchTip.Parent.Width - lblSearchTip.Width) div 2;
  DelayTime(300);
  GetFileFullName(intCount);

  { 全部搜索完毕 }
  lblSearchTip.Caption := '';
  FintSearchType       := 0;
  FbSearch             := True;
  FbTerminated02       := True;
  lblFilter.Visible    := True;
  srchbxFilter.Visible := True;
  lvData.Items.Count   := intCount;
  Caption              := 'NTFS 文件搜索';
end;

{ 获取文件信息 }
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
  strSQL      := 'INSERT INTO ' + c_strTableName + ' (Driver, FileID, FilePID, IsDir, FileName) VALUES(' + QuotedStr(FchrDriver) + ', ' + UIntToStr(intFileID) + ', ' + UIntToStr(intFilePID) + ', ' + IntToStr(intDir) + ', ' + QuotedStr(String((strFileName))) + ')';
  FDatabase.Execute(RawUTF8(strSQL));
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
var
  strJson: RawUTF8;
  strSQL : String;
begin
  if Item = nil then
    Exit;

  if FintSearchType = -1 then
    Exit;

  if not FbSearch then
    Exit;

  if FintSearchType = 0 then
  begin
    Item.Caption := Format('%.10u', [Item.Index + 1]);
    strSQL       := 'select FileName from ' + c_strTempResultTableName + ' where RowID=' + UIntToStr(Item.Index + 1);
    strJson      := FDatabase.ExecuteNoExceptionUTF8(RawUTF8(strSQL));
    Item.SubItems.Add(string(strJson));
  end;

  if FintSearchType = 1 then
  begin
    Item.Caption := Format('%.10u', [Item.Index + 1]);
    Item.SubItems.Add(string(FstrArr[Item.Index + 0]));
  end;
end;

procedure TfrmNTFSS.srchbxFilterInvokeSearch(Sender: TObject);
var
  strCount: RawUTF8;
  intCount: UInt64;
  strSQL  : String;
  strTemp : String;
begin
  if srchbxFilter.Text = '' then
  begin
    strSQL   := 'select count(*) from ' + c_strTempResultTableName;
    strCount := FDatabase.ExecuteNoExceptionUTF8(RawUTF8(strSQL));
    intCount := StrToUInt64(string(strCount));
    lvData.Items.Clear;
    lvData.Items.Count := intCount;
    FintSearchType     := 0;
    FbSearch           := True;
    Exit;
  end;

  if Length(srchbxFilter.Text) < 2 then
  begin
    MessageBox(Handle, '搜索字符串必须大于或等于2个字符串', '系统提示：', MB_OK or MB_ICONINFORMATION);
    Exit;
  end;

  ShowWaittingForm;
  try
    FbSearch := False;
    strTemp  := StringReplace(srchbxFilter.Text, '?', '_', [rfReplaceAll]);
    strTemp  := StringReplace(strTemp, '*', '%', [rfReplaceAll]);
    strSQL   := 'select FileName from ' + c_strTempResultTableName + ' where FileName like ' + QuotedStr('%' + strTemp + '%');
    intCount := FDatabase.Execute(RawUTF8(strSQL), FstrArr);
    lvData.Items.Clear;
    lvData.Items.Count := intCount;
    FintSearchType     := 1;
    FbSearch           := True;
  finally
    FreeWaittingForm;
  end;
end;

procedure TfrmNTFSS.mniOpenFileClick(Sender: TObject);
begin
  if lvData.ItemIndex = -1 then
    Exit;

  if lvData.Selected.SubItems[0] = '' then
    Exit;

  if not FileExists(lvData.Selected.SubItems[0]) then
    Exit;

  ShellExecute(GetMainFormApplication.MainForm.Handle, 'Open', PChar(lvData.Selected.SubItems[0]), nil, nil, SW_HIDE);
end;

function SHOpenFolderAndSelectItems(pidlFolder: pItemIDList; cidl: Cardinal; apidl: Pointer; dwFlags: DWORD): HRESULT; stdcall; external shell32;

function OpenFolderAndSelectFile(const strFileName: string; const bEditMode: Boolean = False): Boolean;
var
  IIDL      : pItemIDList;
  pShellLink: IShellLink;
  hr        : Integer;
begin
  Result := False;

  hr := CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IID_IShellLink, &pShellLink);
  if hr = S_OK then
  begin
    pShellLink.SetPath(PChar(strFileName));
    pShellLink.GetIDList(&IIDL);
    Result := SHOpenFolderAndSelectItems(IIDL, 0, nil, Cardinal(bEditMode)) = S_OK;
  end;
end;

function ShowFileProperties(FileName: String; Wnd: HWND): Boolean;
var
  sfi: TSHELLEXECUTEINFOW;
begin
  with sfi do
  begin
    cbSize       := Sizeof(sfi);
    lpFile       := PChar(FileName);
    Wnd          := Wnd;
    fMask        := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
    lpVerb       := PChar('properties');
    lpIDList     := nil;
    lpDirectory  := nil;
    nShow        := 0;
    hInstApp     := 0;
    lpParameters := nil;
    dwHotKey     := 0;
    hIcon        := 0;
    hkeyClass    := 0;
    hProcess     := 0;
    lpClass      := nil;
  end;
  Result := ShellExecuteEX(@sfi);
end;

procedure TfrmNTFSS.mniOpenPathClick(Sender: TObject);
begin
  if lvData.ItemIndex = -1 then
    Exit;

  OpenFolderAndSelectFile(lvData.Selected.SubItems[0]);
end;

procedure TfrmNTFSS.mniDeleteFileClick(Sender: TObject);
begin
  if lvData.ItemIndex = -1 then
    Exit;

  if lvData.Selected.SubItems[0] = '' then
    Exit;

  if not FileExists(lvData.Selected.SubItems[0]) then
  begin
    lvData.Selected.Delete
  end
  else
  begin
    if DeleteFile(lvData.Selected.SubItems[0]) then
      lvData.Selected.Delete;
  end;
end;

procedure TfrmNTFSS.mniFileAttrClick(Sender: TObject);
begin
  if lvData.ItemIndex = -1 then
    Exit;

  ShowFileProperties(lvData.Selected.SubItems[0], 0);
end;

end.
