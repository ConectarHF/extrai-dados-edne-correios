-- Criação do esquema e tabelas
CREATE SCHEMA IF NOT EXISTS cep;
SET search_path TO cep;

-- Criação das tabelas
DROP TABLE IF EXISTS cep;
CREATE TABLE cep (
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

-- Função para atualizar CEP
CREATE OR REPLACE FUNCTION stp_atualizacao_cep()
RETURNS VOID AS $$

-----------------------------------inicio paises-----------------
DECLARE
    v_linha TEXT; -- Variável renomeada
    v_arquivo BYTEA; -- Variável renomeada
    v_sg_pais CHAR(2); -- Variável renomeada
    v_sg_pais_2 CHAR(3); -- Variável renomeada
    v_nm_pais VARCHAR(72); -- Variável renomeada
    v_nm_pais_eng VARCHAR(72); -- Variável renomeada
    v_nm_pais_fra VARCHAR(72); -- Variável renomeada
BEGIN
    -- Lê o arquivo como BYTEA (binário)
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_PAISES.TXT');

    -- Converte o arquivo para texto usando a codificação LATIN1
    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            -- Verifica se a linha começa com 'D' e tem o comprimento mínimo esperado
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 222 THEN
                -- Extrai os campos conforme as posições especificadas
                v_sg_pais := RTRIM(LTRIM(SUBSTRING(v_linha FROM 2 FOR 2))); -- Posição 2, tamanho 2
                v_sg_pais_2 := RTRIM(LTRIM(SUBSTRING(v_linha FROM 4 FOR 3))); -- Posição 4, tamanho 3
                v_nm_pais := RTRIM(LTRIM(SUBSTRING(v_linha FROM 7 FOR 72))); -- Posição 7, tamanho 72
                v_nm_pais_eng := RTRIM(LTRIM(SUBSTRING(v_linha FROM 79 FOR 72))); -- Posição 79, tamanho 72
                v_nm_pais_fra := RTRIM(LTRIM(SUBSTRING(v_linha FROM 151 FOR 72))); -- Posição 151, tamanho 72

                -- Valida se os campos não estão vazios e têm o comprimento esperado
                IF v_sg_pais IS NOT NULL AND LENGTH(v_sg_pais) = 2 AND
                   v_sg_pais_2 IS NOT NULL AND LENGTH(v_sg_pais_2) = 3 AND
                   v_nm_pais IS NOT NULL AND LENGTH(v_nm_pais) > 0 AND
                   v_nm_pais_eng IS NOT NULL AND LENGTH(v_nm_pais_eng) > 0 AND
                   v_nm_pais_fra IS NOT NULL AND LENGTH(v_nm_pais_fra) > 0 THEN

                    -- Log dos campos extraídos
                    RAISE NOTICE 'Linha processada: sg_pais=%, sg_pais_2=%, nm_pais=%, nm_pais_eng=%, nm_pais_fra=%',
                                 v_sg_pais, v_sg_pais_2, v_nm_pais, v_nm_pais_eng, v_nm_pais_fra;

                    -- Insere os dados na tabela pais
                    INSERT INTO cep.pais (Sg_Pais, Sg_Pais_2, Nm_Pais, Nm_Pais_ENG, Nm_Pais_FRA)
                    VALUES (v_sg_pais, v_sg_pais_2, v_nm_pais, v_nm_pais_eng, v_nm_pais_fra)
                    ON CONFLICT (Sg_Pais) DO NOTHING; -- Evita duplicatas
                ELSE
                    -- Ignora a linha se algum campo estiver vazio ou inválido
                    RAISE NOTICE 'Linha ignorada: Campos inválidos. Linha: %', v_linha;
                END IF;
            ELSE
                -- Ignora a linha se não começar com 'D' ou não tiver o comprimento mínimo
                RAISE NOTICE 'Linha ignorada: Formato inválido. Linha: %', v_linha;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                -- Captura erros e continua o processamento
                RAISE NOTICE 'Erro ao processar linha: %', v_linha;
                CONTINUE;
        END;
    END LOOP;
--------------------------------fim de paises------------------------------

-------------------------------inicio locolidade------------------------

DECLARE
    v_linha TEXT; -- Variável para armazenar cada linha do arquivo
    v_arquivo BYTEA; -- Variável para armazenar o conteúdo do arquivo
    v_nr_cep CHAR(8); -- CEP da localidade
    v_sg_uf CHAR(2); -- Sigla da UF
    v_cd_localidade INT; -- Código da localidade
    v_nm_localidade VARCHAR(72); -- Nome da localidade
    v_nm_abreviatura VARCHAR(36); -- Nome abreviado da localidade
BEGIN
    -- Lê o arquivo como BYTEA (binário)
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_PAISES.TXT/DNE_GU_LOCALIDADES.TXT');

    -- Converte o arquivo para texto usando a codificação LATIN1
    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            -- Verifica se a linha começa com 'D' e tem o comprimento mínimo esperado
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 136 THEN
                -- Extrai os campos conforme as posições especificadas
                v_nr_cep := CASE WHEN SUBSTRING(v_linha FROM 92 FOR 8) = '        ' THEN NULL
                                ELSE RTRIM(LTRIM(SUBSTRING(v_linha FROM 92 FOR 8)))
                           END;
                v_sg_uf := RTRIM(LTRIM(SUBSTRING(v_linha FROM 4 FOR 2)));
                v_cd_localidade := RTRIM(LTRIM(SUBSTRING(v_linha FROM 12 FOR 8)))::INT;
                v_nm_localidade := RTRIM(LTRIM(SUBSTRING(v_linha FROM 20 FOR 72)));
                v_nm_abreviatura := RTRIM(LTRIM(SUBSTRING(v_linha FROM 100 FOR 36)));

                -- Valida se os campos não estão vazios e têm o comprimento esperado
                IF v_sg_uf IS NOT NULL AND LENGTH(v_sg_uf) = 2 AND
                   v_cd_localidade IS NOT NULL AND
                   v_nm_localidade IS NOT NULL AND LENGTH(v_nm_localidade) > 0 THEN

                    -- Log dos campos extraídos
                    RAISE NOTICE 'Linha processada: nr_cep=%, sg_uf=%, cd_localidade=%, nm_localidade=%, nm_abreviatura=%',
                                 v_nr_cep, v_sg_uf, v_cd_localidade, v_nm_localidade, v_nm_abreviatura;

                    -- Insere os dados na tabela Localidade
                    INSERT INTO Localidade (Nr_Cep, Sg_Uf, Cd_Localidade, Nm_Localidade, Nm_Abreviatura)
                    VALUES (v_nr_cep, v_sg_uf, v_cd_localidade, v_nm_localidade, v_nm_abreviatura)
                    ON CONFLICT (Cd_Localidade) DO NOTHING; -- Evita duplicatas
                ELSE
                    -- Ignora a linha se algum campo estiver vazio ou inválido
                    RAISE NOTICE 'Linha ignorada: Campos inválidos. Linha: %', v_linha;
                END IF;
            ELSE
                -- Ignora a linha se não começar com 'D' ou não tiver o comprimento mínimo
                RAISE NOTICE 'Linha ignorada: Formato inválido. Linha: %', v_linha;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                -- Captura erros e continua o processamento
                RAISE NOTICE 'Erro ao processar linha: %', v_linha;
                CONTINUE;
        END;
    END LOOP;


---------------------------------fim localidade-------------------------------------





    -- Processamento de outros arquivos (Grandes Usuários, Caixas Postais, etc.)
    -- [Inserir aqui o restante do código de importação para os outros arquivos]

    -- Criação das chaves estrangeiras
    ALTER TABLE estado
    ADD CONSTRAINT fk_estado_pais
    FOREIGN KEY (sg_pais)
    REFERENCES pais(sg_pais);

    ALTER TABLE bairro
    ADD CONSTRAINT fk_bairro_estado
    FOREIGN KEY (sg_uf)
    REFERENCES estado(sg_uf);

    ALTER TABLE bairro
    ADD CONSTRAINT fk_bairro_localidade
    FOREIGN KEY (cd_localidade)
    REFERENCES localidade(cd_localidade);

    ALTER TABLE localidade
    ADD CONSTRAINT fk_localidade_estado
    FOREIGN KEY (sg_uf)
    REFERENCES estado(sg_uf);

    ALTER TABLE cep
    ADD CONSTRAINT fk_cep_estado
    FOREIGN KEY (sg_uf)
    REFERENCES estado(sg_uf);

    ALTER TABLE cep
    ADD CONSTRAINT fk_cep_localidade
    FOREIGN KEY (cd_localidade)
    REFERENCES localidade(cd_localidade);

    ALTER TABLE cep
    ADD CONSTRAINT fk_cep_bairro
    FOREIGN KEY (cd_bairro)
    REFERENCES bairro(cd_bairro);

    ALTER TABLE cep
    ADD CONSTRAINT fk_cep_tipo_logradouro
    FOREIGN KEY (tp_logradouro)
    REFERENCES tipo_logradouro(tp_logradouro);

    ALTER TABLE cep
    ADD CONSTRAINT fk_cep_titulo_patente
    FOREIGN KEY (nm_patente)
    REFERENCES titulo_patente(nm_patente);
END;
$$ LANGUAGE plpgsql;