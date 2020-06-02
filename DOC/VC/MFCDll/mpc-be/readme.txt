1、将 MFC EXE ，修改为 MFC DLL，MFC 使用静态库
2、修改 CMPlayerCApp::InitInstance()
3、添加 Dll 导出函数

注：
  还需要修改一些东东，因为 EXE 和 DLL 差别，修改量不大。
