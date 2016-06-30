unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uFWConnection, System.IniFiles,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.ImgList, System.DateUtils;

type
  TfrmPrincipal = class(TForm)
    Panel1: TPanel;
    btIniciar: TBitBtn;
    Timer1: TTimer;
    ImageList1: TImageList;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btIniciarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function BuscaNumeroArquivo(Con : TFWConnection; Tipo : Integer) : Integer;
    procedure SaveLog(Texto : String);
    procedure CarregarConexaoBD;
    procedure CarregarConfigLocal;
    function EnviaPedidos : Boolean;
    function EnviaPedidosFaturados : Boolean;
    function EnviaPDF : Boolean;
    function EnviaProdutos : Boolean;
    function EnviaNotasFiscais : Boolean;
    function BuscaMDD : Boolean;
    function BuscaCONF : Boolean;
    function CopiarPDF(Data : TDate; Documento : Integer; Serie : String; ID : Integer) : Boolean;
    Procedure IniciarPararLeitura;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  uFuncoes,
  uConexaoFTP,
  uBeanproduto,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanTransportadoras,
  uBeanArquivosFTP,
  uBeanNotafiscal,
  uBeanNotafiscalItens,
  uBeanPedido_Notafiscal,
  uConstantes,
  uDados,
  uFuncoes;
{$R *.dfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.btIniciarClick(Sender: TObject);
begin
  if btIniciar.Tag = 0 then begin
    try
      IniciarPararLeitura;
    finally
      btIniciar.Tag := 0;
    end;
  end;
end;

function TfrmPrincipal.BuscaCONF: Boolean;
var
  search_rec  : TSearchRec;
  Lista       : TStringList;
  CONF        : TStringList;
  I,
  J           : Integer;
  FWC         : TFWConnection;
  PR          : TPRODUTO;
  NF          : TNOTAFISCAL;
  NI          : TNOTAFISCALITENS;
  Deletar     : Boolean;
  NOTAENTRADA : array of TNOTAENTRADA;
  NOTAATUAL   : TNOTAENTRADA;
  Achou       : Boolean;
begin
  if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
    SaveLog('Achou pelo menos 1!');
    SetLength(NOTAENTRADA, 0);
    try
      repeat
        if (search_rec.Attr <> faDirectory) and (Pos('CONF', search_rec.Name) > 0) then begin
          Deletar := True;

          Lista   := TStringList.Create;
          CONF    := TStringList.Create;

          FWC     := TFWConnection.Create;
          NF      := TNOTAFISCAL.Create(FWC);
          NI      := TNOTAFISCALITENS.Create(FWC);
          PR      := TPRODUTO.Create(FWC);

          try
            FWC.StartTransaction;
            try

              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);

              for I := 0 to Pred(Lista.Count) do begin
                if Length(Trim(Lista[I])) > 0 then begin
                  CONF.Delimiter       := ';';
                  CONF.StrictDelimiter := True;
                  CONF.DelimitedText   := Lista[I];
                  if CONF.Count = 11 then begin

                    //Add by Sergio 16.06.16
                    if StrToFloatDef(CONF[8], -1) < 0 then begin
                      SaveLog('QUANTIDADE FISICA PRODUTO em ' + search_rec.Name + ' Inválida! ' + Lista[I]);
                      Exit;
                    end;

                    if StrToFloatDef(CONF[9], -1) < 0 then begin
                      SaveLog('QUANTIDADE AVARIADA PRODUTO em ' + search_rec.Name + ' Inválida! ' + Lista[I]);
                      Exit;
                    end;

                    SaveLog('arquivo valido!');
                    Achou := False;
                    for J := Low(NOTAENTRADA) to High(NOTAENTRADA) do begin
                      if (IntToStr(NOTAENTRADA[J].DOCUMENTO) = CONF[0]) and (IntToStr(NOTAENTRADA[J].SERIE) = CONF[1]) then begin
                        Achou := True;
                        NOTAATUAL.DOCUMENTO   := NOTAENTRADA[J].DOCUMENTO;
                        NOTAATUAL.SERIE       := NOTAENTRADA[J].SERIE;
                        NOTAATUAL.ID          := NOTAENTRADA[J].ID;
                        Break;
                      end;
                    end;

                    if not Achou then begin
                      NF.SelectList('documento = ' + CONF[0] + ' and serie = ' + CONF[1] + ' and status <= 1');
                      if NF.Count > 0 then begin
                        SetLength(NOTAENTRADA, Length(NOTAENTRADA) + 1);
                        NOTAENTRADA[High(NOTAENTRADA)].DOCUMENTO  := TNOTAFISCAL(NF.Itens[0]).DOCUMENTO.Value;
                        NOTAENTRADA[High(NOTAENTRADA)].SERIE      := TNOTAFISCAL(NF.Itens[0]).SERIE.Value;
                        NOTAENTRADA[High(NOTAENTRADA)].ID         := TNOTAFISCAL(NF.Itens[0]).ID.Value;

                        NOTAATUAL.DOCUMENTO := NOTAENTRADA[High(NOTAENTRADA)].DOCUMENTO;
                        NOTAATUAL.SERIE := NOTAENTRADA[High(NOTAENTRADA)].SERIE;
                        NOTAATUAL.ID := NOTAENTRADA[High(NOTAENTRADA)].ID;
                      end else begin
                        SaveLog('Nota Fiscal ' + CONF[0] + ' não encontrada ou já recebida!');
                        NOTAATUAL.DOCUMENTO := -1;
                        NOTAATUAL.SERIE     := -1;
                        NOTAATUAL.ID        := -1;
                        Deletar                        := False;
                      end;
                    end;

                    if NOTAATUAL.ID >= 0 then begin
                      PR.SelectList('upper(codigoproduto) = ' + QuotedStr(UpperCase(CONF[5])));
                      if PR.Count > 0 then begin
                        NI.SelectList('ID_NOTAFISCAL = ' + IntToStr(NOTAATUAL.ID) + ' AND ID_PRODUTO = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                        if NI.Count > 0 then begin
                          NI.ID.Value                := TNOTAFISCALITENS(NI.Itens[0]).ID.Value;
                          NI.QUANTIDADEREC.Value     := StrToFloat(CONF[8]);
                          NI.QUANTIDADEAVA.Value     := StrToFloat(CONF[9]);
                          NI.Update;
                        end else begin
                         SaveLog('Produto ' + CONF[5] + ' não encontrado na nota!');
                         Deletar                     := False;
                        end;
                      end else begin
                        SaveLog('Produto não encontrado!');
                        Deletar                      := False;
                      end;
                    end;
                  end;
                end;
              end;

              for I := Low(NOTAENTRADA) to High(NOTAENTRADA) do begin
                NF.ID.Value                      := NOTAENTRADA[I].ID;
                NF.DATA_RECEBIDO.Value           := Now;
                NF.STATUS.Value                  := 2;
                NF.Update;
              end;

              if Deletar then
                SalvarArquivo(DirArquivosFTP + search_rec.Name)
              else begin
                if CopyFile(PwideChar(DirArquivosFTP + search_rec.Name), PwideChar(DirArquivosFTP + 'Erros\' + search_rec.Name), False) then
                  DeleteFile(DirArquivosFTP + search_rec.Name);
              end;

              FWC.Commit;

            except
              on E : Exception do begin
                FWC.Rollback;
                SaveLog('Erro ao bucar CONF: ' + E.Message);
              end;
            end;
          finally
            FreeAndNil(CONF);
            FreeAndNil(Lista);
            FreeAndNil(NF);
            FreeAndNil(NI);
            FreeAndNil(PR);
            FreeAndNil(FWC);
          end;
        end;
      until FindNext(search_rec) <> 0;
    finally
      FindClose(search_rec);
    end;
  end;
end;

function TfrmPrincipal.BuscaMDD: Boolean;
var
  search_rec  : TSearchRec;
  Lista       : TStringList;
  MDD         : TStringList;
  I,
  J           : Integer;
  CON         : TFWConnection;
  PR          : TPRODUTO;
  P           : TPEDIDO;
  PI          : TPEDIDOITENS;
  T           : TTRANSPORTADORA;
  Deletar,
  Achou,
  Atualizar   : Boolean;
  PEDIDOS     : array of TPEDIDOS;
  PEDIDOATUAL : TPEDIDOS;
  Arquivo     : String;
begin
  if FindFirst(DirArquivosFTP + '*.txt', faAnyFile, search_rec) = 0 then begin
    SaveLog('Existe arquivo na pasta local, arquivo: ' + search_rec.Name);
    try
      repeat
        if (search_rec.Attr <> faDirectory) and (Pos('MDD', search_rec.Name) > 0) then begin
          SaveLog('Arquivo é um MDD');
          Lista   := TStringList.Create;
          MDD     := TStringList.Create;
          SetLength(PEDIDOS, 0);
          Deletar := True;
          try
            try
              MDD.Delimiter       := ';';
              MDD.StrictDelimiter := True;
              SaveLog('Antes de Carregar o Arquivo!');

              Lista.LoadFromFile(DirArquivosFTP + search_rec.Name);

              SaveLog('Depois de Carregar o Arquivo!');
              if Lista.Count > 0 then begin
                SaveLog('Arquivo não esta Vazio!');
                for I := 0 to Pred(Lista.Count) do begin
                  if Length(Trim(Lista[I])) > 0 then begin

                    SaveLog('Antes do Delimit');
                    MDD.DelimitedText   := Lista[I];

                    SaveLog('Depois do Delimit');
                    if MDD.Count = 7 then begin
                      SaveLog('MDD Válido!');
                      for J := 0 to Pred(Length(PEDIDOS)) do begin
                        if PEDIDOS[J].PEDIDO = MDD[2] then begin
                          SetLength(PEDIDOS[J].PRODUTOS, Length(PEDIDOS[J].PRODUTOS) + 1);
                          PEDIDOS[J].PRODUTOS[High(PEDIDOS[J].PRODUTOS)] := MDD[2];
                          Achou       := True;
                          SaveLog('Inserindo Itens no Pedido');
                          Break;
                        end;
                      end;
                      if not Achou then begin
                        SaveLog('Não Achou, Vamos incluir');
                        SetLength(PEDIDOS, Length(PEDIDOS) + 1);
                        SaveLog('Aumentou o tamanho do array');
                        PEDIDOS[High(PEDIDOS)].PEDIDO      := MDD[0];
                        PEDIDOS[High(PEDIDOS)].VOLUMES     := StrToIntDef(MDD[6], 1);
                        SaveLog('atribuiu os valores');

                        SetLength(PEDIDOS[High(PEDIDOS)].PRODUTOS, 1);
                        SaveLog('aumentou array de itens');
                        PEDIDOS[High(PEDIDOS)].PRODUTOS[0] := MDD[2];
                        SaveLog('Inseriu um Pedido no Array');
                      end;
                    end else
                      SaveLog('Linha com tamanho inválido!');
                  end;
                end;

                CON    := TFWConnection.Create;
                P      := TPEDIDO.Create(CON);
                PR     := TPRODUTO.Create(CON);
                PI     := TPEDIDOITENS.Create(CON);
                T      := TTRANSPORTADORA.Create(CON);

                try
                  SaveLog('Percorrendo Array');
                  CON.StartTransaction;
                  try
                    for I := Low(PEDIDOS) to High(PEDIDOS) do begin
                      Atualizar := True;
                      P.SelectList('pedido = ' + QuotedStr(PEDIDOS[I].PEDIDO) + ' and status <= 2');
                      if P.Count > 0 then begin
                        for J := Low(PEDIDOS[I].PRODUTOS) to High(PEDIDOS[I].PRODUTOS) do begin
                          PR.SelectList('upper(codigoproduto) = ' + QuotedStr(AnsiUpperCase(PEDIDOS[I].PRODUTOS[J])));
                          if PR.Count > 0 then begin
                            PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[0]).ID.asString + ' and id_produto = ' + TPRODUTO(PR.Itens[0]).ID.asString);
                            if PI.Count = 0 then begin
                              SaveLog('Produto não esta incluido no pedido!');
                              Atualizar := False;
                              Deletar := False;
                            end;
                          end else begin
                            SaveLog('Produto ' + PEDIDOS[I].PRODUTOS[J] + ' não cadastrado!');
                            Atualizar := False;
                            Deletar := False;
                          end;
                        end;

                        if Atualizar then begin
                          P.ID.Value                := TPEDIDO(P.Itens[0]).ID.Value;
                          P.STATUS.Value            := 3;
                          P.DATA_RECEBIDO.Value     := Now;
                          T.SelectList('ID = ' + TPEDIDO(P.Itens[0]).ID_TRANSPORTADORA.asString);
                          if T.Count > 0 then begin
                            if ( AnsiUpperCase(TTRANSPORTADORA(T.Itens[0]).NOME.Value) = 'TEX COURIER S.A.') then
                              P.VOLUMES_DOCUMENTO.Value := 1
                            else
                              P.VOLUMES_DOCUMENTO.Value := PEDIDOS[I].VOLUMES;
                          end;
                          P.Update;
                        end;
                      end else begin
                        SaveLog('Pedido Não Encontrado ou já recebido!');
                        Deletar := False;
                      end;
                    end;

                    CON.Commit;

                  except
                    on E : Exception do begin
                      CON.Rollback;
                      SaveLog('Erro ao Salvar Dados, Erro: ' + E.Message);
                    end;
                  end;
                finally
                  FreeAndNil(P);
                  FreeAndNil(PR);
                  FreeAndNil(PI);
                  FreeAndNil(CON);
                end;

                if Deletar then
                  SalvarArquivo(DirArquivosFTP + search_rec.Name)
                else begin
                  Arquivo := DirArquivosFTP + search_rec.Name;
                  if CopyFile(PWidechar(Arquivo), PWidechar(DirArquivosFTP + 'Erros\' + search_rec.Name), false) then
                    DeleteFile(DirArquivosFTP + search_rec.Name);
                end;
              end else begin
                SaveLog('Arquivo ' + search_rec.Name + ' Vazio, Copiado para pasta Erros e Apagado!');
                Arquivo := DirArquivosFTP + search_rec.Name;
                if CopyFile(PWidechar(Arquivo), PWidechar(DirArquivosFTP + 'Erros\' + search_rec.Name), false) then
                  DeleteFile(DirArquivosFTP + search_rec.Name);
              end;
            except
              on E : Exception do
                SaveLog('Ocorreu algum erro ao tratar arquivos locais, Erro: ' + E.Message);
            end;
          finally
            FreeAndNil(Lista);
            FreeAndNil(MDD);
          end;
        end else
          SaveLog('Arquivo não é um MDD!');
      until (FindNext(search_rec) <> 0);
    finally
      FindClose(search_rec);
    end;
  end;
end;

function TfrmPrincipal.BuscaNumeroArquivo(Con: TFWConnection;
  Tipo: Integer): Integer;
var
  AF : TARQUIVOSFTP;
begin

  Result := 0;

  AF   := TARQUIVOSFTP.Create(Con);
  try
    try
      AF.ID.isNull        := True;
      AF.TIPO.Value       := Tipo;
      AF.DATAENVIO.Value  := Now;
      AF.Insert;

      Result := AF.ID.Value;
    except
      on E : exception do
        SaveLog('Erro ao buscar numero arquivo FTP. Erro: ' + E.Message);
    end;
  finally
    FreeAndNil(AF);
  end;
end;

procedure TfrmPrincipal.CarregarConexaoBD;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    LOGIN.Usuario               := ArqINI.ReadString('LOGIN', 'USUARIO', '');
    LOGIN.LembrarUsuario        := ArqINI.ReadBool('LOGIN', 'LEMBRARUSUARIO', True);

    CONFIG_LOCAL.DirRelatorios  := ArqINI.ReadString('CONFIGURACOES', 'DIR_RELATORIOS', 'C:\ConectorE10First\Relatorios\');
    CONFIG_LOCAL.DirLog         := ArqINI.ReadString('CONFIGURACOES', 'DIR_LOGS', 'C:\ConectorE10First\Logs\');
    CONFIG_LOCAL.FTPUsuario     := ArqINI.ReadString('CONFIGURACOES', 'FTP_USUARIO', '');
    CONFIG_LOCAL.FTPSenha       := ArqINI.ReadString('CONFIGURACOES', 'FTP_SENHA', '');
    CONFIG_LOCAL.Sleep          := ArqINI.ReadInteger('CONFIGURACOES', 'FTP_SLEEP', 0);
  finally
    FreeAndNil(ArqINI);
  end;

end;

procedure TfrmPrincipal.CarregarConfigLocal;
Var
  ArqINI : TIniFile;
begin

  ArqINI := TIniFile.Create(DirArqConf);
  try

    CONEXAO.LibVendor     := ExtractFilePath(ParamStr(0)) + 'libpq.dll';
    CONEXAO.Database      := ArqINI.ReadString('CONEXAOBD', 'Database', '');
    CONEXAO.Server        := ArqINI.ReadString('CONEXAOBD', 'Server', 'localhost');
    CONEXAO.User_Name     := ArqINI.ReadString('CONEXAOBD', 'User_Name', '');
    CONEXAO.Password      := ArqINI.ReadString('CONEXAOBD', 'Password', '');
    CONEXAO.CharacterSet  := ArqINI.ReadString('CONEXAOBD', 'CharacterSet', 'UTF8');
    CONEXAO.DriverID      := ArqINI.ReadString('CONEXAOBD', 'DriverID', 'PG');
    CONEXAO.Port          := ArqINI.ReadString('CONEXAOBD', 'Port', '5432');

  finally
    FreeAndNil(ArqINI);
  end;

end;

function TfrmPrincipal.EnviaNotasFiscais: Boolean;
var
  Con     : TFWConnection;
  NF      : TNOTAFISCAL;
  NI      : TNOTAFISCALITENS;
  PR      : TPRODUTO;
  I,
  J,
  AFTP    : Integer;
  Lista   : TStringList;
begin
  Con   := TFWConnection.Create;
  NF    := TNOTAFISCAL.Create(Con);
  NI    := TNOTAFISCALITENS.Create(Con);
  PR    := TPRODUTO.Create(Con);
  Lista := TStringList.Create;
  try
    Con.StartTransaction;
    try
      NF.SelectList('status = 0');
      if NF.Count > 0 then begin
        SaveLog('Tem NF para exportar');
        AFTP    := BuscaNumeroArquivo(Con, 1);
        for I := 0 to Pred(NF.Count) do begin
          NI.SelectList('id_notafiscal = ' + TNOTAFISCAL(NF.Itens[I]).ID.asString);
          if NI.Count > 0 then begin
            for J := 0 to Pred(NI.Count) do begin
              PR.SelectList('id = ' + TNOTAFISCALITENS(NI.Itens[J]).ID_PRODUTO.asString);
              if PR.Count > 0 then begin
                Lista.Add(TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).SERIE.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).CNPJCPF.asString + ';' +
                  FormatDateTime('yyyymmdd', TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value) + ';' +
                  TNOTAFISCAL(NF.Itens[I]).CFOP.asString + ';' +
                  IntToStr(J + 1) + ';' +
                  TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString + ';' +
                  TNOTAFISCALITENS(NI.Itens[J]).QUANTIDADE.asString + ';' +
                  TNOTAFISCALITENS(NI.Itens[J]).VALORUNITARIO.asString + ';' +
                  TNOTAFISCALITENS(NI.Itens[J]).VALORTOTAL.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).VALORTOTAL.asString + ';' +
                  TNOTAFISCAL(NF.Itens[I]).ESPECIE.asString + ';'
                );
              end;
            end;
            NF.ID.Value           := TNOTAFISCAL(NF.Itens[I]).ID.Value;
            NF.STATUS.Value       := 1;
            NF.ID_ARQUIVO.Value   := AFTP;
            NF.DATA_ENVIO.Value   := Now;
            NF.Update;
          end;
        end;
        if Lista.Count > 0 then begin
          SaveLog('Tem algo na lista!');
          Lista.SaveToFile(DirArquivosFTP + 'ARMZ' + NF.ID_ARQUIVO.asString + '.txt');
        end;
      end;

      Con.Commit;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar NF: ' +E.Message);
      end;
    end;
  finally
    FreeAndNil(NF);
    FreeAndNil(NI);
    FreeAndNil(PR);
    FreeAndNil(Con);
    FreeAndNil(Lista);
  end;
end;

function TfrmPrincipal.EnviaPedidos: Boolean;
var
  Con     : TFWConnection;
  P       : TPEDIDO;
  PI      : TPEDIDOITENS;
  PR      : TPRODUTO;
  T       : TTRANSPORTADORA;
  Lista   : TStringList;
  I,
  J       : Integer;
begin
  Con    := TFWConnection.Create;
  P      := TPEDIDO.Create(Con);
  PI     := TPEDIDOITENS.Create(Con);
  PR     := TPRODUTO.Create(Con);
  T      := TTRANSPORTADORA.Create(Con);
  Lista  := TStringList.Create;

  try
    Con.StartTransaction;
    try
      P.SelectList('status = 1');
      if P.Count > 0 then begin
        for I := 0 to Pred(P.Count) do begin
          Lista.Clear;

          T.SelectList('id = ' + TPEDIDO(P.Itens[I]).ID_TRANSPORTADORA.asString);
          if T.Count > 0 then begin
            PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[I]).ID.asString);
            if PI.Count > 0 then begin
              for J := 0 to Pred(PI.Count) do begin
                PR.SelectList('id = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
                if PR.Count > 0 then begin
                  Lista.Add(TTRANSPORTADORA(T.Itens[0]).CNPJ.asString + ';' +
                    TPEDIDO(P.Itens[I]).PEDIDO.asString + ';' +
                    TPEDIDO(P.Itens[I]).VIAGEM.asString + ';' +
                    TPEDIDO(P.Itens[I]).SEQUENCIA.asString + ';' +
                    TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString + ';' +
                    TPRODUTO(PR.Itens[0]).UNIDADEDEMEDIDA.asString + ';' +
                    TPEDIDOITENS(PI.Itens[J]).QUANTIDADE.asString + ';' +
                    TPEDIDOITENS(PI.Itens[J]).VALOR_UNITARIO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_CNPJ.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_NOME.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_ENDERECO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_COMPLEMENTO.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_CEP.asString + ';' +
                    TPEDIDO(P.Itens[I]).DEST_MUNICIPIO.asString + ';;;I');
                end;
              end;
            end;
          end;

          P.ID.Value         := TPEDIDO(P.Itens[I]).ID.Value;
          P.ID_ARQUIVO.Value := BuscaNumeroArquivo(Con, 2);
          P.STATUS.Value     := 2;
          P.DATA_ENVIO.Value := Now;
          P.Update;

          if Lista.Count > 0 then begin
            if not DirectoryExists(DirArquivosFTP) then
              ForceDirectories(DirArquivosFTP);
            Lista.SaveToFile(DirArquivosFTP + 'SC' + P.ID_ARQUIVO.asString + '.txt');
          end;
        end;
      end;
      Con.Commit;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Pedido : ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(P);
    freeAndNil(T);
    Freeandnil(Con);
    FreeAndNil(Lista);
  end;
end;

function TfrmPrincipal.EnviaPedidosFaturados: Boolean;
var
  Con     : TFWConnection;
  P       : TPEDIDO;
  PI      : TPEDIDOITENS;
  PR      : TPRODUTO;
  T       : TTRANSPORTADORA;
  PN      : TPEDIDO_NOTAFISCAL;
  Lista   : TStringList;
  I,
  J       : Integer;
begin
  Con    := TFWConnection.Create;
  P      := TPEDIDO.Create(Con);
  PN     := TPEDIDO_NOTAFISCAL.Create(Con);
  PI     := TPEDIDOITENS.Create(Con);
  PR     := TPRODUTO.Create(Con);
  T      := TTRANSPORTADORA.Create(Con);
  Lista  := TStringList.Create;

  try
    Con.StartTransaction;
    try
      PN.SelectList('status = 0');
      if PN.Count > 0 then begin
        for I := 0 to Pred(PN.Count) do begin
          Lista.Clear;
          P.SelectList('id = ' + TPEDIDO_NOTAFISCAL(PN.Itens[I]).ID_PEDIDO.asSQL);
          if P.Count > 0 then begin
            T.SelectList('id = ' + TPEDIDO(P.Itens[0]).ID_TRANSPORTADORA.asString);
            if T.Count > 0 then begin
              PI.SelectList('id_pedido = ' + TPEDIDO(P.Itens[0]).ID.asString);
              if PI.Count > 0 then begin
                for J := 0 to Pred(PI.Count) do begin
                  PR.SelectList('id = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
                  if PR.Count > 0 then begin
                    Lista.Add(TTRANSPORTADORA(T.Itens[0]).CNPJ.asString + ';' +
                      TPEDIDO(P.Itens[0]).PEDIDO.asString + ';' +
                      TPEDIDO(P.Itens[0]).VIAGEM.asString + ';' +
                      TPEDIDO(P.Itens[0]).SEQUENCIA.asString + ';' +
                      TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString + ';' +
                      TPRODUTO(PR.Itens[0]).UNIDADEDEMEDIDA.asString + ';' +
                      TPEDIDOITENS(PI.Itens[J]).QUANTIDADE.asString + ';' +
                      TPEDIDOITENS(PI.Itens[J]).VALOR_UNITARIO.asString + ';' +
                      TPEDIDO(P.Itens[0]).DEST_CNPJ.asString + ';' +
                      TPEDIDO(P.Itens[0]).DEST_NOME.asString + ';' +
                      TPEDIDO(P.Itens[0]).DEST_ENDERECO.asString + ';' +
                      TPEDIDO(P.Itens[0]).DEST_COMPLEMENTO.asString + ';' +
                      TPEDIDO(P.Itens[0]).DEST_CEP.asString + ';' +
                      TPEDIDO(P.Itens[0]).DEST_MUNICIPIO.asString + ';' +
                      TPEDIDO_NOTAFISCAL(PN.Itens[I]).NUMERO_DOCUMENTO.asString + ';' +
                      TPEDIDO_NOTAFISCAL(PN.Itens[I]).SERIE_DOCUMENTO.asString + ';A');
                  end;
                end;
              end;
            end;
          end;

          PN.ID.Value         := TPEDIDO_NOTAFISCAL(PN.Itens[I]).ID.Value;
          PN.ID_ARQUIVO.Value := BuscaNumeroArquivo(Con, 2);
          PN.STATUS.Value     := 1;
          PN.DATA_ENVIO.Value := Now;
          PN.Update;

          if Lista.Count > 0 then begin
            if not DirectoryExists(DirArquivosFTP) then
              ForceDirectories(DirArquivosFTP);
            Lista.SaveToFile(DirArquivosFTP + 'SC' + PN.ID_ARQUIVO.asString + '.txt');
          end;
        end;
      end;
      Con.Commit;
    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Pedido : ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(P);
    FreeAndNil(PN);
    freeAndNil(T);
    Freeandnil(Con);
    FreeAndNil(Lista);
  end;
end;

function TfrmPrincipal.EnviaProdutos: Boolean;
var
  Con     : TFWConnection;
  PR      : TPRODUTO;
  I,
  AFTP,
  Quant   : Integer;
  Lista   : TStringList;
  Teste   : Boolean;
begin
  Con := TFWConnection.Create;
  PR  := TPRODUTO.Create(Con);

  try
    Con.StartTransaction;
    try
      Teste := True;
      while Teste do begin
        SaveLog('while');
        PR.SelectList('status = 0');
        SaveLog('select');
        Quant        := 1000;

        if PR.Count < Quant then begin
          Quant      := PR.Count;
          Teste      := False;
        end;

        if PR.Count > 0 then begin
          SaveLog('Tem produtos para exportar');
          AFTP         := BuscaNumeroArquivo(Con, 0);
          SaveLog('Buscou um codigo para o FTP');
          Lista        := TStringList.Create;
          SaveLog('Passou do create');
          try
            for I := 0 to Pred(Quant) do begin
              Lista.Add(TPRODUTO(PR.Itens[I]).CODIGOPRODUTO.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAO.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAOREDUZIDA.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAOSKU.asString + ';' +
                TPRODUTO(PR.Itens[I]).DESCRICAOREDUZIDASKU.asString + ';' +
                TPRODUTO(PR.Itens[I]).QUANTIDADEPOREMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).UNIDADEDEMEDIDA.asString + ';' +
                TPRODUTO(PR.Itens[I]).CODIGOBARRAS.asString + ';' +
                TPRODUTO(PR.Itens[I]).ALTURAEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).COMPRIMENTOEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).LARGURAEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).PESOEMBALAGEM.asString + ';' +
                TPRODUTO(PR.Itens[I]).PESOPRODUTO.asString + ';' +
                TPRODUTO(PR.Itens[I]).QUANTIDADECAIXASALTURAPALET.asString + ';' +
                TPRODUTO(PR.Itens[I]).QUANTIDADESCAIXASLASTROPALET.asString + ';' +
                TPRODUTO(PR.Itens[I]).ALIQUOTAIPI.asString + ';' +
                TPRODUTO(PR.Itens[I]).CLASSIFICACAOFISCAL.asString + ';' +
                TPRODUTO(PR.Itens[I]).CATEGORIAPRODUTO.asString + ';'
              );

              PR.ID.Value           := TPRODUTO(PR.Itens[I]).ID.Value;
              PR.STATUS.Value       := 1;
              PR.ID_ARQUIVO.Value   := AFTP;
              PR.Update;
            end;
            SaveLog('Passou do for');
            if Lista.Count > 0 then begin
              SaveLog('Tem algo na lista tio');
              Lista.SaveToFile(DirArquivosFTP + 'PROD' + IntToStr(AFTP) + '.txt');
              SaveLog('passou do salvar');
            end;
          finally
            FreeAndNil(Lista);
          end;
        end;
      end;
      Con.Commit;

    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Enviar Produtos : ' + E.Message);
      end;
    end;
  finally
    SaveLog('free');
    FreeAndNil(PR);
    FreeAndNil(Con);
  end;
end;
function TfrmPrincipal.CopiarPDF(Data : TDate; Documento : Integer; Serie : String; ID : Integer) : Boolean;
Var
  FWC         : TFWConnection;
  PNF         : TPEDIDO_NOTAFISCAL;
  NomeArqPDF,
  DirArqPDF   : String;
  I           : Integer;
  SR          : TSearchRec;
begin

  Result      := False;
  NomeArqPDF  := StrZero(Serie, 3);
  NomeArqPDF  := NomeArqPDF + StrZero(IntToStr(Documento), 9);
  DirArqPDF   := CONFIG_LOCAL.DIR_ARQ_PDF;

  if DirectoryExists(DirArqPDF) then begin

    if FindFirst(DirArqPDF + '*.pdf', faAnyFile, SR) = 0 then begin
      try
        repeat
          if (SR.Attr <> faDirectory) then begin
            if (Pos('-nfe.pdf', AnsiLowerCase(SR.Name)) > 0) then begin //pois tem arquivos de processamento
              if (Pos(NomeArqPDF, SR.Name) > 0) then begin

                //Copiando o PDF
                SaveLog('Copiando PDF, Origem.: ' + DirArqPDF + SR.Name + ' Destino.: ' + DirArquivosFTP + SR.Name);
                CopyFile(PWideChar(DirArqPDF + SR.Name), PWideChar(DirArquivosFTP + SR.Name), True);
                SaveLog('PDF Copiado com Sucesso!');

                FWC := TFWConnection.Create;
                PNF := TPEDIDO_NOTAFISCAL.Create(FWC);
                try
                  try
                    PNF.ID.Value              := ID;
                    PNF.STATUS.Value          := 2;//PDF Enviado
                    PNF.NOMEARQUIVOPDF.Value  := SR.Name;
                    PNF.Update;

                    FWC.Commit;

                    SaveLog('Nome do PDF Salvo com Sucesso no BD!');

                    Result := True;
                    Break;//Concluiu com sucesso para o For
                  except
                    on E : Exception do begin
                      FWC.Rollback;
                      SaveLog('Erro ao Salvar Nome do Arquivo PDF para ID.: ' + IntToStr(ID) + ' ' + E.Message);
                    end;
                  end;
                finally
                  FreeAndNil(PNF);
                  FreeAndNil(FWC);
                end;
              end;
            end;
          end;
        until FindNext(SR) <> 0;
      finally
        FindClose(SR);
      end;
    end;
  end;
end;

function TfrmPrincipal.EnviaPDF: Boolean;
type
  TArArqPDF = record
    ID  : Integer;
    DATA_IMPORTACAO : TDate;
    NUMERO_DOCUMENTO : Integer;
    SERIE_DOCUMENTO : string;
  end;
var
  Con     : TFWConnection;
  PNF     : TPEDIDO_NOTAFISCAL;
  I       : Integer;
  ArArqPDF: array of TArArqPDF;
begin

  Con := TFWConnection.Create;
  PNF := TPEDIDO_NOTAFISCAL.Create(Con);

  SetLength(ArArqPDF, 0);
  try
    try
      SaveLog('Consultando Notas');
      PNF.SelectList('status = 1');

      if PNF.Count > 0 then begin
        for I := 0 to PNF.Count -1 do begin
          SetLength(ArArqPDF, Length(ArArqPDF) + 1);
          ArArqPDF[High(ArArqPDF)].ID               := TPEDIDO_NOTAFISCAL(PNF.Itens[I]).ID.Value;
          ArArqPDF[High(ArArqPDF)].DATA_IMPORTACAO  := TPEDIDO_NOTAFISCAL(PNF.Itens[I]).DATA_IMPORTACAO.Value;
          ArArqPDF[High(ArArqPDF)].NUMERO_DOCUMENTO := TPEDIDO_NOTAFISCAL(PNF.Itens[I]).NUMERO_DOCUMENTO.Value;
          ArArqPDF[High(ArArqPDF)].SERIE_DOCUMENTO  := TPEDIDO_NOTAFISCAL(PNF.Itens[I]).SERIE_DOCUMENTO.Value;
        end;
      end;

    except
      on E : Exception do begin
        Con.Rollback;
        SaveLog('Erro ao Carregar array de PDF : ' + E.Message);
      end;
    end;
  finally
    FreeAndNil(PNF);
    FreeAndNil(Con);
  end;

  SaveLog('Iniciando Copia de Arquivos');

  SaveLog('Encontrou ' + IntToStr(Length(ArArqPDF)) + ' Notas para eviar o PDF');
  for I := Low(ArArqPDF) to High(ArArqPDF) do begin
    if not CopiarPDF(ArArqPDF[I].DATA_IMPORTACAO, ArArqPDF[I].NUMERO_DOCUMENTO, ArArqPDF[I].SERIE_DOCUMENTO, ArArqPDF[I].ID) then
      SaveLog('Não Encontrado PDF para Doc.: ' + IntToStr(ArArqPDF[I].NUMERO_DOCUMENTO) + ' Serie.: ' + ArArqPDF[I].SERIE_DOCUMENTO);
    Application.ProcessMessages;
  end;

end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
var
 Con : TFWConnection;
begin
  CONFIG_LOCAL.DirLog  := GetCurrentDir + '\Logs\';
  SaveLog('Serviço iniciado!');
  try

    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';

    CarregarConexaoBD;

    CarregarConfigLocal;

    CON   := TFWConnection.Create;
    try
      SaveLog('Conectou no Banco de dados!');
    finally
      FreeAndNil(CON);
    end;
  except
    on E : Exception do
      SaveLog('Erro ao iniciar Aplicativo: ' + E.Message);
  end;
end;

procedure TfrmPrincipal.IniciarPararLeitura;
begin
  if btIniciar.Caption = 'Iniciar Leitura' then begin
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(1, btIniciar.Glyph);
    btIniciar.Caption := 'Parar Leitura';
    Timer1.Enabled    := True;
  end else begin
    btIniciar.Glyph := nil;
    ImageList1.GetBitmap(0, btIniciar.Glyph);
    btIniciar.Caption := 'Iniciar Leitura';
    Timer1.Enabled    := False;
  end;
end;

procedure TfrmPrincipal.SaveLog(Texto: String);
var
  ArquivoLog : TextFile;
  Caminho : string;
begin

  Caminho := CONFIG_LOCAL.DirLog + FormatDateTime('yyyymmdd', Now) + '.txt';

  if not DirectoryExists(CONFIG_LOCAL.DirLog) then
    ForceDirectories(CONFIG_LOCAL.DirLog);

  AssignFile(ArquivoLog, Caminho);

  if FileExists(Caminho) then
    Append(ArquivoLog)
  else
    Rewrite(ArquivoLog);

  try
    Writeln(ArquivoLog, DateTimeToStr(Now) + ' ' + Texto)
  finally
    CloseFile(ArquivoLog);
  end;
end;

procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
var
  ConexaoFTP : TConexaoFTP;
begin
  Timer1.Enabled := False;
  SaveLog('Início do Execute do Timmer');
  try
    try
      SaveLog('Enviar Produtos');
      EnviaProdutos;
      SaveLog('Enviar NFs');
      EnviaNotasFiscais;
      SaveLog('Enviar Pedidos');
      EnviaPedidos;
      SaveLog('Enviar Pedidos Faturados');
      EnviaPedidosFaturados;
      SaveLog('Enviar PDF');
      EnviaPDF;

      SaveLog('Conectar com FTP');
      ConexaoFTP := TConexaoFTP.Create;
      try
        if ConexaoFTP.Connected then begin
          SaveLog('Enviar Produtos para o FTP!');
          ConexaoFTP.EnviarProdutos;
          SaveLog('Enviar Notas Fiscais de Entrada para o FTP!');
          ConexaoFTP.EnviarNotasFiscais;
          SaveLog('Enviar Pedidos para o FTP!');
          ConexaoFTP.EnviarPedidos;
          SaveLog('Enviar PDF para o FTP!');
          ConexaoFTP.EnviarPDF;
          SaveLog('Buscar Confirmação de NFs - CONF para o FTP!');
          ConexaoFTP.BuscaCONF;
          SaveLog('Buscar Confirmação de Mercadorias - MDD para o FTP!');
          ConexaoFTP.BuscaMDD;
          SaveLog('Limpar conexao FTP');
        end;
      finally
        FreeAndNil(ConexaoFTP);
      end;

      SaveLog('Buscar CONF');
      BuscaCONF;
      SaveLog('Buscar MDD');
      BuscaMDD;
      SaveLog('Buscou arquivos!');
    except
     on E : Exception do
       SaveLog('Ocorreu algum erro na execução do processo no Timmer! Erro: ' + E.Message);
    end;
  finally
//    IniciarPararLeitura;
    SaveLog('Final do Execute do Timmer');
    Timer1.Enabled := True;
  end;
end;

end.
