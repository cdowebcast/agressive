<?php


ini_set('display_errors', 'On');
error_reporting(E_ALL);

include '../conf/config.php';

try
 {
   $trecho = $_GET['trecho'];

   //$db = new PDO("sqlite:../db/agressive.sqlite") or die("Impossivel criar BD");

   $total  = $db->query("SELECT COUNT(*) as rows FROM musicas")->fetch(PDO::FETCH_OBJ);

 $perpage = 3;
 $posts  = $total->rows;
 $pages  = ceil($posts / $perpage);

 # default
  $get_pages = isset($_GET['page']) ? $_GET['page'] : 1;

  $data = array(

  'options' => array(
    'default'   => 1,
    'min_range' => 1,
    'max_range' => $pages
    )
);

  $number = trim($get_pages);
  $number = filter_var($number, FILTER_VALIDATE_INT, $data);
  $range  = $perpage * ($number - 1);

  $prev = $number - 1;
  $next = $number + 1;

  //$stmt = $conn->prepare("SELECT ID, Author, Content FROM Posts LIMIT :limit, :perpage");



   //now output the data to a simple html table...

   //$result = $db->prepare('SELECT * FROM musicas');

   //$stmt = $db->prepare("SELECT * FROM musicas WHERE artista LIKE :pesquisa OR titulo LIKE :pesquisa LIMIT :limit, :perpage");
   $stmt = $db->prepare("SELECT * FROM musicas WHERE artista LIKE :pesquisa OR titulo LIKE :pesquisa");
   // $stmt->execute(array('pesquisa' => "%{$_GET['trecho']}%"));

   $stmt->bindValue(':pesquisa', '%'.$trecho.'%');

   //$stmt->bindParam(':perpage', $perpage, PDO::PARAM_INT);
   //$stmt->bindParam(':limit', $range, PDO::PARAM_INT);

   $stmt->execute();
   //return ($stmt->fetchColumn() != 0);

   //$result->execute();

    //$row = $stmt->fetchColumn();

    print "<table border=1>";
    print "<tr><td>Id</td><td>Artista</td><td>Titulo</td><td>Curtidas</td></tr>";

   while($row = $stmt->fetch( PDO::FETCH_ASSOC ))
   //$row = $result->fetch( PDO::FETCH_ASSOC )
   //while($row = $stmt->fetchColumn())
   {
     print "<tr><td>".$row['id']."</td>";
     print "<td>".$row['artista']."</td>";
     print "<td>".$row['titulo']."</td>";
     print "<td>".$row['caminho']."</td></tr>";
   }
   print "</table>";

   $db = NULL;
 }
 catch(PDOException $e)
 {
   print 'Exception : '.$e->getMessage();
 }
 ?>
