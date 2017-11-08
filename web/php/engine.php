<?php

include(dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'conf/config.php');

$resultado=$db->prepare("SELECT COUNT(*) FROM pedidos");
$resultado->execute();
$registros = $resultado->fetchColumn();

if ($registros > 0) {
	try {
		$result = $db->prepare('SELECT * FROM pedidos ORDER BY hora LIMIT 1');
		$result->execute();
		$row = $result->fetch();
		print($row['caminho']);
		$result = $db->prepare('DELETE FROM pedidos WHERE id=:id LIMIT 1');
		$result->bindValue(':id', $row['id']);
		$result->execute();
		$db = NULL;
	 } catch(PDOException $e) {
		print 'Exception : '.$e->getMessage();
		$result = $db->prepare('SELECT * FROM pedidos ORDER BY hora LIMIT 1');
		$result->execute();
		$row = $result->fetch();
		print($row['caminho']);
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
		$result = $db->prepare('SELECT caminho FROM musicas WHERE id >= (abs(random()) % (SELECT max(id) FROM musicas)) LIMIT 1');
		$result->execute();
		$row = $result->fetch( PDO::FETCH_ASSOC );
		print($row['caminho']);
		$db = NULL;
	} catch(PDOException $e) {
		print 'Exception : '.$e->getMessage();
	}
		$result = $db->prepare('SELECT caminho FROM musicas WHERE id >= (abs(random()) % (SELECT max(id) FROM musicas)) LIMIT 1');
		$result->execute();
		$row = $result->fetch( PDO::FETCH_ASSOC );
		print($row['caminho']);
		$db = NULL;
	} catch(PDOException $e) {
		print 'Exception : '.$e->getMessage();
	}
}
?>
