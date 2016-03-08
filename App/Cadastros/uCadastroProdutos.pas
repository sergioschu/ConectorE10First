unit uCadastroProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  System.Win.ComObj, System.TypInfo, Vcl.Samples.Gauges, Vcl.ImgList;

type
  TfrmCadastroProdutos = class(TForm)
    pnVisualizacao: TPanel;
    gdProdutos: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    dsProdutos: TDataSource;
    csProdutos: TClientDataSet;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    btAtualizar: TSpeedButton;
    csProdutosDESCRICAO: TStringField;
    csProdutosCODIGOPRODUTO: TStringField;
    csProdutosID: TIntegerField;
    OpenDialog1: TOpenDialog;
    pbAtualizaProduto: TGauge;
    csProdutosSTATUS: TBooleanField;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure csProdutosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure gdProdutosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btPesquisarClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure AtualizarProdutos;
    procedure Filtrar;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroProdutos: TfrmCadastroProdutos;

implementation

uses
  uFuncoes,
  uMensagem,
  uDomains,
  uFWConnection,
  uBeanProduto;

{$R *.dfm}

procedure TfrmCadastroProdutos.AtualizarProdutos;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  P       : TPRODUTO;
  List    : TPropList;
  Arquivo : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  Count,
  I,
  J       : Integer;
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

          P.CODIGOPRODUTO.excelTitulo          := 'CODIGO PRODUTO';
          P.DESCRICAOREDUZIDA.excelTitulo      := 'DESCRICAO REDUZIDA';
          P.DESCRICAOREDUZIDASKU.excelTitulo   := 'DESCRICAO REDUZIDA';
          P.DESCRICAOSKU.excelTitulo           := 'DESCRICAO DO SKU';
          P.DESCRICAO.excelTitulo              := 'DESCRICAO PRODUTO';
          P.PESOEMBALAGEM.excelTitulo          := 'PESO EMBALAGEM';
          P.QUANTIDADEPOREMBALAGEM.excelTitulo := 'QUANTIDADE POR EMBALAGEM';
          P.COMPRIMENTOEMBALAGEM.excelTitulo   := 'COMPRIMENTO';
          P.LARGURAEMBALAGEM.excelTitulo       := 'LARGURA';
          P.ALTURAEMBALAGEM.excelTitulo        := 'ALTURA';

          P.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(P.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(P, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(P, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'SKU, ' + sLineBreak +
                                                                                    'Código de barras, ' + sLineBreak +
                                                                                    'Nome');
              Exit;
            end;
          end;
          for I := 2 to vrow do begin
            for J := 0 to Pred(Count) do begin
              if (TFieldTypeDomain(GetObjectProp(P, List[J]^.Name)).excelIndice > 0) then begin
                Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(P, List[J]^.Name)).excelIndice]);
                if Valor <> '' then
                  TFieldTypeDomain(GetObjectProp(P, List[J]^.Name)).asVariant := Valor;
              end;
            end;
            P.UNIDADEDEMEDIDA.Value              := 'UND';
            P.CODIGOBARRAS.Value                 := P.CODIGOPRODUTO.Value;
            P.PESOPRODUTO.Value                  := 0;
            P.QUANTIDADECAIXASALTURAPALET.Value  := 0;
            P.QUANTIDADESCAIXASLASTROPALET.Value := 0;
            P.ALIQUOTAIPI.Value                  := 0;
            P.CLASSIFICACAOFISCAL.Value          := 'A';
            P.CATEGORIAPRODUTO.Value             := 1;
            P.STATUS.Value                       := False;
            P.SelectList('codigoproduto = ' + P.CODIGOPRODUTO.asSQL);
            if P.Count > 0 then begin
              P.ID.Value    := TPRODUTO(P.Itens[0]).ID.Value;
              P.Update;
            end else
              P.Insert;
            pbAtualizaProduto.Progress           := I;
          end;
          FWC.Commit;
          DisplayMsgFinaliza;
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
        FreeAndNil(P);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TfrmCadastroProdutos.btAtualizarClick(Sender: TObject);
begin
  if btAtualizar.Tag = 0 then begin
    btAtualizar.Tag := 1;
    try
      AtualizarProdutos;
    finally
      btAtualizar.Tag := 0;
    end;
  end;
end;

procedure TfrmCadastroProdutos.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroProdutos.btPesquisarClick(Sender: TObject);
begin
  if btPesquisar.Tag = 0 then begin
    btPesquisar.Tag    := 1;
    try
      Filtrar;
    finally
      btPesquisar.Tag  := 0;
    end;
  end;
end;

procedure TfrmCadastroProdutos.CarregaDados;
Var
  FWC : TFWConnection;
  P   : TPRODUTO;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  P   := TPRODUTO.Create(FWC);
  try
    try

      csProdutos.EmptyDataSet;

      P.SelectList();
      if P.Count > 0 then begin
        for I := 0 to P.Count -1 do begin
          csProdutos.Append;
          csProdutosID.Value              := TPRODUTO(P.Itens[I]).ID.Value;
          csProdutosCODIGOPRODUTO.Value   := TPRODUTO(P.Itens[I]).CODIGOPRODUTO.Value;
          csProdutosDESCRICAO.Value       := TPRODUTO(P.Itens[I]).DESCRICAO.Value;
          csProdutosSTATUS.Value          := TPRODUTO(P.Itens[I]).STATUS.Value;
          csProdutos.Post;
        end;
      end;

    except
      on E : Exception do begin
        DisplayMsg(MSG_ERR, 'Erro ao Carregar os dados da Tela.', '', E.Message);
      end;
    end;

  finally
    FreeAndNil(P);
    FreeAndNil(FWC);
  end;
end;

procedure TfrmCadastroProdutos.csProdutosFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  I : Integer;
begin
  Accept := False;
  for I := 0 to Pred(csProdutos.FieldCount) do begin
    Accept  := Pos(AnsiUpperCase(edPesquisa.Text), AnsiUpperCase(csProdutos.Fields[I].Value)) > 0;
    if Accept then
      Break;
  end;
end;

procedure TfrmCadastroProdutos.edPesquisaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_UP : begin
      if not ((csProdutos.IsEmpty) or (csProdutos.Bof)) then
        csProdutos.Prior;
    end;
    VK_DOWN : begin
      if not ((csProdutos.IsEmpty) or (csProdutos.Eof)) then
        csProdutos.Next;
    end;
    VK_RETURN : Filtrar;
  end;
end;

procedure TfrmCadastroProdutos.Filtrar;
begin
  csProdutos.Filtered := False;
  csProdutos.Filtered := edPesquisa.Text <> '';
end;

procedure TfrmCadastroProdutos.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TfrmCadastroProdutos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE : Close;
  end;
end;

procedure TfrmCadastroProdutos.FormShow(Sender: TObject);
begin
  csProdutos.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdProdutos);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TfrmCadastroProdutos.gdProdutosDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if csProdutos.IsEmpty then Exit;

  if (gdSelected in State) or (gdFocused in State) then begin
    gdProdutos.Canvas.Font.Color   := clWhite;
    gdProdutos.Canvas.Brush.Color  := clBlue;
    gdProdutos.Canvas.Font.Style   := [];
  end;

  gdProdutos.DefaultDrawDataCell( Rect, gdProdutos.Columns[DataCol].Field, State);

  if Column.FieldName = csProdutosSTATUS.FieldName then begin
    gdProdutos.Canvas.FillRect(Rect);
    if csProdutosSTATUS.Value then // Cadastro está ativo
      ImageList1.Draw(gdProdutos.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, 1)
    else
      ImageList1.Draw(gdProdutos.Canvas, (Rect.Left + (Rect.Width div 2) - 1), Rect.Top + 2, 0);
  end;
end;

end.
