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
import { FamilyMemoriesPage } from "./pages/FamilyMemoriesPage";
import { FamilySettingsPage } from "./pages/FamilySettingsPage";
import { FamilyAppointmentsPage } from "./pages/FamilyAppointmentsPage";
import { FamilyBillingPage } from "./pages/FamilyBillingPage";
import { FamilyMessagesPage } from "./pages/FamilyMessagesPage";
import { FamilyReportsPage } from "./pages/FamilyReportsPage";
import { ProviderDetailPage } from "./pages/ProviderDetailPage";
import { AdminAccessRequestsPage } from "./pages/AdminAccessRequestsPage";
import { AdminDashboardPage } from "./pages/AdminDashboardPage";
import { AdminUsersPage } from "./pages/AdminUsersPage";
import { AdminAuditLogPage, AdminMedicalCentersPage, AdminProviderApprovalsPage, AdminRolesPage, AdminSettingsPage } from "./pages/AdminModulePages";
import { RoleAccessPage } from "./pages/RoleAccessPage";
import { AICompanionPage } from "./pages/AICompanionPage";
import { ClinicianMessagesPage } from "./pages/ClinicianMessagesPage";
import { ClinicianSettingsPage } from "./pages/ClinicianSettingsPage";
import { useI18n } from "./i18n/useI18n";
import { FamilyMemberProvider } from "./familyMembers";
import { CurrentFamilyPatientProvider } from "./currentFamilyPatient";
import { FamilyAiPreferencesProvider } from "./familyAiPreferences";

function AppRoutes() {
  const { user, isClinician, isFamily, isAdmin, loading } = useAuth();
  const { t } = useI18n();

  if (loading) return <Spinner label={t("common.loading")} />;

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
          {isClinician && <Route path="/ai-companion" element={<AICompanionPage />} />}
          {isClinician && <Route path="/messages" element={<ClinicianMessagesPage />} />}
          {isClinician && <Route path="/settings" element={<ClinicianSettingsPage />} />}
          {isAdmin && (
            <Route path="/admin" element={<AdminDashboardPage />} />
          )}
          {isAdmin && <Route path="/admin/users" element={<AdminUsersPage />} />}
          {isAdmin && <Route path="/admin/users/:section" element={<AdminUsersPage />} />}
          {isAdmin && <Route path="/admin/provider-approvals" element={<AdminProviderApprovalsPage />} />}
          {isAdmin && <Route path="/admin/roles" element={<AdminRolesPage />} />}
          {isAdmin && <Route path="/admin/medical-centers" element={<AdminMedicalCentersPage />} />}
          {isAdmin && <Route path="/admin/audit-log" element={<AdminAuditLogPage />} />}
          {isAdmin && <Route path="/admin/settings" element={<AdminSettingsPage />} />}
          {isAdmin && (
            <Route
              path="/admin/access-requests"
              element={<AdminAccessRequestsPage />}
            />
          )}
          {/* A pure admin (no clinician role) lands on the Admin overview. */}
          {!isClinician && (
            <Route
              path="/"
              element={<Navigate to="/admin" replace />}
            />
          )}
          <Route
            path="*"
            element={
              <Navigate
                to={isClinician ? "/" : "/admin"}
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
          <Route path="/memories" element={<FamilyMemoriesPage />} />
          <Route path="/appointments" element={<FamilyAppointmentsPage />} />
          <Route path="/billing" element={<FamilyBillingPage />} />
          <Route
            path="/providers/:providerId"
            element={<ProviderDetailPage />}
          />
          <Route path="/messages" element={<FamilyMessagesPage />} />
          <Route path="/reports" element={<FamilyReportsPage />} />
          <Route path="/ai-companion" element={<AICompanionPage />} />
          <Route path="/settings" element={<FamilySettingsPage />} />
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
      <FamilyMemberProvider>
        <CurrentFamilyPatientProvider><FamilyAiPreferencesProvider><BrowserRouter><AppRoutes /></BrowserRouter></FamilyAiPreferencesProvider></CurrentFamilyPatientProvider>
      </FamilyMemberProvider>
    </AuthProvider>
  );
}
