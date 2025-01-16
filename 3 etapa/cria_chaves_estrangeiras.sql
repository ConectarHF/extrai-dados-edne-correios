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