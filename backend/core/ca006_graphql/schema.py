import strawberry
from strawberry.schema.config import StrawberryConfig
from strawberry.types import Info
from typing import Optional, List
from core.ca008_errores.graphql_errors import AcademicoSchema
from .types import (
    UsuarioType, DocenteType, EstudianteType,
    CursoType, InscripcionType, AuthPayload,
    EstudianteInput, DocenteInput, CursoInput, InscripcionInput,
)
from core.ca005_db.models import Estudiante, Docente, Curso, Inscripcion, Usuario
from core.ca001_auth.security import create_access_token, verify_password, verify_token
from core.ca009_auditoria.services import registrar_auditoria

def get_db_from_info(info: Info):
    return info.context["db"]

def get_usuario_actual(info: Info, *roles: str):
    # No existe middleware global de autenticacion para GraphQL (a diferencia
    # de REST, que usa requiere_rol de core.ca003_roles.dependencies); cada
    # query/mutation que necesita proteger acceso o saber "quien" actua
    # (para auditoria) llama a este helper, que valida el Authorization
    # header manualmente y opcionalmente exige uno de los roles indicados.
    request = info.context.get("request")
    auth_header = request.headers.get("authorization") if request else None
    if not auth_header or not auth_header.lower().startswith("bearer "):
        raise Exception("No autorizado")
    token = auth_header.split(" ", 1)[1]
    usuario = verify_token(token)
    if roles and usuario.rol not in roles:
        raise Exception("Permiso denegado")
    return usuario

@strawberry.type
class Query:
    @strawberry.field
    def estudiantes(self, info: Info, filtro: Optional[str] = None) -> List[EstudianteType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        q = db.query(Estudiante)
        if filtro: q = q.filter(Estudiante.nombre.ilike(f"%{filtro}%"))
        return q.all()

    @strawberry.field
    def docentes(self, info: Info, filtro: Optional[str] = None) -> List[DocenteType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        q = db.query(Docente)
        if filtro: q = q.filter(Docente.nombre.ilike(f"%{filtro}%"))
        return q.all()

    @strawberry.field
    def cursos(self, info: Info, filtro: Optional[str] = None) -> List[CursoType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        return db.query(Curso).all()

    @strawberry.field
    def inscripciones(self, info: Info, filtro: Optional[str] = None) -> List[InscripcionType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        return db.query(Inscripcion).all()

@strawberry.type
class Mutation:
    @strawberry.mutation
    def login(self, info: Info, correo: str, contrasena: str) -> AuthPayload:
        db = get_db_from_info(info)
        usuario = db.query(Usuario).filter(Usuario.correo == correo).first()
        if not usuario or not verify_password(contrasena, usuario.contrasena_hash):
            raise Exception("Credenciales invalidas")
        token = create_access_token(data={"sub": usuario.correo}, rol=usuario.rol)
        return AuthPayload(token=token, usuario=usuario)

    @strawberry.mutation
    def crear_estudiante(self, info: Info, datos: EstudianteInput) -> EstudianteType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        nuevo = Estudiante(**datos.__dict__)
        db.add(nuevo)
        db.commit()
        db.refresh(nuevo)
        registrar_auditoria(db, usuario=usuario.sub, recurso="estudiante", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "codigo": nuevo.codigo})
        return nuevo

    @strawberry.mutation
    def crear_curso(self, info: Info, datos: CursoInput) -> CursoType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        nuevo = Curso(**datos.__dict__)
        db.add(nuevo)
        db.commit()
        db.refresh(nuevo)
        registrar_auditoria(db, usuario=usuario.sub, recurso="curso", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "periodo_academico": nuevo.periodo_academico})
        return nuevo

    @strawberry.mutation
    def crear_inscripcion(self, info: Info, datos: InscripcionInput) -> InscripcionType:
        usuario = get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        nueva = Inscripcion(**datos.__dict__)
        db.add(nueva)
        db.commit()
        db.refresh(nueva)
        registrar_auditoria(db, usuario=usuario.sub, recurso="inscripcion", accion="crear", valores_nuevos={"estudiante_id": nueva.estudiante_id, "curso_id": nueva.curso_id, "estado": nueva.estado})
        return nueva

schema = AcademicoSchema(query=Query, mutation=Mutation, config=StrawberryConfig(auto_camel_case=False))
