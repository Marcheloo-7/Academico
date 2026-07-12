import { Box, Drawer, List, ListItem, ListItemButton, ListItemText, AppBar, Toolbar, Typography, Button } from "@mui/material";
import { useNavigate, useLocation, Outlet } from "react-router-dom";
import { useAuth } from "../../auth/AuthContext";
import { academic } from "../../theme";

const DRAWER_WIDTH = 248;

export default function Layout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();
  if (!user) return <Outlet />;

  const menu = [
    { index: "01", text: "Estudiantes", path: "/estudiantes" },
    { index: "02", text: "Docentes", path: "/docentes" },
    { index: "03", text: "Cursos", path: "/cursos" },
    { index: "04", text: "Inscripciones", path: "/inscripciones" },
  ];

  return (
    <Box sx={{ display: "flex" }}>
      <AppBar position="fixed" sx={{ zIndex: 1201 }}>
        <Toolbar sx={{ gap: 2 }}>
          <Typography variant="h6" sx={{ flexGrow: 1, letterSpacing: "0.02em" }}>
            SGA <Box component="span" sx={{ color: academic.gold }}>·</Box> Sistema de Gestion Academica
          </Typography>
          <Typography
            sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.8rem", opacity: 0.85 }}
          >
            {user.correo}
          </Typography>
          <Button
            size="small"
            variant="outlined"
            onClick={() => { logout(); navigate("/login"); }}
            sx={{ color: academic.paperElevated, borderColor: "rgba(248,249,244,0.4)", "&:hover": { borderColor: academic.gold } }}
          >
            Salir
          </Button>
        </Toolbar>
      </AppBar>
      <Drawer
        variant="permanent"
        sx={{ width: DRAWER_WIDTH, flexShrink: 0, [`& .MuiDrawer-paper`]: { width: DRAWER_WIDTH, boxSizing: "border-box" } }}
      >
        <Toolbar />
        <Typography
          variant="overline"
          sx={{ px: 2.5, pt: 2.5, pb: 1, display: "block", color: academic.inkMuted }}
        >
          Indice
        </Typography>
        <List sx={{ px: 0 }}>
          {menu.map((m) => {
            const selected = location.pathname.startsWith(m.path);
            return (
              <ListItem key={m.text} disablePadding>
                <ListItemButton selected={selected} onClick={() => navigate(m.path)} sx={{ px: 2.5 }}>
                  <Typography
                    sx={{
                      fontFamily: '"IBM Plex Mono", monospace',
                      fontSize: "0.75rem",
                      color: selected ? academic.gold : academic.inkMuted,
                      mr: 1.5,
                      minWidth: 20,
                    }}
                  >
                    {m.index}
                  </Typography>
                  <ListItemText
                    primary={m.text}
                    primaryTypographyProps={{ fontWeight: selected ? 600 : 400 }}
                  />
                </ListItemButton>
              </ListItem>
            );
          })}
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 4, bgcolor: "background.default", minHeight: "100vh" }}>
        <Toolbar />
        <Outlet />
      </Box>
    </Box>
  );
}
