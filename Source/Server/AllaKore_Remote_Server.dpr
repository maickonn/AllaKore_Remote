program AllaKore_Remote_Server;

uses
  Forms,
  Form_Main in 'Form_Main.pas' {frm_Main};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'AllaKore Remote - Server';
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.Run;
end.
