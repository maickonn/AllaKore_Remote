unit Form_Chat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  Tfrm_Chat = class(TForm)
    YourText_Edit: TEdit;
    Chat_RichEdit: TRichEdit;
    procedure YourText_EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    procedure WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
    { Private declarations }
  public
    LastMessageAreYou: Boolean;
    FirstMessage: Boolean;
    { Public declarations }
  end;

var
  frm_Chat: Tfrm_Chat;

implementation

{$R *.dfm}

uses
  Form_Main;

procedure Tfrm_Chat.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
{ sets Size-limits for the Form }
var
  MinMaxInfo: PMinMaxInfo;
begin
  inherited;
  MinMaxInfo := Message.MinMaxInfo;
  MinMaxInfo^.ptMinTrackSize.X := 230; // Minimum Width
  MinMaxInfo^.ptMinTrackSize.Y := 340; // Minimum Height
end;

procedure Tfrm_Chat.FormCreate(Sender: TObject);
begin
  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
  FirstMessage := true;
  Left := Screen.WorkAreaWidth - Width;
  Top := Screen.WorkAreaHeight - Height;
  Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
  Chat_RichEdit.SelAttributes.Style := [fsBold];
  Chat_RichEdit.SelAttributes.Color := clWhite;
  Chat_RichEdit.SelText := 'AllaKore Remote - Chat' + #13 + #13;
end;

procedure Tfrm_Chat.YourText_EditKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
  begin
    if Length(YourText_Edit.Text) > 0 then
    begin
      FirstMessage := false;

      if not LastMessageAreYou then
      begin
        LastMessageAreYou := true;
        Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
        Chat_RichEdit.SelAttributes.Style := [fsBold];
        Chat_RichEdit.SelAttributes.Color := clYellow;
        Chat_RichEdit.SelText := #13 + #13 + 'You say:' + #13;
        Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
        Chat_RichEdit.SelAttributes.Color := clWhite;
        Chat_RichEdit.SelText := '   •   ' + YourText_Edit.Text;
      end
      else
      begin
        Chat_RichEdit.SelStart := Chat_RichEdit.GetTextLen;
        Chat_RichEdit.SelAttributes.Color := clWhite;
        Chat_RichEdit.SelText := #13 + '   •   ' + YourText_Edit.Text;
      end;

      frm_main.Main_Socket.Socket.SendText('<|REDIRECT|><|CHAT|>' + YourText_Edit.Text + '<|END|>');
      YourText_Edit.Clear;
      SendMessage(Chat_RichEdit.Handle, WM_VSCROLL, SB_BOTTOM, 0);
    end;

    Key := #0;
  end;
end;

end.
