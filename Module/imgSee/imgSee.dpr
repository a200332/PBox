library imgSee;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  uFirstUnit,
  System.SysUtils,
  System.Classes,
  uMain in 'uMain.pas' {frmImageSee};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin

end.
