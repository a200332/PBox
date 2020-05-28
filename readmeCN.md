# PBox 是一个基于 Delphi Dll 动态库窗体的模块化开发平台

- [English](readme.md)

## 一：开发宗旨
    本着尽量少修改或不修改原有工程源代码的原则;
    仅支持 Delphi Dll 窗体; 
    PBox2 (https://github.com/dbyoung720/PBox2) 支持 Delphi、VC、QT Dll 窗体; 

## 二：开发平台
    Delphi10.3.3、WIN10X64 下开发；
    代码没有使用任何第三方控件；
    WIN7X64、WIN10X64下测试通过；支持X86、X64;
    邮箱：dbyoung@sina.com
    QQ群：101611228

## 三：使用方法
### Delphi：
* Delphi 原 EXE 工程文件，修改为 Dll 工程。输出特定函数就可以了，原有代码不用作任何修改。
* 把编译后的 Dll 文件放置到 plugins 目录下就可以了。
* 示例：Module\SysSPath
* Delphi 函数声明：
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;
```

## 四：Dll 输出函数参数说明
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;

 frm                 ：Delphi 中 Dll 主窗体类名；
 strParentModuleName ：父模块名称；
 strSubModuleName    ：子模块名称；
 strIconFileName     ：图标文件；可为空，在 PBox 配置中，选择图标；
```

## 五：特色功能
    界面支持，菜单方式显示、按钮（对话框）方式显示、列表视方式显示;
    PBox 还支持将一个 EXE 窗体程序显示在我们的窗体中;
    支持窗体类名动态变化的 EXE 程序;
    支持 x86 EXE 调用 x64 EXE，x64 EXE 调用 x86 EXE;
    
## 六：注意事项
    多文档窗体标题，当窗体最大化时，标题栏标题为 "主窗体标题 - [子窗体标题]"，非最大化时，标题栏标题为："主窗体标题 - 子窗体标题"
    比如：Spy++
    
## 七：接下来工作：
    添加数据库支持（由于本人对数据库不熟悉，所以开发较慢，又是业余时间开发）;

