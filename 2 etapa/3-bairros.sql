CREATE OR REPLACE FUNCTION carregar_bairros()
RETURNS VOID AS $$
DECLARE
	v_linha TEXT;
	v_arquivo BYTEA;
	v_sg_uf CHAR(2);
	v_cd_localidade INT;
	v_cd_bairro INT;
	v_nm_bairro VARCHAR(72);
	v_nm_bairro_abrev VARCHAR(36);
	v_zona VARCHAR(255);
BEGIN
	v_arquivo := pg_read_binary_file('DNE_GU_BAIRROS.TXT');

	FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
		BEGIN
			IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 210 THEN
				v_sg_uf := RTRIM(LTRIM(SUBSTRING(v_linha FROM 2 FOR 2)));
				v_cd_localidade := RTRIM(LTRIM(SUBSTRING(v_linha FROM 10 FOR 8)))::INT;
				v_cd_bairro := RTRIM(LTRIM(SUBSTRING(v_linha FROM 95 FOR 8)))::INT;
				v_nm_bairro := RTRIM(LTRIM(SUBSTRING(v_linha FROM 103 FOR 72)));
				v_nm_bairro_abrev := RTRIM(LTRIM(SUBSTRING(v_linha FROM 175 FOR 36)));
				v_zona := CASE
					WHEN LENGTH(v_linha) >= 211 AND RTRIM(LTRIM(SUBSTRING(v_linha FROM 211 FOR 1))) <> ''
						THEN RTRIM(LTRIM(SUBSTRING(v_linha FROM 211 FOR 1)))
					ELSE NULL
				END;

				IF v_sg_uf IS NOT NULL AND LENGTH(v_sg_uf) = 2 AND
				   v_cd_localidade IS NOT NULL AND
				   v_cd_bairro IS NOT NULL AND
				   v_nm_bairro IS NOT NULL AND LENGTH(v_nm_bairro) > 0 THEN

					RAISE NOTICE 'Linha processada: sg_uf=%, cd_localidade=%, cd_bairro=%, nm_bairro=%, nm_bairro_abrev=%, zona=%',
								 v_sg_uf, v_cd_localidade, v_cd_bairro, v_nm_bairro, v_nm_bairro_abrev, v_zona;

					INSERT INTO bairro (sg_uf, cd_localidade, cd_bairro, nm_bairro, nm_bairro_abrev, zona)
					VALUES (v_sg_uf, v_cd_localidade, v_cd_bairro, v_nm_bairro, v_nm_bairro_abrev, v_zona)
					ON CONFLICT (cd_bairro) DO NOTHING;
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
