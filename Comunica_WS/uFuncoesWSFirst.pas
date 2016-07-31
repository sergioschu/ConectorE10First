unit uFuncoesWSFirst;

interface

uses
  System.JSON,
  System.SysUtils;

procedure EnviarProdutos;

implementation

uses
  uConstantes,
  uMensagem,
  uFuncoes,
  uFWConnection,
  uBeanProduto,
  uConexaoFirst,
  uBeanRequisicoesFirst,
  uBeanReq_Itens;

procedure EnviarProdutos;
var
  FWC          : TFWConnection;
  P           : TPRODUTO;
  I           : Integer;
  JSONArray   : TJSONArray;
  JSONObject,
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
  JSONObject  := TJSONObject.Create;
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
              jso.AddPair(TJSONPair.Create('qtd_item', TPRODUTO(P.Itens[I]).QUANTIDADEPOREMBALAGEM.asString));
              jso.AddPair(TJSONPair.Create('cod_unid_med', TPRODUTO(P.Itens[I]).UNIDADEDEMEDIDA.asString));
              jso.AddPair(TJSONPair.Create('cod_barras', TPRODUTO(P.Itens[I]).CODIGOBARRAS.asString));
              jso.AddPair(TJSONPair.Create('altura', TPRODUTO(P.Itens[I]).ALTURAEMBALAGEM.asString));
              jso.AddPair(TJSONPair.Create('comprimento', TPRODUTO(P.Itens[I]).COMPRIMENTOEMBALAGEM.asString));
              jso.AddPair(TJSONPair.Create('largura', TPRODUTO(P.Itens[I]).LARGURAEMBALAGEM.asString));
              jso.AddPair(TJSONPair.Create('peso_bruto', TPRODUTO(P.Itens[I]).PESOEMBALAGEM.asString));
              jso.AddPair(TJSONPair.Create('pes_unit', TPRODUTO(P.Itens[I]).PESOPRODUTO.asString));
              jso.AddPair(TJSONPair.Create('qtd_caixa_altura', TPRODUTO(P.Itens[I]).QUANTIDADECAIXASALTURAPALET.asString));
              jso.AddPair(TJSONPair.Create('qtd_caixa_lastro', TPRODUTO(P.Itens[I]).QUANTIDADESCAIXASLASTROPALET.asString));
              jso.AddPair(TJSONPair.Create('pct_ipi', '0'));
              jso.AddPair(TJSONPair.Create('cod_cla_fisc', '0'));
              jso.AddPair(TJSONPair.Create('cat_item', '1'));

              JSONArray.Add(jso);

              JSONArray.ToString;

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

end.
