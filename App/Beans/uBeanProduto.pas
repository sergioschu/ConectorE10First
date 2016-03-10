unit uBeanProduto;

interface

uses uFWPersistence, uDomains;

type
  TPRODUTO = class(TFWPersistence)
  private
    FDESCRICAOSKU: TFieldString;
    FDESCRICAOREDUZIDA: TFieldString;
    FPESOPRODUTO: TFieldCurrency;
    FLARGURAEMBALAGEM: TFieldCurrency;
    FQUANTIDADESCAIXASLASTROPALET: TFieldInteger;
    FUNIDADEDEMEDIDA: TFieldString;
    FDESCRICAO: TFieldString;
    FCODIGOPRODUTO: TFieldString;
    FCODIGOBARRAS: TFieldString;
    FID: TFieldInteger;
    FCATEGORIAPRODUTO: TFieldInteger;
    FCOMPRIMENTOEMBALAGEM: TFieldCurrency;
    FALIQUOTAIPI: TFieldCurrency;
    FSTATUS: TFieldInteger;
    FPESOEMBALAGEM: TFieldCurrency;
    FDESCRICAOREDUZIDASKU: TFieldString;
    FCLASSIFICACAOFISCAL: TFieldString;
    FQUANTIDADECAIXASALTURAPALET: TFieldInteger;
    FQUANTIDADEPOREMBALAGEM: TFieldCurrency;
    FALTURAEMBALAGEM: TFieldCurrency;
    FID_ARQUIVO: TFieldInteger;
    procedure SetALIQUOTAIPI(const Value: TFieldCurrency);
    procedure SetALTURAEMBALAGEM(const Value: TFieldCurrency);
    procedure SetCATEGORIAPRODUTO(const Value: TFieldInteger);
    procedure SetCLASSIFICACAOFISCAL(const Value: TFieldString);
    procedure SetCODIGOBARRAS(const Value: TFieldString);
    procedure SetCODIGOPRODUTO(const Value: TFieldString);
    procedure SetCOMPRIMENTOEMBALAGEM(const Value: TFieldCurrency);
    procedure SetDESCRICAO(const Value: TFieldString);
    procedure SetDESCRICAOREDUZIDA(const Value: TFieldString);
    procedure SetDESCRICAOREDUZIDASKU(const Value: TFieldString);
    procedure SetDESCRICAOSKU(const Value: TFieldString);
    procedure SetID(const Value: TFieldInteger);
    procedure SetLARGURAEMBALAGEM(const Value: TFieldCurrency);
    procedure SetPESOEMBALAGEM(const Value: TFieldCurrency);
    procedure SetPESOPRODUTO(const Value: TFieldCurrency);
    procedure SetQUANTIDADECAIXASALTURAPALET(const Value: TFieldInteger);
    procedure SetQUANTIDADEPOREMBALAGEM(const Value: TFieldCurrency);
    procedure SetQUANTIDADESCAIXASLASTROPALET(const Value: TFieldInteger);
    procedure SetSTATUS(const Value: TFieldInteger);
    procedure SetUNIDADEDEMEDIDA(const Value: TFieldString);
    procedure SetID_ARQUIVO(const Value: TFieldInteger);
  protected
    procedure InitInstance; override;
  published
    property ID                           : TFieldInteger   read FID                            write SetID;
    property CODIGOPRODUTO                : TFieldString    read FCODIGOPRODUTO                 write SetCODIGOPRODUTO;
    property DESCRICAO                    : TFieldString    read FDESCRICAO                     write SetDESCRICAO;
    property DESCRICAOREDUZIDA            : TFieldString    read FDESCRICAOREDUZIDA             write SetDESCRICAOREDUZIDA;
    property DESCRICAOSKU                 : TFieldString    read FDESCRICAOSKU                  write SetDESCRICAOSKU;
    property DESCRICAOREDUZIDASKU         : TFieldString    read FDESCRICAOREDUZIDASKU          write SetDESCRICAOREDUZIDASKU;
    property QUANTIDADEPOREMBALAGEM       : TFieldCurrency  read FQUANTIDADEPOREMBALAGEM        write SetQUANTIDADEPOREMBALAGEM;
    property UNIDADEDEMEDIDA              : TFieldString    read FUNIDADEDEMEDIDA               write SetUNIDADEDEMEDIDA;
    property CODIGOBARRAS                 : TFieldString    read FCODIGOBARRAS                  write SetCODIGOBARRAS;
    property ALTURAEMBALAGEM              : TFieldCurrency  read FALTURAEMBALAGEM               write SetALTURAEMBALAGEM;
    property COMPRIMENTOEMBALAGEM         : TFieldCurrency  read FCOMPRIMENTOEMBALAGEM          write SetCOMPRIMENTOEMBALAGEM;
    property LARGURAEMBALAGEM             : TFieldCurrency  read FLARGURAEMBALAGEM              write SetLARGURAEMBALAGEM;
    property PESOEMBALAGEM                : TFieldCurrency  read FPESOEMBALAGEM                 write SetPESOEMBALAGEM;
    property PESOPRODUTO                  : TFieldCurrency  read FPESOPRODUTO                   write SetPESOPRODUTO;
    property QUANTIDADECAIXASALTURAPALET  : TFieldInteger   read FQUANTIDADECAIXASALTURAPALET   write SetQUANTIDADECAIXASALTURAPALET;
    property QUANTIDADESCAIXASLASTROPALET : TFieldInteger   read FQUANTIDADESCAIXASLASTROPALET  write SetQUANTIDADESCAIXASLASTROPALET;
    property ALIQUOTAIPI                  : TFieldCurrency  read FALIQUOTAIPI                   write SetALIQUOTAIPI;
    property CLASSIFICACAOFISCAL          : TFieldString    read FCLASSIFICACAOFISCAL           write SetCLASSIFICACAOFISCAL;
    property CATEGORIAPRODUTO             : TFieldInteger   read FCATEGORIAPRODUTO              write SetCATEGORIAPRODUTO;
    property STATUS                       : TFieldInteger   read FSTATUS                        write SetSTATUS;
    property ID_ARQUIVO                   : TFieldInteger read FID_ARQUIVO write SetID_ARQUIVO;
  end;

implementation

{ TPRODUTO }

procedure TPRODUTO.InitInstance;
begin
  inherited;
  ID.isPK                               := True;

  CODIGOPRODUTO.isNotNull               := True;
  DESCRICAO.isNotNull                   := True;
  DESCRICAOREDUZIDA.isNotNull           := True;
  DESCRICAOSKU.isNotNull                := True;
  DESCRICAOREDUZIDASKU.isNotNull        := True;
  QUANTIDADEPOREMBALAGEM.isNotNull      := True;
  UNIDADEDEMEDIDA.isNotNull             := True;
  CODIGOBARRAS.isNotNull                := True;
  ALTURAEMBALAGEM.isNotNull             := True;
  COMPRIMENTOEMBALAGEM.isNotNull        := True;
  LARGURAEMBALAGEM.isNotNull            := True;
  PESOEMBALAGEM.isNotNull               := True;
  PESOPRODUTO.isNotNull                 := True;
  QUANTIDADECAIXASALTURAPALET.isNotNull := True;
  QUANTIDADESCAIXASLASTROPALET.isNotNull:= True;
  ALIQUOTAIPI.isNotNull                 := True;
  CLASSIFICACAOFISCAL.isNotNull         := True;
  CATEGORIAPRODUTO.isNotNull            := True;
  STATUS.isNotNull                      := True;

  CODIGOPRODUTO.Size                    := 25;
  DESCRICAO.Size                        := 76;
  DESCRICAOREDUZIDA.Size                := 18;
  DESCRICAOSKU.Size                     := 76;
  DESCRICAOREDUZIDASKU.Size             := 18;
  UNIDADEDEMEDIDA.Size                  := 3;
  CODIGOBARRAS.Size                     := 128;
  CLASSIFICACAOFISCAL.Size              := 10;
end;

procedure TPRODUTO.SetALIQUOTAIPI(const Value: TFieldCurrency);
begin
  FALIQUOTAIPI := Value;
end;

procedure TPRODUTO.SetALTURAEMBALAGEM(const Value: TFieldCurrency);
begin
  FALTURAEMBALAGEM := Value;
end;

procedure TPRODUTO.SetCATEGORIAPRODUTO(const Value: TFieldInteger);
begin
  FCATEGORIAPRODUTO := Value;
end;

procedure TPRODUTO.SetCLASSIFICACAOFISCAL(const Value: TFieldString);
begin
  FCLASSIFICACAOFISCAL := Value;
end;

procedure TPRODUTO.SetCODIGOBARRAS(const Value: TFieldString);
begin
  FCODIGOBARRAS := Value;
end;

procedure TPRODUTO.SetCODIGOPRODUTO(const Value: TFieldString);
begin
  FCODIGOPRODUTO := Value;
end;

procedure TPRODUTO.SetCOMPRIMENTOEMBALAGEM(const Value: TFieldCurrency);
begin
  FCOMPRIMENTOEMBALAGEM := Value;
end;

procedure TPRODUTO.SetDESCRICAO(const Value: TFieldString);
begin
  FDESCRICAO := Value;
end;

procedure TPRODUTO.SetDESCRICAOREDUZIDA(const Value: TFieldString);
begin
  FDESCRICAOREDUZIDA := Value;
end;

procedure TPRODUTO.SetDESCRICAOREDUZIDASKU(const Value: TFieldString);
begin
  FDESCRICAOREDUZIDASKU := Value;
end;

procedure TPRODUTO.SetDESCRICAOSKU(const Value: TFieldString);
begin
  FDESCRICAOSKU := Value;
end;

procedure TPRODUTO.SetID(const Value: TFieldInteger);
begin
  FID := Value;
end;

procedure TPRODUTO.SetID_ARQUIVO(const Value: TFieldInteger);
begin
  FID_ARQUIVO := Value;
end;

procedure TPRODUTO.SetLARGURAEMBALAGEM(const Value: TFieldCurrency);
begin
  FLARGURAEMBALAGEM := Value;
end;

procedure TPRODUTO.SetPESOEMBALAGEM(const Value: TFieldCurrency);
begin
  FPESOEMBALAGEM := Value;
end;

procedure TPRODUTO.SetPESOPRODUTO(const Value: TFieldCurrency);
begin
  FPESOPRODUTO := Value;
end;

procedure TPRODUTO.SetQUANTIDADECAIXASALTURAPALET(const Value: TFieldInteger);
begin
  FQUANTIDADECAIXASALTURAPALET := Value;
end;

procedure TPRODUTO.SetQUANTIDADEPOREMBALAGEM(const Value: TFieldCurrency);
begin
  FQUANTIDADEPOREMBALAGEM := Value;
end;

procedure TPRODUTO.SetQUANTIDADESCAIXASLASTROPALET(const Value: TFieldInteger);
begin
  FQUANTIDADESCAIXASLASTROPALET := Value;
end;

procedure TPRODUTO.SetSTATUS(const Value: TFieldInteger);
begin
  FSTATUS := Value;
end;

procedure TPRODUTO.SetUNIDADEDEMEDIDA(const Value: TFieldString);
begin
  FUNIDADEDEMEDIDA := Value;
end;

end.
