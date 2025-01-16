CREATE OR REPLACE FUNCTION carregar_logradouros()
RETURNS VOID AS $$
DECLARE
    v_arquivo_nome TEXT;     -- Nome do arquivo atual
    v_arquivo BYTEA;         -- Conteúdo do arquivo atual
    v_linha TEXT;            -- Linha do arquivo
    file_list TEXT[] := ARRAY[
        'DNE_GU_AC_LOGRADOUROS.TXT',
        'DNE_GU_AL_LOGRADOUROS.TXT',
        'DNE_GU_AM_LOGRADOUROS.TXT',
        'DNE_GU_AP_LOGRADOUROS.TXT',
        'DNE_GU_BA_LOGRADOUROS.TXT',
        'DNE_GU_CE_LOGRADOUROS.TXT',
        'DNE_GU_DF_LOGRADOUROS.TXT',
        'DNE_GU_ES_LOGRADOUROS.TXT',
        'DNE_GU_GO_LOGRADOUROS.TXT',
        'DNE_GU_MA_LOGRADOUROS.TXT',
        'DNE_GU_MG_LOGRADOUROS.TXT',
        'DNE_GU_MS_LOGRADOUROS.TXT',
        'DNE_GU_MT_LOGRADOUROS.TXT',
        'DNE_GU_PA_LOGRADOUROS.TXT',
        'DNE_GU_PB_LOGRADOUROS.TXT',
        'DNE_GU_PE_LOGRADOUROS.TXT',
        'DNE_GU_PI_LOGRADOUROS.TXT',
        'DNE_GU_PR_LOGRADOUROS.TXT',
        'DNE_GU_RJ_LOGRADOUROS.TXT',
        'DNE_GU_RN_LOGRADOUROS.TXT',
        'DNE_GU_RO_LOGRADOUROS.TXT',
        'DNE_GU_RR_LOGRADOUROS.TXT',
        'DNE_GU_RS_LOGRADOUROS.TXT',
        'DNE_GU_SC_LOGRADOUROS.TXT',
        'DNE_GU_SE_LOGRADOUROS.TXT',
        'DNE_GU_SP_LOGRADOUROS.TXT',
        'DNE_GU_TO_LOGRADOUROS.TXT'
    ]; -- Lista de arquivos a serem processados
BEGIN
    -- Iterar sobre cada arquivo na lista
    FOREACH v_arquivo_nome IN ARRAY file_list LOOP
        BEGIN
            RAISE NOTICE 'Processando arquivo: %', v_arquivo_nome;

            -- Lê o arquivo como BYTEA (binário)
            v_arquivo := pg_read_binary_file('/home/Davi/Documentos/Conectar/base_correis_edne/eDNE_Master_24122/Fixo/' || v_arquivo_nome);
            RAISE NOTICE 'Arquivo % lido com sucesso. Tamanho: % bytes', v_arquivo_nome, LENGTH(v_arquivo);

            -- Converte o conteúdo do arquivo para texto usando a codificação LATIN1
            FOR v_linha IN SELECT unnest(string_to_array(convert_from(v_arquivo, 'LATIN1'), E'\n')) LOOP
                BEGIN
                    RAISE NOTICE 'Processando linha: %', v_linha;

                    -- Verifica se a linha começa com 'D' e tem o comprimento mínimo esperado
                    IF SUBSTRING(v_linha FROM 1 FOR 1) = 'D' AND LENGTH(v_linha) >= 519 THEN
                        RAISE NOTICE 'Linha válida detectada. Extraindo dados...';

                        -- Insere os dados na tabela `cep` com base nas posições especificadas
                        INSERT INTO cep (
                            nr_cep, sg_uf, cd_localidade, cd_bairro, 
                            tp_logradouro, nm_patente, nm_preposicao, 
                            cd_logradouro, nm_logradouro, nm_abreviatura, 
                            ds_info_adicional
                        ) VALUES (
                            RTRIM(LTRIM(SUBSTRING(v_linha FROM 519 FOR 8))),       -- nr_cep
                            RTRIM(LTRIM(SUBSTRING(v_linha FROM 2 FOR 2))),        -- sg_uf
                            CAST(RTRIM(LTRIM(SUBSTRING(v_linha FROM 10 FOR 8))) AS INTEGER),  -- cd_localidade (convertido para integer)
                            CAST(RTRIM(LTRIM(SUBSTRING(v_linha FROM 95 FOR 8))) AS INTEGER),  -- cd_bairro (convertido para integer)
                            CASE WHEN SUBSTRING(v_linha FROM 260 FOR 26) = LPAD('', 26, ' ') 
                                THEN NULL 
                                ELSE RTRIM(LTRIM(SUBSTRING(v_linha FROM 260 FOR 26))) 
                            END,                                                 -- tp_logradouro
                            CASE WHEN SUBSTRING(v_linha FROM 289 FOR 72) = LPAD('', 72, ' ') 
                                THEN NULL 
                                ELSE RTRIM(LTRIM(SUBSTRING(v_linha FROM 289 FOR 72))) 
                            END,                                                 -- nm_patente
                            CASE WHEN SUBSTRING(v_linha FROM 286 FOR 3) = LPAD('', 3, ' ') 
                                THEN NULL 
                                ELSE RTRIM(LTRIM(SUBSTRING(v_linha FROM 286 FOR 3))) 
                            END,                                                 -- nm_preposicao
                            CAST(RTRIM(LTRIM(SUBSTRING(v_linha FROM 367 FOR 8))) AS INTEGER),  -- cd_logradouro (convertido para integer)
                            RTRIM(LTRIM(SUBSTRING(v_linha FROM 375 FOR 72))),     -- nm_logradouro
                            RTRIM(LTRIM(SUBSTRING(v_linha FROM 447 FOR 36))),     -- nm_abreviatura
                            CASE WHEN SUBSTRING(v_linha FROM 483 FOR 36) = LPAD('', 36, ' ') 
                                THEN NULL 
                                ELSE RTRIM(LTRIM(SUBSTRING(v_linha FROM 483 FOR 36))) 
                            END                                                  -- ds_info_adicional
                        );

                        RAISE NOTICE 'Dados inseridos com sucesso para a linha: %', v_linha;
                    ELSE
                        -- Log de erro para linhas que não atendem aos critérios
                        RAISE NOTICE 'Linha ignorada: % no arquivo %', v_linha, v_arquivo_nome;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        -- Log de erro, mas continua o processamento
                        RAISE NOTICE 'Erro ao processar linha: % no arquivo %. Detalhes: %', v_linha, v_arquivo_nome, SQLERRM;
                        CONTINUE;
                END;
            END LOOP;

            RAISE NOTICE 'Arquivo % processado com sucesso.', v_arquivo_nome;
        EXCEPTION
            WHEN OTHERS THEN
                -- Log de erro para arquivos
                RAISE NOTICE 'Erro ao processar arquivo: %. Detalhes: %', v_arquivo_nome, SQLERRM;
                CONTINUE;
        END;
    END LOOP;

    RAISE NOTICE 'Processamento concluído.';
END;
$$ LANGUAGE plpgsql;