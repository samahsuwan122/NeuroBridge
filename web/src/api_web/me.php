<?php

declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

applyCors(['GET', 'OPTIONS']);

if (
    ($_SERVER['REQUEST_METHOD'] ?? 'GET') !==
    'GET'
) {
    jsonResponse([
        'success' => false,
        'message' => 'طريقة الطلب غير مسموحة'
    ], 405);
}

require_once __DIR__ . '/db.php';

$authenticated =
    authenticatedAccount($pdo);

$publicUser = publicAccount(
    $authenticated['row'],
    $authenticated['type']
);

jsonResponse([
    'success' => true,
    'user' => $publicUser,
    'roles' => $publicUser['roles']
]);