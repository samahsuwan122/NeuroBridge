<?php

declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

applyCors(['POST', 'OPTIONS']);

if (
    ($_SERVER['REQUEST_METHOD'] ?? 'GET') !==
    'POST'
) {
    respond([
        'success' => false,
        'message' => 'طريقة الطلب غير مسموحة'
    ], 405);
}

require_once __DIR__ . '/db.php';

$input = jsonBody();

$fullName = trim(
    (string)($input['full_name'] ?? '')
);

$email = strtolower(
    trim((string)($input['email'] ?? ''))
);

$phone = trim(
    (string)($input['phone'] ?? '')
);

$password = (string)(
    $input['password'] ?? ''
);

$confirmPassword = (string)(
    $input['confirm_password'] ?? ''
);

$role = (string)(
    $input['role'] ?? ''
);

$language = (string)(
    $input['preferred_language'] ?? 'ar'
);

$phone = $phone !== '' ? $phone : null;

$allowedRegistrationRoles = [
    'doctor',
    'therapist',
    'family'
];

$allowedRegistrationLanguages = [
    'ar',
    'en',
    'fr',
    'es',
    'de'
];

if (
    !in_array(
        $language,
        $allowedRegistrationLanguages,
        true
    )
) {
    $language = 'ar';
}

if ($fullName === '') {
    respond([
        'success' => false,
        'message' => 'الاسم الكامل مطلوب'
    ], 422);
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respond([
        'success' => false,
        'message' => 'البريد الإلكتروني غير صحيح'
    ], 422);
}

if (strlen($password) < 8) {
    respond([
        'success' => false,
        'message' => 'كلمة المرور يجب أن تكون 8 خانات على الأقل'
    ], 422);
}

if (
    !hash_equals(
        $password,
        $confirmPassword
    )
) {
    respond([
        'success' => false,
        'message' => 'كلمتا المرور غير متطابقتين'
    ], 422);
}

if (
    !in_array(
        $role,
        $allowedRegistrationRoles,
        true
    )
) {
    respond([
        'success' => false,
        'message' => 'يرجى اختيار نوع الحساب'
    ], 422);
}

/*
 * التحقق من جدول مستخدمي التطبيق.
 */
$usersCheck = $pdo->prepare(
    'SELECT id
     FROM users
     WHERE LOWER(email) = LOWER(?)
        OR (? IS NOT NULL AND phone = ?)
     LIMIT 1'
);

$usersCheck->execute([
    $email,
    $phone,
    $phone
]);

if ($usersCheck->fetch()) {
    respond([
        'success' => false,
        'message' => 'البريد أو الهاتف مستخدم مسبقًا'
    ], 409);
}

/*
 * التحقق من جدول مستخدمي الويب.
 */
$staffCheck = $pdo->prepare(
    'SELECT id
     FROM web_staff_users
     WHERE LOWER(email) = LOWER(?)
        OR (? IS NOT NULL AND phone = ?)
     LIMIT 1'
);

$staffCheck->execute([
    $email,
    $phone,
    $phone
]);

if ($staffCheck->fetch()) {
    respond([
        'success' => false,
        'message' => 'البريد أو الهاتف مستخدم مسبقًا'
    ], 409);
}

$pdo->beginTransaction();

try {
    $passwordHash = password_hash(
        $password,
        PASSWORD_DEFAULT
    );

    if ($role === 'family') {
        /*
         * العائلة تستخدم الموبايل والويب.
         */
        $insertFamily = $pdo->prepare(
            "INSERT INTO users (
                full_name,
                email,
                phone,
                preferred_language,
                password_hash,
                role,
                is_verified
            ) VALUES (
                ?,
                ?,
                ?,
                ?,
                ?,
                'caregiver',
                0
            )"
        );

        $insertFamily->execute([
            $fullName,
            $email,
            $phone,
            $language,
            $passwordHash
        ]);

        $accountId =
            (int)$pdo->lastInsertId();

        $accountType = 'family';

        $insertAccess = $pdo->prepare(
            "INSERT INTO web_family_access (
                user_id,
                status
             ) VALUES (
                ?,
                'pending'
             )"
        );

        $insertAccess->execute([
            $accountId
        ]);
    } else {
        /*
         * الطبيب والمعالج للويب فقط.
         */
        $insertStaff = $pdo->prepare(
            "INSERT INTO web_staff_users (
                full_name,
                email,
                phone,
                password_hash,
                role,
                preferred_language,
                status
            ) VALUES (
                ?,
                ?,
                ?,
                ?,
                ?,
                ?,
                'pending'
            )"
        );

        $insertStaff->execute([
            $fullName,
            $email,
            $phone,
            $passwordHash,
            $role,
            $language
        ]);

        $accountId =
            (int)$pdo->lastInsertId();

        $accountType = 'staff';
    }

    /*
     * تسجيل الطلب ليظهر للأدمن.
     */
    $insertRequest = $pdo->prepare(
        "INSERT INTO web_registration_requests (
            account_type,
            account_id,
            requested_role,
            status
         ) VALUES (
            ?,
            ?,
            ?,
            'pending'
         )"
    );

    $insertRequest->execute([
        $accountType,
        $accountId,
        $role
    ]);

    $requestId =
        (int)$pdo->lastInsertId();

    $pdo->commit();

    respond([
        'success' => true,
        'message' => 'تم إرسال طلب إنشاء الحساب. يمكنك تسجيل الدخول بعد موافقة الأدمن',
        'request' => [
            'id' => $requestId,
            'role' => $role,
            'status' => 'pending'
        ]
    ], 201);
} catch (Throwable $exception) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }

    respond([
        'success' => false,
        'message' => 'تعذر إنشاء طلب الحساب'
    ], 500);
}