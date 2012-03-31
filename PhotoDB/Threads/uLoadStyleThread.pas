unit uLoadStyleThread;

interface

uses
  Windows,
  Vcl.Styles,
  Themes,
  SysUtils,
  uLogger,
  uSettings,
  uConstants,
  uDBThread,
  uRuntime,
  Classes;

type
  TLoadStyleThread = class(TDBThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

uses
  uFastLoad;

{ TLoadStyleThread }

procedure TLoadStyleThread.Execute;
var
  StyleFileName: string;
  StyleHandle: TStyleManager.TStyleServicesHandle;
  SI: TStyleInfo;
begin
  FreeOnTerminate := True;
  try
    if not FolderView then
    begin
      StyleFileName := Settings.ReadString('Style', 'FileName', DefaultThemeName);
      if StyleFileName <> '' then
      begin
        StyleFileName := ExtractFilePath(ParamStr(0)) + StylesFolder + StyleFileName;
        if TStyleManager.IsValidStyle(StyleFileName, SI) then
        begin
          TStyleManager.LoadFromFile(StyleFileName);
          TStyleManager.SetStyle(si.Name);
        end;
      end;
    end else
    begin
      TStyleManager.Initialize;
      if TStyleManager.TryLoadFromResource(HInstance, 'MOBILE_STYLE', PWideChar(StyleResourceSection), StyleHandle ) then
        TStyleManager.SetStyle(StyleHandle);
    end;
  except
    on e: Exception do
      EventLog(e);
  end;
end;

initialization
  TLoad.Instance.StartStyleThread;

end.