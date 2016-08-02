unit uFuncoesWSFirst;

interface

uses
  System.JSON,
  System.SysUtils;

procedure EnviarProdutos;
procedure EnviarPedidos;
procedure EnviarNFEntrada;

procedure BuscarMDD;

implementation

uses
  uConstantes,
  uMensagem,
  uFuncoes,
  uFWConnection,
  uBeanProduto,
  uConexaoFirst,
  uBeanRequisicoesFirst,
  uBeanReq_Itens,
  uBeanPedido,
  uBeanPedidoItens,
  uBeanTransportadoras, uBeanNotaFiscal, uBeanNotaFiscalItens;

procedure EnviarProdutos;
var
  FWC          : TFWConnection;
  P           : TPRODUTO;
  I           : Integer;
  JSONArray   : TJSONArray;
  jso         : TJSONObject;
  ConexaoFirst: TConexaoFirst;

  REQ         : TREQUISICOESFIRST;
  RD          : TREQ_ITENS;
  Cod_Retorno : Integer;
  Dsc_Retorno : string;
begin

  FWC         := TFWConnection.Create;
  P           := TPRODUTO.Create(FWC);
  REQ         := TREQUISICOESFIRST.Create(FWC);
  RD          := TREQ_ITENS.Create(FWC);
  JSONArray   := TJSONArray.Create;
  ConexaoFirst:= TConexaoFirst.Create;

  try

    if TOKEN_WS.STATUS_CODE = 200 then begin

      repeat

        FWC.StartTransaction;

        try
          P.SelectList('status = 0', 'codigoproduto limit 100');
          if P.Count > 0 then begin
            REQ.ID.isNull             := True;
            REQ.DATAHORA.Value        := Now;
            REQ.COD_STATUS.Value      := 900;
            REQ.DSC_STATUS.Value      := 'Criando dados da Requisição';
            REQ.TIPOREQUISICAO.Value  := TIPOREQUISICAOFIRST[rfProd];
            REQ.Insert;

            for I := 0 to Pred(P.Count) do begin
              jso := TJSONObject.Create;

              jso.AddPair(TJSONPair.Create('item_deposit', TPRODUTO(P.Itens[I]).CODIGOPRODUTO.asString));
              jso.AddPair(TJSONPair.Create('den_item', TPRODUTO(P.Itens[I]).DESCRICAO.asString));
              jso.AddPair(TJSONPair.Create('den_item_reduz', TPRODUTO(P.Itens[I]).DESCRICAOREDUZIDA.asString));
              jso.AddPair(TJSONPair.Create('des_sku', TPRODUTO(P.Itens[I]).DESCRICAOSKU.asString));
              jso.AddPair(TJSONPair.Create('des_reduz_sku', TPRODUTO(P.Itens[I]).DESCRICAOREDUZIDASKU.asString));
              jso.AddPair(TJSONPair.Create('qtd_item', TJSONNumber.Create(TPRODUTO(P.Itens[I]).QUANTIDADEPOREMBALAGEM.Value)));
              jso.AddPair(TJSONPair.Create('cod_unid_med', TPRODUTO(P.Itens[I]).UNIDADEDEMEDIDA.asString));
              jso.AddPair(TJSONPair.Create('cod_barras', TPRODUTO(P.Itens[I]).CODIGOBARRAS.asString));
              jso.AddPair(TJSONPair.Create('altura', TJSONNumber.Create(TPRODUTO(P.Itens[I]).ALTURAEMBALAGEM.Value)));
              jso.AddPair(TJSONPair.Create('comprimento', TJSONNumber.Create(TPRODUTO(P.Itens[I]).COMPRIMENTOEMBALAGEM.Value)));
              jso.AddPair(TJSONPair.Create('largura', TJSONNumber.Create(TPRODUTO(P.Itens[I]).LARGURAEMBALAGEM.Value)));
              jso.AddPair(TJSONPair.Create('peso_bruto', TJSONNumber.Create(TPRODUTO(P.Itens[I]).PESOEMBALAGEM.Value)));
              jso.AddPair(TJSONPair.Create('pes_unit', TJSONNumber.Create(TPRODUTO(P.Itens[I]).PESOPRODUTO.Value)));
              jso.AddPair(TJSONPair.Create('qtd_caixa_altura', TPRODUTO(P.Itens[I]).QUANTIDADECAIXASALTURAPALET.asString));
              jso.AddPair(TJSONPair.Create('qtd_caixa_lastro', TPRODUTO(P.Itens[I]).QUANTIDADESCAIXASLASTROPALET.asString));
              jso.AddPair(TJSONPair.Create('pct_ipi', '0'));
              jso.AddPair(TJSONPair.Create('cod_cla_fisc', '0'));
              jso.AddPair(TJSONPair.Create('cat_item', '1'));

              JSONArray.Add(jso);

              RD.ID.isNull            := True;
              RD.ID_REQUISICOES.Value := REQ.ID.Value;
              RD.ID_DADOS.Value       := TPRODUTO(P.Itens[I]).ID.Value;
              RD.Insert;
            end;

            ConexaoFirst.CadastrarProdutos(JSONArray, Cod_Retorno, Dsc_Retorno);
            REQ.COD_STATUS.Value := Cod_Retorno;
            REQ.DSC_STATUS.Value := Dsc_Retorno;
            REQ.Update;

            if REQ.COD_STATUS.Value = 200 then begin
              for I := 0 to Pred(P.Count) do begin
                P.ID.Value     := TPRODUTO(P.Itens[I]).ID.Value;
                P.STATUS.Value := 1;
                P.Update;
              end;
            end else begin
              SaveLog('Problema ao EnviarProdutos, Retorno.: ' + IntToStr(Cod_Retorno) + ' - ' + Dsc_Retorno);
              Break;
            end;
          end;

          FWC.Commit;

        except
          on E : Exception do begin
            FWC.Rollback;
            SaveLog('Erro no Procedimento EnviarProdutos, ' + E.Message);
            Exit;
          end;
        end;
      until P.Count = 0;

    end else
      SaveLog('TOKEN Inválido para Enviar Produtos, Status = ' + IntToStr(TOKEN_WS.STATUS_CODE));

  finally
    FreeAndNil(JSONArray);
    FreeAndNil(P);
    FreeAndNil(REQ);
    FreeAndNil(RD);
    FreeAndNil(FWC);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure EnviarPedidos;
var
  FWC         : TFWConnection;
  PED         : TPEDIDO;
  PI          : TPEDIDOITENS;
  T           : TTRANSPORTADORA;
  PR          : TPRODUTO;
  REQ         : TREQUISICOESFIRST;
  RD          : TREQ_ITENS;
  JSONArray   : TJSONArray;
  jso         : TJSONObject;
  ConexaoFirst: TConexaoFirst;
  I, J        : Integer;
  Cod_Retorno : Integer;
  Dsc_Retorno : string;
begin

  FWC           := TFWConnection.Create;
  REQ           := TREQUISICOESFIRST.Create(FWC);
  RD            := TREQ_ITENS.Create(FWC);
  PED           := TPEDIDO.Create(FWC);
  PI            := TPEDIDOITENS.Create(FWC);
  PR            := TPRODUTO.Create(FWC);
  T             := TTRANSPORTADORA.Create(FWC);
  JSONArray     := TJSONArray.Create;
  ConexaoFirst  := TConexaoFirst.Create;

  try

    if TOKEN_WS.STATUS_CODE = 200 then begin

      FWC.StartTransaction;

      try

        PED.SelectList('status = 1', 'id limit 100');

        if PED.Count > 0 then begin

          REQ.ID.isNull             := True;
          REQ.DATAHORA.Value        := Now;
          REQ.COD_STATUS.Value      := 900;
          REQ.DSC_STATUS.Value      := 'Criando dados da Requisição';
          REQ.TIPOREQUISICAO.Value  := TIPOREQUISICAOFIRST[rfSc];
          REQ.Insert;

          for I := 0 to Pred(PED.Count) do begin

            PI.SelectList('id_pedido = ' + TPEDIDO(PED.Itens[I]).ID.asString);
            for J := 0 to Pred(PI.Count) do begin

              PR.SelectList('id = ' + TPEDIDOITENS(PI.Itens[J]).ID_PRODUTO.asString);
              T.SelectList('id = ' + TPEDIDO(PED.Itens[I]).ID_TRANSPORTADORA.asString);

              if (PR.Count > 0) and (T.Count > 0) then begin

                jso := TJSONObject.Create;

                jso.AddPair(TJSONPair.Create('cnpj_tran', TTRANSPORTADORA(T.Itens[0]).CNPJ.asString));
                jso.AddPair(TJSONPair.Create('pedido', TPEDIDO(PED.Itens[I]).PEDIDO.asString));
                jso.AddPair(TJSONPair.Create('num_viagem', TPEDIDO(PED.Itens[I]).VIAGEM.asString));
                jso.AddPair(TJSONPair.Create('sequencial_embarq', TPEDIDO(PED.Itens[I]).SEQUENCIA.asString));
                jso.AddPair(TJSONPair.Create('item', TPRODUTO(PR.Itens[0]).CODIGOPRODUTO.asString));
                jso.AddPair(TJSONPair.Create('unid_medida', TPRODUTO(PR.Itens[0]).UNIDADEDEMEDIDA.asString));
                jso.AddPair(TJSONPair.Create('qtd_original_docum', TJSONNumber.Create(TPEDIDOITENS(PI.Itens[J]).QUANTIDADE.Value)));
                jso.AddPair(TJSONPair.Create('val_unit', TJSONNumber.Create(TPEDIDOITENS(PI.Itens[J]).VALOR_UNITARIO.Value)));
                jso.AddPair(TJSONPair.Create('cnpj_cpf_destinat', TPEDIDO(PED.Itens[I]).DEST_CNPJ.asString));
                jso.AddPair(TJSONPair.Create('nom_destinat', TPEDIDO(PED.Itens[I]).DEST_NOME.asString));
                jso.AddPair(TJSONPair.Create('ende_dest', TPEDIDO(PED.Itens[I]).DEST_ENDERECO.asString));
                jso.AddPair(TJSONPair.Create('compl_endereco', TPEDIDO(PED.Itens[I]).DEST_COMPLEMENTO.asString));
                jso.AddPair(TJSONPair.Create('cep', TPEDIDO(PED.Itens[I]).DEST_CEP.asString));

                JSONArray.Add(jso);

                RD.ID.isNull            := True;
                RD.ID_REQUISICOES.Value := REQ.ID.Value;
                RD.ID_DADOS.Value       := TPEDIDO(PED.Itens[I]).ID.Value;
                RD.Insert;
              end;
            end;
          end;

          ConexaoFirst.EnviarPedidos(JSONArray, Cod_Retorno, Dsc_Retorno);

          REQ.COD_STATUS.Value := Cod_Retorno;
          REQ.DSC_STATUS.Value := Dsc_Retorno;
          REQ.Update;

          if REQ.COD_STATUS.Value = 200 then begin
            for I := 0 to Pred(PED.Count) do begin
              PED.ID.Value     := TPEDIDO(PED.Itens[I]).ID.Value;
              PED.STATUS.Value := 2;
              PED.Update;
            end;
          end else
            SaveLog('Problema ao EnviarPedidos, Retorno.: ' + IntToStr(Cod_Retorno) + ' - ' + Dsc_Retorno);
        end;

        FWC.Commit;

      except
        on E : Exception do begin
          FWC.Rollback;
          SaveLog('Erro no Procedimento EnviarPedidos, ' + E.Message);
        end;
      end;
    end else
      SaveLog('TOKEN Inválido para Enviar Pedidos, Status = ' + IntToStr(TOKEN_WS.STATUS_CODE));

  finally
    FreeAndNil(JSONArray);
    FreeAndNil(PED);
    FreeAndNil(PR);
    FreeAndNil(PI);
    FreeAndNil(T);
    FreeAndNil(REQ);
    FreeAndNil(RD);
    FreeAndNil(FWC);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure EnviarNFEntrada;
var
  FWC         : TFWConnection;
  NF          : TNOTAFISCAL;
  NFI         : TNOTAFISCALITENS;
  P           : TPRODUTO;
  JSONArray   : TJSONArray;
  jso         : TJSONObject;
  ConexaoFirst: TConexaoFirst;
  I, J        : Integer;
  REQ         : TREQUISICOESFIRST;
  RD          : TREQ_ITENS;
  Cod_Retorno : Integer;
  Dsc_Retorno : string;
begin

  FWC           := TFWConnection.Create;
  NF            := TNOTAFISCAL.Create(FWC);
  NFI           := TNOTAFISCALITENS.Create(FWC);
  P             := TPRODUTO.Create(FWC);
  REQ           := TREQUISICOESFIRST.Create(FWC);
  RD            := TREQ_ITENS.Create(FWC);
  JSONArray     := TJSONArray.Create;
  ConexaoFirst  := TConexaoFirst.Create;

  try

    if TOKEN_WS.STATUS_CODE = 200 then begin

      FWC.StartTransaction;

      try

        NF.SelectList('status = 0', 'id limit 100');
        if NF.Count > 0 then begin

          REQ.ID.isNull             := True;
          REQ.DATAHORA.Value        := Now;
          REQ.COD_STATUS.Value      := 900;
          REQ.DSC_STATUS.Value      := 'Criando dados da Requisição';
          REQ.TIPOREQUISICAO.Value  := TIPOREQUISICAOFIRST[rfArmz];
          REQ.Insert;

          for I := 0 to Pred(NF.Count) do begin

            NFI.SelectList('id_notafiscal = ' + TNOTAFISCAL(NF.Itens[I]).ID.asString);
            for J := 0 to Pred(NFI.Count) do begin

              P.SelectList('id = ' + TNOTAFISCALITENS(NFI.Itens[J]).ID_PRODUTO.asString);
              if P.Count > 0 then begin

                jso := TJSONObject.Create;

                jso.AddPair(TJSONPair.Create('num_nf', TNOTAFISCAL(NF.Itens[I]).DOCUMENTO.asString));
                jso.AddPair(TJSONPair.Create('ser_nf', TNOTAFISCAL(NF.Itens[I]).SERIE.asString));
                jso.AddPair(TJSONPair.Create('dat_emis_nf', DateTimeToStrFirst(TNOTAFISCAL(NF.Itens[I]).DATAEMISSAO.Value)));
                jso.AddPair(TJSONPair.Create('num_seq', TNOTAFISCALITENS(NFI.Itens[J]).SEQUENCIA.asString));
                jso.AddPair(TJSONPair.Create('cod_item', TPRODUTO(P.Itens[0]).CODIGOPRODUTO.asString));
                jso.AddPair(TJSONPair.Create('qtd_declarad_nf', TJSONNumber.Create(TNOTAFISCALITENS(NFI.Itens[J]).QUANTIDADE.Value)));
                jso.AddPair(TJSONPair.Create('pre_unit_nf', TJSONNumber.Create(TNOTAFISCALITENS(NFI.Itens[J]).VALORUNITARIO.Value)));
                jso.AddPair(TJSONPair.Create('val_liquido_item', TJSONNumber.Create(TNOTAFISCALITENS(NFI.Itens[J]).VALORTOTAL.Value)));
                jso.AddPair(TJSONPair.Create('val_tot_nf_d', TJSONNumber.Create(TNOTAFISCAL(NF.Itens[I]).VALORTOTAL.Value)));

                JSONArray.Add(jso);

                RD.ID.isNull            := True;
                RD.ID_REQUISICOES.Value := REQ.ID.Value;
                RD.ID_DADOS.Value       := TNOTAFISCAL(NF.Itens[I]).ID.Value;
                RD.Insert;
              end;
            end;
          end;

          ConexaoFirst.NFEntrada(JSONArray, Cod_Retorno, Dsc_Retorno);

          REQ.COD_STATUS.Value := Cod_Retorno;
          REQ.DSC_STATUS.Value := Dsc_Retorno;
          REQ.Update;

          if REQ.COD_STATUS.Value = 200 then begin
            for I := 0 to Pred(NF.Count) do begin
              NF.ID.Value     := TNOTAFISCAL(NF.Itens[I]).ID.Value;
              NF.STATUS.Value := 1;
              NF.Update;
            end;
          end else
            SaveLog('Problema ao EnviarNFEntrada, Retorno.: ' + IntToStr(Cod_Retorno) + ' - ' + Dsc_Retorno);

        end;

        FWC.Commit;

      except
        on E : Exception do begin
          FWC.Rollback;
          SaveLog('Erro no Procedimento EnviarNFEntrada, ' + E.Message);
        end;
      end;
    end else
      SaveLog('TOKEN Inválido para Enviar NFEntrada, Status = ' + IntToStr(TOKEN_WS.STATUS_CODE));
  finally
    FreeAndNil(JSONArray);
    FreeAndNil(P);
    FreeAndNil(NF);
    FreeAndNil(NFI);
    FreeAndNil(REQ);
    FreeAndNil(RD);
    FreeAndNil(FWC);
    FreeAndNil(ConexaoFirst);
  end;
end;

procedure BuscarMDD;
var
  ConexaoFirst: TConexaoFirst;

begin

  ConexaoFirst  := TConexaoFirst.Create;

  try

    if TOKEN_WS.STATUS_CODE = 200 then begin

      ConexaoFirst.GetMDD;

    end else
      SaveLog('TOKEN Inválido para Enviar Pedidos, Status = ' + IntToStr(TOKEN_WS.STATUS_CODE));

  finally
    FreeAndNil(ConexaoFirst);
  end;
end;

end.
