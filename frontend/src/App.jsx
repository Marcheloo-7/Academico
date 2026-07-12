import { Routes, Route, Navigate } from "react-router-dom";
import LoginPage from "./auth/LoginPage";
import Layout from "./design-system/components/Layout";
import InicioPage from "./modules/inicio/InicioPage";
import EstudiantesPage from "./modules/estudiantes/EstudiantesPage";
import DocentesPage from "./modules/docentes/DocentesPage";
import CursosPage from "./modules/cursos/CursosPage";
import InscripcionesPage from "./modules/inscripciones/InscripcionesPage";
import { useAuth } from "./auth/AuthContext";

function Protected({ children }) {
  const { user, loading } = useAuth();
  if (loading) return null;
  return user ? children : <Navigate to="/login" />;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/" element={<Protected><Layout /></Protected>}>
        <Route index element={<InicioPage />} />
        <Route path="estudiantes" element={<EstudiantesPage />} />
        <Route path="docentes" element={<DocentesPage />} />
        <Route path="cursos" element={<CursosPage />} />
        <Route path="inscripciones" element={<InscripcionesPage />} />
      </Route>
    </Routes>
  );
}
