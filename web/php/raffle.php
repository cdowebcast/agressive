<?php

$players = array(
        "A" => 10,
        "B" => 1,
        "C" => 20,
        "D" => 2
);
$sum = array_sum($players);
echo $random = rand(1, $sum)."\n";
foreach($players as $player => $points) {
        $winner = $player;
        $random -= $points;
        if($random <= 0)
                break;
}
echo $winner."\n";