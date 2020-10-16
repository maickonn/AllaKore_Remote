{
  This source has created by Maickonn Richard & Gabriel Stilben.
  Any questions, contact-me: maickonnrichard@gmail.com

  My Github: https://www.github.com/Maickonn

  Join our Facebook group: https://www.facebook.com/groups/1202680153082328/

  Are totally free!
}

unit Form_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, AppEvnts, System.Win.ScktComp;

// Thread to Define type connection, if Main, Desktop Remote, Download or Upload Files.
type
  TThreadConnection_Define = class(TThread)
  private
    defineSocket: TCustomWinSocket;
  public
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Main.
type
  TThreadConnection_Main = class(TThread)
  private
    mainSocket: TCustomWinSocket;
    targetMainSocket: TCustomWinSocket;
    ID: string;
    Password: string;
    TargetID: string;
    TargetPassword: string;
    StartPing: Int64;
    EndPing: Int64;
  public
    constructor Create(aSocket: TCustomWinSocket); overload;
    procedure Execute; override;
    procedure AddItems;
    procedure InsertTargetID;
    procedure InsertPing;
  end;

  // Thread to Define type connection are Desktop.
type
  TThreadConnection_Desktop = class(TThread)
  private
    desktopSocket: TCustomWinSocket;
    targetDesktopSocket: TCustomWinSocket;
    MyID: string;
  public
    constructor Create(aSocket: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Keyboard.
type
  TThreadConnection_Keyboard = class(TThread)
  private
    keyboardSocket: TCustomWinSocket;
    targetKeyboardSocket: TCustomWinSocket;
    MyID: string;
  public
    constructor Create(aSocket: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Files.
type
  TThreadConnection_Files = class(TThread)
  private
    filesSocket: TCustomWinSocket;
    targetFilesSocket: TCustomWinSocket;
    MyID: string;
  public
    constructor Create(aSocket: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

type
  Tfrm_Main = class(TForm)
    Splitter1: TSplitter;
    Logs_Memo: TMemo;
    Connections_ListView: TListView;
    Ping_Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Ping_TimerTimer(Sender: TObject);
    procedure Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);

  private
    Main_ServerSocket: TServerSocket;
  public
    { Public declarations }
  end;

var
  frm_Main: Tfrm_Main;

const
  Port = 3898; // Port for Socket;
  ProcessingSlack = 2; // Processing slack for Sleep Commands

implementation

{$R *.dfm}

constructor TThreadConnection_Define.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  defineSocket := aSocket;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Main.Create(aSocket: TCustomWinSocket);
begin
  inherited Create(False);
  mainSocket := aSocket;
  StartPing := 0;
  EndPing := 256;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Desktop.Create(aSocket: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  desktopSocket := aSocket;
  MyID := ID;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Keyboard.Create(aSocket: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  keyboardSocket := aSocket;
  MyID := ID;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Files.Create(aSocket: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  filesSocket := aSocket;
  MyID := ID;
  FreeOnTerminate := true;
end;

// Get current Version
function GetAppVersionStr: string;
type
  TBytes = array of Byte;
var
  Exe: string;
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  Exe := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);

  if Size = 0 then
    RaiseLastOSError;

  SetLength(Buffer, Size);

  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;

  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;

  Result := Format('%d.%d.%d.%d', [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
    LongRec(FixedPtr.dwFileVersionMS).Lo, // minor
    LongRec(FixedPtr.dwFileVersionLS).Hi, // release
    LongRec(FixedPtr.dwFileVersionLS).Lo]) // build
end;

function GenerateID(): string;
var
  i: Integer;
  ID: string;
  Exists: Boolean;
begin
  Exists := False;

  while true do
  begin
    Randomize;
    ID := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + '-' + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
    i := 0;
    while i < frm_Main.Connections_ListView.Items.Count - 1 do
    begin
      if frm_Main.Connections_ListView.Items.Item[i].SubItems[2] = ID then
      begin
        Exists := true;
        break;
      end
      else
        Exists := False;

      Inc(i);
    end;

    if not(Exists) then
      break;
  end;
  Result := ID;
end;

function GeneratePassword(): string;
begin
  Randomize;
  Result := IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9)) + IntToStr(Random(9));
end;

function FindListItemID(ID: string): TListItem;
var
  i: Integer;
begin
  i := 0;
  while i < frm_Main.Connections_ListView.Items.Count do
  begin
    if (frm_Main.Connections_ListView.Items.Item[i].SubItems[1] = ID) then
      break;

    Inc(i);
  end;
  Result := frm_Main.Connections_ListView.Items.Item[i];
end;

function CheckIDExists(ID: string): Boolean;
var
  i: Integer;
  Exists: Boolean;
begin
  Exists := False;
  i := 0;
  while i < frm_Main.Connections_ListView.Items.Count do
  begin
    if (frm_Main.Connections_ListView.Items.Item[i].SubItems[1] = ID) then
    begin
      Exists := true;
      break;
    end;

    Inc(i);
  end;
  Result := Exists;
end;

function CheckIDPassword(ID, Password: string): Boolean;
var
  i: Integer;
  Correct: Boolean;
begin
  Correct := False;
  i := 0;
  while i < frm_Main.Connections_ListView.Items.Count do
  begin
    if (frm_Main.Connections_ListView.Items.Item[i].SubItems[1] = ID) and (frm_Main.Connections_ListView.Items.Item[i].SubItems[2] = Password) then
    begin
      Correct := true;
      break;
    end;

    Inc(i);
  end;
  Result := Correct;
end;

procedure RegisterErrorLog(Header: string; ClassError: string; MessageText: string);
begin
  with frm_Main do
  begin
    Logs_Memo.Lines.Add(' ');
    Logs_Memo.Lines.Add(' ');
    Logs_Memo.Lines.Add('--------');
    Logs_Memo.Lines.Add(Header + ' (Class: ' + ClassError + ')');
    Logs_Memo.Lines.Add('Error: ' + MessageText);
    Logs_Memo.Lines.Add('--------');
  end;
end;

procedure Tfrm_Main.FormCreate(Sender: TObject);
begin
  Main_ServerSocket := TServerSocket.Create(self);
  Main_ServerSocket.Active := False;
  Main_ServerSocket.ServerType := stNonBlocking;
  Main_ServerSocket.OnClientConnect := Main_ServerSocketClientConnect;
  Main_ServerSocket.OnClientError := Main_ServerSocketClientError;
  Main_ServerSocket.Port := Port;
  Main_ServerSocket.Active := true;

  Caption := Caption + ' - ' + GetAppVersionStr;
end;

procedure Tfrm_Main.Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  // Create Defines Thread of Connections
  TThreadConnection_Define.Create(Socket);
end;

procedure Tfrm_Main.Main_ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  ErrorCode := 0;
end;

{ TThreadConnection_Define }
// Here it will be defined the type of connection.
procedure TThreadConnection_Define.Execute;
var
  Buffer: string;
  BufferTemp: string;
  ID: string;
  position: Integer;
  ThreadMain: TThreadConnection_Main;
  ThreadDesktop: TThreadConnection_Desktop;
  ThreadKeyboard: TThreadConnection_Keyboard;
  ThreadFiles: TThreadConnection_Files;
begin
  inherited;
  while true do
  begin
    Sleep(ProcessingSlack);

    if (defineSocket = nil) or not(defineSocket.Connected) then
      break;

    if defineSocket.ReceiveLength < 1 then
      Continue;

    Buffer := defineSocket.ReceiveText;

    position := Pos('<|MAINSOCKET|>', Buffer); // Storing the position in an integer variable will prevent it from having to perform two searches, gaining more performance
    if position > 0 then
    begin
      // Create the Thread for Main Socket
      ThreadMain := TThreadConnection_Main.Create(defineSocket);
      break; // Break the while
    end;

    position := Pos('<|DESKTOPSOCKET|>', Buffer); // For example, I stored the position of the string I wanted to find
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 16); // So since I already know your position, I do not need to pick it up again
      ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
      // Create the Thread for Desktop Socket
      ThreadDesktop := TThreadConnection_Desktop.Create(defineSocket, ID);
      break; // Break the while
    end;

    position := Pos('<|KEYBOARDSOCKET|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 17);
      ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
      // Create the Thread for Keyboard Socket
      ThreadKeyboard := TThreadConnection_Keyboard.Create(defineSocket, ID);
      break; // Break the while
    end;

    position := Pos('<|FILESSOCKET|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, Pos('<|FILESSOCKET|>', Buffer) + 14);
      ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
      // Create the Thread for Files Socket
      ThreadFiles := TThreadConnection_Files.Create(defineSocket, ID);
      break; // Break the while
    end;
  end;
end;

{ TThreadConnection_Main }

procedure TThreadConnection_Main.AddItems;
var
  L: TListItem;
begin

  ID := GenerateID;
  Password := GeneratePassword;
  L := frm_Main.Connections_ListView.Items.Add;
  L.Caption := IntToStr(mainSocket.Handle);
  L.SubItems.Add(mainSocket.RemoteAddress);
  L.SubItems.Add(ID);
  L.SubItems.Add(Password);
  L.SubItems.Add('');
  L.SubItems.Add('Calculating...');
  L.SubItems.Objects[4] := TObject(0);
end;

// The connection type is the main.
procedure TThreadConnection_Main.Execute;
var
  Buffer: string;
  BufferTemp: string;
  position: Integer;
  L: TListItem;
  L2: TListItem;
begin
  inherited;

  Synchronize(AddItems);
  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(mainSocket.Handle), False, true, False);
  L.SubItems.Objects[0] := TObject(self);

  while mainSocket.SendText('<|ID|>' + ID + '<|>' + Password + '<|END|>') < 0 do
    Sleep(ProcessingSlack);

  while true do
  begin
    Sleep(ProcessingSlack);

    if (mainSocket = nil) or not(mainSocket.Connected) then
      break;

    if mainSocket.ReceiveLength < 1 then
      Continue;

    Buffer := mainSocket.ReceiveText;

    position := Pos('<|FINDID|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 9);
      TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

      if (CheckIDExists(TargetID)) then
      begin
        if (FindListItemID(TargetID).SubItems[3] = '') then
        begin
          while mainSocket.SendText('<|IDEXISTS!REQUESTPASSWORD|>') < 0 do
            Sleep(ProcessingSlack);
        end
        else
        begin
          while mainSocket.SendText('<|ACCESSBUSY|>') < 0 do
            Sleep(ProcessingSlack);
        end
      end
      else
      begin
        while mainSocket.SendText('<|IDNOTEXISTS|>') < 0 do
          Sleep(ProcessingSlack);
      end;
    end;

    if Buffer.Contains('<|PONG|>') then
    begin
      EndPing := GetTickCount - StartPing;
      Synchronize(InsertPing);
    end;

    position := Pos('<|CHECKIDPASSWORD|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 18);
      position := Pos('<|>', BufferTemp);
      TargetID := Copy(BufferTemp, 1, position - 1);
      Delete(BufferTemp, 1, position + 2);
      TargetPassword := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

      if (CheckIDPassword(TargetID, TargetPassword)) then
      begin
        while mainSocket.SendText('<|ACCESSGRANTED|>') < 0 do
          Sleep(ProcessingSlack);
      end
      else
      begin
        while mainSocket.SendText('<|ACCESSDENIED|>') < 0 do
          Sleep(ProcessingSlack);
      end;
    end;

    position := Pos('<|RELATION|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 11);
      position := Pos('<|>', BufferTemp);
      ID := Copy(BufferTemp, 1, position - 1);
      Delete(BufferTemp, 1, position + 2);
      TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);
      L := FindListItemID(ID);
      L2 := FindListItemID(TargetID);
      Synchronize(InsertTargetID);

      // Relates the main Sockets
      TThreadConnection_Main(L.SubItems.Objects[0]).targetMainSocket := TThreadConnection_Main(L2.SubItems.Objects[0]).mainSocket;
      TThreadConnection_Main(L2.SubItems.Objects[0]).targetMainSocket := TThreadConnection_Main(L.SubItems.Objects[0]).mainSocket;
      // Relates the Remote Desktop
      TThreadConnection_Desktop(L.SubItems.Objects[1]).targetDesktopSocket := TThreadConnection_Desktop(L2.SubItems.Objects[1]).desktopSocket;
      TThreadConnection_Desktop(L2.SubItems.Objects[1]).targetDesktopSocket := TThreadConnection_Desktop(L.SubItems.Objects[1]).desktopSocket;
      // Relates the Keyboard Socket
      TThreadConnection_Keyboard(L.SubItems.Objects[2]).targetKeyboardSocket := TThreadConnection_Keyboard(L2.SubItems.Objects[2]).keyboardSocket;
      // Relates the Share Files
      TThreadConnection_Files(L.SubItems.Objects[3]).targetFilesSocket := TThreadConnection_Files(L2.SubItems.Objects[3]).filesSocket;
      TThreadConnection_Files(L2.SubItems.Objects[3]).targetFilesSocket := TThreadConnection_Files(L.SubItems.Objects[3]).filesSocket;
      // Warns Access
      TThreadConnection_Main(L.SubItems.Objects[0]).targetMainSocket.SendText('<|ACCESSING|>');
      // Get first screenshot
      TThreadConnection_Desktop(L.SubItems.Objects[1]).targetDesktopSocket.SendText('<|GETFULLSCREENSHOT|>');
    end;

    // Stop relations
    if Buffer.Contains('<|STOPACCESS|>') then
    begin
      mainSocket.SendText('<|DISCONNECTED|>');
      targetMainSocket.SendText('<|DISCONNECTED|>');
      targetMainSocket := nil;
      TThreadConnection_Main(L2.SubItems.Objects[0]).targetMainSocket := nil;
      Synchronize(
        procedure
        begin
          L.SubItems[3] := '';
          L2.SubItems[3] := '';
        end);
    end;

    // Redirect commands
    position := Pos('<|REDIRECT|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 11);

      if (Pos('<|FOLDERLIST|>', BufferTemp) > 0) then
      begin
        while (mainSocket.Connected) do
        begin
          Sleep(ProcessingSlack); // Avoids using 100% CPU

          if (Pos('<|ENDFOLDERLIST|>', BufferTemp) > 0) then
            break;

          BufferTemp := BufferTemp + mainSocket.ReceiveText;
        end;
      end;

      if (Pos('<|FILESLIST|>', BufferTemp) > 0) then
      begin
        while (mainSocket.Connected) do
        begin
          Sleep(ProcessingSlack); // Avoids using 100% CPU

          if (Pos('<|ENDFILESLIST|>', BufferTemp) > 0) then
            break;

          BufferTemp := BufferTemp + mainSocket.ReceiveText;
        end;
      end;

      if (targetMainSocket <> nil) and (targetMainSocket.Connected) then
      begin
        while targetMainSocket.SendText(BufferTemp) < 0 do
          Sleep(ProcessingSlack);
      end;
    end;
  end;

  if (targetMainSocket <> nil) and (targetMainSocket.Connected) then
  begin
    while targetMainSocket.SendText('<|DISCONNECTED|>') < 0 do
      Sleep(ProcessingSlack);
  end;

  Synchronize(
    procedure
    begin
      L2 := FindListItemID(L.SubItems[3]);

      if L2 <> nil then
        L2.SubItems[3] := '';

      L.Delete;
    end);

end;

procedure TThreadConnection_Main.InsertPing;
var
  L: TListItem;
begin
  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(mainSocket.Handle), False, true, False);

  if L <> nil then
    L.SubItems[4] := IntToStr(EndPing) + ' ms';
end;

procedure TThreadConnection_Main.InsertTargetID;
var
  L, L2: TListItem;
begin
  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(mainSocket.Handle), False, true, False);

  if L <> nil then
  begin
    L2 := FindListItemID(TargetID);
    L.SubItems[3] := TargetID;
    L2.SubItems[3] := ID;
  end;
end;

{ TThreadConnection_Desktop }
// The connection type is the Desktop Screens
procedure TThreadConnection_Desktop.Execute;
var
  Buffer: string;
  L: TListItem;
begin
  inherited;

  L := FindListItemID(MyID);
  L.SubItems.Objects[1] := TObject(self);

  while true do
  begin
    Sleep(ProcessingSlack);

    if (desktopSocket = nil) or not(desktopSocket.Connected) then
      break;

    if desktopSocket.ReceiveLength < 1 then
      Continue;

    Buffer := desktopSocket.ReceiveText;

    if (targetDesktopSocket <> nil) and (targetDesktopSocket.Connected) then
    begin
      while targetDesktopSocket.SendText(Buffer) < 0 do
        Sleep(ProcessingSlack);
    end;
  end;
end;

// The connection type is the Keyboard Remote
procedure TThreadConnection_Keyboard.Execute;
var
  Buffer: string;
  L: TListItem;
begin
  inherited;

  L := FindListItemID(MyID);
  L.SubItems.Objects[2] := TObject(self);

  while true do
  begin
    Sleep(ProcessingSlack);

    if (keyboardSocket = nil) or not(keyboardSocket.Connected) then
      break;

    if keyboardSocket.ReceiveLength < 1 then
      Continue;

    Buffer := keyboardSocket.ReceiveText;

    if (targetKeyboardSocket <> nil) and (targetKeyboardSocket.Connected) then
    begin
      while targetKeyboardSocket.SendText(Buffer) < 0 do
        Sleep(ProcessingSlack);
    end;
  end;
end;

{ TThreadConnection_Files }
// The connection type is to Share Files
procedure TThreadConnection_Files.Execute;
var
  Buffer: string;
  L: TListItem;
begin
  inherited;

  L := FindListItemID(MyID);
  L.SubItems.Objects[3] := TObject(self);

  while true do
  begin
    Sleep(ProcessingSlack);

    if (filesSocket = nil) or not(filesSocket.Connected) then
      break;

    if filesSocket.ReceiveLength < 1 then
      Continue;

    Buffer := filesSocket.ReceiveText;

    if (targetFilesSocket <> nil) and (targetFilesSocket.Connected) then
    begin
      while targetFilesSocket.SendText(Buffer) < 0 do
        Sleep(ProcessingSlack);
    end;
  end;
end;

procedure Tfrm_Main.Ping_TimerTimer(Sender: TObject);
var
  i: Integer;
  Connection: TThreadConnection_Main;
begin
  try
    for i := 0 to Connections_ListView.Items.Count - 1 do
    begin
      if Connections_ListView.Items.Item[i].SubItems.Objects[0] = nil then
        Continue;

      Connection := TThreadConnection_Main(Connections_ListView.Items.Item[i].SubItems.Objects[0]);
      if (Connection.mainSocket = nil) or not(Connection.mainSocket.Connected) then
        Continue;

      Connection.mainSocket.SendText('<|PING|>');
      Connection.StartPing := GetTickCount;

      if Connections_ListView.Items.Item[i].SubItems[4] <> 'Calculating...' then
        Connection.mainSocket.SendText('<|SETPING|>' + IntToStr(Connection.EndPing) + '<|END|>');
    end;
  except
    On E: Exception do
      RegisterErrorLog('Ping Timer', E.ClassName, E.Message);
  end;
end;

end.
