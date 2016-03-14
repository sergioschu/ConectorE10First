unit uNotaFiscal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  System.Win.ComObj, System.TypInfo, Vcl.Samples.Gauges, Vcl.ImgList,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

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
    csNotaFiscal: TClientDataSet;
    dsNotaFiscal: TDataSource;
    csNotaFiscalDOCUMENTO: TIntegerField;
    csNotaFiscalDATAEMISSAO: TDateField;
    csNotaFiscalSERIE: TIntegerField;
    csNotaFiscalCNPJ: TStringField;
    cbStatus: TComboBox;
    btDetalhes: TSpeedButton;
    csNotaFiscalID: TIntegerField;
    csNotaFiscalSTATUS: TStringField;
    csNotaFiscalSTATUSCOD: TIntegerField;
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
    procedure btDetalhesClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure AtualizarNotasFiscais;
    procedure Filtrar;
    procedure ImprimirDetalhes;
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
  J       : Integer;
  NOTAS   : array of TNOTA;
  Lista   : TStringList;
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
            Application.ProcessMessages;
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
            NF.ID_ARQUIVO.Value            := 0;
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
      csNotaFiscalID.Value            := TNOTAFISCAL(NF.Itens[I]).ID.Value;
      csNotaFiscalDOCUMENTO.Value     := TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.Value;
      csNotaFiscalDATAEMISSAO.Value   := TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value;
      csNotaFiscalSERIE.Value         := TNOTAFISCAL(NF.Itens[I]).SERIE.Value;
      csNotaFiscalCNPJ.Value          := TNOTAFISCAL(NF.Itens[I]).CNPJCPF.Value;
      csNotaFiscalSTATUSCOD.Value     := TNOTAFISCAL(NF.Itens[I]).STATUS.Value;
      case TNOTAFISCAL(NF.Itens[I]).STATUS.Value of
        0 : csNotaFiscalSTATUS.Value  := 'Não Enviada para o FTP';
        1 : csNotaFiscalSTATUS.Value  := 'Enviada para o FTP';
        2 : csNotaFiscalSTATUS.Value  := 'MDD Recebido';
      end;
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
    1 : Accept := csNotaFiscalSTATUSCOD.AsInteger = 0;
    2 : Accept := csNotaFiscalSTATUSCOD.AsInteger = 1;
    3 : Accept := csNotaFiscalSTATUSCOD.AsInteger = 2;
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

end.
