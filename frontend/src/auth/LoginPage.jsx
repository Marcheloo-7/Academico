import { useState } from "react";
import { useMutation } from "@apollo/client";
import { useNavigate } from "react-router-dom";
import { Button, TextField, Box, Typography, Paper } from "@mui/material";
import { LOGIN_MUTATION } from "../graphql/operations";
import { useAuth } from "./AuthContext";
import { validateEmail, validateRequired, ERROR_MESSAGES } from "../utils/validation";
import { useErrorHandler } from "../errors/useErrorHandler";
import ErrorSnackbar from "../errors/ErrorSnackbar";
import { academic } from "../theme";

export default function LoginPage() {
  const [correo, setCorreo] = useState("");
  const [pass, setPass] = useState("");
  const [formError, setFormError] = useState("");
  const [loginMutation] = useMutation(LOGIN_MUTATION);
  const { login } = useAuth();
  const navigate = useNavigate();
  const { error, showError, clearError } = useErrorHandler();

  const handleLogin = async (e) => {
    e.preventDefault();
    setFormError("");
    if (!validateRequired(correo) || !validateEmail(correo)) {
      setFormError(ERROR_MESSAGES.formatoEmailInvalido);
      return;
    }
    if (!validateRequired(pass)) {
      setFormError(ERROR_MESSAGES.campoRequerido);
      return;
    }
    try {
      const { data } = await loginMutation({ variables: { correo, contrasena: pass } });
      login(data.login.token, data.login.usuario);
      navigate("/");
    } catch (err) { showError(err.message); }
  };

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        bgcolor: academic.ink,
        px: 2,
      }}
    >
      <Paper
        elevation={0}
        sx={{
          width: "100%",
          maxWidth: 420,
          p: 5,
          pt: 4.5,
          borderTop: `4px solid ${academic.gold}`,
          bgcolor: academic.paperElevated,
        }}
      >
        <Typography variant="overline" sx={{ color: academic.gold, fontWeight: 500, textAlign: "center", display: "block" }}>
          Acceso institucional
        </Typography>
        <Typography variant="h4" sx={{ mt: 0.5, mb: 0.5, textAlign: "center" }}>
          Iniciar sesion
        </Typography>
        <Typography variant="subtitle1" sx={{ mb: 4 }}>
          Ingresa tus credenciales para acceder al sistema.
        </Typography>

        <form onSubmit={handleLogin} noValidate>
          <Typography variant="caption" sx={{ color: academic.inkMuted, letterSpacing: "0.06em" }}>
            CORREO INSTITUCIONAL
          </Typography>
          <TextField
            fullWidth
            margin="dense"
            placeholder="nombre@academico.com"
            value={correo}
            onChange={(e) => setCorreo(e.target.value)}
            error={!!formError}
            sx={{ mb: 2.5 }}
          />
          <Typography variant="caption" sx={{ color: academic.inkMuted, letterSpacing: "0.06em" }}>
            CONTRASENA
          </Typography>
          <TextField
            fullWidth
            margin="dense"
            type="password"
            value={pass}
            onChange={(e) => setPass(e.target.value)}
            error={!!formError}
            helperText={formError}
          />
          <Button fullWidth variant="contained" type="submit" size="large" sx={{ mt: 3.5 }}>
            Entrar
          </Button>
        </form>
      </Paper>
      <ErrorSnackbar open={!!error} message={error} onClose={clearError} />
    </Box>
  );
}
