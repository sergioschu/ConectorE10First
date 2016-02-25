unit uDomains;

interface

uses Classes, SysUtils, Variants, Math;

type

{ //Chaves Primárias
  //Campos NOT NULL
  //Tamanho máximo dos campos literais
  //Campos disponíveis para busca
  //Label dos campos de busca
    }
 TImportDadosExcel = class
  private
    FexcelIndice: integer;
    FexcelTitulo: string;
    procedure SetexcelIndice(const Value: integer);
    procedure SetexcelTitulo(const Value: string);
  published
   property excelTitulo : string read FexcelTitulo write SetexcelTitulo;
   property excelIndice : integer read FexcelIndice write SetexcelIndice;
 end;
  //////////////////////////////
  //Interface de domínio padrão
  //////////////////////////////
  TFieldTypeDomain = class(TImportDadosExcel)
  private
    function getIsPK : Boolean; virtual; abstract;
    function getIsNotNull : Boolean; virtual; abstract;
    function getIsSearchField : Boolean; virtual; abstract;
    function getIsNull : Boolean; virtual; abstract;
    function getDisplayLabel : String; virtual; abstract;
    function getDisplayWidth : Integer; virtual; abstract;
    function getAsSQL : String; virtual; abstract;
    function getAsVariant : Variant; virtual; abstract;
    function getAsString : String; virtual; abstract;

    procedure setIsPK(const Value: Boolean); virtual; abstract;
    procedure setIsNotNull(const Value: Boolean); virtual; abstract;
    procedure setIsSearchField(const Value: Boolean); virtual; abstract;
    procedure setIsNull(const Value: Boolean); virtual; abstract;
    procedure setDisplayLabel(const Value: String); virtual; abstract;
    procedure setDisplayWidth(const Value: Integer); virtual; abstract;
    procedure setAsVariant(const Value: Variant); virtual; abstract;

  public
    property isPK           : Boolean read getIsPK          write setIsPK;
    property isNotNull      : Boolean read getIsNotNull     write setIsNotNull;
    property isSearchField  : Boolean read getIsSearchField write setIsSearchField;
    property isNull         : Boolean read getIsNull        write setIsNull;
    property displayLabel   : String  read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String  read getAsSQL;
    property asVariant      : Variant read getAsVariant     write setAsVariant;
    property asString       : String  read getAsString;
  end;

  //////////////////////////////
  //        STRING
  //////////////////////////////
  TFieldString = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FSize           : Word;
    FValue          : AnsiString;
    FisNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull: Boolean; override;
    function getDisplayLabel : String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: AnsiString;
    function getSize: Word;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: AnsiString);
    procedure setSize(const Value: Word);

  public
    property isNotNull      : Boolean     read getIsNotNull     write setIsNotNull;
    property isPK           : Boolean     read getIsPK          write setIsPK;
    property isSearchField  : Boolean     read getIsSearchField write setIsSearchField;
    property isNull         : Boolean     read getIsNull        write setIsNull;
    property displayLabel   : String      read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer     read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String      read getasSQL;
    property asVariant      : Variant     read getAsVariant     write setAsVariant;
    property asString       : String      read getAsString;
    property Size           : Word        read getSize          write setSize;
    property Value          : AnsiString  read getValue         write setValue;
  end;

  //////////////////////////////
  //        INTEGER
  //////////////////////////////
  TFieldInteger = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FValue          : Integer;
    FIsNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull : Boolean; override;
    function getDisplayLabel: String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: Integer;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: Integer);

  public
    property isNotNull      : Boolean read getIsNotNull     write setIsNotNull;
    property isPK           : Boolean read getIsPK          write setIsPK;
    property isSearchField  : Boolean read getIsSearchField write setIsSearchField;
    property isNull         : Boolean read getIsNull        write setIsNull;
    property displayLabel   : String  read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String  read getasSQL;
    property asVariant      : Variant read getAsVariant     write setAsVariant;
    property asString       : String  read getAsString;
    property Value          : Integer read getValue         write setValue;
  end;

  //////////////////////////////
  //        FLOAT
  //////////////////////////////
  TFieldFloat = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FValue          : Double;
    FisNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull: Boolean; override;
    function getDisplayLabel: String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: Double;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: Double);

  public
    property isNotNull      : Boolean read getIsNotNull     write setIsNotNull;
    property isPK           : Boolean read getIsPK          write setIsPK;
    property isSearchField  : Boolean read getIsSearchField write setIsSearchField;
    property isNull         : Boolean read getIsNull        write setIsNull;
    property displayLabel   : String  read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String  read getAsSQL;
    property asVariant      : Variant read getAsVariant     write setAsVariant;
    property asString       : String  read getAsString;
    property Value          : Double  read getValue         write setValue;
  end;

  //////////////////////////////
  //        CURRENCY
  //////////////////////////////
  TFieldCurrency = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FValue          : Currency;
    FisNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull: Boolean; override;
    function getDisplayLabel: String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: Currency;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: Currency);

  public
    property isPK           : Boolean   read getIsPK          write setIsPK;
    property isNotNull      : Boolean   read getIsNotNull     write setIsNotNull;
    property isSearchField  : Boolean   read getIsSearchField write setIsSearchField;
    property isNull         : Boolean   read getIsNull        write setIsNull;
    property displayLabel   : String    read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer   read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String    read getAsSQL;
    property asVariant      : Variant   read getAsVariant     write setAsVariant;
    property asString       : String    read getAsString;
    property Value          : Currency  read getValue         write setValue;
  end;

  //////////////////////////////
  //      BOOLEAN
  //////////////////////////////
  TFieldBoolean = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FValue          : Boolean;
    FisNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull: Boolean; override;
    function getDisplayLabel: String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: Boolean;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: Boolean);

  public
    property isPK           : Boolean read getIsPK          write setIsPK;
    property isNotNull      : Boolean read getIsNotNull     write setIsNotNull;
    property isSearchField  : Boolean read getIsSearchField write setIsSearchField;
    property isNull         : Boolean read getIsNull        write setIsNull;
    property displayLabel   : String  read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String  read getAsSQL;
    property asVariant      : Variant read getAsVariant     write setAsVariant;
    property asString       : String  read getAsString;
    property Value          : Boolean read getValue         write setValue;

  end;

  //////////////////////////////
  //      DATETIME
  //////////////////////////////
  TFieldDateTime = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FValue          : TDateTime;
    FisNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull: Boolean; override;
    function getDisplayLabel: String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: TDateTime;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: TDateTime);

  public
    property isPK           : Boolean   read getIsPK          write setIsPK;
    property isNotNull      : Boolean   read getIsNotNull     write setIsNotNull;
    property isSearchField  : Boolean   read getIsSearchField write setIsSearchField;
    property isNull         : Boolean   read getIsNull        write setIsNull;
    property displayLabel   : String    read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer   read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String    read getAsSQL;
    property asVariant      : Variant   read getAsVariant     write setAsVariant;
    property asString       : String    read getAsString;
    property Value          : TDateTime read getValue         write setValue;
  end;

  //////////////////////////////
  //        BLOB
  //////////////////////////////
  TFieldBlob = class(TFieldTypeDomain)
  private
    FisPK           : Boolean;
    FisNotNull      : Boolean;
    FisSearchField  : Boolean;
    FDisplayLabel   : String;
    FDisplayWidth   : Integer;
    FValue          : AnsiString;
    FisNull         : Boolean;

  protected
    function getIsPK: Boolean; override;
    function getIsNotNull: Boolean; override;
    function getIsSearchField: Boolean; override;
    function getIsNull: Boolean; override;
    function getDisplayLabel: String; override;
    function getDisplayWidth : Integer; override;
    function getAsSQL: String; override;
    function getAsVariant: Variant; override;
    function getAsString: String; override;
    function getValue: AnsiString;

    procedure setIsPK(const Value: Boolean); override;
    procedure setIsNotNull(const Value: Boolean); override;
    procedure setIsSearchField(const Value: Boolean); override;
    procedure setIsNull(const Value: Boolean); override;
    procedure setDisplayLabel(const Value: String); override;
    procedure setDisplayWidth(const Value: Integer); override;
    procedure setAsVariant(const Value: Variant); override;
    procedure setValue(const Value: AnsiString);

  public
    property isPK           : Boolean     read getIsPK          write setIsPK;
    property isNotNull      : Boolean     read getIsNotNull     write setIsNotNull;
    property isSearchField  : Boolean     read getIsSearchField write setIsSearchField;
    property isNull         : Boolean     read getIsNull        write setIsNull;
    property displayLabel   : String      read getDisplayLabel  write setDisplayLabel;
    property displayWidth   : Integer     read getDisplayWidth  write setDisplayWidth;
    property asSQL          : String      read getAsSQL;
    property asVariant      : Variant     read getAsVariant     write setAsVariant;
    property asString       : String      read getAsString;
    property Value          : AnsiString  read getValue         write setValue;
  end;

  //////////////////////////////
  //        BLOB BINARY
  //////////////////////////////
{  TFieldBlobBinary = class(TFieldTypeDomain)

  public
    property isPK           : Boolean;
    property isNotNull      : Boolean;
    property isSearchField  : Boolean;
    property isNull         : Boolean;
    property displayLabel   : String;
    property asSQL          : String;
    property asVariant      : Variant;
    property asString       : String;
    property Value          : String;
  end;
 }
implementation

{ TFieldString }

function TFieldString.getasSQL: String;
begin
  Result := QuotedStr(Self.FValue);
end;

function TFieldString.getAsString: String;
begin
  Result := Self.FValue;
end;

function TFieldString.getAsVariant: Variant;
begin
  Result := Variant(Self.FValue);
end;

function TFieldString.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldString.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldString.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldString.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldString.getIsNull: Boolean;
begin
  Result := Self.FisNull;
end;

function TFieldString.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldString.getSize: Word;
begin
  Result := Self.FSize;
end;

function TFieldString.getValue: AnsiString;
begin
  Result := Copy(Self.FValue, 0, Self.FSize);
end;

procedure TFieldString.setAsVariant(const Value: Variant);
begin
  Self.FValue := String(Value);
  Self.setIsNull(False);  
end;

procedure TFieldString.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel := Value;
end;

procedure TFieldString.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldString.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldString.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldString.setIsNull(const Value: Boolean);
begin
  Self.FisNull := Value;
end;

procedure TFieldString.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldString.setSize(const Value: Word);
begin
  Self.FSize := Value;
end;

procedure TFieldString.setValue(const Value: AnsiString);
begin
  Self.FValue := Copy(Value, 0, Self.FSize);
  Self.setIsNull(False);  
end;

{ TFieldInteger }

function TFieldInteger.getasSQL: String;
begin
  Result := IntToStr(Self.FValue);
end;

function TFieldInteger.getAsString: String;
begin
  Result := IntToStr(Self.FValue);
end;

function TFieldInteger.getAsVariant: Variant;
begin
  Result := Variant(Self.FValue);
end;

function TFieldInteger.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldInteger.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldInteger.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldInteger.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldInteger.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldInteger.getIsNull: Boolean;
begin
  Result := Self.FIsNull;
end;

function TFieldInteger.getValue: Integer;
begin
  Result := Self.FValue;
end;

procedure TFieldInteger.setAsVariant(const Value: Variant);
begin
  Self.FValue := Integer(Value);
  Self.setIsNull(False);
end;

procedure TFieldInteger.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel  := Value;
end;

procedure TFieldInteger.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldInteger.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldInteger.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldInteger.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldInteger.setIsNull(const Value: Boolean);
begin
  Self.FIsNull := Value;
end;

procedure TFieldInteger.setValue(const Value: Integer);
begin
  Self.FValue := Value;
  Self.setIsNull(False);  
end;

{ TFieldFloat }

function TFieldFloat.getasSQL: String;
begin
  Result := FloatToStr(Self.FValue);
end;

function TFieldFloat.getAsString: String;
begin
  Result := FloatToStr(Self.FValue);
end;

function TFieldFloat.getAsVariant: Variant;
begin
  Result := Variant(Self.FValue);
end;

function TFieldFloat.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldFloat.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldFloat.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldFloat.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldFloat.getisNull: Boolean;
begin
  Result := Self.FisNull;
end;

function TFieldFloat.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldFloat.getValue: Double;
begin
  Result := Self.FValue;
end;

procedure TFieldFloat.setAsVariant(const Value: Variant);
begin
  Self.FValue := Double(Value);
  Self.setIsNull(False);  
end;

procedure TFieldFloat.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel  := Value;
end;

procedure TFieldFloat.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldFloat.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldFloat.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldFloat.setIsNull(const Value: Boolean);
begin
  Self.FisNull  := Value;
end;

procedure TFieldFloat.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldFloat.setValue(const Value: Double);
begin
  Self.FValue := Value;
  Self.setIsNull(False);  
end;

{ TFieldCurrency }

function TFieldCurrency.getasSQL: String;
begin
  Result := CurrToStr(Self.FValue);
end;

function TFieldCurrency.getAsString: String;
begin
  Result := CurrToStr(Self.FValue);
end;

function TFieldCurrency.getAsVariant: Variant;
begin
  Result := Variant(Self.FValue);
end;

function TFieldCurrency.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldCurrency.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldCurrency.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldCurrency.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldCurrency.getisNull: Boolean;
begin
  Result := Self.FisNull;
end;

function TFieldCurrency.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldCurrency.getValue: Currency;
begin
  Result := Self.FValue;
end;

procedure TFieldCurrency.setAsVariant(const Value: Variant);
begin
  Self.FValue := Currency(Value);
  Self.setIsNull(False);  
end;

procedure TFieldCurrency.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel  := Value;
end;

procedure TFieldCurrency.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldCurrency.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldCurrency.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldCurrency.setIsNull(const Value: Boolean);
begin
  Self.FisNull := Value;
end;

procedure TFieldCurrency.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldCurrency.setValue(const Value: Currency);
begin
  Self.FValue := Value;
  Self.setIsNull(False);  
end;

{ TFieldBoolean }

function TFieldBoolean.getasSQL: String;
begin
  Result := BoolToStr(Self.FValue);
end;

function TFieldBoolean.getAsString: String;
begin
  Result := BoolToStr(Self.FValue);
end;

function TFieldBoolean.getAsVariant: Variant;
begin  //Se não converter pra numérico ele grava -1 pra verdadeiro
  Result := Variant(IfThen(Self.FValue, 1, 0));
end;

function TFieldBoolean.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldBoolean.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldBoolean.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldBoolean.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldBoolean.getIsNull: Boolean;
begin
  Result := Self.FisNull;
end;

function TFieldBoolean.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldBoolean.getValue: Boolean;
begin
  Result := Self.FValue;
end;

procedure TFieldBoolean.setAsVariant(const Value: Variant);
begin
  Self.FValue := Boolean(Value);
  Self.setIsNull(False);
end;

procedure TFieldBoolean.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel  := Value;
end;

procedure TFieldBoolean.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldBoolean.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldBoolean.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldBoolean.setIsNull(const Value: Boolean);
begin
  Self.FisNull  := Value;
end;

procedure TFieldBoolean.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldBoolean.setValue(const Value: Boolean);
begin
  Self.FValue := Value;
  Self.setIsNull(False);  
end;

{ TFieldDateTime }

function TFieldDateTime.getasSQL: String;
begin
  Result := QuotedStr(StringReplace(DateTimeToStr(Self.FValue), '/', '.', [rfReplaceAll]));
end;

function TFieldDateTime.getAsString: String;
begin
  Result := DateTimeToStr(Self.FValue);
end;

function TFieldDateTime.getAsVariant: Variant;
begin
  Result := Variant(Self.FValue);
end;

function TFieldDateTime.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldDateTime.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldDateTime.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldDateTime.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldDateTime.getIsNull: Boolean;
begin
  Result := Self.FisNull;
end;

function TFieldDateTime.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldDateTime.getValue: TDateTime;
begin
  Result := Self.FValue;
end;

procedure TFieldDateTime.setAsVariant(const Value: Variant);
begin
  if not VarIsNull(Value) then begin
    Self.FValue := TDateTime(Value);
    Self.setIsNull(False);
  end;
end;

procedure TFieldDateTime.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel  := Value;
end;

procedure TFieldDateTime.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldDateTime.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldDateTime.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldDateTime.setIsNull(const Value: Boolean);
begin
  Self.FisNull  := Value;
end;

procedure TFieldDateTime.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldDateTime.setValue(const Value: TDateTime);
begin
  Self.FValue := Value;
  Self.setIsNull(False);  
end;

{ TFieldBlob }

function TFieldBlob.getasSQL: String;
begin //Verificar
  Result := Self.FValue;
end;

function TFieldBlob.getAsString: String;
begin
  Result := String(Self.FValue);
end;

function TFieldBlob.getAsVariant: Variant;
begin
  Result := Self.FValue;
end;

function TFieldBlob.getDisplayLabel: String;
begin
  Result := Self.FDisplayLabel;
end;

function TFieldBlob.getDisplayWidth: Integer;
begin
  Result := Self.FDisplayWidth;
end;

function TFieldBlob.getIsPK: Boolean;
begin
  Result := Self.FisPK;
end;

function TFieldBlob.getIsNotNull: Boolean;
begin
  Result := Self.FisNotNull;
end;

function TFieldBlob.getIsNull: Boolean;
begin
  Result := Self.FisNull;
end;

function TFieldBlob.getIsSearchField: Boolean;
begin
  Result := Self.FisSearchField;
end;

function TFieldBlob.getValue: AnsiString;
begin
  Result := Self.FValue;
end;

procedure TFieldBlob.setAsVariant(const Value: Variant);
begin
  Self.FValue := Value;
  Self.setIsNull(False);
end;

procedure TFieldBlob.setDisplayLabel(const Value: String);
begin
  Self.FDisplayLabel  := Value;
end;

procedure TFieldBlob.setDisplayWidth(const Value: Integer);
begin
  Self.FDisplayWidth  := Value;
end;

procedure TFieldBlob.setIsPK(const Value: Boolean);
begin
  Self.FisPK       := Value;
  Self.FisNotNull  := Value;
end;

procedure TFieldBlob.setIsNotNull(const Value: Boolean);
begin
  Self.FisNotNull := Value;
end;

procedure TFieldBlob.setIsNull(const Value: Boolean);
begin
  Self.FisNull := Value;
end;

procedure TFieldBlob.setIsSearchField(const Value: Boolean);
begin
  Self.FisSearchField := Value;
end;

procedure TFieldBlob.setValue(const Value: AnsiString);
begin
  Self.FValue := Value;
  Self.setIsNull(False);
end;

{ TImportDadosExcel }

procedure TImportDadosExcel.SetexcelIndice(const Value: integer);
begin
  FexcelIndice := Value;
end;

procedure TImportDadosExcel.SetexcelTitulo(const Value: string);
begin
  FexcelTitulo := Value;
end;

end.
