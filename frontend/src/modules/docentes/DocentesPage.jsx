import { useQuery, gql } from "@apollo/client";
import { Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box } from "@mui/material";
import PageHeader from "../../design-system/components/PageHeader";

const GET_DOCENTES = gql`
  query { docentes { id nombre correo especialidad } }
`;

export default function DocentesPage() {
  const { data, loading, error } = useQuery(GET_DOCENTES);

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 02"
        title="Docentes"
        action={data && (
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.docentes.length} en planta
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
                <TableCell>Nombre</TableCell>
                <TableCell>Correo</TableCell>
                <TableCell>Especialidad</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.docentes.map((d) => (
                <TableRow key={d.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{d.nombre}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{d.correo}</TableCell>
                  <TableCell>{d.especialidad || "Sin especialidad"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}
    </Box>
  );
}
