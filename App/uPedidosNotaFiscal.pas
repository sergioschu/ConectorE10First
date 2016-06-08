unit uPedidosNotaFiscal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, Vcl.ComCtrls, System.Win.ComObj, Vcl.Mask,
  JvExMask, JvToolEdit;

type
  TFrmPedidosNotaFiscal = class(TForm)
    pnVisualizacao: TPanel;
    gdPedidos: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btAtualizar: TSpeedButton;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    dsPedidos: TDataSource;
    csPedidos: TClientDataSet;
    csPedidosID: TIntegerField;
    csPedidosPEDIDO: TStringField;
    csPedidosSTATUSTEXTO: TStringField;
    csPedidosSELECIONAR: TBooleanField;
    csPedidosSTATUS: TIntegerField;
    csPedidosDATA_IMPORTACAO: TDateField;
    pnConsulta: TPanel;
    btConsultar: TSpeedButton;
    gbPeriodo: TGroupBox;
    Label1: TLabel;
    rgStatus: TRadioGroup;
    btExportar: TSpeedButton;
    edTotalRegistros: TEdit;
    OpenDialog1: TOpenDialog;
    edDataI: TJvDateEdit;
    edDataF: TJvDateEdit;
    btReenviar: TSpeedButton;
    pbAtualizaPedidos: TGauge;
    csPedidosID_PEDIDO: TIntegerField;
    csPedidosDATA_ENVIO: TDateTimeField;
    csPedidosNUMERODOCUMENTO: TIntegerField;
    csPedidosSERIEDOCUMENTO: TStringField;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure csPedidosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure gdPedidosCellClick(Column: TColumn);
    procedure gdPedidosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btAtualizarClick(Sender: TObject);
    procedure cbFiltroStatusChange(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure btExportarClick(Sender: TObject);
    procedure gdPedidosTitleClick(Column: TColumn);
    procedure btPesquisarClick(Sender: TObject);
    procedure btReenviarClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure Filtrar;
    procedure MarcarDesmarcarTodos;
    procedure VincularNotasFiscais;
    procedure Reenviar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPedidosNotaFiscal: TFrmPedidosNotaFiscal;

implementation

uses
  uFuncoes,
  uConstantes,
  uMensagem,
  uFWConnection,
  uDMUtil,
  uBeanPedido,
  uBeanPedido_NotaFiscal;

{$R *.dfm}

procedure TFrmPedidosNotaFiscal.btConsultarClick(Sender: TObject);
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

procedure TFrmPedidosNotaFiscal.btExportarClick(Sender: TObject);
Var
  Arq : string;
begin

  if btExportar.Tag = 0 then begin
    btExportar.Tag    := 1;
    try
      Arq := DirArquivosExcel;
      ExpXLS(csPedidos, 'Pedidos_NotaFiscal' + FormatDateTime('ddmmyyyy', Date) + '.xlsx');
    finally
      btExportar.Tag  := 0;
    end;
  end;
end;

procedure TFrmPedidosNotaFiscal.btAtualizarClick(Sender: TObject);
begin
  if btAtualizar.Tag = 0 then begin
    btAtualizar.Tag    := 1;
    try
      VincularNotasFiscais;
      CarregaDados;
    finally
      btAtualizar.Tag  := 0;
    end;
  end;
end;

procedure TFrmPedidosNotaFiscal.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPedidosNotaFiscal.btPesquisarClick(Sender: TObject);
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

procedure TFrmPedidosNotaFiscal.btReenviarClick(Sender: TObject);
begin
  if btReenviar.Tag = 0 then begin
    btReenviar.Tag   := 1;
    try
      if not csPedidos.IsEmpty then begin
        Reenviar;
        CarregaDados;
      end;
    finally
      btReenviar.Tag := 0;
    end;
  end;
end;

procedure TFrmPedidosNotaFiscal.CarregaDados;
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
      SQL.SQL.Add('	PNF.ID,');
      SQL.SQL.Add(' P.ID AS ID_PEDIDO,');
      SQL.SQL.Add('	P.PEDIDO,');
      SQL.SQL.Add('	PNF.NUMERO_DOCUMENTO,');
      SQL.SQL.Add('	PNF.SERIE_DOCUMENTO,');
      SQL.SQL.Add('	CAST(P.DATA_IMPORTACAO AS DATE) AS DATA_IMPORTACAO,');
      SQL.SQL.Add('	PNF.DATA_ENVIO,');
      SQL.SQL.Add('	P.STATUS,');
      SQL.SQL.Add('	CASE PNF.STATUS WHEN 0 THEN ''Não Enviado''');
      SQL.SQL.Add('		ELSE ''Enviado'' END AS STATUSTEXTO');
      SQL.SQL.Add('FROM PEDIDO_NOTAFISCAL PNF INNER JOIN PEDIDO P ON (PNF.ID_PEDIDO = P.ID)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_IMPORTACAO AS DATE) BETWEEN :DATAI AND :DATAF');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataI.Date;
      SQL.ParamByName('DATAF').Value    := edDataF.Date;

      case rgStatus.ItemIndex of
        1 : SQL.SQL.Add('AND PNF.STATUS = 0');
        2 : SQL.SQL.Add('AND PNF.STATUS = 1');
      end;

      SQL.Connection                      := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open();

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          csPedidos.Append;
          csPedidosID.Value             := SQL.Fields[0].Value;
          csPedidosID_PEDIDO.Value      := SQL.Fields[1].Value;
          csPedidosPEDIDO.Value         := SQL.Fields[2].Value;

          if SQL.Fields[3].AsInteger > 0 then begin
            csPedidosNUMERODOCUMENTO.Value:= SQL.Fields[3].Value;
            csPedidosSERIEDOCUMENTO.Value := SQL.Fields[4].Value;
          end;

          csPedidosDATA_IMPORTACAO.Value:= SQL.Fields[5].Value;

          if not SQL.Fields[6].IsNull then
            csPedidosDATA_ENVIO.Value   := SQL.Fields[6].Value;

          csPedidosSTATUS.Value         := SQL.Fields[7].Value;
          csPedidosSTATUSTEXTO.Value    := SQL.Fields[8].Value;
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

procedure TFrmPedidosNotaFiscal.cbFiltroStatusChange(Sender: TObject);
begin
  CarregaDados;
end;

procedure TFrmPedidosNotaFiscal.csPedidosFilterRecord(DataSet: TDataSet;
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

procedure TFrmPedidosNotaFiscal.Filtrar;
begin
  csPedidos.Filtered := False;
  csPedidos.Filtered := edPesquisa.Text <> '';
end;

procedure TFrmPedidosNotaFiscal.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmPedidosNotaFiscal.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TFrmPedidosNotaFiscal.FormShow(Sender: TObject);
begin
  csPedidos.CreateDataSet;

  AutoSizeDBGrid(gdPedidos);

  edDataI.Date  := Date;
  edDataF.Date  := Date;

  CarregaDados;

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TFrmPedidosNotaFiscal.gdPedidosCellClick(Column: TColumn);
begin
  if not csPedidos.IsEmpty then begin
    csPedidos.Edit;
    csPedidosSELECIONAR.Value := not csPedidosSELECIONAR.Value;
    csPedidos.Post;
  end;
end;

procedure TFrmPedidosNotaFiscal.gdPedidosDrawColumnCell(Sender: TObject;
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

procedure TFrmPedidosNotaFiscal.gdPedidosTitleClick(Column: TColumn);
begin
  if UpperCase(Column.FieldName) = 'SELECIONAR' then
    MarcarDesmarcarTodos
  else
    OrdenarGrid(Column);
end;

procedure TFrmPedidosNotaFiscal.MarcarDesmarcarTodos;
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

procedure TFrmPedidosNotaFiscal.Reenviar;
var
  FWC : TFWConnection;
  PNF : TPEDIDO_NOTAFISCAL;
begin

  csPedidos.DisableControls;

  FWC  := TFWConnection.Create;
  PNF  := TPEDIDO_NOTAFISCAL.Create(FWC);

  DisplayMsg(MSG_WAIT, 'Atualizando pedidos!');

  try
    try
      csPedidos.First;
      while not csPedidos.Eof do begin
        if csPedidosSELECIONAR.Value then begin
          PNF.SelectList('id = ' + csPedidosID.AsString + ' and status = 1');
          if PNF.Count = 1 then begin
            PNF.ID.Value           := TPEDIDO_NOTAFISCAL(PNF.Itens[0]).ID.Value;
            PNF.STATUS.Value       := 0;
            PNF.Update;
          end;
        end;
        csPedidos.Next;
      end;
      FWC.Commit;

      DisplayMsgFinaliza;

    except
      on E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_WAR, 'Erro ao atualizar pedidos!');
        Exit;
      end;
    end;
  finally
    csPedidos.EnableControls;
    FreeAndNil(PNF);
    FreeAndNil(FWC);
  end;
end;

procedure TFrmPedidosNotaFiscal.VincularNotasFiscais;
const
  xlCellTypeLastCell = $0000000B;
type
  TPedidos_NF = record
    ID              : Integer;
    ID_Pedido       : Integer;
    NumeroPedido    : String;
    NumeroDocumento : Integer;
    NumeroSerie     : string;
  end;
Var
  FWC     : TFWConnection;
  P       : TPEDIDO;
  PNF     : TPEDIDO_NOTAFISCAL;
  Arquivo,
  Excel   : OleVariant;
  Aux     : String;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  I,
  J,
  Contador      : Integer;
  ArqValido     : Boolean;
  AchouColuna   : Boolean;
  Pedidos_NF    : array of TPedidos_NF;
  Colunas       : array of String;
begin
  if OpenDialog1.Execute then begin
    if Pos(AnsiUpperCase(ExtractFileExt(OpenDialog1.FileName)), '|.XLS|.XLSX|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
        Exit;
      end;

      // Cria Excel- OLE Object
      Excel := CreateOleObject('Excel.Application');

      FWC := TFWConnection.Create;
      P   := TPEDIDO.Create(FWC);
      PNF := TPEDIDO_NOTAFISCAL.Create(FWC);

      pbAtualizaPedidos.Progress := 0;
      pbAtualizaPedidos.Visible   := True;

      DisplayMsg(MSG_WAIT, 'Buscando dados do arquivo Excel!');
      try
        FWC.StartTransaction;
        try
          // Esconde Excel
          Excel.Visible  := False;
          // Abre o Workbook
          Excel.Workbooks.Open(Arquivo);

          Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
          vrow                                 := Excel.ActiveCell.Row;
          vcol                                 := Excel.ActiveCell.Column;
          pbAtualizaPedidos.MaxValue           := vrow;
          arrData                              := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

          SetLength(Colunas, 3);
          Colunas[0] := 'Numero do Pedido';
          Colunas[1] := 'Nota Fiscal';
          Colunas[2] := 'Serie da Nota';

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

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := vrow;

          DisplayMsg(MSG_WAIT, 'Capturando Notas Fiscais do arquivo!');

          SetLength(Pedidos_NF, 0);
          for I := 2 to vrow do begin
            SetLength(Pedidos_NF, Length(Pedidos_NF) + 1);
            Pedidos_NF[High(Pedidos_NF)].ID         := 0;
            Pedidos_NF[High(Pedidos_NF)].ID_Pedido  := 0;
            for J := 1 to vcol do begin
              if arrData[1, J] = Colunas[0] then
                Pedidos_NF[High(Pedidos_NF)].NumeroPedido     := arrData[I, J]
              else
                if arrData[1, J] = Colunas[1] then
                  Pedidos_NF[High(Pedidos_NF)].NumeroDocumento := arrData[I, J]
                else
                  if arrData[1, J] = Colunas[2] then
                    Pedidos_NF[High(Pedidos_NF)].NumeroSerie := Format('%.3d', [StrToIntDef(arrData[I, J],0)]);
            end;
            pbAtualizaPedidos.Progress := I;
          end;

          DisplayMsg(MSG_WAIT, 'Identificando Pedidos!');

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := High(Pedidos_NF);

          Aux := EmptyStr;
          for I := Low(Pedidos_NF) to High(Pedidos_NF) do begin
            if Length(Trim(Pedidos_NF[I].NumeroPedido)) > 0 then begin

              //Consulta o pedido no BD
              P.SelectList('STATUS = 5 AND PEDIDO = ' + QuotedStr(Pedidos_NF[I].NumeroPedido));
              if P.Count = 1 then begin
                Pedidos_NF[I].ID_Pedido := TPEDIDO(P.Itens[0]).ID.Value;

                //Consulta a nf do pedido no BD
                PNF.SelectList('ID_PEDIDO = ' + IntToStr(Pedidos_NF[I].ID_Pedido));
                if PNF.Count = 1 then
                  Pedidos_NF[I].ID := TPEDIDO_NOTAFISCAL(PNF.Itens[0]).ID.Value;
              end else begin
                if Aux = EmptyStr then
                  Aux := 'Pedido Nº ' + Pedidos_NF[I].NumeroPedido + ' -> NF Nº ' + IntToStr(Pedidos_NF[I].NumeroDocumento)
                else
                  Aux := Aux + sLineBreak + 'Pedido Nº ' + Pedidos_NF[I].NumeroPedido + ' -> NF Nº ' + IntToStr(Pedidos_NF[I].NumeroDocumento);
              end;
            end;

            Application.ProcessMessages;
            pbAtualizaPedidos.Progress := I;
          end;

          if Aux <> EmptyStr then
            DisplayMsg(MSG_WAR, 'Existem notas que não foi encontrado Pedido' + sLineBreak +
                                'Faturado ou Despachado, Verifique!' + sLineBreak + sLineBreak +
                                'A atualização será concluida, para os Demais!', '', Aux);

          DisplayMsg(MSG_WAIT, 'Gravando Nota dos Pedidos no Banco de Dados!');

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := High(Pedidos_NF);
          Contador                    := 0;

          //Começa a Gravação dos Dados no BD
          for I := Low(Pedidos_NF) to High(Pedidos_NF) do begin
            if Pedidos_NF[I].ID_Pedido > 0 then begin
              if Pedidos_NF[I].ID = 0 then begin
                PNF.ID.isNull             := True;
                PNF.ID_PEDIDO.Value       := Pedidos_NF[I].ID_Pedido;
                PNF.ID_ARQUIVO.Value      := 0;
                PNF.DATA_IMPORTACAO.Value := Now;
                PNF.NUMERO_DOCUMENTO.Value:= Pedidos_NF[I].NumeroDocumento;
                PNF.SERIE_DOCUMENTO.Value := Pedidos_NF[I].NumeroSerie;
                PNF.STATUS.Value          := 0;
                PNF.Insert;

                Contador  := Contador + 1;

              end;
            end;
            Application.ProcessMessages;
            pbAtualizaPedidos.Progress  := I;
          end;

          if Contador > 0 then begin
            FWC.Commit;

            DisplayMsg(MSG_OK, IntToStr(Contador) + ' Notas Fiscais Vínculadas com Sucesso!');
          end else
            DisplayMsg(MSG_WAR, 'Não Houve Atualização, Verifique!');

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Notas Fiscais!', '', E.Message);
            Exit;
          end;
        end;
      finally
        Application.ProcessMessages;
        arrData := Unassigned;
        pbAtualizaPedidos.Progress  := 0;
        pbAtualizaPedidos.Visible   := False;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(P);
        FreeAndNil(PNF);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

end.
