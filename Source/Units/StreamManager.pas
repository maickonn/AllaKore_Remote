unit StreamManager;

interface

uses
  Windows, Classes, Graphics;

procedure GetScreenToMemoryStream(DrawCur: Boolean; TargetMemoryStream: TMemoryStream);

procedure CompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);

procedure ResumeStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);

procedure ResizeBmp(bmp: TBitmap; Width, Height: Integer);

implementation

// Resize the Bitmap ( Best quality )
procedure ResizeBmp(bmp: TBitmap; Width, Height: Integer);
var
  SrcBMP : TBitmap;
  DestBMP: TBitmap;
begin
  SrcBMP := TBitmap.Create;
  try
    SrcBMP.Assign(bmp);
    DestBMP := TBitmap.Create;
    try
      DestBMP.Width  := Width;
      DestBMP.Height := Height;
      SetStretchBltMode(DestBMP.Canvas.Handle, HALFTONE);
      StretchBlt(DestBMP.Canvas.Handle, 0, 0, DestBMP.Width, DestBMP.Height, SrcBMP.Canvas.Handle, 0, 0, SrcBMP.Width, SrcBMP.Height, SRCCOPY);
      bmp.Assign(DestBMP);
    finally
      DestBMP.Free;
    end;
  finally
    SrcBMP.Free;
  end;
end;

// Screenshot
procedure GetScreenToMemoryStream(DrawCur: Boolean; TargetMemoryStream: TMemoryStream);
const
  CAPTUREBLT = $40000000;
var
  Mybmp           : TBitmap;
  Cursorx, Cursory: Integer;
  dc              : hdc;
  R               : TRect;
  DrawPos         : TPoint;
  MyCursor        : TIcon;
  hld             : hwnd;
  Threadld        : dword;
  mp              : TPoint;
  pIconInfo       : TIconInfo;
begin
  Mybmp := TBitmap.Create;

  dc := GetWindowDC(0);
  try
    R            := Rect(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN));
    Mybmp.Width  := R.Right;
    Mybmp.Height := R.Bottom;
    BitBlt(Mybmp.Canvas.Handle, 0, 0, Mybmp.Width, Mybmp.Height, dc, 0, 0, SRCCOPY or CAPTUREBLT);
  finally
    releaseDC(0, dc);
  end;

  if DrawCur then
  begin
    GetCursorPos(DrawPos);
    MyCursor := TIcon.Create;
    GetCursorPos(mp);
    hld      := WindowFromPoint(mp);
    Threadld := GetWindowThreadProcessId(hld, nil);
    AttachThreadInput(GetCurrentThreadId, Threadld, True);
    MyCursor.Handle := Getcursor();
    AttachThreadInput(GetCurrentThreadId, Threadld, False);
    GetIconInfo(MyCursor.Handle, pIconInfo);
    Cursorx := DrawPos.x - round(pIconInfo.xHotspot);
    Cursory := DrawPos.y - round(pIconInfo.yHotspot);
    Mybmp.Canvas.Draw(Cursorx, Cursory, MyCursor);
    DeleteObject(pIconInfo.hbmColor);
    DeleteObject(pIconInfo.hbmMask);
    MyCursor.ReleaseHandle;
    MyCursor.Free;
  end;
  Mybmp.PixelFormat := pf8bit;
  // ResizeBMP(Mybmp, Width, Height);
  TargetMemoryStream.Clear;
  Mybmp.SaveToStream(TargetMemoryStream);
  Mybmp.Free;

end;

// Compare Streams and separate when the Bitmap Pixels are equal.
procedure CompareStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);
var
  I : Integer;
  P1: ^AnsiChar;
  P2: ^AnsiChar;
  P3: ^AnsiChar;
begin
  // Check if the resolution has been changed
  if MyFirstStream.Size <> MySecondStream.Size then
  begin
    MyFirstStream.LoadFromStream(MySecondStream);
    MyCompareStream.LoadFromStream(MySecondStream);
    Exit;
  end;

  MyCompareStream.Clear;

  P1 := MyFirstStream.Memory;
  P2 := MySecondStream.Memory;
  MyCompareStream.SetSize(MyFirstStream.Size);
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin

    if P1^ = P2^ then
      P3^ := '0'
    else
      P3^ := P2^;

    Inc(P1);
    Inc(P2);
    Inc(P3);

  end;

  MyFirstStream.LoadFromStream(MySecondStream);
end;

// Modifies Streams to set the Pixels of Bitmap
procedure ResumeStream(MyFirstStream, MySecondStream, MyCompareStream: TMemoryStream);
var
  I : Integer;
  P1: ^AnsiChar;
  P2: ^AnsiChar;
  P3: ^AnsiChar;
begin

  // Check if the resolution has been changed
  if MyFirstStream.Size <> MyCompareStream.Size then
  begin
    MyFirstStream.LoadFromStream(MyCompareStream);
    MySecondStream.LoadFromStream(MyCompareStream);
    Exit;
  end;

  P1 := MyFirstStream.Memory;
  MySecondStream.SetSize(MyFirstStream.Size);
  P2 := MySecondStream.Memory;
  P3 := MyCompareStream.Memory;

  for I := 0 to MyFirstStream.Size - 1 do
  begin

    if P3^ = '0' then
      P2^ := P1^
    else
      P2^ := P3^;

    Inc(P1);
    Inc(P2);
    Inc(P3);

  end;

  MyFirstStream.LoadFromStream(MySecondStream);
  MySecondStream.Position := 0;
end;

end.
