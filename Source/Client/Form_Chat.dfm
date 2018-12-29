object frm_Chat: Tfrm_Chat
  Left = 0
  Top = 0
  Caption = 'Chat'
  ClientHeight = 301
  ClientWidth = 214
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poDesigned
  ScreenSnap = True
  SnapBuffer = 50
  StyleElements = [seFont, seClient]
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object YourText_Edit: TEdit
    Left = 0
    Top = 280
    Width = 214
    Height = 21
    Align = alBottom
    TabOrder = 0
    OnKeyPress = YourText_EditKeyPress
  end
  object Chat_RichEdit: TRichEdit
    Left = 0
    Top = 0
    Width = 214
    Height = 280
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    Zoom = 100
  end
end
