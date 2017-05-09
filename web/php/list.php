<?php
try
 {
   $db = new PDO("sqlite:../db/agressive.sqlite") or die("Impossivel criar BD");
   //now output the data to a simple html table...
   print "<table border=1>";
   print "<tr><td>Id</td><td>Artista</td><td>Titulo</td><td>Curtidas</td></tr>";
   $result = $db->prepare('SELECT * FROM musicas');
   $result->execute();
   while($row = $result->fetch( PDO::FETCH_ASSOC ))
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
