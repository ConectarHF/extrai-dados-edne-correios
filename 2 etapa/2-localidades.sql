CREATE OR REPLACE FUNCTION carregar_localidades()
RETURNS VOID AS $$
DECLARE
    v_linha TEXT; 
    v_arquivo BYTEA; 
    v_nr_cep CHAR(8); 
    v_sg_uf CHAR(2); 
    v_cd_localidade INT; 
    v_nm_localidade VARCHAR(72); 
    v_nm_abreviatura VARCHAR(36); 
BEGIN
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_LOCALIDADES.TXT');

    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 136 THEN
                v_nr_cep := CASE WHEN SUBSTRING(v_linha FROM 92 FOR 8) = '        ' THEN NULL
                                ELSE RTRIM(LTRIM(SUBSTRING(v_linha FROM 92 FOR 8)))
                           END;
                v_sg_uf := RTRIM(LTRIM(SUBSTRING(v_linha FROM 4 FOR 2)));
                v_cd_localidade := RTRIM(LTRIM(SUBSTRING(v_linha FROM 12 FOR 8)))::INT;
                v_nm_localidade := RTRIM(LTRIM(SUBSTRING(v_linha FROM 20 FOR 72)));
                v_nm_abreviatura := RTRIM(LTRIM(SUBSTRING(v_linha FROM 100 FOR 36)));

                IF v_sg_uf IS NOT NULL AND LENGTH(v_sg_uf) = 2 AND
                   v_cd_localidade IS NOT NULL AND
                   v_nm_localidade IS NOT NULL AND LENGTH(v_nm_localidade) > 0 THEN

                    RAISE NOTICE 'Linha processada: nr_cep=%, sg_uf=%, cd_localidade=%, nm_localidade=%, nm_abreviatura=%',
                                 v_nr_cep, v_sg_uf, v_cd_localidade, v_nm_localidade, v_nm_abreviatura;

                    INSERT INTO Localidade (Nr_Cep, Sg_Uf, Cd_Localidade, Nm_Localidade, Nm_Abreviatura)
                    VALUES (v_nr_cep, v_sg_uf, v_cd_localidade, v_nm_localidade, v_nm_abreviatura)
                    ON CONFLICT (Cd_Localidade) DO NOTHING; 
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