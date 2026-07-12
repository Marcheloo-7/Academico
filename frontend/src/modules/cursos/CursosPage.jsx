import { useQuery, gql } from "@apollo/client";
import { Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box } from "@mui/material";
import PageHeader from "../../design-system/components/PageHeader";

const GET_CURSOS = gql`
  query { cursos { id nombre periodo_academico } }
`;

export default function CursosPage() {
  const { data, loading, error } = useQuery(GET_CURSOS);

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 03"
        title="Cursos"
        action={data && (
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.cursos.length} activos
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
                <TableCell>Curso</TableCell>
                <TableCell width={160}>Periodo</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.cursos.map((c) => (
                <TableRow key={c.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{c.nombre}</TableCell>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.85rem", color: "text.secondary" }}>
                    {c.periodo_academico}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}
    </Box>
  );
}
