unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.StrUtils, System.RegularExpressions, System.IniFiles, Vcl.Imaging.jpeg, db.uCommon,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus, Vcl.OleCtrls, SHDocVw, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdURI;

type
  TfrmSpider = class(TForm)
    mmoLog: TMemo;
    imgVW: TImage;
    pmLog: TPopupMenu;
    idhtpDown: TIdHTTP;
    tmrDown: TTimer;
    procedure tmrDownTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FintIndexCate: Integer;
    FintIndexPage: Integer;
    { 获取分类 }
    procedure GetCategory(const strHtml: string; var lstCategory: THashedStringList);
    { 获取某个分类的总页数 }
    function GetCategoryPageCount(const strCateHtml, strCateKey, strCateName: string): Integer;
    { 下载某个分类的所有页 }
    procedure DownCategroyAllPage(const strCateKey, strCateName: String; const Count: Integer);
    { 下载一页中所有的图片 }
    procedure DownCateOnePageAllImage(const strCateKey, strURL: string; const intPageIndex: Integer);
    { 下载一幅图片保存到磁盘 }
    function DownImageFile(const strCateKey, strImageURL: string; const intPageIndex: Integer): Boolean;
    procedure SaveDownIndex;
  end;

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;

implementation

{$R *.dfm}

procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strModuleName, strIconFileName: PAnsiChar); stdcall;
begin
  frm                     := TfrmSpider;
  strParentModuleName     := '网络管理';
  strModuleName           := '爬虫';
  strIconFileName         := '';
  Application.Handle      := GetMainFormApplication.Handle;
  Application.Icon.Handle := GetMainFormApplication.Icon.Handle;
end;

const
  c_strHTTPURL      = 'http://www.netbian.com';
  c_strCateURL      = c_strHTTPURL + '/%s';
  c_strPageURL      = c_strCateURL + '/index_%d.htm';
  c_strStart        = '<a href="http://pic.netbian.com/" target="_blank" style="color:#FFA800;" title="4k壁纸">4k壁纸</a>';
  c_strEnd          = '>LOL</a></div></li>';
  c_strHtml         = '<(\S*?)[^>]*>.*?</\1>|<.*? />';
  c_strDivi1        = '\"([^\"]*)\"';
  c_strDivi2        = '\>(\S*)\<';
  c_intLeng         = 95;
  c_ImageSize       = '1920x1080';
  c_strFileSavePath = 'F:\Picture';

procedure TfrmSpider.SaveDownIndex;
begin
  with TIniFile.Create(string(GetConfigFileName)) do
  begin
    writeInteger('Down', 'IndexCate', FintIndexCate);
    writeInteger('Down', 'IndexPage', FintIndexPage);
    Free;
  end;
end;

procedure TfrmSpider.FormDestroy(Sender: TObject);
begin
  SaveDownIndex;
end;

procedure TfrmSpider.tmrDownTimer(Sender: TObject);
var
  strHtml     : String;
  lstCategory : THashedStringList;
  I           : Integer;
  strCateURL  : String;
  intPageCount: Integer;
  strCateKey  : string;
  strCateValue: string;
  intIndex    : Integer;
begin
  tmrDown.Enabled := False;

  strHtml := idhtpDown.Get(c_strHTTPURL);
  if strHtml = '' then
    Exit;

  { 获取分类 }
  lstCategory := THashedStringList.Create;
  try
    GetCategory(strHtml, lstCategory);
    if lstCategory.Count = 0 then
      Exit;

    { 读取上次下载已经进行到的分类 }
    with TIniFile.Create(string(GetConfigFileName)) do
    begin
      intIndex := ReadInteger('Down', 'IndexCate', 0);
      Free;
    end;

    if intIndex >= lstCategory.Count - 1 then
      Exit;

    for I := intIndex to lstCategory.Count - 1 do
    begin
      { 当前下载分类 }
      FintIndexCate := I;

      Application.ProcessMessages;
      if Application.Terminated then
      begin
        SaveDownIndex;
        Break;
      end;

      strCateKey   := lstCategory.Names[I];
      strCateValue := lstCategory.ValueFromIndex[I];
      strCateURL   := Format(c_strCateURL, [strCateValue]) + '/index.htm';

      { 获取某个分类的总页数 }
      intPageCount := GetCategoryPageCount(strCateURL, strCateKey, strCateValue);

      { 下载某个分类的所有页 }
      DownCategroyAllPage(strCateKey, strCateValue, intPageCount);
    end;

    mmoLog.Lines.Add('下载完毕');
  finally
    lstCategory.Free;
  end;
end;

{ 获取分类 }
procedure TfrmSpider.GetCategory(const strHtml: string; var lstCategory: THashedStringList);
var
  strCate         : String;
  I, J            : Integer;
  mc, ms1, ms2    : TMatchCollection;
  mt, mp          : TMatch;
  strKey, strValue: string;
  strTemp         : String;
begin
  strTemp := '4K';
  I       := Pos(c_strStart, strHtml) + c_intLeng;
  J       := Pos(c_strEnd, strHtml);
  strCate := MidStr(strHtml, I, J - I + 8);
  mc      := TRegEx.Matches(strCate, c_strHtml);
  for mt in mc do
  begin
    strValue := '';
    I        := 0;
    J        := 0;
    ms1      := TRegEx.Matches(mt.Value, c_strDivi2);
    ms2      := TRegEx.Matches(mt.Value, c_strDivi1);
    for mp in ms2 do
    begin
      strValue := mp.Groups[1].Value;
      strValue := MidStr(strValue, 2, Length(strValue) - 2);
      Inc(I);
      if I mod 2 = 1 then
      begin
        strKey  := ms1.Item[J].Groups[1].Value;
        strTemp := strTemp + '、' + strKey;
        lstCategory.Add(Format('%s=%s', [strKey, strValue]));
        Inc(J);
      end;
    end;
  end;

  mmoLog.Lines.Add('分类：' + strTemp);
end;

{ 获取某个分类的总页数 }
function TfrmSpider.GetCategoryPageCount(const strCateHtml, strCateKey, strCateName: string): Integer;
const
  c_strPageCount = '…</span><a href="/%s/index_';
var
  strTemp     : String;
  strHtml     : String;
  strPageCount: String;
  I           : Integer;
begin
  Result := 0;
  try
    strHtml := idhtpDown.Get(strCateHtml);
  except
    SaveDownIndex;
  end;

  if strHtml = '' then
    Exit;

  strTemp := Format(c_strPageCount, [strCateName]);
  I       := Pos(strTemp, strHtml);
  if I <= 0 then
    Exit;

  strPageCount := MidStr(strHtml, I + Length(strTemp), 10);
  I            := Pos('.htm', strPageCount);
  if I <= 0 then
    Exit;

  strPageCount := LeftStr(strPageCount, I - 1);
  Result       := StrToInt(strPageCount);
end;

{ 下载某个分类的所有页 }
procedure TfrmSpider.DownCategroyAllPage(const strCateKey, strCateName: String; const Count: Integer);
var
  I         : Integer;
  strPageURL: string;
  intIndex  : Integer;
begin
  { 读取上次下载已经进行到的页面 }
  with TIniFile.Create(string(GetConfigFileName)) do
  begin
    intIndex := ReadInteger('Down', 'IndexPage', 0);
    Free;
  end;
  if intIndex >= Count - 1 then
    Exit;

  for I := intIndex to Count - 1 do
  begin
    { 当前下载页 }
    FintIndexPage := I;

    Application.ProcessMessages;
    if Application.Terminated then
    begin
      SaveDownIndex;
      Break;
    end;

    if I = 0 then
      strPageURL := Format(c_strCateURL, [strCateName]) + '/index.htm'
    else
      strPageURL := Format(c_strPageURL, [strCateName, I + 1]);

    { 下载一页中所有的图片 }
    DownCateOnePageAllImage(strCateKey, strPageURL, I + 1);
  end;
end;

{ 下载一页中所有的图片 }
procedure TfrmSpider.DownCateOnePageAllImage(const strCateKey, strURL: string; const intPageIndex: Integer);
const
  c_strliStart   = '<ul><li>';
  c_strliEnd     = '</b></a></li></ul>';
  c_strUrlStart  = '<a href="';
  c_strUrlEnd    = '.htm"';
  c_strUrlStart2 = '<tr><td align="left">';
  c_strUrlEnd2   = '/></a></td></tr>';
var
  strHtml      : String;
  I, J         : Integer;
  strli        : String;
  ms           : TMatchCollection;
  mp           : TMatch;
  mt           : TMatch;
  strPicUrl    : String;
  strPicDownURL: String;
begin
  try
    strHtml := idhtpDown.Get(strURL);
  except
    SaveDownIndex;
  end;

  if strHtml = '' then
    Exit;

  I := Pos(c_strliStart, strHtml);
  J := Pos(c_strliEnd, strHtml);
  if (I <= 0) or (J <= 0) then
    Exit;

  strli := MidStr(strHtml, I + 4, J - I + 9);
  if strli = '' then
    Exit;

  ms := TRegEx.Matches(strli, c_strHtml);
  if ms.Count = 0 then
    Exit;

  for mt in ms do
  begin
    Application.ProcessMessages;
    if Application.Terminated then
    begin
      SaveDownIndex;
      Break;
    end;

    I := Pos(c_strUrlStart, mt.Value);
    J := Pos(c_strUrlEnd, mt.Value);
    if (I <= 0) or (J <= 0) then
      Continue;

    strPicUrl := MidStr(mt.Value, I + 9, J - I - 5);
    strPicUrl := Format(c_strHTTPURL + '%s', [strPicUrl]);
    strPicUrl := ChangeFileExt(strPicUrl, Format('-%s.htm', [c_ImageSize]));

    try
      strHtml := idhtpDown.Get(strPicUrl);
      if strHtml = '' then
        Continue;

      I := Pos(c_strUrlStart2, strHtml);
      J := Pos(c_strUrlEnd2, strHtml);
      if (I <= 0) or (J <= 0) then
        Continue;

      strPicDownURL := MidStr(strHtml, I, J - I + 16);
      if strPicDownURL = '' then
        Continue;

      mp := TRegEx.Match(strPicDownURL, '\<a href=(\S*)\" title');
      if mp.Value = '' then
        Continue;

      mp := TRegEx.Match(mp.Value, '\"(\S*)"');
      if mp.Value = '' then
        Continue;

      { 下载一幅图片保存到磁盘 }
      strPicDownURL := mp.Groups[1].Value;
      DownImageFile(strCateKey, strPicDownURL, intPageIndex);
    except
      SaveDownIndex;
    end;
  end;
end;

{ 下载一幅图片保存到磁盘 }
function TfrmSpider.DownImageFile(const strCateKey, strImageURL: string; const intPageIndex: Integer): Boolean;
var
  imgMS      : TMemoryStream;
  strFilePath: String;
  strFileName: String;
  url        : TIdURI;
begin
  Result := True;

  { 检查保存目录是否存在，不在则创建 }
  url         := TIdURI.Create(strImageURL);
  strFilePath := Format(c_strFileSavePath + '\%s\%d', [strCateKey, intPageIndex]);
  if not DirectoryExists(strFilePath) then
    ForceDirectories(strFilePath);

  { 检查文件是否已经存在，如果存在就不重复下载了 }
  strFileName := strFilePath + '\' + url.Document;
  if FileExists(strFileName) then
  begin
    mmoLog.Lines.Add('下载：' + strImageURL + Chr(9) + '已经存在，无需重复下载');
    imgVW.Picture.LoadFromFile(strFileName);
    Exit;
  end;

  imgMS := TMemoryStream.Create;
  try
    try
      idhtpDown.Get(strImageURL, imgMS);
      if imgMS.Size = 0 then
        Exit;

      imgMS.SaveToFile(strFileName);
      imgVW.Picture.LoadFromFile(strFileName);
      mmoLog.Lines.Add('下载：' + strImageURL + Chr(9) + '成功');
    finally
      url.Free;
      imgMS.Free;
    end;
  except
    mmoLog.Lines.Add('下载：' + strImageURL + Chr(9) + '失败');
    Result := False;
    SaveDownIndex;
  end;
end;

end.
