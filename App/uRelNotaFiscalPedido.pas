unit uRelNotaFiscalPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelNotaFiscalPedido = class(TForm)
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
    rgStatus: TRadioGroup;
    edDataInicial: TJvDateEdit;
    edDataFinal: TJvDateEdit;
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
  frmRelNotaFiscalPedido: TfrmRelNotaFiscalPedido;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelNotaFiscalPedido.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelNotaFiscalPedido.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelNotaFiscalPedido.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelNotaFiscalPedido.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelNotaFiscalPedido.VisualizarRelatorio;
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
      SQL.SQL.Add('	PNF.NUMERO_DOCUMENTO,');
      SQL.SQL.Add('	PNF.SERIE_DOCUMENTO,');
      SQL.SQL.Add('	PNF.DATA_ENVIO,');
      SQL.SQL.Add('	CASE PNF.STATUS WHEN 0 THEN ''Não Enviado''');
      SQL.SQL.Add('		ELSE ''Enviado'' END AS STATUS');
      SQL.SQL.Add('FROM PEDIDO_NOTAFISCAL PNF');
      SQL.SQL.Add('INNER JOIN PEDIDO P ON (PNF.ID_PEDIDO = P.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');

      case rgStatus.ItemIndex of
        0 : SQL.SQL.Add('AND PNF.STATUS = 0');
        1 : SQL.SQL.Add('AND PNF.STATUS = 1');
      end;

      SQL.SQL.Add('ORDER BY P.PEDIDO');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
      SQL.ParamByName('DATAF').Value    := edDataFinal.Date;

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frNotaFiscalPedido.fr3');

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
