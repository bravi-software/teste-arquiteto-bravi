# Bravi Software - Teste para vaga de Arquiteto DevOps

Este documento tem como objetivo demonstrar os passos necessários para validar as implementações submetidas pelos candidados à vaga de Arquiteto DevOps na Bravi Software.

Tabela de conteúdo
==================

- [Pré-requisitos](#pré-requisitos)
- [Tarefas](#tarefas)
  - [Tarefa 1: Migrar a persistência para Postgresql ou MySQL](#tarefa-1:-migrar-a-persistência-para-postgresql-ou-mysql)
  - [Tarefa 2: Empacotar a aplicação usando Docker e implantá-la usando uma ferramenta de orquestração compatível com Docker](#tarefa-2:-empacotar-a-aplicação-usando-docker-e-implantá-la-usando-uma-ferramenta-de-orquestração-compatível-com-Docker)
- [Referências](#referências)

## Pré-requisitos

Antes de iniciar a execução das tarefas descritas no teste em pauta, certifique-se que as seguintes ferramentas estão disponíveis em seu ambiente:

- [Git](https://git-scm.com/)
- [JDK 8+](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
- [Maven 3.3+](https://maven.apache.org/download.cgi)
- [Docker 1.17+](https://docs.docker.com/install/)
- [Docker Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/)
- [cURL](https://curl.haxx.se/docs/manpage.html)
- [watch](https://linux.die.net/man/1/watch)

Para assegurar que as ferramentas citadas acima estão devidamente instaladas no ambiente, execute os comandos abaixo:

```shell
# Printa a versão do Git instalado na máquina
git --version

# Printa a versão da JDK instalada na máquina
java -version

# Printa a versão do Maven instalado na máquina
mvn --version

# Printa a versão do Docker instalado na máquina
docker --version
```

![Console com a confirmação da instalação das ferramentas](docs/images/Tarefa1-Console_com_a_confirmacao_da_instalacao_das_ferramentas.png)

## Tarefas

## Tarefa 1: Migrar a persistência para Postgresql ou MySQL

Para execução dessa tarefa, será utilizado o banco de dados PostgreSQL.

1) Nesta etapa, será demonstrado os passos necessários para criação do banco de dados que será utilizado pela aplicação.

```shell
# Execute o comando abaixo para criar um container Docker a partir da imagem oficial do PostgreSQL expondo-o na porta 5432
docker run --name postgres-test -p 5432:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=postgres -d postgres:10.6-alpine
```

![Console com a criação do banco de dados PostgreSQL](docs/images/Tarefa1-Console_com_a_criacao_do_banco_de_dados_PostgreSQL.png)

2) A partir do diretório raiz do projeto, empacote (formato .jar) a aplicação e execute-a a partir de um terminal, conforme descrito abaixo.

```shell
# Execute o empacotamento da aplicação utilizando o Maven
mvn clean package
```

![Console com o finalização do empacotamento da aplicação](docs/images/Tarefa1-Console_com_o_finalizacao_do_empacotamento_da_aplicacao.png)

```shell
# Inicie a aplicação empacotada via terminal
java -jar target/spring-boot-sample-hateoas-2.0.1.RELEASE.jar
```

![Console com a inicialização da aplicação via terminal](docs/images/Tarefa1-Console_com_a_inicializacao_da_aplicacao_via_terminal.png)

3) Com aplicação inicializada, acesse a URL `http://localhost:8090/swagger-ui.html` a partir do seu navegador favorito e teste a aplicação utilizando os recursos do Swagger.

![Página inicial do Swagger gerado pela aplicação](docs/images/Tarefa1-Pagina_inicial_do_Swagger_gerado_pela_aplicacao.png)

>**Nota:** Tenha certeza que as portas `8090` e `5432` utilizadas pela aplicação e banco de dados respectivamente, não estão em uso por outros processos em seu ambiente.

### Tarefa 2: Empacotar a aplicação usando Docker e implantá-la usando uma ferramenta de orquestração compatível com Docker

Para execução dessa tarefa, será utilizado o Docker Swarm como ferramenta de orquestração de containers Dockers.

1) Inicie um docker swarm em seu ambiente, executando os comandos abaixo:

```shell
# Inicializa o orquestrador de containers na máquina
docker swarm init
```

2) Com o orquestrador de containers inicializado, inicie o container do PostgreSQL como serviço.

```shell
# Execute o comando abaixo a partir do diretório raiz do projeto
docker stack deploy --compose-file docker-stack-infra.yml BRAVI
```

![Console com a criação do container PostgreSQL como serviço](docs/images/Tarefa2-Console_com_a_criacao_do_container_PostgreSQL_como_servico.png)

>**Nota:** Garanta que a porta `5432` utilizada pelo PostgreSQL não esteja em uso.

2) Em seguida, a partir do diretório raiz do projeto, gere a imagem docker da aplicação e implante-a como serviço, conforme configuração contida no arquivo `docker-stack.yml`.

```shell
# Constrói a imagem docker da aplicação 
docker build --tag spring-boot-sample-hateoas:1.0.0 .

# Execute o comando abaixo a partir do diretório raiz do projeto para implantar a aplicação como serviço
docker stack deploy --compose-file docker-stack.yml BRAVI

# Confirme se o serviço foi criado corretamente
docker service ls
```

![Console com a confirmação da criação do serviço da aplicação](docs/images/Tarefa2-Console_com_a_confirmacao_da_criacao_do_servico_da_aplicacao.png)

>**Nota:** Para visualizar os logs gerados pela aplicação implantada como serviço, utilize o comando `docker service logs BRAVI_spring-boot-sample-hateoas` a partir do terminal.

3) Na sequência, usando seu navegador favorito, acesse a URL `http://127.0.0.1:8090/swagger-ui.html` e teste a aplicação utilizando os recursos do Swagger.

![Página inicial do Swagger da aplicação](docs/images/Tarefa2-Pagina_inicial_do_Swagger_da_aplicacao.png)

4) Agora, simule a queda de um dos containers associados ao serviço da aplicação e veja como a aplicação se comporta para o usuário final. Para executar esse passo, todos os comandos descritos abaixo devem ser executados em terminais diferentes.

```shell
# Diminua a réplica do serviço de 2 para 1
docker service scale BRAVI_spring-boot-sample-hateoas=1

# Lista todos os containers em execução a meio segundo
watch -n 0.5 docker ps

# Testa o endpoint da aplicação a cada 1 segundo
watch -n 1 curl -I http://127.0.0.1:8090/swagger-ui.html
```

![Console com a saída do monitoramento da aplicação quando simulado uma queda](docs/images/Tarefa2-Console_com_a_saida_do_monitoramento_da_aplicacao_quando_simulado_uma_queda.png)

## Referências

- [Git - Documentação](https://git-scm.com/doc)
- [JDK - Documentação](https://docs.oracle.com/javase/8/docs/)
- [Maven - Documentação](https://maven.apache.org/guides/index.html)
- [Docker - Documentação](https://docs.docker.com/)
- [Docker Swarm - Documentação](https://docs.docker.com/engine/swarm/)
- [PostgreSQL - Documentação](https://www.postgresql.org/docs/10/index.html)
- [PostgreSQL - Imagem oficial no Docker Store](https://docs.docker.com/samples/library/postgres/)

