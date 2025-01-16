CREATE OR REPLACE FUNCTION carregar_estados()
RETURNS VOID AS $$
DECLARE
    v_linha TEXT; 
    v_arquivo BYTEA; 
    v_sg_pais CHAR(2); 
    v_cd_uf INTEGER; 
    v_nm_estado VARCHAR(72); 
BEGIN
    v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/DNE_GU_UNIDADES_FEDERACAO.TXT');

    FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
        BEGIN
            IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 84 THEN
                v_sg_pais := RTRIM(LTRIM(SUBSTRING(v_linha FROM 2 FOR 2))); 
                v_sg_uf := RTRIM(LTRIM(SUBSTRING(v_linha FROM 4 FOR 2))); 
                v_cd_uf := RTRIM(LTRIM(SUBSTRING(v_linha FROM 8 FOR 2)))::INTEGER; 
                v_nm_estado := RTRIM(LTRIM(SUBSTRING(v_linha FROM 10 FOR 72))); 

                IF v_sg_pais IS NOT NULL AND LENGTH(v_sg_pais) = 2 AND
                   v_sg_uf IS NOT NULL AND LENGTH(v_sg_uf) = 2 AND
                   v_cd_uf IS NOT NULL AND
                   v_nm_estado IS NOT NULL AND LENGTH(v_nm_estado) > 0 THEN

                    RAISE NOTICE 'Linha processada: sg_pais=%, sg_uf=%, cd_uf=%, nm_estado=%',
                                 v_sg_pais, v_sg_uf, v_cd_uf, v_nm_estado;
                    INSERT INTO estado (sg_pais, sg_uf, cd_uf, nm_estado)
                    VALUES (v_sg_pais, v_sg_uf, v_cd_uf, v_nm_estado)
                    ON CONFLICT (sg_uf) DO NOTHING;
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