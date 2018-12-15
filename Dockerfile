#=================================== MULTISTAGE -> build ====================================
# FROM [nome da imagem]:[versão/tag da imagem]
# Referência: https://docs.docker.com/engine/reference/builder/#from
# 
# Define uma imagem local ou pública do Docker Store. Aqui é utilizado uma imagem oficial do 
# Maven (baseada na distribuição linux Debian Stretch Slim), cujo objetivo é servir de imagem 
# base para os demais estágios do processo de build da imagem final, reduzindo seu tamanho e 
# permitindo total independência à ferramentas externas ao Docker.
#============================================================================================
FROM maven:3.5.2-jdk-8 AS build

#============================================================================================
# COPY [arquivo a ser copiado] [destino do arquivo copiado]
# Referência: https://docs.docker.com/engine/reference/builder/#copy
#
# Copia os arquivos de código fonte da aplicação para dentro do container.
#============================================================================================
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app

#============================================================================================
# RUN [comandos a serem executados]
# Referência: https://docs.docker.com/engine/reference/builder/#run
# 
# A instrução RUN executará qualquer comando sobre uma nova camada da imagem atual e 
# confirmará os resultados. A imagem resultante será usada para o próximo passo no Dockerfile.
#============================================================================================
RUN \
    mvn -f /usr/src/app/pom.xml clean package -DskipTests

#================================== MULTISTAGE -> release ===================================
# FROM [nome da imagem]:[versão/tag da imagem]
# Referência: https://docs.docker.com/engine/reference/builder/#from
# 
# Define uma imagem local ou pública do Docker Store. Aqui é utilizado uma imagem oficial do 
# Debian (baseada na distribuição linux Debian Stretch Slim). Em sua primeira execução, ela 
# será baixada para o computador e usada no build para criar a imagem da aplicação.
#================================
FROM debian:stretch

#============================================================================================
# LABEL maintainer=[nome e e-mail do mantenedor da imagem]
# Referência: https://docs.docker.com/engine/reference/builder/#label
#
# Indica o responsável/autor por manter a imagem.
#============================================================================================
LABEL maintainer="Raphael F. Jesus <raphaelfjesus@gmail.com>"

#============================================================================================
# ARG <nome do argumento>[=<valor padrão>]
# Referência: https://docs.docker.com/engine/reference/builder/#arg
#
# A instrução ARG define uma variável que os usuários podem passar no tempo de compilação 
# para o construtor com o comando docker build.
#============================================================================================
ARG PORT

#============================================================================================
# ENV [nome da variável de ambiente]
# Referência: https://docs.docker.com/engine/reference/builder/#env
# 
# Variáveis de ambiente com o path da aplicação dentro do container.
#============================================================================================
ENV \
    PORT=${PORT:-8090} \
    JAVA_OPTS='-Xms256m -Xmx256m' \
    DEBUG_OPTS=

#============================================================================================
# VOLUME [nome do volume]
# Referência: https://docs.docker.com/engine/reference/builder/#volume
# 
# Cria um ponto de montagem com o nome especificado e marca-o como um volume persistente 
# montado a partir de hospedeiros nativos ou outros containers.
#============================================================================================
VOLUME /tmp

#============================================================================================
# EXPOSE [número da porta]
# Referência: https://docs.docker.com/engine/reference/builder/#expose
#
# Irá expor a porta para a máquina host (hospedeira). É possível expor múltiplas portas, como 
# por exemplo: EXPOSE 80 443 8080
#============================================================================================
EXPOSE ${PORT}

#============================================================================================
# RUN [comandos a serem executados]
# Referência: https://docs.docker.com/engine/reference/builder/#run
# 
# A instrução RUN executará qualquer comando sobre uma nova camada da imagem atual e 
# confirmará os resultados. Aqui será executado a atualização dos pacotes instalado no sistema 
# operacional, bem como instalar o openjdk e o pacote Curl para usarmos no healthcheck.
#============================================================================================
RUN \
    apt -y update \
    && apt-get -y install openjdk-8-jre-headless curl --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

#============================================================================================
# COPY [arquivo a ser copiado] [destino do arquivo copiado]
# Referência: https://docs.docker.com/engine/reference/builder/#copy
#
# Copia o arquivo da aplicação para dentro do container sob o nome app.jar.
#============================================================================================
COPY --from=build /usr/src/app/target/spring-boot-sample-hateoas-2.0.1.RELEASE.jar /app.jar

#============================================================================================
# ENTRYPOINT [executável seguido dos parâmetros]
# Referência: https://docs.docker.com/engine/reference/builder/#entrypoint
# 
# Inicia o container como um executável a partir da inicialização da aplicação. Essa instrução 
# é muito útil, pois caso a aplicação caia, o container cai junto, indicando ao orquestrador 
# de containers aplicar a política de restart configurada para a aplicação.
#============================================================================================
ENTRYPOINT exec java ${JAVA_OPTS} ${DEBUG_OPTS} -Djava.security.egd=file:/dev/./urandom -jar /app.jar

