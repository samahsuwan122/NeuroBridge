export type DemoAppointmentStatus = "confirmed" | "pending" | "cancelled" | "completed";
export type DemoPaymentStatus = "paid" | "pending" | "failed" | "refunded";
export type DemoPaymentMethod = "card" | "apple" | "google" | "center" | "later";

export interface DemoFamilyAppointment {
  id: string;
  patientId: string;
  patientName: string;
  providerId: string;
  providerName: string;
  providerRole: string;
  providerSpecialty?: string;
  date: string;
  time: string;
  type: "in_person" | "remote";
  location: string;
  amount: number;
  currency: "USD";
  appointmentStatus: DemoAppointmentStatus;
  paymentStatus: DemoPaymentStatus;
  bookedByMemberId?: string;
  bookedByName?: string;
  bookedByRelationship?: string;
  payerType: "patient" | "family";
  payerMemberId?: string;
  payerName: string;
  payerRelationship?: string;
  relationship?: string;
  paymentMethod: DemoPaymentMethod;
  maskedMethod?: string;
  receiptReference?: string;
  createdAt: string;
}

const STORAGE_KEY = "nb_family_demo_appointments";

export function readDemoAppointments(): DemoFamilyAppointment[] {
  try {
    const parsed: unknown = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
    return Array.isArray(parsed) ? parsed.filter((item): item is DemoFamilyAppointment => Boolean(item && typeof item === "object" && "id" in item)).map((item) => ({ ...item, bookedByName: item.bookedByName || "Omar", bookedByRelationship: item.bookedByRelationship || "son", payerName: item.payerName === "Demo Family" ? "Omar" : item.payerName, payerRelationship: item.payerName === "Demo Family" ? "son" : item.payerRelationship })) : [];
  } catch {
    return [];
  }
}

export function writeDemoAppointments(items: DemoFamilyAppointment[]) {
  // Safe appointment/payment metadata only. Card number, expiry and CVV are never accepted here.
  localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
}

export const demoSlots = () => {
  const day = (offset: number) => { const date = new Date(); date.setDate(date.getDate() + offset); return date.toISOString().slice(0, 10); };
  return [
    { date: day(1), times: ["10:00", "11:30", "14:00"] },
    { date: day(2), times: ["09:30", "13:00"] },
    { date: day(4), times: ["10:30", "15:30"] },
  ];
};

export const demoReference = () => `NB-${new Date().getFullYear()}-${Math.random().toString(36).slice(2, 8).toUpperCase()}`;
