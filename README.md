# agreSSive  

[![Build Status](https://travis-ci.org/sistematico/agressive.svg?branch=master)](https://travis-ci.org/sistematico/agressive)  

Streaming de Rádio <b>muito</b> fácil!

## Pŕe-requisitos

* Sistema Operacional Linux(Debian, Ubuntu ou Arch Linux)
* curl (somente no caso da instalação automática)
* git
* nginx
* php-fpm e php-cli
* SQLite3 e php-sqlite
* tmux

## Instalação automática

```  
bash <(curl -s -L http://bit.ly/agrsv)
```

## Instalação manual
* Baixe ou clone este repositório: `git clone https://github.com/sistematico/agressive.git`
* Copie o conteúdo da pasta `web/` para o diretório raíz do Servidor Web (Ex.: */var/www/html/agressive*).
* Crie um novo usuário e copie o conteúdo(conteúdo, não a pasta!) da pasta `sistema/` para a **$HOME** do novo usuário.
* Copie o arquivo `sistema/agressive.rc` para a pasta `/etc/init.d/shoutcast` (*no caso do Debian/Ubuntu*). E dê permissões de execução (Ex.: *chmod 755 /etc/init.d/agressive*).
* Edite os arquivos: **sistema/engine.php**, **web/conf/config.php**, **sistema/config.cfg** e **sistema/agressive.rc(/etc/init.d/agressive)** conforme suas necessidades.
* Habilite a inicialização do shoutcast: `systemctl enable agressive` ou `update-rc.d agressive defaults`
* Inicie a rádio: `systemctl start agressive` ou `/etc/init.d/agressive start`
* Mais informações em breve...

## TO-DO
* Proteção contra pedidos repetidos, por música e por artista.
* Sistema de sorteio para o AutoDJ com "peso" para músicas e artistas.

## Ajude
Se você gostou do meu trabalho e resolveu usa-lo ou ele ajudou de alguma forma, considere uma doação de qualquer valor usando o Paypal:  
<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QCHXHH4NDDAVE' target='_blank'>
<img src='https://sistematico.github.io/img/doacao.png' alt='Doe e ajude' />
</a>


## Contato
* <mailto:lucas@archlinux.com.br>
