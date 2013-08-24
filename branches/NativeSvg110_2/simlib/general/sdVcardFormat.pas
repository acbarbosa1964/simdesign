unit sdVcardFormat;
{ unit sdcardFormat

  This unit implements a file format for business cards,
  called VCARD (often *.vcf or *.vcard);
  it allows to import V2.1, V3.0, V4.0 and xCard versions and export xCard, as well as
  convert to well-known *.CSV (comma separated values)

  Please see http://en.wikipedia.org/wiki/VCard for more information.
}
interface

uses
  Classes, SysUtils, NativeXml, sdDebug;

type
  TsdVcardFormat = class(TDebugComponent)
  public
    procedure LoadFromFile(const AFileName: string); virtual;
    procedure LoadFromStream(S: TStream); virtual;
  end;

implementation

const
  csdBeginVcard: Utf8String = 'BEGIN:VCARD';
  csdEndVcard:   Utf8String = 'END:VCARD';
  csdName:       Utf8String = 'N:';
  csdFullName:   Utf8String = 'FN:';
  csdOrg:        Utf8String = 'ORG:';
  csdTitle:      Utf8String = 'TITLE:';
  csdVersion:    Utf8String = 'VERSION:';
  csdProdId:     Utf8String = 'PRODID:';
  csdNote:       Utf8String = 'NOTE:';
  csdRev:        Utf8String = 'REV:';
  csdXabadr:     Utf8String = 'X-ABADR:';

  csdAdr:        Utf8String = 'ADR;';
  csdTel:        Utf8String = 'TEL;';
  csdEmail:      Utf8String = 'EMAIL;';
  csdType:       Utf8String = 'TYPE=';

const
  csdProps = (csdBeginVcard);

type
  // Vcard properties
  TsdVcardProperty = (
    vpNone,
    vpBeginVcard,
    vpEndVcard,
    vpName,
    vpFullName
  );

{ TsdVcardParser }

type
  TsdVcardParser = class(TsdXmlParser)
  public
    function ReadProperty: TsdVcardProperty; virtual;
  end;

{ TsdVcardFormat }

procedure TsdVcardFormat.LoadFromFile(const AFileName: string);
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(AFileName, fmOpenRead);
  try
    DoDebugOut(nil, wsInfo, Format('loading file "%s"...', [AFileName]));
    LoadFromStream(FS);
  finally
    FS.Free;
  end;
end;

procedure TsdVcardFormat.LoadFromStream(S: TStream);
begin
  //
end;

{ TsdVcardParser }

function TsdVcardParser.ReadProperty: TsdVcardProperty;
var
  AnsiCh: AnsiChar;
begin
  Result := vpNone;
//  AnsiCh := NextChar;
//  if FEndOfStream then
//    exit;

  CheckString(
end;

end.
