<?php

include '../conf/config.php';

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

	// Todas as músicas...
	//foreach ($arquivos as &$valor) {
	//	echo $valor . "\n";
	//}

	// Uma música
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
