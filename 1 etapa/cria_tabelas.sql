
-- Criação das tabelas
DROP TABLE IF EXISTS cep;
CREATE TABLE cep.cep (
	nr_cep bpchar(8) NOT NULL,
	sg_uf bpchar(2) NOT NULL,
	cd_localidade int4 NOT NULL,
	cd_bairro int4 NULL,
	tp_logradouro varchar(26) NULL,
	nm_patente varchar(72) NULL,
	nm_preposicao varchar(3) NULL,
	cd_logradouro int4 NULL,
	nm_logradouro varchar(72) NULL,
	nm_abreviatura varchar(36) NULL,
	ds_info_adicional varchar(36) NULL,
	CONSTRAINT cep_pkey PRIMARY KEY (nr_cep)
);


DROP TABLE IF EXISTS bairro;
CREATE TABLE bairro (
    sg_Uf CHAR(2) NOT NULL,
    cd_Localidade INT NOT NULL,
    cd_Bairro INT NOT NULL,
    nm_Bairro VARCHAR(72) NOT NULL,
    nm_Bairro_Abrev VARCHAR(36),
    zona VARCHAR(255),
    PRIMARY KEY (cd_Bairro)
);

DROP TABLE IF EXISTS localidade;
CREATE TABLE localidade (
    nr_cep CHAR(8),
    sg_uf CHAR(2) NOT NULL,
    cd_localidade INTEGER NOT NULL PRIMARY KEY,
    nm_localidade TEXT NOT NULL,
    nm_abreviatura TEXT
);

DROP TABLE IF EXISTS estado;
CREATE TABLE estado (
    sg_pais CHAR(2) NOT NULL,
    sg_uf CHAR(2) NOT NULL,
    cd_uf INTEGER NOT NULL,
    nm_estado VARCHAR(72) NOT NULL
);
CREATE UNIQUE INDEX estado_pkey
    ON estado (sg_uf)
    WITH (FILLFACTOR = 90);
ALTER TABLE estado
    ADD CONSTRAINT estado_pkey PRIMARY KEY USING INDEX estado_pkey;

DROP TABLE IF EXISTS pais;
CREATE TABLE pais (
    Sg_Pais CHAR(2) NOT NULL,
    Sg_Pais_2 CHAR(3) NOT NULL,
    Nm_Pais VARCHAR(72) NOT NULL,
    Nm_Pais_ENG VARCHAR(72) NOT NULL,
    Nm_Pais_FRA VARCHAR(72) NOT NULL,
    PRIMARY KEY (Sg_Pais)
);

DROP TABLE IF EXISTS tipo_logradouro;
CREATE TABLE tipo_logradouro (
    cd_tipo_logradouro INTEGER NOT NULL,
    tp_logradouro VARCHAR(26) NOT NULL,
    tp_logradouro_abrev VARCHAR(15) NOT NULL,
    PRIMARY KEY (tp_logradouro)
);
CREATE INDEX idx_tipo_logradouro_tp_logradouro 
ON tipo_logradouro (tp_logradouro) 
WITH (FILLFACTOR = 90);

DROP TABLE IF EXISTS titulo_patente;
CREATE TABLE titulo_patente (
    cd_titulo_patente INTEGER NOT NULL,
    nm_patente VARCHAR(72) NOT NULL PRIMARY KEY,
    nm_patente_abrev VARCHAR(15) NOT NULL
);


