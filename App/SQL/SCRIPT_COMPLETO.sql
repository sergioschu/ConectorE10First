CREATE TABLE if not exists usuario
(
  id serial NOT NULL,
  nome character varying(100) NOT NULL,
  email character varying(100) NOT NULL,
  senha character varying(100),
  CONSTRAINT pk_usuario PRIMARY KEY (id)
);

INSERT INTO usuario (id, nome, email) VALUES (0, 'Geral', 'Geral@geral.com');

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

CREATE TABLE arquivosftp
(
  id serial NOT NULL,
  tipo smallint NOT NULL, -- 0-Produtos...
  dataenvio timestamp without time zone,
  mensagem character varying(255),
  CONSTRAINT pk_arquivosftp PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE arquivosftp
  OWNER TO postgres;
COMMENT ON COLUMN arquivosftp.tipo IS '0-Produtos
1-NotaFiscal
2-Pedido';

INSERT INTO arquivosftp (id, tipo, dataenvio) VALUES (0, 0, current_timestamp);

CREATE TABLE produto
(
  id serial NOT NULL,
  codigoproduto character varying(100) NOT NULL,
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
  status smallint default 0,
  id_arquivo integer Default 0,
  CONSTRAINT pk_produto PRIMARY KEY (id),
  CONSTRAINT fk_p_arquivosftp FOREIGN KEY (id_arquivo)
      REFERENCES arquivosftp (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE transportadora
(
  id serial NOT NULL,
  cnpj character varying(19),
  nome character varying(100),
  CONSTRAINT pk_transportadora PRIMARY KEY (id)
);

INSERT INTO transportadora (id, cnpj, nome) VALUES (0, '99999999000191', 'Transportadora Padrão');

CREATE TABLE if not exists pedido
(
  id serial NOT NULL,
  pedido character varying(20) NOT NULL,
  viagem character varying(10) NOT NULL,
  sequencia smallint NOT NULL DEFAULT 0,
  dest_cnpj character varying(19) NOT NULL,
  dest_nome character varying(60) NOT NULL,
  dest_endereco character varying(36) NOT NULL,
  dest_complemento character varying(30) NOT NULL,
  dest_cep character varying(9) NOT NULL,
  dest_municipio character varying(30) NOT NULL,
  status smallint DEFAULT 0,
  id_arquivo integer NOT NULL,
  id_transportadora integer NOT NULL,
  id_usuario integer NOT NULL,
  data_importacao timestamp without time zone,
  data_envio timestamp without time zone,
  data_recebido timestamp without time zone,
  data_faturado timestamp without time zone,
  CONSTRAINT pk_lote PRIMARY KEY (id),
CONSTRAINT fk_p_transportadora FOREIGN KEY (id_transportadora)
      REFERENCES transportadora (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_ped_arquivosftp FOREIGN KEY (id_arquivo)
      REFERENCES arquivosftp (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_p_usuario FOREIGN KEY (id_usuario)
      REFERENCES usuario (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
);

ALTER TABLE PEDIDO
  OWNER TO postgres;
COMMENT ON COLUMN PEDIDO.STATUS IS 
'0 - Pedidos sem Transportadora
1 - Pedidos Com Transportadora
2 - Pedido Enviado
3 - MDD Recebido
4 - Pedido Impresso
5 - Pedido Faturado';

CREATE TABLE pedidoitens
(
  id serial NOT NULL,
  id_pedido bigint NOT NULL,
  id_produto bigint NOT NULL,
  quantidade numeric(17,3),
  valor_unitario numeric(17,6),
  recebido boolean,
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
  status smallint default 0,
  id_arquivo integer NOT NULL,
  id_usuario integer NOT NULL,
  data_importacao timestamp without time zone,
  data_envio timestamp without time zone,
  data_recebido timestamp without time zone,
  CONSTRAINT pk_notafiscal PRIMARY KEY (id),
  CONSTRAINT fk_pi_arquivosftp FOREIGN KEY (id_arquivo)
      REFERENCES arquivosftp (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_nf_usuario FOREIGN KEY (id_usuario)
      REFERENCES usuario (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
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

alter table pedido add volumes_documento integer;

update pedido set volumes_documento = 1;

alter table pedido add codigo_rastreio character varying(100);