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

function IsAccountSystem: Boolean;
var
  hToken: THandle;
  pTokenUser: ^TTokenUser;
  dwInfoBufferSize: DWORD;
  pSystemSid: PSID;
const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_LOCAL_SYSTEM_RID = $00000012;
begin
  if not OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hToken) then
  begin
    Result := False;
    Exit;
  end;

  GetMem(pTokenUser, 1024);
  if not GetTokenInformation(hToken, TokenUser, pTokenUser, 1024, dwInfoBufferSize) then
  begin
    CloseHandle(hToken);
    Result := False;
    Exit;
  end;

  CloseHandle(hToken);

  if not AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 1, SECURITY_LOCAL_SYSTEM_RID, 0, 0, 0, 0, 0, 0, 0, pSystemSid) then
  begin
    Result := False;
    Exit;
  end;

  Result := EqualSid(pTokenUser.User.Sid, pSystemSid);
  FreeSid(pSystemSid);
end;

begin
  Application.Initialize;

  // Workaround to run on SYSTEM account. This is necessary in order to be able to interact with UAC.
  {$IFNDEF DEBUG}
  if not IsAccountSystem then
  begin
    ExtractRunAsSystem;
    ShellExecute(0, 'open', PChar(ExtractFilePath(ParamStr(0)) + '\RunAsSystem.exe'), PChar('"' + Application.ExeName + '"'), nil, SW_HIDE);
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
