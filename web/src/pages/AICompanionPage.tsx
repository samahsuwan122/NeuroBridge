import { FormEvent, useEffect, useRef, useState } from "react";
import { getAIChatHistory, sendAIChatMessage, type AIChatMessage } from "../api/aiChat";
import { useAuth } from "../auth/AuthContext";
import { useI18n } from "../i18n/useI18n";

const copy = {
  en: {
    eyebrow: "Supportive guidance", title: "NeuroBridge AI Companion",
    disclaimer: "This assistant provides supportive guidance and performance-only summaries. It does not provide diagnosis, treatment decisions, or medical advice.",
    empty: "Start a conversation. Ask for app help, a simple activity explanation, a supportive message, or a performance-only summary.",
    placeholder: "Type a supportive question…", send: "Send", sending: "Thinking…",
    retry: "Could not load the conversation. Please try again.",
    patient: "Hello! I can explain today’s activities, encourage you, and help you use NeuroBridge.",
    family: "Hello! I can suggest supportive messages, memory ideas, and explain performance summaries in simple language.",
    care: "Hello! I can draft performance-only activity summaries and follow-up notes for care-team review.",
  },
  ar: {
    eyebrow: "إرشاد داعم", title: "المساعد الذكي من NeuroBridge",
    disclaimer: "يوفّر هذا المساعد إرشادًا داعمًا وملخصات قائمة على الأداء فقط. لا يقدّم تشخيصًا أو قرارات علاجية أو نصائح طبية.",
    empty: "ابدأ محادثة. اطلب مساعدة في التطبيق، أو شرحًا بسيطًا لنشاط، أو رسالة داعمة، أو ملخصًا قائمًا على الأداء.",
    placeholder: "اكتب سؤالًا داعمًا…", send: "إرسال", sending: "جارٍ التفكير…",
    retry: "تعذّر تحميل المحادثة. يرجى المحاولة مرة أخرى.",
    patient: "مرحبًا! يمكنني شرح أنشطة اليوم وتشجيعك ومساعدتك في استخدام NeuroBridge.",
    family: "مرحبًا! يمكنني اقتراح رسائل داعمة وأفكار للذكريات وشرح ملخصات الأداء بلغة بسيطة.",
    care: "مرحبًا! يمكنني صياغة ملخصات أنشطة قائمة على الأداء وملاحظات متابعة لمراجعة فريق الرعاية.",
  },
} as const;

export function AICompanionPage() {
  const { roles } = useAuth();
  const { lang } = useI18n();
  const c = lang === "ar" ? copy.ar : copy.en;
  const [messages, setMessages] = useState<AIChatMessage[]>([]);
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState("");
  const endRef = useRef<HTMLDivElement>(null);
  const welcome = roles.includes("doctor") || roles.includes("therapist")
    ? c.care : roles.includes("family") ? c.family : c.patient;

  useEffect(() => {
    let active = true;
    getAIChatHistory().then((result) => active && setMessages(result.messages))
      .catch(() => active && setError(c.retry)).finally(() => active && setLoading(false));
    return () => { active = false; };
  }, [c.retry]);

  useEffect(() => endRef.current?.scrollIntoView({ behavior: "smooth" }), [messages]);

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    const value = text.trim();
    if (!value || sending) return;
    setSending(true); setError("");
    try {
      const saved = await sendAIChatMessage(value);
      setMessages((items) => [...items, saved]); setText("");
    } catch { setError(c.retry); } finally { setSending(false); }
  };

  return (
    <section className="ai-companion" aria-labelledby="ai-companion-title">
      <header className="ai-companion__header"><span className="ai-companion__mark" aria-hidden="true">✦</span><div><span className="eyebrow">{c.eyebrow}</span><h1 id="ai-companion-title">{c.title}</h1></div></header>
      <p className="ai-companion__disclaimer"><span aria-hidden="true">ⓘ</span>{c.disclaimer}</p>
      <div className="ai-companion__thread" aria-live="polite" aria-busy={loading || sending}>
        <div className="ai-bubble ai-bubble--assistant"><span className="ai-bubble__avatar" aria-hidden="true">NB</span><p>{welcome}</p></div>
        {!loading && messages.length === 0 && <p className="ai-companion__empty">{c.empty}</p>}
        {messages.map((item) => <div className="ai-exchange" key={item.id}><div className="ai-bubble ai-bubble--user"><p>{item.message}</p></div><div className="ai-bubble ai-bubble--assistant"><span className="ai-bubble__avatar" aria-hidden="true">NB</span><p>{item.assistant_response}</p></div></div>)}
        {sending && <div className="ai-bubble ai-bubble--assistant"><span className="ai-bubble__avatar" aria-hidden="true">NB</span><p className="ai-typing"><i></i><i></i><i></i><span className="sr-only">{c.sending}</span></p></div>}
        <div ref={endRef} />
      </div>
      {error && <p className="ai-companion__error" role="alert">{error}</p>}
      <form className="ai-composer" onSubmit={submit}>
        <label className="sr-only" htmlFor="ai-message">{c.placeholder}</label>
        <textarea id="ai-message" rows={2} maxLength={2000} value={text} onChange={(e) => setText(e.target.value)} placeholder={c.placeholder} disabled={sending} onKeyDown={(e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); e.currentTarget.form?.requestSubmit(); } }} />
        <button className="btn btn--gold" type="submit" disabled={sending || !text.trim()}>{sending ? c.sending : c.send}</button>
      </form>
    </section>
  );
}
