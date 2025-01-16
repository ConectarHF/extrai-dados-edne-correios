Ao gerar uma chave estrangeira para tabela cep, 
tive que alterar dois registros do arquivo:
DNE_GU_TIPOS_LOGRADOURO.TXT


Erro SQL [23503]: ERROR: insert or update on table "cep" violates foreign key constraint "fk_cep_tipo_logradouro"
  Detalhe: Key (tp_logradouro)=(Travessa de Pedestre) is not present in table "tipo_logradouro".

Erro SQL [23503]: ERROR: insert or update on table "cep" violates foreign key constraint "fk_cep_tipo_logradouro"
  Detalhe: Key (tp_logradouro)=(Centro administrativo) is not present in table "tipo_logradouro".

 foi adicionado NULL nas linhas no arquivo

 depois retirei para ajustar a demanda