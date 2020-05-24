library Snap;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  uMain in 'uMain.pas' {frmSnapScreen};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
