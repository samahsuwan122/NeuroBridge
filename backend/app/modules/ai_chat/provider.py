"""Safe AI provider boundary. Replace MockAIProvider only after safety review."""

from typing import Protocol

SYSTEM_PROMPT = """You are the NeuroBridge AI Companion. Use a warm, supportive tone and simple language.
Adapt answers to the authenticated role: patient, family, or care team. Only help with app navigation,
activity explanations, encouragement, family message or memory ideas, performance-only summaries, and
draft follow-up notes. Never diagnose, recommend treatment, make treatment decisions, advise about
medication, predict risk, or give medical instructions. For any care-related concern, recommend review
by the person's qualified care team. Do not interpret performance as a medical condition."""

CARE_TERMS = (
    "diagnos", "medicine", "medication", "dose", "treatment", "symptom",
    "emergency", "pain", "risk", "doctor", "دواء", "جرعة", "تشخيص", "علاج", "ألم",
)


class AIProvider(Protocol):
    def respond(self, *, message: str, role: str, language: str) -> str: ...


class MockAIProvider:
    """Deterministic, non-clinical fallback requiring no API key."""

    def respond(self, *, message: str, role: str, language: str) -> str:
        arabic = language == "ar"
        if any(term in message.lower() for term in CARE_TERMS):
            return (
                "لا أستطيع تقديم تشخيص أو قرار علاجي أو نصيحة دوائية. يرجى مشاركة هذا القلق مع فريق الرعاية المؤهل للمراجعة. يمكنني مساعدتك في صياغة رسالة قصيرة لهم."
                if arabic else
                "I can’t provide a diagnosis, treatment decision, or medication advice. Please share this concern with the qualified care team for review. I can help you draft a short message to them."
            )
        if role == "patient":
            return (
                "لنأخذها خطوة بسيطة في كل مرة. افتح نشاط اليوم، اقرأ التعليمات القصيرة، ثم اضغط بدء عندما تكون مستعدًا. يمكنني شرح أي خطوة في التطبيق."
                if arabic else
                "Let’s take it one simple step at a time. Open Today’s Activity, read the short instructions, then select Start when you’re ready. I can explain any app step."
            )
        if role == "family":
            return (
                "اقتراح داعم: «كل خطوة صغيرة مهمة، ونحن فخورون بمحاولتك اليوم.» يمكنك أيضًا إضافة صورة مألوفة مع تذكير قصير ولطيف."
                if arabic else
                "Supportive suggestion: “Every small step matters, and we’re proud you practiced today.” You could also add a familiar photo with one short, gentle reminder."
            )
        return (
            "مسودة ملخص قائمة على الأداء: اكتملت الأنشطة المسجلة كما هو موضح في لوحة المتابعة. راجع فريق الرعاية أي عناصر غير مكتملة أو تغيّرات ملحوظة قبل اتخاذ أي قرار."
            if arabic else
            "Performance-only draft: recorded activities were completed as shown in the dashboard. The care team should review incomplete items or notable changes before making any decisions."
        )


provider: AIProvider = MockAIProvider()
