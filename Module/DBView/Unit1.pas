unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.IniFiles, System.SysUtils, System.StrUtils, System.SyncObjs, System.Variants, System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ComCtrls, Data.Win.ADOConEd, Data.Win.ADODB, Data.DB,
  XLSReadWriteII5, Xc12Utils5, XLSUtils5, Xc12DataStyleSheet5, SynSQLite3Static, mORMotSQLite3, SynSQLite3, SynCommons, SynTable, mORMot, System.JSON, DB.uCommon;

type
  TfrmDBView = class(TForm)
    btnDBLink: TButton;
    grpTables: TGroupBox;
    grpFieldType: TGroupBox;
    lvData: TListView;
    btnExportExcel: TButton;
    lstTables: TListBox;
    lvFieldType: TListView;
    conADO: TADOConnection;
    qryTemp: TADOQuery;
    btnDataView: TButton;
    qryData: TADOQuery;
    btnQuery: TButton;
    dlgSaveExcel: TSaveDialog;
    pmDBType: TPopupMenu;
    mniSqlite31: TMenuItem;
    dlgOpenSqlite3DB: TOpenDialog;
    procedure btnDBLinkClick(Sender: TObject);
    procedure lstTablesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDataViewClick(Sender: TObject);
    procedure lvDataData(Sender: TObject; Item: TListItem);
    procedure btnExportExcelClick(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure lvFieldTypeDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
    procedure lvFieldTypeClick(Sender: TObject);
    procedure mniSqlite31Click(Sender: TObject);
  private
    FbSqlite3  : Boolean;
    FSqlite3DB : TSQLDatabase;
    FstrColumns: String;
    procedure ReadDBFromConfig(ADOCNN: TADOConnection);
    procedure GetTableFieldType(const strTableName: string);
    function GetFieldType(const strTableName, strFieldName: string): String;
    { 获取自动增长字段 }
    function GetAutoAddField(const strTableName: String; var strAutoField: string): Boolean;
    function GetDisplayFields(const strTableName: string): String;
    function GetChineseFields(const strTableName, strDisplayFields: string): string;
    procedure CreateColumnField(const strChineseFields: string); overload;
    procedure CreateColumnField(const qry: TADOQuery); overload;
    procedure DisplayData(qry: TADOQuery);
    procedure GetSqlite3AllTable;
    { 获取表信息 ADO }
    procedure GetTableInfo_ADO(const strTableName: string);
    { 获取表信息 Sqlite3 }
    procedure GetTableInfo_Sqlite3(const strTableName: string);
    { 浏览数据 ADO }
    procedure BrowseData_ADO;
    { 浏览数据 Sqlite3 }
    procedure BrowseData_Sqlite3;
    { 保存到 EXCEL 文件 }
    procedure SaveToXLSX_ADO(const strFileName: string);
    procedure SaveToXLSX_Sqlite3(const strFileName: string);
    function GetSqliteFieldDataType(const strFieldType: string): string;
    function GetSqliteFieldDataType2(const strFieldType: string): string;
    procedure DrawListView_ADO(Item: TListItem);
    procedure DrawListView_Sqlite3(Item: TListItem);
  public
    { Public declarations }
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

uses Unit2;

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmDBView;
  strParentModuleName     := '数据库管理';
  strModuleName           := '数据库查看器';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

procedure TfrmDBView.FormCreate(Sender: TObject);
begin
  FbSqlite3 := False;
  ReadDBFromConfig(conADO);
end;

procedure TfrmDBView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmDBView.GetSqlite3AllTable;
var
  strName: TRawUTF8DynArray;
  I      : Integer;
begin
  FSqlite3DB.Execute('SELECT name FROM sqlite_master WHERE type=''table'' ORDER BY name;', strName);
  lstTables.Clear;
  for I := 0 to Length(strName) - 1 do
  begin
    if Trim(strName[I]) <> '' then
    begin
      lstTables.Items.Add(string(strName[I]));
    end;
  end;
end;

procedure SaveSqlite3OpenPath(const strPath: String);
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    WriteString('UI', 'OpenPath', strPath);
    Free;
  end;
end;

function GetSqlite3OpenPath: String;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Result := ReadString('UI', 'OpenPath', '');
    Free;
  end;
end;

procedure TfrmDBView.mniSqlite31Click(Sender: TObject);
var
  strSqlite3DBFileName: string;
begin
  dlgOpenSqlite3DB.InitialDir := GetSqlite3OpenPath;
  if not dlgOpenSqlite3DB.Execute then
    Exit;

  FbSqlite3            := True;
  strSqlite3DBFileName := dlgOpenSqlite3DB.FileName;
  FSqlite3DB           := TSQLDatabase.Create(strSqlite3DBFileName, '', SQLITE_OPEN_READONLY);
  GetSqlite3AllTable;
  SaveSqlite3OpenPath(ExtractFilePath(strSqlite3DBFileName));
end;

procedure TfrmDBView.btnDBLinkClick(Sender: TObject);
begin
  if EditConnectionString(conADO) then
  begin
    if TryLinkDataBase(conADO.ConnectionString, conADO) then
    begin
      conADO.GetTableNames(lstTables.Items);
      btnQuery.Enabled := True;
    end;
  end;
end;

procedure TfrmDBView.lstTablesClick(Sender: TObject);
begin
  if lstTables.ItemIndex = -1 then
    Exit;

  lvData.Items.Count := 0;
  lvData.Items.Clear;
  lvData.Columns.Clear;
  btnDataView.Enabled := True;
  btnQuery.Enabled    := True;
  GetTableFieldType(lstTables.Items.Strings[lstTables.ItemIndex]);
end;

function TfrmDBView.GetFieldType(const strTableName, strFieldName: string): String;
var
  ft: TFieldType;
begin
  ft := qryTemp.FieldByName(strFieldName).DataType;
  if ft in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint, ftADT, ftLongWord, ftShortint, ftByte] then
    Result := '整数'
  else if ft in [ftString, ftFixedChar, ftWideString, ftFixedWideChar] then
    Result := '字符串'
  else if ft = ftBoolean then
    Result := '布尔'
  else if ft in [Data.DB.ftFloat, Data.DB.ftCurrency, Data.DB.ftBCD, Data.DB.ftExtended, Data.DB.ftSingle] then
    Result := '浮点数'
  else if ft in [Data.DB.ftDate, Data.DB.ftTime, Data.DB.ftDateTime] then
    Result := '日期'
  else if ft in [ftBytes, ftVarBytes, ftArray] then
    Result := '整数数组'
  else if ft = ftBoolean then
    Result := '布尔'
  else if ft in [Data.DB.ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftWideMemo, ftObject] then
    Result := '二进制'
  else
    Result := '未知'
end;

{ 获取表信息 ADO }
procedure TfrmDBView.GetTableInfo_ADO(const strTableName: string);
var
  lstFields   : TStringList;
  strFieldName: String;
  strFieldType: String;
  I           : Integer;
begin
  qryTemp.Close;
  qryTemp.SQL.Clear;
  qryTemp.SQL.Text := 'select * from ' + strTableName + ' where 0=1';
  qryTemp.Open;

  lvFieldType.Clear;
  lstFields := TStringList.Create;
  try
    conADO.GetFieldNames(strTableName, lstFields);
    for I := 0 to lstFields.Count - 1 do
    begin
      strFieldName := lstFields.Strings[I];
      strFieldType := GetFieldType(strTableName, strFieldName);
      with lvFieldType.Items.Add do
      begin
        Caption := '1';
        SubItems.Add(strFieldName);
        SubItems.Add(strFieldType);
      end;
    end;
  finally
    lstFields.Free;
  end;
end;

function TfrmDBView.GetSqliteFieldDataType(const strFieldType: string): string;
var
  strUpper: String;
begin
  strUpper := System.SysUtils.UpperCase(strFieldType);
  if Pos('VARCHAR', strUpper) > 0 then
    Result := '字符串'
  else if Pos('TEXT', strUpper) > 0 then
    Result := '字符串'
  else if Pos('CHAR(', strUpper) > 0 then
    Result := '字符串'
  else if Pos('INTEGER', strUpper) > 0 then
    Result := '整数'
  else if Pos('BIGINT', strUpper) > 0 then
    Result := '整数'
  else
    Result := '二进制';
end;

function TfrmDBView.GetSqliteFieldDataType2(const strFieldType: string): string;
var
  I: Integer;
begin
  Result := '二进制';
  for I  := 0 to lvFieldType.Items.Count - 1 do
  begin
    if SameText(lvFieldType.Items[I].SubItems[0], strFieldType) then
    begin
      Result := lvFieldType.Items[I].SubItems[1];
      Break;
    end;
  end;
end;

{ 获取表信息 Sqlite3 }
procedure TfrmDBView.GetTableInfo_Sqlite3(const strTableName: string);
var
  strFieldName: String;
  strFieldType: String;
  I           : Integer;
  strJson     : RawUTF8;
  jsn         : TJSONArray;
begin
  strJson := FSqlite3DB.ExecuteJSON(RawUTF8('PRAGMA table_info(' + QuotedStr(strTableName) + ')'), True);
  lvFieldType.Clear;
  jsn := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(string(strJson)), 0) as TJSONArray;
  try
    if jsn.Count > 0 then
    begin
      for I := 0 to jsn.Count - 1 do
      begin
        strFieldName := jsn.Items[I].GetValue<String>('name');
        strFieldType := jsn.Items[I].GetValue<String>('type');
        with lvFieldType.Items.Add do
        begin
          Caption := '1';
          SubItems.Add(strFieldName);
          SubItems.Add(GetSqliteFieldDataType(strFieldType));
        end;
      end;
    end;
  finally
    jsn.Free;
  end;
end;

procedure TfrmDBView.GetTableFieldType(const strTableName: string);
begin
  if not FbSqlite3 then
    GetTableInfo_ADO(strTableName)
  else
    GetTableInfo_Sqlite3(strTableName);
end;

{ 获取自动增长字段 }
function TfrmDBView.GetAutoAddField(const strTableName: String; var strAutoField: string): Boolean;
begin
  Result := False;

  with TADOQuery.Create(nil) do
  begin
    Connection := conADO;
    SQL.Text   := Format('select colstat, name from syscolumns where id=object_id(%s) and colstat = 1', [QuotedStr(strTableName)]);
    Open;
    if RecordCount > 0 then
    begin
      strAutoField := Fields[1].AsString;
      Result       := True;
    end;
    Free;
  end;
end;

function TfrmDBView.GetDisplayFields(const strTableName: string): String;
var
  I: Integer;
begin
  Result := '';
  for I  := 0 to lvFieldType.Items.Count - 1 do
  begin
    if lvFieldType.Items[I].Caption = '1' then
    begin
      Result := Result + ',' + lvFieldType.Items[I].SubItems[0];
    end;
  end;

  if Result <> '' then
  begin
    Result := RightStr(Result, Length(Result) - 1);
  end;
end;

function TfrmDBView.GetChineseFields(const strTableName, strDisplayFields: string): string;
const
  c_strFieldChineseName =                                                                                   //
    ' SELECT c.[name] AS 字段名, cast(ep.[value] as varchar(100)) AS [字段说明] FROM sys.tables AS t' +            //
    ' INNER JOIN sys.columns AS c ON t.object_id = c.object_id' +                                           //
    ' LEFT JOIN sys.extended_properties AS ep ON ep.major_id = c.object_id AND ep.minor_id = c.column_id' + //
    ' WHERE ep.class = 1 AND t.name=%s';
var
  strFields      : TArray<String>;
  I              : Integer;
  strChineseField: string;
begin
  with TADOQuery.Create(nil) do
  begin
    Connection := conADO;
    SQL.Text   := Format(c_strFieldChineseName, [QuotedStr(strTableName)]);
    Open;
    strFields := strDisplayFields.Split([',']);
    for I     := 0 to Length(strFields) - 1 do
    begin
      if Locate('字段名', strFields[I], []) then
      begin
        strChineseField := Fields[1].AsString;
        if System.SysUtils.Trim(strChineseField) <> '' then
          Result := Result + '|' + strChineseField
        else
          Result := Result + '|' + strFields[I];
      end
      else
      begin
        Result := Result + '|' + strFields[I];
      end;
    end;

    if Result <> '' then
    begin
      Result := RightStr(Result, Length(Result) - 1);
    end;

    Free;
  end;
end;

procedure TfrmDBView.CreateColumnField(const strChineseFields: string);
var
  strFields: TArray<string>;
  I, Count : Integer;
begin
  with lvData.Columns.Add do
  begin
    Caption := '序列';
    Width   := 140;
  end;

  strFields := strChineseFields.Split(['|']);
  Count     := Length(strFields);
  for I     := 0 to Count - 1 do
  begin
    with lvData.Columns.Add do
    begin
      Caption := strFields[I];
      Width   := 140;
    end;
  end;
end;

procedure TfrmDBView.DisplayData(qry: TADOQuery);
var
  I: Integer;
begin
  qry.First;
  lvData.Items.BeginUpdate;
  while not qry.Eof do
  begin
    with lvData.Items.Add do
    begin
      Caption := qry.Fields[0].AsString;
      for I   := 1 to qry.FieldCount - 1 do
      begin
        SubItems.Add(qry.Fields[I].AsString);
      end;
    end;
    qry.Next;
  end;
  lvData.Items.EndUpdate;
end;

{ 浏览数据 ADO }
procedure TfrmDBView.BrowseData_ADO;
var
  strAutoField    : String;
  strTableName    : String;
  strDisplayFields: String;
  strChineseFields: String;
begin
  lvData.Items.Count := 0;
  lvData.Columns.Clear;
  lvData.Items.Clear;
  btnExportExcel.Enabled := True;

  strTableName     := lstTables.Items.Strings[lstTables.ItemIndex];
  strDisplayFields := GetDisplayFields(strTableName);
  if strDisplayFields = '' then
  begin
    MessageBox(Handle, '至少选择一个字段用来显示', '系统提示：', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  strChineseFields := GetChineseFields(strTableName, strDisplayFields);
  CreateColumnField(strChineseFields);

  qryData.Close;
  qryData.SQL.Clear;
  if GetAutoAddField(strTableName, strAutoField) then
    qryData.SQL.Text := 'select ROW_NUMBER() over(order by ' + strAutoField + ') as RowNum, ' + strDisplayFields + ' from ' + strTableName
  else
    qryData.SQL.Text := 'select Top 1000 ' + strDisplayFields + ' from ' + strTableName;
  qryData.Open;
  lvData.Items.Count := qryData.RecordCount;
end;

{ 浏览数据 Sqlite3 }
procedure TfrmDBView.BrowseData_Sqlite3;
var
  strTemp : String;
  I       : Integer;
  bFind   : Boolean;
  intCount: Int64;
begin
  lvData.Items.Count := 0;
  lvData.Columns.Clear;
  lvData.Items.Clear;
  btnExportExcel.Enabled := True;

  bFind := False;
  for I := 0 to lvFieldType.Items.Count - 1 do
  begin
    if lvFieldType.Items[I].Caption = '1' then
    begin
      bFind := True;
      Break;
    end;
  end;
  if not bFind then
  begin
    MessageBox(Handle, '至少选择一个字段用来显示', '系统提示：', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  FstrColumns := '';
  strTemp     := '';
  for I       := 0 to lvFieldType.Items.Count - 1 do
  begin
    if lvFieldType.Items[I].Caption = '1' then
    begin
      if lvFieldType.Items[I].SubItems[1] <> '二进制' then
      begin
        strTemp     := strTemp + '|' + lvFieldType.Items[I].SubItems[0];
        FstrColumns := FstrColumns + ',' + lvFieldType.Items[I].SubItems[0];
      end;
    end;
  end;
  strTemp     := RightStr(strTemp, Length(strTemp) - 1);
  FstrColumns := RightStr(FstrColumns, Length(FstrColumns) - 1);
  CreateColumnField(strTemp);

  FSqlite3DB.Execute(RawUTF8('select count(*) from ' + lstTables.Items[lstTables.ItemIndex]), intCount);
  lvData.Items.Count := intCount;
end;

procedure TfrmDBView.btnDataViewClick(Sender: TObject);
begin
  if not FbSqlite3 then
    BrowseData_ADO
  else
    BrowseData_Sqlite3;
end;

procedure TfrmDBView.DrawListView_ADO(Item: TListItem);
var
  I: Integer;
begin
  qryData.RecNo := Item.Index + 1;
  Item.Caption  := Format('%.10u', [Item.Index + 1]);
  for I         := 1 to qryData.Fields.Count - 1 do
  begin
    if qryData.Fields[I].DataType = Data.DB.ftBlob then
      Item.SubItems.Add('')
    else
      Item.SubItems.Add(qryData.Fields[I].AsString);
  end;
end;

function MyTrim(const strValue: string): String;
begin
  Result := strValue;
  if System.SysUtils.Trim(strValue) = '' then
    Exit;

  if (strValue[1] = '"') and (strValue[Length(strValue)] = '"') then
    Result := MidStr(strValue, 2, Length(strValue) - 2);
end;

procedure TfrmDBView.DrawListView_Sqlite3(Item: TListItem);
var
  I           : Integer;
  strSQL      : String;
  strJson     : RawUTF8;
  strValue    : String;
  jso         : TJSONObject;
  jsn         : TJSONArray;
  intRows     : Integer;
  strFieldName: String;
begin
  strSQL := 'select ' + FstrColumns + ' from ' + lstTables.Items[lstTables.ItemIndex] + ' where RowID=' + IntToStr(Item.Index + 1);
  try
    strJson  := FSqlite3DB.ExecuteJSON(RawUTF8(strSQL), True);
    strValue := UTF8ToString((strJson));
    if System.SysUtils.Trim(strValue) = '' then
      Exit;
  except
    Exit;
  end;

  if LeftStr(string(strValue), 1) <> '[' then
  begin
    jso := (TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(string(strValue)), 0) as TJSONObject);
    if jso = nil then
      Exit;

    intRows := jso.Values['rowCount'].AsType<Integer>;
    if intRows > 0 then
    begin
      jsn := jso.Values['values'] as TJSONArray;
      if (jsn <> nil) and (jsn.Count > 0) then
      begin
        Item.Caption := Format('%.10u', [Item.Index + 1]);
        for I        := 0 to lvData.Columns.Count - 2 do
        begin
          strFieldName := lvData.Columns[I + 1].Caption;
          if GetSqliteFieldDataType2(strFieldName) <> '二进制' then
            Item.SubItems.Add(MyTrim(jsn.Items[lvData.Columns.Count + I - 1].ToString))
          else
            Item.SubItems.Add('');
        end;
      end;
    end;
  end
  else
  begin
    jsn := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(string(strValue)), 0) as TJSONArray;
    if (jsn <> nil) and (jsn.Count > 0) then
    begin
      Item.Caption := Format('%.10u', [Item.Index + 1]);
      for I        := 1 to lvData.Columns.Count - 1 do
      begin
        Item.SubItems.Add(MyTrim(jsn.Items[0].GetValue<String>(lvData.Columns[I].Caption)));
      end;
    end;
  end;
end;

procedure TfrmDBView.lvDataData(Sender: TObject; Item: TListItem);
begin
  if lvData.Items.Count = 0 then
    Exit;

  if not FbSqlite3 then
    DrawListView_ADO(Item)
  else
    DrawListView_Sqlite3(Item);
end;

procedure TfrmDBView.lvFieldTypeClick(Sender: TObject);
begin
  if lvFieldType.ItemIndex = -1 then
    Exit;

  if lvFieldType.Items[lvFieldType.ItemIndex].Caption = '1' then
    lvFieldType.Items[lvFieldType.ItemIndex].Caption := '0'
  else
    lvFieldType.Items[lvFieldType.ItemIndex].Caption := '1';
end;

procedure TfrmDBView.lvFieldTypeDrawItem(Sender: TCustomListView; Item: TListItem; Rect: TRect; State: TOwnerDrawState);
var
  bDisplay: Boolean;
  bmpCheck: TBitmap;
  rct     : TRect;
  strTmp  : String;
  I       : Integer;
begin
  bDisplay := Item.Caption = '1';
  rct      := Item.DisplayRect(drBounds);

  bmpCheck := TBitmap.Create;
  try
    bmpCheck.PixelFormat := pf24bit;
    bmpCheck.Width       := 15;
    bmpCheck.Height      := 15;
    bmpCheck.LoadFromResourceName(HInstance, IfThen(bDisplay, 'CHECK', 'UNCHECK'));
    TListView(Sender).Canvas.Draw(rct.Left + 4, rct.Top, bmpCheck);
  finally
    bmpCheck.Free;
  end;

  for I := 0 to Item.SubItems.Count - 1 do
  begin
    strTmp    := Item.SubItems.Strings[I];
    rct.Left  := rct.Left + lvFieldType.Column[I + 0].Width + 2;
    rct.Right := rct.Left + lvFieldType.Column[I + 1].Width;
    TListView(Sender).Canvas.TextRect(rct, strTmp, [tfLeft, tfSingleLine, tfVerticalCenter]);
  end;
end;

procedure TfrmDBView.ReadDBFromConfig(ADOCNN: TADOConnection);
var
  strIniFileName: String;
  strEncLink    : String;
  strSQLLink    : String;
begin
  strIniFileName := string(GetConfigFileName);
  if System.SysUtils.Trim(strIniFileName) = '' then
    Exit;

  with TIniFile.Create(strIniFileName) do
  begin
    strEncLink := ReadString('DB', 'Name', '');
    if System.SysUtils.Trim(strEncLink) <> '' then
    begin
      strSQLLink       := DecryptString(strEncLink, c_strAESKey);
      ADOCNN.Connected := False;
      try
        ADOCNN.ConnectionString := strSQLLink;
        ADOCNN.KeepConnection   := True;
        ADOCNN.LoginPrompt      := False;
        ADOCNN.Connected        := True;
        btnDBLink.Enabled       := False;
        conADO.GetTableNames(lstTables.Items);
        btnQuery.Enabled := True;
      except
        btnDBLink.Enabled := True;
        ADOCNN.Connected  := False;
      end;
    end;
    Free;
  end;
end;

procedure TfrmDBView.CreateColumnField(const qry: TADOQuery);
var
  I: Integer;
begin
  for I := 0 to qry.FieldCount - 1 do
  begin
    with lvData.Columns.Add do
    begin
      Caption := qry.Fields[I].FieldName;
      Width   := 140;
    end;
  end;
end;

procedure TfrmDBView.btnQueryClick(Sender: TObject);
var
  strSQL: string;
begin
  if not ShowQryForm(strSQL) then
    Exit;

  lvData.OwnerData := False;
  qryData.Close;
  qryData.SQL.Clear;
  qryData.SQL.Text := strSQL;
  qryData.Open;
  if qryData.RecordCount > 1000 then
  begin
    lvData.OwnerData := True;
    Exit;
  end;

  lvData.Columns.Clear;
  lvData.Items.Clear;
  CreateColumnField(qryData);
  DisplayData(qryData);
end;

{ 保存到 EXCEL 文件 }
procedure TfrmDBView.SaveToXLSX_ADO(const strFileName: string);
var
  XLS    : TXLSReadWriteII5;
  I, J, K: Integer;
  intPos : Integer;
begin
  intPos                 := qryData.RecNo;
  btnDBLink.Enabled      := False;
  btnDataView.Enabled    := False;
  btnQuery.Enabled       := False;
  btnExportExcel.Enabled := False;
  Application.ProcessMessages;
  XLS := TXLSReadWriteII5.Create(nil);
  try
    XLS.FileName := dlgSaveExcel.FileName + '.xlsx';
    for I        := 1 to lvData.Columns.Count do
    begin
      for J := 1 to qryData.RecordCount + 1 do
      begin
        XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineStyle := cbsThin;
        XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineColor := 0;
      end;
    end;

    for I := 1 to lvData.Columns.Count do
    begin
      Application.ProcessMessages;
      XLS.Sheets[0].AsString[I, 1]                  := lvData.Column[I - 1].Caption;
      XLS.Sheets[0].Columns[I].Width                := 4000;
      XLS.Sheets[0].Cell[I, 1].FontColor            := clWhite;
      XLS.Sheets[0].Cell[I, 1].FontStyle            := XLS.Sheets[0].Cell[I, 1].FontStyle + [xfsBold];
      XLS.Sheets[0].Cell[I, 1].FillPatternForeColor := xcBlue;
      XLS.Sheets[0].Cell[I, 1].HorizAlignment       := chaCenter;
      XLS.Sheets[0].Cell[I, 1].VertAlignment        := cvaCenter;
    end;

    K := 2;
    qryData.First;
    while not qryData.Eof do
    begin
      J     := 1;
      for I := 1 to lvData.Columns.Count do
      begin
        if I = 1 then
          XLS.Sheets[0].AsInteger[J, K] := qryData.Fields[I].AsInteger
        else
          XLS.Sheets[0].AsString[J, K] := qryData.Fields[I].AsString;

        XLS.Sheets[0].Cell[J, K].HorizAlignment := chaCenter;
        XLS.Sheets[0].Cell[J, K].VertAlignment  := cvaCenter;
        Inc(J);
      end;
      Inc(K);
      btnExportExcel.Caption := Format('正在导出：%d', [K - 2]);
      qryData.Next;
    end;

    XLS.Write;
  finally
    XLS.Free;
    btnExportExcel.Caption := '数据导出到 Excel';
    btnDBLink.Enabled      := True;
    btnDataView.Enabled    := True;
    btnQuery.Enabled       := True;
    btnExportExcel.Enabled := True;
    qryData.RecNo          := intPos;
  end;
end;

procedure TfrmDBView.SaveToXLSX_Sqlite3(const strFileName: string);
var
  XLS : TXLSReadWriteII5;
  I, J: Integer;
begin
  btnDBLink.Enabled      := False;
  btnDataView.Enabled    := False;
  btnQuery.Enabled       := False;
  btnExportExcel.Enabled := False;
  Application.ProcessMessages;
  XLS := TXLSReadWriteII5.Create(nil);
  try
    XLS.FileName := dlgSaveExcel.FileName + '.xlsx';
    for I        := 1 to lvData.Columns.Count do
    begin
      for J := 1 to lvData.Items.Count + 1 do
      begin
        XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineStyle := cbsThin;
        XLS.Sheets[0].Range.Items[I, J, I, J].BorderOutlineColor := 0;
      end;
    end;

    for I := 1 to lvData.Columns.Count do
    begin
      Application.ProcessMessages;
      XLS.Sheets[0].AsString[I, 1]                  := lvData.Column[I - 1].Caption;
      XLS.Sheets[0].Columns[I].Width                := 4000;
      XLS.Sheets[0].Cell[I, 1].FontColor            := clWhite;
      XLS.Sheets[0].Cell[I, 1].FontStyle            := XLS.Sheets[0].Cell[I, 1].FontStyle + [xfsBold];
      XLS.Sheets[0].Cell[I, 1].FillPatternForeColor := xcBlue;
      XLS.Sheets[0].Cell[I, 1].HorizAlignment       := chaCenter;
      XLS.Sheets[0].Cell[I, 1].VertAlignment        := cvaCenter;
    end;

    for I := 0 to lvData.Items.Count - 1 do
    begin
      XLS.Sheets[0].AsString[1, I + 2] := lvData.Items[I].Caption;
      for J                            := 0 to lvData.Columns.Count - 2 do
      begin
        Application.ProcessMessages;
        XLS.Sheets[0].AsString[J + 2, I + 2] := lvData.Items[I].SubItems[J];
      end;
    end;

    XLS.Write;
  finally
    XLS.Free;
    btnExportExcel.Caption := '数据导出到 Excel';
    btnDBLink.Enabled      := True;
    btnDataView.Enabled    := True;
    btnQuery.Enabled       := True;
    btnExportExcel.Enabled := True;
  end;
end;

procedure TfrmDBView.btnExportExcelClick(Sender: TObject);
begin
  if not dlgSaveExcel.Execute then
    Exit;

  if not FbSqlite3 then
    SaveToXLSX_ADO(dlgSaveExcel.FileName)
  else
    SaveToXLSX_Sqlite3(dlgSaveExcel.FileName);
end;

end.
