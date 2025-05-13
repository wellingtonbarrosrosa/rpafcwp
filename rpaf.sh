#!/bin/bash

# Caminhos principais
CONF_DIR="/usr/local/apache/conf.d"
RPAF_CONF="$CONF_DIR/rpaf.conf"
REMOTEIP_CONF="$CONF_DIR/remoteip.conf"
HTTPD=$(which httpd)

# Funções de mensagens
erro() {
    echo -e "\033[31m[ERRO] $1\033[0m"
}
sucesso() {
    echo -e "\033[32m[SUCESSO] $1\033[0m"
}
info() {
    echo -e "\033[34m[INFO] $1\033[0m"
}

# 1. Desabilitar rpaf.conf se existir
if [ -f "$RPAF_CONF" ]; then
    info "Arquivo rpaf.conf encontrado. Renomeando para rpaf.conf.bak..."
    mv "$RPAF_CONF" "$RPAF_CONF.bak"
    sucesso "rpaf.conf desativado."
else
    info "rpaf.conf não encontrado. Nada a fazer aqui."
fi

# 2. Criar configuração usando mod_remoteip
info "Criando arquivo de configuração para mod_remoteip..."
cat > "$REMOTEIP_CONF" <<EOL
LoadModule remoteip_module modules/mod_remoteip.so

<IfModule mod_remoteip.c>
    RemoteIPHeader X-Forwarded-For
    RemoteIPInternalProxy 127.0.0.1
</IfModule>
EOL

sucesso "Arquivo remoteip.conf criado com sucesso em $REMOTEIP_CONF"

# 3. Testar configuração
info "Testando a configuração do Apache..."
$HTTPD -t
if [ $? -ne 0 ]; then
    erro "A configuração do Apache contém erros. Verifique o log."
    exit 1
else
    sucesso "Configuração válida (Syntax OK)."
fi

# 4. Reiniciar Apache
info "Reiniciando o Apache..."
systemctl restart httpd
if [ $? -ne 0 ]; then
    erro "Falha ao reiniciar o Apache."
    exit 1
else
    sucesso "Apache reiniciado com sucesso."
fi

echo -e "\n\033[1;32m[OK] Script de correção finalizado com sucesso!\033[0m"
