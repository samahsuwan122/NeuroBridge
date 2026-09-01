<?php

declare(strict_types=1);

require_once __DIR__ . '/helpers.php';

applyCors(['GET', 'PATCH', 'OPTIONS']);

require_once __DIR__ . '/db.php';

requireAdmin($pdo);

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

$allowedRequestStatuses = [
    'pending',
    'reviewed',
    'accepted',
    'declined'
];

function accessRequestSql(): string
{
    return "
        SELECT
            requests.id,
            requests.account_type,
            requests.account_id,
            requests.requested_role,
            requests.status,
            requests.admin_note,
            requests.created_at,
            requests.updated_at,

            CASE
                WHEN requests.account_type = 'staff'
                    THEN staff.full_name
                ELSE family.full_name
            END AS full_name,

            CASE
                WHEN requests.account_type = 'staff'
                    THEN staff.email
                ELSE family.email
            END AS email,

            CASE
                WHEN requests.account_type = 'staff'
                    THEN staff.phone
                ELSE family.phone
            END AS phone

        FROM web_registration_requests AS requests

        LEFT JOIN web_staff_users AS staff
            ON requests.account_type = 'staff'
            AND staff.id = requests.account_id

        LEFT JOIN users AS family
            ON requests.account_type = 'family'
            AND family.id = requests.account_id
    ";
}

function formatRegistrationRequest(array $row): array
{
    return [
        'id' => (string)$row['id'],
        'full_name' =>
            (string)($row['full_name'] ?? ''),
        'email' =>
            (string)($row['email'] ?? ''),
        'phone' => $row['phone'] ?? null,
        'requested_role' =>
            (string)$row['requested_role'],
        'organization' => null,
        'message' => null,
        'status' => (string)$row['status'],
        'admin_note' =>
            $row['admin_note'] ?? null,
        'created_at' =>
            (string)$row['created_at'],
        'updated_at' =>
            (string)$row['updated_at']
    ];
}

/*
 * جلب طلبات الوصول.
 */
if ($method === 'GET') {
    $status = trim(
        (string)($_GET['status'] ?? '')
    );

    if (
        $status !== '' &&
        !in_array(
            $status,
            $allowedRequestStatuses,
            true
        )
    ) {
        respond([
            'success' => false,
            'message' => 'حالة الطلب غير صحيحة'
        ], 422);
    }

    $sql = accessRequestSql();
    $parameters = [];

    if ($status !== '') {
        $sql .= ' WHERE requests.status = ?';
        $parameters[] = $status;
    }

    $sql .= ' ORDER BY requests.created_at DESC';

    $statement = $pdo->prepare($sql);
    $statement->execute($parameters);

    $rows = $statement->fetchAll();

    $requests = array_map(
        'formatRegistrationRequest',
        $rows
    );

    respond([
        'success' => true,
        'total' => count($requests),
        'limit' => count($requests),
        'offset' => 0,
        'requests' => $requests
    ]);
}

/*
 * تحديث طلب الوصول.
 */
if ($method === 'PATCH') {
    $requestId = filter_var(
        $_GET['id'] ?? null,
        FILTER_VALIDATE_INT
    );

    if (!$requestId) {
        respond([
            'success' => false,
            'message' => 'رقم الطلب غير صحيح'
        ], 422);
    }

    $input = jsonBody();

    $statusProvided =
        array_key_exists('status', $input);

    $noteProvided =
        array_key_exists('admin_note', $input);

    if (!$statusProvided && !$noteProvided) {
        respond([
            'success' => false,
            'message' => 'لا توجد بيانات لتحديثها'
        ], 422);
    }

    $newStatus = $statusProvided
        ? (string)$input['status']
        : null;

    if (
        $newStatus !== null &&
        !in_array(
            $newStatus,
            $allowedRequestStatuses,
            true
        )
    ) {
        respond([
            'success' => false,
            'message' => 'حالة الطلب غير صحيحة'
        ], 422);
    }

    $adminNote = $noteProvided
        ? trim(
            (string)($input['admin_note'] ?? '')
        )
        : null;

    $pdo->beginTransaction();

    try {
        $find = $pdo->prepare(
            'SELECT *
             FROM web_registration_requests
             WHERE id = ?
             FOR UPDATE'
        );

        $find->execute([$requestId]);

        $request = $find->fetch();

        if (!$request) {
            $pdo->rollBack();

            respond([
                'success' => false,
                'message' => 'طلب الوصول غير موجود'
            ], 404);
        }

        $fields = [];
        $values = [];

        if ($statusProvided) {
            $fields[] = 'status = ?';
            $values[] = $newStatus;
        }

        if ($noteProvided) {
            $fields[] = 'admin_note = ?';

            $values[] = $adminNote !== ''
                ? $adminNote
                : null;
        }

        $values[] = $requestId;

        $update = $pdo->prepare(
            'UPDATE web_registration_requests
             SET ' . implode(', ', $fields) . '
             WHERE id = ?'
        );

        $update->execute($values);

        /*
         * عند القبول يتم تفعيل الحساب.
         * عند الرفض يتم تعطيله.
         */
        if (
            $statusProvided &&
            in_array(
                $newStatus,
                ['accepted', 'declined'],
                true
            )
        ) {
            $accountStatus =
                $newStatus === 'accepted'
                    ? 'active'
                    : 'inactive';

            if (
                $request['account_type'] ===
                'staff'
            ) {
                $updateStaff = $pdo->prepare(
                    'UPDATE web_staff_users
                     SET status = ?
                     WHERE id = ?'
                );

                $updateStaff->execute([
                    $accountStatus,
                    $request['account_id']
                ]);
            } else {
                $updateFamily = $pdo->prepare(
                    'INSERT INTO web_family_access (
                        user_id,
                        status
                     ) VALUES (?, ?)
                     ON DUPLICATE KEY UPDATE
                        status = VALUES(status)'
                );

                $updateFamily->execute([
                    $request['account_id'],
                    $accountStatus
                ]);

                $verified =
                    $newStatus === 'accepted'
                        ? 1
                        : 0;

                $updateUser = $pdo->prepare(
                    "UPDATE users
                     SET is_verified = ?
                     WHERE id = ?
                       AND role = 'caregiver'"
                );

                $updateUser->execute([
                    $verified,
                    $request['account_id']
                ]);
            }
        }

        $readUpdated = $pdo->prepare(
            accessRequestSql() .
            ' WHERE requests.id = ?
              LIMIT 1'
        );

        $readUpdated->execute([$requestId]);

        $updatedRequest =
            $readUpdated->fetch();

        $pdo->commit();

        respond(
            formatRegistrationRequest(
                $updatedRequest
            )
        );
    } catch (Throwable $exception) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }

        respond([
            'success' => false,
            'message' => 'تعذر تحديث طلب الوصول'
        ], 500);
    }
}

respond([
    'success' => false,
    'message' => 'طريقة الطلب غير مسموحة'
], 405);