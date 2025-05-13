#!/bin/bash

# Definindo o caminho para o arquivo de configuração do Apache
CONF_DIR="/usr/local/apache/conf.d"
MOD_RPAF_PATH="/usr/local/apache/modules/mod_rpaf.so"
RPAF_CONF="$CONF_DIR/rpaf.conf"
HTTPD=$(which httpd)

# Função para exibir mensagens de erro
erro() {
    echo -e "\033[31m[ERRO] $1\033[0m"
}

# Função para exibir mensagens de sucesso
sucesso() {
    echo -e "\033[32m[SUCESSO] $1\033[0m"
}

# Função para verificar se o arquivo existe
verificar_arquivo() {
    if [ ! -f "$1" ]; then
        return 1
    fi
    return 0
}

# 1. Verificando se o módulo mod_rpaf.so existe
verificar_arquivo "$MOD_RPAF_PATH"
if [ $? -ne 0 ]; then
    erro "O arquivo $MOD_RPAF_PATH não foi encontrado."
    
    # Remover a referência ao mod_rpaf.so no arquivo de configuração
    if [ -f "$RPAF_CONF" ]; then
        erro "Removendo a referência ao módulo mod_rpaf no arquivo $RPAF_CONF..."
        sed -i '/mod_rpaf.so/d' "$RPAF_CONF"
        sucesso "Referência ao módulo mod_rpaf removida com sucesso."
    else
        erro "O arquivo de configuração $RPAF_CONF não foi encontrado."
    fi
else
    sucesso "O módulo mod_rpaf.so foi encontrado em $MOD_RPAF_PATH."
fi

# 2. Verificando o arquivo de configuração do Apache
echo "Verificando a configuração do Apache..."
$HTTPD -t
if [ $? -ne 0 ]; then
    erro "A configuração do Apache contém erros."
    exit 1
else
    sucesso "A configuração do Apache está correta (Syntax OK)."
fi

# 3. Reiniciando o Apache
echo "Reiniciando o Apache..."
sudo systemctl restart httpd
if [ $? -ne 0 ]; then
    erro "Falha ao reiniciar o Apache."
    exit 1
else
    sucesso "Apache reiniciado com sucesso."
fi

echo "Script de correção finalizado!"

