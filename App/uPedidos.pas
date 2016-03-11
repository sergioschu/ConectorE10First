unit uPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, System.TypInfo, System.Win.ComObj;

type
  TFrmPedidos = class(TForm)
    pnVisualizacao: TPanel;
    gdPedidos: TDBGrid;
    pnPequisa: TPanel;
    btPesquisar: TSpeedButton;
    edPesquisa: TEdit;
    Panel2: TPanel;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    btAtualizarPedidos: TSpeedButton;
    pbAtualizaPedidos: TGauge;
    Panel3: TPanel;
    btFechar: TSpeedButton;
    dsPedidos: TDataSource;
    csPedidos: TClientDataSet;
    csPedidosID: TIntegerField;
    OpenDialog1: TOpenDialog;
    ImageList1: TImageList;
    csPedidosPEDIDO: TStringField;
    csPedidosDEST_NOME: TStringField;
    csPedidosDEST_ENDERECO: TStringField;
    csPedidosDEST_CEP: TStringField;
    csPedidosDEST_MUNICIPIO: TStringField;
    btAtualizarTransportadora: TSpeedButton;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure csPedidosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btPesquisarClick(Sender: TObject);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btAtualizarPedidosClick(Sender: TObject);
    procedure btAtualizarTransportadoraClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure Filtrar;
    procedure AtualizarPedidos;
    procedure AtualizarTransportadora;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPedidos: TFrmPedidos;

implementation

uses
  uFuncoes,
  uDomains,
  uFWConnection,
  uMensagem, uBeanPedido;

{$R *.dfm}

procedure TFrmPedidos.AtualizarPedidos;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
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
      PED                        := TPEDIDO.Create(FWC);
      pbAtualizaPedidos.Progress := 0;

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

          PED.PEDIDO.excelTitulo            := 'Pedido';
          PED.VIAGEM.excelTitulo            := ''; //Não tem no Excel
          PED.SEQUENCIA.excelTitulo         := ''; //Não tem no Excel
          PED.TRANSP_CNPJ.excelTitulo       := ''; //Não tem no Excel
          PED.DEST_CNPJ.excelTitulo         := 'CPF/CNPJ (sem máscara)';
          PED.DEST_NOME.excelTitulo         := 'Cliente - Nome';
          PED.DEST_ENDERECO.excelTitulo     := 'Cliente - Logradouro';
          PED.DEST_COMPLEMENTO.excelTitulo  := 'Cliente - Complemento';
          PED.DEST_CEP.excelTitulo          := 'Cliente - CEP';
          PED.DEST_MUNICIPIO.excelTitulo    := 'Cliente - Município';
          PED.STATUS.excelTitulo            := ''; //Não tem no Excel
          PED.ID_ARQUIVO.excelTitulo        := ''; //Não tem no Excel

          PED.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(PED.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(PED, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(PED, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'Pedido, ' + sLineBreak +
                                                                                    'CPF/CNPJ (sem máscara), ' + sLineBreak +
                                                                                    'Cliente - Nome, ' + sLineBreak +
                                                                                    'Cliente - Logradouro, ' + sLineBreak +
                                                                                    'Cliente - Complemento, ' + sLineBreak +
                                                                                    'Cliente - CEP, ' + sLineBreak +
                                                                                    'Cliente - Município');
              Exit;
            end;
          end;

          for I := 2 to vrow do begin
            for J := 0 to Pred(Count) do begin
              if (TFieldTypeDomain(GetObjectProp(PED, List[J]^.Name)).excelIndice > 0) then begin
                Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(PED, List[J]^.Name)).excelIndice]);
                if Valor <> '' then
                  TFieldTypeDomain(GetObjectProp(PED, List[J]^.Name)).asVariant := Valor;
              end;
            end;

            PED.VIAGEM.Value              := '';
            PED.SEQUENCIA.Value           := 0;
            PED.TRANSP_CNPJ.Value         := '';
            PED.STATUS.Value              := 0;
            PED.ID_ARQUIVO.Value          := 0;

            PED.SelectList('PEDIDO = ' + PED.PEDIDO.asSQL);
            if PED.Count > 0 then begin
              PED.ID.Value    := TPEDIDO(PED.Itens[0]).ID.Value;
              PED.Update;
            end else
              PED.Insert;
            pbAtualizaPedidos.Progress           := I;
          end;

          FWC.Commit;

          DisplayMsg(MSG_OK, 'Pedidos Atualizados com Sucesso!');

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Produtos!', '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData := Unassigned;
        pbAtualizaPedidos.Progress               := 0;
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

procedure TFrmPedidos.AtualizarTransportadora;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
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
      PED                        := TPEDIDO.Create(FWC);
      pbAtualizaPedidos.Progress := 0;

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

          PED.PEDIDO.excelTitulo            := 'Pedido - Nº';
          PED.VIAGEM.excelTitulo            := ''; //Não tem no Excel
          PED.SEQUENCIA.excelTitulo         := ''; //Não tem no Excel
          PED.TRANSP_CNPJ.excelTitulo       := 'Transportadora';
          PED.DEST_CNPJ.excelTitulo         := ''; //Não tem no Excel
          PED.DEST_NOME.excelTitulo         := ''; //Não tem no Excel
          PED.DEST_ENDERECO.excelTitulo     := ''; //Não tem no Excel
          PED.DEST_COMPLEMENTO.excelTitulo  := ''; //Não tem no Excel
          PED.DEST_CEP.excelTitulo          := ''; //Não tem no Excel
          PED.DEST_MUNICIPIO.excelTitulo    := ''; //Não tem no Excel
          PED.STATUS.excelTitulo            := ''; //Não tem no Excel
          PED.ID_ARQUIVO.excelTitulo        := ''; //Não tem no Excel

          PED.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(PED.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(PED, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(PED, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inválida, Verifique!', '', 'Colunas: ' + sLineBreak + 'Pedido - Nº, ' + sLineBreak +
                                                                                    'Transportadora');
              Exit;
            end;
          end;

          for I := 2 to vrow do begin
            for J := 0 to Pred(Count) do begin
              if (TFieldTypeDomain(GetObjectProp(PED, List[J]^.Name)).excelIndice > 0) then begin
                Valor                                   := Trim(arrData[I, TFieldTypeDomain(GetObjectProp(PED, List[J]^.Name)).excelIndice]);
                if Valor <> '' then
                  TFieldTypeDomain(GetObjectProp(PED, List[J]^.Name)).asVariant := Valor;
              end;
            end;

            PED.SelectList('PEDIDO = ' + PED.PEDIDO.asSQL);
            if PED.Count > 0 then begin
              PED.ID.Value          := TPEDIDO(PED.Itens[0]).ID.Value;
              PED.Update;
            end;
            pbAtualizaPedidos.Progress           := I;
          end;

          FWC.Commit;

          DisplayMsg(MSG_OK, 'Pedidos Atualizados com Sucesso!');

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Produtos!', '', E.Message);
            Exit;
          end;
        end;
      finally
        arrData := Unassigned;
        pbAtualizaPedidos.Progress               := 0;
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

procedure TFrmPedidos.btAtualizarPedidosClick(Sender: TObject);
begin
  if btAtualizarPedidos.Tag = 0 then begin
    btAtualizarPedidos.Tag := 1;
    try
      AtualizarPedidos;
    finally
      btAtualizarPedidos.Tag := 0;
    end;
  end;
end;

procedure TFrmPedidos.btAtualizarTransportadoraClick(Sender: TObject);
begin
  if btAtualizarTransportadora.Tag = 0 then begin
    btAtualizarTransportadora.Tag := 1;
    try
      AtualizarTransportadora;
    finally
      btAtualizarTransportadora.Tag := 0;
    end;
  end;
end;

procedure TFrmPedidos.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPedidos.btPesquisarClick(Sender: TObject);
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

procedure TFrmPedidos.CarregaDados;
Var
  FWC : TFWConnection;
  SQL : TFDQuery;
  I   : Integer;
begin

  FWC := TFWConnection.Create;
  SQL := TFDQuery.Create(nil);
  try
    try

      csPedidos.EmptyDataSet;

      SQL.Close;
      SQL.SQL.Clear;
      SQL.SQL.Add('SELECT');
      SQL.SQL.Add('	P.ID,');
      SQL.SQL.Add('	P.PEDIDO,');
      SQL.SQL.Add('	P.DEST_NOME,');
      SQL.SQL.Add('	P.DEST_ENDERECO,');
      SQL.SQL.Add('	P.DEST_CEP,');
      SQL.SQL.Add('	P.DEST_MUNICIPIO');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.Connection                      := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open();

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          csPedidos.Append;
          csPedidosID.Value             := SQL.Fields[0].Value;
          csPedidosPEDIDO.Value         := SQL.Fields[1].Value;
          csPedidosDEST_NOME.Value      := SQL.Fields[2].Value;
          csPedidosDEST_ENDERECO.Value  := SQL.Fields[3].Value;
          csPedidosDEST_CEP.Value       := SQL.Fields[4].Value;
          csPedidosDEST_MUNICIPIO.Value := SQL.Fields[5].Value;
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
  end;
end;

procedure TFrmPedidos.csPedidosFilterRecord(DataSet: TDataSet;
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

procedure TFrmPedidos.edPesquisaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_UP : begin
      if not ((csPedidos.IsEmpty) or (csPedidos.Bof)) then
        csPedidos.Prior;
    end;
    VK_DOWN : begin
      if not ((csPedidos.IsEmpty) or (csPedidos.Eof)) then
        csPedidos.Next;
    end;
    VK_RETURN : Filtrar;
  end;
end;

procedure TFrmPedidos.Filtrar;
begin
  csPedidos.Filtered := False;
  csPedidos.Filtered := edPesquisa.Text <> '';
end;

procedure TFrmPedidos.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmPedidos.FormShow(Sender: TObject);
begin
  csPedidos.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPedidos);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

end.
