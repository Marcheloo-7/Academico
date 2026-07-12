import { gql } from "@apollo/client";

export const LOGIN_MUTATION = gql`
  mutation Login($correo: String!, $contrasena: String!) {
    login(correo: $correo, contrasena: $contrasena) {
      token
      usuario { id correo rol }
    }
  }
`;

export const GET_ESTUDIANTES = gql`
  query GetEstudiantes { estudiantes { id nombre codigo correo } }
`;
