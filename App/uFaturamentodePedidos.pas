unit uFaturamentodePedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, Vcl.ComCtrls, System.Win.ComObj, Vcl.Mask,
  JvExMask, JvToolEdit;

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
    rgStatus: TRadioGroup;
    btExportar: TSpeedButton;
    csImpressaoPedidosNOMETRANSPORTADORA: TStringField;
    edTotalRegistros: TEdit;
    csImpressaoPedidosVOLUMES_DOCUMENTO: TIntegerField;
    btRastreio: TSpeedButton;
    OpenDialog1: TOpenDialog;
    edDataI: TJvDateEdit;
    edDataF: TJvDateEdit;
    csPedidosDATARETORNO: TDateTimeField;
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
    procedure btPesquisarClick(Sender: TObject);
    procedure btRastreioClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure Filtrar;
    procedure FaturarPedidos;
    procedure ImprimirPedidos;
    procedure MarcarDesmarcarTodos;
    procedure AtualizarCodigoRastreio;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmFaturamentodePedidos: TFrmFaturamentodePedidos;

implementation

uses
  uFuncoes,
  uConstantes,
  uMensagem,
  uFWConnection, uBeanPedido, uDMUtil;

{$R *.dfm}

procedure TFrmFaturamentodePedidos.AtualizarCodigoRastreio;
const
  xlCellTypeLastCell = $0000000B;
type
  TListaPedidos = record
    ID_Pedido : Integer;
    NumeroPedido : String;
    CodigoRastreio: String;
  End;

Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
  Arquivo,
  Aux     : String;
  Excel   : OleVariant;
  arrData : Variant;
  Contador,
  vrow,
  vcol,
  I, J    : Integer;
  ArqValido,
  AchouColuna     : Boolean;
  Colunas         : array of String;
  ListadePedidos  : array of TListaPedidos;
begin

  if OpenDialog1.Execute then begin
    if Pos(AnsiUpperCase(ExtractFileExt(OpenDialog1.FileName)), '|.XLS|.XLSX|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
        Exit;
      end;

      DisplayMsg(MSG_WAIT, 'Validando arquivo!');

      // Cria Excel- OLE Object
      Excel                      := CreateOleObject('Excel.Application');

      FWC       := TFWConnection.Create;
      PED       := TPEDIDO.Create(FWC);

      try
        try

          FWC.StartTransaction;

          // Esconde Excel
          Excel.Visible  := False;
          // Abre o Workbook
          Excel.Workbooks.Open(Arquivo);

          Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
          vrow                                 := Excel.ActiveCell.Row;
          vcol                                 := Excel.ActiveCell.Column;
          arrData                              := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

          SetLength(Colunas, 2);
          Colunas[0] := 'Pedido - Nº';
          Colunas[1] := 'Nr. de rastreio';

          ArqValido := True;
          for I := Low(Colunas) to High(Colunas) do begin
            AchouColuna := False;
            for J := 1 to vcol do begin
              if AnsiUpperCase(Colunas[I]) = AnsiUpperCase(arrData[1, J]) then begin
                AchouColuna := True;
                Break;
              end;
            end;
            if not AchouColuna then begin
              ArqValido := False;
              Break;
            end;
          end;

          if not ArqValido then begin
            Aux := 'Colunas.:';
            for I := Low(Colunas) to High(Colunas) do
              Aux := Aux + sLineBreak + Colunas[I];

            DisplayMsg(MSG_WAR, 'Arquivo Inválido, Verifique as Colunas!', '', Aux);
            Exit;
          end;

          DisplayMsg(MSG_WAIT, 'Capturando Pedidos do arquivo!');

          SetLength(ListadePedidos, 0);
          for I := 2 to vrow do begin

            SetLength(ListadePedidos, Length(ListadePedidos) + 1);
            ListadePedidos[High(ListadePedidos)].ID_Pedido      := 0;
            ListadePedidos[High(ListadePedidos)].NumeroPedido   := EmptyStr;
            ListadePedidos[High(ListadePedidos)].CodigoRastreio := EmptyStr;

            for J := 1 to vcol do begin
              if arrData[1, J] = 'Pedido - Nº' then
                ListadePedidos[High(ListadePedidos)].NumeroPedido := arrData[I, J]
              else
                if arrData[1, J] = 'Nr. de rastreio' then
                  ListadePedidos[High(ListadePedidos)].CodigoRastreio := arrData[I, J];
            end;
          end;

          DisplayMsg(MSG_WAIT, 'Identificando Pedidos!');

          for I := Low(ListadePedidos) to High(ListadePedidos) do begin
            if Length(Trim(ListadePedidos[I].CodigoRastreio)) > 0 then begin //Somente os que te Código de Rastreio

              PED.SelectList('STATUS = 5 AND PEDIDO = ' + QuotedStr(ListadePedidos[I].NumeroPedido));
              if PED.Count > 0 then
                ListadePedidos[I].ID_Pedido := TPEDIDO(PED.Itens[0]).ID.Value;
            end;
          end;

          DisplayMsg(MSG_WAIT, 'Atualizando Pedidos no Banco de Dados!');

          Contador := 0;
          //Começa a Gravação dos Dados no BD
          for I := Low(ListadePedidos) to High(ListadePedidos) do begin
            if ListadePedidos[I].ID_Pedido > 0 then begin
              PED.ClearFields;
              PED.ID.Value              := ListadePedidos[I].ID_Pedido;
              PED.CODIGO_RASTREIO.Value := ListadePedidos[I].CodigoRastreio;
              PED.Update;
              Contador := Contador + 1;
            end;
          end;

          if Contador > 0 then begin
            FWC.Commit;
            DisplayMsg(MSG_OK, 'Atualização Realizada com Sucesso!' + sLineBreak + sLineBreak + 'Foram atualizados ' + IntToStr(Contador) + ' Pedidos!');
          end else begin
            DisplayMsg(MSG_WAR, 'Nenhum Código de Rastreio foi Atualizado!');
          end;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Códigos de Rastreio!', '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData := Unassigned;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(PED);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

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

procedure TFrmFaturamentodePedidos.btPesquisarClick(Sender: TObject);
begin
  if btPesquisar.Tag = 0 then begin
    btPesquisar.Tag  := 1;
    try
      Filtrar;
      TotalizaRegistros(csPedidos, edTotalRegistros);
    finally
      btPesquisar.Tag := 0;
    end;
  end;
end;

procedure TFrmFaturamentodePedidos.btRastreioClick(Sender: TObject);
begin
  if btRastreio.Tag = 0 then begin
    btRastreio.Tag := 1;
    try
      AtualizarCodigoRastreio;
      //Só recarregar os dados caso estiver exibindo todos ou os Despachados
      if rgStatus.ItemIndex in [0,4] then
        CarregaDados;
    finally
      btRastreio.Tag := 0;
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
      SQL.SQL.Add('	CAST(P.DATA_IMPORTACAO AS DATE) AS DATA_IMPORTACAO,');
      SQL.SQL.Add('	P.DEST_NOME,');
      SQL.SQL.Add('	P.DEST_MUNICIPIO,');
      SQL.SQL.Add('	P.STATUS,');
      SQL.SQL.Add('	CASE WHEN ((P.STATUS = 5) AND (CHARACTER_LENGTH(COALESCE(P.CODIGO_RASTREIO, '''')) > 0))');
      SQL.SQL.Add('		THEN ''Pedido Despachado''');
      SQL.SQL.Add('			ELSE');
      SQL.SQL.Add('			CASE P.STATUS WHEN 3 THEN ''MDD Recebido''');
      SQL.SQL.Add('				WHEN 4 THEN ''Pedido Impresso''');
      SQL.SQL.Add('				WHEN 5 THEN ''Pedido Faturado''');
      SQL.SQL.Add('				WHEN 6 THEN ''Pedido Cancelado''');
      SQL.SQL.Add('				ELSE ''Status não Definido'' END END AS STATUSTEXTO,');
      SQL.SQL.Add('	CAST(COALESCE(P.DATA_FATURADO, CURRENT_DATE) AS DATE) AS DATA_FATURADO,');
      SQL.SQL.Add(' P.DATA_RECEBIDO');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataI.Date;
      SQL.ParamByName('DATAF').Value    := edDataF.Date;

      case rgStatus.ItemIndex of
        0 : SQL.SQL.Add('AND P.STATUS IN (3,4,5)');
        1 : SQL.SQL.Add('AND P.STATUS = 3');
        2 : SQL.SQL.Add('AND P.STATUS = 4');
        3 : SQL.SQL.Add('AND (P.STATUS = 5 AND (CHARACTER_LENGTH(COALESCE(P.CODIGO_RASTREIO, '''')) = 0))');
        4 : SQL.SQL.Add('AND (P.STATUS = 5 AND (CHARACTER_LENGTH(COALESCE(P.CODIGO_RASTREIO, '''')) > 0))');
        5 : SQL.SQL.Add('AND P.STATUS = 6');
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
            csPedidosDATA_FATURADO.Value:= SQL.Fields[7].Value;
          if not SQL.Fields[8].IsNull then
            csPedidosDATARETORNO.Value  := SQL.Fields[8].Value;
          csPedidos.Post;

          SQL.Next;
        end;
      end;
      TotalizaRegistros(csPedidos, edTotalRegistros);
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
    if not csPedidos.Fields[I].IsNull then
      Accept  := Pos(AnsiUpperCase(edPesquisa.Text), AnsiUpperCase(csPedidos.Fields[I].AsString)) > 0;
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
          SQL.SQL.Add(' PED.VOLUMES_DOCUMENTO,');
          SQL.SQL.Add('	P.CODIGOPRODUTO AS SKU,');
          SQL.SQL.Add('	PEDITENS.QUANTIDADE,');
          SQL.SQL.Add(' T.NOME');
          SQL.SQL.Add('FROM PEDIDO PED');
          SQL.SQL.Add('INNER JOIN TRANSPORTADORA T ON PED.ID_TRANSPORTADORA = T.ID');
          SQL.SQL.Add('INNER JOIN PEDIDOITENS PEDITENS ON (PEDITENS.ID_PEDIDO = PED.ID)');
          SQL.SQL.Add('INNER JOIN PRODUTO P ON (P.ID = PEDITENS.ID_PRODUTO)');
          SQL.SQL.Add('WHERE 1 = 1');
          SQL.SQL.Add('AND PED.ID IN (' + Pedidos + ')');
          SQL.SQL.Add('ORDER BY 1,3');
          SQL.Connection  := FWC.FDConnection;
          SQL.Prepare;
          SQL.Open;
          SQL.FetchAll;

          if not SQL.IsEmpty then begin
            SQL.First;
            while not SQL.Eof do begin
              for I := 1 to SQL.FieldByName('QUANTIDADE').AsInteger do begin
                csImpressaoPedidos.Append;
                csImpressaoPedidosPEDIDO.Value              := SQL.FieldByName('NUMEROPEDIDO').AsString;
                csImpressaoPedidosSKU.Value                 := SQL.FieldByName('SKU').AsString;
                csImpressaoPedidosNOMETRANSPORTADORA.Value  := SQL.FieldByName('NOME').AsString;
                csImpressaoPedidosVOLUMES_DOCUMENTO.Value   := SQL.FieldByName('VOLUMES_DOCUMENTO').AsInteger;
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

end.
