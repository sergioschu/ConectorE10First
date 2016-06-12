unit uBeanPedido_NotaFiscal;

interface

uses
  uFWPersistence,
  uDomains;

type
  TPEDIDO_NOTAFISCAL = Class(TFWPersistence)
  private
    FDATA_ENVIO: TFieldDateTime;
    FID_PEDIDO: TFieldInteger;
    FDATA_IMPORTACAO: TFieldDateTime;
    FID: TFieldInteger;
    FSERIE_DOCUMENTO: TFieldString;
    FSTATUS: TFieldInteger;
    FNUMERO_DOCUMENTO: TFieldInteger;
    FID_ARQUIVO: TFieldInteger;
    FNOMEARQUIVOXML: TFieldString;
    procedure SetDATA_ENVIO(const Value: TFieldDateTime);
    procedure SetDATA_IMPORTACAO(const Value: TFieldDateTime);
    procedure SetID(const Value: TFieldInteger);
    procedure SetID_ARQUIVO(const Value: TFieldInteger);
    procedure SetID_PEDIDO(const Value: TFieldInteger);
    procedure SetNUMERO_DOCUMENTO(const Value: TFieldInteger);
    procedure SetSERIE_DOCUMENTO(const Value: TFieldString);
    procedure SetSTATUS(const Value: TFieldInteger);
    procedure SetNOMEARQUIVOXML(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID 				      : TFieldInteger   read FID write SetID;
    property ID_PEDIDO        : TFieldInteger   read FID_PEDIDO write SetID_PEDIDO;
    property ID_ARQUIVO       : TFieldInteger   read FID_ARQUIVO write SetID_ARQUIVO;
    property DATA_IMPORTACAO  : TFieldDateTime  read FDATA_IMPORTACAO write SetDATA_IMPORTACAO;
    property DATA_ENVIO       : TFieldDateTime  read FDATA_ENVIO write SetDATA_ENVIO;
    property NUMERO_DOCUMENTO : TFieldInteger   read FNUMERO_DOCUMENTO write SetNUMERO_DOCUMENTO;
    property SERIE_DOCUMENTO  : TFieldString    read FSERIE_DOCUMENTO write SetSERIE_DOCUMENTO;
    property STATUS           : TFieldInteger   read FSTATUS write SetSTATUS;
    property NOMEARQUIVOXML   : TFieldString read FNOMEARQUIVOXML write SetNOMEARQUIVOXML;
  End;

implementation

{ TPEDIDO_NOTAFISCAL }

procedure TPEDIDO_NOTAFISCAL.InitInstance;
begin
  inherited;
  ID.isPK                     := True;

  ID_PEDIDO.isNotNull         := True;
  ID_ARQUIVO.isNotNull        := True;
  NUMERO_DOCUMENTO.isNotNull  := True;
  SERIE_DOCUMENTO.isNotNull   := True;

  SERIE_DOCUMENTO.Size        := 3;
  NOMEARQUIVOXML.Size         := 100;
end;

procedure TPEDIDO_NOTAFISCAL.SetDATA_ENVIO(const Value: TFieldDateTime);
begin
  FDATA_ENVIO := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetDATA_IMPORTACAO(const Value: TFieldDateTime);
begin
  FDATA_IMPORTACAO := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetID_ARQUIVO(const Value: TFieldInteger);
begin
  FID_ARQUIVO := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetID_PEDIDO(const Value: TFieldInteger);
begin
  FID_PEDIDO := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetNOMEARQUIVOXML(const Value: TFieldString);
begin
  FNOMEARQUIVOXML := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetNUMERO_DOCUMENTO(const Value: TFieldInteger);
begin
  FNUMERO_DOCUMENTO := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetSERIE_DOCUMENTO(const Value: TFieldString);
begin
  FSERIE_DOCUMENTO := Value;
end;

procedure TPEDIDO_NOTAFISCAL.SetSTATUS(const Value: TFieldInteger);
begin
  FSTATUS := Value;
end;

end.
