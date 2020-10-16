object frm_Main: Tfrm_Main
  Left = 192
  Top = 125
  Caption = 'AllaKore Remote - Server (BETA)'
  ClientHeight = 550
  ClientWidth = 742
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 384
    Width = 742
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object Logs_Memo: TMemo
    Left = 0
    Top = 387
    Width = 742
    Height = 163
    Align = alBottom
    Lines.Strings = (
      'Exceptions Log:'
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Connections_ListView: TListView
    Left = 0
    Top = 0
    Width = 742
    Height = 384
    Align = alClient
    Columns = <
      item
        Caption = 'HandleConnection'
        Width = 100
      end
      item
        Caption = 'IP'
        Width = 170
      end
      item
        Caption = 'ID'
        Width = 100
      end
      item
        Caption = 'Password'
        Width = 100
      end
      item
        Caption = 'Target ID'
        Width = 100
      end
      item
        Caption = 'Ping'
        Width = 80
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object Ping_Timer: TTimer
    Interval = 5000
    OnTimer = Ping_TimerTimer
    Left = 360
    Top = 128
  end
end
