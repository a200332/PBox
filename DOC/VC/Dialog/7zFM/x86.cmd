call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

set "include=C:\Program Files (x86)\Windows Kits\10\Include\10.0.17763.0\ucrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.17763.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.17763.0\um;%include%"
set "lib=C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\ucrt\x86;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86;%lib%"

cl /c  /Zi /nologo /W3 /WX- /diagnostics:classic /O2 /Oy- /GL /D WIN32 /D STATIC_BUILD /D BOOKMARK_EDITION /D NDEBUG /D _CRT_SECURE_NO_WARNINGS /D _UNICODE /D UNICODE /Gm- /EHsc /MT /GS /arch:SSE2 /fp:precise /Zc:wchar_t /Zc:forScope /Zc:inline /Gd /analyze- /FC  7zFM.cpp

link /dll -out:7zFM.dll /DELAYLOAD:mpr.dll -nologo -RELEASE -OPT:REF -OPT:ICF -LTCG /LARGEADDRESSAWARE /FIXED:NO 7zFM.obj x86\*.obj x86\Format7z\*.obj x86\resource.res comctl32.lib htmlhelp.lib comdlg32.lib Mpr.lib Gdi32.lib delayimp.lib oleaut32.lib ole32.lib user32.lib advapi32.lib shell32.lib

pause
