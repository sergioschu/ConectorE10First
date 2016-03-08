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
  status boolean NOT NULL default false,
  CONSTRAINT pk_produto PRIMARY KEY (id)  
);
CREATE TABLE pedido
(
  id serial NOT NULL,
  pedido character varying(10) NOT NULL,
  viagem character varying(10) NOT NULL,
  sequencia smallint NOT NULL default 0,
  transp_cnpj character varying(10) NOT NULL,
  dest_cnpj character varying(10) NOT NULL,
  dest_nome character varying(10) NOT NULL,
  dest_endereco character varying(10) NOT NULL,
  dest_complemento character varying(10) NOT NULL,
  dest_cep character varying(10) NOT NULL,
  dest_municipio character varying(10) NOT NULL,
  enviado BOOLEAN,
  CONSTRAINT pk_lote PRIMARY KEY (id)
);
CREATE TABLE pedidoitens
(
  id serial NOT NULL,
  id_pedido smallint NOT NULL,
  id_produto smallint NOT NULL,
  quantidade numeric(17,3),
  valor_unitario numeric(17,6),
  CONSTRAINT pk_pedido_itens PRIMARY KEY (id),
  CONSTRAINT fk_pi_pedido FOREIGN KEY (id_pedido)
      REFERENCES pedido (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_pi_produto FOREIGN KEY (id_produto)
      REFERENCES produto (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
);
CREATE TABLE notafiscal
(
  id serial NOT NULL,
  documento integer NOT NULL,
  serie integer NOT NULL,
  cnpjcpf character varying(19),
  dataemissao timestamp without time zone,
  cfop integer,
  valortotal numeric(17,2),
  especie character varying(2),
  status boolean default false,
  CONSTRAINT pk_notafiscal PRIMARY KEY (id)
);
CREATE TABLE notafiscalitens
(
  id serial NOT NULL,
  id_notafiscal integer NOT NULL,
  sequencia integer NOT NULL,
  id_produto integer NOT NULL,
  quantidade numeric(12,3),
  quantidaderec numeric(12,3),
  quantidadeava numeric(12,3),
  valorunitario numeric(17,6),
  valortotal numeric(17,2),
  CONSTRAINT pk_notafiscalitens PRIMARY KEY (id),
  CONSTRAINT fk_ni_notafiscal FOREIGN KEY (id_notafiscal)
      REFERENCES notafiscal (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ni_produto FOREIGN KEY (id_produto)
      REFERENCES produto (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
);