CREATE OR REPLACE FUNCTION carregar_paises()
RETURNS VOID AS $$
DECLARE
    v_linha TEXT; 
    v_arquivo BYTEA; 
    v_sg_pais CHAR(2); 
    v_sg_pais_2 CHAR(3); 
    v_nm_pais VARCHAR(72); 
    v_nm_pais_eng VARCHAR(72); 
    v_nm_pais_fra VARCHAR(72); 
BEGIN

    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_PAISES.TXT');

    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 222 THEN
                v_sg_pais := RTRIM(LTRIM(SUBSTRING(v_linha FROM 2 FOR 2))); 
                v_sg_pais_2 := RTRIM(LTRIM(SUBSTRING(v_linha FROM 4 FOR 3))); 
                v_nm_pais_eng := RTRIM(LTRIM(SUBSTRING(v_linha FROM 79 FOR 72))); 
                v_nm_pais_fra := RTRIM(LTRIM(SUBSTRING(v_linha FROM 151 FOR 72))); 

                IF v_sg_pais IS NOT NULL AND LENGTH(v_sg_pais) = 2 AND
                   v_sg_pais_2 IS NOT NULL AND LENGTH(v_sg_pais_2) = 3 AND
                   v_nm_pais IS NOT NULL AND LENGTH(v_nm_pais) > 0 AND
                   v_nm_pais_eng IS NOT NULL AND LENGTH(v_nm_pais_eng) > 0 AND
                   v_nm_pais_fra IS NOT NULL AND LENGTH(v_nm_pais_fra) > 0 THEN

                    RAISE NOTICE 'Linha processada: sg_pais=%, sg_pais_2=%, nm_pais=%, nm_pais_eng=%, nm_pais_fra=%',
                                 v_sg_pais, v_sg_pais_2, v_nm_pais, v_nm_pais_eng, v_nm_pais_fra;

                    INSERT INTO cep.pais (Sg_Pais, Sg_Pais_2, Nm_Pais, Nm_Pais_ENG, Nm_Pais_FRA)
                    VALUES (v_sg_pais, v_sg_pais_2, v_nm_pais, v_nm_pais_eng, v_nm_pais_fra)
                    ON CONFLICT (Sg_Pais) DO NOTHING; 
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