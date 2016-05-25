unit uBeanPedido_Cancelamento;

interface
uses
  uFWPersistence,
  uDomains;

type
  TPEDIDO_CANCELAMENTO = Class(TFWPersistence)
  private
    FMOTIVO: TFieldString;
    FID_PEDIDO: TFieldInteger;
    FID: TFieldInteger;
    FDATA_HORA: TFieldDateTime;
    FID_USUARIO: TFieldInteger;
    procedure SetDATA_HORA(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_PEDIDO(const Value: TFieldInteger);
    procedure SetID_USUARIO(const Value: TFieldInteger);
    procedure SetMOTIVO(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID         : TFieldInteger   read FID          write SetID;
    property ID_PEDIDO  : TFieldInteger   read FID_PEDIDO   write SetID_PEDIDO;
    property ID_USUARIO : TFieldInteger   read FID_USUARIO  write SetID_USUARIO;
    property DATA_HORA  : TFieldDateTime  read FDATA_HORA   write SetDATA_HORA;
    property MOTIVO     : TFieldString    read FMOTIVO      write SetMOTIVO;
  End;

implementation

{ TPEDIDO_CANCELAMENTO }

procedure TPEDIDO_CANCELAMENTO.InitInstance;
begin
  inherited;
  ID.isPK               := True;

  ID_PEDIDO.isNotNull   := True;
  ID_USUARIO.isNotNull  := True;
  DATA_HORA.isNotNull   := True;
  MOTIVO.isNotNull      := True;

  MOTIVO.Size           := 255;
end;

procedure TPEDIDO_CANCELAMENTO.SetDATA_HORA(const Value: TFieldDateTime);
begin
  FDATA_HORA := Value;
end;

procedure TPEDIDO_CANCELAMENTO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPEDIDO_CANCELAMENTO.SetID_PEDIDO(const Value: TFieldInteger);
begin
  FID_PEDIDO := Value;
end;

procedure TPEDIDO_CANCELAMENTO.SetID_USUARIO(const Value: TFieldInteger);
begin
  FID_USUARIO := Value;
end;

procedure TPEDIDO_CANCELAMENTO.SetMOTIVO(const Value: TFieldString);
begin
  FMOTIVO := Value;
end;

end.
