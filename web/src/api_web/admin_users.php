<?php

declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

applyCors([
    'GET',
    'POST',
    'PUT',
    'OPTIONS'
]);

require_once __DIR__ . '/db.php';

requireAdmin($pdo);

$method =
    $_SERVER['REQUEST_METHOD'] ?? 'GET';

$action =
    (string)($_GET['action'] ?? 'list');

$allowedRoles = [
    'doctor',
    'therapist',
    'family'
];

$allowedStatuses = [
    'active',
    'inactive',
    'suspended'
];

$allowedLanguages = [
    'ar',
    'en',
    'fr',
    'es',
    'de'
];

/*
 * تحليل المعرّف مثل:
 * staff:1
 * family:2
 * patient:3
 */
function parseAdminAccountId(
    string $value
): array {
    if (
        !preg_match(
            '/^(staff|family|patient):(\d+)$/',
            $value,
            $matches
        )
    ) {
        respond([
            'success' => false,
            'message' =>
                'معرّف الحساب غير صحيح'
        ], 400);
    }

    return [
        $matches[1],
        (int)$matches[2]
    ];
}

/*
 * فحص البريد أو الهاتف في جميع الجداول.
 */
function identifierExists(
    PDO $pdo,
    ?string $email,
    ?string $phone
): bool {
    $users = $pdo->prepare(
        'SELECT id
         FROM users
         WHERE
            (
                ? IS NOT NULL
                AND LOWER(email) = LOWER(?)
            )
            OR
            (
                ? IS NOT NULL
                AND phone = ?
            )
         LIMIT 1'
    );

    $users->execute([
        $email,
        $email,
        $phone,
        $phone
    ]);

    if ($users->fetch()) {
        return true;
    }

    $staff = $pdo->prepare(
        'SELECT id
         FROM web_staff_users
         WHERE
            (
                ? IS NOT NULL
                AND LOWER(email) = LOWER(?)
            )
            OR
            (
                ? IS NOT NULL
                AND phone = ?
            )
         LIMIT 1'
    );

    $staff->execute([
        $email,
        $email,
        $phone,
        $phone
    ]);

    return (bool)$staff->fetch();
}

/*
 * الأدوار التي يستطيع الأدمن إدارتها.
 */
if (
    $action === 'roles' &&
    $method === 'GET'
) {
    respond([
        [
            'id' => 'doctor',
            'name' => 'doctor',
            'description' =>
                'Doctor — web only'
        ],
        [
            'id' => 'therapist',
            'name' => 'therapist',
            'description' =>
                'Therapist — web only'
        ],
        [
            'id' => 'family',
            'name' => 'family',
            'description' =>
                'Family — mobile and web'
        ]
    ]);
}

/*
 * جلب جميع المستخدمين مع العيادات.
 */
if (
    $action === 'list' &&
    $method === 'GET'
) {
    try {
        /*
         * الطبيب والمعالج والأدمن.
         */
        $staffStatement = $pdo->query(
            "SELECT
                web_staff_users.id,
                web_staff_users.full_name,
                web_staff_users.email,
                web_staff_users.phone,
                web_staff_users.role,
                web_staff_users.preferred_language,
                web_staff_users.status
                    AS web_status,
                web_staff_users.created_at,
                web_staff_users.created_at
                    AS updated_at,
                web_medical_center_accounts
                    .medical_center_id
             FROM web_staff_users
             LEFT JOIN web_medical_center_accounts
                ON web_medical_center_accounts
                    .account_type = 'staff'
               AND web_medical_center_accounts
                    .account_id =
                    web_staff_users.id
             ORDER BY
                web_staff_users.created_at DESC"
        );

        $staffRows =
            $staffStatement->fetchAll();

        /*
         * حسابات العائلة.
         */
        $familyStatement = $pdo->query(
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
                users.created_at,
                users.created_at AS updated_at,
                web_medical_center_accounts
                    .medical_center_id
             FROM users
             LEFT JOIN web_family_access
                ON web_family_access.user_id =
                    users.id
             LEFT JOIN web_medical_center_accounts
                ON web_medical_center_accounts
                    .account_type = 'family'
               AND web_medical_center_accounts
                    .account_id = users.id
             WHERE users.role = 'caregiver'
             ORDER BY users.created_at DESC"
        );

        $familyRows =
            $familyStatement->fetchAll();

        /*
         * حسابات المرضى.
         */
        $patientStatement = $pdo->query(
            "SELECT
                users.id,
                users.full_name,
                users.email,
                users.phone,
                users.role,
                users.preferred_language,
                CASE
                    WHEN users.is_verified = 1
                        THEN 'active'
                    ELSE 'inactive'
                END AS web_status,
                users.created_at,
                users.created_at AS updated_at,
                web_medical_center_accounts
                    .medical_center_id
             FROM users
             LEFT JOIN web_medical_center_accounts
                ON web_medical_center_accounts
                    .account_type = 'patient'
               AND web_medical_center_accounts
                    .account_id = users.id
             WHERE users.role = 'patient'
             ORDER BY users.created_at DESC"
        );

        $patientRows =
            $patientStatement->fetchAll();

        $accounts = [];

        foreach ($staffRows as $row) {
            $accounts[] = publicAccount(
                $row,
                'staff'
            );
        }

        foreach ($familyRows as $row) {
            $accounts[] = publicAccount(
                $row,
                'family'
            );
        }

        foreach ($patientRows as $row) {
            $accounts[] = publicAccount(
                $row,
                'patient'
            );
        }

        usort(
            $accounts,
            function (
                array $first,
                array $second
            ): int {
                $firstDate = strtotime(
                    $first['created_at']
                );

                $secondDate = strtotime(
                    $second['created_at']
                );

                return $secondDate <=> $firstDate;
            }
        );

        $offset = max(
            0,
            (int)($_GET['offset'] ?? 0)
        );

        $limit = min(
            200,
            max(
                1,
                (int)($_GET['limit'] ?? 200)
            )
        );

        respond([
            'success' => true,
            'total' => count($accounts),
            'limit' => $limit,
            'offset' => $offset,
            'users' => array_slice(
                $accounts,
                $offset,
                $limit
            )
        ]);
    } catch (PDOException $exception) {
        respond([
            'success' => false,
            'message' =>
                'تعذر تحميل المستخدمين: ' .
                $exception->getMessage()
        ], 500);
    }
}

/*
 * إنشاء حساب من لوحة الأدمن.
 */
if (
    $action === 'create' &&
    $method === 'POST'
) {
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

    $password =
        (string)($input['password'] ?? '');

    $language =
        (string)($input[
            'preferred_language'
        ] ?? 'ar');

    $status =
        (string)($input['status'] ?? 'active');

    $roles =
        $input['roles'] ?? [];

    $medicalCenterId =
        $input['medical_center_id'] ?? null;

    $email =
        $email !== '' ? $email : null;

    $phone =
        $phone !== '' ? $phone : null;

    if (
        !in_array(
            $language,
            $allowedLanguages,
            true
        )
    ) {
        $language = 'ar';
    }

    if (
        !in_array(
            $status,
            $allowedStatuses,
            true
        )
    ) {
        $status = 'active';
    }

    if (!is_array($roles)) {
        $roles = [];
    }

    $roles = array_values(
        array_unique($roles)
    );

    if ($fullName === '') {
        respond([
            'success' => false,
            'message' => 'الاسم الكامل مطلوب'
        ], 422);
    }

    if (!$email && !$phone) {
        respond([
            'success' => false,
            'message' =>
                'البريد الإلكتروني أو الهاتف مطلوب'
        ], 422);
    }

    if (
        $email !== null &&
        !filter_var(
            $email,
            FILTER_VALIDATE_EMAIL
        )
    ) {
        respond([
            'success' => false,
            'message' =>
                'البريد الإلكتروني غير صحيح'
        ], 422);
    }

    if (strlen($password) < 8) {
        respond([
            'success' => false,
            'message' =>
                'كلمة المرور يجب أن تكون 8 خانات على الأقل'
        ], 422);
    }

    if (
        count($roles) !== 1 ||
        !in_array(
            $roles[0],
            $allowedRoles,
            true
        )
    ) {
        respond([
            'success' => false,
            'message' =>
                'يرجى اختيار دور واحد'
        ], 422);
    }

    if (
        identifierExists(
            $pdo,
            $email,
            $phone
        )
    ) {
        respond([
            'success' => false,
            'message' =>
                'البريد أو الهاتف مستخدم مسبقًا'
        ], 409);
    }

    $role = (string)$roles[0];

    $pdo->beginTransaction();

    try {
        $passwordHash = password_hash(
            $password,
            PASSWORD_DEFAULT
        );

        if ($role === 'family') {
            if (!$email) {
                respond([
                    'success' => false,
                    'message' =>
                        'البريد الإلكتروني مطلوب للعائلة'
                ], 422);
            }

            $insert = $pdo->prepare(
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
                    1
                )"
            );

            $insert->execute([
                $fullName,
                $email,
                $phone,
                $language,
                $passwordHash
            ]);

            $newId =
                (int)$pdo->lastInsertId();

            $familyAccess = $pdo->prepare(
                'INSERT INTO web_family_access (
                    user_id,
                    status
                 ) VALUES (?, ?)'
            );

            $familyAccess->execute([
                $newId,
                $status
            ]);

            $accountType = 'family';
        } else {
            if (!$email) {
                respond([
                    'success' => false,
                    'message' =>
                        'البريد الإلكتروني مطلوب'
                ], 422);
            }

            $insert = $pdo->prepare(
                'INSERT INTO web_staff_users (
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
                    ?
                 )'
            );

            $insert->execute([
                $fullName,
                $email,
                $phone,
                $passwordHash,
                $role,
                $language,
                $status
            ]);

            $newId =
                (int)$pdo->lastInsertId();

            $accountType = 'staff';
        }

        /*
         * ربط الحساب بعيادة إذا تم إرسالها.
         */
        if (
            $medicalCenterId !== null &&
            $medicalCenterId !== ''
        ) {
            $centerId = filter_var(
                $medicalCenterId,
                FILTER_VALIDATE_INT
            );

            if (!$centerId) {
                throw new RuntimeException(
                    'معرّف العيادة غير صحيح'
                );
            }

            $assignment = $pdo->prepare(
                'INSERT INTO
                    web_medical_center_accounts (
                        account_type,
                        account_id,
                        medical_center_id
                    )
                 VALUES (?, ?, ?)'
            );

            $assignment->execute([
                $accountType,
                $newId,
                (int)$centerId
            ]);
        }

        $pdo->commit();

        /*
         * إعادة الحساب الذي تم إنشاؤه.
         */
        if ($accountType === 'staff') {
            $read = $pdo->prepare(
                "SELECT
                    web_staff_users.id,
                    web_staff_users.full_name,
                    web_staff_users.email,
                    web_staff_users.phone,
                    web_staff_users.role,
                    web_staff_users
                        .preferred_language,
                    web_staff_users.status
                        AS web_status,
                    web_staff_users.created_at,
                    web_staff_users.created_at
                        AS updated_at,
                    web_medical_center_accounts
                        .medical_center_id
                 FROM web_staff_users
                 LEFT JOIN
                    web_medical_center_accounts
                    ON web_medical_center_accounts
                        .account_type = 'staff'
                   AND web_medical_center_accounts
                        .account_id =
                        web_staff_users.id
                 WHERE web_staff_users.id = ?
                 LIMIT 1"
            );
        } else {
            $read = $pdo->prepare(
                "SELECT
                    users.id,
                    users.full_name,
                    users.email,
                    users.phone,
                    users.role,
                    users.preferred_language,
                    web_family_access.status
                        AS web_status,
                    users.created_at,
                    users.created_at AS updated_at,
                    web_medical_center_accounts
                        .medical_center_id
                 FROM users
                 INNER JOIN web_family_access
                    ON web_family_access.user_id =
                        users.id
                 LEFT JOIN
                    web_medical_center_accounts
                    ON web_medical_center_accounts
                        .account_type = 'family'
                   AND web_medical_center_accounts
                        .account_id = users.id
                 WHERE users.id = ?
                 LIMIT 1"
            );
        }

        $read->execute([$newId]);

        $created = $read->fetch();

        respond(
            publicAccount(
                $created,
                $accountType
            ),
            201
        );
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }

        respond([
            'success' => false,
            'message' =>
                $exception instanceof RuntimeException
                    ? $exception->getMessage()
                    : 'تعذر إنشاء الحساب'
        ], 500);
    }
}

/*
 * تفعيل أو تعطيل الحساب.
 */
if (
    in_array(
        $action,
        ['activate', 'deactivate'],
        true
    ) &&
    $method === 'POST'
) {
    [$type, $id] =
        parseAdminAccountId(
            (string)($_GET['id'] ?? '')
        );

    $status =
        $action === 'activate'
            ? 'active'
            : 'inactive';

    if ($type === 'staff') {
        $update = $pdo->prepare(
            'UPDATE web_staff_users
             SET status = ?
             WHERE id = ?'
        );

        $update->execute([
            $status,
            $id
        ]);
    } elseif ($type === 'family') {
        $update = $pdo->prepare(
            'INSERT INTO web_family_access (
                user_id,
                status
             ) VALUES (?, ?)
             ON DUPLICATE KEY UPDATE
                status = VALUES(status)'
        );

        $update->execute([
            $id,
            $status
        ]);
    } else {
        $update = $pdo->prepare(
            "UPDATE users
             SET is_verified = ?
             WHERE id = ?
               AND role = 'patient'"
        );

        $update->execute([
            $status === 'active' ? 1 : 0,
            $id
        ]);
    }

    respond([
        'success' => true,
        'message' =>
            $status === 'active'
                ? 'تم تفعيل الحساب'
                : 'تم تعطيل الحساب'
    ]);
}

/*
 * تعديل حساب.
 */
if (
    $action === 'update' &&
    $method === 'PUT'
) {
    [$type, $id] =
        parseAdminAccountId(
            (string)($_GET['id'] ?? '')
        );

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

    $language =
        (string)($input[
            'preferred_language'
        ] ?? 'ar');

    $status =
        (string)($input['status'] ?? 'active');

    $phone =
        $phone !== '' ? $phone : null;

    if (
        $fullName === '' ||
        !filter_var(
            $email,
            FILTER_VALIDATE_EMAIL
        )
    ) {
        respond([
            'success' => false,
            'message' =>
                'الاسم والبريد الصحيح مطلوبان'
        ], 422);
    }

    if (
        !in_array(
            $language,
            $allowedLanguages,
            true
        )
    ) {
        $language = 'ar';
    }

    if (
        !in_array(
            $status,
            $allowedStatuses,
            true
        )
    ) {
        $status = 'active';
    }

    try {
        if ($type === 'staff') {
            $update = $pdo->prepare(
                'UPDATE web_staff_users
                 SET
                    full_name = ?,
                    email = ?,
                    phone = ?,
                    preferred_language = ?,
                    status = ?
                 WHERE id = ?'
            );

            $update->execute([
                $fullName,
                $email,
                $phone,
                $language,
                $status,
                $id
            ]);

            $read = $pdo->prepare(
                "SELECT
                    web_staff_users.id,
                    web_staff_users.full_name,
                    web_staff_users.email,
                    web_staff_users.phone,
                    web_staff_users.role,
                    web_staff_users
                        .preferred_language,
                    web_staff_users.status
                        AS web_status,
                    web_staff_users.created_at,
                    web_staff_users.created_at
                        AS updated_at,
                    web_medical_center_accounts
                        .medical_center_id
                 FROM web_staff_users
                 LEFT JOIN
                    web_medical_center_accounts
                    ON web_medical_center_accounts
                        .account_type = 'staff'
                   AND web_medical_center_accounts
                        .account_id =
                        web_staff_users.id
                 WHERE web_staff_users.id = ?
                 LIMIT 1"
            );

            $returnType = 'staff';
        } elseif ($type === 'family') {
            $update = $pdo->prepare(
                "UPDATE users
                 SET
                    full_name = ?,
                    email = ?,
                    phone = ?,
                    preferred_language = ?
                 WHERE id = ?
                   AND role = 'caregiver'"
            );

            $update->execute([
                $fullName,
                $email,
                $phone,
                $language,
                $id
            ]);

            $access = $pdo->prepare(
                'INSERT INTO web_family_access (
                    user_id,
                    status
                 ) VALUES (?, ?)
                 ON DUPLICATE KEY UPDATE
                    status = VALUES(status)'
            );

            $access->execute([
                $id,
                $status
            ]);

            $read = $pdo->prepare(
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
                    users.created_at,
                    users.created_at AS updated_at,
                    web_medical_center_accounts
                        .medical_center_id
                 FROM users
                 LEFT JOIN web_family_access
                    ON web_family_access.user_id =
                        users.id
                 LEFT JOIN
                    web_medical_center_accounts
                    ON web_medical_center_accounts
                        .account_type = 'family'
                   AND web_medical_center_accounts
                        .account_id = users.id
                 WHERE users.id = ?
                   AND users.role = 'caregiver'
                 LIMIT 1"
            );

            $returnType = 'family';
        } else {
            $update = $pdo->prepare(
                "UPDATE users
                 SET
                    full_name = ?,
                    email = ?,
                    phone = ?,
                    preferred_language = ?,
                    is_verified = ?
                 WHERE id = ?
                   AND role = 'patient'"
            );

            $update->execute([
                $fullName,
                $email,
                $phone,
                $language,
                $status === 'active' ? 1 : 0,
                $id
            ]);

            $read = $pdo->prepare(
                "SELECT
                    users.id,
                    users.full_name,
                    users.email,
                    users.phone,
                    users.role,
                    users.preferred_language,
                    CASE
                        WHEN users.is_verified = 1
                            THEN 'active'
                        ELSE 'inactive'
                    END AS web_status,
                    users.created_at,
                    users.created_at AS updated_at,
                    web_medical_center_accounts
                        .medical_center_id
                 FROM users
                 LEFT JOIN
                    web_medical_center_accounts
                    ON web_medical_center_accounts
                        .account_type = 'patient'
                   AND web_medical_center_accounts
                        .account_id = users.id
                 WHERE users.id = ?
                   AND users.role = 'patient'
                 LIMIT 1"
            );

            $returnType = 'patient';
        }

        $read->execute([$id]);

        $row = $read->fetch();

        if (!$row) {
            respond([
                'success' => false,
                'message' =>
                    'الحساب غير موجود'
            ], 404);
        }

        respond(
            publicAccount(
                $row,
                $returnType
            )
        );
    } catch (PDOException $exception) {
        if (
            (string)$exception->getCode() ===
            '23000'
        ) {
            respond([
                'success' => false,
                'message' =>
                    'البريد أو الهاتف مستخدم مسبقًا'
            ], 409);
        }

        respond([
            'success' => false,
            'message' =>
                'تعذر تعديل الحساب: ' .
                $exception->getMessage()
        ], 500);
    }
}

respond([
    'success' => false,
    'message' =>
        'المسار المطلوب غير موجود'
], 404);