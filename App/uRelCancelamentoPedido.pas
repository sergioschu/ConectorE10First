unit uRelCancelamentoPedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelCancelamentoPedido = class(TForm)
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
    rgTipoData: TRadioGroup;
    edDataInicial: TJvDateEdit;
    edDataFinal: TJvDateEdit;
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rgTipoDataClick(Sender: TObject);
  private
    procedure VisualizarRelatorio;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelCancelamentoPedido: TfrmRelCancelamentoPedido;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelCancelamentoPedido.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelCancelamentoPedido.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelCancelamentoPedido.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelCancelamentoPedido.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelCancelamentoPedido.rgTipoDataClick(Sender: TObject);
begin
  case rgTipoData.ItemIndex of
    0 : gbSelecionaPeriodo.Caption  := ' Data de Importação ';
    1 : gbSelecionaPeriodo.Caption  := ' Data de Cancelamento ';
  end;
end;

procedure TfrmRelCancelamentoPedido.VisualizarRelatorio;
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
      SQL.SQL.Add('');
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.PEDIDO AS NUMERO_PEDIDO,');
      SQL.SQL.Add('	PC.DATA_HORA,');
      SQL.SQL.Add('	U.NOME AS NOME_USUARIO,');
      SQL.SQL.Add('	PC.MOTIVO');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('INNER JOIN PEDIDO_CANCELAMENTO PC ON (PC.ID_PEDIDO = P.ID)');
      SQL.SQL.Add('INNER JOIN USUARIO U ON (PC.ID_USUARIO = U.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      case rgTipoData.ItemIndex of
        0 : SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
        1 : SQL.SQL.Add('AND CAST(PC.DATA_HORA AS DATE) BETWEEN :DATAI AND :DATAF');
      end;

      SQL.SQL.Add('ORDER BY P.PEDIDO, PC.DATA_HORA');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
      SQL.ParamByName('DATAF').Value    := edDataFinal.Date;

      SQL.Connection                    := FWC.FDConnection;
      SQL.Prepare;

      SQL.Open;
      SQL.FetchAll;

      DMUtil.frxDBDataset1.DataSet := SQL;
      DMUtil.ImprimirRelatorio('frPedidoCancelamento.fr3');

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
