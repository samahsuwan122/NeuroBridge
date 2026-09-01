<?php

declare(strict_types=1);

$host = 'localhost';
$dbName = 'u474955083_neurobridge';
$dbUser = 'u474955083_neurobri_user';
$dbPassword = 'talaandtala@1111W';

try {
    $pdo = new PDO(
        "mysql:host={$host};dbname={$dbName};charset=utf8mb4",
        $dbUser,
        $dbPassword,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]
    );
} catch (PDOException $exception) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');

    echo json_encode([
        'success' => false,
        'message' => 'تعذر الاتصال بقاعدة البيانات'
    ], JSON_UNESCAPED_UNICODE);

    exit;
}