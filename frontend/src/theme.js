import { createTheme } from "@mui/material/styles";

// Sistema de Gestion Academica -- direccion "Acta Academica":
// la identidad visual del libro de actas y la cedula institucional,
// no la de un dashboard SaaS generico. Paleta fria de papel de archivo,
// tinta azul-marino, un oro institucional como unico acento vivo, y un
// rojo-oxido reservado exclusivamente para estados negativos.
const ink = "#141B2E";
const inkMuted = "#565F55";
const paper = "#EEF0EA";
const paperElevated = "#F8F9F4";
const gold = "#B8872B";
const goldDark = "#8E6A20";
const sage = "#4F6B4A";
const rust = "#9C4632";
const line = "#D2D5C7";

export const academic = { ink, inkMuted, paper, paperElevated, gold, goldDark, sage, rust, line };

export const theme = createTheme({
  palette: {
    mode: "light",
    primary: { main: gold, dark: goldDark, contrastText: ink },
    secondary: { main: ink, contrastText: paperElevated },
    success: { main: sage },
    error: { main: rust },
    background: { default: paper, paper: paperElevated },
    text: { primary: ink, secondary: inkMuted },
    divider: line,
  },
  shape: { borderRadius: 3 },
  typography: {
    fontFamily: '"IBM Plex Sans", "Helvetica Neue", Arial, sans-serif',
    h1: { fontFamily: '"Fraunces", serif', fontWeight: 600 },
    h2: { fontFamily: '"Fraunces", serif', fontWeight: 600 },
    h3: { fontFamily: '"Fraunces", serif', fontWeight: 600, letterSpacing: "-0.01em" },
    h4: { fontFamily: '"Fraunces", serif', fontWeight: 600, letterSpacing: "-0.01em" },
    h5: { fontFamily: '"Fraunces", serif', fontWeight: 500, fontStyle: "italic" },
    h6: { fontFamily: '"Fraunces", serif', fontWeight: 500 },
    subtitle1: { fontFamily: '"IBM Plex Sans", sans-serif', color: inkMuted },
    subtitle2: { fontFamily: '"IBM Plex Sans", sans-serif', color: inkMuted, fontWeight: 500 },
    button: { fontFamily: '"IBM Plex Sans", sans-serif', fontWeight: 600, letterSpacing: "0.05em" },
    overline: { fontFamily: '"IBM Plex Mono", monospace', letterSpacing: "0.08em" },
    caption: { fontFamily: '"IBM Plex Mono", monospace' },
  },
  components: {
    MuiCssBaseline: {
      styleOverrides: {
        body: { backgroundColor: paper },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: ink,
          color: paperElevated,
          boxShadow: "none",
          borderBottom: `2px solid ${gold}`,
        },
      },
    },
    MuiDrawer: {
      styleOverrides: {
        paper: {
          backgroundColor: paperElevated,
          borderRight: `1px solid ${line}`,
          boxShadow: "none",
        },
      },
    },
    MuiListItemButton: {
      styleOverrides: {
        root: {
          borderRadius: 0,
          borderLeft: "3px solid transparent",
          paddingTop: 10,
          paddingBottom: 10,
          "&:hover": { backgroundColor: "rgba(20,27,46,0.04)" },
          "&.Mui-selected": {
            borderLeft: `3px solid ${gold}`,
            backgroundColor: "rgba(184,135,43,0.08)",
          },
          "&.Mui-selected:hover": { backgroundColor: "rgba(184,135,43,0.12)" },
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 3,
          boxShadow: "none",
          textTransform: "uppercase",
          paddingTop: 10,
          paddingBottom: 10,
        },
        contained: {
          boxShadow: "none",
          "&:hover": { boxShadow: "none" },
        },
        outlined: { borderWidth: 1.5, "&:hover": { borderWidth: 1.5 } },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: { backgroundImage: "none" },
        outlined: { borderColor: line },
        elevation1: { boxShadow: "none", border: `1px solid ${line}` },
      },
    },
    MuiTableCell: {
      styleOverrides: {
        root: { borderBottom: `1px solid ${line}`, padding: "14px 16px" },
        head: {
          fontFamily: '"IBM Plex Mono", monospace',
          fontSize: "0.72rem",
          letterSpacing: "0.07em",
          textTransform: "uppercase",
          color: inkMuted,
          borderBottom: `2px solid ${ink}`,
        },
      },
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: 3,
          "& fieldset": { borderColor: line },
          "&:hover fieldset": { borderColor: inkMuted },
          "&.Mui-focused fieldset": { borderColor: gold, borderWidth: 1.5 },
        },
      },
    },
  },
});
