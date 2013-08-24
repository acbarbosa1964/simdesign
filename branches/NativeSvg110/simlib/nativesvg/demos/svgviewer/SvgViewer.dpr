program SvgViewer;

uses
  Forms,
  SvgViewerMain in 'SvgViewerMain.pas' {frmMain},
  pgSvgImport in '..\..\pgSvgImport.pas',
  sdDebug in '..\..\..\general\sdDebug.pas',
  Pyro in '..\..\..\pyro\source\Pyro.pas',
  pgScene in '..\..\..\pyro\source\pgScene.pas',
  pgRasterize in '..\..\..\pyro\source\pgRasterize.pas',
  NativeXmlC14n in '..\..\..\nativexml\NativeXmlC14n.pas',
  NativeXml in '..\..\..\nativexml\NativeXml.pas',
  pgPlatform in '..\..\..\pyro\source\pgPlatform.pas',
  pgCoreSceneViewer in '..\..\..\pyro\source\gui\pgCoreSceneViewer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

