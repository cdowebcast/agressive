<?php
header('Content-Type: application/json');

$dir = "/usr/local/musicas"; //path
$list = array(); //main array
$id = 0;

$iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir));
foreach ($iterator as $file) {
    if ($file->isDir()) continue;
    $caminho = $file->getPathname();
    $partes = pathinfo($caminho);
    $titulo = $partes['filename'];
    $t = explode('-', $titulo);
    $artista = $t[0];
    $musica = (isset($t[1])) ? $t[1] : 'Musica Desconhecida';
    $id++;

    $tmp = array(
        'id' => $id,
        'artista' => trim($artista),
        'musica' => trim($musica),
        'titulo' => trim($titulo),
        'arquivo' => $caminho
    );
    array_push($list, $tmp);
}

//echo json_encode($list);
$dados = json_encode($list);

$fp = fopen('lista.json', 'w');
fwrite($fp, $dados);
fclose($fp);