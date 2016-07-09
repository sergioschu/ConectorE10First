unit uBeanPedido_Embarque;

interface

uses uFWPersistence, uDomains;

type
  TPEDIDO_EMBARQUE = Class(TFWPersistence)
  private
    FDATA_INCLUSAO: TFieldDateTime;
    FID_TRANSPORTADORA: TFieldInteger;
    FID_PEDIDO: TFieldInteger;
    FID: TFieldInteger;
    FDATA_EMBARQUE: TFieldDateTime;
    procedure SetDATA_EMBARQUE(const Value: TFieldDateTime);
    procedure SetDATA_INCLUSAO(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_PEDIDO(const Value: TFieldInteger);
    procedure SetID_TRANSPORTADORA(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID                 : TFieldInteger read FID write SetID;
    property ID_PEDIDO          : TFieldInteger read FID_PEDIDO write SetID_PEDIDO;
    property DATA_INCLUSAO      : TFieldDateTime read FDATA_INCLUSAO write SetDATA_INCLUSAO;
    property DATA_EMBARQUE      : TFieldDateTime read FDATA_EMBARQUE write SetDATA_EMBARQUE;
    property ID_TRANSPORTADORA  : TFieldInteger read FID_TRANSPORTADORA write SetID_TRANSPORTADORA;
  End;

implementation

{ TPEDIDO_EMBARQUE }

procedure TPEDIDO_EMBARQUE.InitInstance;
begin
  inherited;

  FID.isPK                    := True;

  FID_PEDIDO.isNotNull        := True;
  FID_TRANSPORTADORA.isNotNull:= True;

end;

procedure TPEDIDO_EMBARQUE.SetDATA_EMBARQUE(const Value: TFieldDateTime);
begin
  FDATA_EMBARQUE := Value;
end;

procedure TPEDIDO_EMBARQUE.SetDATA_INCLUSAO(const Value: TFieldDateTime);
begin
  FDATA_INCLUSAO := Value;
end;

procedure TPEDIDO_EMBARQUE.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPEDIDO_EMBARQUE.SetID_PEDIDO(const Value: TFieldInteger);
begin
  FID_PEDIDO := Value;
end;

procedure TPEDIDO_EMBARQUE.SetID_TRANSPORTADORA(const Value: TFieldInteger);
begin
  FID_TRANSPORTADORA := Value;
end;

end.
