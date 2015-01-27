{ unit sdBitmapPlatform

  Platform-dependent methods for TsdBitmap
  Currently only for the M$ Windows GDI platform

  Creation Date: 05nov2010
  Original Author: Nils Haeck M.Sc.
  copyright (c) SimDesign BV (www.simdesign.nl)
}
unit sdBitmapPlatform;

{$define UseWin32}

interface

uses
  {$ifdef UseWin32}
  Windows, Graphics,
  {$endif}
  Classes, SysUtils, sdBitmap, sdGraphicTypes, sdMapIterator;

{$ifdef UseWin32}
function SdBitmapToWinBitmap(ABitmap: TsdBitmap): TBitmap;
function WinBitmapToSdBitmap(ABitmap: TBitmap): TsdBitmap;
function sdGetSysColor(AColor: TColor): TsdColor;
procedure GetWinBitmapIterator(ABitmap: TBitmap; AIterator: TsdMapIterator);
{$endif}

function sdBitmapAssignToPlatform(ABitmap: TsdBitmap; var Res: TPersistent): boolean;

implementation

type
  // MS Windows Bitmap Header
  TMSWinBmpHeader = packed record
    bfType: Word;
    bfSize: LongInt;
    bfReserved: LongInt;
    bfOffBits: LongInt;
    biSize: LongInt;
    biWidth: LongInt;
    biHeight: LongInt;
    biPlanes: Word;
    biBitCount: Word;
    biCompression: LongInt;
    biSizeImage: LongInt;
    biXPelsPerMeter: LongInt;
    biYPelsPerMeter: LongInt;
    biClrUsed: LongInt;
    biClrImportant: LongInt;
  end;

{$ifdef UseWin32}
function SdBitmapToWinBitmap(ABitmap: TsdBitmap): TBitmap;
var
  i, sdBitCount, winBitCount: integer;
  ScanLineSize, winScanLineSize, winBitmapSize: integer;
  Header: TMSWinBmpHeader;
  sdpal: PsdPaletteRec;
  winpal: PLogPalette;
  hpal: HPALETTE;
  M: TMemoryStream;
begin
{$RANGECHECKS OFF}
  Result := nil;
  if not assigned(ABitmap) then
    exit;

  Result := TBitmap.Create;

  // pixelformat
  sdBitCount := ABitmap.BitCount;
  if sdBitCount <= 32 then
    winBitCount := sdBitCount
  else
    //36, 48, 64:
    raise Exception.Create('invalid pixelformat');

  // scanline and bitmap size
  ScanLineSize := (winBitCount * ABitmap.Width + 7) div 8;
  // M$ seems to use ScanAlign of 4
  winScanLineSize := ((ScanLineSize + 3) div 4) * 4;
  winBitmapSize := winScanLineSize * ABitmap.Height;

  // MS Windows header
  Header.bfType := $4D42; // Magic bytes for Windows Bitmap
  Header.bfSize := winBitmapSize + SizeOf(TMSWinBmpHeader);
  Header.bfReserved := 0;
  // Save offset relative. However, the spec says it has to be file absolute,
  // which we can not do properly within a stream...
  Header.bfOffBits := SizeOf(TMSWinBmpHeader);
  Header.biSize := $28;
  Header.biWidth := ABitmap.Width;
  Header.biHeight := ABitmap.Height;

  Header.biPlanes := 1;
  Header.biBitCount := winBitCount;
  Header.biCompression := 0; // bi_rgb
  Header.biSizeImage := winBitmapSize;
  Header.biXPelsPerMeter := 0;
  Header.biYPelsPerMeter := 0;
  Header.biClrUsed := 0;
  Header.biClrImportant := 0;

  M := TMemoryStream.Create;
  try
    // memory size indication to avoid repeated capacity setter
    M.Size := Header.bfSize;
    M.WriteBuffer(Header, SizeOf(TMSWinBmpHeader));

    // in MS Windows the bits are upside-down
    for i := ABitmap.Height - 1 downto 0 do
    begin
      M.WriteBuffer(ABitmap.ScanLine[i]^, winScanLineSize);
    end;
    M.Position := 0;

    Result.LoadFromStream(M);
  finally
    M.Free;
  end;

  // palette
  sdpal := ABitmap.Palette;
  if assigned(sdpal) then
  begin
    // Create a windows bitmap palette
    GetMem(winpal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * sdpal.NumEntries);
    try
      winpal.palVersion := $300;
      winpal.palNumEntries := sdpal.NumEntries;
      for i := 0 to sdpal.NumEntries - 1 do
      begin
        winpal.palPalEntry[i].peRed   := sdpal.Entry[i].Red;
        winpal.palPalEntry[i].peGreen := sdpal.Entry[i].Green;
        winpal.palPalEntry[i].peBlue  := sdpal.Entry[i].Blue;
        winpal.palPalEntry[i].peFlags := sdpal.Entry[i].Alpha;
      end;
      hpal := CreatePalette(winpal^);
      if hpal <> 0 then
        Result.Palette := hpal;
    finally
      FreeMem(winpal);
    end;
  end;
{$RANGECHECKS ON}
end;

function WinBitmapToSdBitmap(ABitmap: TBitmap): TsdBitmap;
var
  i, sdBitCount{, winBitCount}: integer;
  ScanLineSize, winScanLineSize, winBitmapSize: integer;
  Header: TsdBmpHeader;
//  sdpal: PsdPaletteRec;
//  winpal: PLogPalette;
//  hpal: HPALETTE;
  M: TMemoryStream;
  TestStream: TMemoryStream;
begin
(*$RANGECHECKS OFF*)
  Result := nil;
  if not assigned(ABitmap) then
    exit;

  Result := TsdBitmap.Create;

  case ABitmap.PixelFormat of
  pf1bit: sdBitCount := 1;
  pf4bit: sdBitCount := 4;
  pf8bit: sdBitCount := 8;
  pf15bit: sdBitCount := 16;
  pf16bit: sdBitCount := 16;
  pf24bit: sdBitCount := 24;
  pf32bit: sdBitCount := 32;
  else
    raise Exception.Create('invalid pixelformat');
  end;

  // scanline and bitmap size
  ScanLineSize := (sdBitCount * ABitmap.Width + 7) div 8;
  // M$ seems to use ScanAlign of 4
  winScanLineSize := ((ScanLineSize + 3) div 4) * 4;
  winBitmapSize := winScanLineSize * ABitmap.Height;

  // SimDesign header
  Header.sdType := $4D42; // Magic bytes for Windows Bitmap
  Header.sdFSize := winBitmapSize + SizeOf(TMSWinBmpHeader);
  Header.sdReserved := 0;

  // Save offset relative. However, the spec says it has to be file absolute,
  // which we can not do properly within a stream...
  Header.sdOffBits := SizeOf(TMSWinBmpHeader);
  Header.sdSize := $28;
  Header.sdWidth := ABitmap.Width;
  Header.sdHeight := ABitmap.Height;

  Header.sdPlanes := 1;
  Header.sdBitCount := sdBitCount;
  Header.sdSizeImage := winBitmapSize;

  M := TMemoryStream.Create;
  try
    // memory size indication to avoid repeated capacity setter
    M.Size := Header.sdFSize;
    M.WriteBuffer(Header, SizeOf(TMSWinBmpHeader));

    // in MS Windows the bits are upside-down
    for i := ABitmap.Height - 1 downto 0 do
    begin
      M.WriteBuffer(ABitmap.ScanLine[i]^, winScanLineSize);
    end;

    M.Position := 0;
    Result.LoadFromStream(M);

    // test
    TestStream := TMemoryStream.Create;
    Result.SaveToStream(TestStream);
    TestStream.SaveToFile('testoutput.bmp');
    TestStream.Free;

  finally
    M.Free;
  end;

  // palette
{  sdpal := ABitmap.Palette;
  if assigned(sdpal) then
  begin
    // Create a windows bitmap palette
    GetMem(winpal, sizeof(TLogPalette) + sizeof(TPaletteEntry) * sdpal.NumEntries);
    try
      winpal.palVersion := $300;
      winpal.palNumEntries := sdpal.NumEntries;
      for i := 0 to sdpal.NumEntries - 1 do
      begin
        winpal.palPalEntry[i].peRed   := sdpal.Entry[i].Red;
        winpal.palPalEntry[i].peGreen := sdpal.Entry[i].Green;
        winpal.palPalEntry[i].peBlue  := sdpal.Entry[i].Blue;
        winpal.palPalEntry[i].peFlags := sdpal.Entry[i].Alpha;
      end;
      hpal := CreatePalette(winpal^);
      if hpal <> 0 then
        Result.Palette := hpal;
    finally
      FreeMem(winpal);
    end;
  end;}
(*$RANGECHECKS ON*)
end;

function sdGetSysColor(AColor: TColor): TsdColor;
begin
  Result := TsdColor(Windows.GetSysColor(AColor));
  Result := (Result {shl 8}) {+ $FF000000};
end;

procedure GetWinBitmapIterator(ABitmap: TBitmap; AIterator: TsdMapIterator);
begin
  AIterator.Width := ABitmap.Width;
  AIterator.Height := ABitmap.Height;
  if ABitmap.Width * ABitmap.Height = 0 then
    exit;
  AIterator.Map := ABitmap.ScanLine[0];
  if AIterator.Height > 1 then
    AIterator.ScanStride := integer(ABitmap.ScanLine[1]) - integer(ABitmap.ScanLine[0])
  else
    AIterator.ScanStride := 0;

  case ABitmap.PixelFormat of
  pf8bit: AIterator.CellStride := 1;
  pf16bit: AIterator.CellStride := 2;
  pf24bit: AIterator.CellStride := 3;
  pf32bit: AIterator.CellStride := 4;
  else
    // iteration not possible with bitcount lower than 8
    raise Exception.Create('Invalid pixelformat');
  end;
end;
{$endif} //UseWin32

function sdBitmapAssignToPlatform(ABitmap: TsdBitmap; var Res: TPersistent): boolean;
begin
  Result := False;
  Res := nil;
{$ifdef UseWin32}
  Res := sdBitmapToWinBitmap(ABitmap);
  if assigned(Res) then
    Result := True;
{$endif}
end;

end.
