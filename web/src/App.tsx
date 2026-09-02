import {
  BrowserRouter,
  Navigate,
  Route,
  Routes,
} from "react-router-dom";

import {
  AuthProvider,
  useAuth,
} from "./auth/AuthContext";

import { Layout } from "./components/Layout";
import { FamilyLayout } from "./components/FamilyLayout";
import { Spinner } from "./components/ui";

import { LoginPage } from "./pages/LoginPage";
import { RegisterPage } from "./pages/RegisterPage";

import { DashboardPage } from "./pages/DashboardPage";
import { PatientsPage } from "./pages/PatientsPage";
import { PatientDetailPage } from "./pages/PatientDetailPage";
import { DoctorAppointmentsPage } from "./pages/DoctorAppointmentsPage";
import { ReportsPage } from "./pages/ReportsPage";
import { PatientReportPage } from "./pages/PatientReportPage";
import { ReviewQueuePage } from "./pages/ReviewQueuePage";
import { AICompanionPage } from "./pages/AICompanionPage";
import { ClinicianMessagesPage } from "./pages/ClinicianMessagesPage";
import { ClinicianSettingsPage } from "./pages/ClinicianSettingsPage";

import { FamilyDashboardPage } from "./pages/FamilyDashboardPage";
import { FamilyEncouragementPage } from "./pages/FamilyEncouragementPage";
import { FamilyMemoriesPage } from "./pages/FamilyMemoriesPage";
import { FamilySettingsPage } from "./pages/FamilySettingsPage";
import { FamilyAppointmentsPage } from "./pages/FamilyAppointmentsPage";
import { FamilyBillingPage } from "./pages/FamilyBillingPage";
import { FamilyMessagesPage } from "./pages/FamilyMessagesPage";
import { FamilyReportsPage } from "./pages/FamilyReportsPage";
import { ProviderDetailPage } from "./pages/ProviderDetailPage";

import { AdminDashboardPage } from "./pages/AdminDashboardPage";
import { AdminUsersPage } from "./pages/AdminUsersPage";
import { AdminAccessRequestsPage } from "./pages/AdminAccessRequestsPage";

/*
 * هذه الصفحات أصبحت ملفات مستقلة.
 */
import { AdminProviderApprovalsPage } from "./pages/AdminProviderApprovalsPage";
import { AdminAuditLogPage } from "./pages/AdminAuditLogPage";

/*
 * نأخذ فقط الأدوار والإعدادات من AdminModulePages.
 * تم حذف AdminMedicalCentersPage.
 */
import {
  AdminRolesPage,
  AdminSettingsPage,
} from "./pages/AdminModulePages";

import { RoleAccessPage } from "./pages/RoleAccessPage";

import { useI18n } from "./i18n/useI18n";

import { FamilyMemberProvider } from "./familyMembers";
import { CurrentFamilyPatientProvider } from "./currentFamilyPatient";
import { FamilyAiPreferencesProvider } from "./familyAiPreferences";

function AppRoutes() {
  const {
    user,
    isClinician,
    isFamily,
    isAdmin,
    loading,
  } = useAuth();

  const { t } = useI18n();

  if (loading) {
    return (
      <Spinner label={t("common.loading")} />
    );
  }

  const supported =
    isClinician || isFamily || isAdmin;

  return (
    <Routes>
      <Route
        path="/login"
        element={
          supported
            ? <Navigate to="/" replace />
            : <LoginPage />
        }
      />

      <Route
        path="/register"
        element={
          supported
            ? <Navigate to="/" replace />
            : <RegisterPage />
        }
      />

      {isClinician || isAdmin ? (
        <Route element={<Layout />}>
          {/* صفحات الطبيب والمعالج */}

          {isClinician && (
            <Route
              path="/"
              element={<DashboardPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/patients"
              element={<PatientsPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/patients/:id"
              element={<PatientDetailPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/appointments"
              element={<DoctorAppointmentsPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/reports"
              element={<ReportsPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/reports/:patientId"
              element={<PatientReportPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/review-queue"
              element={<ReviewQueuePage />}
            />
          )}

          {isClinician && (
            <Route
              path="/ai-companion"
              element={<AICompanionPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/messages"
              element={<ClinicianMessagesPage />}
            />
          )}

          {isClinician && (
            <Route
              path="/settings"
              element={<ClinicianSettingsPage />}
            />
          )}

          {/* صفحات الأدمن */}

          {isAdmin && (
            <Route
              path="/admin"
              element={<AdminDashboardPage />}
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/users"
              element={<AdminUsersPage />}
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/users/:section"
              element={<AdminUsersPage />}
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/provider-approvals"
              element={
                <AdminProviderApprovalsPage />
              }
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/access-requests"
              element={
                <AdminAccessRequestsPage />
              }
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/roles"
              element={<AdminRolesPage />}
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/audit-log"
              element={<AdminAuditLogPage />}
            />
          )}

          {isAdmin && (
            <Route
              path="/admin/settings"
              element={<AdminSettingsPage />}
            />
          )}

          {/*
            لا يوجد مسار:
            /admin/medical-centers
          */}

          {!isClinician && isAdmin && (
            <Route
              path="/"
              element={
                <Navigate
                  to="/admin"
                  replace
                />
              }
            />
          )}

          <Route
            path="*"
            element={
              <Navigate
                to={
                  isClinician
                    ? "/"
                    : "/admin"
                }
                replace
              />
            }
          />
        </Route>
      ) : isFamily ? (
        <Route element={<FamilyLayout />}>
          <Route
            path="/"
            element={<FamilyDashboardPage />}
          />

          <Route
            path="/encouragement"
            element={<FamilyEncouragementPage />}
          />

          <Route
            path="/memories"
            element={<FamilyMemoriesPage />}
          />

          <Route
            path="/appointments"
            element={<FamilyAppointmentsPage />}
          />

          <Route
            path="/billing"
            element={<FamilyBillingPage />}
          />

          <Route
            path="/providers/:providerId"
            element={<ProviderDetailPage />}
          />

          <Route
            path="/messages"
            element={<FamilyMessagesPage />}
          />

          <Route
            path="/reports"
            element={<FamilyReportsPage />}
          />

          <Route
            path="/ai-companion"
            element={<AICompanionPage />}
          />

          <Route
            path="/settings"
            element={<FamilySettingsPage />}
          />

          <Route
            path="*"
            element={
              <Navigate to="/" replace />
            }
          />
        </Route>
      ) : user ? (
        <Route
          path="*"
          element={<RoleAccessPage />}
        />
      ) : (
        <Route
          path="*"
          element={
            <Navigate
              to="/login"
              replace
            />
          }
        />
      )}
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <FamilyMemberProvider>
        <CurrentFamilyPatientProvider>
          <FamilyAiPreferencesProvider>
            <BrowserRouter>
              <AppRoutes />
            </BrowserRouter>
          </FamilyAiPreferencesProvider>
        </CurrentFamilyPatientProvider>
      </FamilyMemberProvider>
    </AuthProvider>
  );
}