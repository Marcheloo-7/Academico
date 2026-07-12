import { useState } from "react";

export function useErrorHandler() {
  const [error, setError] = useState("");

  const showError = (message) => setError(message);
  const clearError = () => setError("");

  return { error, showError, clearError };
}
