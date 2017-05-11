<?php

ini_set('display_errors', 'On');
error_reporting(E_ALL);

  //include '../conf/config.php';
  $db = new PDO("sqlite:../db/agressive.sqlite") or die("Impossivel criar BD");

	if ($_SERVER['REQUEST_METHOD'] == "GET" && isset($_GET['id']) && $_GET['id'] != "") {

    $hora = time();
    #$stmt1 = $db->prepare('SELECT * FROM pedidos WHERE id=?');
    $stmt1 = $db->prepare('SELECT * FROM musicas WHERE id=? LIMIT 1');
    $stmt1->bindParam(1, $_GET['id'], PDO::PARAM_INT);
    $stmt1->execute();
    $row = $stmt1->fetch(PDO::FETCH_ASSOC);
    //$row2 = $stmt1->fetchAll();

    if ($row)
    {
      $diferenca = ($hora - $row['hora']) / 60;
      if ($diferenca < 5) {
        $ok = false;
        $saida = "Você está pedindo muito rápido!\n<br />";
      } else {
        $ok = true;
        $saida = "Você pediu faz tempo!\n<br />";
      }
    } else {
        $ok = true;
        $saida = "Você ainda não pediu essa música!\n<br />";
    }

    if ($ok) {
      //$row2 = $stmt1->fetch();
      $stmt2 = $db->prepare("INSERT INTO pedidos (id, artista, titulo, ip, hora) VALUES (:id, :artista, :titulo, :ip, :hora);");
      $stmt2->bindValue(':id', $row["id"]);
      $stmt2->bindValue(':artista', $row["artista"]);
      $stmt2->bindValue(':titulo', $row["titulo"]);
      $stmt2->bindValue(':ip', 'IP');
      $stmt2->bindValue(':hora', time());
      $stmt2->execute();
    }
		//$musica = urldecode($_GET['musica']) . "\n";
		//file_put_contents($pedidos, $musica, FILE_APPEND);
		//$saida = "Obrigado, música " . pathinfo(basename($musica), PATHINFO_FILENAME) . " pedida.";

		echo $saida;

    $db = NULL;
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
