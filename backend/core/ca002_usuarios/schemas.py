from typing import Optional
from pydantic import BaseModel

class UsuarioCreate(BaseModel):
    correo: str
    contrasena: str
    rol: str

class UsuarioResponse(BaseModel):
    id: int
    correo: str
    rol: str
    activo: bool
    class Config:
        from_attributes = True

class EstudianteCreate(BaseModel):
    nombre: str
    codigo: str
    correo: str
    datos_contacto: Optional[str] = None

class EstudianteResponse(EstudianteCreate):
    id: int
    class Config:
        from_attributes = True

class DocenteCreate(BaseModel):
    nombre: str
    correo: str
    especialidad: Optional[str] = None
    usuario_id: Optional[int] = None

class DocenteResponse(DocenteCreate):
    id: int
    class Config:
        from_attributes = True
