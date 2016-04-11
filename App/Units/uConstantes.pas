unit uConstantes;

interface

type
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
    FTPUsuario : string;
    FTPSenha : string;
    Sleep : Integer;
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

Const
  DirArqConf: String = 'C:\ConectorE10First\Conector.ini';
  DirArquivosFTP : string = 'C:\ConectorE10First\arquivosFTP\';
  DirInstall: String = 'C:\ConectorE10First\';
  DirArquivosExcel: String = 'C:\ConectorE10First\Arquivos\';
  Alfabeto: String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

Var
  LOGIN       : TDADOSLOGIN;
  CONEXAO     : TDADOSCONEXAO;
  USUARIO     : TDADOSUSUARIO;
  CONFIG_LOCAL: TCONFIGURACOESLOCAIS;
  MENUS       : array of TMENU;
  DESIGNREL   : Boolean;

implementation

end.
