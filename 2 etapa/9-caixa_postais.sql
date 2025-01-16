CREATE OR REPLACE FUNCTION carregar_cep_caixas_postais()
RETURNS VOID AS $$
DECLARE
    v_linha TEXT; 
    v_arquivo BYTEA; 
    v_nr_cep CHAR(8); 
    v_sg_uf CHAR(2); 
    v_cd_localidade INT; 
    v_cd_bairro INT; 
    v_tp_logradouro VARCHAR(26); 
    v_nm_patente VARCHAR(72); 
    v_nm_preposicao VARCHAR(3); 
    v_cd_logradouro INT; 
    v_nm_logradouro VARCHAR(72); 
    v_nm_abreviatura VARCHAR(36); 
    v_ds_info_adicional VARCHAR(36); 
BEGIN
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_CAIXAS_POSTAIS_COMUNITA.TXT');

    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 250 THEN
                v_nr_cep := RTRIM(LTRIM(SUBSTRING(v_linha FROM 90 FOR 8))); 
                v_sg_uf := RTRIM(LTRIM(SUBSTRING(v_linha FROM 2 FOR 2))); 
                v_cd_localidade := RTRIM(LTRIM(SUBSTRING(v_linha FROM 10 FOR 8)))::INT; 
                v_cd_logradouro := RTRIM(LTRIM(SUBSTRING(v_linha FROM 170 FOR 8)))::INT; 
                v_nm_logradouro := RTRIM(LTRIM(SUBSTRING(v_linha FROM 178 FOR 72))); 

                IF v_nr_cep IS NOT NULL AND LENGTH(v_nr_cep) = 8 AND
                   v_sg_uf IS NOT NULL AND LENGTH(v_sg_uf) = 2 AND
                   v_cd_localidade IS NOT NULL AND
                   v_cd_logradouro IS NOT NULL AND
                   v_nm_logradouro IS NOT NULL AND LENGTH(v_nm_logradouro) > 0 THEN

                    RAISE NOTICE 'Linha processada: nr_cep=%, sg_uf=%, cd_localidade=%, cd_logradouro=%, nm_logradouro=%',
                                 v_nr_cep, v_sg_uf, v_cd_localidade, v_cd_logradouro, v_nm_logradouro;

                    INSERT INTO cep (nr_cep, sg_uf, cd_localidade, cd_bairro, tp_logradouro, nm_patente, nm_preposicao, cd_logradouro, nm_logradouro, nm_abreviatura, ds_info_adicional)
                    VALUES (v_nr_cep, v_sg_uf, v_cd_localidade, NULL, NULL, NULL, NULL, v_cd_logradouro, v_nm_logradouro, NULL, NULL)
                    ON CONFLICT (nr_cep) DO NOTHING; 
                ELSE
                    RAISE NOTICE 'Linha ignorada: Campos inválidos. Linha: %', v_linha;
                END IF;
            ELSE
                RAISE NOTICE 'Linha ignorada: Formato inválido. Linha: %', v_linha;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Erro ao processar linha: %', v_linha;
                CONTINUE;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;