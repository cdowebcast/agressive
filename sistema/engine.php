<?php

// Onde toda a mágica acontece!
// Procurei por 10 anos uma maneira de fazer isso funcionar, e achei.
// Agora, seja legal comigo e suporte(doando algum valor) meu trabalho.
//
// Olhe bem o arquivo st/playlists/principal.lst é aquele arquivo que "chama" este, OK?

//include_once('/var/www/site.com/php/config.php');
$musicas = '/usr/local/musicas';
$pedidos = '/var/www/site.com/txt/pedidos.txt';

if (trim(file_get_contents($pedidos)) == false) {
	// AutoDJ
	$scan = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($musicas));
	$arquivos = array();
	$extensoes = array('mp3');

	foreach ($scan as $arquivo) {
		if (!$arquivo->isDir() && in_array($arquivo->getExtension(), $extensoes)) {
			$arquivos[] = $arquivo->getPathname();
		}
	}

	shuffle($arquivos);
	echo array_values($arquivos)[0];

} else {
	// Pedidos
	$file = file($pedidos);
  	$output = $file[0];
  	unset($file[0]);
  	file_put_contents($pedidos, $file);
	echo $output;
}

?>
