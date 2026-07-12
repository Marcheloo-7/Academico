import { Box, Typography } from "@mui/material";
import { academic } from "../../theme";

// Encabezado de seccion con el tratamiento de "libro de actas": un
// eyebrow en mono, el titulo en Fraunces, y una doble regla debajo
// (una fina y una gruesa) como en el encabezado de una hoja de registro.
export default function PageHeader({ eyebrow, title, action }) {
  return (
    <Box sx={{ mb: 4 }}>
      <Box sx={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", flexWrap: "wrap", gap: 2 }}>
        <Box>
          {eyebrow && (
            <Typography
              variant="overline"
              sx={{ color: academic.gold, display: "block", mb: 0.5, fontWeight: 500 }}
            >
              {eyebrow}
            </Typography>
          )}
          <Typography variant="h4">{title}</Typography>
        </Box>
        {action}
      </Box>
      <Box sx={{ mt: 1.5, height: 3, borderTop: `1px solid ${academic.line}`, borderBottom: `2px solid ${academic.ink}` }} />
    </Box>
  );
}
