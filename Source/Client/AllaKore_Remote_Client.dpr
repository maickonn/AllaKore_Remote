program AllaKore_Remote_Client;

uses
  Vcl.Forms,
  Windows,
  SysUtils,
  ShellAPI,
  Classes,
  Form_Main in 'Form_Main.pas' {frm_Main},
  Form_Password in 'Form_Password.pas' {frm_Password},
  Form_RemoteScreen in 'Form_RemoteScreen.pas' {frm_RemoteScreen},
  Vcl.Themes,
  Vcl.Styles,
  Form_Chat in 'Form_Chat.pas' {frm_Chat},
  Form_ShareFiles in 'Form_ShareFiles.pas' {frm_ShareFiles},
  sndkey32 in '..\Units\sndkey32.pas',
  StreamManager in '..\Units\StreamManager.pas',
  ZLibEx in '..\Units\DelphiZlib\ZLibEx.pas',
  ZLibExApi in '..\Units\DelphiZlib\ZLibExApi.pas',
  ZLibExGZ in '..\Units\DelphiZlib\ZLibExGZ.pas';

{$R *.res}

function WUserName: String;
var
  nSize: DWord;
begin
 nSize := 1024;
 SetLength(Result, nSize);
 if GetUserName(PChar(Result), nSize) then
   SetLength(Result, nSize-1)
 else
   RaiseLastOSError;
end;

procedure ExtractRunAsSystem;
var
  resource: TResourceStream;
begin
  resource := TResourceStream.Create(HInstance, 'RUN_AS_SYSTEM', RT_RCDATA);
  try
    resource.SaveToFile(ExtractFilePath(ParamStr(0)) + '\RunAsSystem.exe');
  finally
    FreeAndNil(resource);
  end;
end;

begin
  Application.Initialize;

  // Workaround to run on SYSTEM account. This is necessary in order to be able to interact with UAC.
  {$IFNDEF DEBUG}
  if not (UpperCase(WUserName).Contains('SYSTEM')) and not (UpperCase(WUserName).Contains('SISTEMA')) then
  begin
    ExtractRunAsSystem;
    ShellExecute(0, 'open', PChar(ExtractFilePath(ParamStr(0)) + '\RunAsSystem.exe'), PChar(Application.ExeName), nil, SW_HIDE);
    Application.Terminate;
  end
  else
  begin
    Sleep(1000);
    DeleteFile(ExtractFilePath(ParamStr(0)) + '\RunAsSystem.exe');
  end;
  {$ENDIF}

  Application.MainFormOnTaskbar := True;
  Application.Title := 'AllaKore Remote';
  TStyleManager.TrySetStyle('Carbon');
  Application.CreateForm(Tfrm_Main, frm_Main);
  Application.CreateForm(Tfrm_Password, frm_Password);
  Application.CreateForm(Tfrm_RemoteScreen, frm_RemoteScreen);
  Application.CreateForm(Tfrm_Chat, frm_Chat);
  Application.CreateForm(Tfrm_ShareFiles, frm_ShareFiles);
  Application.Run;
end.
