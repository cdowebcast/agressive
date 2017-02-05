# agreSSive
Um sistema de pedidos para o Shoutcast

## Pŕe-requisitos
* Em breve...

## Instalação
* Baixe ou clone este repositório: `git clone https://github.com/sistematico/shoutcast-requests.git`
* Copie o conteúdo da pasta `web/` para o diretório raíz do Servidor Web (Ex.: */var/www/html/*).
* Crie um novo usuário e copie o conteúdo da pasta `sistema/` para a **$HOME** do novo usuário.
* Copie o arquivo `sistema/rc-shoutcast` para a pasta `/etc/init.d/shoutcast` (*no caso do Debian/Ubuntu*). E dê permissões de execução (Ex.: *chmod 755 /etc/init.d/shoutcast*).
* Edite os arquivos: **web/conf/config.php**, **sistema/config.cfg**, **sistema/rc-shoutcast(/etc/init.d/shoutcast)** e **sistema/st/playlists/principal.lst** conforme suas necessidades.
* Habilite a inicialização do shoutcast: `systemctl enable shoutcast` ou `update-rc.d shoutcast defaults`
* Inicie a rádio: `systemctl start shoutcast` ou `/etc/init.d/shoutcast start`
* Mais informações em breve...

## Doação
Se você gostou do meu trabalho e resolveu usa-lo ou ele ajudou de alguma forma, considere uma doação de qualquer valor usando o Paypal:  
<div style="text-align:center">
<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QCHXHH4NDDAVE' target='_blank'>
<img src='https://sistematico.github.io/img/doacao.png' alt='Doe e ajude' />
</a>
</div>


## Contato
* <mailto:lucas@archlinux.com.br>
