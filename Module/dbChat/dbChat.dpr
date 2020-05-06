library dbChat;
{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

uses
  System.SysUtils,
  System.Classes,
  uMain in 'uMain.pas' {frmP2PChat},
  db.uCommon in '..\..\db.uCommon.pas',
  uFrame in 'uFrame.pas' {frmcht: TFrame};

{$R *.res}

exports
  db_ShowDllForm_Plugins;

begin
end.
