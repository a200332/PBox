library DBView;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  Unit1 in 'Unit1.pas' {frmDBView} ,
  Unit2 in 'Unit2.pas' {frmSQL};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.