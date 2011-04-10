unit uFrmSelectDBFromList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, uFrameWizardBase, StdCtrls, ComCtrls, ComboBoxExDB, uMemory,
  UnitDBKernel, ImgList, UnitDBCommonGraphics, uShellIntegration, UnitDBDeclare,
  uConstants;

type
  TFrmSelectDBFromList = class(TFrameWizardBase)
    GbMain: TGroupBox;
    LbSelectFromList: TLabel;
    LbFileName: TLabel;
    CbDBList: TComboBoxExDB;
    SelectDBFileNameEdit: TEdit;
    CbDefaultDB: TCheckBox;
    DBImageList: TImageList;
    procedure CbDBListChange(Sender: TObject);
  private
    { Private declarations }
    procedure RefreshDBList;
    function GetDBFile: TPhotoDBFile;
  protected
    { Protected declarations }
    procedure LoadLanguage; override;
  public
    { Public declarations }
    function ValidateStep(Silent: Boolean): Boolean; override;
    procedure Execute; override;
    procedure Init(Manager: TWizardManagerBase; FirstInitialization: Boolean); override;
    function IsFinal: Boolean; override;
    property DBFile: TPhotoDBFile read GetDBFile;
  end;

implementation

uses
  UnitSelectDB;

{$R *.dfm}

{ TFrmSelectDBFromList }

procedure TFrmSelectDBFromList.CbDBListChange(Sender: TObject);
begin
  inherited;
  if CbDBList.Items.Count > 0 then
    SelectDBFileNameEdit.Text := DBKernel.DBs[CbDBList.ItemIndex].FileName;
end;

procedure TFrmSelectDBFromList.Execute;
begin
  inherited;
  DBKernel.AddDB(DBFile.Name, DBFile.FileName, DBFile.Icon);
  IsStepComplete := True;
  Changed;
end;

function TFrmSelectDBFromList.GetDBFile: TPhotoDBFile;
begin
  Result := TFormSelectDB(Manager.Owner).DBFile;
end;

procedure TFrmSelectDBFromList.Init(Manager: TWizardManagerBase;
  FirstInitialization: Boolean);
begin
  inherited;
  if FirstInitialization then
  begin
    CbDBListChange(Self);
    RefreshDBList;
  end;
end;

function TFrmSelectDBFromList.IsFinal: Boolean;
begin
  Result := True;
end;

procedure TFrmSelectDBFromList.LoadLanguage;
begin
  inherited;
  GbMain.Caption := L('Select collection');
  LbSelectFromList.Caption := L('Select collection from list') + ':';
  CbDefaultDB.Caption := L('Use as default collection');
  LbFileName.Caption := L('File name') + ':';
end;

procedure TFrmSelectDBFromList.RefreshDBList;
var
  I: Integer;
  Ico: TIcon;
begin
  CbDBList.Clear;
  DBImageList.Clear;
  DBImageList.BkColor := clWindow;

  for I := 0 to DBKernel.DBs.Count - 1 do
  begin
    with CbDBList.ItemsEx.Add do
    begin
      Caption := DBKernel.DBs[I].name;
      ImageIndex := I + 1;
    end;
    Ico := TIcon.Create;
    try
      Ico.Handle := ExtractSmallIconByPath(DBKernel.DBs[I].Icon);
      if Ico.Empty then
        Ico.Handle := ExtractSmallIconByPath(Application.ExeName + ',0');

      DBImageList.AddIcon(Ico);
    finally
      F(Ico);
    end;
  end;

  CbDBList.ItemIndex := 0;
  CbDBListChange(Self);
end;

function TFrmSelectDBFromList.ValidateStep(Silent: Boolean): Boolean;
begin
  Result := True;
  if not DBKernel.TestDB(DBFile.FileName) then
  begin
    if not Silent then
      MessageBoxDB(Handle, Format(TFormSelectDB(Manager.Owner).InvalidDBFileMessage,
          [DBKernel.DBs[CbDBList.ItemIndex].FileName]), L('Error'),
        TD_BUTTON_OK, TD_ICON_ERROR);
    Result := False;
  end;
end;

end.