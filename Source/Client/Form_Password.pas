unit Form_Password;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons;

type
  Tfrm_Password = class(TForm)
    BackgroundTop_Image: TImage;
    Ok_BitBtn: TBitBtn;
    Password_Edit: TEdit;
    PasswordIcon_Image: TImage;
    Label1: TLabel;
    procedure Ok_BitBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Password_EditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Password: Tfrm_Password;
  Canceled: Boolean;

implementation

{$R *.dfm}

uses
  Form_RemoteScreen, Form_Main;

procedure Tfrm_Password.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Canceled then
  begin
    frm_Main.Status_Image.Picture.Assign(frm_Main.Image3.Picture);
    frm_Main.Status_Label.Caption := 'Access canceled.';
    frm_Main.TargetID_MaskEdit.Enabled := true;
    frm_Main.Connect_BitBtn.Enabled := true;
  end;
end;

procedure Tfrm_Password.FormCreate(Sender: TObject);
begin
  // Separate Window
  SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_APPWINDOW);
end;

procedure Tfrm_Password.FormShow(Sender: TObject);
begin
  Canceled := true;
  Password_Edit.Clear;
  Password_Edit.SetFocus;
end;

procedure Tfrm_Password.Ok_BitBtnClick(Sender: TObject);
begin
  frm_Main.Main_Socket.Socket.SendText('<|CHECKIDPASSWORD|>' + frm_Main.TargetID_MaskEdit.Text + '<|>' + Password_Edit.Text + '<|END|>');
  Canceled := false;
  Close;
end;

procedure Tfrm_Password.Password_EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Ok_BitBtn.Click;
    Key := #0;
  end
end;

end.
