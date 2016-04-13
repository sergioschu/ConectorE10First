unit uManutencaoPedidos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Data.DB, Datasnap.DBClient,
  Vcl.Samples.Gauges, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids,
  Vcl.DBGrids, FireDAC.Comp.Client, System.TypInfo, System.Win.ComObj,
  uFWConnection, Vcl.ComCtrls;

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
    csPedidosSTATUS: TStringField;
    csPedidosTRANSPORTADORA: TStringField;
    csPedidosDATA_IMPORTACAO: TDateField;
    pnConsulta: TPanel;
    btConsultar: TSpeedButton;
    gbPeriodo: TGroupBox;
    Label1: TLabel;
    edDataF: TDateTimePicker;
    edDataI: TDateTimePicker;
    rgStatus: TRadioGroup;
    csPedidosSELECIONE: TBooleanField;
    btAtualizarPedidos: TSpeedButton;
    btReenviar: TSpeedButton;
    procedure btFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure csPedidosFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure btPesquisarClick(Sender: TObject);
    procedure btAtualizarPedidosClick(Sender: TObject);
    procedure btAtualizarTransportadoraClick(Sender: TObject);
    procedure cbFiltroStatusChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btConsultarClick(Sender: TObject);
    procedure gdPedidosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure gdPedidosCellClick(Column: TColumn);
    procedure btReenviarClick(Sender: TObject);
  private
    procedure CarregaDados;
    procedure Filtrar;
    procedure AtualizarPedidos;
    procedure AtualizarTransportadora;
    procedure Reenviar;
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
  uMensagem,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanProduto,
  uBeanTransportadoras;

{$R *.dfm}

procedure TFrmManutencaoPedidos.AtualizarPedidos;
const
  xlCellTypeLastCell = $0000000B;
type
  TListaProdutos = record
    SKU : String;
    IDProduto: Integer;
  End;

Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
  PEDITENS: TPEDIDOITENS;
  P       : TPRODUTO;
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
  ListadeProdutos : array of TListaProdutos;
begin

  if OpenDialog1.Execute then begin
    if Pos(ExtractFileExt(OpenDialog1.FileName), '|.xls|.xlsx|') > 0 then begin
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
      PEDITENS  := TPEDIDOITENS.Create(FWC);
      P         := TPRODUTO.Create(FWC);

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
          pbAtualizaPedidos.MaxValue           := vrow;
          arrData                              := Excel.Range['A1', Excel.WorkSheets[1].Cells[vrow, vcol].Address].Value;

          SetLength(Colunas, 10);
          Colunas[0] := 'Pedido';
          Colunas[1] := 'CPF/CNPJ (sem máscara)';
          Colunas[2] := 'Cliente - Nome';
          Colunas[3] := 'Cliente - Logradouro';
          Colunas[4] := 'Cliente - Complemento';
          Colunas[5] := 'Cliente - CEP';
          Colunas[6] := 'Cliente - Município';
          Colunas[7] := 'Cod';
          Colunas[8] := 'Qnt. Pedida';
          Colunas[9] := 'Item - Preço uni. bruto';

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

          DisplayMsg(MSG_WAIT, 'Capturando Pedidos do arquivo!');

          SetLength(PedidoItens, 0);
          for I := 2 to vrow do begin
            SetLength(PedidoItens, Length(PedidoItens) + 1);
            PedidoItens[High(PedidoItens)].IMPORTAR := True;
            for J := 1 to vcol do begin
              if arrData[1, J] = 'Pedido' then
                PedidoItens[High(PedidoItens)].NUMEROPEDIDO     := arrData[I, J]
              else
                if arrData[1, J] = 'CPF/CNPJ (sem máscara)' then
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
                          if arrData[1, J] = 'Cliente - Município' then
                            PedidoItens[High(PedidoItens)].DEST_MUNICIPIO   := arrData[I, J]
                          else
                            if arrData[1, J] = 'Cod' then
                              PedidoItens[High(PedidoItens)].SKU              := arrData[I, J]
                            else
                              if arrData[1, J] = 'Qnt. Pedida' then
                                PedidoItens[High(PedidoItens)].QUANTIDADE       := arrData[I, J]
                              else
                                if arrData[1, J] = 'Item - Preço uni. bruto' then
                                  PedidoItens[High(PedidoItens)].VALOR_UNITARIO   := arrData[I, J];
            end;
            pbAtualizaPedidos.Progress := I;
          end;

          //Validando Pedidos a importar (Não Repetir Pedidos)
          DisplayMsg(MSG_WAIT, 'Identificando Pedidos a Importar!');

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := High(PedidoItens);

          for I := Low(PedidoItens) to High(PedidoItens) do begin
            PED.SelectList('PEDIDO = ' + QuotedStr(PedidoItens[I].NUMEROPEDIDO));
            if PED.Count > 0 then
              PedidoItens[I].IMPORTAR := False;
            pbAtualizaPedidos.Progress := I;
          end;

          DisplayMsg(MSG_WAIT, 'Identificando Itens dos Pedidos!');

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := High(PedidoItens);

          Aux := EmptyStr;
          SetLength(ListadeProdutos, 0);
          for I := Low(PedidoItens) to High(PedidoItens) do begin

            //Verifica se o Produto está na Lista
            PedidoItens[I].ID_PRODUTO := 0;
            for J := Low(ListadeProdutos) to High(ListadeProdutos) do begin
              if AnsiUpperCase(PedidoItens[I].SKU) = AnsiUpperCase(ListadeProdutos[J].SKU) then begin
                PedidoItens[I].ID_PRODUTO := ListadeProdutos[J].IDProduto;
                Break;
              end;
            end;

            //Consulta o produto no BD
            if PedidoItens[I].ID_PRODUTO = 0 then begin
              P.SelectList('UPPER(CODIGOPRODUTO) = ' + QuotedStr(UpperCase(PedidoItens[I].SKU)));
              if P.Count = 1 then begin

                PedidoItens[I].ID_PRODUTO := TPRODUTO(P.Itens[0]).ID.Value;

                SetLength(ListadeProdutos, Length(ListadeProdutos) + 1);
                ListadeProdutos[High(ListadeProdutos)].SKU        := PedidoItens[I].SKU;
                ListadeProdutos[High(ListadeProdutos)].IDProduto  := PedidoItens[I].ID_PRODUTO;
              end;
            end;

            if PedidoItens[I].ID_PRODUTO = 0 then begin
              if Aux = EmptyStr then
                Aux := PedidoItens[I].SKU
              else
                Aux := Aux + sLineBreak + PedidoItens[I].SKU;
            end;
            pbAtualizaPedidos.Progress := I;
          end;

          if Aux = EmptyStr then begin

            DisplayMsg(MSG_WAIT, 'Gravando Pedidos no Banco de Dados!');

            pbAtualizaPedidos.Progress  := 0;
            pbAtualizaPedidos.MaxValue  := High(PedidoItens);

            //Começa a Gravação dos Dados no BD
            for I := Low(PedidoItens) to High(PedidoItens) do begin
              if PedidoItens[I].NUMEROPEDIDO <> EmptyStr then begin
                if PedidoItens[I].IMPORTAR then begin
                  PED.SelectList('PEDIDO = ' + QuotedStr(PedidoItens[I].NUMEROPEDIDO));
                  if PED.Count = 0 then begin
                    PED.ID.isNull               := True;
                    PED.PEDIDO.Value            := PedidoItens[I].NUMEROPEDIDO;
                    PED.VIAGEM.Value            := '';
                    PED.SEQUENCIA.Value         := 0;
                    PED.ID_TRANSPORTADORA.Value := 0;
                    PED.DEST_CNPJ.Value         := PedidoItens[I].DEST_CNPJ;
                    PED.DEST_NOME.Value         := PedidoItens[I].DEST_NOME;
                    PED.DEST_ENDERECO.Value     := PedidoItens[I].DEST_ENDERECO;
                    PED.DEST_COMPLEMENTO.Value  := PedidoItens[I].DEST_COMPLEMENTO;
                    PED.DEST_CEP.Value          := PedidoItens[I].DEST_CEP;
                    PED.DEST_MUNICIPIO.Value    := PedidoItens[I].DEST_MUNICIPIO;
                    PED.STATUS.Value            := 0;
                    PED.ID_ARQUIVO.Value        := 0;
                    PED.ID_USUARIO.Value        := USUARIO.CODIGO;
                    PED.DATA_IMPORTACAO.Value   := Now;
                    PED.Insert;
                    PedidoItens[I].ID_PEDIDO    := PED.ID.Value;
                  end else begin
                    PedidoItens[I].ID_PEDIDO    := TPEDIDO(PED.Itens[0]).ID.Value;
                  end;

                  PEDITENS.ID.isNull            := True;
                  PEDITENS.ID_PEDIDO.Value      := PedidoItens[I].ID_PEDIDO;
                  PEDITENS.ID_PRODUTO.Value     := PedidoItens[I].ID_PRODUTO;
                  PEDITENS.QUANTIDADE.Value     := PedidoItens[I].QUANTIDADE;
                  PEDITENS.VALOR_UNITARIO.Value := PedidoItens[I].VALOR_UNITARIO;
                  PEDITENS.RECEBIDO.Value       := False;
                  PEDITENS.Insert;

                  pbAtualizaPedidos.Progress  := I;
                end;
              end;
            end;

            FWC.Commit;

            DisplayMsg(MSG_OK, 'Pedidos Atualizados com Sucesso!');

          end else begin
            DisplayMsg(MSG_WAR, 'Há Produtos com SKU sem Cadastro, Verifique!', '', Aux);
            Exit;
          end;

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
        FreeAndNil(P);
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
type
  TLISTATRANSP = record
    ID    : Integer;
    CNPJ  : String;
    NOME  : String;
  End;

type
  TPEDIDOTRANSP = record
    NumeroPedido      : String;
    Transportadora    : String;
    ID_Transportadora : Integer;
  End;
Var
  FWC     : TFWConnection;
  PED     : TPEDIDO;
  T       : TTRANSPORTADORA;
  Arquivo,
  Aux     : String;
  Excel   : OleVariant;
  arrData,
  Valor   : Variant;
  vrow,
  vcol,
  I,
  J       : Integer;
  PedidoTransp  : array of TPEDIDOTRANSP;
  ListaTransp   : array of TLISTATRANSP;
  ArqValido     : Boolean;
  AchouColuna   : Boolean;
  Colunas       : array of String;
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
      PED   := TPEDIDO.Create(FWC);
      T     := TTRANSPORTADORA.Create(FWC);

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

          SetLength(Colunas, 2);
          Colunas[0] := 'Pedido - Nº';
          Colunas[1] := 'Transportadora';

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

          DisplayMsg(MSG_WAIT, 'Capturando Transportadoras do arquivo!');

          SetLength(PedidoTransp, 0);
          for I := 2 to vrow do begin
            SetLength(PedidoTransp, Length(PedidoTransp) + 1);
            for J := 1 to vcol do begin
              if arrData[1, J] = Colunas[0] then
                PedidoTransp[High(PedidoTransp)].NUMEROPEDIDO     := arrData[I, J]
              else
                if arrData[1, J] = Colunas[1] then
                  PedidoTransp[High(PedidoTransp)].Transportadora := arrData[I, J];
            end;
            pbAtualizaPedidos.Progress := I;
          end;

          DisplayMsg(MSG_WAIT, 'Identificando Transportadora dos Pedidos!');

          pbAtualizaPedidos.Progress  := 0;
          pbAtualizaPedidos.MaxValue  := High(PedidoTransp);

          Aux := EmptyStr;
          SetLength(ListaTransp, 0);
          for I := Low(PedidoTransp) to High(PedidoTransp) do begin

            //Verifica se o Produto está na Lista
            PedidoTransp[I].ID_Transportadora := 0;
            for J := Low(ListaTransp) to High(ListaTransp) do begin
              if AnsiUpperCase(PedidoTransp[I].Transportadora) = AnsiUpperCase(ListaTransp[J].NOME) then begin
                PedidoTransp[I].ID_Transportadora := ListaTransp[J].ID;
                Break;
              end;
            end;

            //Consulta o produto no BD
            if PedidoTransp[I].ID_Transportadora = 0 then begin
              T.SelectList('UPPER(NOME) = ' + QuotedStr(UpperCase(PedidoTransp[I].Transportadora)));
              if T.Count = 1 then begin

                PedidoTransp[I].ID_Transportadora := TTRANSPORTADORA(T.Itens[0]).ID.Value;

                SetLength(ListaTransp, Length(ListaTransp) + 1);
                ListaTransp[High(ListaTransp)].ID   := TTRANSPORTADORA(T.Itens[0]).ID.Value;
                ListaTransp[High(ListaTransp)].CNPJ := TTRANSPORTADORA(T.Itens[0]).CNPJ.Value;
                ListaTransp[High(ListaTransp)].NOME := TTRANSPORTADORA(T.Itens[0]).NOME.Value;
              end;
            end;

            if PedidoTransp[I].ID_Transportadora = 0 then begin
              if Aux = EmptyStr then
                Aux := PedidoTransp[I].Transportadora
              else
                Aux := Aux + sLineBreak + PedidoTransp[I].Transportadora;
            end;
            pbAtualizaPedidos.Progress := I;
          end;

          if Aux = EmptyStr then begin

            DisplayMsg(MSG_WAIT, 'Gravando Transportadora dos Pedidos no Banco de Dados!');

            pbAtualizaPedidos.Progress  := 0;
            pbAtualizaPedidos.MaxValue  := High(PedidoTransp);

            //Começa a Gravação dos Dados no BD
            for I := Low(PedidoTransp) to High(PedidoTransp) do begin
              if PedidoTransp[I].NUMEROPEDIDO <> EmptyStr then begin
                PED.SelectList('PEDIDO = ' + QuotedStr(PedidoTransp[I].NUMEROPEDIDO));
                if PED.Count = 1 then begin
                  PED.ID.Value                := TPEDIDO(PED.Itens[0]).ID.Value;
                  PED.ID_TRANSPORTADORA.Value := PedidoTransp[I].ID_Transportadora;
                  PED.STATUS.Value            := 1;
                  PED.ID_USUARIO.Value        := USUARIO.CODIGO;
                  PED.Update;
                end;

                pbAtualizaPedidos.Progress  := I;
              end;
            end;

            FWC.Commit;

            DisplayMsg(MSG_OK, 'Transportadoras Atualizadas com Sucesso!');

          end else begin
            DisplayMsg(MSG_WAR, 'Há Transportadoras sem Cadastro, Verifique!', '', Aux);
            Exit;
          end;

        except
          on E : Exception do begin
            FWC.Rollback;
            DisplayMsg(MSG_ERR, 'Erro ao atualizar Transportadoras!', '', E.Message);
            Exit;
          end;
        end;
      finally
        Application.ProcessMessages;
        arrData := Unassigned;
        pbAtualizaPedidos.Progress               := 0;
        if not VarIsEmpty(Excel) then begin
          Excel.Quit;
          Excel := Unassigned;
        end;
        FreeAndNil(T);
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

procedure TFrmManutencaoPedidos.btConsultarClick(Sender: TObject);
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

procedure TFrmManutencaoPedidos.btReenviarClick(Sender: TObject);
begin
  if btReenviar.Tag = 0 then begin
    btReenviar.Tag   := 1;
    try
      Reenviar;
    finally
      btReenviar.Tag := 0;
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
      SQL.SQL.Add('	CAST(P.DATA_ENVIO AS DATE) AS DATA_ENVIO,');
      SQL.SQL.Add('	P.DEST_NOME,');
      SQL.SQL.Add('	P.DEST_ENDERECO,');
      SQL.SQL.Add('	P.DEST_CEP,');
      SQL.SQL.Add('	P.DEST_MUNICIPIO,');
      SQL.SQL.Add('	CASE P.STATUS WHEN 0 THEN ''Sem Transportadora''');
      SQL.SQL.Add('	              WHEN 1 THEN ''Com Transportadora''');
      SQL.SQL.Add('	              ELSE ''Enviado''');
      SQL.SQL.Add('	END AS STATUS,');
      SQL.SQL.Add('	CASE ID_TRANSPORTADORA WHEN 0 THEN ''''');
      SQL.SQL.Add('	              ELSE T.NOME');
      SQL.SQL.Add('	END AS NOMETRANSPORTADORA');
      SQL.SQL.Add('FROM PEDIDO P');
      SQL.SQL.Add('INNER JOIN TRANSPORTADORA T ON (T.ID = P.ID_TRANSPORTADORA)');
      SQL.SQL.Add('WHERE 1 = 1');
      SQL.SQL.Add('AND CAST(P.DATA_ENVIO AS DATE) BETWEEN :DATAI AND :DATAF');

      SQL.ParamByName('DATAI').DataType := ftDate;
      SQL.ParamByName('DATAF').DataType := ftDate;
      SQL.ParamByName('DATAI').Value    := edDataI.Date;
      SQL.ParamByName('DATAF').Value    := edDataF.Date;

      case rgStatus.ItemIndex of
        0 : SQL.SQL.Add('AND P.STATUS IN (0,1,2)');
        1 : SQL.SQL.Add('AND P.STATUS = 0');
        2 : SQL.SQL.Add('AND P.STATUS = 1');
        3 : SQL.SQL.Add('AND P.STATUS = 2');
      end;

      SQL.Connection                  := FWC.FDConnection;
      SQL.Prepare;
      SQL.Open();

      if not SQL.IsEmpty then begin
        SQL.First;
        while not SQL.Eof do begin
          csPedidos.Append;
          csPedidosID.Value               := SQL.Fields[0].Value;
          csPedidosPEDIDO.Value           := SQL.Fields[1].Value;
          csPedidosDATA_IMPORTACAO.Value  := SQL.Fields[2].Value;
          csPedidosDEST_NOME.Value        := SQL.Fields[3].Value;
          csPedidosDEST_ENDERECO.Value    := SQL.Fields[4].Value;
          csPedidosDEST_CEP.Value         := SQL.Fields[5].Value;
          csPedidosDEST_MUNICIPIO.Value   := SQL.Fields[6].Value;
          csPedidosSTATUS.Value           := SQL.Fields[7].Value;
          csPedidosTRANSPORTADORA.Value   := SQL.Fields[8].Value;
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

procedure TFrmManutencaoPedidos.Filtrar;
begin
  csPedidos.Filtered := False;
  csPedidos.Filtered := edPesquisa.Text <> '';
end;

procedure TFrmManutencaoPedidos.FormCreate(Sender: TObject);
begin
  AjustaForm(Self);
end;

procedure TFrmManutencaoPedidos.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TFrmManutencaoPedidos.FormShow(Sender: TObject);
begin
  csPedidos.CreateDataSet;
  AutoSizeDBGrid(gdPedidos);

  edDataI.Date  := Date;
  edDataF.Date  := Date;

  CarregaDados;

  if edPesquisa.CanFocus then
    edPesquisa.SetFocus;
end;

procedure TFrmManutencaoPedidos.gdPedidosCellClick(Column: TColumn);
begin
  if csPedidos.IsEmpty then Exit;

  csPedidos.Edit;
  csPedidosSELECIONE.Value  := not csPedidosSELECIONE.Value;
  csPedidos.Post;
end;

procedure TFrmManutencaoPedidos.gdPedidosDrawColumnCell(Sender: TObject;
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

  if Column.FieldName = csPedidosSELECIONE.FieldName then begin
    DrawRect   := Rect;
    InflateRect(DrawRect,-1,-1);
    gdPedidos.Canvas.FillRect(Rect);
    DrawFrameControl(gdPedidos.Canvas.Handle, DrawRect, DFC_BUTTON, ISChecked[Column.Field.AsBoolean]);
  end;
end;

procedure TFrmManutencaoPedidos.Reenviar;
var
  FWC : TFWConnection;
  P   : TPEDIDO;
begin
  if csPedidos.IsEmpty then begin
    DisplayMsg(MSG_WAR, 'Não existem dados para alterar!');
    Exit;
  end;

  csPedidos.DisableControls;
  FWC  := TFWConnection.Create;
  P    := TPEDIDO.Create(FWC);
  DisplayMsg(MSG_WAIT, 'Atualizando pedidos!');
  try
    try
      csPedidos.First;
      while not csPedidos.Eof do begin
        if csPedidosSELECIONE.Value then begin
          P.SelectList('id = ' + csPedidosID.AsString + ' and status = 2');
          if P.Count > 0 then begin
            P.ID.Value           := csPedidosID.Value;
            P.STATUS.Value       := 1;
            P.Update;

            csPedidos.Edit;
            csPedidosSELECIONE.Value := False;
            csPedidosSTATUS.Value    := 'Com Transportadora';
            csPedidos.Post;
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
    FreeAndNil(P);
    FreeAndNil(FWC);
  end;
end;

end.
