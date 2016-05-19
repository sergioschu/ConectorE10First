unit uRelCodigoRastreio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelCodigoRastreio = class(TForm)
    pnPrincipal: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    gbSelecionaPeriodo: TGroupBox;
    GridPanel2: TGridPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    gbSelecionaFornecedor: TGroupBox;
    btTransportadora: TSpeedButton;
    edTransportadora: TEdit;
    edDataI: TJvDateEdit;
    edDataF: TJvDateEdit;
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btTransportadoraClick(Sender: TObject);
  private
    procedure VisualizarRelatorio;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelCodigoRastreio: TfrmRelCodigoRastreio;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil,
  uBeanTransportadoras;

{$R *.dfm}

procedure TfrmRelCodigoRastreio.btRelatorioClick(Sender: TObject);
begin
  if btRelatorio.Tag = 0 then begin
    btRelatorio.Tag   := 1;
    try
      VisualizarRelatorio;
    finally
      btRelatorio.Tag := 0;
    end;
  end;
end;

procedure TfrmRelCodigoRastreio.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelCodigoRastreio.btTransportadoraClick(Sender: TObject);
var
  FWC : TFWConnection;
  T   : TTRANSPORTADORA;
  Ret : Integer;
begin
  edTransportadora.Clear;
  edTransportadora.Tag := 0;

  FWC := TFWConnection.Create;
  T   := TTRANSPORTADORA.Create(FWC);

  try
    Ret := DMUtil.Selecionar(T, '');
    if Ret > 0 then begin
      T.SelectList('ID = ' + IntToStr(Ret));
      if T.Count > 0 then begin
        edTransportadora.Tag  := TTRANSPORTADORA(T.Itens[0]).ID.Value;
        edTransportadora.Text := TTRANSPORTADORA(T.Itens[0]).NOME.asString;
      end;
    end;
  finally
    FreeAndNil(T);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmRelCodigoRastreio.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelCodigoRastreio.FormShow(Sender: TObject);
begin
  edDataI.Date  := Date;
  edDataF.Date  := Date;
end;

procedure TfrmRelCodigoRastreio.VisualizarRelatorio;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
begin

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  try
    try

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.PEDIDO AS NUMERO_PEDIDO,');
      SQL.SQL.Add('	T.NOME AS NOME_TRANSPORTADORA,');
      SQL.SQL.Add('	P.CODIGO_RASTREIO');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('INNER JOIN TRANSPORTADORA T ON (P.ID_TRANSPORTADORA = T.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_FATURADO AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND P.STATUS = 5 AND ((P.CODIGO_RASTREIO IS NOT NULL) AND (CHARACTER_LENGTH(P.CODIGO_RASTREIO) > 0))');

      if edTransportadora.Tag > 0 then begin
        SQL.SQL.Add('AND T.ID = :ID_TRANSPORTADORA');
        SQL.ParamByName('ID_TRANSPORTADORA').DataType := ftInteger;
        SQL.ParamByName('ID_TRANSPORTADORA').Value    := edTransportadora.Tag;
      end;

      SQL.SQL.Add('ORDER BY P.PEDIDO');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataI.Date;
      SQL.ParamByName('DATAF').Value    := edDataF.Date;

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frCodigoRastreio.fr3');

      DisplayMsgFinaliza;

    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Ocorreram erros ao buscar dados!', '', E.Message);
      end;
    end;
  finally
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;
end;

end.
