<?php
declare(strict_types=1);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, OPTIONS');

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once __DIR__ . '/db.php';

function respond(int $status, array $data): never
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function bearerToken(): string
{
    $authorization = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if ($authorization === '' && function_exists('getallheaders')) {
        $headers = getallheaders();
        $authorization = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }
    if (!preg_match('/^Bearer\s+(.+)$/i', trim($authorization), $matches)) {
        respond(401, ['success' => false, 'message' => 'يرجى تسجيل الدخول']);
    }
    return trim($matches[1]);
}

try {
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'GET') {
        respond(405, ['success' => false, 'message' => 'طريقة الطلب غير مسموحة']);
    }

    $patientId = filter_var($_GET['patient_id'] ?? null, FILTER_VALIDATE_INT);
    if ($patientId === false || $patientId === null || $patientId < 1) {
        respond(422, ['success' => false, 'message' => 'رقم المريض غير صحيح']);
    }

    $session = $pdo->prepare(
        "SELECT staff.id, staff.role
         FROM web_portal_sessions AS sessions
         INNER JOIN web_staff_users AS staff ON staff.id = sessions.account_id
         WHERE sessions.account_type = 'staff'
           AND sessions.token_hash = ?
           AND sessions.expires_at > NOW()
           AND staff.status = 'active'
         LIMIT 1"
    );
    $session->execute([hash('sha256', bearerToken())]);
    $staff = $session->fetch(PDO::FETCH_ASSOC);

    if (!$staff) {
        respond(401, ['success' => false, 'message' => 'انتهت جلسة تسجيل الدخول']);
    }
    if (!in_array($staff['role'], ['doctor', 'therapist'], true)) {
        respond(403, ['success' => false, 'message' => 'غير مصرح بعرض حالة المريض']);
    }

    $assignment = $pdo->prepare(
        "SELECT id FROM web_patient_assignments
         WHERE patient_id = ? AND staff_id = ? AND active = 1 LIMIT 1"
    );
    $assignment->execute([(int) $patientId, (int) $staff['id']]);
    if (!$assignment->fetchColumn()) {
        respond(403, ['success' => false, 'message' => 'هذا المريض غير مرتبط بحسابك']);
    }

    $query = $pdo->prepare(
        "SELECT mood, sleep_quality, readiness, energy, need_help,
                checkin_date, created_at, updated_at
         FROM daily_checkins
         WHERE user_id = ?
         ORDER BY checkin_date DESC, updated_at DESC, id DESC
         LIMIT 1"
    );
    $query->execute([(int) $patientId]);
    $checkin = $query->fetch(PDO::FETCH_ASSOC);

    if ($checkin) {
        $checkin['energy'] = (int) $checkin['energy'];
        $checkin['need_help'] = (bool) $checkin['need_help'];
    }

    respond(200, ['success' => true, 'checkin' => $checkin ?: null]);
} catch (Throwable $exception) {
    respond(500, ['success' => false, 'message' => 'تعذر تحميل حالة المريض']);
}
