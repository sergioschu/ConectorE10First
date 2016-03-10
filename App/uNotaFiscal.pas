unit uNotaFiscal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  System.Win.ComObj, System.TypInfo, Vcl.Samples.Gauges, Vcl.ImgList;

type
  TfrmNotaFiscal = class(TForm)
    pnVisualizacao: TPanel;
    dgNotaFiscal: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btAtualizar: TSpeedButton;
    pbAtualizaProduto: TGauge;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    csNotaFiscal: TClientDataSet;
    dsNotaFiscal: TDataSource;
    csNotaFiscalDOCUMENTO: TIntegerField;
    csNotaFiscalDATAEMISSAO: TDateField;
    csNotaFiscalSERIE: TIntegerField;
    csNotaFiscalCNPJ: TStringField;
    csNotaFiscalSTATUS: TIntegerField;
    cbStatus: TComboBox;
    btDetalhes: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
    procedure btFecharClick(Sender: TObject);
    procedure dgNotaFiscalDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure csNotaFiscalFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btPesquisarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbStatusChange(Sender: TObject);
  private
    procedure CarregaDados;
    procedure AtualizarNotasFiscais;
    procedure Filtrar;
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
  uConstantes;
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
  J       : Integer;
  NOTAS   : array of TNOTA;
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

          SetLength(NOTAS, 0);
          for I := 2 to vrow do begin
            Achou   := False;
            if not (IntToStr(arrData[I, 1]) = '') then begin
              for J := Low(NOTAS) to High(NOTAS) do begin

                if (NOTAS[J].DOCUMENTO = arrData[I, 1]) and (NOTAS[High(NOTAS)].SERIE = StrToIntDef(arrData[I, 2], 0)) and (NOTAS[High(NOTAS)].CNPJ = arrData[I, 4]) then begin
                  Achou                                                            := True;
                  SetLength(NOTAS[J].ITENS, Length(NOTAS[J].ITENS) + 1);
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].SEQUENCIA                   := Length(NOTAS[J].ITENS);
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].SKU                         := arrData[I, 5];
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].QUANTIDADE                  := arrData[I, 6];
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].UNITARIO                    := arrData[I, 7];
                  NOTAS[J].ITENS[High(NOTAS[J].ITENS)].TOTAL                       := arrData[I, 8];
                  NOTAS[J].VALOR                                                   := NOTAS[J].VALOR + arrData[I, 8];
                end;
              end;
              if not Achou then begin
                SetLength(NOTAS, Length(NOTAS) + 1);
                NOTAS[High(NOTAS)].DOCUMENTO                                         := arrData[I, 1];
                NOTAS[High(NOTAS)].SERIE                                             := StrToIntDef(arrData[I, 2], 0);
                NOTAS[High(NOTAS)].DATA                                              := StrToDateTime(arrData[I, 3]);
                NOTAS[High(NOTAS)].CNPJ                                              := arrData[I, 4];

                SetLength(NOTAS[High(NOTAS)].ITENS, Length(NOTAS[High(NOTAS)].ITENS) + 1);
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].SEQUENCIA   := Length(NOTAS[High(NOTAS)].ITENS);
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].SKU         := arrData[I, 5];
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].QUANTIDADE  := arrData[I, 6];
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].UNITARIO    := arrData[I, 7];
                NOTAS[High(NOTAS)].ITENS[High(NOTAS[High(NOTAS)].ITENS)].TOTAL       := arrData[I, 8];
                NOTAS[High(NOTAS)].VALOR                                             := arrData[I, 8];
              end;
            end;

            pbAtualizaProduto.Progress                                               := I;
          end;
          pbAtualizaProduto.MaxValue                                                 := Length(NOTAS);
          for I := Low(NOTAS) to High(NOTAS) do begin
            NF.SelectList('documento = ' + IntToStr(NOTAS[I].DOCUMENTO) + ' and serie = ' + IntToStr(NOTAS[I].SERIE) + ' and cnpjcpf = ' + QuotedStr(NOTAS[I].CNPJ));
            if NF.Count > 0 then begin
              NF.ID.Value    := TNOTAFISCAL(NF.Itens[0]).ID.Value;
              NF.Delete;
            end;

            NF.DOCUMENTO.Value             := NOTAS[I].DOCUMENTO;
            NF.SERIE.Value                 := NOTAS[I].SERIE;
            NF.CNPJCPF.Value               := NOTAS[I].CNPJ;
            NF.DATAEMISSAO.Value           := NOTAS[I].DATA;
            NF.CFOP.Value                  := 5905;
            NF.ESPECIE.Value               := 'NF';
            NF.STATUS.Value                := 0;
            NF.VALORTOTAL.Value            := NOTAS[I].VALOR;
            NF.Insert;
            for J := Low(NOTAS[I].ITENS) to High(NOTAS[I].ITENS) do begin
              NFI.ID_NOTAFISCAL.Value      := NF.ID.Value;
              NFI.SEQUENCIA.Value          := I + 1;
              NFI.QUANTIDADE.Value         := NOTAS[I].ITENS[J].QUANTIDADE;
              NFI.QUANTIDADEREC.Value      := 0;
              NFI.QUANTIDADEAVA.Value      := 0;
              NFI.VALORUNITARIO.Value      := NOTAS[I].ITENS[J].UNITARIO;
              NFI.VALORTOTAL.Value         := NOTAS[I].ITENS[J].TOTAL;

              P.SelectList('codigoproduto = ' + QuotedStr(NOTAS[I].ITENS[J].SKU));
              if P.Count > 0 then begin
                NFI.ID_PRODUTO.Value       := TPRODUTO(P.Itens[0]).ID.Value;
                NFI.Insert;
              end;
            end;
            pbAtualizaProduto.Progress     := I;
          end;
          FWC.Commit;
          DisplayMsgFinaliza;
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

procedure TfrmNotaFiscal.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmNotaFiscal.btPesquisarClick(Sender: TObject);
begin
  if btPesquisar.Tag = 0 then begin
    btPesquisar.Tag   := 1;
    try
      Filtrar;
    finally
      btPesquisar.Tag := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.CarregaDados;
var
  CON : TFWConnection;
  NF  : TNOTAFISCAL;
  I   : Integer;
begin
  CON    := TFWConnection.Create;
  NF     := TNOTAFISCAL.Create(CON);
  try
    csNotaFiscal.EmptyDataSet;

    NF.SelectList();

    for I := 0 to Pred(NF.Count) do begin
      csNotaFiscal.Append;
      csNotaFiscalDOCUMENTO.Value     := TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.Value;
      csNotaFiscalDATAEMISSAO.Value   := TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value;
      csNotaFiscalSERIE.Value         := TNOTAFISCAL(NF.Itens[I]).SERIE.Value;
      csNotaFiscalCNPJ.Value          := TNOTAFISCAL(NF.Itens[I]).CNPJCPF.Value;
      csNotaFiscalSTATUS.Value        := TNOTAFISCAL(NF.Itens[I]).STATUS.Value;
      csNotaFiscal.Post;
    end;

  finally
    FreeAndNil(NF);
    FreeAndNil(CON);
  end;
end;

procedure TfrmNotaFiscal.cbStatusChange(Sender: TObject);
begin
  if cbStatus.Tag = 0 then begin
    cbStatus.Tag    := 1;
    try
      Filtrar;
    finally
      cbStatus.Tag  := 0;
    end;
  end;
end;

procedure TfrmNotaFiscal.csNotaFiscalFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  Accept   := True;
  case cbStatus.ItemIndex of
    1 : Accept := csNotaFiscalSTATUS.AsInteger = 0;
    2 : Accept := csNotaFiscalSTATUS.AsInteger = 1;
    3 : Accept := csNotaFiscalSTATUS.AsInteger = 2;
    else
      Accept := True;
  end;
  if (Accept) and (edPesquisa.Text <> '') then begin
    Accept := False;
    for I := 0 to Pred(csNotaFiscal.FieldCount) do begin
      Accept     := Pos(edPesquisa.Text, csNotaFiscal.Fields[I].AsString) > 0;
      if Accept then Exit;
    end;
  end;
end;

procedure TfrmNotaFiscal.dgNotaFiscalDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if csNotaFiscal.IsEmpty then Exit;

  if (gdSelected in State) or (gdFocused in State) then begin
    dgNotaFiscal.Canvas.Font.Color   := clWhite;
    dgNotaFiscal.Canvas.Brush.Color  := clBlue;
    dgNotaFiscal.Canvas.Font.Style   := [];
  end;

  dgNotaFiscal.DefaultDrawDataCell( Rect, dgNotaFiscal.Columns[DataCol].Field, State);

  if Column.FieldName = csNotaFiscalSTATUS.FieldName then begin
    dgNotaFiscal.Canvas.FillRect(Rect);
    ImageList1.Draw(dgNotaFiscal.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, csNotaFiscalSTATUS.Value);
  end;
end;

procedure TfrmNotaFiscal.edPesquisaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
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

  end;
end;

procedure TfrmNotaFiscal.Filtrar;
begin
  csNotaFiscal.Filtered := False;
  csNotaFiscal.Filtered := (edPesquisa.Text <> '') or (cbStatus.ItemIndex > 0);
end;

procedure TfrmNotaFiscal.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmNotaFiscal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmNotaFiscal.FormShow(Sender: TObject);
begin
  csNotaFiscal.CreateDataSet;
  csNotaFiscal.Open;
  CarregaDados;
  AutoSizeDBGrid(dgNotaFiscal);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

end.
