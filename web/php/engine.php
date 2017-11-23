<?php

//ini_set('display_errors', 'On');
//error_reporting(E_ALL);

include(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'conf/config.php');

$db = new PDO('sqlite:' . dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'db/agressive.sqlite') or die("Impossivel criar BD");
//$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$resultado=$db->prepare("SELECT COUNT(*) FROM pedidos");
$resultado->execute();
$registros = $resultado->fetchColumn();

// Pedidos
if ($registros > 0) {
	try {
		//$db = new PDO('sqlite:' . dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'db/agressive.sqlite') or die("Impossivel criar BD");
	   $result = $db->prepare('SELECT * FROM pedidos ORDER BY hora LIMIT 1');
	   $result->execute();
		 $row = $result->fetch();
		 print($row['caminho']);
		 //file_put_contents(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'txt/atual.txt', $row['id']);
		 //criaId(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'txt/atual.txt', $row['id']);
		 $result = $db->prepare('DELETE FROM pedidos WHERE id=:id LIMIT 1');
		 $result->bindValue(':id', $row['id']);
		 $result->execute();
		 $db = NULL;
	 } catch(PDOException $e) {
	   print 'Exception : '.$e->getMessage();
	 }
} else {
	// AutoDJ
	try {
		 $result = $db->prepare('SELECT id,caminho FROM musicas WHERE id >= (abs(random()) % (SELECT max(id) FROM musicas)) LIMIT 1');
	   $result->execute();
	   $row = $result->fetch( PDO::FETCH_ASSOC );
	   print($row['caminho']);
		 //file_put_contents(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'txt/atual.txt', $row['id']);
		 //criaId(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'txt/atual.txt', $row['id']);
	   $db = NULL;
	 } catch(PDOException $e) {
	   print 'Exception : '.$e->getMessage();
	 }
}
?>
