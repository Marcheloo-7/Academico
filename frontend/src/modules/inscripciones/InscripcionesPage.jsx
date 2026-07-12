import { useQuery, gql } from "@apollo/client";
import { Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box } from "@mui/material";
import PageHeader from "../../design-system/components/PageHeader";
import StatusStamp from "../../design-system/components/StatusStamp";

const GET_INSC = gql`
  query { inscripciones { id estado } }
`;

export default function InscripcionesPage() {
  const { data, loading, error } = useQuery(GET_INSC);

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 04"
        title="Inscripciones"
        action={data && (
          <Typography variant="caption" sx={{ color: "text.secondary" }}>
            {data.inscripciones.length} movimientos
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
                <TableCell width={140}>Numero</TableCell>
                <TableCell>Estado</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {data.inscripciones.map((i) => (
                <TableRow key={i.id} hover>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.85rem" }}>
                    #{String(i.id).padStart(4, "0")}
                  </TableCell>
                  <TableCell>
                    <StatusStamp estado={i.estado} />
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
