<?php

if (isset($_POST)) {
	include(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'conf/config.php');

	$reinstall = $_POST['reinstall'];

	if (isset($reinstall) && $reinstall == "ok") {
		function delTree($dir) {
			$files = array_diff(scandir($dir), array('.','..'));
	    foreach ($files as $file) {
	      (is_dir("$dir/$file") && !is_link($dir)) ? delTree("$dir/$file") : unlink("$dir/$file");
	    }
	    rmdir($dir);
		}
		 delTree('../db/');
	}

	if (!is_dir($dbpath) || $perm != "0777") {
		$oldmask = umask(0);
		mkdir($dbpath, 0777, true);
		touch($dbpath . "/agressive.sqlite");
		chmod($dbpath . "/agressive.sqlite", 0777);
		umask($oldmask);
		echo "Dir não encontrado...";
		$db = new PDO('sqlite:' . dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'db/agressive.sqlite') or die("Impossivel criar BD");
	  $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	}

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
} else {
?>
	<!DOCTYPE html>
	<html lang="pt-br">
	  <head>
	    <meta charset="utf-8">
	    <meta http-equiv="X-UA-Compatible" content="IE=edge">
	    <meta name="viewport" content="width=device-width, initial-scale=1">
	    <title></title>
	    <meta name="description" content="">
	    <meta name="keywords" content="">
	    <meta name="author" content="">
		<link rel="icon" href="img/favicon.ico">
	    <link href="style.css" rel="stylesheet" type="text/css">
	    <!--[if lt IE 9]>
	      <script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	    <![endif]-->
	  </head>
	  <body>
			<form action="install.php" method="post">
    	<!-- Choices -->
    	Sobre-escrever?<input type="checkbox" name="reinstall[]" id="color" value="ok">
    	<!-- Submit -->
    	<input type="submit" value="Instalar!">
			</form>
	    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
	    <script src="script.js"></script>
	  </body>
	</html>
<?php } ?>
