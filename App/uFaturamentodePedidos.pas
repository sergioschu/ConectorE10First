unit uFaturamentodePedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, Vcl.ComCtrls;

type
  TFrmFaturamentodePedidos = class(TForm)
    pnVisualizacao: TPanel;
    gdPedidos: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btFaturar: TSpeedButton;
    btImprimir: TSpeedButton;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    dsPedidos: TDataSource;
    csPedidos: TClientDataSet;
    csPedidosID: TIntegerField;
    csPedidosPEDIDO: TStringField;
    csPedidosDEST_NOME: TStringField;
    csPedidosSTATUSTEXTO: TStringField;
    csPedidosSELECIONAR: TBooleanField;
    csPedidosDEST_MUNICIPIO: TStringField;
    csPedidosSTATUS: TIntegerField;
    csImpressaoPedidos: TClientDataSet;
    csImpressaoPedidosPEDIDO: TStringField;
    csImpressaoPedidosSKU: TStringField;
    csPedidosDATA_IMPORTACAO: TDateField;
    csPedidosDATA_FATURADO: TDateTimeField;
    pnConsulta: TPanel;
    btConsultar: TSpeedButton;
    gbPeriodo: TGroupBox;
    Label1: TLabel;
    edDataF: TDateTimePicker;
    edDataI: TDateTimePicker;
    rgStatus: TRadioGroup;
    btExportar: TSpeedButton;
    csImpressaoPedidosNOMETRANSPORTADORA: TStringField;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure csPedidosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gdPedidosCellClick(Column: TColumn);
    procedure gdPedidosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btFaturarClick(Sender: TObject);
    procedure btImprimirClick(Sender: TObject);
    procedure cbFiltroStatusChange(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure btExportarClick(Sender: TObject);
    procedure gdPedidosTitleClick(Column: TColumn);
  private
    procedure CarregaDados;
    procedure Filtrar;
    procedure FaturarPedidos;
    procedure ImprimirPedidos;
    procedure MarcarDesmarcarTodos;
    procedure OrdenarGrid(Column : TColumn);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmFaturamentodePedidos: TFrmFaturamentodePedidos;
  OrdenarPor : string;

implementation

uses
  uFuncoes,
  uConstantes,
  uMensagem,
  uFWConnection, uBeanPedido, uDMUtil;

{$R *.dfm}

procedure TFrmFaturamentodePedidos.btConsultarClick(Sender: TObject);
begin
  if btConsultar.Tag = 0 then begin
    btConsultar.Tag    := 1;
    try
      CarregaDados;
    finally
      btConsultar.Tag  := 0;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.btExportarClick(Sender: TObject);
Var
  Arq : string;
begin

  if btExportar.Tag = 0 then begin
    btExportar.Tag    := 1;
    try
      Arq := DirArquivosExcel;
      ExpXLS(csPedidos, 'Pedidos_' + FormatDateTime('ddmmyyyy', Date) + '.xlsx');
    finally
      btExportar.Tag  := 0;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.btFaturarClick(Sender: TObject);
begin
  if btFaturar.Tag = 0 then begin
    btFaturar.Tag    := 1;
    try
      FaturarPedidos;
    finally
      btFaturar.Tag  := 0;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmFaturamentodePedidos.btImprimirClick(Sender: TObject);
begin
  if btImprimir.Tag = 0 then begin
    btImprimir.Tag    := 1;
    try
      ImprimirPedidos;
    finally
      btImprimir.Tag  := 0;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.CarregaDados;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);
  try
    try

      csPedidos.DisableControls;
      csPedidos.EmptyDataSet;

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.ID,');
      SQL.SQL.Add('	P.PEDIDO,');
      SQL.SQL.Add('	CAST(P.DATA_ENVIO AS DATE) AS DATA_ENVIO,');
      SQL.SQL.Add('	P.DEST_NOME,');
      SQL.SQL.Add('	P.DEST_MUNICIPIO,');
      SQL.SQL.Add('	P.STATUS,');
      SQL.SQL.Add('	CASE P.STATUS WHEN 3 THEN ''MDD Recebido''');
      SQL.SQL.Add('	              WHEN 4 THEN ''Pedido Impresso''');
      SQL.SQL.Add('	              ELSE ''Pedido Faturado''');
      SQL.SQL.Add('	END AS STATUSTEXTO,');
      SQL.SQL.Add('	CAST(COALESCE(P.DATA_FATURADO, CURRENT_DATE) AS DATE) AS DATA_FATURADO');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_ENVIO AS DATE) BETWEEN :DATAI AND :DATAF');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataI.Date;
      SQL.ParamByName('DATAF').Value    := edDataF.Date;

      case rgStatus.ItemIndex of
        0 : SQL.SQL.Add('AND P.STATUS IN (3,4,5)');
        1 : SQL.SQL.Add('AND P.STATUS = 3');
        2 : SQL.SQL.Add('AND P.STATUS = 4');
        3 : SQL.SQL.Add('AND P.STATUS = 5');
      end;

      SQL.Connection                      := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open();

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          csPedidos.Append;
          csPedidosID.Value             := SQL.Fields[0].Value;
          csPedidosPEDIDO.Value         := SQL.Fields[1].Value;
          csPedidosDATA_IMPORTACAO.Value:= SQL.Fields[2].Value;
          csPedidosDEST_NOME.Value      := SQL.Fields[3].Value;
          csPedidosDEST_MUNICIPIO.Value := SQL.Fields[4].Value;
          csPedidosSTATUS.Value         := SQL.Fields[5].Value;
          csPedidosSTATUSTEXTO.Value    := SQL.Fields[6].Value;
          if SQL.Fields[5].Value = 5 then //Faturado
            csPedidosDATA_FATURADO.Value  := SQL.Fields[7].Value;
          csPedidos.Post;

          SQL.Next;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(SQL);
    FreeAndNil(FWC);
    csPedidos.EnableControls;
  end;
end;

procedure TFrmFaturamentodePedidos.cbFiltroStatusChange(Sender: TObject);
begin
  CarregaDados;
end;

procedure TFrmFaturamentodePedidos.csPedidosFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  Accept := False;
  for I := 0 to Pred(csPedidos.FieldCount) do begin
    Accept  := Pos(AnsiUpperCase(edPesquisa.Text), AnsiUpperCase(csPedidos.Fields[I].Value)) > 0;
    if Accept then
      Break;
  end;
end;

procedure TFrmFaturamentodePedidos.FaturarPedidos;
Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
  AtualizouPedido : Boolean;
begin
  if not csPedidos.IsEmpty then begin

    DisplayMsg(MSG_WAIT, 'Faturando Pedidos!');

    FWC := TFWConnection.Create;
    PED := TPEDIDO.Create(FWC);
    try
      try
        csPedidos.DisableControls;
        AtualizouPedido := False;

        csPedidos.First;
        while not csPedidos.Eof do begin
          if csPedidosSELECIONAR.Value then begin
            if csPedidosSTATUS.Value < 5 then begin
              PED.ID.Value            := csPedidosID.Value;
              PED.STATUS.Value        := 5;
              PED.ID_USUARIO.Value    := USUARIO.CODIGO;
              PED.DATA_FATURADO.Value := Now;
              PED.Update;
              AtualizouPedido := True;
            end;
          end;
          csPedidos.Next;
        end;

        if AtualizouPedido then
          FWC.Commit;

        DisplayMsg(MSG_OK, 'Pedidos Faturados com Sucesso!');

        CarregaDados;
      except
        on E : Exception do begin
          FWC.Rollback;
          DisplayMsg(MSG_ERR, 'Erro ao faturar Pedidos!', '', E.Message);
          Exit;
        end;
      end;
    finally
      FreeAndNil(PED);
      FreeAndNil(FWC);
      csPedidos.EnableControls;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.Filtrar;
begin
  csPedidos.Filtered := False;
  csPedidos.Filtered := edPesquisa.Text <> '';
end;

procedure TFrmFaturamentodePedidos.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmFaturamentodePedidos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : Close;
    VK_RETURN : begin
      if edPesquisa.Focused then begin
        Filtrar;
      end else begin
        if edPesquisa.CanFocus then begin
          edPesquisa.SetFocus;
          edPesquisa.SelectAll;
        end;
      end;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.FormShow(Sender: TObject);
begin
  csPedidos.CreateDataSet;
  csImpressaoPedidos.CreateDataSet;

  AutoSizeDBGrid(gdPedidos);

  edDataI.Date  := Date;
  edDataF.Date  := Date;

  CarregaDados;

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TFrmFaturamentodePedidos.gdPedidosCellClick(Column: TColumn);
begin
  if not csPedidos.IsEmpty then begin
    csPedidos.Edit;
    csPedidosSELECIONAR.Value := not csPedidosSELECIONAR.Value;
    csPedidos.Post;
  end;
end;

procedure TFrmFaturamentodePedidos.gdPedidosDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  IsChecked : array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  DrawRect: TRect;
begin
  if csPedidos.IsEmpty then Exit;

  if (gdSelected in State) or (gdFocused in State) then begin
    gdPedidos.Canvas.Font.Color   := clWhite;
    gdPedidos.Canvas.Brush.Color  := clBlue;
    gdPedidos.Canvas.Font.Style   := [];
  end;

  gdPedidos.DefaultDrawDataCell( Rect, gdPedidos.Columns[DataCol].Field, State);

  if Column.FieldName = csPedidosSELECIONAR.FieldName then begin
    DrawRect   := Rect;
    InflateRect(DrawRect,-1,-1);
    gdPedidos.Canvas.FillRect(Rect);
    DrawFrameControl(gdPedidos.Canvas.Handle, DrawRect, DFC_BUTTON, ISChecked[Column.Field.AsBoolean]);
  end;
end;

procedure TFrmFaturamentodePedidos.gdPedidosTitleClick(Column: TColumn);
begin
  if UpperCase(Column.FieldName) = 'SELECIONAR' then
    MarcarDesmarcarTodos
  else
    OrdenarGrid(Column);
end;

procedure TFrmFaturamentodePedidos.ImprimirPedidos;
Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
  SQL     : TFDQuery;
  AtualizouPedido : Boolean;
  Pedidos : String;
  I       : Integer;
begin
  if not csPedidos.IsEmpty then begin

    DisplayMsg(MSG_WAIT, 'Imprimindo Pedidos!');

    FWC := TFWConnection.Create;
    PED := TPEDIDO.Create(FWC);
    SQL := TFDQuery.Create(nil);
    try
      try
        csPedidos.DisableControls;
        AtualizouPedido := False;
        Pedidos         := EmptyStr;
        csImpressaoPedidos.EmptyDataSet;

        csPedidos.First;
        while not csPedidos.Eof do begin
          if csPedidosSELECIONAR.Value then begin

            //Armazena os pedidos para Impressão
            if Pedidos = EmptyStr then
              Pedidos := csPedidosID.AsString
            else
              Pedidos := Pedidos + ',' + csPedidosID.AsString;

            if csPedidosSTATUS.Value < 4 then begin
              PED.ID.Value          := csPedidosID.Value;
              PED.STATUS.Value      := 4;
              PED.ID_USUARIO.Value  := USUARIO.CODIGO;
              PED.Update;
              AtualizouPedido := True;
            end;
          end;
          csPedidos.Next;
        end;

        if Pedidos <> EmptyStr then begin
          SQL.Close;
          SQL.SQL.Clear;
          SQL.SQL.Add('SELECT');
          SQL.SQL.Add('	PED.PEDIDO AS NUMEROPEDIDO,');
          SQL.SQL.Add('	P.CODIGOPRODUTO AS SKU,');
          SQL.SQL.Add('	PEDITENS.QUANTIDADE,');
          SQL.SQL.Add(' T.NOME');
          SQL.SQL.Add('FROM PEDIDO PED');
          SQL.SQL.Add('INNER JOIN TRANSPORTADORA T ON PED.ID_TRANSPORTADORA = T.ID');
          SQL.SQL.Add('INNER JOIN PEDIDOITENS PEDITENS ON (PEDITENS.ID_PEDIDO = PED.ID)');
          SQL.SQL.Add('INNER JOIN PRODUTO P ON (P.ID = PEDITENS.ID_PRODUTO)');
          SQL.SQL.Add('WHERE 1 = 1');
          SQL.SQL.Add('AND PED.ID IN (' + Pedidos + ')');
          SQL.SQL.Add('ORDER BY 1,2');
          SQL.Connection  := FWC.FDConnection;
          SQL.Prepare;
          SQL.Open;
          SQL.FetchAll;

          if not SQL.IsEmpty then begin
            SQL.First;
            while not SQL.Eof do begin
              for I := 1 to SQL.FieldByName('QUANTIDADE').AsInteger do begin
                csImpressaoPedidos.Append;
                csImpressaoPedidosPEDIDO.Value              := SQL.FieldByName('NUMEROPEDIDO').Value;
                csImpressaoPedidosSKU.Value                 := SQL.FieldByName('SKU').Value;
                csImpressaoPedidosNOMETRANSPORTADORA.Value  := SQL.FieldByName('NOME').Value;
                csImpressaoPedidos.Post;
              end;
              SQL.Next;
            end;
          end;


          DMUtil.frxDBDataset1.DataSet := csImpressaoPedidos;
          DMUtil.ImprimirRelatorio('frFaturamentoPedidos.fr3');
        end;
        if AtualizouPedido then
          FWC.Commit;

        DisplayMsg(MSG_OK, 'Pedidos Impresso com Sucesso!');

        CarregaDados;
      except
        on E : Exception do begin
          FWC.Rollback;
          DisplayMsg(MSG_ERR, 'Erro ao Imprimir Pedidos!', '', E.Message);
          Exit;
        end;
      end;
    finally
      csImpressaoPedidos.EmptyDataSet;
      FreeAndNil(SQL);
      FreeAndNil(PED);
      FreeAndNil(FWC);
      csPedidos.EnableControls;
    end;
  end else
    DisplayMsg(MSG_WAR, 'Não há Pedidos para Impressão, Verifique!');
end;

procedure TFrmFaturamentodePedidos.MarcarDesmarcarTodos;
Var
  Aux : Boolean;
begin
  if not csPedidos.IsEmpty then begin

    Aux := not csPedidosSELECIONAR.Value;

    csPedidos.DisableControls;

    try
      csPedidos.First;
      while not csPedidos.Eof do begin
        csPedidos.Edit;
        csPedidosSELECIONAR.Value  := Aux;
        csPedidos.Post;
        csPedidos.Next;
      end;
    finally
      csPedidos.EnableControls;
      DisplayMsgFinaliza
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.OrdenarGrid(Column: TColumn);
var
  Decrescente : Boolean;
  IndexName   : String;
begin
  Decrescente := Column.FieldName = OrdenarPor;

  csPedidos.IndexDefs.Clear;
  if Decrescente then begin
    IndexName      :=  Column.FieldName + '_IDX_D';
    csPedidos.IndexDefs.Add(IndexName, Column.FieldName, [ixDescending]);
    OrdenarPor     := '';
  end else begin
    IndexName      := Column.FieldName + '_IDX';
    csPedidos.IndexDefs.Add(IndexName, Column.FieldName, []);
    OrdenarPor     := Column.FieldName;
  end;

  csPedidos.IndexName := IndexName;
end;

end.
