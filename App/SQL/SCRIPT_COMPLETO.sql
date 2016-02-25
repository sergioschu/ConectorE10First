CREATE TABLE if not exists usuario
(
  id serial NOT NULL,
  nome character varying(100) NOT NULL,
  email character varying(100) NOT NULL,
  senha character varying(100),
  CONSTRAINT pk_usuario PRIMARY KEY (id)
);

CREATE TABLE usuario_permissao
(
  id serial NOT NULL,
  id_usuario bigint,
  menu character varying(100),
  CONSTRAINT pk_usuario_permissao PRIMARY KEY (id),
  CONSTRAINT fk_usuario_permissao_u FOREIGN KEY (id_usuario)
      REFERENCES usuario (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE produto
(
  id serial NOT NULL,
  codigoproduto character varying(25) NOT NULL,
  descricao character varying(76) NOT NULL,
  descricaoreduzida character varying(18) NOT NULL,
  descricaosku character varying(76) NOT NULL,
  descricaoreduzidasku character varying(18) NOT NULL,
  quantidadeporembalagem numeric(17,6) NOT NULL,
  unidadedemedida character varying(3) NOT NULL,
  codigobarras character varying(128) NOT NULL,
  alturaembalagem numeric(17,6) NOT NULL,
  comprimentoembalagem numeric(17,6) NOT NULL,
  larguraembalagem numeric(17,6) NOT NULL,
  pesoembalagem numeric(12,5) NOT NULL default 0.1,
  pesoproduto numeric(12,5) NOT NULL default 0.1,
  quantidadecaixasalturapalet integer NOT NULL default 1,
  quantidadescaixaslastropalet integer NOT NULL default 1,
  aliquotaipi numeric(6,3) NOT NULL default 0,
  classificacaofiscal character varying(10) NOT NULL default 0,
  categoriaproduto integer NOT NULL default 1,
  status boolean NOT NULL default false  
);