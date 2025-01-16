-- Atualiza Zona Norte
UPDATE bairro
SET zona = 'Zona Norte'
WHERE cd_localidade = 7043
AND nm_bairro IN (
    'Abolição', 'Acari', 'Água Santa', 'Aldeia Campista', 'Anchieta', 'Andaraí', 'Bancários', 'Barros Filho', 'Bento Ribeiro', 
    'Bonsucesso', 'Brás de Pina', 'Cachambi', 'Cacuia', 'Campinho', 'Cascadura', 'Cavalcanti', 'Cidade Universitária', 
    'Coelho Neto', 'Colégio', 'Complexo do Alemão', 'Cordovil', 'Costa Barros', 'Del Castilho', 'Encantado', 'Engenheiro Leal', 
    'Engenho da Rainha', 'Engenho de Dentro', 'Engenho Novo', 'Freguesia (Ilha do Governador)', 'Galeão', 'Grajaú', 'Guadalupe', 
    'Higienópolis', 'Honório Gurgel', 'Inhaúma', 'Irajá', 'Jacaré', 'Jacarezinho', 'Jardim América', 'Jardim Carioca', 
    'Jardim Guanabara', 'Lins de Vasconcelos', 'Madureira', 'Manguinhos', 'Maracanã', 'Marechal Hermes', 'Maria da Graça', 
    'Méier', 'Moneró', 'Oswaldo Cruz', 'Parada de Lucas', 'Parque Anchieta', 'Parque Colúmbia', 'Pavuna', 'Penha', 
    'Penha Circular', 'Piedade', 'Pilares', 'Quintino Bocaiúva', 'Ramos', 'Riachuelo', 'Ricardo de Albuquerque', 'Rocha', 
    'Rocha Miranda', 'Sampaio', 'São Cristóvão', 'São Francisco Xavier', 'Tauá', 'Tijuca', 'Todos os Santos', 'Tomás Coelho', 
    'Turiaçu', 'Vaz Lobo', 'Vicente de Carvalho', 'Vigário Geral', 'Vila da Penha', 'Vila Isabel', 'Vila Kosmos', 'Vista Alegre'
);

-- Atualiza Zona Sul
UPDATE bairro
SET zona = 'Zona Sul'
WHERE cd_localidade = 7043
AND nm_bairro IN (
    'Botafogo', 'Catete', 'Copacabana', 'Cosme Velho', 'Flamengo', 'Gávea', 'Glória', 'Humaitá', 'Ipanema', 'Jardim Botânico', 
    'Lagoa', 'Laranjeiras', 'Leblon', 'Leme', 'Rio Comprido', 'Santa Teresa', 'São Conrado', 'Urca', 'Vidigal'
);

-- Atualiza Zona Oeste
UPDATE bairro
SET zona = 'Zona Oeste'
WHERE cd_localidade = 7043
AND nm_bairro IN (
    'Anil', 'Bangu', 'Barra da Tijuca', 'Barra de Guaratiba', 'Camorim', 'Campo Grande', 'Cidade de Deus', 'Cosmos', 'Curicica', 
    'Deodoro', 'Freguesia (Jacarepaguá)', 'Gardênia Azul', 'Grumari', 'Guaratiba', 'Inhoaíba', 'Itanhangá', 'Jacarepaguá', 
    'Jardim Sulacap', 'Joá', 'Magalhães Bastos', 'Padre Miguel', 'Pechincha', 'Pedra de Guaratiba', 'Realengo', 
    'Recreio dos Bandeirantes', 'Santa Cruz', 'Santíssimo', 'Senador Camará', 'Senador Vasconcelos', 'Sepetiba', 'Tanque', 
    'Taquara', 'Vargem Grande', 'Vargem Pequena', 'Vila Militar', 'Vila Valqueire'
);

-- Atualiza Zona Central
UPDATE bairro
SET zona = 'Zona Central'
WHERE cd_localidade = 7043
AND nm_bairro IN (
    'Benfica', 'Caju', 'Castelo', 'Centro', 'Cidade Nova', 'Estácio', 'Gamboa', 'Glória', 'Lapa', 'Mangueira', 'Paquetá', 
    'Praça da Bandeira', 'Praça XV', 'Praça Mauá', 'Santa Teresa', 'Santo Cristo', 'Saúde', 'Vasco da Gama'
);