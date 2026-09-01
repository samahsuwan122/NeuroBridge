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

$input = readJsonBody();

$identifier = trim(
    (string)($input['email_or_phone'] ?? '')
);

$password = (string)(
    $input['password'] ?? ''
);

if (
    $identifier === '' ||
    $password === ''
) {
    jsonResponse([
        'success' => false,
        'message' => 'أدخل البريد أو الهاتف وكلمة المرور'
    ], 422);
}

/*
 * البحث أولًا في حسابات الويب:
 * أدمن، طبيب، معالج.
 */
$staffStatement = $pdo->prepare(
    'SELECT
        id,
        full_name,
        email,
        phone,
        password_hash,
        role,
        preferred_language,
        status AS web_status,
        created_at,
        updated_at
     FROM web_staff_users
     WHERE LOWER(email) = LOWER(?)
        OR phone = ?
     LIMIT 1'
);

$staffStatement->execute([
    $identifier,
    $identifier
]);

$account = $staffStatement->fetch();
$accountType = 'staff';

/*
 * إذا لم نجد الحساب أو كلمة المرور غير صحيحة،
 * نبحث في حسابات العائلة.
 */
if (
    !$account ||
    !password_verify(
        $password,
        $account['password_hash']
    )
) {
    $familyStatement = $pdo->prepare(
        "SELECT
            users.id,
            users.full_name,
            users.email,
            users.phone,
            users.password_hash,
            users.role,
            users.preferred_language,
            COALESCE(
                web_family_access.status,
                'inactive'
            ) AS web_status,
            users.created_at,
            users.updated_at
         FROM users
         LEFT JOIN web_family_access
            ON web_family_access.user_id = users.id
         WHERE users.role = 'caregiver'
           AND (
                LOWER(users.email) = LOWER(?)
                OR users.phone = ?
           )
         LIMIT 1"
    );

    $familyStatement->execute([
        $identifier,
        $identifier
    ]);

    $account = $familyStatement->fetch();
    $accountType = 'family';
}

if (
    !$account ||
    !password_verify(
        $password,
        $account['password_hash']
    )
) {
    jsonResponse([
        'success' => false,
        'message' => 'البريد أو الهاتف أو كلمة المرور غير صحيحة'
    ], 401);
}

$status = (string)(
    $account['web_status'] ?? 'inactive'
);

if ($status === 'pending') {
    jsonResponse([
        'success' => false,
        'message' => 'الحساب بانتظار موافقة الأدمن'
    ], 403);
}

if ($status === 'suspended') {
    jsonResponse([
        'success' => false,
        'message' => 'الحساب موقوف'
    ], 403);
}

if ($status !== 'active') {
    jsonResponse([
        'success' => false,
        'message' => 'الحساب غير نشط'
    ], 403);
}

/*
 * حذف الجلسات المنتهية.
 */
$pdo->exec(
    'DELETE FROM web_portal_sessions
     WHERE expires_at <= NOW()'
);

/*
 * إنشاء Token جديد.
 */
$token = bin2hex(
    random_bytes(32)
);

$tokenHash = hash(
    'sha256',
    $token
);

$insertSession = $pdo->prepare(
    'INSERT INTO web_portal_sessions (
        account_type,
        account_id,
        token_hash,
        expires_at
     ) VALUES (
        ?,
        ?,
        ?,
        DATE_ADD(NOW(), INTERVAL 30 DAY)
     )'
);

$insertSession->execute([
    $accountType,
    $account['id'],
    $tokenHash
]);

/*
 * عدم إعادة كلمة المرور إلى React.
 */
unset($account['password_hash']);

$publicUser = publicAccount(
    $account,
    $accountType
);

jsonResponse([
    'success' => true,
    'message' => 'تم تسجيل الدخول بنجاح',
    'access_token' => $token,
    'user' => $publicUser,
    'roles' => $publicUser['roles']
]);