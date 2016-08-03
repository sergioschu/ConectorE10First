unit uConstantes;

interface

type
  TTIPOREQUISICAOFIRST = (rfProd, rfArmz, rfConf, rfSc, rfmdd, rfScInc, rfScNf);

  TDADOSLOGIN = record
    Usuario : String;
    LembrarUsuario : Boolean;
  end;

  TDADOSCONEXAO = record
    LibVendor : string;
    Database : string;
    Server : string;
    User_Name : string;
    Password : string;
    CharacterSet : string;
    DriverID : string;
    Port : string;
  end;

  TDADOSUSUARIO = record
    CODIGO : Integer;
    NOME : string;
    EMAIL : string;
  end;

  TMENU = record
    NOME    : string;
    CAPTION : string;
  end;

  TCONFIGURACOESLOCAIS = record
    DirRelatorios : string;
    DirLog : String;
    FTPDir : string;
    FTPUsuario : string;
    FTPSenha : string;
    Sleep : Integer;
    DIR_ARQ_PDF : String;
    NOME : string;
    APELIDO : string;
    ID_DEPOSIT_FIRST : string;
    SECRET_KEY_FIRST : string;
  end;

  TITEM = record
    SEQUENCIA : Integer;
    SKU : String;
    QUANTIDADE : Double;
    UNITARIO : Double;
    TOTAL : Double;
  end;

  TNOTA = record
     DOCUMENTO : Integer;
     SERIE : Integer;
     DATA : TDateTime;
     CNPJ : String;
     ITENS : array of TITEM;
     VALOR : Double;
  end;

  TARRAYPEDIDOITENS = record
    ID_PEDIDO : Integer;
    NUMEROPEDIDO : string;
    DEST_CNPJ : String;
    DEST_NOME : String;
    DEST_ENDERECO : String;
    DEST_COMPLEMENTO : String;
    DEST_CEP : String;
    DEST_MUNICIPIO : String;
    SKU : String;
    ID_PRODUTO : Integer;
    QUANTIDADE : Currency;
    VALOR_UNITARIO : Currency;
    IMPORTAR : Boolean;
  end;

  TNOTAENTRADA = record
    DOCUMENTO : Integer;
    SERIE : Integer;
    ID : Integer;
  end;

  TPEDIDOS = record
    ID : Integer;
    PEDIDO : String;
    VOLUMES : Integer;
    PRODUTOS : array of String;
  end;

  TEMBARQUE = record
    PEDIDO : String;
    ID_PEDIDO : Integer;
    ID_TRANSPORTADORA : Integer;
    CNPJ_TRANSPORTADORA : string;
    NOME_TRANSPORTADORA : string;
    DH_EMBARQUE : TDateTime;
  end;

TTOKEN_FIRST = record
  STATUS_CODE : Integer;
  USER_ID : String;
  TOKEN : String;
  REFRESH_TOKEN : String;
  DH_LOGIN : TDateTime;
  SESSION_EXPIRES : Integer;
end;

Const
  Alfabeto: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Producao: Boolean = False;

Var
  LOGIN           : TDADOSLOGIN;
  CONEXAO         : TDADOSCONEXAO;
  USUARIO         : TDADOSUSUARIO;
  CONFIG_LOCAL    : TCONFIGURACOESLOCAIS;
  TOKEN_WS        : TTOKEN_FIRST;
  MENUS           : array of TMENU;
  DESIGNREL       : Boolean;
  DirArqConf      : String;
  DirArquivosFTP  : String;
  DirInstall      : String;
  DirArquivosExcel: String;

  //rfProd, rfArmz, rfConf, rfSc, rfmdd, rfScInc, rfScNf
  TIPOREQUISICAOFIRST : array[TTIPOREQUISICAOFIRST] of String = ('Produtos', 'Nota Fiscal Entrada', 'Confirma Nf Entrada', 'Envio Pedidos', 'MDD', 'Pedidos inconsistentes', 'Pedidos Nota Fiscal');

implementation

end.
