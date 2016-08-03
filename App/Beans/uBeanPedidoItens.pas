unit uBeanPedidoItens;

interface
uses uFWPersistence, uDomains;
type
  TPEDIDOITENS = class(TFWPersistence)
  private
    FVALOR_UNITARIO: TFieldFloat;
    FID_PRODUTO: TFieldInteger;
    FID_PEDIDO: TFieldInteger;
    FID: TFieldInteger;
    FQUANTIDADE: TFieldCurrency;
    FRECEBIDO: TFieldBoolean;
    FOBSERVACAO: TFieldString;
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_PEDIDO(const Value: TFieldInteger);
    procedure SetID_PRODUTO(const Value: TFieldInteger);
    procedure SetQUANTIDADE(const Value: TFieldCurrency);
    procedure SetVALOR_UNITARIO(const Value: TFieldFloat);
    procedure SetRECEBIDO(const Value: TFieldBoolean);
    procedure SetOBSERVACAO(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property ID_PEDIDO : TFieldInteger read FID_PEDIDO write SetID_PEDIDO;
    property ID_PRODUTO : TFieldInteger read FID_PRODUTO write SetID_PRODUTO;
    property QUANTIDADE : TFieldCurrency read FQUANTIDADE write SetQUANTIDADE;
    property VALOR_UNITARIO : TFieldFloat read FVALOR_UNITARIO write SetVALOR_UNITARIO;
    property RECEBIDO : TFieldBoolean read FRECEBIDO write SetRECEBIDO;
    property OBSERVACAO : TFieldString read FOBSERVACAO write SetOBSERVACAO;
  end;
implementation

{ TPEDIDOITENS }

procedure TPEDIDOITENS.InitInstance;
begin
  inherited;
  ID.isPK                   := True;

  ID_PEDIDO.isNotNull       := True;
  ID_PRODUTO.isNotNull      := True;
  QUANTIDADE.isNotNull      := True;
  VALOR_UNITARIO.isNotNull  := True;

  OBSERVACAO.Size           := 100;
end;

procedure TPEDIDOITENS.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPEDIDOITENS.SetID_PEDIDO(const Value: TFieldInteger);
begin
  FID_PEDIDO := Value;
end;

procedure TPEDIDOITENS.SetID_PRODUTO(const Value: TFieldInteger);
begin
  FID_PRODUTO := Value;
end;

procedure TPEDIDOITENS.SetOBSERVACAO(const Value: TFieldString);
begin
  FOBSERVACAO := Value;
end;

procedure TPEDIDOITENS.SetQUANTIDADE(const Value: TFieldCurrency);
begin
  FQUANTIDADE := Value;
end;

procedure TPEDIDOITENS.SetRECEBIDO(const Value: TFieldBoolean);
begin
  FRECEBIDO := Value;
end;

procedure TPEDIDOITENS.SetVALOR_UNITARIO(const Value: TFieldFloat);
begin
  FVALOR_UNITARIO := Value;
end;

end.
