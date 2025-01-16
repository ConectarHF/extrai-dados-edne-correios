CREATE OR REPLACE FUNCTION carregar_todos_dados()
RETURNS VOID AS $$
BEGIN

    -- A execução completa exige bastante da memoria da máquina

    RAISE NOTICE 'Iniciando carregamento de paises...';
    PERFORM carregar_paises();
    RAISE NOTICE 'Carregamento de paises concluído.';

    RAISE NOTICE 'Iniciando carregamento de localidades...';
    PERFORM carregar_localidades();
    RAISE NOTICE 'Carregamento de localidades concluído.';

    RAISE NOTICE 'Iniciando carregamento de bairros...';
    PERFORM carregar_bairros();
    RAISE NOTICE 'Carregamento de bairros concluído.';

    RAISE NOTICE 'Iniciando carregamento de estados...';
    PERFORM carregar_estados();
    RAISE NOTICE 'Carregamento de estados concluído.';

    RAISE NOTICE 'Iniciando carregamento de logradouros...';
    PERFORM carregar_logradouros();
    RAISE NOTICE 'Carregamento de logradouros concluído.';

    RAISE NOTICE 'Iniciando carregamento de tipo logradouros...';
    PERFORM carregar_tipos_logradouros();
    RAISE NOTICE 'Carregamento de tipo logradouros concluído.';

    RAISE NOTICE 'Iniciando carregamento de titulo patentes...';
    PERFORM carregar_titulos_patentes();
    RAISE NOTICE 'Carregamento de titulo patentes concluído.';

    RAISE NOTICE 'Iniciando carregamento de grandes usuarios()...';
    PERFORM carregar_cep_grandes_usuarios();
    RAISE NOTICE 'Carregamento de grandes usuarios concluído.';

    RAISE NOTICE 'Iniciando carregamento de caixas postais...';
    PERFORM carregar_cep_caixas_postais();
    RAISE NOTICE 'Carregamento de caixas postais concluído.';

    RAISE NOTICE 'Todos os carregamentos foram concluídos com sucesso.';
END;
$$ LANGUAGE plpgsql;