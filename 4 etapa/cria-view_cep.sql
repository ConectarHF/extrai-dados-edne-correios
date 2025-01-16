
CREATE OR REPLACE VIEW vwCep AS
SELECT
    C.nr_cep, 
    C.sg_uf, 
    L.nm_localidade, 
    B.nm_bairro, 
    C.tp_logradouro,
    C.nm_patente, 
    C.nm_preposicao,
    C.nm_logradouro,
    C.nm_abreviatura,
    C.ds_info_adicional,
    b.zona
FROM cep C
JOIN localidade L ON C.cd_localidade = L.cd_localidade
JOIN bairro B ON C.cd_bairro = B.cd_bairro;