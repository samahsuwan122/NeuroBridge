import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider, useAuth } from "./auth/AuthContext";
import { Layout } from "./components/Layout";
import { FamilyLayout } from "./components/FamilyLayout";
import { Spinner } from "./components/ui";
import { LoginPage } from "./pages/LoginPage";
import { DashboardPage } from "./pages/DashboardPage";
import { PatientsPage } from "./pages/PatientsPage";
import { PatientDetailPage } from "./pages/PatientDetailPage";
import { DoctorAppointmentsPage } from "./pages/DoctorAppointmentsPage";
import { ReportsPage } from "./pages/ReportsPage";
import { PatientReportPage } from "./pages/PatientReportPage";
import { ReviewQueuePage } from "./pages/ReviewQueuePage";
import { FamilyDashboardPage } from "./pages/FamilyDashboardPage";
import { FamilyEncouragementPage } from "./pages/FamilyEncouragementPage";
import { FamilyAppointmentsPage } from "./pages/FamilyAppointmentsPage";
import { FamilyMessagesPage } from "./pages/FamilyMessagesPage";
import { FamilyReportsPage } from "./pages/FamilyReportsPage";
import { ProviderDetailPage } from "./pages/ProviderDetailPage";
import { AdminAccessRequestsPage } from "./pages/AdminAccessRequestsPage";
import { RoleAccessPage } from "./pages/RoleAccessPage";

function AppRoutes() {
  const { user, isClinician, isFamily, isAdmin, loading } = useAuth();

  if (loading) return <Spinner label="Restoring your session…" />;

  const supported = isClinician || isFamily || isAdmin;

  return (
    <Routes>
      <Route
        path="/login"
        element={supported ? <Navigate to="/" replace /> : <LoginPage />}
      />

      {isClinician || isAdmin ? (
        // Clinical portal (doctor / therapist) and/or admin share the Layout
        // shell. Clinician pages stay clinician-only; the admin route is added
        // only for admins. Clinicians always land here even if also family.
        <Route element={<Layout />}>
          {isClinician && <Route path="/" element={<DashboardPage />} />}
          {isClinician && (
            <Route path="/patients" element={<PatientsPage />} />
          )}
          {isClinician && (
            <Route path="/patients/:id" element={<PatientDetailPage />} />
          )}
          {isClinician && (
            <Route path="/appointments" element={<DoctorAppointmentsPage />} />
          )}
          {isClinician && <Route path="/reports" element={<ReportsPage />} />}
          {isClinician && (
            <Route path="/reports/:patientId" element={<PatientReportPage />} />
          )}
          {isClinician && (
            <Route path="/review-queue" element={<ReviewQueuePage />} />
          )}
          {isAdmin && (
            <Route
              path="/admin/access-requests"
              element={<AdminAccessRequestsPage />}
            />
          )}
          {/* A pure admin (no clinician role) lands on the admin page. */}
          {!isClinician && (
            <Route
              path="/"
              element={<Navigate to="/admin/access-requests" replace />}
            />
          )}
          <Route
            path="*"
            element={
              <Navigate
                to={isClinician ? "/" : "/admin/access-requests"}
                replace
              />
            }
          />
        </Route>
      ) : isFamily ? (
        // Family / caregiver portal.
        <Route element={<FamilyLayout />}>
          <Route path="/" element={<FamilyDashboardPage />} />
          <Route path="/encouragement" element={<FamilyEncouragementPage />} />
          <Route path="/appointments" element={<FamilyAppointmentsPage />} />
          <Route
            path="/providers/:providerId"
            element={<ProviderDetailPage />}
          />
          <Route path="/messages" element={<FamilyMessagesPage />} />
          <Route path="/reports" element={<FamilyReportsPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      ) : user ? (
        // Signed in, but the role has no web portal (e.g. a patient).
        <Route path="*" element={<RoleAccessPage />} />
      ) : (
        // Not signed in.
        <Route path="*" element={<Navigate to="/login" replace />} />
      )}
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  );
}
