import { useQuery } from "@apollo/client";
import { GET_ESTUDIANTES } from "../../graphql/operations";
import { Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box } from "@mui/material";
import PageHeader from "../../design-system/components/PageHeader";

export default function EstudiantesPage() {
  const { data, loading, error } = useQuery(GET_ESTUDIANTES);

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 01"
        title="Estudiantes"
        action={data && (
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.estudiantes.length} matriculados
          </Typography>
        )}
      />

      {loading && <CircularProgress size={24} />}
      {error && <Typography color="error">Error: {error.message}</Typography>}

      {data && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell width={110}>Codigo</TableCell>
                <TableCell>Nombre</TableCell>
                <TableCell>Correo</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.estudiantes.map((e) => (
                <TableRow key={e.id} hover>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.85rem" }}>
                    {e.codigo}
                  </TableCell>
                  <TableCell sx={{ fontWeight: 500 }}>{e.nombre}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{e.correo}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}
    </Box>
  );
}
