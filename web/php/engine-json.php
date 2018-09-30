<?php
if (php_sapi_name() == "cli") {
    // In cli-mode
	$musicas = '/usr/local/musicas';
	$pedidos = json_decode(file_get_contents('/var/www/somdomato.com/pedidos.json'), true);

	if (empty($pedidos)) {
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
		echo $pedidos[0]['caminho'];
		array_shift($pedidos);
		file_put_contents('/var/www/somdomato.com/pedidos.json',json_encode($pedidos));
	}

} else {
	echo "Esse script não foi desenvolvido para ser acessado via browser :'(";
	echo php_sapi_name();
}
?>