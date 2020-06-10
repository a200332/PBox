# PBox 是一个基于 DLL 动态库窗体的模块化开发平台

- [English](readme.md)

## 一：开发宗旨
    本着尽量少修改或不修改原有工程源代码的原则;
    支持 Delphi DLL、VC DLL 窗体; 

## 二：开发平台
    Delphi10.3、WIN10X64 下开发
    无需安装任何第三方控件
    WIN7X64、WIN10X64下测试通过；支持X86、X64
    邮箱：dbyoung@sina.com
    QQ群：101611228

## 三：使用方法
### Delphi：
* Delphi 原 EXE 工程文件，修改为 DLL 工程。输出导出函数就可以了，原有代码不用作任何修改；
* 把编译后的 DLL 文件放置到 plugins 目录下就可以了；
* 示例：Module\SysSPath；
* Delphi 函数声明：
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;
```
### VC2017
* VC 原 EXE，基于对话框，不作任何修改。新建 dll.cpp 文件，输出导出函数就可以了；
* VC 原 EXE，基于   MFC，需要少许修改；
* 把编译后的 DLL 文件放置到 plugins 目录下就可以了；
* 示例(基于对话框)：DOC\VC\Dialog\Notepad2；
* 示例(基于对话框)：DOC\VC\Dialog\7zFM
* 示例(基于   MFC)：DOC\VC\MFCDLL\mpc-be；
* VC2017 函数声明：
```
enum TVCDllType {vtDialog, vtMFC};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TVCDllType* spFileType, char** strParentName, char** strSubModuleName, char** strIconFileName, char** strClassName, char** strWindowName, const bool show = false)
```

## 四：Dll 输出函数参数说明
* Delphi ：
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;

 frm                 ：Delphi 中 DLL 主窗体类名；
 strParentModuleName ：父模块名称；
 strSubModuleName    ：子模块名称；
 strIconFileName     ：图标文件；可为空，在 PBox 配置中，选择图标；
```
* VC2017 ：
```
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TVCDllType* spFileType, char** strParentName, char** strSubModuleName, char** strIconFileName, char** strClassName, char** strWindowName, const bool show = false)

 spFileType        ：是基于 Dialog(对话框) 的 DLL，还是基于 MFC 的 DLL；
 strParentName     ：父模块名称；
 strSubModuleName  ：子模块名称；
 strIconFileName   ：图标文件；可为空，在 PBox 配置中，选择图标；
 strClassName      ：DLL 主窗体的类名；
 strWindowName     ：DLL 主窗体的标题名；
 show              ：显示/隐藏窗体；
```

## 五：特色功能
    界面支持，菜单方式显示、按钮（对话框）方式显示、列表视方式显示；
    PBox 还支持将一个 EXE 窗体程序显示在我们的窗体中；
    支持窗体类名动态变化的 EXE 程序；
    支持 x86 EXE 调用 x64 EXE，x64 EXE 调用 x86 EXE；
    
## 六：注意事项
    多文档窗体标题，当窗体最大化时，标题栏标题为 "主窗体标题 - [子窗体标题]"，非最大化时，标题栏标题为："主窗体标题 - 子窗体标题"
    比如：Spy++
    
## 七：接下来工作：
    添加数据库支持（由于本人对数据库不熟悉，所以开发较慢，又是业余时间开发）;

## 八：待解决的问题：
* VC MFC DLL 窗体的支持；
* QT DLL 窗体的支持；
* DLL/EXE 窗体支持文件拖放；
