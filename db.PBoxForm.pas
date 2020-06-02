unit db.PBoxForm;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, Winapi.IpTypes, System.SysUtils, System.StrUtils, System.Classes, System.Types, System.IniFiles, System.Math, System.UITypes, System.ImageList,
  Vcl.Graphics, Vcl.Controls, Vcl.Buttons, Vcl.Forms, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ImgList, Vcl.ToolWin, Data.Win.ADODB,
  db.uCommon, db.uBaseForm;

type
  TfrmPBox = class(TUIBaseForm)
    ilMainMenu: TImageList;
    pnlBottom: TPanel;
    mmMainMenu: TMainMenu;
    clbrPModule: TCoolBar;
    tlbPModule: TToolBar;
    pnlInfo: TPanel;
    lblInfo: TLabel;
    pnlTime: TPanel;
    lblTime: TLabel;
    tmrDateTime: TTimer;
    rzpgcntrlAll: TPageControl;
    tsButton: TTabSheet;
    tsList: TTabSheet;
    tsDll: TTabSheet;
    pnlIP: TPanel;
    lblIP: TLabel;
    bvlIP: TBevel;
    pmTray: TPopupMenu;
    mniTrayShowForm: TMenuItem;
    mniTrayLine01: TMenuItem;
    mniTrayExit: TMenuItem;
    imgDllFormBack: TImage;
    imgButtonBack: TImage;
    imgListBack: TImage;
    ilPModule: TImageList;
    pnlModuleDialog: TPanel;
    pnlModuleDialogTitle: TPanel;
    imgSubModuleClose: TImage;
    bvlModule01: TBevel;
    pnlWeb: TPanel;
    lblWeb: TLabel;
    bvlWeb: TBevel;
    bvlModule02: TBevel;
    pnlLogin: TPanel;
    lblLogin: TLabel;
    pmFuncMenu: TPopupMenu;
    mniFuncMenuConfig: TMenuItem;
    mniFuncMenuMoney: TMenuItem;
    mniFuncMenuLine01: TMenuItem;
    mniFuncMenuAbout: TMenuItem;
    pmAdapterList: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrDateTimeTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure mniTrayExitClick(Sender: TObject);
    procedure mniTrayShowFormClick(Sender: TObject);
    procedure imgSubModuleCloseClick(Sender: TObject);
    procedure imgSubModuleCloseMouseEnter(Sender: TObject);
    procedure imgSubModuleCloseMouseLeave(Sender: TObject);
    procedure mniFuncMenuConfigClick(Sender: TObject);
    procedure mniFuncMenuAboutClick(Sender: TObject);
    procedure mniFuncMenuMoneyClick(Sender: TObject);
    procedure pnlIPClick(Sender: TObject);
    procedure pnlTimeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FlstAllDll    : THashedStringList;
    FUIShowStyle  : TShowStyle;
    FbMaxForm     : Boolean;
    FDelphiDllForm: TForm;
    FintBakRow    : Integer;
    procedure ShowPageTabView(const bShow: Boolean = False);
    procedure ReadConfigUI;
    { 扫描 EXE 文件，读取配置文件 }
    procedure ScanPlugins_EXE;
    { 扫描 Dll 文件，仅限于插件目录(plugins) }
    procedure ScanPlugins_Dll;
    { 扫描插件目录 }
    procedure ScanPlugins;
    { 创建模块菜单 }
    procedure CreateModuleMenu;
    { 点击菜单 }
    procedure OnMenuItemClick(Sender: TObject);
    { 创建新的 Dll 窗体 }
    procedure CreateDllForm(const strPEFileName: String; const LangType: TLangType = ltDelphi);
    { 系统配置 }
    procedure OnSysConfig(Sender: TObject);
    { Delphi Dll Form 窗体关闭事件 }
    procedure OnDelphiDllFormDestoryCallback(Sender: TObject);
    { VC DLG Dll Form 窗体关闭事件 }
    procedure OnVCDllFormDestoryCallback(Sender: TObject);
    { EXE 程序关闭回调 }
    procedure OnPEProcessDestroyCallback(Sender: TObject);
    { 获取 EXE 文件的图标 }
    function GetExeFileIcon(const strFileName: String): Integer; overload;
    function GetExeFileIcon(const strEXEInfo, strFileName: string): Integer; overload;
    { 获取 Dll 文件的图标 }
    function GetDllFileIcon(const strPModuleName, strSModuleName, strIconFileName: string): Integer;
    function ReadDllIconFromConfig(const strPModule, strSModule: string): Integer;
    procedure ReCreate;
    { 界面显示风格 }
    procedure ChangeUI;
    { 菜单式风格 }
    procedure ChangeUI_Menu;
    { 按钮式风格 }
    procedure ChangeUI_Button;
    { 分栏式风格 }
    procedure ChangeUI_List(const bActivePage: Boolean = True);
    { 参数置空，恢复默认值 }
    procedure FillParamBlank;
    { 点击父模块时，动态创建子模块 }
    procedure OnParentModuleButtonClick(Sender: TObject);
    { 创建显示所有子模块对话框窗体 }
    procedure CreateSubModulesFormDialog(const strPModuleName: string); overload;
    procedure CreateSubModulesFormDialog(const mmItem: TMenuItem); overload;
    { 列表显示风格，创建子模块 DLL 窗体 }
    procedure OnSubModuleButtonClick(Sender: TObject);
    { 销毁分栏式界面 }
    procedure FreeListViewSubModule;
    { 窗体大小改变时，重新创建分栏式的界面 }
    procedure ResizeListViewSubModule;
    { 分栏式显示时，当鼠标进入 label 时 }
    procedure OnSubModuleMouseEnter(Sender: TObject);
    { 分栏式显示时，当鼠标离开 label 时 }
    procedure OnSubModuleMouseLeave(Sender: TObject);
    { 创建子模块 DLL 模块 }
    procedure OnSubModuleListClick(Sender: TObject);
    { 获取垂直位置最大间隔 }
    function GetMaxInstance: Integer;
    { 销毁 Dll 窗体 }
    procedure FreeDllForm;
    procedure OnAdapterDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure OnAdapterIPClick(Sender: TObject);
    function GetCurrentAdapterIP: String;
  public
    FAdoCNN: TADOConnection;
  end;

var
  frmPBox: TfrmPBox;

implementation

uses db.ConfigForm, db.DonateForm, db.AboutForm, db.uCreateDelphiDll, db.uCreateVCDll, db.uCreateEXE;

{$R *.dfm}

procedure TfrmPBox.mniFuncMenuMoneyClick(Sender: TObject);
begin
  ShowDonateForm;
end;

procedure TfrmPBox.mniFuncMenuAboutClick(Sender: TObject);
begin
  ShowAboutForm;
end;

{ 系统配置 }
procedure TfrmPBox.mniFuncMenuConfigClick(Sender: TObject);
begin
  if ShowConfigForm(FlstAllDll, FAdoCNN) then
  begin
    Hide;
    FreeDllForm;
    ReCreate;
    Show;
  end;
end;

{ 系统功能菜单 }
procedure TfrmPBox.OnSysConfig(Sender: TObject);
var
  img: TImage;
  pt : TPoint;
begin
  img  := TImage(Sender);
  pt.X := Left + img.Left + 8;
  pt.Y := Top + img.Top + img.Height;
  pmFuncMenu.Popup(pt.X, pt.Y);
end;

procedure TfrmPBox.OnAdapterDrawItem(Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  ACanvas.Font.Name := '宋体';
  ACanvas.Font.Size := 11;
  ACanvas.TextOut(ARect.Left, ARect.Top, (Sender as TMenuItem).Caption);
end;

procedure TfrmPBox.OnAdapterIPClick(Sender: TObject);
var
  strText       : string;
  strIP         : String;
  strName       : String;
  strIniFileName: String;
begin
  strText       := (Sender as TMenuItem).Caption;
  strIP         := Trim(LeftStr(strText, 19));
  strIP         := RightStr(strIP, Length(strIP) - 3);
  lblIP.Caption := strIP;

  strName        := Trim(RightStr(strText, Length(strText) - 42));
  strName        := RightStr(strName, Length(strName) - 6);
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    WriteString('Network', 'AdapterName', strName);
    Free;
  end;
end;

procedure TfrmPBox.pnlIPClick(Sender: TObject);
var
  lstAdapter : TList;
  I          : Integer;
  AdapterInfo: PIP_ADAPTER_INFO;
  strIP      : String;
  strGate    : String;
  strName    : String;
  mmItem     : TMenuItem;
  pt         : TPoint;
begin
  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count > 0 then
    begin
      pmAdapterList.Items.Clear;
      for I := 0 to lstAdapter.Count - 1 do
      begin
        AdapterInfo       := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
        strIP             := string(AdapterInfo^.IpAddressList.IpAddress.S);
        strGate           := string(AdapterInfo^.GatewayList.IpAddress.S);
        strName           := string(AdapterInfo^.Description);
        mmItem            := TMenuItem.Create(pmAdapterList);
        mmItem.Caption    := Format('IP: ' + '%-16s Gate: %-16s Name: %-80s', [strIP, strGate, strName]);
        mmItem.OnDrawItem := OnAdapterDrawItem;
        mmItem.OnClick    := OnAdapterIPClick;
        pmAdapterList.Items.Add(mmItem);
      end;
      if pmAdapterList.Items.Count > 1 then
      begin
        pt.X := pnlIP.Left + Left;
        pt.Y := Top + Height + 2;
        pmAdapterList.Popup(pt.X, pt.Y);
      end;
    end;
  finally
    lstAdapter.Free;
  end;
end;

procedure TfrmPBox.pnlTimeClick(Sender: TObject);
begin
  WinExec(PAnsiChar('rundll32.exe Shell32.dll,Control_RunDLL intl.cpl,,/p:"date"'), SW_SHOW);
end;

function TfrmPBox.GetCurrentAdapterIP: String;
var
  strName       : String;
  strIniFileName: String;
  I             : Integer;
  lstAdapter    : TList;
  AdapterInfo   : PIP_ADAPTER_INFO;
begin
  strIniFileName := ChangeFileExt(ParamStr(0), '.ini');
  with TIniFile.Create(strIniFileName) do
  begin
    strName := ReadString('Network', 'AdapterName', strName);
    Free;
  end;

  if Trim(strName) = '' then
  begin
    Result := GetNativeIP;
    Exit;
  end;

  lstAdapter := TList.Create;
  try
    GetAdapterInfo(lstAdapter);
    if lstAdapter.Count > 0 then
    begin
      for I := 0 to lstAdapter.Count - 1 do
      begin
        AdapterInfo := PIP_ADAPTER_INFO(lstAdapter.Items[I]);
        if SameText(string(AdapterInfo^.Description), strName) then
        begin
          Result := string(AdapterInfo^.IpAddressList.IpAddress.S);
          Break;
        end;
      end;
    end;
  finally
    lstAdapter.Free;
  end;
end;

{ EXE 程序关闭回调 }
procedure TfrmPBox.OnPEProcessDestroyCallback(Sender: TObject);
begin
  Application.MainForm.Tag := 0;

  lblInfo.Caption := '';
  if FUIShowStyle = ssButton then
    rzpgcntrlAll.ActivePageIndex := 0
  else if FUIShowStyle = ssList then
    rzpgcntrlAll.ActivePageIndex := 1;
end;

{ Delphi Dll Form 窗体关闭事件 }
procedure TfrmPBox.OnDelphiDllFormDestoryCallback(Sender: TObject);
begin
  if FDelphiDllForm <> nil then
  begin
    FreeLibrary(FDelphiDllForm.Tag);
    FDelphiDllForm := nil;

    lblInfo.Caption := '';
    if FUIShowStyle = ssButton then
      rzpgcntrlAll.ActivePageIndex := 0
    else if FUIShowStyle = ssList then
      rzpgcntrlAll.ActivePageIndex := 1;
  end;
end;

{ VC Dll Form 窗体关闭事件 }
procedure TfrmPBox.OnVCDllFormDestoryCallback(Sender: TObject);
begin
  { 界面还原 }
  lblInfo.Caption := '';
  if FUIShowStyle = ssButton then
    rzpgcntrlAll.ActivePageIndex := 0
  else if FUIShowStyle = ssList then
    rzpgcntrlAll.ActivePageIndex := 1;
end;

{ 创建新的 Dll 窗体 }
procedure TfrmPBox.CreateDllForm(const strPEFileName: String; const LangType: TLangType = ltDelphi);
begin
  if strPEFileName = '' then
    Exit;

  { 设置 DLL 搜索路径 }
  SetDllSearchPath;

  { 运行 EXE 文件 }
  if LangType = ltEXE then
  begin
    if (CompareText(ExtractFileExt(strPEFileName), '.exe') = 0) or (CompareText(ExtractFileExt(strPEFileName), '.msc') = 0) then
    begin
      PBoxRun_IMAGE_EXE(strPEFileName, FlstAllDll.Values[strPEFileName], tsDll, lblInfo, OnPEProcessDestroyCallback);
      Exit;
    end;
  end;

  { 运行 DELPHI DLL 窗体 }
  if LangType = ltDelphi then
  begin
    PBoxRun_DelphiDll(FDelphiDllForm, strPEFileName, tsDll, FAdoCNN, OnDelphiDllFormDestoryCallback);
    Exit;
  end;

  { 运行 VC DLL 窗体 }
  if LangType = ltVC then
  begin
    PBoxRun_VCDll(strPEFileName, rzpgcntrlAll, tsDll, OnVCDllFormDestoryCallback);
    Exit;
  end;
end;

{ 点击菜单 }
procedure TfrmPBox.OnMenuItemClick(Sender: TObject);
var
  strTip  : String;
  LangType: TLangType;
begin
  strTip := TMenuItem(TMenuItem(Sender).Owner).Caption + ' - ' + TMenuItem(Sender).Caption;

  { 如果已经创建了，就不在重复创建了 }
  if SameText(strTip, lblInfo.Caption) then
    Exit;

  lblInfo.Caption := strTip;

  { 销毁上一次创建的 Dll 窗体 }
  FreeDllForm;

  { 创建新的 Dll 窗体 }
  LangType := TLangType(StrToInt(FlstAllDll.ValueFromIndex[TMenuItem(Sender).Tag].Split([';'])[6]));
  CreateDllForm(FlstAllDll.Names[TMenuItem(Sender).Tag], LangType);
end;

function TfrmPBox.GetExeFileIcon(const strFileName: String): Integer;
var
  IcoExe: TIcon;
begin
  Result := -1;
  if CompareText(ExtractFileExt(strFileName), '.msc') = 0 then
  begin
    IcoExe := TIcon.Create;
    try
      { 从 .msc 文件中获取图标 }
      LoadIconFromMSCFile(strFileName, IcoExe);
      Result := ilMainMenu.AddIcon(IcoExe);
    finally
      IcoExe.Free;
    end;
  end
  else
  begin
    if ExtractIcon(HInstance, PChar(strFileName), $FFFFFFFF) > 0 then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.Handle := ExtractIcon(HInstance, PChar(strFileName), 0);
        Result        := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
  end;
end;

{ 获取 EXE 文件的图标 }
function TfrmPBox.GetExeFileIcon(const strEXEInfo, strFileName: string): Integer;
var
  strIconFileName    : String;
  IcoExe             : TIcon;
  strCurrIconFileName: String;
begin
  strIconFileName := strEXEInfo.Split([';'])[4];
  if Trim(strIconFileName) = '' then
  begin
    Result := GetExeFileIcon(strFileName);
  end
  else
  begin
    if FileExists(strIconFileName) then
    begin
      strCurrIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\Icon\' + ExtractFileName(strIconFileName);

      if not DirectoryExists(ExtractFilePath(strCurrIconFileName)) then
        ForceDirectories(ExtractFilePath(strCurrIconFileName));

      if not FileExists(strCurrIconFileName) then
        CopyFile(PChar(strIconFileName), PChar(strCurrIconFileName), False);

      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strCurrIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end
    else
    begin
      Result := GetExeFileIcon(strFileName);
    end;
  end;
end;

{ 扫描 EXE 文件，读取配置文件 }
procedure TfrmPBox.ScanPlugins_EXE;
var
  lstEXE      : TStringList;
  I           : Integer;
  strEXEInfo  : String;
  strFileName : String;
  intIconIndex: Integer;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    lstEXE := TStringList.Create;
    try
      ReadSection('EXE', lstEXE);
      for I := 0 to lstEXE.Count - 1 do
      begin
        strFileName  := lstEXE.Strings[I];
        strEXEInfo   := ReadString('EXE', strFileName, '');
        intIconIndex := GetExeFileIcon(strEXEInfo, strFileName);
        if strEXEInfo.CountChar(';') = 4 then
          strEXEInfo := strEXEInfo + ';' + IntToStr(intIconIndex)
        else
          strEXEInfo := strEXEInfo + ';;' + IntToStr(intIconIndex);
        strEXEInfo   := strEXEInfo + ';' + IntToStr(Integer(TLangType(ltEXE)));
        FlstAllDll.Add(Format('%s=%s', [strFileName, strEXEInfo]));
      end;
    finally
      lstEXE.Free;
    end;
    Free;
  end;
end;

function TfrmPBox.ReadDllIconFromConfig(const strPModule, strSModule: string): Integer;
var
  strIconFilePath: String;
  strIconFileName: String;
  IcoExe         : TIcon;
begin
  Result := -1;
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    strIconFilePath := ReadString(c_strIniModuleSection, Format('%s_%s_ICON', [strPModule, strSModule]), '');
    strIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + strIconFilePath;
    if FileExists(strIconFileName) then
    begin
      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end;
    Free;
  end;
end;

{ 获取 Dll 文件的图标 }
function TfrmPBox.GetDllFileIcon(const strPModuleName, strSModuleName, strIconFileName: string): Integer;
var
  strCurrIconFileName: String;
  IcoExe             : TIcon;
begin
  if Trim(strIconFileName) = '' then
  begin
    { 从配置文件中读取图标信息 }
    Result := ReadDllIconFromConfig(strPModuleName, strSModuleName);
  end
  else
  begin
    if FileExists(strIconFileName) then
    begin
      strCurrIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + ExtractFileName(strIconFileName);
      if not DirectoryExists(ExtractFilePath(strCurrIconFileName)) then
        ForceDirectories(ExtractFilePath(strCurrIconFileName));
      if not FileExists(strCurrIconFileName) then
        CopyFile(PChar(strIconFileName), PChar(strCurrIconFileName), False);

      IcoExe := TIcon.Create;
      try
        IcoExe.LoadFromFile(strCurrIconFileName);
        Result := ilMainMenu.AddIcon(IcoExe);
      finally
        IcoExe.Free;
      end;
    end
    else
    begin
      { 从配置文件中读取图标信息 }
      Result := ReadDllIconFromConfig(strPModuleName, strSModuleName);
    end;
  end;
end;

procedure TfrmPBox.ScanPlugins_Dll;
var
  hDll                                           : HMODULE;
  pFunc                                          : Pointer;
  frm                                            : TFormClass;
  strPModuleName, strSModuleName, strIconFileName: PAnsiChar;
  strVCClassName, strVCWindowName                : PAnsiChar;
  strDllFileName                                 : String;
  strInfo                                        : string;
  I, Count                                       : Integer;
  lstTemp                                        : TStringList;
  intIconIndex                                   : Integer;
  vcType                                         : TVCDllType;
  LangType                                       : TLangType;
begin
  lstTemp := TStringList.Create;
  try
    { 扫描 Dll 文件，仅限于插件目录(plugins) }
    SearchPlugInsDllFile(lstTemp);
    Count := lstTemp.Count;
    if Count <= 0 then
      Exit;

    for I := 0 to Count - 1 do
    begin
      strDllFileName := lstTemp.Strings[I];
      hDll           := LoadLibrary(PChar(strDllFileName));
      if hDll = 0 then
      begin
        if CompareText(lowerCase(ExtractFileName(strDllFileName)), 'snap.dll') = 0 then
          MessageBox(Handle, PChar('加载 snap.dll 出错，原因：机器上没有检测到 DirectX9'), c_strMsgTitle, 64)
        else
          MessageBox(Handle, PChar(Format('加载 %s 出错，原因：%d', [ExtractFileName(strDllFileName), GetLastError])), c_strMsgTitle, 64);
        Continue;
      end;

      try
        pFunc := GetProcAddress(hDll, c_strDllExportName);
        if not Assigned(pFunc) then
        begin
          FreeLibrary(hDll);
          Continue;
        end;

        { 获取 Dll 参数 }
        strVCClassName  := '';
        strVCWindowName := '';
        LangType        := ltVC;
        Tdb_ShowDllForm_Plugins_VCForm(pFunc)(vcType, strPModuleName, strSModuleName, strIconFileName, strVCClassName, strVCWindowName);
        if (strVCClassName = '') and (strVCWindowName = '') then
        begin
          LangType := ltDelphi;
          Tdb_ShowDllForm_Plugins_Delphi(pFunc)(frm, strPModuleName, strSModuleName, strIconFileName);
          strVCClassName  := '';
          strVCWindowName := '';
        end;
        intIconIndex := GetDllFileIcon(string(strPModuleName), string(strSModuleName), string(strIconFileName));
        strInfo      := strDllFileName + '=' + string(strPModuleName) + ';' + string(strSModuleName) + ';' + string(strVCClassName) + ';' + string(strVCWindowName) + ';' + string(strIconFileName) + ';' + IntToStr(intIconIndex) + ';' + IntToStr(Integer(LangType));
        FlstAllDll.Add(strInfo);
      finally
        FreeLibrary(hDll);
      end;
    end;
  finally
    lstTemp.Free;
  end;
end;

{ 创建模块菜单 }
procedure TfrmPBox.CreateModuleMenu;
var
  I             : Integer;
  strInfo       : String;
  strPModuleName: String;
  strSModuleName: String;
  mmPM          : TMenuItem;
  mmSM          : TMenuItem;
  intIconIndex  : Integer;
begin
  for I := 0 to FlstAllDll.Count - 1 do
  begin
    strInfo        := FlstAllDll.ValueFromIndex[I];
    strPModuleName := strInfo.Split([';'])[0];
    strSModuleName := strInfo.Split([';'])[1];
    intIconIndex   := StrToInt(strInfo.Split([';'])[5]);

    { 如果父菜单不存在，创建父菜单 }
    mmPM := mmMainMenu.Items.Find(string(strPModuleName));
    if mmPM = nil then
    begin
      mmPM         := TMenuItem.Create(mmMainMenu);
      mmPM.Caption := string((strPModuleName));
      mmMainMenu.Items.Add(mmPM);
    end;

    { 创建子菜单 }
    mmSM            := TMenuItem.Create(mmPM);
    mmSM.Caption    := string((strSModuleName));
    mmSM.Tag        := I;
    mmSM.ImageIndex := intIconIndex;
    mmSM.OnClick    := OnMenuItemClick;
    mmPM.Add(mmSM);
  end;
end;

{ 扫描插件目录 }
procedure TfrmPBox.ScanPlugins;
begin
//  { 设置 DLL 搜索路径 }
//  SetDllSearchPath;
//
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'plugins') then
    Exit;

  { 扫描 Dll 文件，添加到列表；当前插件目录 (plugins) }
  ScanPlugins_Dll;

  { 扫描 EXE 文件，添加到列表；读取配置文件 }
  ScanPlugins_EXE;

  { 排序模块 }
  SortModuleList(FlstAllDll);

  { 创建模块菜单 }
  CreateModuleMenu;
end;

procedure TfrmPBox.tmrDateTimeTimer(Sender: TObject);
const
  WeekDay: array [1 .. 7] of String = ('星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六');
var
  strWebDownSpeed, strWebUpSpeed: String;
begin
  lblTime.Caption := DateTimeToStr(Now) + ' ' + WeekDay[DayOfWeek(Now)];
  GetWebSpeed(strWebDownSpeed, strWebUpSpeed);
  lblWeb.Caption := Format('下载↓：%s  上传↑：%s', [strWebDownSpeed, strWebUpSpeed]);
end;

procedure TfrmPBox.ShowPageTabView(const bShow: Boolean);
var
  I: Integer;
begin
  for I := 0 to rzpgcntrlAll.PageCount - 1 do
  begin
    rzpgcntrlAll.Pages[I].TabVisible := bShow;
  end;
end;

procedure TfrmPBox.ReadConfigUI;
var
  bShowImage  : Boolean;
  strImageBack: String;
begin
  with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
  begin
    Caption        := ReadString(c_strIniUISection, 'Title', c_strTitle);
    TitleString    := Caption;
    MulScreenPos   := ReadBool(c_strIniUISection, 'MulScreen', False);
    FbMaxForm      := ReadBool(c_strIniUISection, 'MAXSIZE', False);
    FormStyle      := TFormStyle(Integer(ReadBool(c_strIniUISection, 'OnTop', False)) * 3);
    CloseToTray    := ReadBool(c_strIniUISection, 'CloseMini', False);
    pnlWeb.Visible := ReadBool(c_strIniUISection, 'ShowWebSpeed', False);
    bShowImage     := ReadBool(c_strIniUISection, 'showbackimage', False);
    strImageBack   := ReadString(c_strIniUISection, 'filebackimage', '');
    if (bShowImage) and (Trim(strImageBack) <> '') and (FileExists(strImageBack)) then
    begin
      imgDllFormBack.Picture.LoadFromFile(strImageBack);
      imgButtonBack.Picture.LoadFromFile(strImageBack);
      imgListBack.Picture.LoadFromFile(strImageBack);
    end
    else
    begin
      imgDllFormBack.Picture.Assign(nil);
      imgButtonBack.Picture.Assign(nil);
      imgListBack.Picture.Assign(nil);
    end;
    Free;
  end;
end;

{ 参数置空，恢复默认值 }
procedure TfrmPBox.FillParamBlank;
var
  I, J: Integer;
begin
  FUIShowStyle        := GetShowStyle;
  FDelphiDllForm      := nil;
  clbrPModule.Visible := False;
  pnlWeb.Visible      := False;
  lblInfo.Caption     := '';
  tlbPModule.Images   := nil;
  tlbPModule.Height   := 30;
  tlbPModule.Menu     := nil;
  FintBakRow          := 0;
  ilMainMenu.Clear;
  ilPModule.Clear;

  for I := tlbPModule.ButtonCount - 1 downto 0 do
  begin
    tlbPModule.Buttons[I].Free;
  end;

  mmMainMenu.AutoMerge := False;
  for I                := mmMainMenu.Items.Count - 1 downto 0 do
  begin
    for J := mmMainMenu.Items.Items[I].Count - 1 downto 0 do
    begin
      mmMainMenu.Items.Items[I].Items[J].Free;
    end;
    mmMainMenu.Items.Items[I].Free;
  end;
  mmMainMenu.Items.Clear;

  FlstAllDll.Clear;
end;

procedure TfrmPBox.ReCreate;
begin
  { 初始化参数 }
  FillParamBlank;

  { 初始化界面 }
  ShowPageTabView(False);
  rzpgcntrlAll.ActivePage := tsDll;
  ReadConfigUI;

  { 扫描插件目录 }
  ScanPlugins;

  { 界面显示风格 }
  ChangeUI;
end;

procedure TfrmPBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  { 是否有 VC Dll 窗体存在 }
  if Application.Tag <> 0 then
  begin
    { 关闭窗体 }
    FreeVCDllForm(True);
  end;
end;

procedure TfrmPBox.FormCreate(Sender: TObject);
begin
  { 列表显示风格，关闭按钮状态 }
  LoadButtonBmp(imgSubModuleClose, 'Close', 0);
  OnConfig      := OnSysConfig;
  TrayIconPMenu := pmTray;
  FlstAllDll    := THashedStringList.Create;
  CheckPlugInConfigSize;

  { 显示 时间 }
  tmrDateTime.OnTimer(nil);

  { 显示 IP }
  lblIP.Caption := GetCurrentAdapterIP;

  ReCreate;
end;

procedure TfrmPBox.FormActivate(Sender: TObject);
begin
  { 最大化窗体 }
  if FbMaxForm then
    pnlDBLClick(nil);
end;

{ 销毁 Dll/EXE 窗体 }
procedure TfrmPBox.FreeDllForm;
begin
  { 是否有 EXE 窗体存在 }
  if Application.MainForm.Tag <> 0 then
    FreeExeForm;

  { 是否有 VC Dll 窗体存在 }
  if Application.Tag <> 0 then
    FreeVCDllForm;

  { 是否有 Delphi Dll 窗体存在 }
  if FDelphiDllForm <> nil then
    FreeDelphiDllForm;
end;

procedure TfrmPBox.FormDestroy(Sender: TObject);
begin
  FreeDllForm;
  FlstAllDll.Free;
end;

function EnumChildFunc(hDllForm: THandle; hParentHandle: THandle): Boolean; stdcall;
var
  rctClient: TRect;
begin
  Result := True;

  { 判断是否是 Dll 的窗体句柄 }
  if GetParent(hDllForm) = 0 then
  begin
    { 更改 Dll 窗体大小 }
    GetWindowRect(hParentHandle, rctClient);
    SetWindowPos(hDllForm, hParentHandle, 0, 0, rctClient.Width, rctClient.Height, SWP_NOZORDER + SWP_NOACTIVATE);
  end;
end;

procedure TfrmPBox.FormResize(Sender: TObject);
begin
  { 更改 Dll 窗体大小 }
  EnumChildWindows(Handle, @EnumChildFunc, tsDll.Handle);

  if FUIShowStyle = ssButton then
  begin
    pnlModuleDialog.Top  := clbrPModule.Height + (pnlModuleDialog.Parent.Height - pnlModuleDialog.Height) div 2 - 60;
    pnlModuleDialog.Left := (pnlModuleDialog.Parent.Width - pnlModuleDialog.Width) div 2;
  end;

  if FUIShowStyle = ssList then
  begin
    ResizeListViewSubModule;
  end;
end;

procedure TfrmPBox.mniTrayShowFormClick(Sender: TObject);
begin
  MainTrayIcon.OnDblClick(nil);
end;

procedure TfrmPBox.mniTrayExitClick(Sender: TObject);
begin
  CloseToTray := False;
  Close;
end;

{ 界面显示风格 }
procedure TfrmPBox.ChangeUI;
begin
  case FUIShowStyle of
    ssMenu:
      ChangeUI_Menu;   // 菜单式
    ssButton:          //
      ChangeUI_Button; // 按钮式
    ssList:            //
      ChangeUI_List;   // 分栏式
  end;
end;

{ ------------------------------------------------------------------------------- 菜单式风格 ------------------------------------------------------------------------------- }
procedure TfrmPBox.ChangeUI_Menu;
begin
  tlbPModule.Menu      := mmMainMenu;
  mmMainMenu.AutoMerge := True;
  clbrPModule.Visible  := True;
end;

{ ------------------------------------------------------------------------------- 按钮式风格 ------------------------------------------------------------------------------- }
procedure TfrmPBox.imgSubModuleCloseClick(Sender: TObject);
var
  I: Integer;
begin
  pnlModuleDialog.Visible := False;
  for I                   := 0 to tlbPModule.ButtonCount - 1 do
  begin
    tlbPModule.Buttons[I].Down := False;
  end;
  lblInfo.Caption := '';
end;

procedure TfrmPBox.imgSubModuleCloseMouseEnter(Sender: TObject);
begin
  { 列表显示风格，关闭按钮状态 }
  LoadButtonBmp(imgSubModuleClose, 'Close', 1);
end;

procedure TfrmPBox.imgSubModuleCloseMouseLeave(Sender: TObject);
begin
  { 列表显示风格，关闭按钮状态 }
  LoadButtonBmp(imgSubModuleClose, 'Close', 0);
end;

{ 列表显示风格，创建子模块 DLL 窗体 }
procedure TfrmPBox.OnSubModuleButtonClick(Sender: TObject);
var
  I, J         : Integer;
  mmItem       : TMenuItem;
  strPMouleName: string;
  strSMouleName: string;
begin
  mmItem := nil;

  for I := 0 to tlbPModule.ButtonCount - 1 do
  begin
    if tlbPModule.Components[I] is TToolButton then
    begin
      if TToolButton(tlbPModule.Components[I]).Down then
      begin
        strPMouleName := TToolButton(tlbPModule.Components[I]).Caption;
        Break;
      end;
    end;
  end;
  strSMouleName := TSpeedButton(Sender).Caption;

  for I := 0 to mmMainMenu.Items.Count - 1 do
  begin
    if SameText(mmMainMenu.Items.Items[I].Caption, strPMouleName) then
    begin
      for J := 0 to mmMainMenu.Items.Items[I].Count - 1 do
      begin
        if SameText(mmMainMenu.Items.Items[I].Items[J].Caption, strSMouleName) then
        begin
          mmItem := mmMainMenu.Items.Items[I].Items[J];
          Break;
        end;
      end;
    end;
  end;

  pnlModuleDialog.Visible := True;
  OnMenuItemClick(mmItem);
end;

{ 创建显示所有子模块对话框窗体 }
procedure TfrmPBox.CreateSubModulesFormDialog(const mmItem: TMenuItem);
const
  c_intCols         = 5;
  c_intButtonWidth  = 128;
  c_intButtonHeight = 64;
  c_intMiniTop      = 2;
  c_intMiniLeft     = 2;
  c_intHorSpace     = 2;
  c_intVerSpace     = 2;
var
  arrSB   : array of TSpeedButton;
  I, Count: Integer;
begin
  { 释放先前创建的按钮 }
  Count := pnlModuleDialog.ComponentCount;
  if Count > 0 then
  begin
    for I := Count - 1 downto 0 do
    begin
      if pnlModuleDialog.Components[I] is TSpeedButton then
      begin
        TSpeedButton(pnlModuleDialog.Components[I]).Free;
      end;
    end;
  end;

  { 创建新的子模块按钮 }
  SetLength(arrSB, mmItem.Count);
  for I := 0 to mmItem.Count - 1 do
  begin
    arrSB[I]            := TSpeedButton.Create(pnlModuleDialog);
    arrSB[I].Parent     := pnlModuleDialog;
    arrSB[I].Caption    := mmItem.Items[I].Caption;
    arrSB[I].Width      := c_intButtonWidth;
    arrSB[I].Height     := c_intButtonHeight;
    arrSB[I].GroupIndex := 1;
    arrSB[I].Flat       := True;
    arrSB[I].Top        := pnlModuleDialogTitle.Height + c_intMiniTop + (c_intCols + c_intButtonHeight + c_intVerSpace) * (I div c_intCols);
    arrSB[I].Left       := c_intMiniLeft + (c_intButtonWidth + c_intHorSpace) * (I mod c_intCols);
    arrSB[I].Tag        := mmItem.Items[I].Tag;
    arrSB[I].OnClick    := OnSubModuleButtonClick;
    ilMainMenu.GetBitmap(mmItem.Items[I].ImageIndex, arrSB[I].Glyph);
  end;
  pnlModuleDialog.Visible := True;
end;

{ 创建显示所有子模块对话框窗体 }
procedure TfrmPBox.CreateSubModulesFormDialog(const strPModuleName: string);
var
  I: Integer;
begin
  for I := 0 to mmMainMenu.Items.Count - 1 do
  begin
    if CompareText(mmMainMenu.Items.Items[I].Caption, strPModuleName) = 0 then
    begin
      CreateSubModulesFormDialog(mmMainMenu.Items.Items[I]);
      Break;
    end;
  end;
end;

{ 点击父模块时，动态创建子模块 }
procedure TfrmPBox.OnParentModuleButtonClick(Sender: TObject);
var
  I             : Integer;
  strPMdouleName: string;
begin
  rzpgcntrlAll.ActivePage := tsButton;
  for I                   := 0 to tlbPModule.ButtonCount - 1 do
  begin
    tlbPModule.Buttons[I].Down := False;
  end;
  TToolButton(Sender).Down     := True;
  strPMdouleName               := TToolButton(Sender).Caption;
  pnlModuleDialogTitle.Caption := strPMdouleName;
  CreateSubModulesFormDialog(strPMdouleName);
end;

{ 按钮式风格 }
procedure TfrmPBox.ChangeUI_Button;
var
  tmpTB          : TToolButton;
  I              : Integer;
  strIconFilePath: String;
  strIconFileName: String;
  icoPModule     : TIcon;
begin
  tlbPModule.Images := ilPModule;
  tlbPModule.Height := 58;

  { 获取所有父模块图标 }
  for I := 0 to mmMainMenu.Items.Count - 1 do
  begin
    with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    begin
      strIconFilePath := mmMainMenu.Items.Items[I].Caption + '_ICON';
      strIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + ReadString(c_strIniModuleSection, strIconFilePath, '');
      Free;
    end;

    if FileExists(strIconFileName) then
    begin
      icoPModule := TIcon.Create;
      try
        icoPModule.LoadFromFile(strIconFileName);
        ilPModule.AddIcon(icoPModule);
      finally
        icoPModule.Free;
      end;
    end;
  end;

  for I := mmMainMenu.Items.Count - 1 downto 0 do
  begin
    tmpTB            := TToolButton.Create(tlbPModule);
    tmpTB.Parent     := tlbPModule;
    tmpTB.Caption    := mmMainMenu.Items.Items[I].Caption;
    tmpTB.ImageIndex := I;
    tmpTB.OnClick    := OnParentModuleButtonClick;
  end;
  clbrPModule.Visible := True;
end;

{ ------------------------------------------------------------------------------- 分栏式风格 ------------------------------------------------------------------------------- }

{ 分栏式显示时，当鼠标进入 label 时 }
procedure TfrmPBox.OnSubModuleMouseEnter(Sender: TObject);
begin
  TLabel(Sender).Font.Color := RGB(0, 0, 255);
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style + [fsUnderline];
end;

{ 分栏式显示时，当鼠标离开 label 时 }
procedure TfrmPBox.OnSubModuleMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Color := RGB(51, 153, 255);
  TLabel(Sender).Font.Style := TLabel(Sender).Font.Style - [fsUnderline];
end;

{ 创建子模块 DLL 模块 }
procedure TfrmPBox.OnSubModuleListClick(Sender: TObject);
var
  intTag: Integer;
  I, J  : Integer;
  mmItem: TMenuItem;
begin
  mmItem := nil;
  intTag := TLabel(Sender).Tag;
  for I  := 0 to mmMainMenu.Items.Count - 1 do
  begin
    for J := 0 to mmMainMenu.Items.Items[I].Count - 1 do
    begin
      if mmMainMenu.Items.Items[I].Items[J].Tag = intTag then
      begin
        mmItem := mmMainMenu.Items.Items[I].Items[J];
        Break;
      end;
    end;
  end;

  if mmItem <> nil then
    OnMenuItemClick(mmItem);
end;

{ 销毁分栏式界面 }
procedure TfrmPBox.FreeListViewSubModule;
var
  I: Integer;
begin
  for I := tsList.ComponentCount - 1 downto 0 do
  begin
    if tsList.Components[I] is TLabel then
    begin
      TLabel(tsList.Components[I]).Free;
    end
    else if tsList.Components[I] is TImage then
    begin
      if TImage(tsList.Components[I]).Name = '' then
      begin
        TImage(tsList.Components[I]).Free;
      end;
    end;
  end;
end;

{ 窗体大小改变时，重新创建分栏式的界面 }
procedure TfrmPBox.ResizeListViewSubModule;
begin
  if FUIShowStyle = ssList then
  begin
    { 重新创建分栏式显示界面 }
    ChangeUI_List(False);
  end;
end;

function TfrmPBox.GetMaxInstance: Integer;
{ 获取垂直位置最大间隔 }
var
  intMax               : Integer;
  arrInt               : array of Integer;
  I                    : Integer;
  intLabelPModuleHeight: Integer;
  intLabelSModuleHeight: Integer;
begin
  { 取最多行的模块个数 }
  SetLength(arrInt, mmMainMenu.Items.Count);
  for I := 0 to mmMainMenu.Items.Count - 1 do
  begin
    arrInt[I] := mmMainMenu.Items.Items[I].Count;
  end;
  intMax := MaxIntValue(arrInt);

  intLabelPModuleHeight := GetLabelHeight('宋体', 17);
  intLabelSModuleHeight := GetLabelHeight('宋体', 12);

  if intMax mod 3 = 0 then
    Result := (intLabelSModuleHeight + c_intBetweenVerticalDistance * 2) * (0 + intMax div 3) + intLabelPModuleHeight
  else
    Result := (intLabelSModuleHeight + c_intBetweenVerticalDistance * 2) * (1 + intMax div 3) + intLabelPModuleHeight;
end;

{ 分栏式风格 }
procedure TfrmPBox.ChangeUI_List(const bActivePage: Boolean = True);
var
  I                     : Integer;
  arrParentModuleLabel  : array of TLabel;
  arrParentModuleImage  : array of TImage;
  arrSubModuleLabel     : array of array of TLabel;
  intRow                : Integer;
  strPModuleIconFileName: string;
  strPModuleIconFilePath: string;
  J                     : Integer;
begin
  intRow := IfThen(MaxForm or FullForm, 5, 3);
  if FintBakRow = intRow then
    Exit;

  { 销毁分栏式界面 }
  FreeListViewSubModule;
  FintBakRow := intRow;

  clbrPModule.Visible := False;
  if bActivePage then
    rzpgcntrlAll.ActivePage := tsList;
  SetLength(arrParentModuleLabel, mmMainMenu.Items.Count);
  SetLength(arrParentModuleImage, mmMainMenu.Items.Count);
  SetLength(arrSubModuleLabel, mmMainMenu.Items.Count);
  for I := 0 to mmMainMenu.Items.Count - 1 do
  begin
    SetLength(arrSubModuleLabel[I], mmMainMenu.Items[I].Count);
  end;

  for I := 0 to mmMainMenu.Items.Count - 1 do
  begin
    { 创建父模块文本 }
    arrParentModuleLabel[I]            := TLabel.Create(tsList);
    arrParentModuleLabel[I].Parent     := tsList;
    arrParentModuleLabel[I].Caption    := mmMainMenu.Items[I].Caption;
    arrParentModuleLabel[I].Font.Name  := '宋体';
    arrParentModuleLabel[I].Font.Size  := 17;
    arrParentModuleLabel[I].Font.Style := [fsBold];
    arrParentModuleLabel[I].Font.Color := RGB(0, 174, 29);
    arrParentModuleLabel[I].Left       := 40 + 400 * (I mod intRow);
    arrParentModuleLabel[I].Top        := GetMaxInstance * (I div intRow);

    { 创建父模块图标 }
    arrParentModuleImage[I]         := TImage.Create(tsList);
    arrParentModuleImage[I].Parent  := tsList;
    arrParentModuleImage[I].Height  := 32;
    arrParentModuleImage[I].Width   := 32;
    arrParentModuleImage[I].Stretch := True;
    arrParentModuleImage[I].Left    := arrParentModuleLabel[I].Left - 40;
    arrParentModuleImage[I].Top     := arrParentModuleLabel[I].Top - 2;
    with TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini')) do
    begin
      strPModuleIconFilePath := ReadString(c_strIniModuleSection, arrParentModuleLabel[I].Caption + '_ICON', '');
      strPModuleIconFileName := ExtractFilePath(ParamStr(0)) + 'plugins\icon\' + strPModuleIconFilePath;
      if FileExists(strPModuleIconFileName) then
        arrParentModuleImage[I].Picture.LoadFromFile(strPModuleIconFileName);
      Free;
    end;

    { 创建子模块文本 }
    for J := 0 to Length(arrSubModuleLabel[I]) - 1 do
    begin
      arrSubModuleLabel[I, J]            := TLabel.Create(tsList);
      arrSubModuleLabel[I, J].Parent     := tsList;
      arrSubModuleLabel[I, J].Caption    := mmMainMenu.Items[I].Items[J].Caption;
      arrSubModuleLabel[I, J].Font.Name  := '宋体';
      arrSubModuleLabel[I, J].Font.Size  := 12;
      arrSubModuleLabel[I, J].Font.Style := [fsBold];
      arrSubModuleLabel[I, J].Font.Color := RGB(51, 153, 255);
      arrSubModuleLabel[I, J].Cursor     := crHandPoint;
      if J mod 3 = 0 then
        arrSubModuleLabel[I, J].Left := arrParentModuleLabel[I].Left + 2
      else
        arrSubModuleLabel[I, J].Left       := arrSubModuleLabel[I, J - 1].Left + arrSubModuleLabel[I, J - 1].Width + 10;
      arrSubModuleLabel[I, J].Top          := arrParentModuleLabel[I].Top + GetLabelHeight('宋体', 17) + c_intBetweenVerticalDistance + (GetLabelHeight('宋体', 12) + c_intBetweenVerticalDistance) * (J div 3);
      arrSubModuleLabel[I, J].Tag          := mmMainMenu.Items[I].Items[J].Tag;
      arrSubModuleLabel[I, J].OnMouseEnter := OnSubModuleMouseEnter;
      arrSubModuleLabel[I, J].OnMouseLeave := OnSubModuleMouseLeave;
      arrSubModuleLabel[I, J].OnClick      := OnSubModuleListClick;
    end;
  end;
end;

end.
