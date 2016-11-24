<?php

  include '../conf/config.php';

	if ($_SERVER['REQUEST_METHOD'] == "GET" && isset($_GET['musica']) && $_GET['musica'] != "") {
		$musica = urldecode($_GET['musica']) . "\n";
		file_put_contents($pedidos, $musica, FILE_APPEND);
		$saida = "Obrigado, música " . pathinfo(basename($musica), PATHINFO_FILENAME) . " pedida.";
		echo $saida;
	}

	if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['titulo']) && $_POST['titulo'] != "") {
		$titulo = strtr($_POST['titulo'], $acentos);
		$scan = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($musicas));
		$arquivos = array();

		try {
			foreach ($scan as $arquivo) {
				$arquivo2 = strtr($arquivo->getPathname(), $acentos);
				if (!$arquivo->isDir() && $arquivo->isReadable() && in_array($arquivo->getExtension(), $extensoes) && strpos(strtolower($arquivo2), strtolower($titulo)) !== false) {
					$arquivos[] = pathinfo(basename($arquivo->getPathname()), PATHINFO_FILENAME) . " <a class='pedir' href='" . urlencode($arquivo->getPathname()) . "'>Pedir</a>";
				}
			}

			foreach ($arquivos as &$valor) {
				$saida .= $valor . "<br />";
			}

		} catch (UnexpectedValueException $e) {
			$saida = "Erro ao listar diretórios.";
		}

		echo $saida;

	}
?>
