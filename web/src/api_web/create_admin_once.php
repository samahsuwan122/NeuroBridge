<?php

declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/db.php';

/*
 * غيّري البريد وكلمة المرور كما تريدين.
 */
$fullName = 'Admin';
$email = 'admin.demo@neurobridge.local';
$phone = null;

/*
 * اكتبي هنا كلمة مرور جديدة من 8 خانات أو أكثر.
 */
$password = 'Admin12345';

$preferredLanguage = 'ar';

if (strlen($password) < 8) {
    http_response_code(422);

    echo json_encode([
        'success' => false,
        'message' => 'كلمة المرور يجب أن تكون 8 خانات على الأقل'
    ], JSON_UNESCAPED_UNICODE);

    exit;
}

try {
    $passwordHash = password_hash(
        $password,
        PASSWORD_DEFAULT
    );

    /*
     * البحث عن حساب الأدمن.
     */
    $find = $pdo->prepare(
        'SELECT id
         FROM web_staff_users
         WHERE LOWER(email) = LOWER(?)
         LIMIT 1'
    );

    $find->execute([$email]);

    $existing = $find->fetch();

    if ($existing) {
        /*
         * إذا كان موجودًا، نحدّث كلمة المرور ونفعّله.
         */
        $update = $pdo->prepare(
            "UPDATE web_staff_users
             SET
                full_name = ?,
                phone = ?,
                password_hash = ?,
                role = 'admin',
                preferred_language = ?,
                status = 'active'
             WHERE id = ?"
        );

        $update->execute([
            $fullName,
            $phone,
            $passwordHash,
            $preferredLanguage,
            $existing['id']
        ]);

        echo json_encode([
            'success' => true,
            'message' => 'تم تحديث حساب الأدمن وتفعيل كلمة المرور الجديدة',
            'email' => $email
        ], JSON_UNESCAPED_UNICODE);

        exit;
    }

    /*
     * إنشاء حساب أدمن جديد.
     */
    $insert = $pdo->prepare(
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
            'admin',
            ?,
            'active'
         )"
    );

    $insert->execute([
        $fullName,
        $email,
        $phone,
        $passwordHash,
        $preferredLanguage
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'تم إنشاء حساب الأدمن بنجاح',
        'email' => $email
    ], JSON_UNESCAPED_UNICODE);
} catch (PDOException $exception) {
    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'تعذر إنشاء حساب الأدمن'
    ], JSON_UNESCAPED_UNICODE);
}