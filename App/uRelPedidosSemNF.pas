unit uRelPedidosSemNF;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelPedidosSemNF = class(TForm)
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
  frmRelPedidosSemNF: TfrmRelPedidosSemNF;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelPedidosSemNF.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelPedidosSemNF.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelPedidosSemNF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelPedidosSemNF.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelPedidosSemNF.VisualizarRelatorio;
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
      SQL.SQL.Add('	P.DATA_IMPORTACAO,');
      SQL.SQL.Add('	P.DATA_ENVIO,');
      SQL.SQL.Add('	P.DATA_RECEBIDO,');
      SQL.SQL.Add('	P.DATA_FATURADO');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND P.STATUS = 5');
      SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
      SQL.SQL.Add('AND NOT EXISTS (SELECT ID FROM PEDIDO_NOTAFISCAL PNF WHERE (PNF.ID_PEDIDO = P.ID))');
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
      DMUtil.ImprimirRelatorio('frPedidosSemNF.fr3');

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
