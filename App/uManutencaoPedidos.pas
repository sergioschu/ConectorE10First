unit uManutencaoPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, System.TypInfo, System.Win.ComObj;

type
  TFrmManutencaoPedidos = class(TForm)
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
    cbFiltroStatus: TComboBox;
    csPedidosSTATUS: TStringField;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure csPedidosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btPesquisarClick(Sender: TObject);
    procedure edPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btAtualizarPedidosClick(Sender: TObject);
    procedure btAtualizarTransportadoraClick(Sender: TObject);
    procedure cbFiltroStatusChange(Sender: TObject);
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
  FrmManutencaoPedidos: TFrmManutencaoPedidos;

implementation

uses
  uFuncoes,
  uDomains,
  uConstantes,
  uFWConnection,
  uMensagem,
  uBeanPedido,
  uBeanPedidoItens;

{$R *.dfm}

procedure TFrmManutencaoPedidos.AtualizarPedidos;
const
  xlCellTypeLastCell = $0000000B;
Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
  PEDITENS: TPEDIDOITENS;
  Arquivo,
  Aux     : String;
  Excel   : OleVariant;
  arrData : Variant;
  vrow, vcol,
  I, J    : Integer;
  ArqValido,
  AchouColuna : Boolean;
  Colunas: array of String;
  PedidoItens : array of TARRAYPEDIDOITENS;
begin

  if OpenDialog1.Execute then begin
    if Pos(ExtractFileExt(OpenDialog1.FileName), '|.xls|.xlsx|') > 0 then begin
      Arquivo := OpenDialog1.FileName;

      if not FileExists(Arquivo) then begin
        DisplayMsg(MSG_WAR, 'Arquivo selecionado n�o existe! Verifique!');
        Exit;
      end;

      // Cria Excel- OLE Object
      Excel                      := CreateOleObject('Excel.Application');

      FWC       := TFWConnection.Create;
      PED       := TPEDIDO.Create(FWC);
      PEDITENS  := TPEDIDOITENS.Create(FWC);

      try
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

          SetLength(Colunas, 10);
          Colunas[0] := 'Pedido';
          Colunas[1] := 'CPF/CNPJ (sem m�scara)';
          Colunas[2] := 'Cliente - Nome';
          Colunas[3] := 'Cliente - Logradouro';
          Colunas[4] := 'Cliente - Complemento';
          Colunas[5] := 'Cliente - CEP';
          Colunas[6] := 'Cliente - Munic�pio';
          Colunas[7] := 'Item - C�digo';
          Colunas[8] := 'Qnt. Pedida';
          Colunas[9] := 'Item - Pre�o uni. bruto';

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

            DisplayMsg(MSG_WAR, 'Arquivo Inv�lido, Verifique as Colunas!', '', Aux);
            Exit;
          end;

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := vrow;

          DisplayMsg(MSG_WAIT, 'Capturando Pedidos do arquivo!');

          SetLength(PedidoItens, 0);
          for I := 2 to vrow do begin
            SetLength(PedidoItens, Length(PedidoItens) + 1);
            for J := 1 to vcol do begin
              if arrData[1, J] = 'Pedido' then
                PedidoItens[High(PedidoItens)].NUMEROPEDIDO     := arrData[I, J]
              else
                if arrData[1, J] = 'CPF/CNPJ (sem m�scara)' then
                  PedidoItens[High(PedidoItens)].DEST_CNPJ        := arrData[I, J]
                else
                  if arrData[1, J] = 'Cliente - Nome' then
                    PedidoItens[High(PedidoItens)].DEST_NOME        := arrData[I, J]
                  else
                    if arrData[1, J] = 'Cliente - Logradouro' then
                      PedidoItens[High(PedidoItens)].DEST_ENDERECO    := arrData[I, J]
                    else
                      if arrData[1, J] = 'Cliente - Complemento' then
                        PedidoItens[High(PedidoItens)].DEST_COMPLEMENTO := arrData[I, J]
                      else
                        if arrData[1, J] = 'Cliente - CEP' then
                          PedidoItens[High(PedidoItens)].DEST_CEP         := arrData[I, J]
                        else
                          if arrData[1, J] = 'Cliente - Munic�pio' then
                            PedidoItens[High(PedidoItens)].DEST_MUNICIPIO   := arrData[I, J]
                          else
                            if arrData[1, J] = 'Item - C�digo' then
                              PedidoItens[High(PedidoItens)].SKU              := arrData[I, J]
                            else
                              if arrData[1, J] = 'Qnt. Pedida' then
                                PedidoItens[High(PedidoItens)].QUANTIDADE       := arrData[I, J]
                              else
                                if arrData[1, J] = 'Item - Pre�o uni. bruto' then
                                  PedidoItens[High(PedidoItens)].VALOR_UNITARIO   := arrData[I, J];
            end;
            pbAtualizaPedidos.Progress := I;
          end;

          DisplayMsg(MSG_WAIT, 'Gravando Pedidos no Banco de Dados!');

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := High(PedidoItens);

          //Come�a a Grava��o dos Dados no BD
          for I := Low(PedidoItens) to High(PedidoItens) do begin
            if PedidoItens[I].NUMEROPEDIDO <> EmptyStr then begin
              PED.SelectList('PEDIDO = ' + QuotedStr(PedidoItens[I].NUMEROPEDIDO));
              if PED.Count = 0 then begin
                PED.ID.isNull               := True;
                PED.PEDIDO.Value            := PedidoItens[I].NUMEROPEDIDO;
                PED.VIAGEM.Value            := '';
                PED.SEQUENCIA.Value         := 0;
                PED.TRANSP_CNPJ.Value       := '';
                PED.DEST_CNPJ.Value         := PedidoItens[I].DEST_CNPJ;
                PED.DEST_NOME.Value         := PedidoItens[I].DEST_NOME;
                PED.DEST_ENDERECO.Value     := PedidoItens[I].DEST_ENDERECO;
                PED.DEST_COMPLEMENTO.Value  := PedidoItens[I].DEST_COMPLEMENTO;
                PED.DEST_CEP.Value          := PedidoItens[I].DEST_CEP;
                PED.DEST_MUNICIPIO.Value    := PedidoItens[I].DEST_MUNICIPIO;
                PED.STATUS.Value            := 0;
                PED.ID_ARQUIVO.Value        := 0;
                PED.Insert;
                PedidoItens[I].ID_PEDIDO    := PED.ID.Value;
              end else begin
                PedidoItens[I].ID_PEDIDO    := TPEDIDO(PED.Itens[0]).ID.Value;
              end;

              PEDITENS.ID.isNull            := True;
              PEDITENS.ID_PEDIDO.Value      := PedidoItens[I].ID_PEDIDO;
              PEDITENS.ID_PRODUTO.Value     := 2;
              PEDITENS.QUANTIDADE.Value     := PedidoItens[I].QUANTIDADE;
              PEDITENS.VALOR_UNITARIO.Value := PedidoItens[I].VALOR_UNITARIO;
              PEDITENS.RECEBIDO.Value       := False;
              PEDITENS.Insert;

              pbAtualizaPedidos.Progress  := I;
            end;
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
        FreeAndNil(PEDITENS);
        FreeAndNil(FWC);
      end;
    end;
  end;
end;

procedure TFrmManutencaoPedidos.AtualizarTransportadora;
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
        DisplayMsg(MSG_WAR, 'Arquivo selecionado n�o existe! Verifique!');
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

          PED.PEDIDO.excelTitulo            := 'Pedido - N�';
          PED.VIAGEM.excelTitulo            := ''; //N�o tem no Excel
          PED.SEQUENCIA.excelTitulo         := ''; //N�o tem no Excel
          PED.TRANSP_CNPJ.excelTitulo       := 'Transportadora';
          PED.DEST_CNPJ.excelTitulo         := ''; //N�o tem no Excel
          PED.DEST_NOME.excelTitulo         := ''; //N�o tem no Excel
          PED.DEST_ENDERECO.excelTitulo     := ''; //N�o tem no Excel
          PED.DEST_COMPLEMENTO.excelTitulo  := ''; //N�o tem no Excel
          PED.DEST_CEP.excelTitulo          := ''; //N�o tem no Excel
          PED.DEST_MUNICIPIO.excelTitulo    := ''; //N�o tem no Excel
          PED.STATUS.excelTitulo            := ''; //N�o tem no Excel
          PED.ID_ARQUIVO.excelTitulo        := ''; //N�o tem no Excel

          PED.buscaIndicesExcel(Arquivo, Excel);

          Count                                           := GetPropList(PED.ClassInfo, tkProperties, @List, False);
          for I := 0 to Pred(Count) do begin
            if (TFieldTypeDomain(GetObjectProp(PED, List[I]^.Name)).excelTitulo <> '') and (TFieldTypeDomain(GetObjectProp(PED, List[I]^.Name)).excelIndice <= 0) then begin
              DisplayMsg(MSG_WAR, 'Estrutura do Arquivo Inv�lida, Verifique!', '', 'Colunas: ' + sLineBreak + 'Pedido - N�, ' + sLineBreak +
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
              PED.STATUS.Value      := 1;// 1 - Transportadora Vinculada
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

procedure TFrmManutencaoPedidos.btAtualizarPedidosClick(Sender: TObject);
begin
  if btAtualizarPedidos.Tag = 0 then begin
    btAtualizarPedidos.Tag := 1;
    try
      AtualizarPedidos;
      CarregaDados;
    finally
      btAtualizarPedidos.Tag := 0;
    end;
  end;
end;

procedure TFrmManutencaoPedidos.btAtualizarTransportadoraClick(Sender: TObject);
begin
  if btAtualizarTransportadora.Tag = 0 then begin
    btAtualizarTransportadora.Tag := 1;
    try
      AtualizarTransportadora;
      CarregaDados;
    finally
      btAtualizarTransportadora.Tag := 0;
    end;
  end;
end;

procedure TFrmManutencaoPedidos.btFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmManutencaoPedidos.btPesquisarClick(Sender: TObject);
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

procedure TFrmManutencaoPedidos.CarregaDados;
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
      SQL.SQL.Add('	P.DEST_NOME,');
      SQL.SQL.Add('	P.DEST_ENDERECO,');
      SQL.SQL.Add('	P.DEST_CEP,');
      SQL.SQL.Add('	P.DEST_MUNICIPIO,');
      SQL.SQL.Add('	CASE P.STATUS WHEN 0 THEN ''Sem Transportadora''');
      SQL.SQL.Add('	              WHEN 1 THEN ''Com Transportadora''');
      SQL.SQL.Add('	              ELSE ''Enviado''');
      SQL.SQL.Add('	END AS STATUS');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('WHERE 1 = 1');

      case cbFiltroStatus.ItemIndex of
        0 : SQL.SQL.Add('AND P.STATUS IN (0,1,2)');
        1 : SQL.SQL.Add('AND P.STATUS = 0');
        2 : SQL.SQL.Add('AND P.STATUS = 1');
        3 : SQL.SQL.Add('AND P.STATUS = 2');
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
          csPedidosDEST_NOME.Value      := SQL.Fields[2].Value;
          csPedidosDEST_ENDERECO.Value  := SQL.Fields[3].Value;
          csPedidosDEST_CEP.Value       := SQL.Fields[4].Value;
          csPedidosDEST_MUNICIPIO.Value := SQL.Fields[5].Value;
          csPedidosSTATUS.Value         := SQL.Fields[6].Value;
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

procedure TFrmManutencaoPedidos.cbFiltroStatusChange(Sender: TObject);
begin
  CarregaDados;
end;

procedure TFrmManutencaoPedidos.csPedidosFilterRecord(DataSet: TDataSet;
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

procedure TFrmManutencaoPedidos.edPesquisaKeyDown(Sender: TObject; var Key: Word;
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

procedure TFrmManutencaoPedidos.Filtrar;
begin
  csPedidos.Filtered := False;
  csPedidos.Filtered := edPesquisa.Text <> '';
end;

procedure TFrmManutencaoPedidos.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmManutencaoPedidos.FormShow(Sender: TObject);
begin
  csPedidos.CreateDataSet;
  CarregaDados;
  AutoSizeDBGrid(gdPedidos);

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

end.
