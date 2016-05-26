unit uRelRetornoForadoPrazo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelRetornoForadoPrazo = class(TForm)
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
    edDataInicial: TJvDateEdit;
    edDataFinal: TJvDateEdit;
    GroupBox1: TGroupBox;
    cbApenasRecebidos: TCheckBox;
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure VisualizarRelatorio;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelRetornoForadoPrazo: TfrmRelRetornoForadoPrazo;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelRetornoForadoPrazo.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelRetornoForadoPrazo.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelRetornoForadoPrazo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelRetornoForadoPrazo.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelRetornoForadoPrazo.VisualizarRelatorio;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
begin

  DisplayMsg(MSG_WAIT, 'Buscando dados...');

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);

  try
    try

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.PEDIDO AS NUMERO_PEDIDO,');
      SQL.SQL.Add('	P.DATA_ENVIO,');
      SQL.SQL.Add('	P.DATA_RECEBIDO,');
      SQL.SQL.Add('	((DATE_PART(''DAY'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO)) * 24) +');
      SQL.SQL.Add('	(DATE_PART(''HOURS'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO)))) AS HORAS,');
      SQL.SQL.Add('	(DATE_PART(''MINUTES'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO))) AS MINUTOS,');
      SQL.SQL.Add('	CASE P.STATUS');
      SQL.SQL.Add('	WHEN 0 THEN ''Sem Transportadora''');
      SQL.SQL.Add('	WHEN 1 THEN ''Com Transportadora''');
      SQL.SQL.Add('	WHEN 2 THEN ''Pedido Enviado''');
      SQL.SQL.Add('	WHEN 3 THEN ''Pedido Recebido''');
      SQL.SQL.Add('	WHEN 4 THEN ''Pedido Impresso''');
      SQL.SQL.Add('	WHEN 6 THEN ''Pedido Cancelado''');
      SQL.SQL.Add('        ELSE');
      SQL.SQL.Add('		CASE WHEN ((P.STATUS = 5) AND (CHARACTER_LENGTH(COALESCE(P.CODIGO_RASTREIO, '''')) > 0))');
      SQL.SQL.Add('		THEN ''Pedido Despachado''');
      SQL.SQL.Add('		ELSE');
      SQL.SQL.Add('		''Pedido Faturado'' END END AS STATUS');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND P.DATA_ENVIO IS NOT NULL');
      SQL.SQL.Add('AND (EXTRACT(HOUR FROM P.DATA_ENVIO) < 18)');
      if cbApenasRecebidos.Checked then
        SQL.SQL.Add('AND P.DATA_RECEBIDO IS NOT NULL');
      SQL.SQL.Add('AND ((P.DATA_RECEBIDO IS NULL)');
      SQL.SQL.Add('	OR (CAST(P.DATA_RECEBIDO AS DATE) > CAST(P.DATA_ENVIO AS DATE))');
      SQL.SQL.Add('	OR ((CAST(P.DATA_ENVIO AS DATE) = CAST(P.DATA_RECEBIDO AS DATE)) AND (EXTRACT(HOUR FROM P.DATA_RECEBIDO) >= 22)))');
      SQL.SQL.Add('ORDER BY P.PEDIDO');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
      SQL.ParamByName('DATAF').Value    := edDataFinal.Date;

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      SQL.Open;
      SQL.FetchAll;

      DisplayMsgFinaliza;
      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frRetornoForadoPrazo.fr3');

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
