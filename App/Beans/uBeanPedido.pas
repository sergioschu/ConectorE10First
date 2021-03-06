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
    FID: TFieldInteger;
    FDEST_CEP: TFieldString;
    FDEST_MUNICIPIO: TFieldString;
    FDEST_COMPLEMENTO: TFieldString;
    FDEST_NOME: TFieldString;
    FSEQUENCIA: TFieldInteger;
    FSTATUS: TFieldInteger;
    FID_ARQUIVO: TFieldInteger;
    FID_TRANSPORTADORA: TFieldInteger;
    FID_USUARIO: TFieldInteger;
    FDATA_ENVIO: TFieldDateTime;
    FDATA_FATURADO: TFieldDateTime;
    FDATA_RECEBIDO: TfieldDateTime;
    FDATA_IMPORTACAO: TFieldDateTime;
    FVOLUMES_DOCUMENTO: TFieldInteger;
    FCODIGO_RASTREIO: TFieldString;
    procedure SetDEST_CEP(const Value: TFieldString);
    procedure SetDEST_CNPJ(const Value: TFieldString);
    procedure SetDEST_COMPLEMENTO(const Value: TFieldString);
    procedure SetDEST_ENDERECO(const Value: TFieldString);
    procedure SetDEST_MUNICIPIO(const Value: TFieldString);
    procedure SetDEST_NOME(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetPEDIDO(const Value: TFieldString);
    procedure SetVIAGEM(const Value: TFieldString);
    procedure SetSEQUENCIA(const Value: TFieldInteger);
    procedure SetSTATUS(const Value: TFieldInteger);
    procedure SetID_ARQUIVO(const Value: TFieldInteger);
    procedure SetID_TRANSPORTADORA(const Value: TFieldInteger);
    procedure SetID_USUARIO(const Value: TFieldInteger);
    procedure SetDATA_ENVIO(const Value: TFieldDateTime);
    procedure SetDATA_FATURADO(const Value: TFieldDateTime);
    procedure SetDATA_IMPORTACAO(const Value: TFieldDateTime);
    procedure SetDATA_RECEBIDO(const Value: TfieldDateTime);
    procedure SetVOLUMES_DOCUMENTO(const Value: TFieldInteger);
    procedure SetCODIGO_RASTREIO(const Value: TFieldString);
  protected
    procedure InitInstance; override;
  published
    property ID : TFieldInteger read FID write SetID;
    property PEDIDO : TFieldString read FPEDIDO write SetPEDIDO;
    property VIAGEM : TFieldString read FVIAGEM write SetVIAGEM;
    property SEQUENCIA : TFieldInteger read FSEQUENCIA write SetSEQUENCIA;
    property DEST_CNPJ : TFieldString read FDEST_CNPJ write SetDEST_CNPJ;
    property DEST_NOME : TFieldString read FDEST_NOME write SetDEST_NOME;
    property DEST_ENDERECO : TFieldString read FDEST_ENDERECO write SetDEST_ENDERECO;
    property DEST_COMPLEMENTO : TFieldString read FDEST_COMPLEMENTO write SetDEST_COMPLEMENTO;
    property DEST_CEP : TFieldString read FDEST_CEP write SetDEST_CEP;
    property DEST_MUNICIPIO : TFieldString read FDEST_MUNICIPIO write SetDEST_MUNICIPIO;
    property STATUS : TFieldInteger read FSTATUS write SetSTATUS;
    property ID_ARQUIVO : TFieldInteger read FID_ARQUIVO write SetID_ARQUIVO;
    property ID_TRANSPORTADORA : TFieldInteger read FID_TRANSPORTADORA write SetID_TRANSPORTADORA;
    property ID_USUARIO : TFieldInteger read FID_USUARIO write SetID_USUARIO;
    property DATA_IMPORTACAO : TFieldDateTime read FDATA_IMPORTACAO write SetDATA_IMPORTACAO;
    property DATA_ENVIO : TFieldDateTime read FDATA_ENVIO write SetDATA_ENVIO;
    property DATA_RECEBIDO : TfieldDateTime read FDATA_RECEBIDO write SetDATA_RECEBIDO;
    property DATA_FATURADO : TFieldDateTime read FDATA_FATURADO write SetDATA_FATURADO;
    property VOLUMES_DOCUMENTO : TFieldInteger read FVOLUMES_DOCUMENTO write SetVOLUMES_DOCUMENTO;
    property CODIGO_RASTREIO : TFieldString read FCODIGO_RASTREIO write SetCODIGO_RASTREIO;
  End;
implementation

{ TPEDIDO }

procedure TPEDIDO.InitInstance;
begin
  inherited;
  ID.isPK      := True;

  PEDIDO.isNotNull           := True;
  DEST_CNPJ.isNotNull        := True;
  DEST_NOME.isNotNull        := True;
  DEST_ENDERECO.isNotNull    := True;
  DEST_COMPLEMENTO.isNotNull := True;
  DEST_CEP.isNotNull         := True;
  DEST_MUNICIPIO.isNotNull   := True;
  ID_TRANSPORTADORA.isNotNull:= True;
  ID_USUARIO.isNotNull       := True;

  PEDIDO.Size                := 20;
  VIAGEM.Size                := 10;
  DEST_CNPJ.Size             := 19;
  DEST_NOME.Size             := 60;
  DEST_ENDERECO.Size         := 36;
  DEST_COMPLEMENTO.Size      := 30;
  DEST_CEP.Size              := 9;
  DEST_MUNICIPIO.Size        := 30;
  CODIGO_RASTREIO.Size       := 100;
end;

procedure TPEDIDO.SetCODIGO_RASTREIO(const Value: TFieldString);
begin
  FCODIGO_RASTREIO := Value;
end;

procedure TPEDIDO.SetDATA_ENVIO(const Value: TFieldDateTime);
begin
  FDATA_ENVIO := Value;
end;

procedure TPEDIDO.SetDATA_FATURADO(const Value: TFieldDateTime);
begin
  FDATA_FATURADO := Value;
end;

procedure TPEDIDO.SetDATA_IMPORTACAO(const Value: TFieldDateTime);
begin
  FDATA_IMPORTACAO := Value;
end;

procedure TPEDIDO.SetDATA_RECEBIDO(const Value: TfieldDateTime);
begin
  FDATA_RECEBIDO := Value;
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

procedure TPEDIDO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPEDIDO.SetID_ARQUIVO(const Value: TFieldInteger);
begin
  FID_ARQUIVO := Value;
end;

procedure TPEDIDO.SetID_TRANSPORTADORA(const Value: TFieldInteger);
begin
  FID_TRANSPORTADORA := Value;
end;

procedure TPEDIDO.SetID_USUARIO(const Value: TFieldInteger);
begin
  FID_USUARIO := Value;
end;

procedure TPEDIDO.SetPEDIDO(const Value: TFieldString);
begin
  FPEDIDO := Value;
end;

procedure TPEDIDO.SetSEQUENCIA(const Value: TFieldInteger);
begin
  FSEQUENCIA := Value;
end;

procedure TPEDIDO.SetSTATUS(const Value: TFieldInteger);
begin
  FSTATUS := Value;
end;

procedure TPEDIDO.SetVIAGEM(const Value: TFieldString);
begin
  FVIAGEM := Value;
end;

procedure TPEDIDO.SetVOLUMES_DOCUMENTO(const Value: TFieldInteger);
begin
  FVOLUMES_DOCUMENTO := Value;
end;

end.
