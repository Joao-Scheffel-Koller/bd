import psycopg2
import time
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt, IntPrompt,Confirm
from rich.table import Table
from rich.rule import Rule

# --- Constantes de Comando ---
SHOULD_STOP_OPTION = 0
COMMAND_DEFAULT_CONSULTAS = 1
COMMAND_CREATE_ACCOUNT = 2
COMMAND_SEE_FOLLOWERS_NUMBER = 3
COMMAND_FOLLOW_USER = 4      
COMMAND_SUBSCRIBE_NEWSLETTER = 5
DELETE_ACCOUNT = 6
UPDATE_ACCOUNT_DESCRIPTION = 7
SEE_ALL_ACCOUNTS = 8

console = Console()

def main(cursor, connection):
    """Loop principal da aplicação."""
    should_stop = False
    
    while not should_stop:
        option = get_input()
        
        if option is not SHOULD_STOP_OPTION:
            treat_input(option, cursor, connection)
            console.print("\n" + "-"*30 + "\n")
        else:
            should_stop = True
    
    console.print("[bold yellow]Encerrando...[/bold yellow]")

def get_input():
    """Exibe o menu, captura e retorna a entrada do usuário."""
    menu_texto = """
    [cyan]1[/cyan] - Ver Consultas Padrão (Etapa II)
    [cyan]2[/cyan] - Criar Nova Conta
    [cyan]3[/cyan] - Ver número de assinantes de uma newsletter
    [cyan]4[/cyan] - Seguir um Usuário
    [cyan]5[/cyan] - Assinar Newsletter
    [cyan]6[/cyan] - Deletar uma conta
    [cyan]7[/cyan] - Alterar a descrição de uma conta
    [cyan]8[/cyan] - Ver todas contas registradas no sistema

    [red]0[/red] - Sair
    """
    
    console.print(
        Panel.fit(
            menu_texto, 
            title="[bold blue]Menu Principal[/bold blue]", 
            border_style="blue"
        )
    )
    
    choice_str = Prompt.ask(
        "[bold]Escolha uma opção[/bold]",
        choices=["0", "1", "2", "3", "4", "5", "6", "7", "8"],
        default="0"
    )
    return int(choice_str)

def treat_input(option, cursor, connection):
    """
    Usa if/elif/else para despachar o comando.
    (Isso corrige os erros do Pylance sobre 'match')
    """
    if option == COMMAND_DEFAULT_CONSULTAS:
        process_default_queries_input(cursor)
        
    elif option == COMMAND_CREATE_ACCOUNT:
        process_create_account(cursor, connection)
    
    elif option == COMMAND_SEE_FOLLOWERS_NUMBER:
        show_followers_number(cursor)
        
    elif option == COMMAND_FOLLOW_USER:
        process_follow_user(cursor, connection)
        
    elif option == COMMAND_SUBSCRIBE_NEWSLETTER:
        process_subscribe_newsletter(cursor, connection)
        
    elif option == DELETE_ACCOUNT:
        delete_account(cursor, connection)

    elif option == UPDATE_ACCOUNT_DESCRIPTION:
        update_account_desc(cursor, connection)

    elif option == SEE_ALL_ACCOUNTS:
        _list_accounts_for_delete(cursor)
    else:
        console.print("[bold red]Opção desconhecida.[/bold red]")

def show_followers_number(cursor):
    
    
    try:
        cursor.execute("SELECT id, nome, num_assinantes FROM Newsletters ORDER BY id;")
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print(f"[yellow]Não há contas no sistema.[/yellow]")
            return

        table = Table(title=f"Usuários e seus seguidores")
        table.add_column("id", style="cyan", no_wrap=True)
        table.add_column("Nome", style="green")
        table.add_column("Número de Seguidores", style="magenta", justify="right")
        
        for linha in resultados:
            table.add_row(str(linha[0]), linha[1], str(linha[2]))
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def process_default_queries_input(cursor):
    menu_texto = """
    [cyan]1[/cyan] - Quais empresas e de quais setores publicaram pelo menos x vagas?
    [cyan]2[/cyan] - Nome das pessoas que trabalham em instituições de ensino, seu cargo e título
    [cyan]3[/cyan] - Métricas: quantas reações tiveram os posts por autor
    [cyan]4[/cyan] - Recrutamento: quais indivíduos possuem todas as competências requeridas para vaga de IA
    [cyan]5[/cyan] - Contas interessadas: Contas individuais que se inscreveram em TODOS os eventos divulgados por uma empresa específica
    [cyan]6[/cyan] - Rede: mostre todos os 'indivíduos' (tipo_conta = 'individual') e quem eles seguem (seguir).
    [cyan]7[/cyan] - Recordistas: Artigos escritos por autores que atingiram o número MÁXIMO de posts da plataforma
    [cyan]8[/cyan] - Newsletters para recomendar: listar newsletters das top 5 contas com maior engajamento de posts.
    [cyan]9[/cyan] - Famosos: listar nome, número de seguidores e empresa em que trabalham todos autores de posts cuja média de reações por post é maior que a média geral de engajamento
    [cyan]10[/cyan] - Bons candidatos: listar profissionais que se candidatam a vagas e possuem mais formações que a média
    [cyan]11[/cyan] - Ociosos: Candidatos que existem no sistema mas nunca se candidataram a nada
    
    [red]0[/red] - Sair
    """
    
    console.print(
        Panel.fit(
            menu_texto, 
            title="[bold blue]Menu Principal[/bold blue]", 
            border_style="blue"
        )
    )

    choice_str = Prompt.ask(
        "[bold]Escolha uma opção[/bold]",
        choices=["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"],
        default="0"
    )
    
    choice = int (choice_str)
    
    if (choice == 1):
        run_query_empresas_por_vagas(cursor)
    if choice == 2:
        run_query_empregados_ensino(cursor)
    if choice == 3:
        run_query_reacoes_autor(cursor)
    if choice == 4:
        run_query_recrutamento_competencias(cursor)
    if choice == 5:
        run_query_interessadas(cursor)
    if choice == 6:
        run_query_rede(cursor)
    if choice == 7:
        run_query_recordistas(cursor)
    if choice == 8:
        run_query_newsletters(cursor)
    if choice == 9:
        run_query_famosos(cursor)
    if choice == 10:
        run_query_bons_candidatos(cursor)
    if choice == 11:
        run_query_ociosos(cursor)


def run_query_recordistas(cursor):

    console.print("\n[bold yellow]Consulta 7: Artigos de recordistas[/bold yellow]")

    query_recordistas = '''
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
    '''

    try:
        cursor.execute(query_recordistas)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhum artigo encontrado.[/yellow]")
            return

        table = Table(title="Artigos escritos por autores que atingiram o número máximo de posts da plataforma")
        table.add_column("Artigo", style="dim")
        table.add_column("Autor", style="cyan")
        
        for linha in resultados:
            table.add_row(linha[0], linha[1])
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_famosos(cursor):

    console.print("\n[bold yellow]Consulta 9: Famosos[/bold yellow]")

    query_famosos = '''
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
'''
    try:
        cursor.execute(query_famosos)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhuma conta encontrada.[/yellow]")
            return

        table = Table(title="Nome, número de seguidores e empresa em que trabalham todos autores de posts cuja média de reações por post é maior que a média geral de engajamento")
        table.add_column("Conta", style="dim")
        table.add_column("Seguidores", style="cyan")
        table.add_column("Empresa em que trabalha", style="cyan")
        table.add_column("Média de Reações", style="cyan")
        
        for linha in resultados:
            table.add_row(linha[0], str(linha[1]), linha[2], str(linha[3]))
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_bons_candidatos(cursor):

    console.print("\n[bold yellow]Consulta 10: Bons Candidatos[/bold yellow]")
    
    query_candidatos = '''
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
'''

    try:
        cursor.execute(query_candidatos)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhuma conta encontrada.[/yellow]")
            return

        table = Table(title="Candidatos a vagas com mais formações que a média")
        table.add_column("id", style="dim")
        table.add_column("Candidato", style="cyan")
        table.add_column("Formações", style="cyan")
        
        for linha in resultados:
            table.add_row(str(linha[0]), linha[1], str(linha[2]))
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_ociosos(cursor):

    console.print("\n[bold yellow]Consulta 11: Ociosos[/bold yellow]")
    
    query_ociosos = '''
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
'''

    try:
        cursor.execute(query_ociosos)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhuma conta encontrada.[/yellow]")
            return

        table = Table(title="Contas que nunca se candidataram a nenhuma vaga")
        table.add_column("Conta", style="dim")
        table.add_column("E-mail", style="cyan")
        
        for linha in resultados:
            table.add_row(linha[0], linha[1])
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_empresas_por_vagas(cursor):
    """
    Executa a Consulta 1 (Parametrizada) e exibe em uma tabela.
    "Quais empresas e de quais setores publicaram pelo menos N vagas?"
    """
    console.print("\n[bold yellow]Consulta 1: Empresas por Nível de Vagas[/bold yellow]")
    
    limite_vagas = IntPrompt.ask(
        "Mostrar empresas com pelo menos quantas vagas?", 
        default=3
    )

    sql_query = """
        SELECT c.nome as empresa, ce.setor, COUNT(d.vaga) as vagas_abertas 
        FROM disponibilizacao as d
        JOIN contas_empresas as ce on ce.id = d.empresa
        JOIN contas as c ON ce.conta_id = c.id
        GROUP BY c.id, c.nome, ce.setor
        HAVING COUNT(d.vaga) >= %s
        ORDER BY vagas_abertas DESC;
    """
    
    try:
        cursor.execute(sql_query, (limite_vagas,))
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print(f"[yellow]Nenhuma empresa encontrada com {limite_vagas} ou mais vagas.[/yellow]")
            return

        table = Table(title=f"Empresas com {limite_vagas} ou mais vagas")
        table.add_column("Empresa", style="cyan", no_wrap=True)
        table.add_column("Setor", style="green")
        table.add_column("Vagas Abertas", style="magenta", justify="right")
        
        for linha in resultados:
            table.add_row(linha[0], linha[1], str(linha[2]))
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_empregados_ensino (cursor):
    console.print("\n[bold yellow]Consulta 1: Empregados por Instituição de Ensino[/bold yellow]")

    query_insituicoes_ensino = '''
        SELECT nome from instituicoes_ensino ie 
        JOIN contas_empresas ce on ie.empresa_id = ce.id
        JOIN contas c on ce.conta_id = c.id;
    '''
    
    try:
        cursor.execute(query_insituicoes_ensino)
        instituicoes = cursor.fetchall()
        
        table = Table(title=f"Instituições")
        table.add_column("Empresa", style="cyan", no_wrap=True)
        
        for inst in instituicoes:
            table.add_row(inst[0])
            
        console.print(table)
        
        console.print("Em qual instituição deseja Pesquisar?")
        target = input()
        
        search_query = '''
        SELECT c_pessoal.nome, e.cargo, e.titulo, c_inst.nome FROM experiencias as e 
	    JOIN contas_individuais as ci on ci.id = e.individuo
	    JOIN contas as c_pessoal on ci.conta_id = c_pessoal.id
	    JOIN contas_empresas as ce on ce.id = e.empresa
	    JOIN instituicoes_ensino as ie on ie.empresa_id = ce.id
	    JOIN contas as c_inst on ce.conta_id = c_inst.id
	    WHERE e.fim IS NULL and c_inst.nome = %s
        '''
        
        cursor.execute(search_query, (target,))
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print(f"[yellow]Nenhuma empregado encontrado em {target}.[/yellow]")
            return

        table = Table(title=f"Empregados nas Instituições de Ensino")
        table.add_column("Nome", style="cyan", no_wrap=True)
        table.add_column("Cargo", style="green")
        table.add_column("Título", style="magenta", justify="right")
        
        for linha in resultados:
            table.add_row(linha[0], linha[1], linha[2], linha[3])
        
        console.print(table)
    
    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")
        
def run_query_reacoes_autor(cursor):
    console.print("\n[bold yellow]Consulta 3: Métricas - Reações por Autor[/bold yellow]")
    
    sql_query = """
        SELECT c.id, c.nome as autor, COUNT(reacoes.id) as num_reacoes 
        FROM reacoes
        RIGHT JOIN posts ON reacoes.post = posts.id
        JOIN contas as c ON c.id = posts.publicador
        GROUP BY c.id, c.nome
        ORDER BY num_reacoes DESC;
    """
    
    try:
        cursor.execute(sql_query)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhum post ou autor encontrado.[/yellow]")
            return

        table = Table(title="Métricas: Reações Totais por Autor")
        table.add_column("ID Autor", style="dim", justify="right")
        table.add_column("Nome do Autor", style="cyan")
        table.add_column("Total de Reações", style="magenta", justify="right")
        
        for linha in resultados:
            table.add_row(str(linha[0]), linha[1], str(linha[2]))
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")
    
def run_query_recrutamento_competencias(cursor):
    console.print("\n[bold yellow]Consulta 4: Recrutamento - Vaga de IA (TODAS as competências)[/bold yellow]")
    
    sql_query = """
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
                        WHERE C.conta_inidivual_id = CI.id
                          AND C.descricao = A.desc_comp 
                    )
            );
    """
    
    try:
        cursor.execute(sql_query)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhum candidato encontrado com TODAS as 3 competências (Python, SQL, IA).[/yellow]")
            return

        table = Table(title="Candidatos Qualificados para Vaga de IA")
        table.add_column("ID Indivíduo", style="dim", justify="right")
        table.add_column("Nome do Candidato", style="cyan")
        
        for linha in resultados:
            table.add_row(str(linha[0]), linha[1])
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_interessadas(cursor):
    """
    Executa a Consulta 5: Candidatos que se inscreveram em todos eventos de uma empresa.
    """
    console.print("\n[bold yellow]Consulta 5: Candidatos que se inscreveram em todos eventos de uma empresa[/bold yellow]")
    
    # Esta consulta usa NOT IN para encontrar indivíduos
    # que não existem na tabela de candidaturas.
    sql_query = """
        SELECT 
            ci.id AS id_individuo,
            c.nome AS nome_individuo
        FROM contas_individuais ci
        JOIN contas c ON c.id = ci.conta_id
        WHERE NOT EXISTS (
            SELECT e.id
            FROM eventos e
            JOIN contas_empresas ce ON ce.conta_id = e.divulgado_por
            WHERE ce.id = 1
            EXCEPT
            SELECT i.evento
            FROM inscricoes i
            WHERE i.inscrito = c.id
        );
    """
    
    try:
        cursor.execute(sql_query)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhum candidato interessado encontrado (todos se inscreveram!).[/yellow]")
            return

        table = Table(title="Candidatos Ociosos (Sem Candidaturas)")
        table.add_column("ID Indivíduo", style="dim", justify="right")
        table.add_column("Nome", style="cyan")
        
        for linha in resultados:
            table.add_row(str(linha[0]), linha[1])
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")

def run_query_rede(cursor):
    console.print("\n[bold yellow]Consulta 6: Rede - Quem Segue Quem[/bold yellow]")
    
    sql_query = """
        SELECT 
            c_seguidor.nome AS nome_seguidor,
            c_seguido.nome AS nome_seguido
        FROM contas_individuais ci
        -- Pega o nome do indivíduo (o seguidor)
        JOIN contas c_seguidor ON ci.conta_id = c_seguidor.id
        -- LEFT JOIN garante que TODOS os indivíduos apareçam
        LEFT JOIN seguir s ON ci.id = s.seguidor
        -- Pega o nome da conta que está sendo seguida (se houver)
        LEFT JOIN contas c_seguido ON s.seguido = c_seguido.id
        ORDER BY c_seguidor.nome, c_seguido.nome;
    """
    
    try:
        cursor.execute(sql_query)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Nenhuma conta individual encontrada no sistema.[/yellow]")
            return

        table = Table(title="Rede: Relações de 'Seguir' dos Indivíduos")
        table.add_column("Indivíduo (Seguidor)", style="cyan")
        table.add_column("Quem ele(a) segue", style="magenta")
        
        for linha in resultados:
            seguidor_nome = linha[0]
            seguido_nome = linha[1] if linha[1] is not None else "[dim]-- Ninguém --[/dim]"
            
            table.add_row(seguidor_nome, seguido_nome)
            
        console.print(table)

    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")
    
def run_query_newsletters(cursor):
    
    console.print("\n[bold yellow]Consulta 8: Newsletters para recomendar - listar newsletters das top 5 contas com maior engajamento de posts.[/bold yellow]")

    sql_query = """
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
    """
    
    try: 
        cursor.execute(sql_query)
        resultados = cursor.fetchall()
        
        if not resultados:
            console.print("[yellow]Não há newsletters para mostrar.[/yellow]")
            return

        table = Table(title="Newsletters Recomendadas")
        table.add_column("Id da Newsletter", style="cyan")
        table.add_column("Nome da Newsletter", style="magenta")
        table.add_column("Administrador", style="magenta")
        table.add_column("Engajamento", style="magenta")
        
        for linha in resultados:           
            table.add_row(str(linha[0]), linha[1], linha[2], f"{linha[3]:.2f}")
            
        console.print(table)
        
    except psycopg2.Error as e:
        console.print(f"[bold red]Erro ao executar consulta:[/bold red] {e}")
    except Exception as e:
        console.print(f"[bold red]Erro inesperado:[/bold red] {e}")
    
def process_create_account(cursor, connection):
    console.print("\n[yellow]Iniciando criação de conta...[/yellow]")
    console.print(Rule("[bold blue]Qual conta deseja criar?[/bold blue]"))
    
    console.print("""
    [cyan]1[/cyan] - Conta Individual
    [cyan]2[/cyan] - Conta de Empresa
    [cyan]3[/cyan] - Conta Instituição de Ensino
    [red]0[/red] - Sair
    """)
    
    choice_str = Prompt.ask(
        "[bold]Escolha uma opção[/bold]",
        choices=["0", "1", "2", "3"],
        default="0"
    )
    
    if (choice_str == "0"):
        return
    
    try:
        if (choice_str == "1"):
            create_individual_account(cursor)
        if (choice_str == "2"):
            create_enterprise_account(cursor)
        if (choice_str == "3"):
            create_education_account(cursor)
            
        connection.commit()
    
    except Exception as e:
        connection.rollback()
        print(e)
        
def create_individual_account(conn):
    dados_comuns = _get_dados_conta_comum("Formulário: Conta Individual")
    
    if not Confirm.ask("\nConfirma a criação desta conta?", default=True):
        raise Exception("Criação cancelada pelo usuário.")
    
    sql_insert_conta = """
        INSERT INTO contas (nome, email, senha) 
        VALUES (%s, %s, %s)
        RETURNING id; 
    """
    
    conn.execute(sql_insert_conta, (
        dados_comuns["nome"], 
        dados_comuns["email"], 
        dados_comuns["senha"]
    ))
    
    new_conta_id = conn.fetchone()
    sql_insert_individual = """
        INSERT INTO contas_individuais (conta_id) 
        VALUES (%s)
    """
    
    conn.execute(sql_insert_individual, (new_conta_id))

def create_enterprise_account(cursor):
    dados_comuns = _get_dados_conta_comum("Formulário: Conta Empresarial")
    
    console.print(Rule("[bold]Dados Específicos da Empresa[/bold]"))
    setor = Prompt.ask("Setor")
    cidade = Prompt.ask("Cidade Sede")
    estado = Prompt.ask("Estado Sede (UF)")
    pais = Prompt.ask("País Sede")
    
    if not Confirm.ask("\nConfirma a criação desta empresa?", default=True):
        raise Exception("Criação cancelada pelo usuário.")
    
    sql_insert_conta = """
        INSERT INTO contas (nome, email, senha) 
        VALUES (%s, %s, %s)
        RETURNING id; 
    """
    cursor.execute(sql_insert_conta, (
        dados_comuns["nome"], 
        dados_comuns["email"], 
        dados_comuns["senha"]
    ))
    new_conta_id = cursor.fetchone()
    
    sql_insert_empresa = """
        INSERT INTO contas_empresas (conta_id, setor, cidade_sede, estado_sede, pais_sede) 
        VALUES (%s, %s, %s, %s, %s)
        RETURNING id;
    """
    cursor.execute(sql_insert_empresa, (new_conta_id, setor, cidade, estado, pais))
    new_empresa_id = cursor.fetchone()[0]
    
    return new_empresa_id

def create_education_account(cursor):
    console.print(Panel(
        "[bold]Cadastro de Instituição de Ensino[/bold]\n"
        "[italic]Uma instituição é um tipo de empresa. "
        "Primeiro, preencha os dados da empresa...[/italic]"
    ))
    
    new_empresa_id = create_enterprise_account(cursor)

    sql_insert_instituicao = """
        INSERT INTO instituicoes_ensino (empresa_id) 
        VALUES (%s)
    """
    cursor.execute(sql_insert_instituicao, (new_empresa_id,))

def _list_accounts_for_delete(cursor):
    """
    Função auxiliar que exibe todas as contas
    para que o usuário saiba qual ID deletar.
    """
    console.print(Rule("[bold]Contas Atuais no Sistema[/bold]"))
    try:
        sql = "SELECT id, nome, email FROM contas ORDER BY nome;"
        cursor.execute(sql)
        results = cursor.fetchall()
        
        table = Table(title="Contas Registradas")
        table.add_column("ID Conta", style="red", justify="right")
        table.add_column("Nome", style="white")
        table.add_column("Email", style="cyan")
        
        for row in results:
            table.add_row(str(row[0]), row[1], row[2])
            
        console.print(table)

    except Exception as e:
        console.print(f"[bold red]Erro ao listar contas:[/bold red] {e}")
        
def delete_account(cursor, connection):
    console.print(Panel("[bold red]Deletar uma Conta (AÇÃO PERMANENTE)[/bold red]", style="red", padding=1))
    
    _list_accounts_for_delete(cursor)
    
    try:
        id_to_delete = IntPrompt.ask("[bold]Digite o ID da 'Conta' a ser DELETADA[/bold]")

       
        if not Confirm.ask(f"\n[bold red]TEM CERTEZA?[/bold red] Deletar a conta {id_to_delete} é [underline]permanente[/underline] e [underline]irrecuperável[/underline].", default=False):
            raise Exception("Operação cancelada pelo usuário.")
        
        console.print(f"[yellow]Iniciando exclusão (ID: {id_to_delete})...[/yellow]")

        console.print("[dim]Deletando conta principal...[/dim]")
        cursor.execute("DELETE FROM contas WHERE id = %s", (id_to_delete,))

        connection.commit()
        console.print(f"[bold green]\nConta {id_to_delete} e todos os dados associados foram deletados com sucesso![/bold green]")

    except psycopg2.Error as e:
        connection.rollback()
        console.print(f"\n[bold red]Erro de Banco de Dados:[/bold red] {e}")
    except Exception as e:
        connection.rollback()
        console.print(f"\n[bold red]Operação falhou:[/bold red] {e}")

def _get_dados_conta_comum(titulo="Formulário de Conta"):
    """
    Exibe um formulário para coletar os dados comuns
    da tabela 'contas'.
    """
    console.print(Panel(f"[bold]{titulo}[/bold]", style="blue", padding=1))
    
    nome = Prompt.ask("Nome")
    email = Prompt.ask("Email")
    senha = Prompt.ask("Senha", password=True)
    
    return {"nome": nome, "email": email, "senha": senha}

def process_follow_user(cursor, connection):
    """
    Formulário para 'Seguir' uma conta.
    Gerencia a transação (commit/rollback).
    """
    console.print(Panel("[bold]Seguir uma Conta[/bold]", style="blue", padding=1))
    
    _list_users_for_follow(cursor)
    
    try:
        seguidor_id = IntPrompt.ask("[bold]Digite o ID do 'Seguidor' (Indivíduo)[/bold]")
        seguido_id = IntPrompt.ask("[bold]Digite o ID da 'Conta' a ser seguida[/bold]")

        if not Confirm.ask(f"\nConfirma seguir? (Indivíduo {seguidor_id} -> Conta {seguido_id})", default=True):
            raise Exception("Operação cancelada pelo usuário.")

        sql_insert = "INSERT INTO seguir (seguidor, seguido) VALUES (%s, %s)"
        cursor.execute(sql_insert, (seguidor_id, seguido_id))
        
        connection.commit()
        console.print("[bold green]\nRelacionamento 'Seguir' criado com sucesso![/bold green]")
        console.print(f"[dim]O gatilho (procedure) deve ter atualizado o contador de seguidores da Conta {seguido_id}.[/dim]")

    except psycopg2.Error as e:
        connection.rollback()
        console.print(f"\n[bold red]Erro de Banco de Dados:[/bold red] {e}")
        console.print("[yellow]Dica: Você já pode estar seguindo esta conta, ou um dos IDs não existe.[/yellow]")
    except Exception as e:
        connection.rollback()
        console.print(f"\n[bold red]Operação falhou:[/bold red] {e}")
        
def _list_users_for_follow(cursor):
    """
    Função auxiliar que exibe duas tabelas:
    1. Quem PODE seguir (apenas Contas Individuais)
    2. Quem PODE SER seguido (TODAS as Contas)
    """
    try:
        sql_followers = """
            SELECT ci.id, c.nome 
            FROM contas_individuais ci
            JOIN contas c ON ci.conta_id = c.id
            ORDER BY c.nome;
        """
        cursor.execute(sql_followers)
        results_followers = cursor.fetchall()
        
        table_followers = Table(title="Quem pode Seguir (Indivíduos)")
        table_followers.add_column("ID Indivíduo", style="cyan", justify="right")
        table_followers.add_column("Nome", style="white")
        
        for row in results_followers:
            table_followers.add_row(str(row[0]), row[1])
        
        console.print(table_followers)

        sql_followed = "SELECT id, nome FROM contas ORDER BY nome;"
        cursor.execute(sql_followed)
        results_followed = cursor.fetchall()
        
        table_followed = Table(title="Quem pode ser Seguido (Todas as Contas)")
        table_followed.add_column("ID Conta", style="magenta", justify="right")
        table_followed.add_column("Nome", style="white")
        
        for row in results_followed:
            table_followed.add_row(str(row[0]), row[1])
            
        console.print(table_followed)

    except Exception as e:
        console.print(f"[bold red]Erro ao listar usuários:[/bold red] {e}")

def process_subscribe_newsletter(cursor, connection):
    console.print("\n[cian]Assinar Newsletters[/cian]")
    
    sql_query = """
    SELECT N.ID, N.NOME, NUM_ASSINANTES, C.NOME, N.DESCRICAO
	FROM NEWSLETTERS N JOIN CONTAS C ON N.ADMINISTRADOR = C.ID;
    """
    
    cursor.execute(sql_query)
    results_newsletters = cursor.fetchall()
    
    table_newsletters = Table(title="Newsletters Disponíveis")
    table_newsletters.add_column("ID", style="cyan", justify="right")
    table_newsletters.add_column("Nome", style="cyan", justify="right")
    table_newsletters.add_column("Seguidores", style="white")
    table_newsletters.add_column("Administrador", style="white")
    table_newsletters.add_column("Descrição", style="white")

    for row in results_newsletters:
        table_newsletters.add_row(str(row[0]), row[1], str(row[2]), row[3], row[4])
    
    console.print(table_newsletters)
    
    sql_query = """
    SELECT ID, NOME FROM CONTAS
    """
    
    cursor.execute(sql_query)
    results_newsletters = cursor.fetchall()
    
    table_accounts = Table(title="Quem pode Seguir (Indivíduos)")
    table_accounts.add_column("ID", style="cyan", justify="right")
    table_accounts.add_column("Nome", style="white", justify="right")

    for row in results_newsletters:
        table_accounts.add_row(str(row[0]), row[1])
    
    console.print(table_accounts)
    
    newsletter = IntPrompt.ask("Qual newsletter será seguida?")
    
    seguidor = IntPrompt.ask("Quem seguirá essa Newsletter?", )
    
    try:
        sql_insert = """
        INSERT INTO ASSINATURAS(INSCRITO, NEWSLETTER) VALUES(%s, %s)
        """
        
        cursor.execute(sql_insert, (seguidor, newsletter))
        connection.commit()
        
        console.print("[bold green]Newsletter assinada com sucesso![/bold green]")       
        
    except Exception as e:
        console.print(f"[bold red]Erro ao tentar seguir usuário:[/bold red] {e}")
        connection.rollback()

def update_account_desc(cursor, connection):
    console.print("\n[bold yellow]Editar a descrição de uma conta[/bold yellow]")
    
    _list_accounts_for_delete(cursor)
    
    try:
        id_to_edit = IntPrompt.ask("[bold]Digite o ID da 'Conta' a ser editada[/bold]")

        cursor.execute("SELECT descricao FROM contas WHERE id = %s", (id_to_edit,))
        result = cursor.fetchone()

        if result is None:
            raise Exception("Nenhuma conta encontrada com esse ID.")
        
        descricao_atual = result[0] if result[0] is not None else "[sem descrição]"

        console.print(f"\n[bold cyan]Descrição atual:[/bold cyan] {descricao_atual}")
       
        if not Confirm.ask(f"\n[bold red]Tem certeza que queres editar a conta {id_to_edit}?[bold/red]", default=False):
            raise Exception("Operação cancelada pelo usuário.")

        
        console.print("\nDigite a nova descrição: ")
        new_description = input()

        cursor.execute("UPDATE CONTAS SET descricao = %s WHERE id = %s", (new_description, id_to_edit,))

        if cursor.rowcount == 0:
            raise Exception("Nenhuma conta encontrada com esse ID.")

        connection.commit()
        console.print(f"[bold green]\nConta {id_to_edit} editada com sucesso![/bold green]")

    except psycopg2.Error as e:
        connection.rollback()
        console.print(f"\n[bold red]Erro de Banco de Dados:[/bold red] {e}")
    except Exception as e:
        connection.rollback()
        console.print(f"\n[bold red]Operação falhou:[/bold red] {e}")

if __name__ == "__main__":
    
    conn = None
    
    try:
        with console.status("[bold green]Conectando ao banco de dados...[/bold green]", spinner="dots") as status:
            time.sleep(1.5)
            
            conn = psycopg2.connect(
                dbname="linkedonho", 
                user="postgres", 
                password="wien", 
                host="127.0.0.1", 
                port="5432"
            )
            
            status.update("[bold green]Conectado com sucesso![/bold green]")
            time.sleep(0.5)

        if conn:
            with conn:
                with conn.cursor() as curr:
                    main(cursor=curr, connection=conn) 
    
    except psycopg2.Error as e:
        console.print(f"\n[bold red]Falha na conexão (psycopg2):[/bold red] {e}")
    
    except Exception as e:
        console.print(f"\n[bold red]Erro inesperado:[/bold red] {e}")