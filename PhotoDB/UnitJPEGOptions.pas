unit UnitJPEGOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Dolphin_DB, uDBForm, JPEG,
  Language;

type
  TDBJPEGOptions = record
    ProgressiveMode: Boolean;
    Compression: Integer;
  end;

type
  TCompresJPEGToSizeCallback = procedure(CurrentSize, CompressionRate: Integer; var Break: Boolean) of object;

type
  TFormJpegOptions = class(TDBForm)
    BtOK: TButton;
    BtCancel: TButton;
    Image1: TImage;
    LbInfo: TLabel;
    GbJPEGOption: TGroupBox;
    TbCompressionRate: TTrackBar;
    CbProgressiveMove: TCheckBox;
    lbCompressionRate: TLabel;
    CbOptimizeToSize: TCheckBox;
    Edit1: TEdit;
    LbKb: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtCancelClick(Sender: TObject);
    procedure TbCompressionRateChange(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure CbOptimizeToSizeClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FSection: string;
    { Private declarations }
  protected
    function GetFormID : string; override;
  public
    procedure LoadLanguage;
    procedure SetSection(Section: string);
    procedure Execute(Section: string);
    { Public declarations }
  end;

procedure SetJPEGOptions; overload;
procedure SetJPEGOptions(Section : String); overload;
procedure SetJPEGGraphicSaveOptions(Section : string; Graphic : TGraphic);
function CompresJPEGToSize(JS: TGraphic; var ToSize : Integer; Progressive : Boolean; var CompressionRate : Integer;
  CallBack: TCompresJPEGToSizeCallback = nil) : Boolean;

implementation

function CompresJPEGToSize(JS: TGraphic; var ToSize : Integer; Progressive : Boolean; var CompressionRate : Integer;
  CallBack: TCompresJPEGToSizeCallback = nil) : Boolean;
var
  Ms: TMemoryStream;
  Jd: TJPEGImage;
  Max_size, Cur_size, Cur_cr, Cur_cr_inc: Integer;
  IsBreak: Boolean;
begin
  Result := False;
  Max_size := ToSize;
  Cur_cr := 50;
  Cur_cr_inc := 50;
  IsBreak := False;
  Jd := TJpegImage.Create;
  try
    repeat
      Jd.Assign(Js);
      Jd.CompressionQuality := Cur_cr;
      Jd.ProgressiveEncoding := Progressive;
      Jd.Compress;
      Ms := TMemoryStream.Create;
      try
        Jd.SaveToStream(Ms);
        Cur_size := Ms.Size;

        if Assigned(CallBack) then
          CallBack(Cur_size, Cur_cr, IsBreak);

        if IsBreak then
        begin
          CompressionRate := -1;
          ToSize := -1;
          Exit;
        end;

        if ((Cur_size < Max_size) and (Cur_cr_inc = 1)) or (Cur_cr = 1) then
          Break;

        Cur_cr_inc := Round(Cur_cr_inc / 2);
        if Cur_cr_inc < 1 then
          Cur_cr_inc := 1;
        if Cur_size < Max_size then
        begin
          Cur_cr := Cur_cr + Cur_cr_inc;
        end
        else
          Cur_cr := Cur_cr - Cur_cr_inc;
        if (Cur_size < Max_size) and (Cur_cr = 99) then
          Cur_cr_inc := 2;

      finally
        Ms.Free;
      end;
    until False;
  finally
    JD.Free;
  end;

  CompressionRate := Cur_cr;
  ToSize := Cur_size;
  Result := True;
end;

procedure SetJPEGGraphicSaveOptions(Section : string; Graphic : TGraphic);
var
  OptimizeToSize : Integer;
  Progressive : Boolean;
  Compression : Integer;
begin
  if Graphic is TJPEGImage then
  begin
    OptimizeToSize := DBKernel.ReadInteger(Section, 'JPEGOptimizeSize', 100) * 1024;
    Progressive := DBKernel.ReadBool(Section, 'JPEGProgressiveMode', False);

    if DBKernel.ReadBool(Section, 'JPEGOptimizeMode', False) then
      CompresJPEGToSize(Graphic, OptimizeToSize, Progressive, Compression)
    else
      Compression := DBKernel.ReadInteger(Section, 'JPEGCompression', 75);

   (Graphic as TJPEGImage).CompressionQuality := Compression;
   (Graphic as TJPEGImage).ProgressiveEncoding := Progressive;
   (Graphic as TJPEGImage).Compress;
  end;
end;

{$R *.dfm}

procedure SetJPEGOptions;
var
  FormJpegOptions: TFormJpegOptions;
begin
  Application.CreateForm(TFormJpegOptions, FormJpegOptions);
  FormJpegOptions.Execute('');
  FormJpegOptions.Release;
end;

procedure SetJPEGOptions(Section: string);
var
  FormJpegOptions: TFormJpegOptions;
begin
  Application.CreateForm(TFormJpegOptions, FormJpegOptions);
  FormJpegOptions.Execute(Section);
  FormJpegOptions.Release;
end;

procedure TFormJpegOptions.FormCreate(Sender: TObject);
begin
  LoadLanguage;
  DBKernel.RecreateThemeToForm(Self);
end;

procedure TFormJpegOptions.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_ESCAPE) then
    Close;
end;

function TFormJpegOptions.GetFormID: string;
begin
  Result := 'JPEG';
end;

procedure TFormJpegOptions.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFormJpegOptions.TbCompressionRateChange(Sender: TObject);
begin
  lbCompressionRate.Caption := Format(L('JPEG compression (%d%%):'), [TbCompressionRate.Position * 5]);
end;

procedure TFormJpegOptions.BtOKClick(Sender: TObject);
begin
  DBKernel.WriteInteger(FSection, 'JPEGCompression', TbCompressionRate.Position * 5);
  DBKernel.WriteBool(FSection, 'JPEGProgressiveMode', CbProgressiveMove.Checked);
  DBKernel.WriteInteger(FSection, 'JPEGOptimizeSize', StrToIntDef(Edit1.Text, 100));
  DBKernel.WriteBool(FSection, 'JPEGOptimizeMode', CbOptimizeToSize.Checked);
  Close;
end;

procedure TFormJpegOptions.LoadLanguage;
begin
  Caption := L('JPEG compression');
  LbInfo.Caption := L('Choose JPEG mode and compression rate:');
  GbJPEGOption.Caption := L('JPEG');
  TbCompressionRateChange(Self);
  CbProgressiveMove.Caption := L('Progressive mode');
  BtCancel.Caption := L('Cancel');
  BtOk.Caption := L('Ok');
  CbOptimizeToSize.Caption := L('Optimize to size:');
  LbKb.Caption := L('Kb');
end;

procedure TFormJpegOptions.SetSection(Section: String);
begin
  FSection := Section;
end;

procedure TFormJpegOptions.Execute(Section: String);
begin
  SetSection(Section);
  TbCompressionRate.Position := DBKernel.ReadInteger(FSection, 'JPEGCompression', 75) div 5;
  CbProgressiveMove.Checked := DBKernel.ReadBool(FSection, 'JPEGProgressiveMode', False);
  Edit1.Text := IntToStr(DBKernel.ReadInteger(FSection, 'JPEGOptimizeSize', 100));
  CbOptimizeToSize.Checked := DBKernel.ReadBool(FSection, 'JPEGOptimizeMode', False);
  CbOptimizeToSizeClick(nil);
  ShowModal;
end;

procedure TFormJpegOptions.CbOptimizeToSizeClick(Sender: TObject);
begin
  Edit1.Enabled := CbOptimizeToSize.Checked;
  TbCompressionRate.Enabled := not CbOptimizeToSize.Checked;
end;

procedure TFormJpegOptions.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
    BtOKClick(Sender);
end;

end.
