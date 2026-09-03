<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(204);
    exit;
}


/* -----------------------------------------
   Read user message
----------------------------------------- */

$data = json_decode(file_get_contents("php://input"), true);

$message = trim($data["message"] ?? "");
$currentPage = trim($data["currentPage"] ?? "Home");

$allowedPages = [
    "Home",
    "About",
    "Platform",
    "Patients",
    "Families",
    "Care Teams",
    "Resources"
];

if (!in_array($currentPage, $allowedPages, true)) {
    $currentPage = "Home";
}

if ($message === "") {
    http_response_code(400);

    echo json_encode([
        "reply" => "Message is required."
    ], JSON_UNESCAPED_UNICODE);

    exit;
}


/* -----------------------------------------
   Gemini API Key
----------------------------------------- */

$apiKey = getenv("GEMINI_API_KEY");

if (!$apiKey) {
    http_response_code(500);

    echo json_encode([
        "reply" => "Sorry, the NeuroBridge Assistant could not process your request. Please try again."
    ], JSON_UNESCAPED_UNICODE);

    exit;
}


/* -----------------------------------------
   Gemini Model
----------------------------------------- */

$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent";


/* -----------------------------------------
   NeuroBridge Instructions
----------------------------------------- */

$systemPrompt = "
You are the NeuroBridge Assistant for the public NeuroBridge website.

ABOUT NEUROBRIDGE:
NeuroBridge is a cognitive rehabilitation platform that connects patients, family members, doctors, therapists, and administrators in one system.

PUBLIC WEBSITE:
The NeuroBridge public website contains:
- Home
- About
- Platform
- Patients
- Families
- Care Teams
- Resources
- Sign in
- Create account

ACCOUNT TYPES:
Users can create accounts as:
- Patient
- Family Member
- Doctor
- Therapist

REGISTRATION:
- A visitor can create an account from the NeuroBridge registration page.
- The user chooses the account type and enters the required registration information.
- Email verification is used to verify the account.
- Doctor and Therapist accounts require administrative approval before full provider access is granted.
- Do not invent registration steps that are not provided here.

PATIENT EXPERIENCE:
Patients can use NeuroBridge for cognitive rehabilitation activities and games.
The platform is designed to provide a simple and accessible patient experience.

FAMILY EXPERIENCE:
Family members can support the patient, follow appropriate progress information, share memories and encouragement, and stay connected with the care experience.

DOCTOR EXPERIENCE:
Doctors use the secure NeuroBridge portal to manage and follow assigned patients, appointments, reports, communication, and care-related information available to their role.

THERAPIST EXPERIENCE:
Therapists use their secure portal to work with assigned patients, appointments, rehabilitation follow-up, communication, and therapy-related activities available to their role.

ADMINISTRATION:
Administrators manage platform users, account roles, provider accounts, access-related administration, and other administrative platform functions.

LANGUAGES:
NeuroBridge supports:
- English
- Arabic
- French
- Spanish
- German

The website also supports Arabic right-to-left layout.

APPEARANCE:
NeuroBridge supports light and dark appearance modes.

CURRENT PAGE:
The visitor is currently viewing the {$currentPage} page.

PAGE DESCRIPTIONS:
- Home: General introduction to NeuroBridge and its connected cognitive rehabilitation experience.
- About: Explains NeuroBridge, its purpose, connected rehabilitation experience, and the relationship between patients, families, doctors, and therapists.
- Platform: Explains the main NeuroBridge platform experience and how the different users interact with the system.
- Patients: Explains the patient experience, cognitive activities, games, and patient-oriented platform support.
- Families: Explains family involvement, encouragement, memories, appropriate progress follow-up, and family support.
- Care Teams: Explains the roles of doctors and therapists and how care teams participate in the NeuroBridge experience.
- Resources: Contains public NeuroBridge information and resources available to visitors.

Use the current page as context when the visitor asks what this page is, what they can find here, or what they can do here. Do not invent page sections, buttons, features, or medical capabilities.

YOUR PURPOSE:
Help public website visitors:
- understand what NeuroBridge is
- understand who can use the platform
- understand the general features of the platform
- navigate the public website
- understand registration and sign-in
- understand the general roles of patients, families, doctors, and therapists

SAFETY AND PRIVACY RULES:
- Do not provide medical diagnoses.
- Do not recommend medications.
- Do not prescribe treatment.
- Do not recommend medical treatment.
- Do not claim to replace a doctor or therapist.
- Do not claim to access private patient records.
- Do not claim to access user accounts, appointments, reports, or private data.
- Never invent private information.

SCOPE RULES:
- Answer only questions related to NeuroBridge, its website, platform, users, services, navigation, and general features.
- If a question is unrelated to NeuroBridge, politely explain that you can only assist with NeuroBridge.
- If information is not included in the NeuroBridge information above, do not invent it.
- Say that the information is not currently available and direct the user to the appropriate NeuroBridge page when possible.

LANGUAGE:
- Understand Modern Standard Arabic and common Arabic dialects.
- Understand informal Arabic questions.
- Reply in the same language used by the user.
- When the user writes Arabic dialect, reply in clear and natural Arabic.

RESPONSE STYLE:
- Answer the user's question immediately.
- Keep normal answers to 2 or 3 short sentences.
- Give more detail only if the user explicitly asks for more explanation.
- Use numbered steps only for procedures.
- Keep each step short.
- Avoid repeating information.
- Avoid long paragraphs.
- Do not use Markdown symbols such as **, ##, or #.
";


/* -----------------------------------------
   Request Body
----------------------------------------- */

$payload = [
    "system_instruction" => [
        "parts" => [
            [
                "text" => $systemPrompt
            ]
        ]
    ],

    "contents" => [
        [
            "role" => "user",
            "parts" => [
                [
                    "text" => $message
                ]
            ]
        ]
    ],

    "generationConfig" => [
        "maxOutputTokens" => 200,
        "thinkingConfig" => [
            "thinkingLevel" => 0
        ]
    ]
];


/* -----------------------------------------
   Prepare cURL
----------------------------------------- */

$ch = curl_init($url);

curl_setopt_array($ch, [
    CURLOPT_POST => true,
    CURLOPT_RETURNTRANSFER => true,

    CURLOPT_CONNECTTIMEOUT => 5,
    CURLOPT_TIMEOUT => 15,

    CURLOPT_IPRESOLVE => CURL_IPRESOLVE_V4,

    CURLOPT_HTTPHEADER => [
        "Content-Type: application/json",
        "x-goog-api-key: " . $apiKey
    ],

    CURLOPT_POSTFIELDS => json_encode(
        $payload,
        JSON_UNESCAPED_UNICODE
    )
]);


/* -----------------------------------------
   Send request
----------------------------------------- */

$response = false;
$statusCode = 0;
$curlError = "";

$maxAttempts = 2;

for ($attempt = 1; $attempt <= $maxAttempts; $attempt++) {

    $response = curl_exec($ch);

    $statusCode = curl_getinfo(
        $ch,
        CURLINFO_HTTP_CODE
    );

    $curlError = curl_error($ch);


    /*
       Successful request or permanent error:
       stop retrying.

       Retry only 503 because it is usually temporary.
       Do NOT retry 429.
    */

    if (
        $response !== false &&
        $statusCode !== 503
    ) {
        break;
    }


    if ($attempt < $maxAttempts) {
        sleep(1);
    }
}

curl_close($ch);


/* -----------------------------------------
   Connection Error
----------------------------------------- */

if ($response === false) {

    http_response_code(500);

    echo json_encode([
        "reply" => "Sorry, the NeuroBridge Assistant could not process your request. Please try again."
    ], JSON_UNESCAPED_UNICODE);

    if ($curlError !== "") {
        error_log("NeuroBridge chatbot connection error: " . $curlError);
    }

    exit;
}


/* -----------------------------------------
   Decode Gemini response
----------------------------------------- */

$result = json_decode($response, true);


/* -----------------------------------------
   Handle API Errors
----------------------------------------- */

if ($statusCode >= 400) {

    if ($statusCode === 429) {

        http_response_code(429);

        echo json_encode([
            "reply" => "The NeuroBridge Assistant is currently handling many requests. Please try again shortly."
        ], JSON_UNESCAPED_UNICODE);

        exit;
    }


    if ($statusCode === 503) {

        http_response_code(503);

        echo json_encode([
            "reply" => "The NeuroBridge Assistant is temporarily busy. Please try again in a moment."
        ], JSON_UNESCAPED_UNICODE);

        exit;
    }


    $googleError = $result["error"]["message"] ?? "Unknown Gemini error.";

    error_log("NeuroBridge chatbot Gemini error ({$statusCode}): " . $googleError);


    http_response_code($statusCode);

    echo json_encode([
        "reply" => "Sorry, the NeuroBridge Assistant could not process your request. Please try again."
    ], JSON_UNESCAPED_UNICODE);

    exit;
}


/* -----------------------------------------
   Extract Gemini Answer
----------------------------------------- */

$reply =
    $result["candidates"][0]["content"]["parts"][0]["text"]
    ?? "Sorry, the NeuroBridge Assistant could not process your request. Please try again.";


/* -----------------------------------------
   Return Answer
----------------------------------------- */

echo json_encode([
    "reply" => trim($reply)
], JSON_UNESCAPED_UNICODE);
