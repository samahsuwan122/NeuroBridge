<?php

declare(strict_types=1);
require_once __DIR__ . '/helpers.php';
applyCors('GET, POST, PUT, DELETE, OPTIONS');
require_once __DIR__ . '/db.php';
requireAdmin($pdo);

$method = $_SERVER['REQUEST_METHOD'];
$action = (string)($_GET['action'] ?? 'list');

function centerId(): int
{
    $id = filter_var($_GET['id'] ?? null, FILTER_VALIDATE_INT);
    if (!$id || $id < 1) respond(['success' => false, 'message' => 'معرّف العيادة غير صحيح'], 422);
    return (int)$id;
}

function centerPayload(array $input): array
{
    $name = trim((string)($input['name'] ?? ''));
    $address = trim((string)($input['address'] ?? '')) ?: null;
    $phone = trim((string)($input['phone'] ?? '')) ?: null;
    $email = strtolower(trim((string)($input['email'] ?? ''))) ?: null;
    $status = in_array($input['status'] ?? 'active', ['active', 'inactive'], true)
        ? $input['status'] : 'active';
    if ($name === '') respond(['success' => false, 'message' => 'اسم العيادة مطلوب'], 422);
    if ($email !== null && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        respond(['success' => false, 'message' => 'البريد الإلكتروني غير صحيح'], 422);
    }
    return [$name, $address, $phone, $email, $status];
}

function readCenter(PDO $pdo, int $id): array
{
    $query = $pdo->prepare("SELECT c.*, COUNT(a.account_id) AS assigned_count,
        SUM(a.account_type = 'staff') AS provider_count
        FROM web_medical_centers c
        LEFT JOIN web_medical_center_accounts a ON a.medical_center_id = c.id
        WHERE c.id = ? GROUP BY c.id LIMIT 1");
    $query->execute([$id]);
    $center = $query->fetch();
    if (!$center) respond(['success' => false, 'message' => 'العيادة غير موجودة'], 404);
    $center['id'] = (string)$center['id'];
    $center['assigned_count'] = (int)$center['assigned_count'];
    $center['provider_count'] = (int)$center['provider_count'];
    return $center;
}

if ($action === 'list' && $method === 'GET') {
    $rows = $pdo->query("SELECT c.*, COUNT(a.account_id) AS assigned_count,
        SUM(a.account_type = 'staff') AS provider_count
        FROM web_medical_centers c
        LEFT JOIN web_medical_center_accounts a ON a.medical_center_id = c.id
        GROUP BY c.id ORDER BY c.created_at DESC")->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (string)$row['id'];
        $row['assigned_count'] = (int)$row['assigned_count'];
        $row['provider_count'] = (int)$row['provider_count'];
    }
    respond(['success' => true, 'centers' => $rows]);
}

if ($action === 'create' && $method === 'POST') {
    [$name, $address, $phone, $email, $status] = centerPayload(jsonBody());
    $query = $pdo->prepare('INSERT INTO web_medical_centers (name, address, phone, email, status) VALUES (?, ?, ?, ?, ?)');
    $query->execute([$name, $address, $phone, $email, $status]);
    respond(readCenter($pdo, (int)$pdo->lastInsertId()), 201);
}

if ($action === 'update' && $method === 'PUT') {
    $id = centerId();
    [$name, $address, $phone, $email, $status] = centerPayload(jsonBody());
    $query = $pdo->prepare('UPDATE web_medical_centers SET name = ?, address = ?, phone = ?, email = ?, status = ? WHERE id = ?');
    $query->execute([$name, $address, $phone, $email, $status, $id]);
    respond(readCenter($pdo, $id));
}

if ($action === 'delete' && $method === 'DELETE') {
    $id = centerId();
    $count = $pdo->prepare('SELECT COUNT(*) FROM web_medical_center_accounts WHERE medical_center_id = ?');
    $count->execute([$id]);
    if ((int)$count->fetchColumn() > 0) {
        respond(['success' => false, 'message' => 'لا يمكن حذف عيادة مرتبطة بحسابات. أزل التعيينات أولًا'], 409);
    }
    $query = $pdo->prepare('DELETE FROM web_medical_centers WHERE id = ?');
    $query->execute([$id]);
    if (!$query->rowCount()) respond(['success' => false, 'message' => 'العيادة غير موجودة'], 404);
    respond(['success' => true, 'message' => 'تم حذف العيادة']);
}

if ($action === 'assign' && $method === 'POST') {
    $input = jsonBody();
    $accountId = (string)($input['account_id'] ?? '');
    if (!preg_match('/^(staff|family|patient):(\d+)$/', $accountId, $match)) {
        respond(['success' => false, 'message' => 'الحساب غير صحيح'], 422);
    }
    $center = $input['medical_center_id'] ?? null;
    if ($center === null || $center === '') {
        $query = $pdo->prepare('DELETE FROM web_medical_center_accounts WHERE account_type = ? AND account_id = ?');
        $query->execute([$match[1], (int)$match[2]]);
    } else {
        $centerValue = filter_var($center, FILTER_VALIDATE_INT);
        if (!$centerValue) respond(['success' => false, 'message' => 'العيادة غير صحيحة'], 422);
        $exists = $pdo->prepare('SELECT 1 FROM web_medical_centers WHERE id = ? LIMIT 1');
        $exists->execute([(int)$centerValue]);
        if (!$exists->fetchColumn()) respond(['success' => false, 'message' => 'العيادة غير موجودة'], 404);
        $query = $pdo->prepare('INSERT INTO web_medical_center_accounts (account_type, account_id, medical_center_id) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE medical_center_id = VALUES(medical_center_id)');
        $query->execute([$match[1], (int)$match[2], (int)$centerValue]);
    }
    respond(['success' => true, 'message' => 'تم حفظ تعيين العيادة']);
}

respond(['success' => false, 'message' => 'المسار المطلوب غير موجود'], 404);
