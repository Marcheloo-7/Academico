PERMISOS = {
    "administrador": ["*"],
    "docente": ["leer_estudiantes", "leer_cursos", "actualizar_cursos", "leer_inscripciones"]
}

def verificar_permiso(rol: str, accion: str) -> bool:
    if rol not in PERMISOS: return False
    if "*" in PERMISOS[rol]: return True
    return accion in PERMISOS[rol]
