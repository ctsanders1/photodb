unit FormManegerUnit;

interface

uses
  GraphicCrypt, DB, UnitINI, UnitTerminationApplication,
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms,  uVistaFuncs, UnitDBNullQueryThread, AppEvnts, ExtCtrls,
  Dialogs, dolphin_db, Crypt, CommonDBSupport, UnitDBDeclare, UnitFileExistsThread,
  UnitDBCommon, uLogger, uConstants, uFileUtils, uTime, uSplashThread;

type
  TFormManager = class(TForm)
    procedure CalledTimerTimer(Sender: TObject);
    procedure CheckTimerTimer(Sender: TObject);
    procedure TimerCloseApplicationByDBTerminateTimer(Sender: TObject);
  private    
    { Private declarations }
    FMainForms : TList;
    FTemtinatedActions : TTemtinatedActions;  
    CanCheckViewerInMainForms : Boolean;
    FCheckCount : Integer;     
    WasIde : Boolean;
    ExitAppl : Boolean;
    LockCleaning : Boolean;
    EnteringCodeNeeded : Boolean;
    procedure ExitApplication;
    procedure WMCopyData(var Msg : TWMCopyData); message WM_COPYDATA;
    procedure InitializeActivation;
  public
    constructor Create(AOwner : TComponent);  override;
    destructor Destroy; override;
    procedure RegisterMainForm(Value: TForm);
    procedure UnRegisterMainForm(Value: TForm);
    procedure RegisterActionCanTerminating(Value: TTemtinatedAction);
    procedure UnRegisterActionCanTerminating(Value: TTemtinatedAction);
    procedure Run(LoadingThread : TThread);
    procedure Close(Form : TForm);
    procedure AppMinimize(Sender: TObject);
    function MainFormsCount : Integer;
    function IsMainForms(Form : TForm) : Boolean;
    procedure CloseApp(Sender : TObject);
    procedure Load;
  end;

var
  FormManager: TFormManager;
  TimerTerminateHandle : THandle;
  TimerCheckMainFormsHandle : THandle;
  TimerTerminateAppHandle : THandle;    
  TimerCloseHandle : THandle;

const
  TIMER_TERMINATE = 1;  
  TIMER_TERMINATE_APP = 2;
  TIMER_CHECK_MAIN_FORMS = 3;  
  TIMER_CLOSE = 4;

implementation

uses Language, UnitCleanUpThread, ExplorerUnit, Searching, SlideShow,
DBSelectUnit, uActivation, UnitUpdateDB, UnitInternetUpdate, uAbout,
UnitConvertDBForm, UnitImportingImagesForm, UnitFileCheckerDB,
UnitSelectDB, UnitFormCont, UnitGetPhotosForm, UnitLoadFilesToPanel;

{$R *.dfm}

// callback function for Timer
procedure TimerProc(wnd :HWND; // handle of window for timer messages
                    uMsg :UINT; // WM_TIMER message
                    idEvent :UINT; // timer identifier
                    dwTime :DWORD // current system time
                    ); stdcall; // use stdcall when declare callback functions
begin
  if idEvent = TimerTerminateHandle then
  begin
    KillTimer(0, TimerTerminateHandle);
    EventLog('TFormManager::TerminateTimerTimer()!');
    Halt;
  end else if idEvent = TimerCheckMainFormsHandle then
  begin
    if FormManager <> nil then
      FormManager.CheckTimerTimer(nil);
  end else if idEvent = TimerTerminateAppHandle then
  begin
    if FormManager <> nil then
      FormManager.CalledTimerTimer(nil);
  end else if idEvent = TimerCloseHandle then
  begin
    if FormManager <> nil then
      FormManager.TimerCloseApplicationByDBTerminateTimer(nil);
  end;
end;

{ TFormManager }

procedure TFormManager.InitializeActivation;
var
  Reg : TBDRegistry;
  days : integer;
  d1 : tdatetime;

begin
 if DBKernel.ProgramInDemoMode and not DBInDebug then
 begin
  try
   Reg:=TBDRegistry.Create(REGISTRY_CLASSES);
   Reg.OpenKey('CLSID\{F70C45B3-1D2B-4FC3-829F-16E5AF6937EB}\',true);  
   d1:=now;
   if Reg.ValueExists('VersionTimeA') then
   begin
    if Reg.ReadBool('VersionTimeA') then
    begin
     Reg.free;
     EnteringCodeNeeded:=true;
     MessageBoxDB(FormManager.Handle,TEXT_MES_LIMIT_TIME_END,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
     exit;
    end
   end else if reg.ValueExists('VersionTime') then
   d1:=reg.Readdatetime('VersionTime') else
   begin
    reg.Writedatetime('VersionTime',now);
    d1:=now;
   end;
   days:=round(now-d1);
   if days<0 then
   begin
    reg.WriteBool('VersionTimeA',true);  
    Reg.free;
    EnteringCodeNeeded:=true;
    MessageBoxDB(FormManager.Handle,TEXT_MES_LIMIT_TIME_END,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
    exit;
   end;
   if (days>DemoDays) and not DBInDebug then
   begin
    reg.WriteBool('VersionTimeA',True);   
    Reg.free;
    EnteringCodeNeeded:=true;
    MessageBoxDB(FormManager.Handle,TEXT_MES_LIMIT_TIME_END,TEXT_MES_WARNING,TD_BUTTON_OK,TD_ICON_INFORMATION);
    exit;
   end;
   Reg.free;
  except
   on e : Exception do
   begin
    MessageBoxDB(FormManager.Handle,Format(TEXT_MES_UNKNOWN_ERROR_F,[e.Message]),TEXT_MES_ERROR ,TD_BUTTON_OK,TD_ICON_INFORMATION);
    Exit;
   end;
  end;
 end;
end;

procedure TFormManager.Run(LoadingThread : TThread);
var
  Directory, s : String;
  ParamStr1, ParamStr2 : String;
  NewSearch : TSearchForm;
  IDList : TArInteger;
  FileList : TArStrings;
  i : integer;

  procedure CloseLoadingForm;
  begin
    LoadingThread.Terminate;
  end;

  function IsFile(s : string) : Boolean;
  var
    Ext : string;
  begin
    Result := False;
    s := Trim(s);
    if ExtractFileName(s) <> '' then
    begin
      Ext := ExtractFileExt(s);
      if (Ext <> '') and (Ext[1] = '.') then
        Result := True;
    end;
  end;

begin
try
 EventLog(':TFormManager::Run()...');
 DBKernel.WriteProperty('Starting','ApplicationStarted','1');

 ParamStr1:=ParamStr(1);
 ParamStr2:=Paramstr(2);
 Directory:=ParamStr2;
 UnFormatDir(Directory);
 Directory:=LongFileName(Directory);
 FormatDir(Directory);
 if FolderView then
 begin
  ParamStr1:='/EXPLORER';
  Directory:=GetDirectory(Application.Exename);
  UnformatDir(Directory);
 end;

 if UpcaseAll(ParamStr1)<>'/EXPLORER' then
 begin
  TW.I.Start('CheckFileExistsWithMessageEx - ParamStr1');
  if IsFile(ParamStr1) then
  begin
   if not ExtInMask(SupportedExt,GetExt(ParamStr1)) then
   begin
    NewSearch:=SearchManager.NewSearch;
    if CheckFileExistsWithMessageEx(ParamStr1,false) then
    begin
     if GetExt(ParamStr1)='IDS' then
     begin
      s:=LoadIDsFromfile(ParamStr1);
      NewSearch.SearchEdit.Text:=Copy(s,1,1000);
      NewSearch.DoSearchNow(nil);
     end;
     if GetExt(ParamStr1)='ITH' then
     begin
      s:=LoadIDsFromfile(ParamStr1);
      NewSearch.SearchEdit.Text:=':ThFile('+ParamStr1+'):';
      NewSearch.DoSearchNow(nil);
     end;
     if GetExt(ParamStr1)='DBL' then
     begin
      LoadDblFromfile(ParamStr1,IDList,FileList);
      s:='';
      for i:=1 to Length(IDList) do
      s:=s+IntToStr(IDList[i-1])+'$';
      NewSearch.SearchEdit.Text:=Copy(s,1,500);
      NewSearch.DoSearchNow(nil);
     end;
    end;  
    CloseLoadingForm;         
    NewSearch.Show;
   end else
   begin
    TW.I.Start('RUN TViewer');
    if Viewer = nil then
      Application.CreateForm(TViewer, Viewer);
    RegisterMainForm(Viewer);
    TW.I.Start('ExecuteDirectoryWithFileOnThread');
    Viewer.ExecuteDirectoryWithFileOnThread(LongFileName(ParamStr1));
    TW.I.Start('ActivateApplication');
    CloseLoadingForm;
    Viewer.Show;
   end;
  end else
  begin
   //Default Form
   if DBKernel.ReadBool('Options','RunExplorerAtStartUp',false) then
   begin     
    TW.I.Start('RUN NewExplorer');
    With ExplorerManager.NewExplorer(False) do
    begin
     if DBKernel.ReadBool('Options','UseSpecialStartUpFolder',false) then
     SetPath(DBKernel.ReadString('Options','SpecialStartUpFolder')) else
     SetNewPathW(GetCurrentPathW,false); 
     CloseLoadingForm;   
     Show;
    end;
   end else
   begin               
   TW.I.Start('SearchManager.NewSearch');
    NewSearch:=SearchManager.NewSearch;
    Application.Restore; 
    CloseLoadingForm;
    NewSearch.Show;
   end;
  end;
 end else
 begin
  If DirectoryExists(Directory) then
  begin
   With ExplorerManager.NewExplorer(False) do
   begin
    SetPath(Directory);    
    CloseLoadingForm;
    Show;
   end;
  end else
  begin
   Application.Restore;
   With SearchManager.NewSearch do
   begin
    Show;    
    CloseLoadingForm;       
   end;
  end;
 end;
 FCheckCount := 0;
 TimerCheckMainFormsHandle := SetTimer(0, TIMER_CHECK_MAIN_FORMS, 100, @TimerProc);
 finally
  ShowWindow(Application.MainForm.Handle, SW_HIDE);
  ShowWindow(Application.Handle, SW_HIDE);
 end;
end;

procedure TFormManager.Close(Form: TForm);
begin
  UnRegisterMainForm(Self);
end;

procedure TFormManager.RegisterMainForm(Value: TForm);
begin
  if Value <> Viewer then
    CanCheckViewerInMainForms := True;
  FMainForms.Add(Value);
end;

procedure TFormManager.UnRegisterMainForm(Value: TForm);
var
  i : integer;
begin
  FMainForms.Remove(Value);
  try
    for i:=FMainForms.Count - 1 downto 1 do
      if not TForm(FMainForms[i]).Visible then
        TForm(FMainForms[i]).Close;
  except
    on e : Exception do EventLog(':TFormManager::UnRegisterMainForm() throw exception: ' + e.Message);
  end;
end;

procedure TFormManager.ExitApplication;
Var
  i : Integer;
  FirstTick : Cardinal;
  ApplReadyForEnd : Boolean;
begin
  if ExitAppl then exit;
    ExitAppl := True;
      
  EventLog(':TFormManager::ExitApplication()...');

  for i := 0 to FMainForms.Count - 1 do
    if not TForm(FMainForms[i]).Visible then
    begin
    try
      TForm(FMainForms[i]).Close;
    except
      on e : Exception do EventLog(':TFormManager::ExitApplication()/CloseForms throw exception: ' + e.Message);
    end;
 end;

 //to allow run new copy
 Caption := '';

 for i:=0 to Length(FTemtinatedActions)-1 do
 if (FTemtinatedActions[i].Options=TA_INFORM) or (FTemtinatedActions[i].Options=TA_INFORM_AND_NT) then
 begin
 end;
 Delay(10);
 ApplReadyForEnd:=false;
 for i:=0 to Length(FTemtinatedActions)-1 do
 FTemtinatedActions[i].TerminatedPointer^:=True;
 FirstTick:=GetTickCount;
 Repeat
  Delay(10);
  try
  if (GetTickCount-FirstTick)>5000 then break;
  ApplReadyForEnd:=true;
  for i:=0 to Length(FTemtinatedActions)-1 do
  if not FTemtinatedActions[i].TerminatedPointer^ then
  begin
   ApplReadyForEnd:=false;
   break;
  end;
  except
   break;
  end;
  if ApplReadyForEnd then Break;
 until false;
  TerminationApplication.Create(False);
  
  FormManager := nil;
  TimerTerminateHandle := SetTimer(0, TIMER_TERMINATE, 10000, @TimerProc);
  Application.Terminate;
  TimerTerminateAppHandle := SetTimer(0, TIMER_TERMINATE_APP, 100, @TimerProc);

  DBKernel.WriteProperty('Starting','ApplicationStarted','0');
  EventLog(':TFormManager::ExitApplication()/OK...');
  EventLog('');
  EventLog('');
  EventLog('');
  EventLog('finalization:');
end;

procedure TFormManager.CalledTimerTimer(Sender: TObject);
begin
  Application.Terminate;
end;

//TODO: review IDLE
{procedure TFormManager.ApplicationEvents1Idle(Sender: TObject;
  var Done: Boolean);
begin
 if WasIde then exit;
 if LockCleaning then exit;
 WasIde:=True;
 DBkernel.BackUpTable;
 if DBKernel.ReadBool('Options','AllowAutoCleaning',false) then
 CleanUpThread.Create(False);
end;  }

procedure TFormManager.CheckTimerTimer(Sender: TObject);
begin
  begin
    Inc(FCheckCount);
    if (FCheckCount = 10) then //after 1sec. set normal priority
    begin
//     SetProcessAffinityMask(MainThreadID, StartProcessorMask);
     SetThreadPriority(MainThreadID, THREAD_PRIORITY_NORMAL);
     SetPriorityClass(GetCurrentProcess, NORMAL_PRIORITY_CLASS);
    end;
    if CanCheckViewerInMainForms then
    begin
      if (FMainForms.Count = 1) and (FMainForms[0] = Viewer) and (Viewer <> nil) then
      begin
        CanCheckViewerInMainForms:=false;
        //to prevent many messageboxes
        KillTimer(0, TimerCheckMainFormsHandle);
        try
          ActivateApplication(Viewer.Handle);
          if ID_YES = MessageBoxDB(Viewer.Handle, TEXT_MES_VIEWER_REST_IN_MEMORY_CLOSE_Q, TEXT_MES_WARNING,TD_BUTTON_YESNO, TD_ICON_WARNING) then
            FMainForms.Clear;
        finally
           TimerCheckMainFormsHandle := SetTimer(0, TIMER_CHECK_MAIN_FORMS, 100, @TimerProc);
        end;
      end;
    end;
    if FMainForms.Count = 0 then
      ExitApplication;
  end;
end;

procedure TFormManager.RegisterActionCanTerminating(
  Value: TTemtinatedAction);
var
  i : integer;
  b : boolean;
begin
 b:=false;
 For i:=0 to Length(FTemtinatedActions)-1 do
 if FTemtinatedActions[i].Owner=Value.Owner then
 begin
  b:=true;
  break;
 end;
 If not b then
 begin
  SetLength(FTemtinatedActions,Length(FTemtinatedActions)+1);
  FTemtinatedActions[Length(FTemtinatedActions)-1]:=Value;
 end;
end;

procedure TFormManager.UnRegisterActionCanTerminating(
  Value: TTemtinatedAction);
var
  i, j : integer;
begin
 For i:=0 to Length(FTemtinatedActions)-1 do
 if FTemtinatedActions[i].Owner=Value.Owner then
 begin
  For j:=i to Length(FTemtinatedActions)-2 do
  FTemtinatedActions[j]:=FTemtinatedActions[j+1];
  SetLength(FTemtinatedActions,Length(FTemtinatedActions)-1);
  break;
 end;
end;

procedure TFormManager.AppMinimize;
begin
 //ShowWindow(Application.Handle, SW_HIDE);
end;

function TFormManager.MainFormsCount: Integer;
begin
  Result := FMainForms.Count;
end;

function TFormManager.IsMainForms(Form: TForm): Boolean;
begin
  Result:= FMainForms.IndexOf(Form) > -1;
end;

procedure TFormManager.CloseApp(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to FMainForms.Count - 1 do
    TForm(FMainForms[i]).Close;
end;

procedure TFormManager.TimerCloseApplicationByDBTerminateTimer(
  Sender: TObject);
begin
  inherited Close;
end;

procedure TFormManager.Load;
var
  DBVersion : integer;
  DBFile : TPhotoDBFile; 
  DateTime : TDateTime;   
begin
  TW.I.Start('FM -> Load');
 Caption:=DBID;
 CanCheckViewerInMainForms:=false;
 LockCleaning:=true;
 EnteringCodeNeeded := false;
 try
  TW.I.Start('FM -> InitializeDolphinDB');
  if not FolderView then
  InitializeActivation else
  begin
   dbname := GetDirectory(Application.ExeName)+'FolderDB.photodb';

   if FileExists(GetDirectory(ParamStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb') then
   dbname:=GetDirectory(ParamStr(0))+AnsiLowerCase(GetFileNameWithoutExt(paramStr(0)))+'.photodb';
  end;
 except
  on e : Exception do EventLog(':TFormManager::FormCreate() throw exception: '+e.Message);
 end;
 if DBTerminating then
   TimerCloseHandle := SetTimer(0, TIMER_CLOSE, 1000, @TimerProc);

 DateTime:=Now;
 If not DBTerminating then
 begin

 // DBVersion:=DBKernel.TestDBEx(dbname,true);

{  if DBVersion<0 then
  begin
   MessageBoxDB(Handle,TEXT_MES_DB_FILE_NOT_FOUND_ERROR,TEXT_MES_ERROR,TD_BUTTON_OK,TD_ICON_ERROR);

   DBFile:=DoChooseDBFile(SELECT_DB_OPTION_GET_DB_OR_EXISTS);
   if DBKernel.TestDB(DBFile.FileName) then
   DBKernel.AddDB(DBFile._Name,DBFile.FileName,DBFile.Icon);
   DBKernel.SetDataBase(DBFile.FileName);

   DBVersion:=DBKernel.TestDBEx(dbname,true);
   if not DBKernel.ValidDBVersion(dbname,DBVersion) then
   Halt;
  end else  }
  begin
  { if not DBKernel.ValidDBVersion(dbname,DBVersion) then
   begin
    ConvertDB(dbname);
    if not DBKernel.TestDB(dbname,true) then Halt;
   end else }
   begin
    if DBkernel.ReadboolW('DBCheckType',ExtractFileName(dbname),true)=true then
    begin
     //TODO: ???
     {if GetDBType=DB_TYPE_BDE then
     ConvertDB(dbname);}
     DBkernel.WriteBoolW('DBCheckType',ExtractFileName(dbname),false);
    end;
    //checking RecordCount
    if DBkernel.ReadboolW('DBCheck',ExtractFileName(dbname),true)=true then
    begin
     if CommonDBSupport.GetRecordsCount(dbname)=0 then
     begin
      if SplashThread <> nil then
        SplashThread.Terminate;
      begin
       //ImportImages(dbname);
       DBkernel.WriteBoolW('DBCheck',ExtractFileName(dbname),false);
      end;
     end else
     begin
      DBkernel.WriteBoolW('DBCheck',ExtractFileName(dbname),false);
     end;
    end;
   end;
  end;
  LockCleaning:=false;
 end;
  TW.I.Start('FM -> HidefromTaskBar');
  HidefromTaskBar(Application.Handle);
  if not DBTerminating then
  TInternetUpdate.Create(False, False);
  TW.I.Start('TInternetUpdate - Create');
end;

procedure TFormManager.WMCopyData(var Msg: TWMCopyData);
var
  Param : TArStrings;
  fids_ : TArInteger;
  FileNameA, FileNameB, S : string;
  n, i : integer;
  FormCont : TFormCont;
  B : TArBoolean;
  Info : TRecordsInfo;
  Data : Pointer;
begin

  if Msg.CopyDataStruct.dwData = WM_COPYDATA_ID then
  begin
    Data := PByte(Msg.CopyDataStruct.lpData) + SizeOf(TMsgHdr);
    SetString(S, PWideChar(Data), (Msg.CopyDataStruct.cbData - SizeOf(TMsgHdr) - 1) div SizeOf(WideChar));

     For i:=1 to Length(s) do
     If s[i]=#0 then
     begin
      FileNameA:=Copy(S,1,i-1);
      FileNameB:=Copy(S,i+1,Length(S)-i);
     end;
     if not CheckFileExistsWithMessageEx(FileNameA,false) then
     begin
      If AnsiUpperCase(FileNameA)='/EXPLORER' then
      begin
       If CheckFileExistsWithMessageEx(LongFileName(filenameB),true) then
       begin
        With ExplorerManager.NewExplorer(False) do
        begin
         SetPath(LongFileName(FileNameB));
         Show;
         ActivateApplication(Handle);
        end;
       end;
      end else
      begin
       if AnsiUpperCase(filenameA)='/GETPHOTOS' then
       if FileNameB<>'' then
       begin
        GetPhotosFromDrive(FileNameB[1]);
        Exit;
       end;
       With SearchManager.GetAnySearch do
       begin
        Show;
        ActivateApplication(Handle);
       end;
       Exit;
      end;
     end;
     If ExtInMask(SupportedExt,GetExt(FileNameA)) then
     begin
      if Viewer=nil then Application.CreateForm(TViewer, Viewer);
      FileNameA:=LongFileName(FileNameA);
      GetFileListByMask(FileNameA,SupportedExt,info,n,True);
      SlideShow.UseOnlySelf:=true;
      ShowWindow(Viewer.Handle,SW_RESTORE);
      Viewer.Execute(Self,info);
      Viewer.Show;
      ActivateApplication(Viewer.Handle);
     end else
     If (AnsiUpperCase(FileNameA)<>'/EXPLORER') and CheckFileExistsWithMessageEx(FileNameA,false) then
     begin
      if GetExt(FileNameA)='DBL' then
      begin
       Dolphin_DB.LoadDblFromfile(FileNameA,fids_,param);
       FormCont:=ManagerPanels.NewPanel;
       SetLength(B,0);
       LoadFilesToPanel.Create(param,fids_,B,false,true,FormCont);
       LoadFilesToPanel.Create(param,fids_,B,false,false,FormCont);
       FormCont.Show;
       ActivateApplication(FormCont.Handle);
       exit;
      end;
      if GetExt(filenameA)='IDS' then
      begin
       fids_:=LoadIDsFromfileA(FileNameA);
       setlength(param,1);
       FormCont:=ManagerPanels.NewPanel;
       LoadFilesToPanel.Create(param,fids_,B,false,true,FormCont);
       FormCont.Show;
       ActivateApplication(FormCont.Handle);
      end else
      begin
       if GetExt(FileNameA)='ITH' then
       begin
        With SearchManager.NewSearch do
        begin
          SearchEdit.Text:=':ThFile('+filenameA+'):';
          DoSearchNow(Self);
          Show;
          ActivateApplication(Handle);
        end;
        exit;
       end else
       begin
        With SearchManager.GetAnySearch do
        begin
         Show;
         ActivateApplication(Handle);
        end;
       end;
      end;
     end;


  end else
    Dispatch(Msg);

end;

constructor TFormManager.Create(AOwner: TComponent);
begin            
  FMainForms := TList.Create;
  WasIde := False;
  ExitAppl := False;
  LockCleaning := False;
  inherited Create(AOwner);
end;

destructor TFormManager.Destroy;
begin
  inherited;    
  FMainForms.Free;
end;

initialization

FormManager:=nil;

end.
