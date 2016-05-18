unit uRelTempoResposta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls;

type
  TfrmRelTempoResposta = class(TForm)
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
    edDataInicial: TDateTimePicker;
    Label1: TLabel;
    edDataFinal: TDateTimePicker;
    Label2: TLabel;
    Panel5: TPanel;
    rgOpcoes: TRadioGroup;
    edTempo: TLabeledEdit;
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rgOpcoesClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure VisualizarRelatorio;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelTempoResposta: TfrmRelTempoResposta;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelTempoResposta.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelTempoResposta.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelTempoResposta.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelTempoResposta.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelTempoResposta.rgOpcoesClick(Sender: TObject);
begin
  case rgOpcoes.ItemIndex of
    0 : edTempo.EditLabel.Caption := 'Tempo em Horas';
    1 : edTempo.EditLabel.Caption := 'Tempo em Minutos';
  end;
end;

procedure TfrmRelTempoResposta.VisualizarRelatorio;
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
      SQL.SQL.Add('SELECT TIPO_DOCUMENTO, DOCUMENTO_PEDIDO, DATA_ENVIO, DATA_RECEBIDO, HORAS, MINUTOS FROM (');
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	''Notas Fiscais'' AS TIPO_DOCUMENTO,');
      SQL.SQL.Add('	CAST(NF.DOCUMENTO AS CHARACTER VARYING(20)) AS DOCUMENTO_PEDIDO,');
      SQL.SQL.Add('	NF.DATA_ENVIO,');
      SQL.SQL.Add('	NF.DATA_RECEBIDO,');
      SQL.SQL.Add('	((DATE_PART(''DAY'', AGE(NF.DATA_RECEBIDO, NF.DATA_ENVIO)) * 24) +');
      SQL.SQL.Add('	(DATE_PART(''HOURS'', AGE(NF.DATA_RECEBIDO, NF.DATA_ENVIO)))) AS HORAS,');
      SQL.SQL.Add('	(DATE_PART(''MINUTES'', AGE(NF.DATA_RECEBIDO, NF.DATA_ENVIO))) AS MINUTOS');
      SQL.SQL.Add('FROM NOTAFISCAL NF WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(NF.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND ((NF.DATA_ENVIO IS NOT NULL) AND (NF.DATA_RECEBIDO IS NOT NULL))');
      SQL.SQL.Add('');
      SQL.SQL.Add('UNION ALL');
      SQL.SQL.Add('');
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	''Pedidos'' AS TIPO_DOCUMENTO,');
      SQL.SQL.Add('	P.PEDIDO AS DOCUMENTO_PEDIDO,');
      SQL.SQL.Add('	P.DATA_ENVIO,');
      SQL.SQL.Add('	P.DATA_RECEBIDO,');
      SQL.SQL.Add('	((DATE_PART(''DAY'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO)) * 24) +');
      SQL.SQL.Add('	(DATE_PART(''HOURS'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO)))) AS HORAS,');
      SQL.SQL.Add('	(DATE_PART(''MINUTES'', AGE(P.DATA_RECEBIDO, P.DATA_ENVIO))) AS MINUTOS');
      SQL.SQL.Add('FROM PEDIDO P WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND ((P.DATA_ENVIO IS NOT NULL) AND (P.DATA_RECEBIDO IS NOT NULL))');
      SQL.SQL.Add(') AS CONTROLE');
      SQL.SQL.Add('WHERE 1 = 1');

      if StrToIntDef(edTempo.Text, 0) > 0 then begin
        SQL.SQL.Add('AND (((HORAS * 60) + MINUTOS) >= :MINUTOS)');
        SQL.ParamByName('MINUTOS').DataType := ftInteger;

        case rgOpcoes.ItemIndex of
          0 : SQL.ParamByName('MINUTOS').Value := StrToIntDef(edTempo.Text, 0) * 60;
          1 : SQL.ParamByName('MINUTOS').Value := StrToIntDef(edTempo.Text, 0);
        end;
      end;

      SQL.SQL.Add('ORDER BY TIPO_DOCUMENTO, DOCUMENTO_PEDIDO');

      ShowMessage(SQL.SQL.Text);

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
      SQL.ParamByName('DATAF').Value    := edDataFinal.Date;

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frControleTempoResposta.fr3');

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
