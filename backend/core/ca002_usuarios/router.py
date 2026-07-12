from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from . import schemas, services
from core.ca005_db.session import get_db
from core.ca003_roles.dependencies import requiere_rol
from core.ca009_auditoria.services import registrar_auditoria

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])

@router.get("/", response_model=List[schemas.UsuarioResponse])
def listar_usuarios(db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    return services.listar_usuarios(db)

@router.post("/", response_model=schemas.UsuarioResponse)
def crear_usuario(datos: schemas.UsuarioCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    nuevo = services.crear_usuario(db, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="usuario", accion="crear", valores_nuevos={"correo": nuevo.correo, "rol": nuevo.rol})
    return nuevo

@router.get("/estudiantes", response_model=List[schemas.EstudianteResponse])
def listar_estudiantes(filtro: str = None, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador", "docente"))):
    return services.listar_estudiantes(db, filtro)

@router.post("/estudiantes", response_model=schemas.EstudianteResponse)
def crear_estudiante(datos: schemas.EstudianteCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    nuevo = services.crear_estudiante(db, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="estudiante", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "codigo": nuevo.codigo})
    return nuevo

@router.get("/docentes", response_model=List[schemas.DocenteResponse])
def listar_docentes(filtro: str = None, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador", "docente"))):
    return services.listar_docentes(db, filtro)

@router.post("/docentes", response_model=schemas.DocenteResponse)
def crear_docente(datos: schemas.DocenteCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    nuevo = services.crear_docente(db, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="docente", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "correo": nuevo.correo})
    return nuevo
