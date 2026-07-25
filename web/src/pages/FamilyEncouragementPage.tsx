import { useEffect, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { EncouragementPanel } from "../components/EncouragementPanel";
import {
  Card,
  EmptyState,
  ErrorState,
  FamilySafetyNote,
  Spinner,
} from "../components/ui";
import { patientName, pickLinkedPatient } from "../lib";
import type { PatientListResponse, PatientProfile } from "../types";

/**
 * Dedicated Family Encouragement page. Hosts the full send-form + message
 * history for the family member's linked patient. Family support only — not
 * medical advice.
 */
export function FamilyEncouragementPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patient, setPatient] = useState<PatientProfile | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      // Backend scopes /patients to the family member's linked patient(s); pick
      // the profile this user is actually linked to for create actions.
      const p = await api<PatientListResponse>("/patients?limit=50");
      setPatient(pickLinkedPatient(p.patients, user?.id));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Family encouragement</span>
          <h1>Family Encouragement</h1>
          <p className="page__sub">
            Send supportive messages to{" "}
            {patient ? patientName(patient.user) : "your family member"} —{" "}
            supportive messages only, not medical advice.
          </p>
        </div>
      </div>

      {loading ? (
        <Spinner label="Loading…" />
      ) : error ? (
        <ErrorState message={error} onRetry={load} />
      ) : !patient ? (
        <EmptyState message="No linked patient yet. Once a patient is linked to your account, you can send encouragement here." />
      ) : (
        <Card>
          <EncouragementPanel patientId={patient.id} />
        </Card>
      )}

      <FamilySafetyNote />
    </div>
  );
}
