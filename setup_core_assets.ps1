# ===========================================================================
#  setup_core_assets.ps1
#  Sistema de GestiÃ³n AcadÃ©mica â€” LÃ­nea de Productos de Software
#  Script Ãºnico de preparaciÃ³n de los 6 Core Assets reutilizables.
#
#  Ejecutar con:  powershell -ExecutionPolicy Bypass -File .\setup_core_assets.ps1
#  Requisitos previos: Python 3.10+, Node.js 18+, npm 9+, pip actualizado.
# ===========================================================================

# Configurar codificaciÃ³n UTF-8 para mostrar caracteres especiales correctamente
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Detener ante cualquier error
$ErrorActionPreference = "Stop"

# Directorio raÃ­z del proyecto (donde reside este script)
$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$BACKEND_DIR = Join-Path $PROJECT_ROOT "backend"
$FRONTEND_DIR = Join-Path $PROJECT_ROOT "frontend"

# Crear estructura base de directorios del proyecto
New-Item -ItemType Directory -Force -Path $BACKEND_DIR | Out-Null
New-Item -ItemType Directory -Force -Path $FRONTEND_DIR | Out-Null


# ===========================================================================
# CA-005 â€” ConfiguraciÃ³n de Base de Datos
# InstalaciÃ³n de dependencias de PostgreSQL, SQLAlchemy y variables de entorno.
# No se ejecutan migraciones ni se crean tablas.
# ===========================================================================

Write-Host "===== CA-005: Configuracion de Base de Datos =====" -ForegroundColor Cyan

# Instalar cliente PostgreSQL, ORM SQLAlchemy con soporte async, y python-dotenv
# - sqlalchemy: ORM principal del proyecto
# - psycopg2-binary: driver sincrono de PostgreSQL (binario para evitar compilacion)
# - asyncpg: driver asincrono de PostgreSQL, recomendado para FastAPI async
# - python-dotenv: carga de variables de entorno desde archivo .env
pip install --quiet sqlalchemy psycopg2-binary asyncpg python-dotenv

# Crear archivo .env con placeholders de conexiÃ³n a la base de datos.
# El desarrollador debe reemplazar los valores entre <> con datos reales.
$envFilePath = Join-Path $BACKEND_DIR ".env"
$envContent = @"
# ============================================
# CA-005 â€” Variables de conexion a PostgreSQL
# ============================================
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=academico_db
DATABASE_URL=postgresql+psycopg2://postgres:postgres@localhost:5432/academico_db
"@
Set-Content -Path $envFilePath -Value $envContent -Encoding UTF8

Write-Host "  [OK] Dependencias de BD instaladas y .env creado en backend/" -ForegroundColor Green


# ===========================================================================
# CA-004 â€” Sistema de DiseÃ±o
# Scaffolding del proyecto React con Vite y librerÃ­as de UI.
# ===========================================================================

Write-Host "===== CA-004: Sistema de Diseno =====" -ForegroundColor Cyan

# Scaffolding del frontend con Vite + React (template de JavaScript).
# Se usa Vite en lugar de Create React App por su velocidad de arranque,
# soporte nativo de HMR y mejor rendimiento en desarrollo.
# El flag --template react selecciona la plantilla de React con JavaScript.
# Se ejecuta con Push-Location + "." (ruta relativa) en vez de pasar la ruta
# absoluta con backslashes: si el proceso npx/npm delega en un shell tipo
# bash (p.ej. al lanzar el script desde Git Bash), los backslashes se
# interpretan como escapes y corrompen el nombre de la carpeta destino.
Push-Location $FRONTEND_DIR
npx -y create-vite@latest . -- --template react

# Instalar dependencias base del proyecto React reciÃ©n creado
npm install --yes

# Instalar MUI (Material UI) como librerÃ­a de componentes del sistema de diseÃ±o.
# JustificaciÃ³n: MUI ofrece un catÃ¡logo completo de componentes accesibles,
# sistema de theming con tokens de diseÃ±o (spacing, palette, typography),
# y es el estÃ¡ndar de facto para proyectos React empresariales.
# - @mui/material: componentes principales
# - @mui/icons-material: iconografÃ­a consistente
# - @emotion/react y @emotion/styled: motor de estilos requerido por MUI 5+
npm install --save @mui/material @mui/icons-material @emotion/react @emotion/styled

# Instalar @mui/system para utilidades de theming y tokens de diseÃ±o (sx prop,
# creaciÃ³n de themes personalizados, breakpoints, paleta de colores).
npm install --save @mui/system

Pop-Location

Write-Host "  [OK] Proyecto React (Vite) creado y librerias de diseno (MUI) instaladas" -ForegroundColor Green


# ===========================================================================
# CA-001 â€” AutenticaciÃ³n y AutorizaciÃ³n
# Dependencias de JWT, hashing de contraseÃ±as y seguridad en FastAPI.
# ===========================================================================

Write-Host "===== CA-001: Autenticacion y Autorizacion =====" -ForegroundColor Cyan

# Instalar dependencias de autenticaciÃ³n:
# - fastapi: framework web async (incluye OAuth2PasswordBearer nativo)
# - uvicorn[standard]: servidor ASGI para levantar FastAPI
# - python-jose[cryptography]: generaciÃ³n y verificaciÃ³n de tokens JWT
#   (recomendada por la documentaciÃ³n oficial de FastAPI sobre seguridad)
# - passlib[bcrypt]: hashing seguro de contraseÃ±as con bcrypt
# - python-multipart: necesario para OAuth2PasswordRequestForm (form-data)
pip install --quiet fastapi "uvicorn[standard]" "python-jose[cryptography]" passlib bcrypt==3.2.0 python-multipart

# Agregar variables de entorno de JWT al archivo .env existente
$envAuthContent = @"

# ============================================
# CA-001 â€” Variables de Autenticacion JWT
# ============================================
JWT_SECRET_KEY=<cambia_esta_clave_secreta_por_una_segura>
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
"@
Add-Content -Path $envFilePath -Value $envAuthContent -Encoding UTF8

Write-Host "  [OK] Dependencias de autenticacion instaladas y variables JWT anadidas al .env" -ForegroundColor Green


# ===========================================================================
# CA-003 â€” GestiÃ³n de Roles y Permisos
# Configurador interactivo de roles RBAC del producto.
# No requiere librerÃ­as adicionales mÃ¡s allÃ¡ de las instaladas en CA-001
# (la lÃ³gica de roles se implementa con dependencias nativas de FastAPI).
# ===========================================================================

Write-Host ""
Write-Host "===== CA-003: Gestion de Roles y Permisos =====" -ForegroundColor Cyan
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€"
Write-Host "  Configurador de roles del producto."
Write-Host "  Seleccione que roles de usuario incluir."
Write-Host "â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€"

# Encabezado de la secciÃ³n de roles en el .env
$envRolesHeader = @"

# ============================================
# CA-003 â€” Roles del Sistema (RBAC)
# ============================================
"@
Add-Content -Path $envFilePath -Value $envRolesHeader -Encoding UTF8

# FunciÃ³n auxiliar para preguntas interactivas s/n
function Ask-YesNo {
    param([string]$Prompt)
    while ($true) {
        $resp = Read-Host $Prompt
        switch ($resp.ToLower()) {
            "s" { return $true }
            "n" { return $false }
            default { Write-Host "  [!] Respuesta no valida. Ingrese 's' o 'n'." -ForegroundColor Yellow }
        }
    }
}

# --- Rol: Administrador ---
if (Ask-YesNo "  Desea incluir el rol Administrador? (s/n)") {
    Add-Content -Path $envFilePath -Value "ROLE_ADMIN=administrador" -Encoding UTF8
    Write-Host "  [OK] Rol 'administrador' agregado al producto" -ForegroundColor Green
}
else {
    Write-Host "  [X] Rol 'administrador' omitido" -ForegroundColor DarkGray
}

# --- Rol: Docente ---
if (Ask-YesNo "  Desea incluir el rol Docente? (s/n)") {
    Add-Content -Path $envFilePath -Value "ROLE_DOCENTE=docente" -Encoding UTF8
    Write-Host "  [OK] Rol 'docente' agregado al producto" -ForegroundColor Green
}
else {
    Write-Host "  [X] Rol 'docente' omitido" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  [OK] Configuracion de roles completada" -ForegroundColor Green


# ===========================================================================
# CA-002 â€” GestiÃ³n de Usuarios (mÃ³dulos funcionales del producto)
# Instala dependencias necesarias para los datos de usuario.
# Los 4 modulos (Estudiante, Docente, Cursos, Inscripciones) se generan
# siempre como parte fija del esqueleto en New-ProjectSkeleton
# (backend/core/ca002_usuarios/) — no existe un flag de inclusion opcional,
# asi que aqui ya no se pregunta ni se crean carpetas placeholder sueltas
# que ningun otro archivo del proyecto termina usando.
# ===========================================================================

Write-Host ""
Write-Host "===== CA-002: Gestion de Usuarios =====" -ForegroundColor Cyan

# Instalar email-validator (necesario para EmailStr en Pydantic si se
# incluye cualquier mÃ³dulo con datos de usuario).
pip install --quiet email-validator

Write-Host "  [OK] Dependencias de gestion de usuarios instaladas" -ForegroundColor Green


# ===========================================================================
# CA-006 â€” Esquema GraphQL Base
# LibrerÃ­a GraphQL para FastAPI (backend) y Apollo Client (frontend).
# Comandos de arranque de servidores de desarrollo.
# ===========================================================================

Write-Host "===== CA-006: Esquema GraphQL Base =====" -ForegroundColor Cyan

# Instalar Strawberry GraphQL con integraciÃ³n FastAPI.
# JustificaciÃ³n: Strawberry usa un enfoque code-first con dataclasses de Python
# y tipado nativo, lo que se integra naturalmente con Pydantic y FastAPI.
# Es la librerÃ­a GraphQL recomendada por la documentaciÃ³n oficial de FastAPI.
pip install --quiet "strawberry-graphql[fastapi]"

# Instalar Apollo Client y la librerÃ­a core de GraphQL en el frontend React.
# - @apollo/client: cliente GraphQL con cachÃ©, hooks (useQuery, useMutation)
#   y gestiÃ³n de estado integrada para React.
# - graphql: implementaciÃ³n de referencia de GraphQL para JavaScript,
#   requerida como peer dependency de @apollo/client.
Push-Location $FRONTEND_DIR
npm install --save @apollo/client@3 graphql
Pop-Location

Write-Host "  [OK] Strawberry GraphQL (backend) y Apollo Client (frontend) instalados" -ForegroundColor Green

# -------------------------------------------------------------------
# Comandos de arranque de servidores de desarrollo
# Ejecutar cada uno en una terminal separada una vez que todos los
# Core Assets estÃ©n configurados y el cÃ³digo fuente implementado.
# -------------------------------------------------------------------

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  Todos los Core Assets han sido configurados."              -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Para arrancar los servidores de desarrollo:"
Write-Host ""
Write-Host "  Backend (FastAPI + Strawberry GraphQL):" -ForegroundColor Yellow
Write-Host "    cd backend; uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
Write-Host ""
Write-Host "  Frontend (React + Vite + Apollo Client):" -ForegroundColor Yellow
Write-Host "    cd frontend; npm run dev"
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green

# --- Fin del bloque de instalacion de Core Assets ---

# ===========================================================================
#  New-ProjectSkeleton
#  Genera la estructura de carpetas y el codigo base (esqueleto) del backend
#  y frontend del producto LPS academico.
#  Se invoca automaticamente al final del script de setup.
# ===========================================================================

function New-ProjectSkeleton {

    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "  Generando estructura de carpetas y codigo base del proyecto"  -ForegroundColor Cyan
    Write-Host "==============================================================" -ForegroundColor Cyan

    $createdFiles = [System.Collections.ArrayList]::new()
    $skippedFiles = [System.Collections.ArrayList]::new()

    function Write-SkeletonFile {
        param([string]$FilePath, [string]$Content)
        if (Test-Path $FilePath) {
            [void]$skippedFiles.Add($FilePath)
            Write-Host "  [OMITIDO] Ya existe: $FilePath" -ForegroundColor Yellow
        }
        else {
            $parentDir = Split-Path -Parent $FilePath
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
            }
            Set-Content -Path $FilePath -Value $Content -Encoding utf8
            [void]$createdFiles.Add($FilePath)
            Write-Host "  [CREADO]  $FilePath" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "--- Instalando dependencias adicionales del frontend ---" -ForegroundColor Cyan
    Push-Location $FRONTEND_DIR
    npm install react-router-dom @apollo/client@3 graphql
    Pop-Location

    Write-Host ""
    Write-Host "--- Creando directorios ---" -ForegroundColor Cyan

    $directories = @(
        (Join-Path $BACKEND_DIR "core\ca001_auth"),
        (Join-Path $BACKEND_DIR "core\ca002_usuarios"),
        (Join-Path $BACKEND_DIR "core\ca003_roles"),
        (Join-Path $BACKEND_DIR "core\ca005_db"),
        (Join-Path $BACKEND_DIR "core\ca006_graphql"),
        (Join-Path $FRONTEND_DIR "src\design-system\components"),
        (Join-Path $FRONTEND_DIR "src\modules\estudiantes"),
        (Join-Path $FRONTEND_DIR "src\modules\docentes"),
        (Join-Path $FRONTEND_DIR "src\modules\cursos"),
        (Join-Path $FRONTEND_DIR "src\modules\inscripciones"),
        (Join-Path $FRONTEND_DIR "src\auth"),
        (Join-Path $FRONTEND_DIR "src\graphql")
    )

    foreach ($dir in $directories) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "  [DIR] $dir" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "--- Creando paquetes Python (__init__.py) ---" -ForegroundColor Cyan
    $initContent = "# Paquete Python - generado por setup_core_assets.ps1"
    $initPaths = @(
        (Join-Path $BACKEND_DIR "core\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca001_auth\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca002_usuarios\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca003_roles\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca005_db\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca006_graphql\__init__.py")
    )
    foreach ($p in $initPaths) {
        Write-SkeletonFile -FilePath $p -Content $initContent
    }

    # CA-005 - DB
    Write-Host ""
    Write-Host "--- CA-005: Archivos de base de datos ---" -ForegroundColor Cyan
    $content_database = @'
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+psycopg2://postgres:postgres@localhost:5432/academico_db")
engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca005_db\database.py") -Content $content_database

    $content_session = @'
from typing import Generator
from sqlalchemy.orm import Session
from .database import SessionLocal
def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca005_db\session.py") -Content $content_session

    $content_models = @'
from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship
from .database import Base

class Usuario(Base):
    __tablename__ = "usuarios"
    id = Column(Integer, primary_key=True, index=True)
    correo = Column(String, unique=True, nullable=False)
    contrasena_hash = Column(String, nullable=False)
    rol = Column(String, nullable=False)
    activo = Column(Boolean, default=True)
    creado_en = Column(DateTime, default=datetime.utcnow)
    __table_args__ = (CheckConstraint("rol IN ('docente', 'administrador')", name="ck_usuario_rol"),)

class Docente(Base):
    __tablename__ = "docentes"
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), unique=True, nullable=True)
    nombre = Column(String, nullable=False)
    correo = Column(String, nullable=False)
    especialidad = Column(String, nullable=True)
    usuario = relationship("Usuario")
    cursos = relationship("Curso", back_populates="docente")

class Estudiante(Base):
    __tablename__ = "estudiantes"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    codigo = Column(String, unique=True, nullable=False)
    correo = Column(String, nullable=False)
    datos_contacto = Column(String, nullable=True)
    inscripciones = relationship("Inscripcion", back_populates="estudiante")

class Curso(Base):
    __tablename__ = "cursos"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    docente_id = Column(Integer, ForeignKey("docentes.id"), nullable=False)
    periodo_academico = Column(String, nullable=False)
    docente = relationship("Docente", back_populates="cursos")
    inscripciones = relationship("Inscripcion", back_populates="curso")

class Inscripcion(Base):
    __tablename__ = "inscripciones"
    id = Column(Integer, primary_key=True, index=True)
    estudiante_id = Column(Integer, ForeignKey("estudiantes.id"), nullable=False)
    curso_id = Column(Integer, ForeignKey("cursos.id"), nullable=False)
    fecha_inscripcion = Column(DateTime, default=datetime.utcnow)
    estado = Column(String, nullable=False)
    __table_args__ = (CheckConstraint("estado IN ('activa', 'cerrada', 'cupo_lleno')", name="ck_inscripcion_estado"),)
    estudiante = relationship("Estudiante", back_populates="inscripciones")
    curso = relationship("Curso", back_populates="inscripciones")
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca005_db\models.py") -Content $content_models

    # CA-001 - Auth
    Write-Host ""
    Write-Host "--- CA-001: Archivos de autenticacion ---" -ForegroundColor Cyan
    $content_auth_schemas = @'
from pydantic import BaseModel
class LoginRequest(BaseModel):
    correo: str
    contrasena: str
class TokenPayload(BaseModel):
    sub: str
    rol: str
    exp: int
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca001_auth\schemas.py") -Content $content_auth_schemas

    $content_auth_security = @'
import os
from datetime import datetime, timedelta
from typing import Optional
from dotenv import load_dotenv
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException, status
from .schemas import TokenPayload

load_dotenv()

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "super_secret_key_123")
ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, rol: str, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta if expires_delta else timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire, "rol": rol})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str) -> TokenPayload:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        correo: str = payload.get("sub")
        rol: str = payload.get("rol")
        if correo is None or rol is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalido")
        return TokenPayload(**payload)
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token invalido")
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca001_auth\security.py") -Content $content_auth_security

    $content_auth_router = @'
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from .schemas import LoginRequest
from .security import verify_password, create_access_token
from core.ca005_db.session import get_db
from core.ca005_db.models import Usuario

router = APIRouter(prefix="/auth", tags=["Autenticacion"])

@router.post("/login")
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.correo == datos.correo).first()
    if not usuario or not verify_password(datos.contrasena, usuario.contrasena_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales incorrectas")
    if not usuario.activo:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Usuario inactivo")
    token = create_access_token(data={"sub": usuario.correo}, rol=usuario.rol)
    return {"token": token, "usuario": {"id": usuario.id, "correo": usuario.correo, "rol": usuario.rol}}
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca001_auth\router.py") -Content $content_auth_router

    # CA-002 - Usuarios
    Write-Host ""
    Write-Host "--- CA-002: Archivos de gestion de usuarios ---" -ForegroundColor Cyan
    $content_usr_schemas = @'
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
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca002_usuarios\schemas.py") -Content $content_usr_schemas

    $content_usr_services = @'
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
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca002_usuarios\services.py") -Content $content_usr_services

    $content_usr_router = @'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from . import schemas, services
from core.ca005_db.session import get_db
from core.ca003_roles.dependencies import requiere_rol

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])

@router.get("/", response_model=List[schemas.UsuarioResponse])
def listar_usuarios(db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    return services.listar_usuarios(db)

@router.post("/", response_model=schemas.UsuarioResponse)
def crear_usuario(datos: schemas.UsuarioCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    return services.crear_usuario(db, datos)

@router.get("/estudiantes", response_model=List[schemas.EstudianteResponse])
def listar_estudiantes(filtro: str = None, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador", "docente"))):
    return services.listar_estudiantes(db, filtro)

@router.post("/estudiantes", response_model=schemas.EstudianteResponse)
def crear_estudiante(datos: schemas.EstudianteCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    return services.crear_estudiante(db, datos)
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca002_usuarios\router.py") -Content $content_usr_router

    # CA-003 - Roles
    Write-Host ""
    Write-Host "--- CA-003: Archivos de roles y permisos ---" -ForegroundColor Cyan
    $content_roles_perms = @'
PERMISOS = {
    "administrador": ["*"],
    "docente": ["leer_estudiantes", "leer_cursos", "actualizar_cursos", "leer_inscripciones"]
}

def verificar_permiso(rol: str, accion: str) -> bool:
    if rol not in PERMISOS: return False
    if "*" in PERMISOS[rol]: return True
    return accion in PERMISOS[rol]
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca003_roles\permissions.py") -Content $content_roles_perms

    $content_roles_deps = @'
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from core.ca001_auth.security import verify_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    return verify_token(token)

def requiere_rol(*roles: str):
    def verificador(token_payload = Depends(get_current_user)):
        if token_payload.rol not in roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tiene permisos para esta accion")
        return token_payload
    return verificador
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca003_roles\dependencies.py") -Content $content_roles_deps

    # CA-006 - GraphQL
    Write-Host ""
    Write-Host "--- CA-006: Archivos de GraphQL ---" -ForegroundColor Cyan
    $content_gql_types = @'
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
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca006_graphql\types.py") -Content $content_gql_types

    $content_gql_schema = @'
import strawberry
from strawberry.schema.config import StrawberryConfig
from strawberry.types import Info
from typing import Optional, List
from .types import (
    UsuarioType, DocenteType, EstudianteType,
    CursoType, InscripcionType, AuthPayload,
    EstudianteInput, DocenteInput, CursoInput,
)
from core.ca005_db.models import Estudiante, Docente, Curso, Inscripcion, Usuario
from core.ca001_auth.security import create_access_token, verify_password

def get_db_from_info(info: Info):
    return info.context["db"]

@strawberry.type
class Query:
    @strawberry.field
    def estudiantes(self, info: Info, filtro: Optional[str] = None) -> List[EstudianteType]:
        db = get_db_from_info(info)
        q = db.query(Estudiante)
        if filtro: q = q.filter(Estudiante.nombre.ilike(f"%{filtro}%"))
        return q.all()

    @strawberry.field
    def docentes(self, info: Info, filtro: Optional[str] = None) -> List[DocenteType]:
        db = get_db_from_info(info)
        q = db.query(Docente)
        if filtro: q = q.filter(Docente.nombre.ilike(f"%{filtro}%"))
        return q.all()

    @strawberry.field
    def cursos(self, info: Info, filtro: Optional[str] = None) -> List[CursoType]:
        db = get_db_from_info(info)
        return db.query(Curso).all()

    @strawberry.field
    def inscripciones(self, info: Info, filtro: Optional[str] = None) -> List[InscripcionType]:
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
        db = get_db_from_info(info)
        nuevo = Estudiante(**datos.__dict__)
        db.add(nuevo)
        db.commit()
        db.refresh(nuevo)
        return nuevo

schema = strawberry.Schema(query=Query, mutation=Mutation, config=StrawberryConfig(auto_camel_case=False))
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca006_graphql\schema.py") -Content $content_gql_schema

    # main.py y env
    Write-Host ""
    Write-Host "--- main.py: Punto de entrada ---" -ForegroundColor Cyan
    $content_main = @'
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from strawberry.fastapi import GraphQLRouter
from sqlalchemy.orm import Session

from core.ca001_auth.router import router as auth_router
from core.ca002_usuarios.router import router as usuarios_router
from core.ca006_graphql.schema import schema
from core.ca005_db.database import engine, Base, SessionLocal

app = FastAPI(title="Sistema de Gestion Academica - LPS", version="0.1.0")

@app.on_event("startup")
def startup_event():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        from core.ca005_db.models import Usuario
        from core.ca001_auth.security import get_password_hash
        if not db.query(Usuario).filter(Usuario.correo == "admin@academico.com").first():
            admin = Usuario(
                correo="admin@academico.com",
                contrasena_hash=get_password_hash("admin123"),
                rol="administrador"
            )
            db.add(admin)
            db.commit()
    except Exception as e:
        print("Error en seeder:", e)
    finally:
        db.close()

from fastapi import Depends

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_context(db: Session = Depends(get_db), request: Request = None):
    return {"db": db, "request": request}

graphql_app = GraphQLRouter(schema, context_getter=get_context)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(usuarios_router)
app.include_router(graphql_app, prefix="/graphql")

@app.get("/")
def root():
    return {"mensaje": "API activa"}
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "main.py") -Content $content_main

    $content_env_example = @'
DB_HOST=localhost
DB_PORT=5432
DB_NAME=academico_db
DB_USER=postgres
DB_PASSWORD=Marcelosql7
SECRET_KEY=super_secret_key_123_change_me_in_prod
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR ".env.example") -Content $content_env_example


    # Frontend
    Write-Host ""
    Write-Host "--- Frontend ---" -ForegroundColor Cyan

    $content_fe_client = @'
import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";
import { setContext } from "@apollo/client/link/context";

const httpLink = createHttpLink({ uri: "http://localhost:8000/graphql" });
const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem("token");
  return { headers: { ...headers, authorization: token ? `Bearer ${token}` : "" } };
});

export const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache()
});
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\graphql\client.js") -Content $content_fe_client

    $content_fe_ops = @'
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
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\graphql\operations.js") -Content $content_fe_ops

    $content_fe_theme = @'
import { createTheme } from "@mui/material/styles";
export const theme = createTheme({
  palette: { primary: { main: "#1976d2" }, secondary: { main: "#dc004e" } }
});
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\theme.js") -Content $content_fe_theme

    $content_fe_auth_ctx = @'
import { createContext, useContext, useState, useEffect } from "react";
const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    const token = localStorage.getItem("token");
    const savedUser = localStorage.getItem("user");
    if (token && savedUser) setUser(JSON.parse(savedUser));
    setLoading(false);
  }, []);

  const login = (token, userData) => {
    localStorage.setItem("token", token);
    localStorage.setItem("user", JSON.stringify(userData));
    setUser(userData);
  };
  const logout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    setUser(null);
  };

  return <AuthContext.Provider value={{ user, loading, login, logout }}>{children}</AuthContext.Provider>;
}
export const useAuth = () => useContext(AuthContext);
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\auth\AuthContext.jsx") -Content $content_fe_auth_ctx

    $content_fe_login = @'
import { useState } from "react";
import { useMutation } from "@apollo/client";
import { useNavigate } from "react-router-dom";
import { Button, TextField, Box, Typography } from "@mui/material";
import { LOGIN_MUTATION } from "../graphql/operations";
import { useAuth } from "./AuthContext";

export default function LoginPage() {
  const [correo, setCorreo] = useState("");
  const [pass, setPass] = useState("");
  const [loginMutation] = useMutation(LOGIN_MUTATION);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    try {
      const { data } = await loginMutation({ variables: { correo, contrasena: pass } });
      login(data.login.token, data.login.usuario);
      navigate("/");
    } catch (err) { alert("Error: " + err.message); }
  };

  return (
    <Box sx={{ maxWidth: 400, mx: "auto", mt: 10 }}>
      <Typography variant="h4" mb={2}>Login</Typography>
      <form onSubmit={handleLogin}>
        <TextField fullWidth label="Correo" margin="normal" value={correo} onChange={e=>setCorreo(e.target.value)} />
        <TextField fullWidth label="Contrasena" type="password" margin="normal" value={pass} onChange={e=>setPass(e.target.value)} />
        <Button fullWidth variant="contained" type="submit" sx={{ mt: 2 }}>Entrar</Button>
      </form>
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\auth\LoginPage.jsx") -Content $content_fe_login

    $content_fe_layout = @'
import { Box, Drawer, List, ListItem, ListItemButton, ListItemText, AppBar, Toolbar, Typography, Button } from "@mui/material";
import { useNavigate, Outlet } from "react-router-dom";
import { useAuth } from "../../auth/AuthContext";

export default function Layout() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  if (!user) return <Outlet />;

  const menu = [
    { text: "Estudiantes", path: "/estudiantes" },
    { text: "Docentes", path: "/docentes" },
    { text: "Cursos", path: "/cursos" },
    { text: "Inscripciones", path: "/inscripciones" }
  ];

  return (
    <Box sx={{ display: "flex" }}>
      <AppBar position="fixed" sx={{ zIndex: 1201 }}><Toolbar>
        <Typography variant="h6" sx={{ flexGrow: 1 }}>SGA</Typography>
        <Typography sx={{ mr: 2 }}>{user.correo}</Typography>
        <Button color="inherit" onClick={() => { logout(); navigate("/login"); }}>Salir</Button>
      </Toolbar></AppBar>
      <Drawer variant="permanent" sx={{ width: 240, flexShrink: 0, [`& .MuiDrawer-paper`]: { width: 240, boxSizing: 'border-box' } }}>
        <Toolbar />
        <List>
          {menu.map(m => (
            <ListItem key={m.text} disablePadding>
              <ListItemButton onClick={() => navigate(m.path)}>
                <ListItemText primary={m.text} />
              </ListItemButton>
            </ListItem>
          ))}
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}><Toolbar /><Outlet /></Box>
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\design-system\components\Layout.jsx") -Content $content_fe_layout

    $content_fe_estudiantes = @'
import { useQuery } from "@apollo/client";
import { GET_ESTUDIANTES } from "../../graphql/operations";
import { Typography, List, ListItem, ListItemText, CircularProgress } from "@mui/material";

export default function EstudiantesPage() {
  const { data, loading, error } = useQuery(GET_ESTUDIANTES);
  if (loading) return <CircularProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  return (
    <div>
      <Typography variant="h4">Estudiantes</Typography>
      <List>
        {data.estudiantes.map(e => (
          <ListItem key={e.id}><ListItemText primary={e.nombre} secondary={e.correo} /></ListItem>
        ))}
      </List>
    </div>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\estudiantes\EstudiantesPage.jsx") -Content $content_fe_estudiantes

    $content_fe_main = @'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { ApolloProvider } from "@apollo/client"
import { ThemeProvider } from "@mui/material/styles"
import { BrowserRouter } from "react-router-dom"
import App from './App'
import { client } from "./graphql/client"
import { theme } from "./theme"
import { AuthProvider } from "./auth/AuthContext"

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <ThemeProvider theme={theme}>
        <AuthProvider>
          <BrowserRouter>
            <App />
          </BrowserRouter>
        </AuthProvider>
      </ThemeProvider>
    </ApolloProvider>
  </React.StrictMode>,
)
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\main.jsx") -Content $content_fe_main

    $content_fe_app = @'
import { Routes, Route, Navigate } from "react-router-dom";
import LoginPage from "./auth/LoginPage";
import Layout from "./design-system/components/Layout";
import EstudiantesPage from "./modules/estudiantes/EstudiantesPage";
import DocentesPage from "./modules/docentes/DocentesPage";
import CursosPage from "./modules/cursos/CursosPage";
import InscripcionesPage from "./modules/inscripciones/InscripcionesPage";
import { useAuth } from "./auth/AuthContext";
import { Typography } from "@mui/material";

function Protected({ children }) {
  const { user, loading } = useAuth();
  if (loading) return null;
  return user ? children : <Navigate to="/login" />;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/" element={<Protected><Layout /></Protected>}>
        <Route index element={<Typography variant="h5">Bienvenido</Typography>} />
        <Route path="estudiantes" element={<EstudiantesPage />} />
        <Route path="docentes" element={<DocentesPage />} />
        <Route path="cursos" element={<CursosPage />} />
        <Route path="inscripciones" element={<InscripcionesPage />} />
      </Route>
    </Routes>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\App.jsx") -Content $content_fe_app

    # --- Frontend: Docentes, Cursos, Inscripciones ---
    $content_fe_docentes = @'
import { useQuery, gql } from "@apollo/client";
import { Typography, List, ListItem, ListItemText, CircularProgress } from "@mui/material";

const GET_DOCENTES = gql`
  query { docentes { id nombre correo especialidad } }
`;

export default function DocentesPage() {
  const { data, loading, error } = useQuery(GET_DOCENTES);
  if (loading) return <CircularProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  return (
    <div>
      <Typography variant="h4">Docentes</Typography>
      <List>
        {data.docentes.map(d => (
          <ListItem key={d.id}><ListItemText primary={d.nombre} secondary={`${d.correo} - ${d.especialidad || 'Sin especialidad'}`} /></ListItem>
        ))}
      </List>
    </div>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\docentes\DocentesPage.jsx") -Content $content_fe_docentes

    $content_fe_cursos = @'
import { useQuery, gql } from "@apollo/client";
import { Typography, List, ListItem, ListItemText, CircularProgress } from "@mui/material";

const GET_CURSOS = gql`
  query { cursos { id nombre periodo_academico } }
`;

export default function CursosPage() {
  const { data, loading, error } = useQuery(GET_CURSOS);
  if (loading) return <CircularProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  return (
    <div>
      <Typography variant="h4">Cursos</Typography>
      <List>
        {data.cursos.map(c => (
          <ListItem key={c.id}><ListItemText primary={c.nombre} secondary={`Periodo: ${c.periodo_academico}`} /></ListItem>
        ))}
      </List>
    </div>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\cursos\CursosPage.jsx") -Content $content_fe_cursos

    $content_fe_insc = @'
import { useQuery, gql } from "@apollo/client";
import { Typography, List, ListItem, ListItemText, CircularProgress } from "@mui/material";

const GET_INSC = gql`
  query { inscripciones { id estado } }
`;

export default function InscripcionesPage() {
  const { data, loading, error } = useQuery(GET_INSC);
  if (loading) return <CircularProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  return (
    <div>
      <Typography variant="h4">Inscripciones</Typography>
      <List>
        {data.inscripciones.map(i => (
          <ListItem key={i.id}><ListItemText primary={`Inscripcion #${i.id}`} secondary={`Estado: ${i.estado}`} /></ListItem>
        ))}
      </List>
    </div>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\inscripciones\InscripcionesPage.jsx") -Content $content_fe_insc

    # Resumen
    if ($skippedFiles.Count -gt 0) {
        Write-Host ""
        Write-Host "  Archivos omitidos (ya existian):" -ForegroundColor Yellow
        foreach ($f in $skippedFiles) {
            $rel = $f.Replace($PROJECT_ROOT + "\", "")
            Write-Host "    - $rel" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

New-ProjectSkeleton



