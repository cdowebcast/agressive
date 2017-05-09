<?php

include '../conf/config.php';

$db = new PDO("sqlite:../db/agressive.sqlite") or die("Impossivel criar BD");
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$stmt_drop = $db->prepare('DROP TABLE IF EXISTS musicas;');
$stmt_drop->execute();

$stmt_conn = $db->prepare('CREATE TABLE IF NOT EXISTS musicas (id INTEGER PRIMARY KEY, artista TEXT, titulo TEXT, curtidas INTEGER, descurtidas INTEGER, execucao INTEGER, caminho TEXT);');
$stmt_conn->execute();

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

	foreach ($arquivos as &$valor) {
		$nome = pathinfo(basename($valor), PATHINFO_FILENAME);
		//$artista = explode('-', basename($row['caminho']));
		$artista = substr($nome, 0, strpos($nome, '-'));
		//$musica = substr($nome, strpos($nome, '-'), -1);
		$musica = substr(strrchr($nome, "-"), 1);

		$stmt1 = $db->prepare("INSERT INTO musicas (artista, titulo, caminho) VALUES (:artista, :titulo, :caminho);");
		$stmt1->bindValue(':artista', $artista);
		$stmt1->bindValue(':titulo', $musica);
		$stmt1->bindValue(':caminho', $valor);
		$stmt1->execute();
	}

}

?>
