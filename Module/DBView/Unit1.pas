unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.IniFiles, System.SysUtils, System.StrUtils, System.SyncObjs, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Data.Win.ADOConEd, Data.Win.ADODB, Data.DB,
  XLSReadWriteII5, Xc12Utils5, XLSUtils5, Xc12DataStyleSheet5, DB.uCommon;

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
  private
    procedure ReadDBFromConfig(ADOCNN: TADOConnection);
    procedure GetTableFieldType(const strTableName: string);
    function GetFieldType(const strTableName, strFieldName: string): String;
    function GetAutoAddField(const strTableName: String; var strAutoField: string): Boolean;
    function GetDisplayFields(const strTableName: string): String;
    function GetChineseFields(const strTableName, strDisplayFields: string): string;
    procedure CreateColumnField(const strChineseFields: string); overload;
    procedure CreateColumnField(const qry: TADOQuery); overload;
    procedure DisplayData(qry: TADOQuery);
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
  ReadDBFromConfig(conADO);
end;

procedure TfrmDBView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
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
  else if ft in [ftFloat, ftCurrency, ftBCD, ftExtended, ftSingle] then
    Result := '浮点数'
  else if ft in [ftDate, ftTime, ftDateTime] then
    Result := '日期'
  else if ft in [ftBytes, ftVarBytes, ftArray] then
    Result := '整数数组'
  else if ft = ftBoolean then
    Result := '布尔'
  else if ft in [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftWideMemo, ftObject] then
    Result := '二进制'
  else
    Result := '未知'
end;

procedure TfrmDBView.GetTableFieldType(const strTableName: string);
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
  strFields := strDisplayFields.Split([',']);
  with TADOQuery.Create(nil) do
  begin
    Connection := conADO;
    SQL.Text   := Format(c_strFieldChineseName, [QuotedStr(strTableName)]);
    Open;
    for I := 0 to Length(strFields) - 1 do
    begin
      if Locate('字段名', strFields[I], []) then
      begin
        strChineseField := Fields[1].AsString;
        if Trim(strChineseField) <> '' then
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

procedure TfrmDBView.btnDataViewClick(Sender: TObject);
var
  strAutoField    : String;
  strTableName    : String;
  strDisplayFields: String;
  strChineseFields: String;
begin
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

  if GetAutoAddField(strTableName, strAutoField) then
  begin
    lvData.OwnerData := True;
    qryData.Close;
    qryData.SQL.Clear;
    qryData.SQL.Text := 'select ROW_NUMBER() over(order by ' + strAutoField + ') as RowNum, ' + strDisplayFields + ' from ' + strTableName;
    qryData.Open;
    lvData.Items.Count := qryData.RecordCount;
  end
  else
  begin
    lvData.OwnerData := False;
    qryData.Close;
    qryData.SQL.Clear;
    qryData.SQL.Text := 'select top 1000' + strDisplayFields + ' from ' + strTableName;
    qryData.Open;
    DisplayData(qryData);
  end;
end;

procedure TfrmDBView.lvDataData(Sender: TObject; Item: TListItem);
var
  I: Integer;
begin
  qryData.RecNo := Item.Index + 1;
  Item.Caption  := qryData.Fields[1].AsString;
  for I         := 2 to qryData.Fields.Count - 1 do
  begin
    if qryData.Fields[I].DataType = ftBlob then
      Item.SubItems.Add('')
    else
      Item.SubItems.Add(qryData.Fields[I].AsString);
  end;
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
  if Trim(strIniFileName) = '' then
    Exit;

  with TIniFile.Create(strIniFileName) do
  begin
    strEncLink := ReadString('DB', 'Name', '');
    if Trim(strEncLink) <> '' then
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

procedure TfrmDBView.btnExportExcelClick(Sender: TObject);
var
  XLS    : TXLSReadWriteII5;
  I, J, K: Integer;
  intPos : Integer;
begin
  if not dlgSaveExcel.Execute then
    Exit;

  intPos                 := qryData.RecNo;
  btnDBLink.Enabled      := False;
  btnDataView.Enabled    := False;
  btnQuery.Enabled       := False;
  btnExportExcel.Enabled := False;
  Application.ProcessMessages;
  XLS := TXLSReadWriteII5.Create(nil);
  try
    XLS.Filename := dlgSaveExcel.Filename + '.xlsx';
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

end.
