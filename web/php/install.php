<?php

	if(isset($_SERVER['HTTP_X_REQUESTED_WITH']) && !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
 		die("Este script não foi desenhado para ser acessado diretamente.");
	}

// if (isset($_POST)) {
	include(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'conf/config.php');

	// $reinstall = $_POST['reinstall'];

	// if (isset($reinstall) && $reinstall == "ok") {
	// 	function delTree($dir) {
	// 		$files = array_diff(scandir($dir), array('.','..'));
	//     foreach ($files as $file) {
	//       (is_dir("$dir/$file") && !is_link($dir)) ? delTree("$dir/$file") : unlink("$dir/$file");
	//     }
	//     rmdir($dir);
	// 	}
	// 	 delTree('../db/');
	// }

	// if (!is_dir($dbpath) || $perm != "0777") {
	// 	$oldmask = umask(0);
	// 	mkdir($dbpath, 0777, true);
	// 	touch($dbpath . "/agressive.sqlite");
	// 	chmod($dbpath . "/agressive.sqlite", 0777);
	// 	umask($oldmask);
	// 	echo "Dir não encontrado...";
	// 	$db = new PDO('sqlite:' . dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'db/agressive.sqlite') or die("Impossivel criar BD");
	//   $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	// }

	$stmt_drop = $db->prepare('DROP TABLE IF EXISTS musicas;');
	$stmt_drop->execute();

	$stmt_drop_p = $db->prepare('DROP TABLE IF EXISTS pedidos;');
	$stmt_drop_p->execute();

	$stmt_conn = $db->prepare('CREATE TABLE IF NOT EXISTS musicas
				(id INTEGER PRIMARY KEY,
				artista TEXT,
				titulo TEXT,
				curtidas INTEGER,
				descurtidas INTEGER,
				caminho TEXT);');
	$stmt_conn->execute();

	$stmt_ped = $db->prepare('CREATE TABLE IF NOT EXISTS pedidos
					(id INTEGER PRIMARY KEY,
					artista TEXT,
					titulo TEXT,
					ip TEXT,
					hora DATETIME DEFAULT CURRENT_TIMESTAMP,
					caminho TEXT);');
	$stmt_ped->execute();

	// AutoDJ
	$scan = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($musicaspath));
	$arquivos = array();
	$extensoes = array('mp3');

	foreach ($scan as $arquivo) {
		if (!$arquivo->isDir() && in_array($arquivo->getExtension(), $extensoes)) {
			$arquivos[] = $arquivo->getPathname();
		}
	}

	foreach ($arquivos as &$valor) {
		$nome = pathinfo(basename($valor), PATHINFO_FILENAME);
		$artista = substr($nome, 0, strpos($nome, '-'));
		$musica = substr(strrchr($nome, "-"), 1);

		$stmt1 = $db->prepare("INSERT INTO musicas (artista, titulo, caminho) VALUES (:artista, :titulo, :caminho);");
		$stmt1->bindValue(':artista', $artista);
		$stmt1->bindValue(':titulo', $musica);
		$stmt1->bindValue(':caminho', $valor);
		$stmt1->execute();
	}

	$db = null;
	echo "Banco de dados instalado!";
?>
