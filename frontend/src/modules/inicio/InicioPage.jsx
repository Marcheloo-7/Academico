import { Box, Typography, Paper } from "@mui/material";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../auth/AuthContext";
import { academic } from "../../theme";

const SECCIONES = [
  { index: "01", text: "Estudiantes", path: "/estudiantes", desc: "Matricula y datos de contacto" },
  { index: "02", text: "Docentes", path: "/docentes", desc: "Planta docente y especialidades" },
  { index: "03", text: "Cursos", path: "/cursos", desc: "Oferta academica por periodo" },
  { index: "04", text: "Inscripciones", path: "/inscripciones", desc: "Movimientos de matricula" },
];

export default function InicioPage() {
  const { user } = useAuth();
  const navigate = useNavigate();

  return (
    <Box>
      <Typography variant="overline" sx={{ color: academic.gold, fontWeight: 500 }}>
        Panel principal
      </Typography>
      <Typography variant="h3" sx={{ mt: 0.5 }}>
        Bienvenido
      </Typography>
      <Typography variant="subtitle1" sx={{ mt: 0.5, mb: 4 }}>
        Sesion iniciada como <strong>{user?.correo}</strong> &middot; rol {user?.rol}
      </Typography>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "1fr 1fr" }, gap: 2 }}>
        {SECCIONES.map((s) => (
          <Paper
            key={s.path}
            variant="outlined"
            onClick={() => navigate(s.path)}
            sx={{
              p: 2.5,
              cursor: "pointer",
              transition: "border-color 0.15s ease",
              "&:hover": { borderColor: academic.gold },
            }}
          >
            <Typography
              sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.75rem", color: academic.gold }}
            >
              {s.index}
            </Typography>
            <Typography variant="h6" sx={{ mt: 0.5 }}>{s.text}</Typography>
            <Typography variant="body2" sx={{ color: "text.secondary", mt: 0.25 }}>
              {s.desc}
            </Typography>
          </Paper>
        ))}
      </Box>
    </Box>
  );
}
