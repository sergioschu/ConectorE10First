unit uNotaFiscal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  System.Win.ComObj, System.TypInfo, Vcl.Samples.Gauges, Vcl.ImgList,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.ComCtrls, System.DateUtils;

type
  TfrmNotaFiscal = class(TForm)
    pnVisualizacao: TPanel;
    dgNotaFiscal: TDBGrid;
    pnFiltro: TPanel;
    btFiltrar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btAtualizar: TSpeedButton;
    pbAtualizaProduto: TGauge;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    OpenDialog1: TOpenDialog;
    csNotaFiscal: TClientDataSet;
    dsNotaFiscal: TDataSource;
    csNotaFiscalDOCUMENTO: TIntegerField;
    csNotaFiscalDATAEMISSAO: TDateField;
    csNotaFiscalSERIE: TIntegerField;
    csNotaFiscalCNPJ: TStringField;
    btDetalhes: TSpeedButton;
    csNotaFiscalID: TIntegerField;
    csNotaFiscalSTATUS: TStringField;
    csNotaFiscalSTATUSCOD: TIntegerField;
    csNotaFiscalSELECIONAR: TBooleanField;
    btReenviar: TSpeedButton;
    btConferida: TSpeedButton;
    pnConsulta: TPanel;
    gbPeriodo: TGroupBox;
    Label1: TLabel;
    edDataF: TDateTimePicker;
    edDataI: TDateTimePicker;
    btConsultar: TSpeedButton;
    rgStatus: TRadioGroup;
    btExportar: TSpeedButton;
    edTotalRegistros: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure dgNotaFiscalDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure csNotaFiscalFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btFiltrarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btDetalhesClick(Sender: TObject);
    procedure btReenviarClick(Sender: TObject);
    procedure dgNotaFiscalCellClick(Column: TColumn);
    procedure btConferidaClick(Sender: TObject);
    procedure btConsultarClick(Sender: TObject);
    procedure dgNotaFiscalTitleClick(Column: TColumn);
    procedure btExportarClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure AtualizarNotasFiscais;
    procedure Filtrar;
    procedure ImprimirDetalhes;
    procedure ReenviaConfirma(Status : Integer);
    procedure MarcarDesmarcarTodos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNotaFiscal: TfrmNotaFiscal;

implementation
uses
  uFuncoes,
  uMensagem,
  uDomains,
  uFWConnection,
  uBeanNotaFiscal,
  uBeanNotaFiscalItens,
  uBeanProduto,
  uConstantes,
  uDMUtil;
{$R *.dfm}

{ TfrmNotaFiscal }

procedure TfrmNotaFiscal.AtualizarNotasFiscais;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  NF      : TNOTAFISCAL;
  NFI     : TNOTAFISCALITENS;
  P       : TPRODUTO;
  Arquivo : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  Achou   : Boolean;
  vrow,
  vcol,
  I,
  J,
  Count   : Integer;
  NOTAS   : array of TNOTA;
  Lista   : TStringList;
  List    : TPropList;
  Erro    : Boolean;
begin
  if OpenDialog1.Execute then begin
    if Pos(ExtractFileExt(OpenDialog1.FileName), '|.xls|.xlsx|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
        Exit;
      end;

      // Cria Excel- OLE Object
      Excel                      := CreateOleObject('Excel.Application');
      FWC                        := TFWConnection.Create;
      NF                         := TNOTAFISCAL.Create(FWC);
      NFI                        := TNOTAFISCALITENS.Create(FWC);
      P                          := TPRODUTO.Create(FWC);
      Lista                      := TStringList.Create;
      pbAtualizaProduto.Progress := 0;

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
          pbAtualizaProduto.MaxValue           := vrow;
          arrData                              := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

          NF.DOCUMENTO.excelTitulo             := 'Nota - Nº';
          NF.SERIE.excelTitulo                 := 'Nota - Série';
          NF.CNPJCPF.excelTitulo               := 'Destinatário - CPF/CNPJ';
          NF.DATAEMISSAO.excelTitulo           := 'Nota - Emissão';

          NFI.ID_PRODUTO.excelTitulo           := 'SKU';
          NFI.QUANTIDADE.excelTitulo           := 'Qnt';
          NFI.VALORUNITARIO.excelTitulo        := 'Preco B';
          NFI.VALORTOTAL.excelTitulo           := 'Item - Total bruto';

          NF.buscaIndicesExcel(Arquivo, Excel);
          NFI.buscaIndicesExcel(Arquivo, Excel);

          Erro                                            := False;


          Count                                           := GetPropList(NF.ClassInfo, tkProperties, @List, False);

          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(NF, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(NF, List[I]^.Name)).excelIndice <= 0) then begin
              Erro  := True;
            end;
          end;

          Count                                           := GetPropList(NFI.ClassInfo, tkProperties, @List, False);

          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(NFI, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(NFI, List[I]^.Name)).excelIndice <= 0) then begin
              Erro  := True;
            end;
          end;

          if Erro then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'Nota - Nº, ' + sLineBreak +
                                                                                    'Nota - Série, ' + sLineBreak +
                                                                                    'Nota - Emissão, ' + sLineBreak +
                                                                                    'Destinatário - CPF/CNPJ, ' + sLineBreak +
                                                                                    'SKU, ' + sLineBreak +
                                                                                    'Qnt, ' + sLineBreak +
                                                                                    'Preco B, ' + sLineBreak +
                                                                                    'Item - Total bruto, ' + sLineBreak +
                                                                                    'Item - CFOP');
              Exit;
          end;

          SetLength(NOTAS, 0);
          for I := 2 to vrow do begin
            Achou   := False;
            if not (Trim(arrData[I, 1]) = EmptyStr) then begin
              for J := Low(NOTAS) to High(NOTAS) do begin

                if (NOTAS[J].DOCUMENTO = arrData[I, NF.DOCUMENTO.excelIndice]) and (NOTAS[High(NOTAS)].SERIE = StrToIntDef(arrData[I, NF.SERIE.excelIndice], 0)) and (NOTAS[High(NOTAS)].CNPJ = arrData[I, NF.CNPJCPF.excelIndice]) then begin
                  Achou                                                            := True;
                  SetLength(NOTAS[J].ITENS, Length(NOTAS[J].ITENS) + 1);
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].SEQUENCIA                   := Length(NOTAS[J].ITENS);
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].SKU                         := arrData[I, NFI.ID_PRODUTO.excelIndice];
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].QUANTIDADE                  := arrData[I, NFI.QUANTIDADE.excelIndice];
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].UNITARIO                    := arrData[I, NFI.VALORUNITARIO.excelIndice];
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].TOTAL                       := arrData[I, NFI.VALORTOTAL.excelIndice];
                  NOTAS[J].VALOR                                                   := NOTAS[J].VALOR + arrData[I, 8];
                end;
              end;
              if not Achou then begin
                SetLength(NOTAS, Length(NOTAS) + 1);
                NOTAS[High(NOTAS)].DOCUMENTO                                         := arrData[I, NF.DOCUMENTO.excelIndice];
                NOTAS[High(NOTAS)].SERIE                                             := StrToIntDef(arrData[I, NF.SERIE.excelIndice], 0);
                NOTAS[High(NOTAS)].DATA                                              := StrToDateTime(arrData[I, NF.DATAEMISSAO.excelIndice]);
                NOTAS[High(NOTAS)].CNPJ                                              := arrData[I, NF.CNPJCPF.excelIndice];

                SetLength(NOTAS[High(NOTAS)].ITENS, Length(NOTAS[High(NOTAS)].ITENS) + 1);
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].SEQUENCIA   := Length(NOTAS[High(NOTAS)].ITENS);
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].SKU         := arrData[I, NFI.ID_PRODUTO.excelIndice];
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].QUANTIDADE  := arrData[I, NFI.QUANTIDADE.excelIndice];
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].UNITARIO    := arrData[I, NFI.VALORUNITARIO.excelIndice];
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].TOTAL       := arrData[I, NFI.VALORTOTAL.excelIndice];
                NOTAS[High(NOTAS)].VALOR                                             := arrData[I, NFI.VALORTOTAL.excelIndice];
              end;
            end;

            pbAtualizaProduto.Progress                                               := I;
            Application.ProcessMessages;
          end;
          pbAtualizaProduto.MaxValue                                                 := Length(NOTAS);
          for I := Low(NOTAS) to High(NOTAS) do begin
            NF.SelectList('documento = ' + IntToStr(NOTAS[I].DOCUMENTO) + ' and serie = ' + IntToStr(NOTAS[I].SERIE) + ' and cnpjcpf = ' + QuotedStr(NOTAS[I].CNPJ));
            if NF.Count = 0 then begin
              NF.DOCUMENTO.Value             := NOTAS[I].DOCUMENTO;
              NF.SERIE.Value                 := NOTAS[I].SERIE;
              NF.CNPJCPF.Value               := NOTAS[I].CNPJ;
              NF.DATAEMISSAO.Value           := NOTAS[I].DATA;
              NF.CFOP.Value                  := 5905;
              NF.ESPECIE.Value               := 'NF';
              NF.STATUS.Value                := 0;
              NF.VALORTOTAL.Value            := NOTAS[I].VALOR;
              NF.ID_ARQUIVO.Value            := 0;
              NF.ID_USUARIO.Value            := 0;
              NF.DATA_IMPORTACAO.Value       := Now;
              NF.Insert;
              for J := Low(NOTAS[I].ITENS) to High(NOTAS[I].ITENS) do begin
                NFI.ID_NOTAFISCAL.Value      := NF.ID.Value;
                NFI.SEQUENCIA.Value          := NOTAS[I].ITENS[J].SEQUENCIA;
                NFI.QUANTIDADE.Value         := NOTAS[I].ITENS[J].QUANTIDADE;
                NFI.QUANTIDADEREC.Value      := 0;
                NFI.QUANTIDADEAVA.Value      := 0;
                NFI.VALORUNITARIO.Value      := NOTAS[I].ITENS[J].UNITARIO;
                NFI.VALORTOTAL.Value         := NOTAS[I].ITENS[J].TOTAL;

                P.SelectList('upper(codigoproduto) = ' + QuotedStr(AnsiUpperCase(NOTAS[I].ITENS[J].SKU)));
                if P.Count > 0 then begin
                  NFI.ID_PRODUTO.Value       := TPRODUTO(P.Itens[0]).ID.Value;
                  NFI.Insert;
                end else begin
                  Lista.Add(NOTAS[I].ITENS[J].SKU);
                end;
              end;
            end;
            pbAtualizaProduto.Progress     := I;
            Application.ProcessMessages;
          end;
          if Lista.Count > 0 then begin
            FWC.Rollback;
            DisplayMsg(MSG_WAR, 'Existem produtos nas Notas Fiscais que não estão cadastrados no ConectorE10!', '', Lista.Text);
          end else begin
            FWC.Commit;
            DisplayMsgFinaliza;
          end;
          CarregaDados;
        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Produtos!', '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData := Unassigned;
        pbAtualizaProduto.Progress               := 0;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(NF);
        FreeAndNil(NFI);
        FreeAndNil(P);
        FreeAndNil(FWC);
        FreeAndNil(Lista);
      end;
    end;
  end;
end;

procedure TfrmNotaFiscal.btAtualizarClick(Sender: TObject);
begin
  if btAtualizar.Tag = 0 then begin
    btAtualizar.Tag := 1;
    try
      AtualizarNotasFiscais;
    finally
      btAtualizar.Tag := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.btConferidaClick(Sender: TObject);
begin
  if btConferida.Tag = 0 then begin
    btConferida.Tag   := 1;
    try
      ReenviaConfirma(3);
    finally
      btConferida.Tag := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.btConsultarClick(Sender: TObject);
begin
  if btConsultar.Tag = 0 then begin
    btConsultar.Tag   := 1;
    try
      CarregaDados;
    finally
      btConsultar.Tag := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.btDetalhesClick(Sender: TObject);
begin
  if btDetalhes.Tag = 0 then begin
    btDetalhes.Tag    := 1;
    try
      ImprimirDetalhes;
    finally
      btDetalhes.Tag   := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.btExportarClick(Sender: TObject);
Var
  Arq : string;
begin

  if btExportar.Tag = 0 then begin
    btExportar.Tag    := 1;
    try
      Arq := DirArquivosExcel;
      ExpXLS(csNotaFiscal, 'NotasFiscais_' + FormatDateTime('ddmmyyyy', Date) + '.xlsx');
    finally
      btExportar.Tag  := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNotaFiscal.btFiltrarClick(Sender: TObject);
begin
  if btFiltrar.Tag = 0 then begin
    btFiltrar.Tag   := 1;
    try
      Filtrar;
      TotalizaRegistros(csNotaFiscal, edTotalRegistros);
    finally
      btFiltrar.Tag := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.btReenviarClick(Sender: TObject);
begin
  if btReenviar.Tag = 0 then begin
    btReenviar.Tag   := 1;
    try
      ReenviaConfirma(0);
    finally
      btReenviar.Tag := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.CarregaDados;
var
  CON : TFWConnection;
  SQL : TFDQuery;
  I   : Integer;
begin
  CON    := TFWConnection.Create;
  SQL    := TFDQuery.Create(nil);
  csNotaFiscal.DisableControls;
  SQL.DisableControls;
  try
    try
      SQL.Connection                   := CON.FDConnection;
      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('select id, documento, dataemissao, serie, cnpjcpf, status from notafiscal');
      SQL.SQL.Add('where cast(data_importacao as date) between :datai and :dataf');
      SQL.ParamByName('datai').DataType   := ftDate;
      SQL.ParamByName('dataf').DataType   := ftDate;

      if rgStatus.ItemIndex > 0 then begin
        SQL.SQL.Add('and status = :status');
        SQL.ParamByName('status').DataType  := ftInteger;
      end;

      SQL.Prepare;
      SQL.Params[0].Value    := edDataI.Date;
      SQL.Params[1].Value    := edDataF.Date;
      if rgStatus.ItemIndex > 0 then begin
        case rgStatus.ItemIndex of
          1 : SQL.Params[2].Value := 0;
          2 : SQL.Params[2].Value := 1;
          3 : SQL.Params[2].Value := 2;
          4 : SQL.Params[2].Value := 3;
        end;
      end;
      SQL.Open();

      csNotaFiscal.EmptyDataSet;

      SQL.First;
      while not SQL.Eof do begin
        csNotaFiscal.Append;
        csNotaFiscalID.Value            := SQL.Fields[0].Value;
        csNotaFiscalDOCUMENTO.Value     := SQL.Fields[1].Value;
        csNotaFiscalDATAEMISSAO.Value   := SQL.Fields[2].Value;
        csNotaFiscalSERIE.Value         := SQL.Fields[3].Value;
        csNotaFiscalCNPJ.Value          := SQL.Fields[4].Value;
        csNotaFiscalSTATUSCOD.Value     := SQL.Fields[5].Value;
        case csNotaFiscalSTATUSCOD.Value of
          0 : csNotaFiscalSTATUS.Value  := 'Não Enviada para o FTP';
          1 : csNotaFiscalSTATUS.Value  := 'Enviada para o FTP';
          2 : csNotaFiscalSTATUS.Value  := 'CONF Recebido';
          3 : csNotaFiscalSTATUS.Value  := 'Conferida';
        end;
        csNotaFiscal.Post;
        SQL.Next;
      end;
      TotalizaRegistros(csNotaFiscal, edTotalRegistros);
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Erro ao realizar consulta!' , '', E.Message);
        Exit;
      end;
    end;
  finally
    csNotaFiscal.EnableControls;
    SQL.EnableControls;
    FreeAndNil(SQL);
    FreeAndNil(CON);
  end;
end;

procedure TfrmNotaFiscal.csNotaFiscalFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  Accept := False;
  for I := 0 to Pred(csNotaFiscal.FieldCount) do begin
    if not csNotaFiscal.Fields[I].IsNull then
      Accept     := Pos(edPesquisa.Text, csNotaFiscal.Fields[I].AsString) > 0;
    if Accept then Exit;
  end;
end;

procedure TfrmNotaFiscal.dgNotaFiscalCellClick(Column: TColumn);
begin
  if not csNotaFiscal.IsEmpty then begin
    csNotaFiscal.Edit;
    csNotaFiscalSELECIONAR.Value := not csNotaFiscalSELECIONAR.Value;
    csNotaFiscal.Post;
  end;
end;

procedure TfrmNotaFiscal.dgNotaFiscalDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
const
  IsChecked : array[Boolean] of Integer = (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
var
  DrawRect: TRect;
begin
  if csNotaFiscal.IsEmpty then Exit;

  if (gdSelected in State) or (gdFocused in State) then begin
    dgNotaFiscal.Canvas.Font.Color   := clWhite;
    dgNotaFiscal.Canvas.Brush.Color  := clBlue;
    dgNotaFiscal.Canvas.Font.Style   := [];
  end;

  dgNotaFiscal.DefaultDrawDataCell( Rect, dgNotaFiscal.Columns[DataCol].Field, State);

  if Column.FieldName = csNotaFiscalSELECIONAR.FieldName then begin
    DrawRect   := Rect;
    InflateRect(DrawRect,-1,-1);
    dgNotaFiscal.Canvas.FillRect(Rect);
    DrawFrameControl(dgNotaFiscal.Canvas.Handle, DrawRect, DFC_BUTTON, ISChecked[Column.Field.AsBoolean]);
  end;
end;

procedure TfrmNotaFiscal.dgNotaFiscalTitleClick(Column: TColumn);
begin
  if UpperCase(Column.FieldName) = 'SELECIONAR' then
    MarcarDesmarcarTodos
  else
    OrdenarGrid(Column);
end;

procedure TfrmNotaFiscal.Filtrar;
begin
  csNotaFiscal.Filtered := False;
  csNotaFiscal.Filtered := (edPesquisa.Text <> '');
end;

procedure TfrmNotaFiscal.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmNotaFiscal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if edPesquisa.Focused then begin
    case Key of
      VK_RETURN : Filtrar;
      VK_UP : begin
        if not ((csNotaFiscal.IsEmpty) or (csNotaFiscal.Bof)) then
          csNotaFiscal.Prior;
      end;
      VK_DOWN : begin
        if not ((csNotaFiscal.IsEmpty) or (csNotaFiscal.Eof)) then
          csNotaFiscal.Next;
      end;
      VK_ESCAPE : Close;
    end;
  end else begin
    case Key of
      VK_RETURN : CarregaDados;
      VK_ESCAPE : Close;
    end;
  end;
end;

procedure TfrmNotaFiscal.FormShow(Sender: TObject);
begin
  csNotaFiscal.CreateDataSet;
  csNotaFiscal.Open;
  edDataI.Date   := Date;
  edDataF.Date   := Date;
  CarregaDados;
  AutoSizeDBGrid(dgNotaFiscal);
  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TfrmNotaFiscal.ImprimirDetalhes;
var
  SQL : TFDQuery;
  FWC : TFWConnection;
begin
  FWC    := TFWConnection.Create;
  SQL    := TFDQuery.Create(nil);
  DisplayMsg(MSG_WAIT, 'Buscando dados no Banco de Dados!');
  try
    try
      SQL.Connection := FWC.FDConnection;

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('select nf.documento, nf.serie, nf.cnpjcpf, nf.dataemissao, p.codigoproduto, p.descricaoreduzida, ni.*');
      SQL.SQL.Add('from notafiscal nf');
      SQL.SQL.Add('inner join notafiscalitens ni on nf.id = ni.id_notafiscal');
      SQL.SQL.Add('inner join produto p on ni.id_produto = p.id');
      SQL.SQL.Add('where nf.id = :id');
      SQL.ParamByName('id').Value    := csNotaFiscalID.Value;
      SQL.Open();

      DMUtil.frxDBDataset1.DataSet   := SQL;
      DMUtil.ImprimirRelatorio('frDetalhesNotafiscal.fr3');
      DisplayMsgFinaliza;
    except
      on E : Exception do begin
        DisplayMsg(MSG_WAR, 'Erro ao buscar dados!', '', E.Message);
        Exit;
      end;
    end;

  finally
    FreeAndNil(SQL);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmNotaFiscal.MarcarDesmarcarTodos;
Var
  Aux : Boolean;
begin
  if not csNotaFiscal.IsEmpty then begin

    Aux := not csNotaFiscalSELECIONAR.Value;

    csNotaFiscal.DisableControls;

    try
      csNotaFiscal.First;
      while not csNotaFiscal.Eof do begin
        csNotaFiscal.Edit;
        csNotaFiscalSELECIONAR.Value  := Aux;
        csNotaFiscal.Post;
        csNotaFiscal.Next;
      end;
    finally
      csNotaFiscal.EnableControls;
      DisplayMsgFinaliza
    end;
  end;
end;

procedure TfrmNotaFiscal.ReenviaConfirma(Status : Integer);
var
  FWC   : TFWConnection;
  NF    : TNOTAFISCAL;
begin
  FWC   := TFWConnection.Create;
  NF    := TNOTAFISCAL.Create(FWC);
  csNotaFiscal.DisableControls;
  DisplayMsg(MSG_WAIT, 'Atualizando NFs!');
  try
     FWC.StartTransaction;
    try
      csNotaFiscal.First;
      while not csNotaFiscal.Eof do begin
        if (csNotaFiscalSELECIONAR.Value) and (csNotaFiscalSTATUSCOD.Value <> 3) then begin
          if not ((Status = 3) and (csNotaFiscalSTATUSCOD.Value <> 2)) then begin
            NF.ID.Value             := csNotaFiscalID.Value;
            NF.STATUS.Value         := Status;
            NF.ID_USUARIO.Value     := USUARIO.CODIGO;
            NF.Update;
          end;
        end;
        csNotaFiscal.Next;
      end;
      FWC.Commit;
      DisplayMsgFinaliza;
      CarregaDados;
    except
      on E : Exception do begin
        FWC.Rollback;
        DisplayMsg(MSG_WAR, 'Erro ao atualizar NFs!', '', E.Message);
        Exit;
      end;
    end;
  finally
    csNotaFiscal.EnableControls;
    FreeAndNil(NF);
    FreeAndNil(FWC);
  end;
end;

end.
