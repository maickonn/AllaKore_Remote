unit Form_RemoteScreen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  Tfrm_RemoteScreen = class(TForm)
    Screen_Image: TImage;
    ScrollBox1: TScrollBox;
    Menu_Panel: TPanel;
    MouseIcon_Image: TImage;
    KeyboardIcon_Image: TImage;
    ResizeIcon_Image: TImage;
    MouseRemote_CheckBox: TCheckBox;
    KeyboardRemote_CheckBox: TCheckBox;
    Resize_CheckBox: TCheckBox;
    MouseIcon_checked_Image: TImage;
    KeyboardIcon_checked_Image: TImage;
    ResizeIcon_checked_Image: TImage;
    ResizeIcon_unchecked_Image: TImage;
    KeyboardIcon_unchecked_Image: TImage;
    MouseIcon_unchecked_Image: TImage;
    CaptureKeys_Timer: TTimer;
    Chat_Image: TImage;
    FileShared_Image: TImage;
    ScreenStart_Image: TImage;
    procedure Resize_CheckBoxClick(Sender: TObject);
    procedure Resize_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure KeyboardRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MouseRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure KeyboardRemote_CheckBoxClick(Sender: TObject);
    procedure MouseRemote_CheckBoxClick(Sender: TObject);
    procedure Screen_ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Screen_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Screen_ImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SendSocketKeys(Keys: string);
    procedure CaptureKeys_TimerTimer(Sender: TObject);
    procedure Chat_ImageClick(Sender: TObject);
    procedure FileShared_ImageClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Screen_ImageDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    { Private declarations }
  public
    CtrlPressed, ShiftPressed, AltPressed: Boolean;
    { Public declarations }
  end;

var
  frm_RemoteScreen: Tfrm_RemoteScreen;

implementation

{$R *.dfm}

uses
  Form_Main, Form_Chat, Form_ShareFiles;

procedure Tfrm_RemoteScreen.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
{ sets Size-limits for the Form }
var
  MinMaxInfo: PMinMaxInfo;
begin
  inherited;
  MinMaxInfo := Message.MinMaxInfo;

  MinMaxInfo^.ptMinTrackSize.X := 800; // Minimum Width
  MinMaxInfo^.ptMinTrackSize.Y := 500; // Minimum Height
  if (Resize_CheckBox.Checked) then
  begin
    MinMaxInfo^.ptMaxTrackSize.X := frm_Main.ResolutionTargetWidth;
    MinMaxInfo^.ptMaxTrackSize.Y := frm_Main.ResolutionTargetHeight;
  end
  else
  begin
    MinMaxInfo^.ptMaxTrackSize.X := frm_Main.ResolutionTargetWidth + 20;
    MinMaxInfo^.ptMaxTrackSize.Y := frm_Main.ResolutionTargetHeight + 120;
  end;

end;

procedure Tfrm_RemoteScreen.SendSocketKeys(Keys: string);
begin

  if (Active) then
    frm_Main.Keyboard_Socket.Socket.SendText(Keys);
end;

procedure Tfrm_RemoteScreen.CaptureKeys_TimerTimer(Sender: TObject);
var
  i: Byte;
begin
  // The keys programmed here, may not match the keys on your keyboard. I recommend to undertake adaptation.
  try

    { Combo }
    if (Active) then
    begin
      // Alt
      if not(AltPressed) then
      begin
        if (GetKeyState(VK_MENU) < 0) then
        begin
          AltPressed := true;
          SendSocketKeys('<|ALTDOWN|>');
        end;
      end
      else
      begin
        if (GetKeyState(VK_MENU) > -1) then
        begin
          AltPressed := false;
          SendSocketKeys('<|ALTUP|>');
        end;
      end;

      // Ctrl
      if not(CtrlPressed) then
      begin
        if (GetKeyState(VK_CONTROL) < 0) then
        begin
          CtrlPressed := true;
          SendSocketKeys('<|CTRLDOWN|>');
        end;
      end
      else
      begin
        if (GetKeyState(VK_CONTROL) > -1) then
        begin
          CtrlPressed := false;
          SendSocketKeys('<|CTRLUP|>');
        end;
      end;

      // Shift
      if not(ShiftPressed) then
      begin
        if (GetKeyState(VK_SHIFT) < 0) then
        begin
          ShiftPressed := true;
          SendSocketKeys('<|SHIFTDOWN|>');
        end;
      end
      else
      begin
        if (GetKeyState(VK_SHIFT) > -1) then
        begin
          ShiftPressed := false;
          SendSocketKeys('<|SHIFTUP|>');
        end;
      end;
    end;

    for i := 8 to 228 do
    begin
      if (GetAsyncKeyState(i) = -32767) then
      begin
        case i of
          8:
            SendSocketKeys('{BS}');
          9:
            SendSocketKeys('{TAB}');
          13:
            SendSocketKeys('{ENTER}');
          27:
            SendSocketKeys('{ESCAPE}');
          32:
            SendSocketKeys(' ');
          33:
            SendSocketKeys('{PGUP}');
          34:
            SendSocketKeys('{PGDN}');
          35:
            SendSocketKeys('{END}');
          36:
            SendSocketKeys('{HOME}');
          37:
            SendSocketKeys('{LEFT}');
          38:
            SendSocketKeys('{UP}');
          39:
            SendSocketKeys('{RIGHT}');
          40:
            SendSocketKeys('{DOWN}');
          44:
            SendSocketKeys('{PRTSC}');
          46:
            SendSocketKeys('{DEL}');
          145:
            SendSocketKeys('{SCROLLLOCK}');

          // Numbers: 1 2 3 4 5 6 7 8 9 and ! @ # $ % ¨& * ( )
          48:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys(')')
            else
              SendSocketKeys('0');
          49:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('!')
            else
              SendSocketKeys('1');
          50:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('@')
            else
              SendSocketKeys('2');
          51:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('#')
            else
              SendSocketKeys('3');
          52:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('$')
            else
              SendSocketKeys('4');
          53:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('%')
            else
              SendSocketKeys('5');
          54:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('^')
            else
              SendSocketKeys('6');
          55:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('&')
            else
              SendSocketKeys('7');
          56:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('*')
            else
              SendSocketKeys('8');
          57:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('(')
            else
              SendSocketKeys('9');

          65 .. 90: // A..Z / a..z
            begin
              if (GetKeyState(VK_CAPITAL) = 1) then
                if (GetKeyState(VK_SHIFT) < 0) then
                  SendSocketKeys(LowerCase(Chr(i)))
                else
                  SendSocketKeys(UpperCase(Chr(i)))
              else if (GetKeyState(VK_SHIFT) < 0) then
                SendSocketKeys(UpperCase(Chr(i)))
              else
                SendSocketKeys(LowerCase(Chr(i)))

            end;

          96 .. 105: // Numpad 1..9
            SendSocketKeys(IntToStr(i - 96));

          106:
            SendSocketKeys('*');
          107:
            SendSocketKeys('+');
          109:
            SendSocketKeys('-');
          110:
            SendSocketKeys(',');
          111:
            SendSocketKeys('/');
          194:
            SendSocketKeys('.');

          // F1..F12
          112 .. 123:
            SendSocketKeys('{F' + IntToStr(i - 111) + '}');

          186:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('Ç')
            else
              SendSocketKeys('ç');
          187:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('+')
            else
              SendSocketKeys('=');
          188:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('<')
            else
              SendSocketKeys(',');
          189:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('_')
            else
              SendSocketKeys('-');
          190:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('>')
            else
              SendSocketKeys('.');
          191:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys(':')
            else
              SendSocketKeys(';');
          192:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('"')
            else
              SendSocketKeys('''');
          193:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('?')
            else
              SendSocketKeys('/');
          219:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('`')
            else
              SendSocketKeys('´');
          220:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('}')
            else
              SendSocketKeys(']');
          221:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('{')
            else
              SendSocketKeys('[');
          222:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('^')
            else
              SendSocketKeys('~');
          226:
            if (GetKeyState(VK_SHIFT) < 0) then
              SendSocketKeys('|')
            else
              SendSocketKeys('\');

        end;
      end;

    end;

  except

  end;

end;

procedure Tfrm_RemoteScreen.Chat_ImageClick(Sender: TObject);
begin
  frm_Chat.Show;
end;

procedure Tfrm_RemoteScreen.FileShared_ImageClick(Sender: TObject);
begin
  frm_ShareFiles.Show;
end;

procedure Tfrm_RemoteScreen.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  frm_ShareFiles.Hide;
  frm_Chat.Hide;

  frm_Main.Main_Socket.Socket.SendText('<|STOPACCESS|>');

  frm_Main.SetOnline;

  frm_Main.Show;

end;

procedure Tfrm_RemoteScreen.FormCreate(Sender: TObject);
begin
  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
end;

procedure Tfrm_RemoteScreen.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if (MouseRemote_CheckBox.Checked) then
    frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|WHEELMOUSE|>' + IntToStr(WheelDelta) + '<|END|>');
end;

procedure Tfrm_RemoteScreen.FormShow(Sender: TObject);
begin
  CtrlPressed  := false;
  ShiftPressed := false;
  AltPressed   := false;
end;

procedure Tfrm_RemoteScreen.KeyboardRemote_CheckBoxClick(Sender: TObject);
begin
  if (KeyboardRemote_CheckBox.Checked) then
  begin
    KeyboardIcon_Image.Picture.Assign(KeyboardIcon_checked_Image.Picture);
    CaptureKeys_Timer.Enabled := true;
  end
  else
  begin
    KeyboardIcon_Image.Picture.Assign(KeyboardIcon_unchecked_Image.Picture);
    CaptureKeys_Timer.Enabled := false;
  end;
end;

procedure Tfrm_RemoteScreen.KeyboardRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

procedure Tfrm_RemoteScreen.MouseRemote_CheckBoxClick(Sender: TObject);
begin
  if (MouseRemote_CheckBox.Checked) then
  begin
    MouseIcon_Image.Picture.Assign(MouseIcon_checked_Image.Picture);
  end
  else
  begin
    MouseIcon_Image.Picture.Assign(MouseIcon_unchecked_Image.Picture);
  end;
end;

procedure Tfrm_RemoteScreen.MouseRemote_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_SPACE) then
    Key := 0;
end;

procedure Tfrm_RemoteScreen.Resize_CheckBoxClick(Sender: TObject);
begin
  if (Resize_CheckBox.Checked) then
  begin
    Screen_Image.AutoSize := false;
    Screen_Image.Stretch  := true;
    Screen_Image.Align    := alClient;
    ResizeIcon_Image.Picture.Assign(ResizeIcon_checked_Image.Picture);
  end
  else
  begin
    Screen_Image.AutoSize := true;
    Screen_Image.Stretch  := false;
    Screen_Image.Align    := alNone;
    ResizeIcon_Image.Picture.Assign(ResizeIcon_unchecked_Image.Picture);
  end;

end;

procedure Tfrm_RemoteScreen.Resize_CheckBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_SPACE then
    Key := 0;
end;

procedure Tfrm_RemoteScreen.Screen_ImageDblClick(Sender: TObject);
begin
  if (Active) and (MouseRemote_CheckBox.Checked) then
  begin
    frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSEDOUBLECLICK|>');
  end;
end;

procedure Tfrm_RemoteScreen.Screen_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Active) and (MouseRemote_CheckBox.Checked) then
  begin
    X := (X * frm_Main.ResolutionTargetWidth) div (Screen_Image.Width);
    Y := (Y * frm_Main.ResolutionTargetHeight) div (Screen_Image.Height);
    if (Button = mbLeft) then
      frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSELEFTCLICKDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else if (Button = mbRight) then
      frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSERIGHTCLICKDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else
      frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSEMIDDLEDOWN|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
  end;
end;

procedure Tfrm_RemoteScreen.Screen_ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if (Active) and (MouseRemote_CheckBox.Checked) then
  begin
    X := (X * frm_Main.ResolutionTargetWidth) div (Screen_Image.Width);
    Y := (Y * frm_Main.ResolutionTargetHeight) div (Screen_Image.Height);
    frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSEPOS|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>');
  end;
end;

procedure Tfrm_RemoteScreen.Screen_ImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Active) and (MouseRemote_CheckBox.Checked) then
  begin
    X := (X * frm_Main.ResolutionTargetWidth) div (Screen_Image.Width);
    Y := (Y * frm_Main.ResolutionTargetHeight) div (Screen_Image.Height);
    if (Button = mbLeft) then
      frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSELEFTCLICKUP|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else if (Button = mbRight) then
      frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSERIGHTCLICKUP|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
    else
      frm_Main.Main_Socket.Socket.SendText('<|REDIRECT|><|SETMOUSEMIDDLEUP|>' + IntToStr(X) + '<|>' + IntToStr(Y) + '<|END|>')
  end;
end;

end.
