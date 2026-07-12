from typing import Optional
from sqlalchemy.orm import Session
from .schemas import UsuarioCreate, EstudianteCreate, DocenteCreate
from core.ca005_db.models import Usuario, Estudiante, Docente
from core.ca001_auth.security import get_password_hash

def crear_usuario(db: Session, datos: UsuarioCreate):
    nuevo_usuario = Usuario(
        correo=datos.correo,
        contrasena_hash=get_password_hash(datos.contrasena),
        rol=datos.rol
    )
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario

def listar_usuarios(db: Session):
    return db.query(Usuario).all()

def crear_estudiante(db: Session, datos: EstudianteCreate):
    nuevo = Estudiante(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

def listar_estudiantes(db: Session, filtro: Optional[str] = None):
    query = db.query(Estudiante)
    if filtro:
        query = query.filter(Estudiante.nombre.ilike(f"%{filtro}%"))
    return query.all()

def crear_docente(db: Session, datos: DocenteCreate):
    nuevo = Docente(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

def listar_docentes(db: Session, filtro: Optional[str] = None):
    query = db.query(Docente)
    if filtro:
        query = query.filter(Docente.nombre.ilike(f"%{filtro}%"))
    return query.all()
