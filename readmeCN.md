# PBox ��һ������ DLL ��̬�ⴰ���ģ�黯����ƽ̨

- [English](readme.md)

## һ��������ּ
    ���ž������޸Ļ��޸�ԭ�й���Դ�����ԭ��;
    ֧�� Delphi DLL��VC DLL ����; 

## ��������ƽ̨
    Delphi10.3��WIN10X64 �¿���
    ���谲װ�κε������ؼ�
    WIN7X64��WIN10X64�²���ͨ����֧��X86��X64
    ���䣺dbyoung@sina.com
    QQȺ��101611228

## ����ʹ�÷���
### Delphi��
* Delphi ԭ EXE �����ļ����޸�Ϊ DLL ���̡�������������Ϳ����ˣ�ԭ�д��벻�����κ��޸ģ�
* �ѱ����� DLL �ļ����õ� plugins Ŀ¼�¾Ϳ����ˣ�
* ʾ����Module\SysSPath��
* Delphi ����������
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;
```
### VC2017
* VC ԭ EXE�����ڶԻ��򣬲����κ��޸ġ��½� dll.cpp �ļ���������������Ϳ����ˣ�
* VC ԭ EXE������   MFC����Ҫ�����޸ģ�
* �ѱ����� DLL �ļ����õ� plugins Ŀ¼�¾Ϳ����ˣ�
* ʾ��(���ڶԻ���)��DOC\VC\Dialog\Notepad2��
* ʾ��(���ڶԻ���)��DOC\VC\Dialog\7zFM
* ʾ��(����   MFC)��DOC\VC\MFCDLL\mpc-be��
* VC2017 ����������
```
enum TVCDllType {vtDialog, vtMFC};
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TVCDllType* spFileType, char** strParentName, char** strSubModuleName, char** strIconFileName, char** strClassName, char** strWindowName, const bool show = false)
```

## �ģ�Dll �����������˵��
* Delphi ��
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;

 frm                 ��Delphi �� DLL ������������
 strParentModuleName ����ģ�����ƣ�
 strSubModuleName    ����ģ�����ƣ�
 strIconFileName     ��ͼ���ļ�����Ϊ�գ��� PBox �����У�ѡ��ͼ�ꣻ
```
* VC2017 ��
```
extern "C" __declspec(dllexport) void db_ShowDllForm_Plugins(TVCDllType* spFileType, char** strParentName, char** strSubModuleName, char** strIconFileName, char** strClassName, char** strWindowName, const bool show = false)

 spFileType        ���ǻ��� Dialog(�Ի���) �� DLL�����ǻ��� MFC �� DLL��
 strParentName     ����ģ�����ƣ�
 strSubModuleName  ����ģ�����ƣ�
 strIconFileName   ��ͼ���ļ�����Ϊ�գ��� PBox �����У�ѡ��ͼ�ꣻ
 strClassName      ��DLL �������������
 strWindowName     ��DLL ������ı�������
 show              ����ʾ/���ش��壻
```

## �壺��ɫ����
    ����֧�֣��˵���ʽ��ʾ����ť���Ի��򣩷�ʽ��ʾ���б��ӷ�ʽ��ʾ��
    PBox ��֧�ֽ�һ�� EXE ���������ʾ�����ǵĴ����У�
    ֧�ִ���������̬�仯�� EXE ����
    ֧�� x86 EXE ���� x64 EXE��x64 EXE ���� x86 EXE��
    
## ����ע������
    ���ĵ�������⣬���������ʱ������������Ϊ "��������� - [�Ӵ������]"�������ʱ������������Ϊ��"��������� - �Ӵ������"
    ���磺Spy++
    
## �ߣ�������������
    ������ݿ�֧�֣����ڱ��˶����ݿⲻ��Ϥ�����Կ�������������ҵ��ʱ�俪����;

## �ˣ�����������⣺
* VC MFC DLL �����֧�֣�
* QT DLL �����֧�֣�
* DLL/EXE ����֧���ļ��Ϸţ�
