<?php

// SELECT date FROM tbemp ORDER BY date ASC
// "DELETE FROM my_news WHERE date < ".strtotime('-1 month')

// MUSICAS id artista titulo curtidas descurtidas caminho
// PEDIDOS id artista titulo ip	hora caminho

ini_set('display_errors', 'On');
error_reporting(E_ALL);

// if(isset($_SERVER['HTTP_X_REQUESTED_WITH']) && !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
// 	die("Este script não foi desenhado para ser acessado diretamente.");
// }

include(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'conf/config.php');

// Pede
if ($_SERVER['REQUEST_METHOD'] == "GET" && isset($_GET['id']) && $_GET['id'] != "") {
	$ok = false;
	$saida = '';

	$stmt = $db->prepare('SELECT musicas.id, musicas.artista, musicas.titulo, musicas.caminho, pedidos.hora FROM musicas,pedidos WHERE musicas.id=? LIMIT 1');
  $stmt->bindParam(1, $_GET['id'], PDO::PARAM_INT);
  $stmt->execute();
  $coluna = $stmt->fetch(PDO::FETCH_ASSOC);

	if ($coluna) {
		$id = $coluna['id'];
		$artista = $coluna['artista'];
		$titulo = $coluna['titulo'];
		$caminho = $coluna['caminho'];
	 	//$hora = $coluna['hora'];
	 }

	 $stmt->closeCursor();

	 $stmt2 = $db->prepare('SELECT * FROM pedidos ORDER BY hora DESC LIMIT 100');
	 $stmt2->execute();

	 while($coluna2 = $stmt2->fetch( PDO::FETCH_ASSOC )) {
		 if ($artista == $coluna2['artista'] && $titulo == $coluna2['titulo']) {
			 $ttempos[] = $coluna2['hora'];
	 	 } else if ($artista == $coluna2['artista']) {
			 $atempos[] = $coluna2['hora'];
		 }
	 }

	 $stmt->closeCursor();

	 //if (in_array($artista, $artistas) && in_array($titulo, $titulos)) {
	 if (!empty($ttempos)) {
		 $max1 = max($ttempos);
	 } else if (!empty($atempos)) {
		 $max2 = max($atempos);
	 } else {
		 $ok = true;
	 }

	 if (isset($max1) && comparaTempo($max1)<$tmin) {
		 $ok = false;
		 $saida = "Você já pediu a música " . $titulo . "nos últimos " . $tmin . " minutos.";
	 }	else if (isset($max2) && comparaTempo($max2)<$amin) {
		 $ok = false;
		 $saida = "Você já pediu o artista " . $artista . "nos últimos " . $amin . " minutos.";
	 }

	//  $arr = array(1, 2, 3, 4);
	//  foreach ($arr as &$value) {
	// 	 $value = $value * 2;
	//  }

	 if ($ok) {
    $stmt2 = $db->prepare("INSERT INTO pedidos (id, artista, titulo, ip, hora, caminho) VALUES (:id, :artista, :titulo, :ip, :hora, :caminho);");
    $stmt2->bindValue(':id', $coluna["id"]);
    $stmt2->bindValue(':artista', $coluna["artista"]);
    $stmt2->bindValue(':titulo', $coluna["titulo"]);
    $stmt2->bindValue(':ip', $ip);
    $stmt2->bindValue(':hora', time());
    $stmt2->bindValue(':caminho', $coluna["caminho"]);
    $stmt2->execute();
    $stmt2->closeCursor();
    $saida = "Obrigado, música " . $coluna["artista"] . " - " . $coluna["titulo"] . " pedida.";
  }
  echo $saida;
  $db = NULL;
}

// Lista
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['titulo']) && $_POST['titulo'] != "") {
	try {
		$trecho = $_POST['titulo'];
		$saida = "<table border=1>";
		$saida .= "<tr><td>Id</td><td>Artista</td><td>Titulo</td><td>Pedido</td></tr>";
		$result = $db->prepare("SELECT * FROM musicas WHERE artista LIKE :pesquisa OR titulo LIKE :pesquisa");
		$result->bindValue(':pesquisa', '%'.$trecho.'%');
		$result->execute();
		while($row = $result->fetch( PDO::FETCH_ASSOC )) {
			$saida .= "<tr><td>".$row['id']."</td>";
			$saida .= "<td>".$row['artista']."</td>";
			$saida .= "<td>".$row['titulo']."</td>";
			$saida .= "<td><a class=\"pedir\" href=\"".$row['id']."\">Pedir</a></td></tr>";
		}
		$saida .= "</table>";
		$db = NULL;
	} catch(PDOException $e) {
		$saida = 'Exception : '.$e->getMessage();
		echo $saida;
	}
	echo $saida;
}
?>
