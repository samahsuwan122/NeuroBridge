import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider, useAuth } from "./auth/AuthContext";
import { Layout } from "./components/Layout";
import { FamilyLayout } from "./components/FamilyLayout";
import { Spinner } from "./components/ui";
import { LoginPage } from "./pages/LoginPage";
import { DashboardPage } from "./pages/DashboardPage";
import { PatientsPage } from "./pages/PatientsPage";
import { PatientDetailPage } from "./pages/PatientDetailPage";
import { FamilyDashboardPage } from "./pages/FamilyDashboardPage";
import { RoleAccessPage } from "./pages/RoleAccessPage";

function AppRoutes() {
  const { user, isClinician, isFamily, loading } = useAuth();

  if (loading) return <Spinner label="Restoring your session…" />;

  const supported = isClinician || isFamily;

  return (
    <Routes>
      <Route
        path="/login"
        element={supported ? <Navigate to="/" replace /> : <LoginPage />}
      />

      {isClinician ? (
        // Clinical portal (doctor / therapist) — unchanged. Clinicians always
        // land here, even if they also hold the family role.
        <Route element={<Layout />}>
          <Route path="/" element={<DashboardPage />} />
          <Route path="/patients" element={<PatientsPage />} />
          <Route path="/patients/:id" element={<PatientDetailPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Route>
      ) : isFamily ? (
        // Family / caregiver portal.
        <Route element={<FamilyLayout />}>
          <Route path="/" element={<FamilyDashboardPage />} />
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
