export const ERROR_MESSAGES = {
  campoRequerido: "Este campo es obligatorio.",
  formatoEmailInvalido: "El formato del correo electronico no es valido.",
  longitudInvalida: "La longitud del campo no cumple con el rango permitido.",
  fechaInvalida: "La fecha ingresada no es valida.",
  cedulaInvalida: "El numero de cedula/matricula no es valido.",
  passwordDebil:
    "La contrasena debe tener al menos 8 caracteres, una mayuscula, una minuscula y un numero.",
};

const EMAIL_REGEX = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export function validateEmail(value) {
  return Boolean(value) && EMAIL_REGEX.test(value);
}

export function validateRequired(value) {
  return value !== null && value !== undefined && String(value).trim() !== "";
}

export function validateLength(value, min = 0, max = Infinity) {
  if (value === null || value === undefined) return false;
  const len = String(value).length;
  return len >= min && len <= max;
}

export function validateDateRange(value, min, max) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return false;
  if (min && date < new Date(min)) return false;
  if (max && date > new Date(max)) return false;
  return true;
}

export function validateCedula(value) {
  return Boolean(value) && /^\d{6,15}$/.test(value);
}

export function validatePasswordStrength(value) {
  if (!value || value.length < 8) return false;
  return /[A-Z]/.test(value) && /[a-z]/.test(value) && /\d/.test(value);
}
