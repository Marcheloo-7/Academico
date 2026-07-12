import { useState } from "react";

// rules: { [campo]: (valor) => mensajeDeError | null }
export function useFormValidation(initialValues, rules) {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState({});

  const handleChange = (campo) => (e) => {
    setValues((prev) => ({ ...prev, [campo]: e.target.value }));
  };

  const validateAll = () => {
    const nuevosErrores = {};
    Object.keys(rules).forEach((campo) => {
      const mensaje = rules[campo](values[campo]);
      if (mensaje) nuevosErrores[campo] = mensaje;
    });
    setErrors(nuevosErrores);
    return Object.keys(nuevosErrores).length === 0;
  };

  return { values, errors, handleChange, validateAll };
}
