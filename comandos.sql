CREATE TABLE contas (
	id serial not null primary key,
	email varchar(100) not null unique,
	senha varchar(255) not null,
	nome varchar(50) not null,
	seguidores int not null default 0,
	descricao varchar(255),
	imagem_perfil bytea,
	imagem_banner bytea
);

CREATE TABLE contas_individuais (
	id serial not null primary key,
	conta_id INTEGER references contas(id) on delete cascade
);

CREATE TABLE certificados(
	id serial not null primary key,
	conta_individual_id INTEGER not null references contas_individuais on delete cascade,
	arquivo_certificado bytea not null
);

CREATE TABLE competencias(
	id serial not null primary key,
	conta_individual_id INTEGER not null references contas_individuais on delete cascade,
	descricao varchar(30)
);

CREATE TABLE contas_empresas (
	id serial not null primary key,
	conta_id INTEGER references contas(id) on delete cascade,
	setor varchar(50) not null,
	cidade_sede varchar(20) not null,
	estado_sede varchar(20) not null,
	pais_sede varchar(20) not null
);

CREATE TABLE seguir (
	id serial not null primary key,
	seguidor INTEGER references contas_individuais(id) on delete cascade,
	seguido INTEGER references contas(id) on delete cascade
);

CREATE TABLE instituicoes_ensino (
	id serial not null primary key,
	empresa_id INTEGER references contas_empresas(id) on delete cascade
);

CREATE TABLE vagas (
	id serial not null primary key,
	nome varchar(50) not null,
	descricao text not null,
	local_vaga varchar(50) not null, -- local é keyword
	modalidade varchar(20) not null
);

CREATE TABLE palavras_chave (
	id serial not null primary key,
	vaga INTEGER references vagas(id) on delete cascade,
	conteudo varchar(20)
);

CREATE TABLE candidaturas (
	id serial not null primary key,
	inscrito INTEGER references contas_individuais(id) on delete cascade,
	vaga INTEGER references vagas(id) on delete cascade
);

CREATE TABLE disponibilizacao (
	id serial not null primary key,
	empresa INTEGER references contas_empresas(id) on delete cascade,
	vaga INTEGER references vagas(id) on delete cascade
);

CREATE TABLE experiencias (
	id serial not null primary key,
	inicio date not null,
	fim date,
	cargo varchar(50) not null,
	titulo varchar(50) not null,
	descricao text,
	empresa INTEGER references contas_empresas(id) on delete set null,
	individuo INTEGER references contas_individuais(id) on delete cascade
);

CREATE TABLE formacao_academica (
	id serial not null primary key,
	inicio date not null,
	fim date,
	diploma varchar(50) not null,
	area_estudo varchar(50) not null,
	descricao text,
	instituicao INTEGER references instituicoes_ensino(id) on delete set null,
	individuo INTEGER references contas_individuais(id) on delete cascade
);

CREATE TABLE posts (
	id serial not null primary key,
	publicador INTEGER not null references contas(id) on delete cascade,
	texto text not null,
	likes int not null default 0,
	data_publicacao date not null
);

CREATE TABLE posts_timeline (
	id serial not null primary key,
	post_id INTEGER not null references posts(id) on delete cascade
);

CREATE TABLE midias_posts (
	id serial not null primary key,
	post INTEGER references posts_timeline(id) on delete cascade,
	arquivo bytea not null,
	extensao varchar(5) not null
);

CREATE TABLE comentarios (
	id serial not null primary key,
	post_self_id INTEGER not null references posts(id) on delete cascade,
	post_commented INTEGER not null references posts(id) on delete cascade
);

CREATE TABLE reacoes (
	id serial not null primary key,
	conta INTEGER not null references contas(id) on delete cascade,
	post INTEGER not null references posts(id) on delete cascade,
	tipo_reacao varchar(9)
);

CREATE TABLE eventos(
	id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    local_evento VARCHAR(50) NOT NULL,
    data_envento DATE NOT NULL,
    horario TIME NOT NULL,
    descricao TEXT NOT NULL,
    link_evento TEXT,
	imagem bytea,
	divulgado_por INTEGER references contas(id) on delete set null
);

CREATE TABLE inscricoes (
	id SERIAL PRIMARY KEY,
	inscrito INTEGER references contas(id) on delete cascade not null,
	evento INTEGER references eventos(id) on delete cascade not null
);


CREATE TABLE newsletters (
	id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
	administrador INTEGER REFERENCES contas(id) ON DELETE SET NULL ON UPDATE CASCADE,
    imagem bytea,              
    descricao TEXT not null,
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT now(),
	num_assinantes INTEGER not null default 0
);


-- Regra de negócio: só pode escrever artigo para newsletter quem administrar ela. Uma única conta administra.

CREATE TABLE artigos (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(300) NOT NULL,
    subtitulo VARCHAR(400),
    conteudo TEXT NOT NULL,
    newsletter_id INTEGER REFERENCES newsletters(id) ON DELETE CASCADE,
	escrito_por INTEGER REFERENCES contas(id) ON DELETE SET NULL,
    publicado_em TIMESTAMP WITH TIME ZONE
);

CREATE TABLE links_artigo(
	id SERIAL PRIMARY KEY,
	artigo_id INTEGER not null references artigos on delete cascade, 
	conteudo_link text not null
);

CREATE TABLE imagens_artigo(
	id SERIAL PRIMARY KEY,
	artigo_id INTEGER not null references artigos on delete cascade,
	arquivo_imagem bytea
);

CREATE TABLE assinaturas (
	id SERIAL PRIMARY KEY,
	inscrito INTEGER REFERENCES contas(id) on delete cascade,
	newsletter INTEGER REFERENCES newsletters(id) on delete cascade
);


-- Junta as contas com suas publicações e suas respectivas reações
CREATE VIEW view_posts_engajamento AS
SELECT 
    p.id AS post_id,
    c.id AS conta_id,
    c.nome AS nome_autor,
    p.texto,
    p.data_publicacao,
    COUNT(r.id) AS total_reacoes
FROM posts p
JOIN contas c ON p.publicador = c.id
LEFT JOIN reacoes r ON r.post = p.id
GROUP BY p.id, c.id, c.nome, p.texto, p.data_publicacao;

CREATE VIEW view_posts_engajamento AS
SELECT 
    p.id AS post_id,
    c.id AS conta_id,
    c.nome AS nome_autor,
    p.texto,
    p.data_publicacao,
    p.likes, 
    COUNT(r.id) AS total_reacoes
FROM posts p
JOIN contas c ON p.publicador = c.id
LEFT JOIN reacoes r ON r.post = p.id
GROUP BY 
    p.id, 
    c.id, 
    c.nome, 
    p.texto, 
    p.data_publicacao, 
    p.likes; 
-- ===================================
-- 		INSTÂNCIAS DE TESTE
-- ===================================

----- CONTAS INDIVIDUAIS --------
-- Primeira conta individual
INSERT INTO contas (id, email, senha, nome, seguidores, descricao)
VALUES (1, 'kauan.rakoski@mail.com', 'senha123', 'Kauan Rakoski', 2, 'Estudante de Ciência da Computação. Especialista em programação web com C.');

INSERT INTO contas_individuais (id, conta_id)
VALUES (1, 1); 

-- Segunda Conta Individual
INSERT INTO contas (id, email, senha, nome, seguidores, descricao)
VALUES (2, 'joao.koller@mail.com', 'senhasegura', 'João Koller', 1, 'Estudante de Matemática Aplicada. Apaixonado por servir sites estáticos altamente escaláveis com kubernetes.');

INSERT INTO contas_individuais (id, conta_id)
VALUES (2, 2);

--Terceira conta individual
INSERT INTO contas (id, email, senha, nome, seguidores, descricao)
VALUES (3, 'bob@biquinibottom.ocean', 'gary', 'Bob Esponja', 3, 'Cozinheiro graduado especializado na produção de hamburguêres artesanais');

INSERT INTO contas_individuais (id, conta_id)
VALUES (3, 3);

-- Quarta conta individual
INSERT INTO contas (id, email, senha, nome, seguidores, descricao)
VALUES (4, 'ww@outlook.com', 'fringedgus', 'Walter White', 1, 'Professor de Química. Gosto de cozinhar no tempo livre.');

INSERT INTO contas_individuais (id, conta_id)
VALUES (4, 4);

-- Quinta conta Individual
INSERT INTO contas (id, nome, email, senha, seguidores, descricao) VALUES
(5, 'Ana Silva', 'ana@email.com', '123', 0, 'Pesquisadora de Comestibilidade de Sabonetes.'),
(6, 'Beto Souza', 'beto@email.com', '456', 0, 'Principal Software Engineer @ SomeStartup'),
(7, 'Carla Dias', 'carla@email.com', '789', 0, 'Professora de Geologia Aplicada');

INSERT INTO contas_individuais (id, conta_id)
VALUES (5, 5);

INSERT INTO contas_individuais (id, conta_id)
VALUES (6, 6);

INSERT INTO contas_individuais (id, conta_id)
VALUES (7, 7);

-- oitava conta individual
INSERT INTO contas (id, email, senha, nome, seguidores, descricao)
VALUES (16, 'wolfgangschuh@gmail.com', 'muenchen', 'Wolfgang Schuh', 0, 'Especialista em IA aplicada à engenharia aeroespacial');

INSERT INTO contas_individuais (id, conta_id)
VALUES (8, 16);

-- nona conta individual
INSERT INTO contas (id, email, senha, nome, seguidores, descricao)
VALUES (17, 'elsas@gmail.com', 'wald', 'Elsa Streit', 0, 'Especialista em restauração de pinturas antigas');

INSERT INTO contas_individuais (id, conta_id)
VALUES (9, 17);


--- DANDO COMPETÊNCIAS PARA NOSSAS CONTAS --------

-- Kauan
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(1, 'C'),
(1, 'Programação Web'),
(1, 'HTML'),
(1, 'Sockets'),
(1, 'Ponteiros'),
(1, 'Gerênciamento de Memória');

-- João
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(2, 'Kubernetes'),
(2, 'Matemática Aplicada'),
(2, 'CI/CD'),
(2, 'Docker'),
(2, 'Helm'),
(2, 'Over-engineering');

-- Bob Esponja
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(3, 'Hambúrguer Gourmet'),
(3, 'Chapeiro'),
(3, 'Molho Secreto'),
(3, 'Fritura'),
(3, 'Atendimento');

-- Walter White
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(4, 'Química Orgânica'),
(4, 'Ensino de Química'),
(4, 'Cristalização'),
(4, 'Empreendedorismo'),
(4, 'Culinária');

-- Ana Silva
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(5, 'Análise Sensorial'),
(5, 'Controle Qualidade'),
(5, 'Química (Polímeros)'),
(5, 'P&D (Higiene)'),
(5, 'Método Científico'),
(5, 'Degustação Técnica');

-- Beto Souza
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(6, 'Liderança Técnica'),
(6, 'Python'),
(6, 'SQL'),
(6, 'IA'),
(6, 'System Design'),
(6, 'DevOps');

-- Carla Dias
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(7, 'Geologia Aplicada'),
(7, 'Ensino Superior'),
(7, 'Geotecnia'),
(7, 'Hidrogeologia'),
(7, 'Pesquisa Acadêmica'),
(7, 'Sensoriamento (GIS)');

-- Wolfgang Schuh
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(8, 'Python'),
(8, 'SQL'),
(8, 'IA'),
(8, 'Mecânica de Aeronaves');

-- Elsa Streit
INSERT INTO competencias (conta_individual_id, descricao) VALUES
(9, 'Restauracao de Pinturas'),

---- INSERINDO CONTAS DE EMPRESAS E INSTITUIÇÕES DE ENSINO ----

-- Google
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(8, 'contact@google.com', 'hash_google_123', 'Google', 150000000, 'Organizando a informação do mundo.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(1, 8, 'Tecnologia', 'Mountain View', 'CA', 'EUA');

-- Github
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(9, 'support@github.com', 'hash_github_456', 'GitHub', 50000000, 'Onde o mundo constrói software.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(2, 9, 'Tecnologia', 'San Francisco', 'CA', 'EUA');

-- Microsoft
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(10, 'hr@microsoft.com', 'hash_msft_789', 'Microsoft', 90000000, 'Empoderando cada pessoa e organização no planeta.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(3, 10, 'Tecnologia', 'Redmond', 'WA', 'EUA');

-- Some Startup
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(11, 'contact@somestartup.io', 'hash_startup_101', 'SomeStartup', 1500, 'Disruptando o paradigma atual com sinergia.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(4, 11, 'Tecnologia', 'Palo Alto', 'CA', 'EUA');

-- Itaú
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(12, 'rh@itau-unibanco.com.br', 'hash_itau_112', 'Itaú Unibanco', 10000000, 'Feito para você.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(5, 12, 'Financeiro', 'São Paulo', 'SP', 'Brasil');

-- UFRGS
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(13, 'vestibular@ufrgs.br', 'hash_ufrgs_131', 'UFRGS', 500000, 'Universidade Federal do Rio Grande do Sul.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(6, 13, 'Educação', 'Porto Alegre', 'RS', 'Brasil');

-- PUC
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(14, 'atendimento@pucrs.br', 'hash_pucrs_141', 'PUCRS', 450000, 'Inovação com mais de 70 anos de tradição.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(7, 14, 'Educação', 'Porto Alegre', 'RS', 'Brasil');

-- Estácio
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(15, 'contato@estacio.br', 'hash_estacio_151', 'Estácio', 2000000, 'Formando para a vida.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(8, 15, 'Educação', 'Rio de Janeiro', 'RJ', 'Brasil');

-- Weingartner jardinagem
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(18, 'weingartner@gmail.br', 'hash_wein_121', 'Weingartner Jardinagem', 0, 'Trazendo o belo ao cotidiano.');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(9, 18, 'jardinagem', 'Munique', 'BV', 'Alemanha');

-- Universität Heidelberg
INSERT INTO contas (id, email, senha, nome, seguidores, descricao) VALUES
(19, 'heidelberg@gmail.com', 'hash_256_h', 'Universitaet Heidelberg', 0, 'Semper Apertus');

INSERT INTO contas_empresas (id, conta_id, setor, cidade_sede, estado_sede, pais_sede) VALUES
(10, 19, 'Ensino', 'Heidelberg', 'BW', 'Alemanha');


-- INSTITUIÇÕES DE ENSINO --
INSERT INTO instituicoes_ensino (id, empresa_id) VALUES
(1, 6), -- ID 6 da tabela contas_empresas (UFRGS)
(2, 7), -- ID 7 da tabela contas_empresas (PUCRS)
(3, 8), -- ID 8 da tabela contas_empresas (Estácio)
(4, 10); -- ID 10 da tabela contas_empresas (Universität Heidelberg)


----- INSERINDO EXPERIÊNCIAS -----
INSERT INTO formacao_academica (id, inicio, fim, diploma, area_estudo, descricao, instituicao, individuo) VALUES
-- Kauan (ID 1)
(1, '2024-03-01', NULL, 'Graduação - Bacharelado', 'Ciência da Computação', 'Foco em Sistemas Operacionais e Redes.', 1, 1),
(8, '2024-06-01', NULL, 'Doutorado', 'Ciência da Computação', 'Operações de Soma de Alta Complexidade Computacional.', 1, 1),
-- João (ID 2)
(2, '2019-03-01', '2024-06-30', 'Graduação', 'Matemática Aplicada', 'Pesquisa em otimização de infraestrutura.', 1, 2),
-- Bob Esponja (ID 3)
(3, '2005-01-10', '2005-01-12', 'Curso Rápido', 'Gastronomia', 'Curso intensivo de 3 dias sobre "O Hambúrguer". Tirei nota máxima.', 3, 3),
-- Walter White (ID 4)
(4, '2000-01-15', '2002-11-20', 'Mestrado', 'Química Inorgânica', 'Dissertação sobre métodos de cristalização.', 2, 4),
-- Ana Silva (ID 5)
(5, '2010-03-01', '2014-06-15', 'Doutorado', 'Química de Polímeros', 'Tese sobre a interação de surfactantes com o paladar humano.', 2, 5),
-- Beto Souza (ID 6)
(6, '2008-08-01', '2011-06-30', 'Tecnólogo', 'Análise de Sistemas', NULL, 3, 6),
-- Carla Dias (ID 7)
(7, '2002-03-01', '2009-12-01', 'Doutorado', 'Geologia Sedimentar', 'Estudo sobre bacias hidrográficas no pré-sal.', 1, 7),
(9, '2000-03-01', '2002-02-15', 'Mestrado', 'Geociências', 'Complex geographic fenomena', 1, 7)
-- Wolfgang Schuh 
(10, '1980-06-30', '1985-09-01', 'Graduação', 'Engenharia Elétrica', 'foco em eletrônica digital', 1, 8),
(11, '2000-06-30', '2002-09-01', 'Mestrado', 'Engenharia Elétrica', 'Pesquisa em aceleradores par IA', 1, 8),
(11, '1990-06-30', '1996-09-01', 'Doutorado', 'Ciência da Computação', 'Estudo sobre bancos de dados avançados para IA', 1, 8);

INSERT INTO experiencias (id, inicio, fim, cargo, titulo, descricao, empresa, individuo) VALUES
-- Kauan (ID 1)
(1, '2022-01-10', '2023-01-10', 'Estagiário', 'Estagiário de TI', 'Manutenção de sistemas legados da universidade.', 6, 1),
(2, '2023-02-01', NULL, 'Dev Jr. (Web C)', 'Programador Web C', 'Desenvolvimento e manutenção do internet banking.', 5, 1),

-- João (ID 2)
(3, '2022-05-01', '2023-05-01', 'Estagiário SRE', 'Estagiário Kubernetes', 'Ajudava a escalar o "Olá, Mundo!" estático da equipe para 1000 pods.', 1, 2),
(4, '2023-06-01', NULL, 'DevOps Pleno', 'Engenheiro de Confiabilidade', 'Garantindo que o GitHub Actions rode liso.', 2, 2),

-- Bob Esponja (ID 3)
(5, '2006-01-01', NULL, 'Chapeiro', 'Mestre Hamburgueiro', 'Responsável pelo cardápio e pela cozinha do refeitório principal (G-Kitchen).', 1, 3),

-- Walter White (ID 4)
(6, '2003-03-01', '2015-01-01', 'Professor', 'Professor Titular de Química', 'Lecionava química básica para turmas de EAD.', 8, 4),
(7, '2015-02-01', NULL, 'Consultor', 'Consultor Químico Estratégico', 'Otimização de processos de "produtos" para uma startup de logística.', 4, 4),

-- Ana Silva (ID 5)
(8, '2015-01-01', NULL, 'Pesquisadora Sênior', 'UX Researcher (Sensorial)', 'Lidero testes A/B de sabor para o "Microsoft Soap", garantindo a melhor (ou pior) experiência de usuário.', 3, 5),

-- Beto Souza (ID 6)
(9, '2012-01-10', '2018-05-30', 'Engenheiro Sênior', 'Arquiteto de Software', 'Desenvolvimento de ferramentas internas no GitHub.', 2, 6),
(10, '2018-06-01', NULL, 'Principal Engineer', 'Principal Software Engineer', 'Liderança técnica e definição da arquitetura da SomeStartup.', 4, 6),

-- Carla Dias (ID 7)
(11, '2010-03-01', NULL, 'Professora', 'Professora Adjunta', 'Lecionando no departamento de Geociências.', 6, 7),

-- Elsa Streit
(12, '1985-09-09', NULL, 'Professora', 'Professora Titular de História', 'Lecionando no departamento de restauração de pinturas.', 10, 9);

--- CRIANDO VAGAS ---
INSERT INTO vagas (id, nome, descricao, local_vaga, modalidade) VALUES
(1, 'Engenheiro de IA', 'Buscamos engenheiro de IA com experiência em Python e SQL para nosso time de Cloud.', 'Redmond (Híbrido)', 'hibrido'),
(2, 'Engenheiro SRE', 'Garantir a confiabilidade dos nossos serviços globais. Necessário Kubernetes.', 'Mountain View', 'presencial'),
(3, 'Gerente de Produto', 'Liderar a estratégia de produto para o Google Workplace. Foco no mercado Latam.', 'São Paulo', 'remoto'),
(4, 'Pesquisador Químico', 'P&D de novos polímeros para hardware. Foco em materiais sustentáveis.', 'Mountain View', 'hibrido'),
(5, 'Dev Sênior (Backend)', 'Manutenção e evolução de microserviços na SomeStartup.', 'Palo Alto (Remoto)', 'remoto'),
(6, 'Dev Mainframe (Cobol)', 'Desenvolvimento e manutenção de sistemas core bancários em Cobol.', 'São Paulo', 'hibrido'),
(7, 'Engenheiro de Cloud', 'Especialista em Azure para migração de sistemas legados.', 'Redmond (Híbrido)', 'hibrido'),
(8, 'UX Designer', 'Designer de Experiência de Usuário para o pacote Office. Foco em acessibilidade.', 'São Paulo', 'remoto'),
(9, 'Professor Adjunto (CC)', 'Professor doutor para o Instituto de Informática. Exige Pós-Doutorado.', 'Porto Alegre', 'presencial'),
(10, 'Técnico de Laboratório', 'Suporte técnico para os laboratórios de TI do Tecnopuc.', 'Porto Alegre', 'presencial'),
(11, 'Tutor EAD (ADM)', 'Tutor para acompanhar turmas de Administração EAD. Desejável mestrado.', 'Rio de Janeiro (Remoto)', 'remoto');

INSERT INTO palavras_chave (id, vaga, conteudo) VALUES
-- Vaga 1 (IA) - Para a Consulta #4
(1, 1, 'IA'),
(2, 1, 'Python'),
(3, 1, 'SQL'),
(4, 1, 'Machine Learning'),
-- Vaga 2 (SRE)
(5, 2, 'Kubernetes'),
(6, 2, 'DevOps'),
(7, 2, 'SRE'),
-- Vaga 4 (Química)
(8, 4, 'Química'),
(9, 4, 'P&D'),
-- Vaga 6 (Mainframe)
(10, 6, 'Cobol'),
(11, 6, 'Mainframe'),
(12, 6, 'Bancos'),
-- Vaga 7 (Cloud MSFT)
(13, 7, 'Azure'),
(14, 7, 'Cloud'),
(15, 7, 'SysAdmin'),
-- Vaga 8 (UX MSFT)
(16, 8, 'UX Design'),
(17, 8, 'Figma'),
(18, 8, 'Acessibilidade'),
-- Vaga 9 (Prof UFRGS)
(19, 9, 'Docência'),
(20, 9, 'Pesquisa'),
(21, 9, 'Computação'),
-- Vaga 10 (Tec PUCRS)
(22, 10, 'Suporte TI'),
(23, 10, 'Redes'),
-- Vaga 11 (Tutor Estácio)
(24, 11, 'EAD'),
(25, 11, 'Tutoria');

INSERT INTO disponibilizacao (id, empresa, vaga) VALUES
-- 3 VAGAS PARA O GOOGLE
(1, 1, 2),
(2, 1, 3),
(3, 1, 4),

-- VAGAS RESTANTES
(4, 3, 1), -- Vaga de IA (Microsoft)
(7, 3, 7), -- Vaga 'Engenheiro de Cloud' (Microsoft)
(8, 3, 8), -- Vaga 'UX Designer' (Microsoft)
(5, 4, 5), -- Vaga Dev Sênior (SomeStartup)
(6, 5, 6), -- Vaga Mainframe (Itaú)

-- VAGAS INSTITUIÇÕES DE ENSINO
(9, 6, 9), -- Vaga 'Professor Adjunto' (UFRGS)
(10, 7, 10), -- Vaga 'Técnico de Laboratório' (PUCRS)
(11, 8, 11); -- Vaga 'Tutor EAD' (Estácio)


-- CANDIDATURAS --
INSERT INTO candidaturas (id, inscrito, vaga) VALUES
-- Beto Souza (ID 6) -> Vaga de IA (ID 1) e Vaga Sênior (ID 5)
(1, 6, 1),
(2, 6, 5),

-- João Koller (ID 2) -> Vaga de SRE (ID 2)
(3, 2, 2),

-- Kauan Rakoski (ID 1) -> Vaga de Mainframe (ID 6) (o desafio!)
(4, 1, 6),

-- Ana Silva (ID 5) -> Vaga de Pesquisa (ID 4)
(5, 5, 4),

-- Carla Dias (ID 7) -> Vaga de Professora (ID 9)
(6, 7, 9),

-- Wolfgang Schuh (ID 8) -> Vaga de IA (ID 1) e Vaga Sênior (ID 5)
(9, 8, 1),
(10, 8, 5),

-- Walter White (ID 4) -> Vaga de Professor (ID 9) e Tutor EAD (ID 11)
(7, 4, 9),
(8, 4, 11);

--- POSTS ---
INSERT INTO posts (id, publicador, texto, likes, data_publicacao) VALUES
-- Beto Souza (ID 6) - Nosso autor engajado (4 posts)
(1, 6, 'System Design é mais sobre tradeoffs do que sobre ferramentas.', 150, '2025-10-01'),
(2, 6, 'Microserviços resolveram 1 problema e criaram 10, mas no fim, valeu a pena.', 240, '2025-10-10'),
(3, 6, 'Estou contratando! Se você é sênior e gosta de desafios reais, veja a vaga na @SomeStartup. #Vaga', 95, '2025-10-15'),
(4, 6, 'A verdadeira escalabilidade começa na modelagem do banco de dados, não no Kubernetes.', 310, '2025-10-20'),

-- Posts de outros usuários
(5, 2, 'Acabei de otimizar meu cluster K8s para rodar um "Hello World" estático. Agora ele escala para 10 mil pods em 0.1s. #overengineering #SRE', 88, '2025-10-05'),
(6, 1, 'Finalizando o módulo de carrinho de compras do e-commerce em C. O cliente disse que "performance é tudo". #WebEmC #CGI', 32, '2025-10-06'),
(7, 3, 'Hambúrguer de Siri: O segredo está no molho. E em não contar o segredo. #Culinária #Gourmet', 2500, '2025-10-11'),
(8, 5, 'Resultados promissores no novo estudo de análise sensorial de surfactantes. O paladar humano é fascinante. #P&D #Química', 60, '2025-10-12'),

-- Posts de Empresas (anunciando vagas)
(9, 8, 'Procurando um SRE para garantir a confiabilidade de bilhões de usuários. #Vaga #Google', 1200, '2025-10-16'),
(10, 10, 'Temos uma vaga incrível para Engenheiro de IA no time de Azure. Venha construir o futuro. #Microsoft #IA', 1150, '2025-10-17'),
(11, 13, 'Nosso vestibular está aberto! E também estamos contratando Professores Doutores. Confira as vagas. #UFRGS', 300, '2025-10-18'),

-- Um post para "comentar" depois
(12, 4, 'Às vezes, a solução para um problema complexo de química é mais simples do que parece.', 45, '2025-10-19');

-- Colocando os posts acima como posts de timeline
INSERT INTO posts_timeline (id, post_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12);

--- REAÇÕES A POSTS ---
INSERT INTO reacoes (id, conta, post, tipo_reacao) VALUES
-- Reações aos posts do Beto (IDs 1, 2, 4) - para torná-lo 'famoso'
(1, 2, 1, 'insight'),  -- João reage ao Beto
(2, 5, 1, 'like'),     -- Ana reage ao Beto
(3, 9, 2, 'celebrar'), -- GitHub reage ao Beto
(4, 2, 4, 'insight'),  -- João reage ao Beto
(5, 4, 4, 'like'),     -- Walter reage ao Beto

-- Reações ao post do Bob Esponja (ID 7) - o post mais popular
(6, 1, 7, 'amei'),
(7, 2, 7, 'amei'),
(8, 4, 7, 'amei'),
(9, 5, 7, 'amei'),
(10, 6, 7, 'like'),
(11, 8, 7, 'like'), -- Google reage ao Bob Esponja
(19, 16, 7, 'like'),
(20, 17, 7, 'like'),
(21, 18, 7, 'like'),

-- Reações aos posts de Vagas (IDs 9, 10)
(12, 6, 10, 'apoio'),  -- Beto reage à vaga da Microsoft
(13, 2, 9, 'like'),   -- João reage à vaga do Google
(14, 1, 9, 'like'),   -- Kauan reage à vaga do Google

-- Reações aleatórias
(15, 7, 8, 'apoio'),  -- Carla reage à Ana
(16, 1, 5, 'celebrar'), -- Kauan reage ao João
(17, 4, 12, 'insight'), -- Walter reage ao seu próprio post (ID 12)
(18, 6, 12, 'insight'); -- Beto reage ao Walter

-- COMENTÁRIOS -- 
INSERT INTO posts (id, publicador, texto, likes, data_publicacao) VALUES
-- ID 13: João (conta 2) a comentar o post 4 do Beto ("escalabilidade começa no BD")
(13, 2, 'Concordo 100%. Estou fazendo a disciplina de Bancos de Dados no momento e já sei tudo sobre SQL.', 12, '2025-10-20'),

-- ID 14: Ana (conta 5) a comentar o post 7 do Bob Esponja ("segredo do molho")
(14, 5, 'Fascinante! Isso tem a ver com a emulsão dos ingredientes? Gostaria de fazer uma análise sensorial disso.', 8, '2025-10-12'),

-- ID 15: Kauan (conta 1) a comentar o post 5 do João ("K8s p/ Hello World")
(15, 1, 'Impressionante. Essa parece uma área próspera.', 5, '2025-10-06');

INSERT INTO comentarios (id, post_self_id, post_commented) VALUES
-- post_self_id (o comentário) | post_commented (o original)
(1, 13, 4), -- João (post 13) comentou no Beto (post 4)
(2, 14, 7), -- Ana (post 14) comentou no Bob Esponja (post 7)
(3, 15, 5); -- Kauan (post 15) comentou no João (post 5)


--- RELAÇÕES DE SEGUIR --- 
INSERT INTO seguir (id, seguidor, seguido) VALUES
-- Kauan (ID 1) segue:
(1, 1, 2),  -- João Koller
(2, 1, 12), -- Itaú (empregador)
(3, 1, 8),  -- Google

-- João (ID 2) segue:
(4, 2, 6),  -- Beto Souza (colega de área)
(5, 2, 8),  -- Google (ex-empregador)
(6, 2, 9),  -- GitHub (empregador)

-- Bob Esponja (ID 3) segue:
(7, 3, 8),  -- Google (empregador)

-- Walter (ID 4) segue:
(8, 4, 11), -- SomeStartup (empregador)
(9, 4, 15), -- Estácio (ex-empregador)

-- Ana (ID 5) segue:
(10, 5, 10), -- Microsoft (empregador)
(11, 5, 6),  -- Beto Souza (interesse em tecnologia)

-- Beto (ID 6) segue:
(12, 6, 11), -- SomeStartup (empregador)
(13, 6, 9),  -- GitHub (ex-empregador)
(14, 6, 2),  -- João Koller

-- Carla (ID 7) segue:
(15, 7, 13), -- UFRGS (empregadora)
(16, 7, 14); -- PUCRS (colega de cidade)


---- POPULANDO EVENTOS ----
INSERT INTO eventos (id, nome, local_evento, data_envento, horario, descricao, link_evento, divulgado_por) VALUES
(1, 'Google I/O Cloud Summit', 'Online', '2025-11-20', '14:00:00', 'O maior evento de Cloud do Google. Novidades em SRE, K8s e IA.', 'https://cloud.google.com/io', 8),
(2, 'Webinar: SRE para Startups', 'Online', '2025-11-25', '19:00:00', 'Como aplicar princípios SRE em equipes pequenas. Evento exclusivo Google.', 'https://cloud.google.com/webinar-sre', 8),
(3, 'Seminário de Geotecnia', 'Auditório UFRGS', '2025-11-28', '09:00:00', 'Apresentação de novas pesquisas em geologia aplicada e sensoriamento.', NULL, 13),
(4, 'SomeStartup Tech Meetup', 'Online', '2025-12-02', '18:00:00', 'Venha conhecer nossa arquitetura e as vagas que temos abertas.', 'https://somestartup.io/meetup', 11);
(5, 'Workshop de Jardinagem', 'Englischer Garten', '2026-01-20', '08:00:00', 'Venha aprender as sublimes técnicas que moldam jardins de palácios', NULL, 18)
INSERT INTO inscricoes (id, inscrito, evento) VALUES
-- Evento 1 (Google I/O) - Alta adesão
(1, 2, 1), -- João
(2, 6, 1), -- Beto
(3, 1, 1), -- Kauan
(4, 5, 1), -- Ana

-- Evento 2 (Webinar Google) - Baixa adesão
(5, 2, 2), -- Apenas o João (Garante que ele se inscreveu em TUDO do Google - Query #12)

-- Evento 3 (Seminário UFRGS)
(6, 7, 3), -- Carla (professora da área)
(7, 1, 3), -- Kauan (aluno da UFRGS)

-- Evento 4 (Meetup SomeStartup)
(8, 6, 4), -- Beto (funcionário)
(9, 4, 4); -- Walter (consultor)

-- Evento 5
(10, 16, 5) -- Wolfgang Schuh
(11, 17, 5) -- Elsa Streit

-- Evento 5 (Workshop de Jardinagem)

--- NEWSLETTERS E ARTIGOS ---
INSERT INTO newsletters (id, nome, administrador, imagem, descricao, num_assinantes) VALUES
(1, 'Engenharia em Contexto', 6, NULL, 'Análises profundas sobre System Design, arquitetura e os tradeoffs da engenharia de software.', 2),
(2, 'O Diário do Chapeiro', 3, NULL, 'Segredos e receitas do Siri Cascudo. O que o Sr. Sirigueijo não quer que você saiba.', 4),
(3, 'Google Tech News', 8, NULL, 'As últimas novidades do Google Cloud, IA, SRE e o futuro da tecnologia.', 2),
(4, 'Cloud Digest', 8, NULL, 'Insights semanais sobre Google Cloud, arquitetura distribuída e novidades em IA generativa.', 5),
(5, 'Tech Open Source Weekly', 9, NULL, 'Atualizações sobre GitHub, projetos open-source emergentes e tendências no ecossistema dev.', 7),
(6, 'A Arte da Jardinagem Moderna', 18, NULL, 'Dicas práticas de paisagismo, manutenção ecológica e tendências da jardinagem urbana sustentável.',3);


INSERT INTO artigos (id, titulo, subtitulo, conteudo, newsletter_id, escrito_por, publicado_em) VALUES
-- Artigo do Beto (ID 6) para a Newsletter 1 (Satisfaz a Consulta #7)
(1, 'O Mito do Monolito: Por que "monolito" não é palavrão', 
 'Uma análise sobre como Monolitos Bem Estruturados superam Microserviços mal planejados.', 
 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...', 
 1, 6, '2025-11-01 10:00:00-03'),

-- Artigo do Bob Esponja (ID 3) para a Newsletter 2
(2, 'A Arte do Hambúrguer Perfeito (Nível Mestre)', 
 'Não é só sobre a carne, é sobre a física da chapa e a química do molho.', 
 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...', 
 2, 3, '2025-11-05 15:30:00-03'),

-- Artigo do Google (ID 8) para a Newsletter 3
(3, 'O Futuro é SRE: Como o Kubernetes mudou nossa forma de pensar infraestrutura', 
 'Uma visão interna de como o Google gerencia confiabilidade em escala planetária.', 
 'Lorem ipsum dolor sit amet, consectetur adipiscing elit...', 
 3, 8, '2025-11-10 09:00:00-03');

INSERT INTO assinaturas (id, inscrito, newsletter) VALUES
-- Pessoal de Tech assina Beto e Google
(1, 2, 1), -- João assina Beto
(2, 5, 1), -- Ana assina Beto
(3, 2, 3), -- João assina Google
(4, 6, 3), -- Beto assina Google (ele mesmo)

-- Todo mundo adora o Bob Esponja
(5, 1, 2), -- Kauan assina Bob
(6, 2, 2), -- João assina Bob
(7, 6, 2), -- Beto assina Bob
(8, 7, 2); -- Carla assina Bob

-- ===================================
-- 		CONSULTAS ESPECIFICADAS
-- ===================================

-- Quais empresas e de quais setores publicaram pelo menos 3 vagas?
SELECT c.nome as empresa, ce.setor, COUNT(d.vaga) as vagas_abertas FROM disponibilizacao as d
	JOIN contas_empresas as ce on ce.id = d.empresa
	JOIN contas as c ON ce.conta_id = c.id
	GROUP BY c.id, c.nome, ce.setor
	HAVING COUNT(d.vaga) >= 3

-- > Nome das pessoas que trabalham em instituições de ensino, seu cargo e título
SELECT c_pessoal.nome, e.cargo, e.titulo, c_inst.nome FROM experiencias as e 
	JOIN contas_individuais as ci on ci.id = e.individuo
	JOIN contas as c_pessoal on ci.conta_id = c_pessoal.id
	JOIN contas_empresas as ce on ce.id = e.empresa
	JOIN instituicoes_ensino as ie on ie.empresa_id = ce.id
	JOIN contas as c_inst on ce.conta_id = c_inst.id
	WHERE e.fim IS NULL

-- Métricas: quantas reações tiveram os posts por autor
SELECT c.id, c.nome as autor, COUNT(reacoes.id) as num_reacoes FROM reacoes
	RIGHT JOIN posts ON reacoes.post = posts.id
	JOIN contas as c ON c.id = posts.publicador
	GROUP BY c.id, c.nome
	ORDER BY COUNT(reacoes.id) DESC;

-- Recrutamento: quais indivíduos possuem todas as competências requeridas para vaga de IA
WITH Conjunto_Alvo AS (
    SELECT 'Python' AS desc_comp UNION ALL
    SELECT 'SQL' AS desc_comp UNION ALL
    SELECT 'IA' AS desc_comp
)

SELECT CI.id, c.nome
FROM contas_individuais CI JOIN contas c on CI.conta_id = c.id
WHERE
    NOT EXISTS (
        SELECT * FROM Conjunto_Alvo A
        WHERE
            NOT EXISTS (
                SELECT * FROM competencias C
                WHERE C.conta_individual_id = CI.id
                  AND C.descricao = A.desc_comp 
            )
    );

-- Inatividade: candidatos que não se inscreveram em nenhuma vaga
SELECT 
    ci.id AS id_individuo,
    c.nome AS nome,
    c.email
FROM contas_individuais ci
JOIN contas c ON c.id = ci.conta_id
WHERE ci.id NOT IN (
    SELECT DISTINCT inscrito
    FROM candidaturas
);


-- Rede: mostre todos os 'indivíduos' (tipo_conta = 'individual') e quem eles seguem (seguir).
SELECT 
    seguidor_conta.nome AS nome_seguidor,
    seguido_conta.nome AS nome_seguido,
    CASE
        WHEN ce.id IS NOT NULL THEN 'empresa'
        ELSE 'individual'
    END AS tipo_conta_seguido
FROM seguir s
JOIN contas_individuais ci ON ci.id = s.seguidor
JOIN contas seguidor_conta ON seguidor_conta.id = ci.conta_id
JOIN contas seguido_conta ON seguido_conta.id = s.seguido
LEFT JOIN contas_empresas ce ON ce.conta_id = s.seguido
ORDER BY seguidor_conta.nome, seguido_conta.nome;


-- Autores engajados: quais artigos foram escritos por autores que publicaram o quase o máximo (max - treshold de 2) de posts publicados por uma conta na plataforma?
SELECT a.titulo, c.nome AS autor 
	FROM artigos AS a
	JOIN contas AS c ON c.id = a.escrito_por
	WHERE a.escrito_por IN (
		SELECT AVG(contagem) FROM (
        SELECT COUNT(*) as contagem FROM posts GROUP BY publicador) as medias
	);


-- Newsletters para recomendar: listar newsletters das top 5 contas com maior engajamento de posts.

WITH top5_engajadas AS (
    SELECT 
        conta_id,
        nome_autor,
        AVG(total_reacoes + likes) AS media_engajamento
    FROM view_posts_engajamento
    GROUP BY conta_id, nome_autor
    ORDER BY media_engajamento DESC
    LIMIT 5
)
SELECT 
    n.id AS id_newsletter,
    n.nome AS nome_newsletter,
    c.nome AS administrador,
    t.media_engajamento
FROM newsletters n
JOIN contas c ON n.administrador = c.id
JOIN top5_engajadas t ON c.id = t.conta_id
ORDER BY t.media_engajamento DESC;


-- Famosos: listar nome, número de seguidores e empresa em que trabalham
-- todos autores de posts cuja média de reações por post é maior que a média geral de engajamento. (UTILIZA A VIEW)
SELECT 
    v.nome_autor,
    c.seguidores,
    c.nome AS empresa_atual,
    ROUND(AVG(v.total_reacoes), 2) AS media_reacoes_autor
FROM view_posts_engajamento v
JOIN contas c ON c.nome = v.nome_autor
LEFT JOIN experiencias e ON e.individuo = c.id
LEFT JOIN contas_empresas ce ON e.empresa = ce.id
GROUP BY v.nome_autor, c.seguidores, c.nome
HAVING AVG(v.total_reacoes) > (
    SELECT AVG(total_reacoes)
    FROM view_posts_engajamento
)
ORDER BY media_reacoes_autor DESC;

SELECT 
    v.nome_autor,
    c_autor.seguidores,
    c_empresa.nome AS empresa_atual,
    ROUND(AVG(v.total_reacoes), 2) AS media_reacoes_autor
FROM view_posts_engajamento v
JOIN contas c_autor ON c_autor.id = v.conta_id
LEFT JOIN contas_individuais ci ON ci.conta_id = c_autor.id
LEFT JOIN experiencias e ON e.individuo = ci.id AND e.fim IS NULL
LEFT JOIN contas_empresas ce ON e.empresa = ce.id
LEFT JOIN contas c_empresa ON c_empresa.id = ce.conta_id
GROUP BY v.nome_autor, c_autor.seguidores, c_empresa.nome
HAVING AVG(v.total_reacoes) > (
    SELECT AVG(total_reacoes)
    FROM view_posts_engajamento
)
ORDER BY media_reacoes_autor DESC;


-- Bons candidatos: listar profissionais que se candidatam a vagas e possuem mais formações que a média
-- Requisito: subconsulta necessária


SELECT 
    ci.id AS id_individuo,
    c.nome AS nome,
    COUNT(DISTINCT fa.id) AS qtd_formacoes
FROM contas_individuais ci
JOIN contas c ON c.id = ci.conta_id
JOIN candidaturas cand ON cand.inscrito = ci.id
LEFT JOIN formacao_academica fa ON fa.individuo = ci.id
GROUP BY ci.id, c.nome
HAVING COUNT(DISTINCT fa.id) > (
    SELECT AVG(num_formacoes)
    FROM (
        SELECT COUNT(DISTINCT fa2.id) AS num_formacoes
        FROM contas_individuais ci2
        JOIN candidaturas cand2 ON cand2.inscrito = ci2.id
        LEFT JOIN formacao_academica fa2 ON fa2.individuo = ci2.id
        GROUP BY ci2.id
    ) AS media_formacao
)
ORDER BY qtd_formacoes DESC;


-- Empresas com engajamento: listar o nome das empresas que divulgam eventos que possuem número de inscrições acima da média (MANTER)
-- 
SELECT 
    ce.setor,
    c.nome AS empresa,
    e.nome AS evento,
    COUNT(i.id) AS total_inscricoes
FROM eventos e
JOIN contas c ON c.id = e.divulgado_por
JOIN contas_empresas ce ON ce.conta_id = c.id
JOIN inscricoes i ON i.evento = e.id
GROUP BY ce.setor, c.nome, e.nome
HAVING COUNT(i.id) > (
    SELECT AVG(sub.total)
    FROM (
        SELECT COUNT(*) AS total
        FROM inscricoes
        GROUP BY evento
    ) AS sub
)
ORDER BY total_inscricoes DESC;


-- Contas interessadas: Contas individuais que se inscreveram em TODOS eventos de pelo menos uma empresa
-- Requisito: todos/nenhum


SELECT DISTINCT
    ci.id AS id_individuo,
    c.nome AS nome_individuo
FROM contas_individuais ci
JOIN contas c ON c.id = ci.conta_id
WHERE EXISTS (
    SELECT 1
    FROM contas_empresas ce
    WHERE NOT EXISTS (
        SELECT e.id
        FROM eventos e
        WHERE e.divulgado_por = ce.conta_id
        
        EXCEPT
        
        SELECT i.evento
        FROM inscricoes i
        WHERE i.inscrito = ci.id
    )
);

--- ========================================
---    			ETAPA 2 FINAL
--- ========================================
-- Recrutamento: quais indivíduos possuem todas as competências requeridas para vaga de IA
-- Requisito: todos/nenhum
WITH Conjunto_Alvo AS (
    SELECT 'Python' AS desc_comp UNION ALL
    SELECT 'SQL' AS desc_comp UNION ALL
    SELECT 'IA' AS desc_comp
)

SELECT CI.id, c.nome
FROM contas_individuais CI JOIN contas c on CI.conta_id = c.id
WHERE
    NOT EXISTS (
        SELECT * FROM Conjunto_Alvo A
        WHERE
            NOT EXISTS (
                SELECT * FROM competencias C
                WHERE C.conta_individual_id = CI.id
                  AND C.descricao = A.desc_comp 
            )
    );

-- Contas interessadas: Contas individuais que se inscreveram em TODOS os eventos divulgados por uma empresa específicas
-- Requisito: todos/nenhum
SELECT 
    ci.id AS id_individuo,
    c.nome AS nome_individuo
FROM contas_individuais ci
JOIN contas c ON c.id = ci.conta_id
WHERE NOT EXISTS (
    SELECT e.id
    FROM eventos e
    JOIN contas_empresas ce ON ce.conta_id = e.divulgado_por
    WHERE ce.id = 1  -- ID da empresa em questão
    EXCEPT
    SELECT i.evento
    FROM inscricoes i
    WHERE i.inscrito = c.id
);

-- Newsletters para recomendar: listar newsletters das top 5 contas com maior engajamento de posts.
-- Requisito: uso de visão

WITH top5_engajadas AS (
    SELECT 
        conta_id,
        nome_autor,
        AVG(total_reacoes + likes) AS media_engajamento
    FROM view_posts_engajamento
    GROUP BY conta_id, nome_autor
    ORDER BY media_engajamento DESC
    LIMIT 5
)
SELECT 
    n.id AS id_newsletter,
    n.nome AS nome_newsletter,
    c.nome AS administrador,
    t.media_engajamento
FROM newsletters n
JOIN contas c ON n.administrador = c.id
JOIN top5_engajadas t ON c.id = t.conta_id
ORDER BY t.media_engajamento DESC;


-- Famosos: listar nome, número de seguidores e empresa em que trabalham
-- todos autores de posts cuja média de reações por post é maior que a média geral de engajamento. (UTILIZA A VIEW)
-- Requisitos: uso de visão, group by, having e subconsulta necessária
SELECT 
    v.nome_autor,
    c.seguidores,
    c.nome AS empresa_atual,
    ROUND(AVG(v.total_reacoes), 2) AS media_reacoes_autor
FROM view_posts_engajamento v
JOIN contas c ON c.id = v.conta_id
LEFT JOIN experiencias e ON e.individuo = c.id
LEFT JOIN contas_empresas ce ON e.empresa = ce.id
GROUP BY v.nome_autor, c.seguidores, c.nome
HAVING AVG(v.total_reacoes) > (
    SELECT AVG(total_reacoes)
    FROM view_posts_engajamento
)
ORDER BY media_reacoes_autor DESC;

-- Bons candidatos: listar profissionais que se candidatam a vagas e possuem mais formações que a média 
-- Requisitos: subconsulta necessária
SELECT 
    ci.id AS id_individuo,
    c.nome AS nome,
    COUNT(fa.id) AS qtd_formacoes
FROM contas_individuais ci
JOIN contas c ON c.id = ci.conta_id
JOIN candidaturas cand ON cand.inscrito = ci.id
LEFT JOIN formacao_academica fa ON fa.individuo = ci.id
GROUP BY ci.id, c.nome
HAVING COUNT(fa.id) > (
    SELECT AVG(num_formacoes)
    FROM (
        SELECT COUNT(fa2.id) AS num_formacoes
        FROM contas_individuais ci2
        JOIN candidaturas cand2 ON cand2.inscrito = ci2.id
        LEFT JOIN formacao_academica fa2 ON fa2.individuo = ci2.id
        GROUP BY ci2.id
    ) AS media_formacao
)
ORDER BY qtd_formacoes DESC;

-- > Nome das pessoas que trabalham em instituições de ensino, seu cargo e título
-- Requisitos: nenhum em especifico, mas adiciona tabelas e variedade, além de ser mais comum
SELECT c_pessoal.nome, e.cargo, e.titulo, c_inst.nome FROM experiencias as e 
	JOIN contas_individuais as ci on ci.id = e.individuo
	JOIN contas as c_pessoal on ci.conta_id = c_pessoal.id
	JOIN contas_empresas as ce on ce.id = e.empresa
	JOIN instituicoes_ensino as ie on ie.empresa_id = ce.id
	JOIN contas as c_inst on ce.conta_id = c_inst.id
	WHERE e.fim IS NULL


-- Rede: Listar indivíduos e quem eles seguem, identificando se o seguido é empresa ou pessoa
SELECT 
    seguidor_conta.nome AS nome_seguidor,
    seguido_conta.nome AS nome_seguido,
    CASE 
        WHEN ce.id IS NOT NULL THEN 'Empresa' 
        ELSE 'Individual' 
    END AS tipo_conta_seguido
FROM seguir s
JOIN contas_individuais ci ON ci.id = s.seguidor
JOIN contas seguidor_conta ON seguidor_conta.id = ci.conta_id
JOIN contas seguido_conta ON seguido_conta.id = s.seguido
LEFT JOIN contas_empresas ce ON ce.conta_id = s.seguido
ORDER BY seguidor_conta.nome;

-- Recordistas: Artigos escritos por autores que atingiram o número MÁXIMO de posts da plataforma
SELECT a.titulo, c.nome AS autor 
FROM artigos AS a
JOIN contas AS c ON c.id = a.escrito_por
WHERE a.escrito_por IN (
    SELECT p.publicador
    FROM posts p
    GROUP BY p.publicador
    HAVING COUNT(p.id) = (
        -- Subconsulta Obrigatória: Descobre o teto (Recorde)
        SELECT MAX(contagem) 
        FROM (
            SELECT COUNT(*) as contagem FROM posts GROUP BY publicador
        ) as maximos
    )
);

-- Mercado: Quais empresas (e seus setores) estão contratando agressivamente (3 ou mais vagas)?
SELECT 
    c.nome as empresa, 
    ce.setor, 
    COUNT(d.vaga) as vagas_abertas 
FROM disponibilizacao as d
JOIN contas_empresas as ce on ce.id = d.empresa
JOIN contas as c ON ce.conta_id = c.id
GROUP BY c.id, c.nome, ce.setor
HAVING COUNT(d.vaga) >= 3
ORDER BY vagas_abertas DESC;

-- Ociosos: Candidatos que existem no sistema mas nunca se candidataram a nada
SELECT 
    c.nome, 
    c.email 
FROM contas_individuais ci
JOIN contas c ON c.id = ci.conta_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM candidaturas cand 
    WHERE cand.inscrito = ci.id
);

--- ========================================
---    			ETAPA 3
--- ========================================


CREATE FUNCTION fn_atualizar_contador_seguidores()
	RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN   
    IF (TG_OP = 'INSERT') THEN
        UPDATE contas 
        SET seguidores = seguidores + 1 
        WHERE id = NEW.seguido;
        
        RETURN NEW;
        
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE contas 
        SET seguidores = seguidores - 1 
        WHERE id = OLD.seguido;
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END $$


CREATE TRIGGER trg_contador_seguidores
    AFTER INSERT OR DELETE ON seguir
    FOR EACH ROW
    EXECUTE FUNCTION fn_atualizar_contador_seguidores();



CREATE FUNCTION fn_atualizar_contador_assinantes()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE newsletters 
        SET num_assinantes = num_assinantes + 1 
        WHERE id = NEW.newsletter; 
        
        RETURN NEW;
        
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE newsletters 
        SET num_assinantes = num_assinantes - 1 
        WHERE id = OLD.newsletter; 
        
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_contador_assinantes
    AFTER INSERT OR DELETE ON assinaturas
    FOR EACH ROW                         
    EXECUTE FUNCTION fn_atualizar_contador_assinantes(); 

-- IDEIA DE PROCEDURE NÃO TRIVIAL: MODERAÇÃO - DADO UM USUÁRIO, VERIFICAR SE HÁ ESCRITAS
-- ILÍCITAS EM SUA DESCRIÇÃO/COMPETÊNCIAS/POSTS (TIPO PORNOGRAFIA OU PALAVRÕES) E DELETAR 
-- A CONTA CASO ISSO OCORRA.

SELECT N.NOME, N.DESCRICAO, NUM_ASSINANTES, C.NOME
	FROM NEWSLETTERS N JOIN CONTAS C ON N.ADMINISTRADOR = C.ID;


create or replace function processa_inscricao()
returns trigger as $$
BEGIN

IF exists(
    select 1
    from inscricoes
    where inscrito = NEW.inscrito
    and evento = NEW.evento
) THEN
    raise exception "Usuario ja inscrito nesse evento!";
END IF;

RETURN NEW;
END;
$$ language plpsql;

CREATE TRIGGER trg_processa_inscricao
    BEFORE INSERT ON inscricoes
    FOR EACH ROW
    EXECUTE FUNCTION processa_inscricao();


CREATE OR REPLACE FUNCTION fn_gerenciar_assinaturas_newsletter()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_id INTEGER; 
BEGIN
    
    IF (TG_OP = 'INSERT') THEN
        
        -- Busca quem é o administrador dessa newsletter específica
        SELECT administrador INTO v_admin_id
        FROM newsletters
        WHERE id = NEW.newsletter;

        -- Se quem está tentando assinar (NEW.inscrito) for o dono (v_admin_id)
        IF (v_admin_id IS NOT NULL AND NEW.inscrito = v_admin_id) THEN
            RAISE EXCEPTION 'Regra de Negócio: O administrador não pode assinar a própria newsletter.';
        END IF;

        -- Se passou na validação, atualiza o contador (+1)
        UPDATE newsletters
        SET num_assinantes = num_assinantes + 1
        WHERE id = NEW.newsletter;
        
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
    
        UPDATE newsletters
        SET num_assinantes = GREATEST(num_assinantes - 1, 0)
        WHERE id = OLD.newsletter;
        
        RETURN OLD;
        
    END IF;

    RETURN NULL;
END $$;


CREATE TRIGGER trg_processa_assintura
    BEFORE INSERT OR DELETE ON assinaturas
    FOR EACH ROW
    EXECUTE FUNCTION fn_gerenciar_assinaturas_newsletter();