<?php

declare(strict_types=1);

/*
 * يدعم:
 * applyCors(['GET', 'POST']);
 * applyCors('GET, POST');
 */
function applyCors(
    $methods = ['GET', 'POST', 'OPTIONS']
): void {
    $methodsHeader = is_array($methods)
        ? implode(', ', $methods)
        : (string)$methods;

    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    header(
        'Access-Control-Allow-Headers: Content-Type, Authorization'
    );
    header(
        'Access-Control-Allow-Methods: ' . $methodsHeader
    );

    if (
        ($_SERVER['REQUEST_METHOD'] ?? 'GET') ===
        'OPTIONS'
    ) {
        http_response_code(204);
        exit;
    }
}

/*
 * إرسال JSON وإنهاء الطلب.
 */
function jsonResponse(
    array $data,
    int $status = 200
): never {
    http_response_code($status);

    echo json_encode(
        $data,
        JSON_UNESCAPED_UNICODE |
        JSON_UNESCAPED_SLASHES
    );

    exit;
}

/*
 * اسم متوافق مع ملفات الأدمن.
 */
function respond(
    array $data,
    int $status = 200
): never {
    jsonResponse($data, $status);
}

/*
 * قراءة JSON المرسل من React.
 */
function readJsonBody(): array
{
    $rawBody = file_get_contents('php://input');

    $input = json_decode(
        $rawBody ?: '',
        true
    );

    if (!is_array($input)) {
        jsonResponse([
            'success' => false,
            'message' => 'البيانات المرسلة غير صحيحة'
        ], 400);
    }

    return $input;
}

/*
 * اسم متوافق مع الملفات الجديدة.
 */
function jsonBody(): array
{
    return readJsonBody();
}

/*
 * قراءة Bearer Token.
 */
function bearerToken(): ?string
{
    $authorization =
        $_SERVER['HTTP_AUTHORIZATION'] ?? '';

    if (
        $authorization === '' &&
        function_exists('getallheaders')
    ) {
        $headers = getallheaders();

        $authorization =
            $headers['Authorization']
            ?? $headers['authorization']
            ?? '';
    }

    if (
        !preg_match(
            '/^Bearer\s+([A-Fa-f0-9]{64})$/',
            trim($authorization),
            $matches
        )
    ) {
        return null;
    }

    return $matches[1];
}

/*
 * تجهيز الحساب بالشكل الذي يحتاجه React.
 */
function publicAccount(
    array $row,
    string $accountType
): array {
    if ($accountType === 'family') {
        $role = 'family';
    } elseif ($accountType === 'patient') {
        $role = 'patient';
    } else {
        $role = (string)($row['role'] ?? '');
    }

    $medicalCenterId = null;

    if (
        isset($row['medical_center_id']) &&
        $row['medical_center_id'] !== ''
    ) {
        $medicalCenterId =
            (string)$row['medical_center_id'];
    }

    return [
        'id' =>
            $accountType . ':' . $row['id'],

        'full_name' =>
            (string)($row['full_name'] ?? ''),

        'email' =>
            $row['email'] ?? null,

        'phone' =>
            $row['phone'] ?? null,

        'preferred_language' =>
            $row['preferred_language'] ?? 'ar',

        'status' =>
            $row['web_status']
            ?? $row['status']
            ?? 'active',

        'medical_center_id' =>
            $medicalCenterId,

        'roles' =>
            [$role],

        'created_at' =>
            $row['created_at']
            ?? date(DATE_ATOM),

        'updated_at' =>
            $row['updated_at']
            ?? $row['created_at']
            ?? date(DATE_ATOM)
    ];
}

/*
 * اسم توافق إضافي مع ملفات الأدمن.
 */
function adminAccount(
    array $row,
    string $accountType
): array {
    return publicAccount(
        $row,
        $accountType
    );
}

/*
 * التأكد من جلسة المستخدم.
 */
function authenticatedAccount(PDO $pdo): array
{
    $token = bearerToken();

    if ($token === null) {
        jsonResponse([
            'success' => false,
            'message' => 'يجب تسجيل الدخول'
        ], 401);
    }

    $tokenHash = hash(
        'sha256',
        $token
    );

    $sessionStatement = $pdo->prepare(
        'SELECT
            id,
            account_type,
            account_id,
            token_hash,
            expires_at
         FROM web_portal_sessions
         WHERE token_hash = ?
           AND expires_at > NOW()
         LIMIT 1'
    );

    $sessionStatement->execute([
        $tokenHash
    ]);

    $session = $sessionStatement->fetch();

    if (!$session) {
        jsonResponse([
            'success' => false,
            'message' =>
                'انتهت جلسة الدخول، يرجى تسجيل الدخول مجددًا'
        ], 401);
    }

    $accountType =
        (string)$session['account_type'];

    $accountId =
        (int)$session['account_id'];

    if ($accountType === 'staff') {
        $accountStatement = $pdo->prepare(
            'SELECT
                id,
                full_name,
                email,
                phone,
                role,
                preferred_language,
                status AS web_status,
                created_at
             FROM web_staff_users
             WHERE id = ?
             LIMIT 1'
        );

        $accountStatement->execute([
            $accountId
        ]);
    } elseif ($accountType === 'family') {
        $accountStatement = $pdo->prepare(
            "SELECT
                users.id,
                users.full_name,
                users.email,
                users.phone,
                users.role,
                users.preferred_language,
                COALESCE(
                    web_family_access.status,
                    'inactive'
                ) AS web_status,
                users.created_at
             FROM users
             LEFT JOIN web_family_access
                ON web_family_access.user_id =
                    users.id
             WHERE users.id = ?
               AND users.role = 'caregiver'
             LIMIT 1"
        );

        $accountStatement->execute([
            $accountId
        ]);
    } else {
        jsonResponse([
            'success' => false,
            'message' => 'نوع الحساب غير صحيح'
        ], 401);
    }

    $account = $accountStatement->fetch();

    if (!$account) {
        jsonResponse([
            'success' => false,
            'message' => 'الحساب غير موجود'
        ], 401);
    }

    $status = (string)(
        $account['web_status'] ?? 'inactive'
    );

    if ($status !== 'active') {
        jsonResponse([
            'success' => false,
            'message' => 'الحساب غير نشط'
        ], 403);
    }

    return [
        'type' => $accountType,
        'row' => $account,
        'token_hash' => $tokenHash
    ];
}

/*
 * السماح للأدمن فقط.
 */
function requireAdmin(PDO $pdo): array
{
    $authenticated =
        authenticatedAccount($pdo);

    $accountType =
        $authenticated['type'];

    $role =
        $authenticated['row']['role'] ?? '';

    if (
        $accountType !== 'staff' ||
        $role !== 'admin'
    ) {
        jsonResponse([
            'success' => false,
            'message' =>
                'هذه العملية متاحة للأدمن فقط'
        ], 403);
    }

    return $authenticated;
}

/*
 * توافق مع الملفات القديمة.
 */
function authenticatedWebUser(PDO $pdo): array
{
    $authenticated =
        authenticatedAccount($pdo);

    return $authenticated['row'];
}