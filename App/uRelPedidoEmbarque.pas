unit uRelPedidoEmbarque;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  FireDAC.Comp.Client, Data.DB, Vcl.ComCtrls, Vcl.Mask, JvExMask, JvToolEdit;

type
  TfrmRelPedidoEmbarque = class(TForm)
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
    rgTipoRelatorio: TRadioGroup;
    gbPedidoEspecifico: TGroupBox;
    edNumeroPedido: TLabeledEdit;
    procedure btSairClick(Sender: TObject);
    procedure btRelatorioClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rgTipoDataClick(Sender: TObject);
    procedure rgTipoRelatorioClick(Sender: TObject);
  private
    procedure VisualizarRelatorio;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelPedidoEmbarque: TfrmRelPedidoEmbarque;

implementation

uses
  uMensagem,
  uFWConnection,
  uDMUtil;

{$R *.dfm}

procedure TfrmRelPedidoEmbarque.btRelatorioClick(Sender: TObject);
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

procedure TfrmRelPedidoEmbarque.btSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelPedidoEmbarque.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmRelPedidoEmbarque.FormShow(Sender: TObject);
begin
  edDataInicial.Date  := Date;
  edDataFinal.Date    := Date;
end;

procedure TfrmRelPedidoEmbarque.rgTipoDataClick(Sender: TObject);
begin
  case rgTipoData.ItemIndex of
    0 : gbSelecionaPeriodo.Caption  := ' Data Importação ';
    1 : gbSelecionaPeriodo.Caption  := ' Data do Embarque ';
  end;
end;

procedure TfrmRelPedidoEmbarque.rgTipoRelatorioClick(Sender: TObject);
begin
  case rgTipoRelatorio.ItemIndex of
    0 : begin
      rgTipoData.Enabled := True;
    end;
    1 : begin
      rgTipoData.ItemIndex := 0;
      rgTipoData.Enabled := False;
    end;
  end;
end;

procedure TfrmRelPedidoEmbarque.VisualizarRelatorio;
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

      case rgTipoRelatorio.ItemIndex of
        0 : begin

          SQL.SQL.Add('SELECT');
          SQL.SQL.Add('	P.PEDIDO,');
          SQL.SQL.Add('	P.DATA_IMPORTACAO,');
          SQL.SQL.Add('	PE.DATA_EMBARQUE,');
          SQL.SQL.Add('	T.CNPJ AS CNPJTRANSPORTADORA,');
          SQL.SQL.Add('	T.NOME AS NOMETRANSPORTADORA');
          SQL.SQL.Add('FROM PEDIDO P');
          SQL.SQL.Add('INNER JOIN PEDIDO_EMBARQUE PE ON (P.ID = PE.ID_PEDIDO)');
          SQL.SQL.Add('INNER JOIN TRANSPORTADORA T ON (PE.ID_TRANSPORTADORA = T.ID)');
          SQL.SQL.Add('WHERE 1 = 1');

          if Length(Trim(edNumeroPedido.Text)) > 0 then begin
            SQL.SQL.Add('AND P.PEDIDO = :NUMEROPEDIDO');
            SQL.ParamByName('NUMEROPEDIDO').DataType := ftString;
            SQL.ParamByName('NUMEROPEDIDO').Value    := edNumeroPedido.Text;
          end else begin

            case rgTipoData.ItemIndex of
              0 : SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
              1 : SQL.SQL.Add('AND CAST(PE.DATA_EMBARQUE AS DATE) BETWEEN :DATAI AND :DATAF');
            end;

            SQL.ParamByName('DATAI').DataType := ftDate;
            SQL.ParamByName('DATAF').DataType := ftDate;
            SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
            SQL.ParamByName('DATAF').Value    := edDataFinal.Date;
          end;

          SQL.SQL.Add('ORDER BY P.PEDIDO');

          SQL.Connection                    := FWC.FDConnection;
          SQL.Prepare;

          SQL.Open;
          SQL.FetchAll;

          DMUtil.frxDBDataset1.DataSet := SQL;

          DMUtil.ImprimirRelatorio('frEmbarquePedido.fr3');
        end;
        1 : begin //Pedidos sem Embarque

          SQL.SQL.Add('SELECT');
          SQL.SQL.Add('	P.PEDIDO,');
          SQL.SQL.Add('	P.DATA_IMPORTACAO,');
          SQL.SQL.Add('	P.DATA_ENVIO,');
          SQL.SQL.Add('	P.DATA_RECEBIDO');
          SQL.SQL.Add('FROM PEDIDO P');
          SQL.SQL.Add('WHERE 1 = 1');
          SQL.SQL.Add('AND NOT EXISTS (SELECT PEDIDO_EMBARQUE.ID FROM PEDIDO_EMBARQUE WHERE ID_PEDIDO = P.ID)');

          if Length(Trim(edNumeroPedido.Text)) > 0 then begin
            SQL.SQL.Add('AND P.PEDIDO = :NUMEROPEDIDO');
            SQL.ParamByName('NUMEROPEDIDO').DataType := ftString;
            SQL.ParamByName('NUMEROPEDIDO').Value    := edNumeroPedido.Text;
          end else begin
            case rgTipoData.ItemIndex of
              0 : begin
                SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');
                SQL.ParamByName('DATAI').DataType := ftDate;
                SQL.ParamByName('DATAF').DataType := ftDate;
                SQL.ParamByName('DATAI').Value    := edDataInicial.Date;
                SQL.ParamByName('DATAF').Value    := edDataFinal.Date;
              end;
            end;
          end;

          SQL.SQL.Add('ORDER BY P.PEDIDO');

          SQL.Connection                    := FWC.FDConnection;
          SQL.Prepare;

          SQL.Open;
          SQL.FetchAll;

          DMUtil.frxDBDataset1.DataSet := SQL;
          DMUtil.ImprimirRelatorio('frPedidosSemEmbarque.fr3');
        end;
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
