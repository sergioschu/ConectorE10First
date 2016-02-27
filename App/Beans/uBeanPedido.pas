unit uBeanPedido;

interface
uses uFWPersistence, uDomains;
type
  TPEDIDO = Class(TFWPersistence)
  private
    FDEST_ENDERECO: TFieldString;
    FDEST_CNPJ: TFieldString;
    FVIAGEM: TFieldString;
    FPEDIDO: TFieldString;
    FTRANSP_CNPJ: TFieldString;
    FID: TFieldInteger;
    FDEST_CEP: TFieldString;
    FDEST_MUNICIPIO: TFieldString;
    FDEST_COMPLEMENTO: TFieldString;
    FDEST_NOME: TFieldString;
    FENVIADO: TFieldBoolean;
    procedure SetDEST_CEP(const Value: TFieldString);
    procedure SetDEST_CNPJ(const Value: TFieldString);
    procedure SetDEST_COMPLEMENTO(const Value: TFieldString);
    procedure SetDEST_ENDERECO(const Value: TFieldString);
    procedure SetDEST_MUNICIPIO(const Value: TFieldString);
    procedure SetDEST_NOME(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetPEDIDO(const Value: TFieldString);
    procedure SetTRANSP_CNPJ(const Value: TFieldString);
    procedure SetVIAGEM(const Value: TFieldString);
    procedure SetENVIADO(const Value: TFieldBoolean);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property PEDIDO : TFieldString read FPEDIDO write SetPEDIDO;
    property VIAGEM : TFieldString read FVIAGEM write SetVIAGEM;
    property TRANSP_CNPJ : TFieldString read FTRANSP_CNPJ write SetTRANSP_CNPJ;
    property DEST_CNPJ : TFieldString read FDEST_CNPJ write SetDEST_CNPJ;
    property DEST_NOME : TFieldString read FDEST_NOME write SetDEST_NOME;
    property DEST_ENDERECO : TFieldString read FDEST_ENDERECO write SetDEST_ENDERECO;
    property DEST_COMPLEMENTO : TFieldString read FDEST_COMPLEMENTO write SetDEST_COMPLEMENTO;
    property DEST_CEP : TFieldString read FDEST_CEP write SetDEST_CEP;
    property DEST_MUNICIPIO : TFieldString read FDEST_MUNICIPIO write SetDEST_MUNICIPIO;
    property ENVIADO : TFieldBoolean read FENVIADO write SetENVIADO;
  End;
implementation

{ TPEDIDO }

procedure TPEDIDO.InitInstance;
begin
  inherited;
  ID.isPK      := True;

  PEDIDO.isNotNull           := True;
  TRANSP_CNPJ.isNotNull      := True;
  DEST_CNPJ.isNotNull        := True;
  DEST_NOME.isNotNull        := True;
  DEST_ENDERECO.isNotNull    := True;
  DEST_COMPLEMENTO.isNotNull := True;
  DEST_CEP.isNotNull         := True;
  DEST_MUNICIPIO.isNotNull   := True;


  PEDIDO.Size                := 20;
  VIAGEM.Size                := 10;
  TRANSP_CNPJ.Size           := 19;
  DEST_CNPJ.Size             := 19;
  DEST_NOME.Size             := 60;
  DEST_ENDERECO.Size         := 36;
  DEST_COMPLEMENTO.Size      := 30;
  DEST_CEP.Size              := 9;
  DEST_MUNICIPIO.Size        := 30;
end;

procedure TPEDIDO.SetDEST_CEP(const Value: TFieldString);
begin
  FDEST_CEP := Value;
end;

procedure TPEDIDO.SetDEST_CNPJ(const Value: TFieldString);
begin
  FDEST_CNPJ := Value;
end;

procedure TPEDIDO.SetDEST_COMPLEMENTO(const Value: TFieldString);
begin
  FDEST_COMPLEMENTO := Value;
end;

procedure TPEDIDO.SetDEST_ENDERECO(const Value: TFieldString);
begin
  FDEST_ENDERECO := Value;
end;

procedure TPEDIDO.SetDEST_MUNICIPIO(const Value: TFieldString);
begin
  FDEST_MUNICIPIO := Value;
end;

procedure TPEDIDO.SetDEST_NOME(const Value: TFieldString);
begin
  FDEST_NOME := Value;
end;

procedure TPEDIDO.SetENVIADO(const Value: TFieldBoolean);
begin
  FENVIADO := Value;
end;

procedure TPEDIDO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPEDIDO.SetPEDIDO(const Value: TFieldString);
begin
  FPEDIDO := Value;
end;

procedure TPEDIDO.SetTRANSP_CNPJ(const Value: TFieldString);
begin
  FTRANSP_CNPJ := Value;
end;

procedure TPEDIDO.SetVIAGEM(const Value: TFieldString);
begin
  FVIAGEM := Value;
end;

end.
