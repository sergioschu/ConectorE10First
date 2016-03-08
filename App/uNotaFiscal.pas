unit uNotaFiscal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  System.Win.ComObj, System.TypInfo, Vcl.Samples.Gauges, Vcl.ImgList;

type
  TfrmNotaFiscal = class(TForm)
    pnVisualizacao: TPanel;
    dgNotaFiscal: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btAtualizar: TSpeedButton;
    pbAtualizaProduto: TGauge;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    csNotaFiscal: TClientDataSet;
    dsNotaFiscal: TDataSource;
    csNotaFiscalDOCUMENTO: TIntegerField;
    csNotaFiscalDATAEMISSAO: TDateField;
    csNotaFiscalSTATUS: TBooleanField;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure CarregaDados;
    procedure AtualizarNotasFiscais;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNotaFiscal: TfrmNotaFiscal;

implementation
uses
  uFuncoes,
  uMensagem,
  uDomains,
  uFWConnection,
  uBeanNotaFiscal,
  uBeanNotaFiscalItens;
{$R *.dfm}

{ TfrmNotaFiscal }

procedure TfrmNotaFiscal.AtualizarNotasFiscais;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  NF      : TNOTAFISCAL;
  NFI     : TNOTAFISCALITENS;
  List    : TPropList;
  Arquivo : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  Count,
  I,
  J       : Integer;
begin

end;

procedure TfrmNotaFiscal.CarregaDados;
var
  CON : TFWConnection;
  NF  : TNOTAFISCAL;
  I   : Integer;
begin
  CON    := TFWConnection.Create;
  NF     := TNOTAFISCAL.Create(CON);
  try
    csNotaFiscal.EmptyDataSet;

    NF.SelectList('status');

    for I := 0 to Pred(NF.Count) do begin
      csNotaFiscal.Append;
      csNotaFiscalDOCUMENTO.Value     := TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.Value;
      csNotaFiscalDATAEMISSAO.Value   := TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value;
      csNotaFiscalSTATUS.Value        := TNOTAFISCAL(NF.Itens[I]).STATUS.Value;
      csNotaFiscal.Post;
    end;

  finally
    FreeAndNil(NF);
    FreeAndNil(CON);
  end;
end;

procedure TfrmNotaFiscal.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmNotaFiscal.FormShow(Sender: TObject);
begin
  csNotaFiscal.CreateDataSet;
  csNotaFiscal.Open;
  CarregaDados;
  AutoSizeDBGrid(dgNotaFiscal);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

end.
