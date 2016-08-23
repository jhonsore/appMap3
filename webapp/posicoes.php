<?php
header('Access-Control-Allow-Origin: *');
header('Cache-Control: no-cache, must-revalidate');
header('Content-Type: application/json; charset=utf-8');

$json_str['status'] = true;

$json_str['locais'][] = "-20.316746, -40.319567";
$json_str['locais'][] = "-20.316746, -40.319567";
$json_str['locais'][] = "-20.307926, -40.316646";
$json_str['locais'][] = "-20.302345, -40.314406";
$json_str['locais'][] = "-20.299350, -40.310998";
$json_str['locais'][] = "-20.301941, -40.304396";
$json_str['locais'][] = "-20.314593, -40.302100";
$json_str['locais'][] = "-20.299888, -40.297005";
$json_str['locais'][] = "-20.284004, -40.301167";
$json_str['locais'][] = "-20.274412, -40.297184";
$json_str['locais'][] = "-20.255866, -40.296969";


echo json_encode($json_str);