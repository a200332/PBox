# PBox is a modular development platform based on Dll Form

- [��������](readmeCN.md)

## I. Development purpose
    Based on the principle of minimizing or not modifying the original project source code;
    Support Delphi DLL��VC DLL Form; 

## II. Development platform
    Delphi10.4��WIN10X64��
    Do not install any third-party controls��
    WIN7X64��WIN10X64 test pass��Support X86��X64;
    Email��dbyoung@sina.com
    QQg  ��101611228

## III.Usage 
### Delphi��
* Delphi original exe project, modified to DLL project. Output export function, the original code without any modification.
* Put the compiled DLL file in the plugins directory.
* Example: Module\SysSPath
* Delphi function declaration:  
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;
```
### VC2017
* VC original EXE(base on Dialog) project��without any modifitication��new a dll.cpp file��output export function��original code not need any modification��
* VC original EXE(base on MFC   ) project��need a little modify code��
* Put the compiled DLL file in the plugins directory.
* Example(base on Dialog)��DOC\VC\Dialog\Notepad2
* Example(base on MFC   )��DOC\VC\MFCDLL\mpc-be
* VC2017 function declaration:  
```
enum TVCDllType {vtDialog, vtMFC};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TVCDllType* spFileType, char** strParentName, char** strSubModuleName, char** strIconFileName, char** strClassName, char** strWindowName, const bool show = false)
```


## IV: Description of DLL output function parameters 
* Delphi ��
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;

 frm                 ��Dll main form class name in Delphi;
 strParentModuleName ��Parent module name;  
 strSubModuleName    ��Sub module name;  
 strIconFileName     ��Icon file; can be empty. In PBox configuration, select the icon;  
```
* VC2017 ��
```
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TVCDllType* spFileType, char** strParentName, char** strSubModuleName, char** strIconFileName, char** strClassName, char** strWindowName, const bool show = false)

 spFileType        ��Base on Dialog DLL��or base MFC DLL��
 strParentName     ��Parent module name;  
 strSubModuleName  ��Sub module name; 
 strIconFileName   ��Icon file; can be empty. In PBox configuration, select the icon; 
 strClassName      ��DLL Main form class name��
 strWindowName     ��DLL Main form title name��
 show              ��show/hide dll main form��
```

## V. Features 
    The UI supports menu display, button (dialog box) display and list view display.  
    PBox also supports the display of an EXE form program in our forms. 
    Support the EXE program of dynamic change of form class name. 
    Support x86 EXE call x64 EXE, x64 EXE call x86 EXE.
    
## VI. Note
    MDI form title, when the form is maximized, the title bar title is "main caption - [sub caption]"��not maximized, the title bar title is��"main caption - sub caption"
    Sample: Spy++.

## VII. Next work:  
    Add database support (because I am not familiar with the database, the development is slow, and it is developed in my spare time)  

