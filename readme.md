# PBox is a modular development platform based on Delphi Dll Form

- [¼òÌåÖÐÎÄ](readmeCN.md)

## I. Development purpose
    Based on the principle of minimizing or not modifying the original project source code;
    Only Support Delphi Dll Form; 
    PBox2 (https://github.com/dbyoung720/PBox2) Support Delphi¡¢VC¡¢QT, Dll Form

## II. Development platform
    Delphi10.3.3¡¢WIN10X64£»
    The code does not use any third-party controls£»
    WIN7X64¡¢WIN10X64 test pass£»Support X86¡¢X64;
    Email£ºdbyoung@sina.com
    QQ   £º101611228

## III.Usage 
### Delphi£º
* Delphi original exe project, modified to DLL project. Output specific functions, the original code without any modification.
* Put the compiled DLL file in the plugins directory.
* Example: Module\SysSPath
* Delphi function declaration:  
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;
```


## IV: Description of DLL output function parameters 
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;

 frm                 £ºDll main form class name in Delphi;
 strParentModuleName £ºParent module name;  
 strSubModuleName    £ºSub module name;  
 strIconFileName     £ºIcon file; can be empty. In PBox configuration, select the icon;  
```

## V. Features 
    The UI supports menu display, button (dialog box) display and list view display.  
    PBox also supports the display of an EXE form program in our forms. 
    Support the EXE program of dynamic change of form class name. 

## VI. Note
    MDI form title, when the form is maximized, the title bar title is "main caption - [sub caption]"£¬not maximized, the title bar title is£º"main caption - sub caption"
    Sample: Spy++.

## VII. Next work:  
    Add database support (because I am not familiar with the database, the development is slow, and it is developed in my spare time)  

