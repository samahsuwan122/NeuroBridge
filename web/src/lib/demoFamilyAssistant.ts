import type { Lang, TranslationKey } from "../i18n/translations";

export type AssistantTopic = "medical" | "memories" | "encouragement" | "appointments" | "billing" | "messages" | "reports" | "activities" | "care" | "settings" | "usage" | "unknown";

export interface DemoAssistantReply {
  topic: AssistantTopic;
  responseKey: TranslationKey;
  titleKey: TranslationKey;
  followUpKeys: TranslationKey[];
}

const words: Record<AssistantTopic, string[]> = {
  medical: ["diagnos", "medicine", "medication", "dose", "change my medication", "stop medication", "treatment", "emergency", "prognosis", "will recover", "dangerous", "doctor decision", "تشخيص", "دواء", "تغيير الدواء", "إيقاف الدواء", "طوارئ", "توقعات المرض", "العلاج", "خطير", "جرعة", "diagnostic", "médicament", "traitement", "medicamento", "tratamiento", "diagnose", "medikament", "behandlung"],
  memories: ["memory", "memories", "photo", "ذكر", "صورة", "souvenir", "recuerdo", "erinner"],
  encouragement: ["encour", "supportive message", "تشجيع", "رسالة", "encouragement", "ánimo", "ermutigung"],
  appointments: ["appointment", "موعد", "موعد", "rendez-vous", "cita", "termin"],
  billing: ["payment", "paid", "payer", "receipt", "invoice", "billing", "دفع", "مدفوع", "إيصال", "فاتورة", "paiement", "reçu", "pago", "recibo", "zahlung", "quittung"],
  messages: ["message", "chat", "محادث", "رسائل", "nachricht", "mensaje"],
  reports: ["report", "summary", "تقرير", "rapport", "informe", "bericht"],
  activities: ["activity", "performance", "result", "session", "%", "نشاط", "أداء", "نتائج", "activité", "rendement", "actividad", "resultado", "leistung", "sitzung"],
  care: ["care team", "doctor question", "therapist question", "فريق الرعاية", "الطبيب", "المعالج", "équipe", "preguntas", "betreuungsteam"],
  settings: ["setting", "language", "لغة", "إعداد", "paramètre", "idioma", "einstellung", "sprache"],
  usage: ["neurobridge", "how do i", "navigate", "استخدام", "كيف", "utiliser", "cómo", "verwenden"],
  unknown: [],
};

const responseKeys: Record<AssistantTopic, TranslationKey> = {
  medical: "ai.family.response.medical", memories: "ai.family.response.memories",
  encouragement: "ai.family.response.encouragement", appointments: "ai.family.response.appointments",
  billing: "ai.family.response.appointments",
  messages: "ai.family.response.messages", reports: "ai.family.response.reports",
  activities: "ai.family.response.activities", care: "ai.family.response.care",
  settings: "ai.family.response.settings", usage: "ai.family.response.usage",
  unknown: "ai.family.response.unknown",
};

const titleKeys: Record<AssistantTopic, TranslationKey> = {
  medical: "ai.family.title.careQuestions", memories: "ai.family.title.memories",
  encouragement: "ai.family.title.encouragement", appointments: "ai.family.title.appointments",
  billing: "ai.family.title.appointments",
  messages: "ai.family.title.messages", reports: "ai.family.title.reports",
  activities: "ai.family.title.activities", care: "ai.family.title.careQuestions",
  settings: "ai.family.title.settings", usage: "ai.family.title.neurobridge",
  unknown: "ai.family.title.conversation",
};

const followUps: Partial<Record<AssistantTopic, TranslationKey[]>> = {
  memories: ["ai.family.followup.memoryVideo", "ai.family.followup.memoryVoice", "ai.family.followup.memorySearch"],
  reports: ["ai.family.followup.explainResults", "ai.family.followup.prepareDoctor"],
  activities: ["ai.family.followup.explainResults", "ai.family.followup.prepareDoctor"],
  appointments: ["ai.family.followup.prepareDoctor", "ai.family.title.appointments"],
  billing: ["ai.family.title.appointments", "ai.family.followup.prepareDoctor"],
  encouragement: ["ai.family.suggestion.encouragement", "ai.family.followup.prepareDoctor"],
};

export function demoFamilyAssistantResponse(input: string, _lang: Lang): DemoAssistantReply {
  const value = input.toLocaleLowerCase();
  const topic = (Object.keys(words) as AssistantTopic[]).find((candidate) =>
    candidate !== "unknown" && words[candidate].some((word) => value.includes(word)),
  ) ?? "unknown";
  return { topic, responseKey: responseKeys[topic], titleKey: titleKeys[topic], followUpKeys: followUps[topic] ?? [] };
}
