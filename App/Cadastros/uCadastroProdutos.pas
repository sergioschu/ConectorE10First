unit uCadastroProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids,
  System.Win.ComObj, System.TypInfo;

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
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btFecharClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btAtualizarClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure AtualizarProdutos;
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
  arrData : Variant;
  vrow,
  vcol,
  Count,
  I       : Integer;
begin
  if OpenDialog1.Execute then begin
    if Pos(ExtractFileExt(OpenDialog1.FileName), '|.xls|.xlsx|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado não existe! Verifique!');
        Exit;
      end;

      // Cria Excel- OLE Object
      Excel := CreateOleObject('Excel.Application');
      FWC   := TFWConnection.Create;
      P     := TPRODUTO.Create(FWC);
      try
        // Esconde Excel
        Excel.Visible  := False;
        // Abre o Workbook
        Excel.Workbooks.Open(Arquivo);

        Excel.Cells.SpecialCells(xlCellTypeLastCell, EmptyParam).Activate;
        vrow    := Excel.ActiveCell.Row;
        vcol    := Excel.ActiveCell.Column;
        arrData := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

        P.CODIGOPRODUTO.excelTitulo := 'SKU';
        P.CODIGOBARRAS.excelTitulo  := 'Código de barras';
        P.DESCRICAO.excelTitulo     := 'Nome';

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
      finally
        arrData := Unassigned;
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

end.
