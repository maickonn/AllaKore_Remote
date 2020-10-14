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
    AThread_Define: TCustomWinSocket;
  public
    constructor Create(AThread: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Main.
type
  TThreadConnection_Main = class(TThread)
  private
    AThread_Main       : TCustomWinSocket;
    AThread_Main_Target: TCustomWinSocket;
    ID                 : string;
    Password           : string;
    TargetID           : string;
    TargetPassword     : string;
    StartPing          : Int64;
    EndPing            : Int64;
  public
    constructor Create(AThread: TCustomWinSocket); overload;
    procedure Execute; override;
    procedure AddItems;
    procedure InsertTargetID;
    procedure InsertPing;
  end;

  // Thread to Define type connection are Desktop.
type
  TThreadConnection_Desktop = class(TThread)
  private
    AThread_Desktop       : TCustomWinSocket;
    AThread_Desktop_Target: TCustomWinSocket;
    MyID                  : string;
  public
    constructor Create(AThread: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Keyboard.
type
  TThreadConnection_Keyboard = class(TThread)
  private
    AThread_Keyboard       : TCustomWinSocket;
    AThread_Keyboard_Target: TCustomWinSocket;
    MyID                   : string;
  public
    constructor Create(AThread: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

  // Thread to Define type connection are Files.
type
  TThreadConnection_Files = class(TThread)
  private
    AThread_Files       : TCustomWinSocket;
    AThread_Files_Target: TCustomWinSocket;
    MyID                : string;
  public
    constructor Create(AThread: TCustomWinSocket; ID: string); overload;
    procedure Execute; override;
  end;

type
  Tfrm_Main = class(TForm)
    Splitter1: TSplitter;
    Logs_Memo: TMemo;
    Connections_ListView: TListView;
    Ping_Timer: TTimer;
    Main_ServerSocket: TServerSocket;
    procedure FormCreate(Sender: TObject);
    procedure Ping_TimerTimer(Sender: TObject);
    procedure Main_ServerSocketClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Main_ServerSocketClientError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Main: Tfrm_Main;

const
  Port            = 3898; // Port for Socket;
  ProcessingSlack = 2;    // Processing slack for Sleep Commands

implementation

{$R *.dfm}

constructor TThreadConnection_Define.Create(AThread: TCustomWinSocket);
begin
  inherited Create(False);
  AThread_Define  := AThread;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Main.Create(AThread: TCustomWinSocket);
begin
  inherited Create(False);
  AThread_Main := AThread;

  StartPing := 0;
  EndPing   := 256;

  FreeOnTerminate := true;
end;

constructor TThreadConnection_Desktop.Create(AThread: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  AThread_Desktop := AThread;
  MyID            := ID;
  FreeOnTerminate := true;
end;

constructor TThreadConnection_Keyboard.Create(AThread: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  AThread_Keyboard := AThread;
  MyID             := ID;
  FreeOnTerminate  := true;
end;

constructor TThreadConnection_Files.Create(AThread: TCustomWinSocket; ID: string);
begin
  inherited Create(False);
  AThread_Files   := AThread;
  MyID            := ID;
  FreeOnTerminate := true;
end;

// Get current Version
function GetAppVersionStr: string;
type
  TBytes = array of Byte;
var
  Exe         : string;
  Size, Handle: DWORD;
  Buffer      : TBytes;
  FixedPtr    : PVSFixedFileInfo;
begin
  Exe  := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d', [LongRec(FixedPtr.dwFileVersionMS).Hi, // major
    LongRec(FixedPtr.dwFileVersionMS).Lo,                                // minor
    LongRec(FixedPtr.dwFileVersionLS).Hi,                                // release
    LongRec(FixedPtr.dwFileVersionLS).Lo])                               // build
end;

function GenerateID(): string;
var
  i     : Integer;
  ID    : string;
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

      if (frm_Main.Connections_ListView.Items.Item[i].SubItems[2] = ID) then
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
  i     : Integer;
  Exists: Boolean;
begin

  Exists := False;
  i      := 0;
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
  i      : Integer;
  Correct: Boolean;
begin

  Correct := False;
  i       := 0;
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
  Main_ServerSocket.Port   := Port;
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
  Buffer        : string;
  BufferTemp    : string;
  ID            : string;
  position      : Integer;
  ThreadMain    : TThreadConnection_Main;
  ThreadDesktop : TThreadConnection_Desktop;
  ThreadKeyboard: TThreadConnection_Keyboard;
  ThreadFiles   : TThreadConnection_Files;
begin
  inherited;
  while True do
  begin

    Sleep(ProcessingSlack);

    if (AThread_Define = nil) or not (AThread_Define.Connected) then
      Break;

    if AThread_Define.ReceiveLength < 1 then
      Continue;

    Buffer := AThread_Define.ReceiveText;

    position := Pos('<|MAINSOCKET|>', Buffer); // Storing the position in an integer variable will prevent it from having to perform two searches, gaining more performance
    if position > 0 then
    begin
      // Create the Thread for Main Socket
      ThreadMain := TThreadConnection_Main.Create(AThread_Define);

      break; // Break the while
    end;

    position := Pos('<|DESKTOPSOCKET|>', Buffer); // For example, I stored the position of the string I wanted to find
    if position > 0 then
    begin
      BufferTemp := Buffer;

      Delete(BufferTemp, 1, position + 16); // So since I already know your position, I do not need to pick it up again
      ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

      // Create the Thread for Desktop Socket
      ThreadDesktop := TThreadConnection_Desktop.Create(AThread_Define, ID);

      break; // Break the while
    end;

    position := Pos('<|KEYBOARDSOCKET|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;

      Delete(BufferTemp, 1, position + 17);
      ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

      // Create the Thread for Keyboard Socket
      ThreadKeyboard := TThreadConnection_Keyboard.Create(AThread_Define, ID);

      break; // Break the while
    end;

    position := Pos('<|FILESSOCKET|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;

      Delete(BufferTemp, 1, Pos('<|FILESSOCKET|>', Buffer) + 14);
      ID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

      // Create the Thread for Files Socket
      ThreadFiles := TThreadConnection_Files.Create(AThread_Define, ID);

      break; // Break the while
    end;

  end;

end;

{ TThreadConnection_Main }

procedure TThreadConnection_Main.AddItems;
var
  L: TListItem;
begin

  ID        := GenerateID;
  Password  := GeneratePassword;
  L         := frm_Main.Connections_ListView.Items.Add;
  L.Caption := IntToStr(AThread_Main.Handle);
  L.SubItems.Add(AThread_Main.RemoteAddress);
  L.SubItems.Add(ID);
  L.SubItems.Add(Password);
  L.SubItems.Add('');
  L.SubItems.Add('Calculating...');
  L.SubItems.Objects[4] := TObject(0);
end;

// The connection type is the main.
procedure TThreadConnection_Main.Execute;
var
  Buffer    : string;
  BufferTemp: string;
  position  : Integer;
  L         : TListItem;
  L2        : TListItem;
begin
  inherited;

  Synchronize(AddItems);

  L                     := frm_Main.Connections_ListView.FindCaption(0, IntToStr(AThread_Main.Handle), False, true, False);
  L.SubItems.Objects[0] := TObject(Self);

  while AThread_Main.SendText('<|ID|>' + ID + '<|>' + Password + '<|END|>') < 0 do
    Sleep(ProcessingSlack);

  while true do
  begin

    Sleep(ProcessingSlack);

    if (AThread_Main = nil) or not (AThread_Main.Connected) then
      break;

    if AThread_Main.ReceiveLength < 1 then
      Continue;

    Buffer := AThread_Main.ReceiveText;

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

          while AThread_Main.SendText('<|IDEXISTS!REQUESTPASSWORD|>') < 0 do
            Sleep(ProcessingSlack);

        end
        else
        begin

          while AThread_Main.SendText('<|ACCESSBUSY|>') < 0 do
            Sleep(ProcessingSlack);

        end
      end
      else
      begin

        while AThread_Main.SendText('<|IDNOTEXISTS|>') < 0 do
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

        while AThread_Main.SendText('<|ACCESSGRANTED|>') < 0 do
          Sleep(ProcessingSlack);
      end
      else
      begin

        while AThread_Main.SendText('<|ACCESSDENIED|>') < 0 do
          Sleep(ProcessingSlack);

      end;
    end;

    position := Pos('<|RELATION|>', Buffer);
    if position > 0 then
    begin
      BufferTemp := Buffer;
      Delete(BufferTemp, 1, position + 11);

      position := Pos('<|>', BufferTemp);
      ID       := Copy(BufferTemp, 1, position - 1);

      Delete(BufferTemp, 1, position + 2);

      TargetID := Copy(BufferTemp, 1, Pos('<|END|>', BufferTemp) - 1);

      L  := FindListItemID(ID);
      L2 := FindListItemID(TargetID);

      Synchronize(InsertTargetID);

      // Relates the main Sockets
      TThreadConnection_Main(L.SubItems.Objects[0]).AThread_Main_Target  := TThreadConnection_Main(L2.SubItems.Objects[0]).AThread_Main;
      TThreadConnection_Main(L2.SubItems.Objects[0]).AThread_Main_Target := TThreadConnection_Main(L.SubItems.Objects[0]).AThread_Main;

      // Relates the Remote Desktop
      TThreadConnection_Desktop(L.SubItems.Objects[1]).AThread_Desktop_Target  := TThreadConnection_Desktop(L2.SubItems.Objects[1]).AThread_Desktop;
      TThreadConnection_Desktop(L2.SubItems.Objects[1]).AThread_Desktop_Target := TThreadConnection_Desktop(L.SubItems.Objects[1]).AThread_Desktop;

      // Relates the Keyboard Socket
      TThreadConnection_Keyboard(L.SubItems.Objects[2]).AThread_Keyboard_Target := TThreadConnection_Keyboard(L2.SubItems.Objects[2]).AThread_Keyboard;

      // Relates the Share Files
      TThreadConnection_Files(L.SubItems.Objects[3]).AThread_Files_Target  := TThreadConnection_Files(L2.SubItems.Objects[3]).AThread_Files;
      TThreadConnection_Files(L2.SubItems.Objects[3]).AThread_Files_Target := TThreadConnection_Files(L.SubItems.Objects[3]).AThread_Files;

      // Warns Access
      TThreadConnection_Main(L.SubItems.Objects[0]).AThread_Main_Target.SendText('<|ACCESSING|>');

      // Get first screenshot
      TThreadConnection_Desktop(L.SubItems.Objects[1]).AThread_Desktop_Target.SendText('<|GETFULLSCREENSHOT|>');

    end;

    // Stop relations
    if Buffer.Contains('<|STOPACCESS|>') then
    begin
      AThread_Main.SendText('<|DISCONNECTED|>');
      AThread_Main_Target.SendText('<|DISCONNECTED|>');

      AThread_Main_Target                                                := nil;
      TThreadConnection_Main(L2.SubItems.Objects[0]).AThread_Main_Target := nil;

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
        while (AThread_Main.Connected) do
        begin

          Sleep(ProcessingSlack); // Avoids using 100% CPU

          if (Pos('<|ENDFOLDERLIST|>', BufferTemp) > 0) then
            break;

          BufferTemp := BufferTemp + AThread_Main.ReceiveText;

        end;
      end;

      if (Pos('<|FILESLIST|>', BufferTemp) > 0) then
      begin

        while (AThread_Main.Connected) do
        begin

          Sleep(ProcessingSlack); // Avoids using 100% CPU

          if (Pos('<|ENDFILESLIST|>', BufferTemp) > 0) then
            break;

          BufferTemp := BufferTemp + AThread_Main.ReceiveText;

        end;
      end;

      if (AThread_Main_Target <> nil) and (AThread_Main_Target.Connected) then
        while AThread_Main_Target.SendText(BufferTemp) < 0 do
          Sleep(ProcessingSlack);

    end;

  end;

  if (AThread_Main_Target <> nil) and (AThread_Main_Target.Connected) then
  begin
    while AThread_Main_Target.SendText('<|DISCONNECTED|>') < 0 do
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

  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(AThread_Main.Handle), False, true, False);
  if L <> nil then
    L.SubItems[4] := IntToStr(EndPing) + ' ms';

end;

procedure TThreadConnection_Main.InsertTargetID;
var
  L, L2: TListItem;
begin
  L := frm_Main.Connections_ListView.FindCaption(0, IntToStr(AThread_Main.Handle), False, true, False);
  if L <> nil then
  begin
    L2 := FindListItemID(TargetID);

    L.SubItems[3]  := TargetID;
    L2.SubItems[3] := ID;
  end;
end;

{ TThreadConnection_Desktop }
// The connection type is the Desktop Screens
procedure TThreadConnection_Desktop.Execute;
var
  Buffer: string;
  L     : TListItem;
begin
  inherited;

  L                     := FindListItemID(MyID);
  L.SubItems.Objects[1] := TObject(Self);

  while true do
  begin

    Sleep(ProcessingSlack);

    if (AThread_Desktop = nil) or not (AThread_Desktop.Connected) then
      break;

    if AThread_Desktop.ReceiveLength < 1 then
      Continue;

    Buffer := AThread_Desktop.ReceiveText;

    if (AThread_Desktop_Target <> nil) and (AThread_Desktop_Target.Connected) then
    begin
      while AThread_Desktop_Target.SendText(Buffer) < 0 do
        Sleep(ProcessingSlack);
    end;

  end;

end;

// The connection type is the Keyboard Remote
procedure TThreadConnection_Keyboard.Execute;
var
  Buffer: string;
  L     : TListItem;
begin
  inherited;

  L                     := FindListItemID(MyID);
  L.SubItems.Objects[2] := TObject(Self);

  while true do
  begin

    Sleep(ProcessingSlack);

    if (AThread_Keyboard = nil) or not (AThread_Keyboard.Connected) then
      break;

    if AThread_Keyboard.ReceiveLength < 1 then
      Continue;

    Buffer := AThread_Keyboard.ReceiveText;

    if (AThread_Keyboard_Target <> nil) and (AThread_Keyboard_Target.Connected) then
    begin
      while AThread_Keyboard_Target.SendText(Buffer) < 0 do
        Sleep(ProcessingSlack);
    end;

  end;
end;

{ TThreadConnection_Files }
// The connection type is to Share Files
procedure TThreadConnection_Files.Execute;
var
  Buffer: string;
  L     : TListItem;
begin
  inherited;

  L                     := FindListItemID(MyID);
  L.SubItems.Objects[3] := TObject(Self);


  while true do
  begin

    Sleep(ProcessingSlack);

    if (AThread_Files = nil) or not (AThread_Files.Connected) then
      break;

    if AThread_Files.ReceiveLength < 1 then
      Continue;

    Buffer := AThread_Files.ReceiveText;

    if (AThread_Files_Target <> nil) and (AThread_Files_Target.Connected) then
      while AThread_Files_Target.SendText(Buffer) < 0 do
        Sleep(ProcessingSlack);

  end;

end;

procedure Tfrm_Main.Ping_TimerTimer(Sender: TObject);
var
  i         : Integer;
  Connection: TThreadConnection_Main;
begin
  try
    for i := 0 to Connections_ListView.Items.Count - 1 do
    begin
      if Connections_ListView.Items.Item[i].SubItems.Objects[0] = nil then
        Continue;

      Connection := TThreadConnection_Main(Connections_ListView.Items.Item[i].SubItems.Objects[0]);
      if (Connection.AThread_Main = nil) or not(Connection.AThread_Main.Connected) then
        Continue;

      Connection.AThread_Main.SendText('<|PING|>');
      Connection.StartPing := GetTickCount;

      if Connections_ListView.Items.Item[i].SubItems[4] <> 'Calculating...' then
        Connection.AThread_Main.SendText('<|SETPING|>' + IntToStr(Connection.EndPing) + '<|END|>');
    end;
  except
    On E: Exception do
      RegisterErrorLog('Ping Timer', E.ClassName, E.Message);
  end;
end;

end.
