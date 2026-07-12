import strawberry
from typing import Optional

@strawberry.type
class UsuarioType:
    id: int
    correo: str
    rol: str
    activo: bool

@strawberry.type
class DocenteType:
    id: int
    nombre: str
    correo: str
    especialidad: Optional[str] = None

@strawberry.type
class EstudianteType:
    id: int
    nombre: str
    codigo: str
    correo: str
    datos_contacto: Optional[str] = None

@strawberry.type
class CursoType:
    id: int
    nombre: str
    docente_id: int
    periodo_academico: str

@strawberry.type
class InscripcionType:
    id: int
    estudiante_id: int
    curso_id: int
    estado: str

@strawberry.type
class AuthPayload:
    token: str
    usuario: UsuarioType

@strawberry.input
class EstudianteInput:
    nombre: str
    codigo: str
    correo: str
    datos_contacto: Optional[str] = None

@strawberry.input
class DocenteInput:
    nombre: str
    correo: str
    especialidad: Optional[str] = None

@strawberry.input
class CursoInput:
    nombre: str
    docente_id: int
    periodo_academico: str

@strawberry.input
class InscripcionInput:
    estudiante_id: int
    curso_id: int
    estado: str = "activa"
