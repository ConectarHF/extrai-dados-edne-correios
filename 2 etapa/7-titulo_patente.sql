CREATE OR REPLACE FUNCTION carregar_titulos_patentes()
RETURNS VOID AS $$
DECLARE
    v_linha TEXT; 
    v_arquivo BYTEA; 
    v_cd_titulo_patente INTEGER; 
    v_nm_patente VARCHAR(72); 
    v_nm_patente_abrev VARCHAR(15); 
BEGI
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_TITULOS_PATENTES.TXT');

    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 95 THEN
                v_cd_titulo_patente := RTRIM(LTRIM(SUBSTRING(v_linha FROM 5 FOR 4)))::INTEGER; 
                v_nm_patente := RTRIM(LTRIM(SUBSTRING(v_linha FROM 9 FOR 72))); 
                v_nm_patente_abrev := RTRIM(LTRIM(SUBSTRING(v_linha FROM 81 FOR 15))); 

                IF v_cd_titulo_patente IS NOT NULL AND
                   v_nm_patente IS NOT NULL AND LENGTH(v_nm_patente) > 0 AND
                   v_nm_patente_abrev IS NOT NULL AND LENGTH(v_nm_patente_abrev) > 0 THEN

                    RAISE NOTICE 'Linha processada: cd_titulo_patente=%, nm_patente=%, nm_patente_abrev=%',
                                 v_cd_titulo_patente, v_nm_patente, v_nm_patente_abrev;

                    INSERT INTO titulo_patente (cd_titulo_patente, nm_patente, nm_patente_abrev)
                    VALUES (v_cd_titulo_patente, v_nm_patente, v_nm_patente_abrev)
                    ON CONFLICT (nm_patente) DO NOTHING; 
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