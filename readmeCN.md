# PBox ��һ������ Dll ��̬�ⴰ���ģ�黯����ƽ̨

- [English](readme.md)

## һ��������ּ
    ���ž������޸Ļ��޸�ԭ�й���Դ�����ԭ��;
    ��֧�� Delphi Dll ����; PBox2 ֧�� VC��QT Dll ����

## ��������ƽ̨
    Delphi10.3.3��WIN10X64 �¿�����
    ����û��ʹ���κε������ؼ���
    WIN7X64��WIN10X64�²���ͨ����֧��X86��X64;
    ���䣺dbyoung@sina.com
    QQȺ��101611228

## ����ʹ�÷���
### Delphi��
* Delphi ԭ EXE �����ļ����޸�Ϊ Dll ���̡�����ض������Ϳ����ˣ�ԭ�д��벻�����κ��޸ġ�
* �ѱ����� Dll �ļ����õ� plugins Ŀ¼�¾Ϳ����ˡ�
* ʾ����Module\SysSPath
* Delphi ����������
```
 type
 { ֧�ֵ��ļ����� }
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;
```

## �ģ�Dll �����������˵��
```
 procedure db_ShowDllForm_Plugins(var frm: TFormClass; var strParentModuleName, strSubModuleName, strIconFileName: PAnsiChar); stdcall;

 frm                 ��Delphi �� Dll ������������
 strParentModuleName ����ģ�����ƣ�
 strSubModuleName    ����ģ�����ƣ�
 strIconFileName     ��ͼ���ļ�����Ϊ�գ��� PBox �����У�ѡ��ͼ�ꣻ
```

## �壺��ɫ����
    ����֧�֣��˵���ʽ��ʾ����ť���Ի��򣩷�ʽ��ʾ���б��ӷ�ʽ��ʾ;
    PBox ��֧�ֽ�һ�� EXE ���������ʾ�����ǵĴ�����;

## ����������������
    ������ݿ�֧�֣����ڱ��˶����ݿⲻ��Ϥ�����Կ�������������ҵ��ʱ�俪����;

