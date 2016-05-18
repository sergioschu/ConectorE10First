unit uRelDivergencias;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls;

type
  TfrmRelDivergencias = class(TForm)
    pnPrincipal: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btRelatorio: TSpeedButton;
    Panel2: TPanel;
    btSair: TSpeedButton;
    rgOpcoes: TRadioGroup;
    gbSelecionaPeriodo: TGroupBox;
    GridPanel2: TGridPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    edDataInicial: TDateTimePicker;
    Label1: TLabel;
    edDataFinal: TDateTimePicker;
    Label2: TLabel;
    cbExibirTodos: TCheckBox;
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
  frmRelDivergencias: TfrmRelDivergencias;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelDivergencias.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelDivergencias.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelDivergencias.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelDivergencias.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelDivergencias.VisualizarRelatorio;
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

      case rgOpcoes.ItemIndex of
        0 : begin//NOTA FISCAL

          SQL.SQL.Add('SELECT');
          SQL.SQL.Add('	NF.DATAEMISSAO,');
          SQL.SQL.Add('	NF.DOCUMENTO,');
          SQL.SQL.Add('	NF.DATA_IMPORTACAO,');
          SQL.SQL.Add('	NF.DATA_ENVIO,');
          SQL.SQL.Add('	NF.DATA_RECEBIDO,');
          SQL.SQL.Add('	((DATE_PART(''DAY'', AGE(NF.DATA_RECEBIDO, NF.DATA_ENVIO)) * 24) +');
          SQL.SQL.Add('	(DATE_PART(''HOURS'', AGE(NF.DATA_RECEBIDO, NF.DATA_ENVIO)))) AS HORAS,');
          SQL.SQL.Add('	(DATE_PART(''MINUTES'', AGE(NF.DATA_RECEBIDO, NF.DATA_ENVIO))) AS MINUTOS,');
          SQL.SQL.Add('	CASE WHEN STATUS = 2 THEN');
          SQL.SQL.Add('		''AGUARDANDO CONFERENCIA''');
          SQL.SQL.Add('		ELSE');
          SQL.SQL.Add('		CASE WHEN NF.DATA_ENVIO IS NULL	THEN');
          SQL.SQL.Add('			''AGUARDANDO ENVIO''');
          SQL.SQL.Add('			ELSE');
          SQL.SQL.Add('			CASE WHEN NF.DATA_RECEBIDO IS NULL THEN');
          SQL.SQL.Add('				''AGUARDANDO RECEBIMENTO'' END END END AS STATUS');
          SQL.SQL.Add('FROM NOTAFISCAL NF WHERE 1 = 1');
          if not cbExibirTodos.Checked then begin
            SQL.SQL.Add('AND CAST(NF.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
            SQL.ParamByName('DATAI').DataType := ftDate;
            SQL.ParamByName('DATAF').DataType := ftDate;
            SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
            SQL.ParamByName('DATAF').Value    := edDataFinal.Date;
          end;
          SQL.SQL.Add('AND ((NF.DATA_ENVIO IS NULL) OR (NF.DATA_RECEBIDO IS NULL) OR (NF.STATUS = 2))');
          SQL.SQL.Add('ORDER BY STATUS, NF.DOCUMENTO');
        end;
        1 : begin
          SQL.SQL.Add('SELECT');
          SQL.SQL.Add('	P.PEDIDO,');
          SQL.SQL.Add('	P.DATA_IMPORTACAO,');
          SQL.SQL.Add('	P.DATA_ENVIO,');
          SQL.SQL.Add('	P.DATA_RECEBIDO,');
          SQL.SQL.Add('	((DATE_PART(''DAY'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO)) * 24) +');
          SQL.SQL.Add('	(DATE_PART(''HOURS'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO)))) AS HORAS,');
          SQL.SQL.Add('	(DATE_PART(''MINUTES'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO))) AS MINUTOS,');
          SQL.SQL.Add('	CASE WHEN P.DATA_ENVIO IS NULL	THEN');
          SQL.SQL.Add('		''AGUARDANDO ENVIO''');
          SQL.SQL.Add('		ELSE');
          SQL.SQL.Add('		CASE WHEN P.DATA_RECEBIDO IS NULL THEN');
          SQL.SQL.Add('			''AGUARDANDO RECEBIMENTO''');
          SQL.SQL.Add('			ELSE');
          SQL.SQL.Add('			CASE WHEN P.DATA_FATURADO IS NULL THEN');
          SQL.SQL.Add('				''AGUARDANDO FATURAMENTO'' END END END AS STATUS');
          SQL.SQL.Add('FROM PEDIDO P WHERE 1 = 1');

          if not cbExibirTodos.Checked then begin
            SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
            SQL.ParamByName('DATAI').DataType := ftDate;
            SQL.ParamByName('DATAF').DataType := ftDate;
            SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
            SQL.ParamByName('DATAF').Value    := edDataFinal.Date;
          end;
          SQL.SQL.Add('AND ((P.DATA_ENVIO IS NULL) OR (P.DATA_RECEBIDO IS NULL) OR (P.DATA_FATURADO IS NULL))');
          SQL.SQL.Add('ORDER BY STATUS, P.PEDIDO');
        end;
      end;

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      case rgOpcoes.ItemIndex of
        0 : DMUtil.ImprimirRelatorio('frDivergenciasNotasFiscais.fr3');
        1 : DMUtil.ImprimirRelatorio('frDivergenciasPedidos.fr3');
      end;
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
