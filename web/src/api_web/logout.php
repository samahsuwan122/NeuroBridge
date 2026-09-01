<?php

declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

applyCors(['POST', 'OPTIONS']);

if (
    ($_SERVER['REQUEST_METHOD'] ?? 'GET') !==
    'POST'
) {
    jsonResponse([
        'success' => false,
        'message' => 'طريقة الطلب غير مسموحة'
    ], 405);
}

require_once __DIR__ . '/db.php';

$token = bearerToken();

/*
 * تسجيل الخروج يبقى ناجحًا حتى لو لم يوجد Token.
 */
if ($token !== null) {
    $tokenHash = hash(
        'sha256',
        $token
    );

    $deleteStatement = $pdo->prepare(
        'DELETE FROM web_portal_sessions
         WHERE token_hash = ?'
    );

    $deleteStatement->execute([
        $tokenHash
    ]);
}

jsonResponse([
    'success' => true,
    'message' => 'تم تسجيل الخروج'
]);