CREATE OR REPLACE FUNCTION carregar_tipos_logradouro()
RETURNS VOID AS $$
DECLARE
    v_linha TEXT;
    v_arquivo BYTEA; 
    v_cd_tipo_logradouro INTEGER; 
    v_tp_logradouro VARCHAR(26); 
    v_tp_logradouro_abrev VARCHAR(15); 
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_TIPOS_LOGRADOURO.TXT');

    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 95 THEN
                v_cd_tipo_logradouro := RTRIM(LTRIM(SUBSTRING(v_linha FROM 5 FOR 3)))::INTEGER; 
                v_tp_logradouro := RTRIM(LTRIM(SUBSTRING(v_linha FROM 8 FOR 26))); 
                v_tp_logradouro_abrev := RTRIM(LTRIM(SUBSTRING(v_linha FROM 80 FOR 15))); 

                IF v_cd_tipo_logradouro IS NOT NULL AND
                   v_tp_logradouro IS NOT NULL AND LENGTH(v_tp_logradouro) > 0 AND
                   v_tp_logradouro_abrev IS NOT NULL AND LENGTH(v_tp_logradouro_abrev) > 0 THEN

                    RAISE NOTICE 'Linha processada: cd_tipo_logradouro=%, tp_logradouro=%, tp_logradouro_abrev=%',
                                 v_cd_tipo_logradouro, v_tp_logradouro, v_tp_logradouro_abrev;

                    INSERT INTO tipo_logradouro (cd_tipo_logradouro, tp_logradouro, tp_logradouro_abrev)
                    VALUES (v_cd_tipo_logradouro, v_tp_logradouro, v_tp_logradouro_abrev)
                    ON CONFLICT (tp_logradouro) DO NOTHING; s
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