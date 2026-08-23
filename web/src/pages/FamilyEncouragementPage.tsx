import { MultimediaEncouragementComposer } from "../components/MultimediaEncouragementComposer";
import { useI18n } from "../i18n/useI18n";
import familyEncouragementHero from "../assets/family-encouragement-hero.png";

export function FamilyEncouragementPage() {
  const { t } = useI18n();

  return (
    <div className="page page--wide encouragement-page">
      <section className="enc-hero" aria-labelledby="encouragement-page-title">
        <div className="enc-hero__content">
          <span className="eyebrow">{t("encourage.eyebrow")}</span>
          <h1 id="encouragement-page-title">{t("encourage.title")}</h1>
          <p className="enc-hero__phrase">{t("encourage.phrase")}</p>
          <p className="enc-hero__description">{t("encourage.description")}</p>
          <a className="enc-hero__cta" href="#encouragement-composer">
            <span aria-hidden="true">＋</span>
            {t("encourage.heroCta")}
          </a>
        </div>
        <div className="enc-hero__visual" aria-hidden="true">
          <div className="enc-hero__photo-slot">
            <img src={familyEncouragementHero} alt="" />
          </div>
          <span className="enc-hero__heart">♡</span>
          <div className="enc-hero__visual-copy">
            <strong>{t("encourage.visualTitle")}</strong>
            <small>{t("encourage.visualHint")}</small>
          </div>
        </div>
        <span className="enc-hero__orb enc-hero__orb--one" aria-hidden="true" />
        <span className="enc-hero__orb enc-hero__orb--two" aria-hidden="true" />
      </section>

      <MultimediaEncouragementComposer />
    </div>
  );
}
