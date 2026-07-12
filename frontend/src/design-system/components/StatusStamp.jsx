import { Box } from "@mui/material";
import { academic } from "../../theme";

const ESTADOS = {
  activa: { label: "Activa", color: academic.sage },
  cerrada: { label: "Cerrada", color: academic.inkMuted },
  cupo_lleno: { label: "Cupo lleno", color: academic.rust },
};

// El elemento firma del sistema: un badge de estado con la forma de un
// sello de tinta -- doble borde, esquinas casi rectas, una leve
// inclinacion -- en vez del chip solido y plano de un dashboard tipico.
export default function StatusStamp({ estado }) {
  const info = ESTADOS[estado] || { label: estado, color: academic.inkMuted };
  return (
    <Box
      component="span"
      sx={{
        display: "inline-flex",
        alignItems: "center",
        fontFamily: '"IBM Plex Mono", monospace',
        fontSize: "0.7rem",
        fontWeight: 500,
        letterSpacing: "0.06em",
        textTransform: "uppercase",
        color: info.color,
        border: `1.5px solid ${info.color}`,
        borderRadius: "2px",
        padding: "3px 10px",
        transform: "rotate(-1.5deg)",
        boxShadow: `0 0 0 1px ${info.color}33 inset`,
      }}
    >
      {info.label}
    </Box>
  );
}
