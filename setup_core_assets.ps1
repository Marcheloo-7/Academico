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

# Instalar las tipografias de la identidad visual "Acta Academica":
# Fraunces (display), IBM Plex Sans (texto) e IBM Plex Mono (datos/codigos).
# Se auto-hospedan via @fontsource en vez de un <link> a Google Fonts para
# que el build no dependa de una peticion externa en tiempo de ejecucion.
npm install --save @fontsource/fraunces @fontsource/ibm-plex-sans @fontsource/ibm-plex-mono

# Ajustar el titulo del index.html generado por create-vite (el titulo por
# defecto queda vacio o generico segun el nombre de carpeta usado)
$indexHtmlPath = Join-Path $FRONTEND_DIR "index.html"
(Get-Content $indexHtmlPath -Raw) -replace '<title>.*?</title>', '<title>SGA - Sistema de Gestion Academica</title>' | Set-Content $indexHtmlPath -Encoding UTF8

Pop-Location

Write-Host "  [OK] Proyecto React (Vite) creado, librerias de diseno (MUI) y tipografias instaladas" -ForegroundColor Green


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


# ===========================================================================
# CA-007 - Validaciones Comunes
# Funciones de validacion compartidas entre frontend y backend.
# No requiere paquetes adicionales (usa re/stdlib en Python y JS puro).
# ===========================================================================

Write-Host "===== CA-007: Validaciones Comunes =====" -ForegroundColor Cyan
Write-Host "  [OK] No se requieren paquetes adicionales" -ForegroundColor Green


# ===========================================================================
# CA-008 - Manejo Centralizado de Errores
# Exception handlers de FastAPI, logging y formateo de errores GraphQL.
# No requiere paquetes adicionales (usa logging/stdlib y Strawberry ya instalado).
# ===========================================================================

Write-Host "===== CA-008: Manejo Centralizado de Errores =====" -ForegroundColor Cyan
Write-Host "  [OK] No se requieren paquetes adicionales" -ForegroundColor Green


# ===========================================================================
# CA-009 - Registro de Auditoria
# Modelo AuditLog y endpoint de consulta de historial.
# No requiere paquetes adicionales (usa SQLAlchemy ya instalado).
# ===========================================================================

Write-Host "===== CA-009: Registro de Auditoria =====" -ForegroundColor Cyan
Write-Host "  [OK] No se requieren paquetes adicionales" -ForegroundColor Green


# ===========================================================================
# CA-010 - Configuracion del Entorno
# Modulo de Settings tipado (pydantic-settings) y variables de CORS/entorno.
# ===========================================================================

Write-Host "===== CA-010: Configuracion del Entorno =====" -ForegroundColor Cyan

pip install --quiet pydantic-settings

$envConfigContent = @"

# ============================================
# CA-010 - Configuracion del Entorno
# ============================================
CORS_ORIGINS=http://localhost:5173
ENVIRONMENT=development
LOG_LEVEL=INFO
"@
Add-Content -Path $envFilePath -Value $envConfigContent -Encoding UTF8

Write-Host "  [OK] pydantic-settings instalado y variables de entorno anadidas al .env" -ForegroundColor Green


# ===========================================================================
# CA-011 - DevOps Templates
# Dockerfiles, docker-compose, workflows de CI/CD y linting del frontend.
# ===========================================================================

Write-Host "===== CA-011: DevOps Templates =====" -ForegroundColor Cyan

Push-Location $FRONTEND_DIR
npm install --save-dev "eslint@^9" "@eslint/js@^9" eslint-plugin-react eslint-plugin-react-hooks globals
npm pkg set scripts.lint="eslint ."
Pop-Location

Write-Host "  [OK] ESLint instalado y script 'lint' anadido al frontend" -ForegroundColor Green

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
        (Join-Path $BACKEND_DIR "core\ca007_validaciones"),
        (Join-Path $BACKEND_DIR "core\ca008_errores"),
        (Join-Path $BACKEND_DIR "core\ca009_auditoria"),
        (Join-Path $BACKEND_DIR "core\ca010_config"),
        (Join-Path $FRONTEND_DIR "src\design-system\components"),
        (Join-Path $FRONTEND_DIR "src\modules\estudiantes"),
        (Join-Path $FRONTEND_DIR "src\modules\docentes"),
        (Join-Path $FRONTEND_DIR "src\modules\cursos"),
        (Join-Path $FRONTEND_DIR "src\modules\inscripciones"),
        (Join-Path $FRONTEND_DIR "src\modules\inicio"),
        (Join-Path $FRONTEND_DIR "src\auth"),
        (Join-Path $FRONTEND_DIR "src\graphql"),
        (Join-Path $FRONTEND_DIR "src\utils"),
        (Join-Path $FRONTEND_DIR "src\errors"),
        (Join-Path $PROJECT_ROOT ".github\workflows")
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
        (Join-Path $BACKEND_DIR "core\ca006_graphql\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca007_validaciones\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca008_errores\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca009_auditoria\__init__.py"),
        (Join-Path $BACKEND_DIR "core\ca010_config\__init__.py")
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
﻿from datetime import datetime
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

class TokenRevocado(Base):
    __tablename__ = "tokens_revocados"
    id = Column(Integer, primary_key=True, index=True)
    jti = Column(String, unique=True, nullable=False, index=True)
    revocado_en = Column(DateTime, default=datetime.utcnow)

class Docente(Base):
    __tablename__ = "docentes"
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id"), unique=True, nullable=True)
    nombre = Column(String, nullable=False)
    correo = Column(String, nullable=False)
    especialidad = Column(String, nullable=True)
    activo = Column(Boolean, default=True, nullable=False)
    usuario = relationship("Usuario")
    cursos = relationship("Curso", back_populates="docente")

class Estudiante(Base):
    __tablename__ = "estudiantes"
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    codigo = Column(String, unique=True, nullable=False)
    correo = Column(String, nullable=False)
    datos_contacto = Column(String, nullable=True)
    activo = Column(Boolean, default=True, nullable=False)
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
﻿from typing import Optional
from pydantic import BaseModel
class LoginRequest(BaseModel):
    correo: str
    contrasena: str
class RegistroRequest(BaseModel):
    correo: str
    contrasena: str
class TokenPayload(BaseModel):
    sub: str
    rol: str
    exp: int
    jti: Optional[str] = None
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca001_auth\schemas.py") -Content $content_auth_schemas

    $content_auth_security = @'
﻿import os
import uuid
from datetime import datetime, timedelta
from typing import Optional
from dotenv import load_dotenv
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
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
    to_encode.update({"exp": expire, "rol": rol, "jti": str(uuid.uuid4())})
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

def es_token_revocado(db: Session, jti: Optional[str]) -> bool:
    if not jti:
        return False
    from core.ca005_db.models import TokenRevocado
    return db.query(TokenRevocado).filter(TokenRevocado.jti == jti).first() is not None

def revocar_token(db: Session, jti: str) -> None:
    from core.ca005_db.models import TokenRevocado
    if not db.query(TokenRevocado).filter(TokenRevocado.jti == jti).first():
        db.add(TokenRevocado(jti=jti))
        db.commit()
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca001_auth\security.py") -Content $content_auth_security

    $content_auth_router = @'
﻿from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .schemas import LoginRequest, RegistroRequest
from .security import verify_password, get_password_hash, create_access_token, verify_token, revocar_token
from core.ca005_db.session import get_db
from core.ca005_db.models import Usuario
from core.ca007_validaciones.validators import es_email_valido, es_password_seguro

router = APIRouter(prefix="/auth", tags=["Autenticacion"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

@router.post("/login")
def login(datos: LoginRequest, db: Session = Depends(get_db)):
    usuario = db.query(Usuario).filter(Usuario.correo == datos.correo).first()
    if not usuario or not verify_password(datos.contrasena, usuario.contrasena_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales incorrectas")
    if not usuario.activo:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Usuario inactivo")
    token = create_access_token(data={"sub": usuario.correo}, rol=usuario.rol)
    return {"token": token, "usuario": {"id": usuario.id, "correo": usuario.correo, "rol": usuario.rol}}

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(datos: RegistroRequest, db: Session = Depends(get_db)):
    # Auto-registro publico: el rol siempre queda fijo en "docente". Asignar
    # "administrador" requiere que otro administrador lo haga luego via
    # PUT /usuarios/{id}, para no exponer creacion de cuentas admin sin
    # control desde un endpoint sin autenticacion previa.
    if not es_email_valido(datos.correo):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="Correo invalido")
    if not es_password_seguro(datos.contrasena):
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail="La contrasena no cumple los requisitos de seguridad")
    if db.query(Usuario).filter(Usuario.correo == datos.correo).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="El correo ya esta registrado")
    nuevo = Usuario(correo=datos.correo, contrasena_hash=get_password_hash(datos.contrasena), rol="docente")
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return {"id": nuevo.id, "correo": nuevo.correo, "rol": nuevo.rol}

@router.post("/logout")
def logout(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = verify_token(token)
    if payload.jti:
        revocar_token(db, payload.jti)
    return {"mensaje": "Sesion cerrada"}
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca001_auth\router.py") -Content $content_auth_router

    # CA-002 - Usuarios
    Write-Host ""
    Write-Host "--- CA-002: Archivos de gestion de usuarios ---" -ForegroundColor Cyan
    $content_usr_schemas = @'
﻿from typing import Optional
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

class UsuarioUpdate(BaseModel):
    correo: Optional[str] = None
    rol: Optional[str] = None
    activo: Optional[bool] = None

class EstudianteCreate(BaseModel):
    nombre: str
    codigo: str
    correo: str
    datos_contacto: Optional[str] = None

class EstudianteResponse(EstudianteCreate):
    id: int
    activo: bool
    class Config:
        from_attributes = True

class EstudianteUpdate(BaseModel):
    nombre: Optional[str] = None
    codigo: Optional[str] = None
    correo: Optional[str] = None
    datos_contacto: Optional[str] = None

class DocenteCreate(BaseModel):
    nombre: str
    correo: str
    especialidad: Optional[str] = None
    usuario_id: Optional[int] = None

class DocenteResponse(DocenteCreate):
    id: int
    activo: bool
    class Config:
        from_attributes = True

class DocenteUpdate(BaseModel):
    nombre: Optional[str] = None
    correo: Optional[str] = None
    especialidad: Optional[str] = None
    usuario_id: Optional[int] = None
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca002_usuarios\schemas.py") -Content $content_usr_schemas

    $content_usr_services = @'
﻿from typing import Optional
from sqlalchemy.orm import Session
from .schemas import (
    UsuarioCreate, UsuarioUpdate,
    EstudianteCreate, EstudianteUpdate,
    DocenteCreate, DocenteUpdate,
)
from core.ca005_db.models import Usuario, Estudiante, Docente
from core.ca001_auth.security import get_password_hash
from core.ca008_errores.exceptions import RecursoNoEncontradoException

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

def listar_usuarios(db: Session, filtro: Optional[str] = None, offset: int = 0, limite: int = 50):
    query = db.query(Usuario)
    if filtro:
        query = query.filter(Usuario.correo.ilike(f"%{filtro}%"))
    return query.order_by(Usuario.id).offset(offset).limit(limite).all()

def obtener_usuario(db: Session, usuario_id: int) -> Usuario:
    usuario = db.query(Usuario).filter(Usuario.id == usuario_id).first()
    if not usuario:
        raise RecursoNoEncontradoException("Usuario no encontrado")
    return usuario

def actualizar_usuario(db: Session, usuario_id: int, datos: UsuarioUpdate):
    usuario = obtener_usuario(db, usuario_id)
    for campo, valor in datos.dict(exclude_unset=True).items():
        setattr(usuario, campo, valor)
    db.commit()
    db.refresh(usuario)
    return usuario

def eliminar_usuario(db: Session, usuario_id: int):
    usuario = obtener_usuario(db, usuario_id)
    usuario.activo = False
    db.commit()
    db.refresh(usuario)
    return usuario

def crear_estudiante(db: Session, datos: EstudianteCreate):
    nuevo = Estudiante(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

def listar_estudiantes(db: Session, filtro: Optional[str] = None, offset: int = 0, limite: int = 50):
    query = db.query(Estudiante).filter(Estudiante.activo == True)  # noqa: E712
    if filtro:
        query = query.filter(Estudiante.nombre.ilike(f"%{filtro}%"))
    return query.order_by(Estudiante.id).offset(offset).limit(limite).all()

def obtener_estudiante(db: Session, estudiante_id: int) -> Estudiante:
    estudiante = db.query(Estudiante).filter(Estudiante.id == estudiante_id).first()
    if not estudiante:
        raise RecursoNoEncontradoException("Estudiante no encontrado")
    return estudiante

def actualizar_estudiante(db: Session, estudiante_id: int, datos: EstudianteUpdate):
    estudiante = obtener_estudiante(db, estudiante_id)
    for campo, valor in datos.dict(exclude_unset=True).items():
        setattr(estudiante, campo, valor)
    db.commit()
    db.refresh(estudiante)
    return estudiante

def eliminar_estudiante(db: Session, estudiante_id: int):
    estudiante = obtener_estudiante(db, estudiante_id)
    estudiante.activo = False
    db.commit()
    db.refresh(estudiante)
    return estudiante

def crear_docente(db: Session, datos: DocenteCreate):
    nuevo = Docente(**datos.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

def listar_docentes(db: Session, filtro: Optional[str] = None, offset: int = 0, limite: int = 50):
    query = db.query(Docente).filter(Docente.activo == True)  # noqa: E712
    if filtro:
        query = query.filter(Docente.nombre.ilike(f"%{filtro}%"))
    return query.order_by(Docente.id).offset(offset).limit(limite).all()

def obtener_docente(db: Session, docente_id: int) -> Docente:
    docente = db.query(Docente).filter(Docente.id == docente_id).first()
    if not docente:
        raise RecursoNoEncontradoException("Docente no encontrado")
    return docente

def actualizar_docente(db: Session, docente_id: int, datos: DocenteUpdate):
    docente = obtener_docente(db, docente_id)
    for campo, valor in datos.dict(exclude_unset=True).items():
        setattr(docente, campo, valor)
    db.commit()
    db.refresh(docente)
    return docente

def eliminar_docente(db: Session, docente_id: int):
    docente = obtener_docente(db, docente_id)
    docente.activo = False
    db.commit()
    db.refresh(docente)
    return docente
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca002_usuarios\services.py") -Content $content_usr_services

    $content_usr_router = @'
﻿from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from . import schemas, services
from core.ca005_db.session import get_db
from core.ca003_roles.dependencies import requiere_rol
from core.ca009_auditoria.services import registrar_auditoria

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])

@router.get("/", response_model=List[schemas.UsuarioResponse])
def listar_usuarios(filtro: str = None, offset: int = 0, limite: int = 50, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    return services.listar_usuarios(db, filtro, offset, limite)

@router.post("/", response_model=schemas.UsuarioResponse)
def crear_usuario(datos: schemas.UsuarioCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    nuevo = services.crear_usuario(db, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="usuario", accion="crear", valores_nuevos={"correo": nuevo.correo, "rol": nuevo.rol})
    return nuevo

@router.put("/{usuario_id}", response_model=schemas.UsuarioResponse)
def actualizar_usuario(usuario_id: int, datos: schemas.UsuarioUpdate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    actualizado = services.actualizar_usuario(db, usuario_id, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="usuario", accion="actualizar", valores_nuevos=datos.dict(exclude_unset=True))
    return actualizado

@router.delete("/{usuario_id}", response_model=schemas.UsuarioResponse)
def eliminar_usuario(usuario_id: int, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    eliminado = services.eliminar_usuario(db, usuario_id)
    registrar_auditoria(db, usuario=token.sub, recurso="usuario", accion="eliminar", valores_nuevos={"id": eliminado.id, "activo": eliminado.activo})
    return eliminado

@router.get("/estudiantes", response_model=List[schemas.EstudianteResponse])
def listar_estudiantes(filtro: str = None, offset: int = 0, limite: int = 50, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador", "docente"))):
    return services.listar_estudiantes(db, filtro, offset, limite)

@router.post("/estudiantes", response_model=schemas.EstudianteResponse)
def crear_estudiante(datos: schemas.EstudianteCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    nuevo = services.crear_estudiante(db, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="estudiante", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "codigo": nuevo.codigo})
    return nuevo

@router.put("/estudiantes/{estudiante_id}", response_model=schemas.EstudianteResponse)
def actualizar_estudiante(estudiante_id: int, datos: schemas.EstudianteUpdate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    actualizado = services.actualizar_estudiante(db, estudiante_id, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="estudiante", accion="actualizar", valores_nuevos=datos.dict(exclude_unset=True))
    return actualizado

@router.delete("/estudiantes/{estudiante_id}", response_model=schemas.EstudianteResponse)
def eliminar_estudiante(estudiante_id: int, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    eliminado = services.eliminar_estudiante(db, estudiante_id)
    registrar_auditoria(db, usuario=token.sub, recurso="estudiante", accion="eliminar", valores_nuevos={"id": eliminado.id, "activo": eliminado.activo})
    return eliminado

@router.get("/docentes", response_model=List[schemas.DocenteResponse])
def listar_docentes(filtro: str = None, offset: int = 0, limite: int = 50, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador", "docente"))):
    return services.listar_docentes(db, filtro, offset, limite)

@router.post("/docentes", response_model=schemas.DocenteResponse)
def crear_docente(datos: schemas.DocenteCreate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    nuevo = services.crear_docente(db, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="docente", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "correo": nuevo.correo})
    return nuevo

@router.put("/docentes/{docente_id}", response_model=schemas.DocenteResponse)
def actualizar_docente(docente_id: int, datos: schemas.DocenteUpdate, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    actualizado = services.actualizar_docente(db, docente_id, datos)
    registrar_auditoria(db, usuario=token.sub, recurso="docente", accion="actualizar", valores_nuevos=datos.dict(exclude_unset=True))
    return actualizado

@router.delete("/docentes/{docente_id}", response_model=schemas.DocenteResponse)
def eliminar_docente(docente_id: int, db: Session = Depends(get_db), token = Depends(requiere_rol("administrador"))):
    eliminado = services.eliminar_docente(db, docente_id)
    registrar_auditoria(db, usuario=token.sub, recurso="docente", accion="eliminar", valores_nuevos={"id": eliminado.id, "activo": eliminado.activo})
    return eliminado
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca002_usuarios\router.py") -Content $content_usr_router

    # CA-003 - Roles
    Write-Host ""
    Write-Host "--- CA-003: Archivos de roles y permisos ---" -ForegroundColor Cyan
    $content_roles_perms = @'
﻿PERMISOS = {
    "administrador": ["*"],
    "docente": ["leer_estudiantes", "leer_cursos", "actualizar_cursos", "leer_inscripciones"]
}

def verificar_permiso(rol: str, accion: str) -> bool:
    if rol not in PERMISOS: return False
    if "*" in PERMISOS[rol]: return True
    return accion in PERMISOS[rol]

def listar_roles() -> list[dict]:
    return [{"rol": rol, "permisos": permisos} for rol, permisos in PERMISOS.items()]
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca003_roles\permissions.py") -Content $content_roles_perms

    $content_roles_deps = @'
﻿from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from core.ca001_auth.security import verify_token, es_token_revocado
from core.ca005_db.session import get_db
from .permissions import verificar_permiso

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = verify_token(token)
    if es_token_revocado(db, payload.jti):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token revocado")
    return payload

def requiere_rol(*roles: str):
    def verificador(token_payload = Depends(get_current_user)):
        if token_payload.rol not in roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tiene permisos para esta accion")
        return token_payload
    return verificador

def requiere_permiso(accion: str):
    def verificador(token_payload = Depends(get_current_user)):
        if not verificar_permiso(token_payload.rol, accion):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tiene permiso para esta accion")
        return token_payload
    return verificador
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca003_roles\dependencies.py") -Content $content_roles_deps

    $content_roles_router = @'
from fastapi import APIRouter, Depends
from .dependencies import requiere_rol
from .permissions import listar_roles

router = APIRouter(prefix="/roles", tags=["Roles"])

@router.get("/")
def obtener_roles(token = Depends(requiere_rol("administrador"))):
    return listar_roles()
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca003_roles\router.py") -Content $content_roles_router

    # CA-006 - GraphQL
    Write-Host ""
    Write-Host "--- CA-006: Archivos de GraphQL ---" -ForegroundColor Cyan
    $content_gql_types = @'
﻿import strawberry
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

@strawberry.input
class EstudianteUpdateInput:
    nombre: Optional[str] = None
    codigo: Optional[str] = None
    correo: Optional[str] = None
    datos_contacto: Optional[str] = None

@strawberry.input
class DocenteUpdateInput:
    nombre: Optional[str] = None
    correo: Optional[str] = None
    especialidad: Optional[str] = None

@strawberry.input
class CursoUpdateInput:
    nombre: Optional[str] = None
    docente_id: Optional[int] = None
    periodo_academico: Optional[str] = None

@strawberry.input
class InscripcionUpdateInput:
    estado: Optional[str] = None
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca006_graphql\types.py") -Content $content_gql_types

    $content_gql_schema = @'
import strawberry
from strawberry.schema.config import StrawberryConfig
from strawberry.types import Info
from typing import Optional, List
from core.ca008_errores.graphql_errors import (
    AcademicoSchema,
    NoAutorizadoGraphQLError,
    PermisoDenegadoGraphQLError,
    RecursoNoEncontradoGraphQLError,
)
from .types import (
    UsuarioType, DocenteType, EstudianteType,
    CursoType, InscripcionType, AuthPayload,
    EstudianteInput, DocenteInput, CursoInput, InscripcionInput,
    EstudianteUpdateInput, DocenteUpdateInput, CursoUpdateInput, InscripcionUpdateInput,
)
from core.ca005_db.models import Estudiante, Docente, Curso, Inscripcion, Usuario
from core.ca001_auth.security import create_access_token, verify_password, verify_token, es_token_revocado, revocar_token
from core.ca003_roles.permissions import verificar_permiso
from core.ca009_auditoria.services import registrar_auditoria

def get_db_from_info(info: Info):
    return info.context["db"]

def get_usuario_actual(info: Info, *roles: str, accion: Optional[str] = None):
    # No existe middleware global de autenticacion para GraphQL (a diferencia
    # de REST, que usa requiere_rol de core.ca003_roles.dependencies); cada
    # query/mutation que necesita proteger acceso o saber "quien" actua
    # (para auditoria) llama a este helper, que valida el Authorization
    # header manualmente y opcionalmente exige uno de los roles indicados.
    # "accion" permite, ademas del chequeo de rol, exigir un permiso
    # granular de CA-003 (core.ca003_roles.permissions.PERMISOS).
    request = info.context.get("request")
    auth_header = request.headers.get("authorization") if request else None
    if not auth_header or not auth_header.lower().startswith("bearer "):
        raise NoAutorizadoGraphQLError()
    token = auth_header.split(" ", 1)[1]
    usuario = verify_token(token)
    if es_token_revocado(get_db_from_info(info), usuario.jti):
        raise NoAutorizadoGraphQLError("Token revocado")
    if roles and usuario.rol not in roles:
        raise PermisoDenegadoGraphQLError()
    if accion and not verificar_permiso(usuario.rol, accion):
        raise PermisoDenegadoGraphQLError()
    return usuario

def obtener_o_404(db, modelo, id: int, mensaje: str):
    instancia = db.query(modelo).filter(modelo.id == id).first()
    if not instancia:
        raise RecursoNoEncontradoGraphQLError(mensaje)
    return instancia

def aplicar_cambios(instancia, datos):
    for campo, valor in datos.__dict__.items():
        if valor is not None:
            setattr(instancia, campo, valor)
    return instancia

@strawberry.type
class Query:
    @strawberry.field
    def estudiantes(self, info: Info, filtro: Optional[str] = None, offset: int = 0, limite: int = 50) -> List[EstudianteType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        q = db.query(Estudiante).filter(Estudiante.activo == True)  # noqa: E712
        if filtro: q = q.filter(Estudiante.nombre.ilike(f"%{filtro}%"))
        return q.order_by(Estudiante.id).offset(offset).limit(limite).all()

    @strawberry.field
    def docentes(self, info: Info, filtro: Optional[str] = None, offset: int = 0, limite: int = 50) -> List[DocenteType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        q = db.query(Docente).filter(Docente.activo == True)  # noqa: E712
        if filtro: q = q.filter(Docente.nombre.ilike(f"%{filtro}%"))
        return q.order_by(Docente.id).offset(offset).limit(limite).all()

    @strawberry.field
    def cursos(self, info: Info, filtro: Optional[str] = None, offset: int = 0, limite: int = 50) -> List[CursoType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        q = db.query(Curso)
        if filtro: q = q.filter(Curso.nombre.ilike(f"%{filtro}%"))
        return q.order_by(Curso.id).offset(offset).limit(limite).all()

    @strawberry.field
    def inscripciones(self, info: Info, filtro: Optional[str] = None, offset: int = 0, limite: int = 50) -> List[InscripcionType]:
        get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        q = db.query(Inscripcion)
        return q.order_by(Inscripcion.id).offset(offset).limit(limite).all()

@strawberry.type
class Mutation:
    @strawberry.mutation
    def login(self, info: Info, correo: str, contrasena: str) -> AuthPayload:
        db = get_db_from_info(info)
        usuario = db.query(Usuario).filter(Usuario.correo == correo).first()
        if not usuario or not verify_password(contrasena, usuario.contrasena_hash):
            raise NoAutorizadoGraphQLError("Credenciales invalidas")
        token = create_access_token(data={"sub": usuario.correo}, rol=usuario.rol)
        return AuthPayload(token=token, usuario=usuario)

    @strawberry.mutation
    def logout(self, info: Info) -> bool:
        usuario = get_usuario_actual(info)
        db = get_db_from_info(info)
        if usuario.jti:
            revocar_token(db, usuario.jti)
        return True

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
    def actualizar_estudiante(self, info: Info, id: int, datos: EstudianteUpdateInput) -> EstudianteType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        estudiante = obtener_o_404(db, Estudiante, id, "Estudiante no encontrado")
        aplicar_cambios(estudiante, datos)
        db.commit()
        db.refresh(estudiante)
        registrar_auditoria(db, usuario=usuario.sub, recurso="estudiante", accion="actualizar", valores_nuevos={k: v for k, v in datos.__dict__.items() if v is not None})
        return estudiante

    @strawberry.mutation
    def eliminar_estudiante(self, info: Info, id: int) -> EstudianteType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        estudiante = obtener_o_404(db, Estudiante, id, "Estudiante no encontrado")
        estudiante.activo = False
        db.commit()
        db.refresh(estudiante)
        registrar_auditoria(db, usuario=usuario.sub, recurso="estudiante", accion="eliminar", valores_nuevos={"id": id, "activo": False})
        return estudiante

    @strawberry.mutation
    def crear_docente(self, info: Info, datos: DocenteInput) -> DocenteType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        nuevo = Docente(**datos.__dict__)
        db.add(nuevo)
        db.commit()
        db.refresh(nuevo)
        registrar_auditoria(db, usuario=usuario.sub, recurso="docente", accion="crear", valores_nuevos={"nombre": nuevo.nombre, "correo": nuevo.correo})
        return nuevo

    @strawberry.mutation
    def actualizar_docente(self, info: Info, id: int, datos: DocenteUpdateInput) -> DocenteType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        docente = obtener_o_404(db, Docente, id, "Docente no encontrado")
        aplicar_cambios(docente, datos)
        db.commit()
        db.refresh(docente)
        registrar_auditoria(db, usuario=usuario.sub, recurso="docente", accion="actualizar", valores_nuevos={k: v for k, v in datos.__dict__.items() if v is not None})
        return docente

    @strawberry.mutation
    def eliminar_docente(self, info: Info, id: int) -> DocenteType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        docente = obtener_o_404(db, Docente, id, "Docente no encontrado")
        docente.activo = False
        db.commit()
        db.refresh(docente)
        registrar_auditoria(db, usuario=usuario.sub, recurso="docente", accion="eliminar", valores_nuevos={"id": id, "activo": False})
        return docente

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
    def actualizar_curso(self, info: Info, id: int, datos: CursoUpdateInput) -> CursoType:
        # Unico punto del dominio que exige el permiso granular "actualizar_cursos"
        # de CA-003 en vez de solo el rol: administrador tiene "*" y pasa siempre;
        # docente solo pasa porque ese permiso especifico esta en su lista.
        usuario = get_usuario_actual(info, "administrador", "docente", accion="actualizar_cursos")
        db = get_db_from_info(info)
        curso = obtener_o_404(db, Curso, id, "Curso no encontrado")
        aplicar_cambios(curso, datos)
        db.commit()
        db.refresh(curso)
        registrar_auditoria(db, usuario=usuario.sub, recurso="curso", accion="actualizar", valores_nuevos={k: v for k, v in datos.__dict__.items() if v is not None})
        return curso

    @strawberry.mutation
    def eliminar_curso(self, info: Info, id: int) -> CursoType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        curso = obtener_o_404(db, Curso, id, "Curso no encontrado")
        db.delete(curso)
        db.commit()
        registrar_auditoria(db, usuario=usuario.sub, recurso="curso", accion="eliminar", valores_nuevos={"id": id})
        return curso

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

    @strawberry.mutation
    def actualizar_inscripcion(self, info: Info, id: int, datos: InscripcionUpdateInput) -> InscripcionType:
        usuario = get_usuario_actual(info, "administrador", "docente")
        db = get_db_from_info(info)
        inscripcion = obtener_o_404(db, Inscripcion, id, "Inscripcion no encontrada")
        aplicar_cambios(inscripcion, datos)
        db.commit()
        db.refresh(inscripcion)
        registrar_auditoria(db, usuario=usuario.sub, recurso="inscripcion", accion="actualizar", valores_nuevos={k: v for k, v in datos.__dict__.items() if v is not None})
        return inscripcion

    @strawberry.mutation
    def eliminar_inscripcion(self, info: Info, id: int) -> InscripcionType:
        usuario = get_usuario_actual(info, "administrador")
        db = get_db_from_info(info)
        inscripcion = obtener_o_404(db, Inscripcion, id, "Inscripcion no encontrada")
        db.delete(inscripcion)
        db.commit()
        registrar_auditoria(db, usuario=usuario.sub, recurso="inscripcion", accion="eliminar", valores_nuevos={"id": id})
        return inscripcion

schema = AcademicoSchema(query=Query, mutation=Mutation, config=StrawberryConfig(auto_camel_case=False))
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca006_graphql\schema.py") -Content $content_gql_schema

    # CA-007 - Validaciones Comunes
    Write-Host ""
    Write-Host "--- CA-007: Validaciones Comunes ---" -ForegroundColor Cyan
    $content_val_mensajes = @'
MENSAJES_ERROR = {
    "campo_requerido": "Este campo es obligatorio.",
    "formato_email_invalido": "El formato del correo electronico no es valido.",
    "longitud_invalida": "La longitud del campo no cumple con el rango permitido.",
    "fecha_invalida": "La fecha ingresada no es valida.",
    "cedula_invalida": "El numero de cedula/matricula no es valido.",
    "password_debil": "La contrasena debe tener al menos 8 caracteres, una mayuscula, una minuscula y un numero.",
}
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca007_validaciones\mensajes.py") -Content $content_val_mensajes

    $content_val_validators = @'
import re
from datetime import datetime
from typing import Optional

EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def es_email_valido(valor: str) -> bool:
    return bool(valor) and bool(EMAIL_REGEX.match(valor))


def validar_longitud(valor: str, minimo: int = 0, maximo: Optional[int] = None) -> bool:
    if valor is None:
        return False
    largo = len(valor)
    if largo < minimo:
        return False
    if maximo is not None and largo > maximo:
        return False
    return True


def es_fecha_valida(valor: str, formato: str = "%Y-%m-%d") -> bool:
    try:
        datetime.strptime(valor, formato)
        return True
    except (ValueError, TypeError):
        return False


def es_cedula_valida(valor: str) -> bool:
    # Validacion basica: solo digitos y longitud entre 6 y 15.
    # Un checksum real de cedula es especifico de cada pais/producto
    # y queda fuera del alcance de este Core Asset generico.
    return bool(valor) and valor.isdigit() and 6 <= len(valor) <= 15


def es_password_seguro(valor: str) -> bool:
    if not valor or len(valor) < 8:
        return False
    tiene_mayuscula = any(c.isupper() for c in valor)
    tiene_minuscula = any(c.islower() for c in valor)
    tiene_digito = any(c.isdigit() for c in valor)
    return tiene_mayuscula and tiene_minuscula and tiene_digito
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca007_validaciones\validators.py") -Content $content_val_validators

    $content_val_mixins = @'
from .validators import es_email_valido
from .mensajes import MENSAJES_ERROR


def validar_correo_pydantic(cls, v: str) -> str:
    if not es_email_valido(v):
        raise ValueError(MENSAJES_ERROR["formato_email_invalido"])
    return v


# Ejemplo de uso en un schema Pydantic v2 (no aplicado automaticamente a los
# schemas existentes, disponible para que cada producto derivado lo adopte):
#
# from pydantic import BaseModel, field_validator
# from core.ca007_validaciones.mixins import validar_correo_pydantic
#
# class MiSchema(BaseModel):
#     correo: str
#     _check_correo = field_validator("correo")(validar_correo_pydantic)
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca007_validaciones\mixins.py") -Content $content_val_mixins

    $content_fe_validation = @'
export const ERROR_MESSAGES = {
  campoRequerido: "Este campo es obligatorio.",
  formatoEmailInvalido: "El formato del correo electronico no es valido.",
  longitudInvalida: "La longitud del campo no cumple con el rango permitido.",
  fechaInvalida: "La fecha ingresada no es valida.",
  cedulaInvalida: "El numero de cedula/matricula no es valido.",
  passwordDebil:
    "La contrasena debe tener al menos 8 caracteres, una mayuscula, una minuscula y un numero.",
};

const EMAIL_REGEX = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export function validateEmail(value) {
  return Boolean(value) && EMAIL_REGEX.test(value);
}

export function validateRequired(value) {
  return value !== null && value !== undefined && String(value).trim() !== "";
}

export function validateLength(value, min = 0, max = Infinity) {
  if (value === null || value === undefined) return false;
  const len = String(value).length;
  return len >= min && len <= max;
}

export function validateDateRange(value, min, max) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return false;
  if (min && date < new Date(min)) return false;
  if (max && date > new Date(max)) return false;
  return true;
}

export function validateCedula(value) {
  return Boolean(value) && /^\d{6,15}$/.test(value);
}

export function validatePasswordStrength(value) {
  if (!value || value.length < 8) return false;
  return /[A-Z]/.test(value) && /[a-z]/.test(value) && /\d/.test(value);
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\utils\validation.js") -Content $content_fe_validation

    $content_fe_useformvalidation = @'
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

  return { values, errors, handleChange, validateAll, setValues };
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\utils\useFormValidation.js") -Content $content_fe_useformvalidation

    $content_fe_apiclient = @'
const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";

async function apiFetch(path, options = {}) {
  const token = localStorage.getItem("token");
  const headers = { "Content-Type": "application/json", ...(options.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;

  const res = await fetch(`${API_URL}${path}`, { ...options, headers });
  if (!res.ok) {
    let mensaje = `Error ${res.status}`;
    try {
      const body = await res.json();
      mensaje = body.mensaje || body.detail || mensaje;
    } catch {
      // respuesta sin cuerpo JSON (ej. error de red)
    }
    throw new Error(mensaje);
  }
  const contentType = res.headers.get("content-type") || "";
  if (contentType.includes("application/json")) return res.json();
  return res;
}

export { apiFetch, API_URL };
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\utils\apiClient.js") -Content $content_fe_apiclient

    # CA-008 - Manejo Centralizado de Errores
    Write-Host ""
    Write-Host "--- CA-008: Manejo Centralizado de Errores ---" -ForegroundColor Cyan
    $content_err_schemas = @'
from typing import Any, Optional
from pydantic import BaseModel


class ErrorResponse(BaseModel):
    codigo: str
    mensaje: str
    tipo: str
    detalle: Optional[Any] = None
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca008_errores\schemas.py") -Content $content_err_schemas

    $content_err_exceptions = @'
class AppException(Exception):
    def __init__(self, codigo: str, mensaje: str, status_code: int = 400, tipo: str = "aplicacion"):
        self.codigo = codigo
        self.mensaje = mensaje
        self.status_code = status_code
        self.tipo = tipo
        super().__init__(mensaje)


class RecursoNoEncontradoException(AppException):
    def __init__(self, mensaje: str = "Recurso no encontrado"):
        super().__init__(codigo="recurso_no_encontrado", mensaje=mensaje, status_code=404, tipo="no_encontrado")


class NoAutorizadoException(AppException):
    def __init__(self, mensaje: str = "No autorizado"):
        super().__init__(codigo="no_autorizado", mensaje=mensaje, status_code=401, tipo="autenticacion")


class PermisoDenegadoException(AppException):
    def __init__(self, mensaje: str = "Permiso denegado"):
        super().__init__(codigo="permiso_denegado", mensaje=mensaje, status_code=403, tipo="autorizacion")


class ErrorDeValidacionException(AppException):
    def __init__(self, mensaje: str = "Error de validacion"):
        super().__init__(codigo="error_validacion", mensaje=mensaje, status_code=422, tipo="validacion")
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca008_errores\exceptions.py") -Content $content_err_exceptions

    $content_err_logging = @'
import logging

logger = logging.getLogger("academico")


def configurar_logging():
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca008_errores\logging_config.py") -Content $content_err_logging

    $content_err_handlers = @'
from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from .exceptions import AppException
from .schemas import ErrorResponse
from .logging_config import logger


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.warning("Error de validacion en %s: %s", request.url.path, exc.errors())
    error = ErrorResponse(
        codigo="error_validacion",
        mensaje="Los datos enviados no son validos.",
        tipo="validacion",
        detalle=exc.errors(),
    )
    return JSONResponse(status_code=422, content=error.model_dump())


async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    logger.warning("HTTPException en %s: %s", request.url.path, exc.detail)
    error = ErrorResponse(
        codigo="error_http",
        mensaje=str(exc.detail),
        tipo="cliente" if exc.status_code < 500 else "servidor",
    )
    return JSONResponse(status_code=exc.status_code, content=error.model_dump())


async def app_exception_handler(request: Request, exc: AppException):
    logger.warning("AppException en %s: %s", request.url.path, exc.mensaje)
    error = ErrorResponse(codigo=exc.codigo, mensaje=exc.mensaje, tipo=exc.tipo)
    return JSONResponse(status_code=exc.status_code, content=error.model_dump())


async def generic_exception_handler(request: Request, exc: Exception):
    logger.error("Error no controlado en %s: %s", request.url.path, exc, exc_info=True)
    error = ErrorResponse(
        codigo="error_servidor",
        mensaje="Ocurrio un error inesperado en el servidor.",
        tipo="servidor",
    )
    return JSONResponse(status_code=500, content=error.model_dump())
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca008_errores\handlers.py") -Content $content_err_handlers

    $content_err_graphql = @'
import strawberry
from graphql import GraphQLError

from .logging_config import logger


class ErrorAcademico(GraphQLError):
    # Version GraphQL del formato de ErrorResponse (codigo/mensaje/tipo) que
    # usan los exception handlers REST, expuesta via "extensions" ya que
    # GraphQL no tiene un canal de respuesta de error separado del body.
    def __init__(self, mensaje: str, codigo: str = "error_aplicacion", tipo: str = "aplicacion"):
        super().__init__(mensaje, extensions={"codigo": codigo, "tipo": tipo})


class NoAutorizadoGraphQLError(ErrorAcademico):
    def __init__(self, mensaje: str = "No autorizado"):
        super().__init__(mensaje, codigo="no_autorizado", tipo="autenticacion")


class PermisoDenegadoGraphQLError(ErrorAcademico):
    def __init__(self, mensaje: str = "Permiso denegado"):
        super().__init__(mensaje, codigo="permiso_denegado", tipo="autorizacion")


class RecursoNoEncontradoGraphQLError(ErrorAcademico):
    def __init__(self, mensaje: str = "Recurso no encontrado"):
        super().__init__(mensaje, codigo="recurso_no_encontrado", tipo="no_encontrado")


class AcademicoSchema(strawberry.Schema):
    def process_errors(self, errors, execution_context=None):
        for error in errors:
            logger.error("Error GraphQL: %s", error)
        super().process_errors(errors, execution_context)
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca008_errores\graphql_errors.py") -Content $content_err_graphql

    $content_fe_errorsnackbar = @'
import { Snackbar, Alert } from "@mui/material";

export default function ErrorSnackbar({ open, message, onClose, severity = "error" }) {
  return (
    <Snackbar open={open} autoHideDuration={5000} onClose={onClose} anchorOrigin={{ vertical: "top", horizontal: "center" }}>
      <Alert onClose={onClose} severity={severity} variant="filled" sx={{ width: "100%" }}>
        {message}
      </Alert>
    </Snackbar>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\errors\ErrorSnackbar.jsx") -Content $content_fe_errorsnackbar

    $content_fe_useerrorhandler = @'
import { useState } from "react";

export function useErrorHandler() {
  const [error, setError] = useState("");

  const showError = (message) => setError(message);
  const clearError = () => setError("");

  return { error, showError, clearError };
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\errors\useErrorHandler.js") -Content $content_fe_useerrorhandler

    # CA-009 - Registro de Auditoria
    Write-Host ""
    Write-Host "--- CA-009: Registro de Auditoria ---" -ForegroundColor Cyan
    $content_audit_models = @'
from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, JSON
from core.ca005_db.database import Base


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    usuario_correo = Column(String, nullable=False)
    recurso = Column(String, nullable=False)
    accion = Column(String, nullable=False)
    valores_anteriores = Column(JSON, nullable=True)
    valores_nuevos = Column(JSON, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False)
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca009_auditoria\models.py") -Content $content_audit_models

    $content_audit_schemas = @'
from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel


class AuditLogResponse(BaseModel):
    id: int
    usuario_correo: str
    recurso: str
    accion: str
    valores_anteriores: Optional[Any] = None
    valores_nuevos: Optional[Any] = None
    timestamp: datetime

    class Config:
        from_attributes = True
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca009_auditoria\schemas.py") -Content $content_audit_schemas

    $content_audit_services = @'
import csv
import io
from datetime import datetime, timedelta
from typing import Any, Optional
from sqlalchemy.orm import Session
from .models import AuditLog


def registrar_auditoria(
    db: Session,
    usuario: str,
    recurso: str,
    accion: str,
    valores_anteriores: Optional[Any] = None,
    valores_nuevos: Optional[Any] = None,
) -> AuditLog:
    entrada = AuditLog(
        usuario_correo=usuario,
        recurso=recurso,
        accion=accion,
        valores_anteriores=valores_anteriores,
        valores_nuevos=valores_nuevos,
    )
    db.add(entrada)
    db.commit()
    db.refresh(entrada)
    return entrada


def listar_auditoria(
    db: Session,
    recurso: Optional[str] = None,
    usuario_correo: Optional[str] = None,
    limite: int = 50,
) -> list[AuditLog]:
    query = db.query(AuditLog)
    if recurso:
        query = query.filter(AuditLog.recurso == recurso)
    if usuario_correo:
        query = query.filter(AuditLog.usuario_correo == usuario_correo)
    return query.order_by(AuditLog.timestamp.desc()).limit(limite).all()


def purgar_auditoria_antigua(db: Session, dias: int) -> int:
    limite = datetime.utcnow() - timedelta(days=dias)
    eliminados = db.query(AuditLog).filter(AuditLog.timestamp < limite).delete(synchronize_session=False)
    db.commit()
    return eliminados


def exportar_auditoria_csv(
    db: Session,
    recurso: Optional[str] = None,
    usuario_correo: Optional[str] = None,
) -> str:
    query = db.query(AuditLog)
    if recurso:
        query = query.filter(AuditLog.recurso == recurso)
    if usuario_correo:
        query = query.filter(AuditLog.usuario_correo == usuario_correo)
    registros = query.order_by(AuditLog.timestamp.desc()).all()

    buffer = io.StringIO()
    writer = csv.writer(buffer)
    writer.writerow(["id", "usuario_correo", "recurso", "accion", "valores_anteriores", "valores_nuevos", "timestamp"])
    for r in registros:
        writer.writerow([r.id, r.usuario_correo, r.recurso, r.accion, r.valores_anteriores, r.valores_nuevos, r.timestamp.isoformat()])
    return buffer.getvalue()
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca009_auditoria\services.py") -Content $content_audit_services

    $content_audit_router = @'
import io
from typing import List, Optional
from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from . import schemas, services
from core.ca005_db.session import get_db
from core.ca003_roles.dependencies import requiere_rol
from core.ca010_config.settings import settings

router = APIRouter(prefix="/auditoria", tags=["Auditoria"])


@router.get("/", response_model=List[schemas.AuditLogResponse])
def listar_auditoria(
    recurso: Optional[str] = None,
    usuario_correo: Optional[str] = None,
    limite: int = 50,
    db: Session = Depends(get_db),
    token=Depends(requiere_rol("administrador")),
):
    return services.listar_auditoria(db, recurso, usuario_correo, limite)


@router.get("/exportar")
def exportar_auditoria(
    recurso: Optional[str] = None,
    usuario_correo: Optional[str] = None,
    db: Session = Depends(get_db),
    token=Depends(requiere_rol("administrador")),
):
    contenido = services.exportar_auditoria_csv(db, recurso, usuario_correo)
    return StreamingResponse(
        io.StringIO(contenido),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=auditoria.csv"},
    )


@router.post("/purgar")
def purgar_auditoria(
    dias: Optional[int] = None,
    db: Session = Depends(get_db),
    token=Depends(requiere_rol("administrador")),
):
    periodo = dias if dias is not None else settings.audit_retention_days
    eliminados = services.purgar_auditoria_antigua(db, periodo)
    return {"eliminados": eliminados, "dias_retencion": periodo}
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca009_auditoria\router.py") -Content $content_audit_router

    # CA-010 - Configuracion del Entorno
    Write-Host ""
    Write-Host "--- CA-010: Configuracion del Entorno ---" -ForegroundColor Cyan
    $content_settings = @'
# Modulo centralizado de configuracion (CA-010). El resto del proyecto
# (ca001_auth/security.py, ca005_db/database.py) sigue usando os.getenv()
# + load_dotenv() directamente; no se migro ese codigo existente a este
# modulo para no forzar un refactor fuera del alcance de este Core Asset.
# El codigo nuevo debe preferir "settings" en vez de os.getenv() suelto.
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg2://postgres:postgres@localhost:5432/academico_db"
    jwt_secret_key: str = "super_secret_key_123"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30
    cors_origins: str = "http://localhost:5173"
    environment: str = "development"
    log_level: str = "INFO"
    audit_retention_days: int = 365

    @property
    def cors_origins_list(self) -> list[str]:
        return [origen.strip() for origen in self.cors_origins.split(",") if origen.strip()]


settings = Settings()
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "core\ca010_config\settings.py") -Content $content_settings

    $content_env_dev_example = @'
DB_HOST=localhost
DB_PORT=5432
DB_NAME=academico_db
DB_USER=postgres
DB_PASSWORD=postgres
DATABASE_URL=postgresql+psycopg2://postgres:postgres@localhost:5432/academico_db

JWT_SECRET_KEY=<genera_una_clave_secreta_aleatoria>
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

ROLE_ADMIN=administrador
ROLE_DOCENTE=docente

CORS_ORIGINS=http://localhost:5173
ENVIRONMENT=development
LOG_LEVEL=DEBUG
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR ".env.development.example") -Content $content_env_dev_example

    $content_env_prod_example = @'
DB_HOST=<host_de_produccion>
DB_PORT=5432
DB_NAME=academico_db
DB_USER=<usuario_produccion>
DB_PASSWORD=<password_produccion>
DATABASE_URL=postgresql+psycopg2://<usuario_produccion>:<password_produccion>@<host_de_produccion>:5432/academico_db

JWT_SECRET_KEY=<genera_una_clave_secreta_aleatoria_larga>
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

ROLE_ADMIN=administrador
ROLE_DOCENTE=docente

CORS_ORIGINS=<https://tu-dominio>
ENVIRONMENT=production
LOG_LEVEL=WARNING
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR ".env.production.example") -Content $content_env_prod_example

    $content_fe_env_example = @'
VITE_API_URL=http://localhost:8000
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR ".env.example") -Content $content_fe_env_example

    # CA-011 - DevOps Templates
    Write-Host ""
    Write-Host "--- CA-011: DevOps Templates ---" -ForegroundColor Cyan
    $content_requirements = @'
fastapi
uvicorn[standard]
python-jose[cryptography]
passlib
bcrypt==3.2.0
python-multipart
sqlalchemy
psycopg2-binary
asyncpg
python-dotenv
email-validator
strawberry-graphql[fastapi]
pydantic-settings
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "requirements.txt") -Content $content_requirements

    $content_backend_dockerfile = @'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "Dockerfile") -Content $content_backend_dockerfile

    $content_frontend_dockerfile = @'
FROM node:20-alpine AS build
WORKDIR /app
ARG VITE_API_URL=http://localhost:8000
ENV VITE_API_URL=$VITE_API_URL
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "Dockerfile") -Content $content_frontend_dockerfile

    $content_nginx_conf = @'
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "nginx.conf") -Content $content_nginx_conf

    $content_docker_compose = @'
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: academico_db
    ports:
      - "5433:5432"
    volumes:
      - db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 10

  backend:
    build: ./backend
    depends_on:
      db:
        condition: service_healthy
    environment:
      DATABASE_URL: postgresql+psycopg2://postgres:postgres@db:5432/academico_db
      JWT_SECRET_KEY: cambia_esta_clave_en_produccion
      JWT_ALGORITHM: HS256
      JWT_ACCESS_TOKEN_EXPIRE_MINUTES: "30"
      CORS_ORIGINS: http://localhost:5174
      ENVIRONMENT: development
      LOG_LEVEL: INFO
    ports:
      - "8001:8000"

  frontend:
    build:
      context: ./frontend
      args:
        VITE_API_URL: http://localhost:8001
    depends_on:
      - backend
    ports:
      - "5174:80"

volumes:
  db_data:
'@
    Write-SkeletonFile -FilePath (Join-Path $PROJECT_ROOT "docker-compose.yml") -Content $content_docker_compose

    $content_ci_workflow = @'
name: CI

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]

jobs:
  backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install -r requirements.txt
      # No hay suite de tests todavia; compileall sirve como chequeo minimo
      # de que todos los modulos importan sin errores de sintaxis.
      - run: python -m compileall .

  frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
      - run: npm install
      - run: npm run lint
      - run: npm run build
'@
    Write-SkeletonFile -FilePath (Join-Path $PROJECT_ROOT ".github\workflows\ci.yml") -Content $content_ci_workflow

    $content_cd_workflow = @'
# Plantilla de despliegue continuo. NO es funcional tal cual: requiere
# configurar los secrets del repositorio (registro de contenedores,
# credenciales del servidor/orquestador destino) antes de poder desplegar
# a un ambiente real. Se deja como punto de partida para que cada producto
# derivado la complete segun su infraestructura (Docker Hub, GHCR, K8s, etc.).
name: CD

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build backend image
        run: docker build -t academico-backend:${{ github.sha }} ./backend

      - name: Build frontend image
        run: docker build -t academico-frontend:${{ github.sha }} ./frontend

      # - name: Login al registro de contenedores
      #   run: echo "${{ secrets.REGISTRY_PASSWORD }}" | docker login <registry> -u "${{ secrets.REGISTRY_USER }}" --password-stdin
      # - name: Push de imagenes
      #   run: |
      #     docker push <registry>/academico-backend:${{ github.sha }}
      #     docker push <registry>/academico-frontend:${{ github.sha }}
      # - name: Deploy a staging/produccion
      #   run: echo "Agregar aqui el paso de despliegue especifico del ambiente destino"
'@
    Write-SkeletonFile -FilePath (Join-Path $PROJECT_ROOT ".github\workflows\cd.yml") -Content $content_cd_workflow

    $content_eslint_config = @'
import js from "@eslint/js";
import react from "eslint-plugin-react";
import reactHooks from "eslint-plugin-react-hooks";
import globals from "globals";

export default [
  { ignores: ["dist"] },
  js.configs.recommended,
  {
    files: ["**/*.{js,jsx}"],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        ecmaFeatures: { jsx: true },
        sourceType: "module",
      },
    },
    plugins: {
      react,
      "react-hooks": reactHooks,
    },
    rules: {
      ...react.configs.recommended.rules,
      ...reactHooks.configs.recommended.rules,
      "react/react-in-jsx-scope": "off",
      "react/prop-types": "off",
      // Restaurar sesion desde localStorage al montar es un patron valido
      // y comun para bootstrap de auth; se baja a warning en vez de error.
      "react-hooks/set-state-in-effect": "warn",
    },
    settings: { react: { version: "detect" } },
  },
];
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "eslint.config.js") -Content $content_eslint_config

    # main.py y env
    Write-Host ""
    Write-Host "--- main.py: Punto de entrada ---" -ForegroundColor Cyan
    $content_main = @'
﻿from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from strawberry.fastapi import GraphQLRouter
from sqlalchemy.orm import Session

from core.ca001_auth.router import router as auth_router
from core.ca002_usuarios.router import router as usuarios_router
from core.ca003_roles.router import router as roles_router
from core.ca009_auditoria.router import router as auditoria_router
from core.ca006_graphql.schema import schema
from core.ca005_db.database import engine, Base, SessionLocal
from core.ca008_errores.handlers import (
    validation_exception_handler,
    http_exception_handler,
    app_exception_handler,
    generic_exception_handler,
)
from core.ca008_errores.exceptions import AppException
from core.ca008_errores.logging_config import configurar_logging
from core.ca010_config.settings import settings

configurar_logging()

app = FastAPI(title="Sistema de Gestion Academica - LPS", version="0.1.0")

app.add_exception_handler(RequestValidationError, validation_exception_handler)
app.add_exception_handler(StarletteHTTPException, http_exception_handler)
app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

@app.on_event("startup")
def startup_event():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        from core.ca005_db.models import Usuario
        from core.ca009_auditoria.models import AuditLog
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
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(usuarios_router)
app.include_router(roles_router)
app.include_router(auditoria_router)
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
DB_PASSWORD=<tu_password>
DATABASE_URL=postgresql+psycopg2://postgres:<tu_password>@localhost:5432/academico_db

JWT_SECRET_KEY=<genera_una_clave_secreta_aleatoria>
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

ROLE_ADMIN=administrador
ROLE_DOCENTE=docente

CORS_ORIGINS=http://localhost:5173
ENVIRONMENT=development
LOG_LEVEL=INFO
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR ".env.example") -Content $content_env_example


    # Frontend
    Write-Host ""
    Write-Host "--- Frontend ---" -ForegroundColor Cyan

    $content_fe_client = @'
import { ApolloClient, InMemoryCache, createHttpLink } from "@apollo/client";
import { setContext } from "@apollo/client/link/context";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:8000";
const httpLink = createHttpLink({ uri: `${API_URL}/graphql` });
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

export const LOGOUT_MUTATION = gql`
  mutation Logout {
    logout
  }
`;

// --- Estudiantes ---

export const GET_ESTUDIANTES = gql`
  query GetEstudiantes { estudiantes(limite: 200) { id nombre codigo correo datos_contacto } }
`;

export const CREAR_ESTUDIANTE = gql`
  mutation CrearEstudiante($datos: EstudianteInput!) {
    crear_estudiante(datos: $datos) { id nombre codigo correo datos_contacto }
  }
`;

export const ACTUALIZAR_ESTUDIANTE = gql`
  mutation ActualizarEstudiante($id: Int!, $datos: EstudianteUpdateInput!) {
    actualizar_estudiante(id: $id, datos: $datos) { id nombre codigo correo datos_contacto }
  }
`;

export const ELIMINAR_ESTUDIANTE = gql`
  mutation EliminarEstudiante($id: Int!) {
    eliminar_estudiante(id: $id) { id }
  }
`;

// --- Docentes ---

export const GET_DOCENTES = gql`
  query GetDocentes { docentes(limite: 200) { id nombre correo especialidad } }
`;

export const CREAR_DOCENTE = gql`
  mutation CrearDocente($datos: DocenteInput!) {
    crear_docente(datos: $datos) { id nombre correo especialidad }
  }
`;

export const ACTUALIZAR_DOCENTE = gql`
  mutation ActualizarDocente($id: Int!, $datos: DocenteUpdateInput!) {
    actualizar_docente(id: $id, datos: $datos) { id nombre correo especialidad }
  }
`;

export const ELIMINAR_DOCENTE = gql`
  mutation EliminarDocente($id: Int!) {
    eliminar_docente(id: $id) { id }
  }
`;

// --- Cursos ---

export const GET_CURSOS = gql`
  query GetCursos { cursos(limite: 200) { id nombre docente_id periodo_academico } }
`;

export const CREAR_CURSO = gql`
  mutation CrearCurso($datos: CursoInput!) {
    crear_curso(datos: $datos) { id nombre docente_id periodo_academico }
  }
`;

export const ACTUALIZAR_CURSO = gql`
  mutation ActualizarCurso($id: Int!, $datos: CursoUpdateInput!) {
    actualizar_curso(id: $id, datos: $datos) { id nombre docente_id periodo_academico }
  }
`;

export const ELIMINAR_CURSO = gql`
  mutation EliminarCurso($id: Int!) {
    eliminar_curso(id: $id) { id }
  }
`;

// --- Inscripciones ---

export const GET_INSCRIPCIONES = gql`
  query GetInscripciones { inscripciones(limite: 200) { id estudiante_id curso_id estado } }
`;

export const CREAR_INSCRIPCION = gql`
  mutation CrearInscripcion($datos: InscripcionInput!) {
    crear_inscripcion(datos: $datos) { id estudiante_id curso_id estado }
  }
`;

export const ACTUALIZAR_INSCRIPCION = gql`
  mutation ActualizarInscripcion($id: Int!, $datos: InscripcionUpdateInput!) {
    actualizar_inscripcion(id: $id, datos: $datos) { id estudiante_id curso_id estado }
  }
`;

export const ELIMINAR_INSCRIPCION = gql`
  mutation EliminarInscripcion($id: Int!) {
    eliminar_inscripcion(id: $id) { id }
  }
`;
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\graphql\operations.js") -Content $content_fe_ops

    $content_fe_theme = @'
import { createTheme } from "@mui/material/styles";

// Sistema de Gestion Academica -- direccion "Acta Academica":
// la identidad visual del libro de actas y la cedula institucional,
// no la de un dashboard SaaS generico. Paleta fria de papel de archivo,
// tinta azul-marino, un oro institucional como unico acento vivo, y un
// rojo-oxido reservado exclusivamente para estados negativos.
const ink = "#141B2E";
const inkMuted = "#565F55";
const paper = "#EEF0EA";
const paperElevated = "#F8F9F4";
const gold = "#B8872B";
const goldDark = "#8E6A20";
const sage = "#4F6B4A";
const rust = "#9C4632";
const line = "#D2D5C7";

export const academic = { ink, inkMuted, paper, paperElevated, gold, goldDark, sage, rust, line };

export const theme = createTheme({
  palette: {
    mode: "light",
    primary: { main: gold, dark: goldDark, contrastText: ink },
    secondary: { main: ink, contrastText: paperElevated },
    success: { main: sage },
    error: { main: rust },
    background: { default: paper, paper: paperElevated },
    text: { primary: ink, secondary: inkMuted },
    divider: line,
  },
  shape: { borderRadius: 3 },
  typography: {
    fontFamily: '"IBM Plex Sans", "Helvetica Neue", Arial, sans-serif',
    h1: { fontFamily: '"Fraunces", serif', fontWeight: 600 },
    h2: { fontFamily: '"Fraunces", serif', fontWeight: 600 },
    h3: { fontFamily: '"Fraunces", serif', fontWeight: 600, letterSpacing: "-0.01em" },
    h4: { fontFamily: '"Fraunces", serif', fontWeight: 600, letterSpacing: "-0.01em" },
    h5: { fontFamily: '"Fraunces", serif', fontWeight: 500, fontStyle: "italic" },
    h6: { fontFamily: '"Fraunces", serif', fontWeight: 500 },
    subtitle1: { fontFamily: '"IBM Plex Sans", sans-serif', color: inkMuted },
    subtitle2: { fontFamily: '"IBM Plex Sans", sans-serif', color: inkMuted, fontWeight: 500 },
    button: { fontFamily: '"IBM Plex Sans", sans-serif', fontWeight: 600, letterSpacing: "0.05em" },
    overline: { fontFamily: '"IBM Plex Mono", monospace', letterSpacing: "0.08em" },
    caption: { fontFamily: '"IBM Plex Mono", monospace' },
  },
  components: {
    MuiCssBaseline: {
      styleOverrides: {
        body: { backgroundColor: paper },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: ink,
          color: paperElevated,
          boxShadow: "none",
          borderBottom: `2px solid ${gold}`,
        },
      },
    },
    MuiDrawer: {
      styleOverrides: {
        paper: {
          backgroundColor: paperElevated,
          borderRight: `1px solid ${line}`,
          boxShadow: "none",
        },
      },
    },
    MuiListItemButton: {
      styleOverrides: {
        root: {
          borderRadius: 0,
          borderLeft: "3px solid transparent",
          paddingTop: 10,
          paddingBottom: 10,
          "&:hover": { backgroundColor: "rgba(20,27,46,0.04)" },
          "&.Mui-selected": {
            borderLeft: `3px solid ${gold}`,
            backgroundColor: "rgba(184,135,43,0.08)",
          },
          "&.Mui-selected:hover": { backgroundColor: "rgba(184,135,43,0.12)" },
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 3,
          boxShadow: "none",
          textTransform: "uppercase",
          paddingTop: 10,
          paddingBottom: 10,
        },
        contained: {
          boxShadow: "none",
          "&:hover": { boxShadow: "none" },
        },
        outlined: { borderWidth: 1.5, "&:hover": { borderWidth: 1.5 } },
      },
    },
    MuiPaper: {
      styleOverrides: {
        root: { backgroundImage: "none" },
        outlined: { borderColor: line },
        elevation1: { boxShadow: "none", border: `1px solid ${line}` },
      },
    },
    MuiTableCell: {
      styleOverrides: {
        root: { borderBottom: `1px solid ${line}`, padding: "14px 16px" },
        head: {
          fontFamily: '"IBM Plex Mono", monospace',
          fontSize: "0.72rem",
          letterSpacing: "0.07em",
          textTransform: "uppercase",
          color: inkMuted,
          borderBottom: `2px solid ${ink}`,
        },
      },
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: 3,
          "& fieldset": { borderColor: line },
          "&:hover fieldset": { borderColor: inkMuted },
          "&.Mui-focused fieldset": { borderColor: gold, borderWidth: 1.5 },
        },
      },
    },
  },
});
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\theme.js") -Content $content_fe_theme

    $content_fe_pageheader = @'
import { Box, Typography } from "@mui/material";
import { academic } from "../../theme";

// Encabezado de seccion con el tratamiento de "libro de actas": un
// eyebrow en mono, el titulo en Fraunces, y una doble regla debajo
// (una fina y una gruesa) como en el encabezado de una hoja de registro.
export default function PageHeader({ eyebrow, title, action }) {
  return (
    <Box sx={{ mb: 4 }}>
      <Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between", flexWrap: "wrap", gap: 2 }}>
        <Box>
          {eyebrow && (
            <Typography
              variant="overline"
              sx={{ color: academic.gold, display: "block", mb: 0.5, fontWeight: 500 }}
            >
              {eyebrow}
            </Typography>
          )}
          <Typography variant="h4">{title}</Typography>
        </Box>
        {action}
      </Box>
      <Box sx={{ mt: 1.5, height: 3, borderTop: `1px solid ${academic.line}`, borderBottom: `2px solid ${academic.ink}` }} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\design-system\components\PageHeader.jsx") -Content $content_fe_pageheader

    $content_fe_statusstamp = @'
import { Box } from "@mui/material";
import { academic } from "../../theme";

const ESTADOS = {
  activa: { label: "Activa", color: academic.sage },
  cerrada: { label: "Cerrada", color: academic.inkMuted },
  cupo_lleno: { label: "Cupo lleno", color: academic.rust },
};

// El elemento firma del sistema: un badge de estado con la forma de un
// sello de tinta -- doble borde, esquinas casi rectas, una leve
// inclinacion -- en vez del chip solido y plano de un dashboard tipico.
export default function StatusStamp({ estado }) {
  const info = ESTADOS[estado] || { label: estado, color: academic.inkMuted };
  return (
    <Box
      component="span"
      sx={{
        display: "inline-flex",
        alignItems: "center",
        fontFamily: '"IBM Plex Mono", monospace',
        fontSize: "0.7rem",
        fontWeight: 500,
        letterSpacing: "0.06em",
        textTransform: "uppercase",
        color: info.color,
        border: `1.5px solid ${info.color}`,
        borderRadius: "2px",
        padding: "3px 10px",
        transform: "rotate(-1.5deg)",
        boxShadow: `0 0 0 1px ${info.color}33 inset`,
      }}
    >
      {info.label}
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\design-system\components\StatusStamp.jsx") -Content $content_fe_statusstamp

    $content_fe_confirmdialog = @'
import { Dialog, DialogTitle, DialogContent, DialogContentText, DialogActions, Button } from "@mui/material";
import { academic } from "../../theme";

export default function ConfirmDialog({ open, title, message, onConfirm, onCancel, confirmLabel = "Eliminar" }) {
  return (
    <Dialog open={open} onClose={onCancel} maxWidth="xs" fullWidth>
      <DialogTitle>{title}</DialogTitle>
      <DialogContent>
        <DialogContentText>{message}</DialogContentText>
      </DialogContent>
      <DialogActions sx={{ px: 3, pb: 2.5 }}>
        <Button onClick={onCancel} color="inherit">Cancelar</Button>
        <Button onClick={onConfirm} variant="contained" sx={{ bgcolor: academic.rust, "&:hover": { bgcolor: academic.rust } }}>
          {confirmLabel}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\design-system\components\ConfirmDialog.jsx") -Content $content_fe_confirmdialog

    $content_fe_auth_ctx = @'
﻿import { createContext, useContext, useState, useEffect } from "react";
import { client } from "../graphql/client";
import { LOGOUT_MUTATION } from "../graphql/operations";
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
  const logout = async () => {
    try {
      await client.mutate({ mutation: LOGOUT_MUTATION });
    } catch {
      // El token puede ya haber expirado o ser invalido; de todas formas
      // se limpia la sesion localmente.
    }
    await client.clearStore();
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
import { useNavigate, Link as RouterLink } from "react-router-dom";
import { Button, TextField, Box, Typography, Paper, Link } from "@mui/material";
import { LOGIN_MUTATION } from "../graphql/operations";
import { useAuth } from "./AuthContext";
import { validateEmail, validateRequired, ERROR_MESSAGES } from "../utils/validation";
import { useErrorHandler } from "../errors/useErrorHandler";
import ErrorSnackbar from "../errors/ErrorSnackbar";
import { academic } from "../theme";

export default function LoginPage() {
  const [correo, setCorreo] = useState("");
  const [pass, setPass] = useState("");
  const [formError, setFormError] = useState("");
  const [loginMutation] = useMutation(LOGIN_MUTATION);
  const { login } = useAuth();
  const navigate = useNavigate();
  const { error, showError, clearError } = useErrorHandler();

  const handleLogin = async (e) => {
    e.preventDefault();
    setFormError("");
    if (!validateRequired(correo) || !validateEmail(correo)) {
      setFormError(ERROR_MESSAGES.formatoEmailInvalido);
      return;
    }
    if (!validateRequired(pass)) {
      setFormError(ERROR_MESSAGES.campoRequerido);
      return;
    }
    try {
      const { data } = await loginMutation({ variables: { correo, contrasena: pass } });
      login(data.login.token, data.login.usuario);
      navigate("/");
    } catch (err) { showError(err.message); }
  };

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        bgcolor: academic.ink,
        px: 2,
      }}
    >
      <Paper
        elevation={0}
        sx={{
          width: "100%",
          maxWidth: 420,
          p: 5,
          pt: 4.5,
          borderTop: `4px solid ${academic.gold}`,
          bgcolor: academic.paperElevated,
        }}
      >
        <Typography variant="overline" sx={{ color: academic.gold, fontWeight: 500, textAlign: "center", display: "block" }}>
          Acceso institucional
        </Typography>
        <Typography variant="h4" sx={{ mt: 0.5, mb: 0.5, textAlign: "center" }}>
          Iniciar sesion
        </Typography>
        <Typography variant="subtitle1" sx={{ mb: 4 }}>
          Ingresa tus credenciales para acceder al sistema.
        </Typography>

        <form onSubmit={handleLogin} noValidate>
          <Typography variant="caption" sx={{ color: academic.inkMuted, letterSpacing: "0.06em" }}>
            CORREO INSTITUCIONAL
          </Typography>
          <TextField
            fullWidth
            margin="dense"
            placeholder="nombre@academico.com"
            value={correo}
            onChange={(e) => setCorreo(e.target.value)}
            error={!!formError}
            sx={{ mb: 2.5 }}
          />
          <Typography variant="caption" sx={{ color: academic.inkMuted, letterSpacing: "0.06em" }}>
            CONTRASENA
          </Typography>
          <TextField
            fullWidth
            margin="dense"
            type="password"
            value={pass}
            onChange={(e) => setPass(e.target.value)}
            error={!!formError}
            helperText={formError}
          />
          <Button fullWidth variant="contained" type="submit" size="large" sx={{ mt: 3.5 }}>
            Entrar
          </Button>
        </form>

        <Typography variant="body2" sx={{ mt: 3, textAlign: "center" }}>
          <Link component={RouterLink} to="/registro" sx={{ color: academic.gold }}>
            No tengo cuenta, registrarme
          </Link>
        </Typography>
      </Paper>
      <ErrorSnackbar open={!!error} message={error} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\auth\LoginPage.jsx") -Content $content_fe_login

    $content_fe_register = @'
import { useState } from "react";
import { Link as RouterLink, useNavigate } from "react-router-dom";
import { Button, TextField, Box, Typography, Paper, Link } from "@mui/material";
import { validateEmail, validateRequired, validatePasswordStrength, ERROR_MESSAGES } from "../utils/validation";
import { useErrorHandler } from "../errors/useErrorHandler";
import ErrorSnackbar from "../errors/ErrorSnackbar";
import { apiFetch } from "../utils/apiClient";
import { academic } from "../theme";

export default function RegisterPage() {
  const [correo, setCorreo] = useState("");
  const [pass, setPass] = useState("");
  const [formError, setFormError] = useState("");
  const [exito, setExito] = useState(false);
  const { error, showError, clearError } = useErrorHandler();
  const navigate = useNavigate();

  const handleRegister = async (e) => {
    e.preventDefault();
    setFormError("");
    if (!validateRequired(correo) || !validateEmail(correo)) {
      setFormError(ERROR_MESSAGES.formatoEmailInvalido);
      return;
    }
    if (!validatePasswordStrength(pass)) {
      setFormError(ERROR_MESSAGES.passwordDebil);
      return;
    }
    try {
      await apiFetch("/auth/register", {
        method: "POST",
        body: JSON.stringify({ correo, contrasena: pass }),
      });
      setExito(true);
      setTimeout(() => navigate("/login"), 1500);
    } catch (err) {
      showError(err.message);
    }
  };

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        bgcolor: academic.ink,
        px: 2,
      }}
    >
      <Paper
        elevation={0}
        sx={{
          width: "100%",
          maxWidth: 420,
          p: 5,
          pt: 4.5,
          borderTop: `4px solid ${academic.gold}`,
          bgcolor: academic.paperElevated,
        }}
      >
        <Typography variant="overline" sx={{ color: academic.gold, fontWeight: 500, textAlign: "center", display: "block" }}>
          Acceso institucional
        </Typography>
        <Typography variant="h4" sx={{ mt: 0.5, mb: 0.5, textAlign: "center" }}>
          Crear cuenta
        </Typography>
        <Typography variant="subtitle1" sx={{ mb: 4 }}>
          El registro publico crea una cuenta con rol docente.
        </Typography>

        {exito ? (
          <Typography sx={{ color: academic.sage, textAlign: "center" }}>
            Cuenta creada. Redirigiendo al inicio de sesion...
          </Typography>
        ) : (
          <form onSubmit={handleRegister} noValidate>
            <Typography variant="caption" sx={{ color: academic.inkMuted, letterSpacing: "0.06em" }}>
              CORREO INSTITUCIONAL
            </Typography>
            <TextField
              fullWidth
              margin="dense"
              placeholder="nombre@academico.com"
              value={correo}
              onChange={(e) => setCorreo(e.target.value)}
              error={!!formError}
              sx={{ mb: 2.5 }}
            />
            <Typography variant="caption" sx={{ color: academic.inkMuted, letterSpacing: "0.06em" }}>
              CONTRASENA
            </Typography>
            <TextField
              fullWidth
              margin="dense"
              type="password"
              value={pass}
              onChange={(e) => setPass(e.target.value)}
              error={!!formError}
              helperText={formError || ERROR_MESSAGES.passwordDebil}
            />
            <Button fullWidth variant="contained" type="submit" size="large" sx={{ mt: 3.5 }}>
              Registrarme
            </Button>
          </form>
        )}

        <Typography variant="body2" sx={{ mt: 3, textAlign: "center" }}>
          <Link component={RouterLink} to="/login" sx={{ color: academic.gold }}>
            Ya tengo cuenta, iniciar sesion
          </Link>
        </Typography>
      </Paper>
      <ErrorSnackbar open={!!error} message={error} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\auth\RegisterPage.jsx") -Content $content_fe_register

    $content_fe_layout = @'
import { Box, Drawer, List, ListItem, ListItemButton, ListItemText, AppBar, Toolbar, Typography, Button } from "@mui/material";
import { useNavigate, useLocation, Outlet } from "react-router-dom";
import { useAuth } from "../../auth/AuthContext";
import { academic } from "../../theme";

const DRAWER_WIDTH = 248;

export default function Layout() {
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuth();
  if (!user) return <Outlet />;

  const menu = [
    { index: "01", text: "Estudiantes", path: "/estudiantes" },
    { index: "02", text: "Docentes", path: "/docentes" },
    { index: "03", text: "Cursos", path: "/cursos" },
    { index: "04", text: "Inscripciones", path: "/inscripciones" },
    ...(user.rol === "administrador"
      ? [
          { index: "05", text: "Roles", path: "/roles" },
          { index: "06", text: "Auditoria", path: "/auditoria" },
        ]
      : []),
  ];

  return (
    <Box sx={{ display: "flex" }}>
      <AppBar position="fixed" sx={{ zIndex: 1201 }}>
        <Toolbar sx={{ gap: 2 }}>
          <Typography
            variant="h6"
            onClick={() => navigate("/")}
            sx={{ flexGrow: 1, letterSpacing: "0.02em", cursor: "pointer", "&:hover": { opacity: 0.85 } }}
          >
            SGA <Box component="span" sx={{ color: academic.gold }}>·</Box> Sistema de Gestion Academica
          </Typography>
          <Typography
            sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.8rem", opacity: 0.85 }}
          >
            {user.correo}
          </Typography>
          <Button
            size="small"
            variant="outlined"
            onClick={() => { logout(); navigate("/login"); }}
            sx={{ color: academic.paperElevated, borderColor: "rgba(248,249,244,0.4)", "&:hover": { borderColor: academic.gold } }}
          >
            Salir
          </Button>
        </Toolbar>
      </AppBar>
      <Drawer
        variant="permanent"
        sx={{ width: DRAWER_WIDTH, flexShrink: 0, [`& .MuiDrawer-paper`]: { width: DRAWER_WIDTH, boxSizing: "border-box" } }}
      >
        <Toolbar />
        <Typography
          variant="overline"
          sx={{ px: 2.5, pt: 2.5, pb: 1, display: "block", color: academic.inkMuted }}
        >
          Indice
        </Typography>
        <List sx={{ px: 0 }}>
          {menu.map((m) => {
            const selected = location.pathname.startsWith(m.path);
            return (
              <ListItem key={m.text} disablePadding>
                <ListItemButton selected={selected} onClick={() => navigate(m.path)} sx={{ px: 2.5 }}>
                  <Typography
                    sx={{
                      fontFamily: '"IBM Plex Mono", monospace',
                      fontSize: "0.75rem",
                      color: selected ? academic.gold : academic.inkMuted,
                      mr: 1.5,
                      minWidth: 20,
                    }}
                  >
                    {m.index}
                  </Typography>
                  <ListItemText
                    primary={m.text}
                    slotProps={{ primary: { fontWeight: selected ? 600 : 400 } }}
                  />
                </ListItemButton>
              </ListItem>
            );
          })}
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 4, bgcolor: "background.default", minHeight: "100vh" }}>
        <Toolbar />
        <Outlet />
      </Box>
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\design-system\components\Layout.jsx") -Content $content_fe_layout

    $content_fe_estudiantes = @'
import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import {
  Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box,
  Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Stack,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/EditOutlined";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import PageHeader from "../../design-system/components/PageHeader";
import ConfirmDialog from "../../design-system/components/ConfirmDialog";
import ErrorSnackbar from "../../errors/ErrorSnackbar";
import { useErrorHandler } from "../../errors/useErrorHandler";
import { useFormValidation } from "../../utils/useFormValidation";
import { validateRequired, validateEmail, ERROR_MESSAGES } from "../../utils/validation";
import { GET_ESTUDIANTES, CREAR_ESTUDIANTE, ACTUALIZAR_ESTUDIANTE, ELIMINAR_ESTUDIANTE } from "../../graphql/operations";
import { useAuth } from "../../auth/AuthContext";

const VALORES_INICIALES = { nombre: "", codigo: "", correo: "", datos_contacto: "" };

const REGLAS = {
  nombre: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
  codigo: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
  correo: (v) => (validateEmail(v) ? null : ERROR_MESSAGES.formatoEmailInvalido),
};

export default function EstudiantesPage() {
  const { user } = useAuth();
  const esAdmin = user?.rol === "administrador";
  const { data, loading, error, refetch } = useQuery(GET_ESTUDIANTES);
  const { error: formError, showError, clearError } = useErrorHandler();
  const { values, errors, handleChange, validateAll, setValues } = useFormValidation(VALORES_INICIALES, REGLAS);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editando, setEditando] = useState(null);
  const [aEliminar, setAEliminar] = useState(null);

  const [crearEstudiante] = useMutation(CREAR_ESTUDIANTE);
  const [actualizarEstudiante] = useMutation(ACTUALIZAR_ESTUDIANTE);
  const [eliminarEstudiante] = useMutation(ELIMINAR_ESTUDIANTE);

  const abrirNuevo = () => {
    setEditando(null);
    setValues(VALORES_INICIALES);
    setDialogOpen(true);
  };

  const abrirEditar = (estudiante) => {
    setEditando(estudiante);
    setValues({
      nombre: estudiante.nombre,
      codigo: estudiante.codigo,
      correo: estudiante.correo,
      datos_contacto: estudiante.datos_contacto || "",
    });
    setDialogOpen(true);
  };

  const guardar = async () => {
    if (!validateAll()) return;
    try {
      if (editando) {
        await actualizarEstudiante({ variables: { id: editando.id, datos: values } });
      } else {
        await crearEstudiante({ variables: { datos: values } });
      }
      setDialogOpen(false);
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  const confirmarEliminar = async () => {
    const objetivo = aEliminar;
    setAEliminar(null);
    try {
      await eliminarEstudiante({ variables: { id: objetivo.id } });
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 01"
        title="Estudiantes"
        action={
          <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
            {data && (
              <Typography variant="caption" sx={{ color: "text.secondary", lineHeight: 1 }}>
                {data.estudiantes.length} matriculados
              </Typography>
            )}
            {esAdmin && (
              <Button size="small" variant="contained" startIcon={<AddIcon />} onClick={abrirNuevo}>
                Nuevo
              </Button>
            )}
          </Stack>
        }
      />

      {loading && <CircularProgress size={24} />}
      {error && <Typography color="error">Error: {error.message}</Typography>}

      {data && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell width={110}>Codigo</TableCell>
                <TableCell>Nombre</TableCell>
                <TableCell>Correo</TableCell>
                {esAdmin && <TableCell width={100} align="right">Acciones</TableCell>}
              </TableRow>
            </TableHead>
            <TableBody>
              {data.estudiantes.map((e) => (
                <TableRow key={e.id} hover>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.85rem" }}>
                    {e.codigo}
                  </TableCell>
                  <TableCell sx={{ fontWeight: 500 }}>{e.nombre}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{e.correo}</TableCell>
                  {esAdmin && (
                    <TableCell align="right">
                      <IconButton size="small" onClick={() => abrirEditar(e)}><EditIcon fontSize="small" /></IconButton>
                      <IconButton size="small" onClick={() => setAEliminar(e)}><DeleteIcon fontSize="small" /></IconButton>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>{editando ? "Editar estudiante" : "Nuevo estudiante"}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Nombre" value={values.nombre} onChange={handleChange("nombre")} error={!!errors.nombre} helperText={errors.nombre} fullWidth />
            <TextField label="Codigo" value={values.codigo} onChange={handleChange("codigo")} error={!!errors.codigo} helperText={errors.codigo} fullWidth disabled={!!editando} />
            <TextField label="Correo" value={values.correo} onChange={handleChange("correo")} error={!!errors.correo} helperText={errors.correo} fullWidth />
            <TextField label="Datos de contacto" value={values.datos_contacto} onChange={handleChange("datos_contacto")} fullWidth />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2.5 }}>
          <Button onClick={() => setDialogOpen(false)} color="inherit">Cancelar</Button>
          <Button onClick={guardar} variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={!!aEliminar}
        title="Eliminar estudiante"
        message={`Se dara de baja a "${aEliminar?.nombre}".`}
        onConfirm={confirmarEliminar}
        onCancel={() => setAEliminar(null)}
      />

      <ErrorSnackbar open={!!formError} message={formError} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\estudiantes\EstudiantesPage.jsx") -Content $content_fe_estudiantes

    $content_fe_main = @'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { ApolloProvider } from "@apollo/client"
import { ThemeProvider } from "@mui/material/styles"
import CssBaseline from "@mui/material/CssBaseline"
import { BrowserRouter } from "react-router-dom"
import "@fontsource/fraunces/500.css"
import "@fontsource/fraunces/600.css"
import "@fontsource/fraunces/600-italic.css"
import "@fontsource/ibm-plex-sans/400.css"
import "@fontsource/ibm-plex-sans/500.css"
import "@fontsource/ibm-plex-sans/600.css"
import "@fontsource/ibm-plex-mono/400.css"
import "@fontsource/ibm-plex-mono/500.css"
import App from './App'
import { client } from "./graphql/client"
import { theme } from "./theme"
import { AuthProvider } from "./auth/AuthContext"

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
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

    $content_fe_inicio = @'
import { Box, Typography, Paper } from "@mui/material";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../auth/AuthContext";
import { academic } from "../../theme";

const SECCIONES = [
  { index: "01", text: "Estudiantes", path: "/estudiantes", desc: "Matricula y datos de contacto" },
  { index: "02", text: "Docentes", path: "/docentes", desc: "Planta docente y especialidades" },
  { index: "03", text: "Cursos", path: "/cursos", desc: "Oferta academica por periodo" },
  { index: "04", text: "Inscripciones", path: "/inscripciones", desc: "Movimientos de matricula" },
];

const SECCIONES_ADMIN = [
  { index: "05", text: "Roles", path: "/roles", desc: "Roles del sistema y sus permisos" },
  { index: "06", text: "Auditoria", path: "/auditoria", desc: "Historial de acciones, exportacion y retencion" },
];

export default function InicioPage() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const secciones = user?.rol === "administrador" ? [...SECCIONES, ...SECCIONES_ADMIN] : SECCIONES;

  return (
    <Box>
      <Typography variant="overline" sx={{ color: academic.gold, fontWeight: 500 }}>
        Panel principal
      </Typography>
      <Typography variant="h3" sx={{ mt: 0.5 }}>
        Bienvenido
      </Typography>
      <Typography variant="subtitle1" sx={{ mt: 0.5, mb: 4 }}>
        Sesion iniciada como <strong>{user?.correo}</strong> &middot; rol {user?.rol}
      </Typography>

      <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", sm: "1fr 1fr" }, gap: 2 }}>
        {secciones.map((s) => (
          <Paper
            key={s.path}
            variant="outlined"
            onClick={() => navigate(s.path)}
            sx={{
              p: 2.5,
              cursor: "pointer",
              transition: "border-color 0.15s ease",
              "&:hover": { borderColor: academic.gold },
            }}
          >
            <Typography
              sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.75rem", color: academic.gold }}
            >
              {s.index}
            </Typography>
            <Typography variant="h6" sx={{ mt: 0.5 }}>{s.text}</Typography>
            <Typography variant="body2" sx={{ color: "text.secondary", mt: 0.25 }}>
              {s.desc}
            </Typography>
          </Paper>
        ))}
      </Box>
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\inicio\InicioPage.jsx") -Content $content_fe_inicio

    $content_fe_app = @'
﻿import { Routes, Route, Navigate } from "react-router-dom";
import LoginPage from "./auth/LoginPage";
import RegisterPage from "./auth/RegisterPage";
import Layout from "./design-system/components/Layout";
import InicioPage from "./modules/inicio/InicioPage";
import EstudiantesPage from "./modules/estudiantes/EstudiantesPage";
import DocentesPage from "./modules/docentes/DocentesPage";
import CursosPage from "./modules/cursos/CursosPage";
import InscripcionesPage from "./modules/inscripciones/InscripcionesPage";
import RolesPage from "./modules/roles/RolesPage";
import AuditoriaPage from "./modules/auditoria/AuditoriaPage";
import { useAuth } from "./auth/AuthContext";

function Protected({ children }) {
  const { user, loading } = useAuth();
  if (loading) return null;
  return user ? children : <Navigate to="/login" />;
}

function SoloAdmin({ children }) {
  const { user, loading } = useAuth();
  if (loading) return null;
  return user?.rol === "administrador" ? children : <Navigate to="/" />;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/registro" element={<RegisterPage />} />
      <Route path="/" element={<Protected><Layout /></Protected>}>
        <Route index element={<InicioPage />} />
        <Route path="estudiantes" element={<EstudiantesPage />} />
        <Route path="docentes" element={<DocentesPage />} />
        <Route path="cursos" element={<CursosPage />} />
        <Route path="inscripciones" element={<InscripcionesPage />} />
        <Route path="roles" element={<SoloAdmin><RolesPage /></SoloAdmin>} />
        <Route path="auditoria" element={<SoloAdmin><AuditoriaPage /></SoloAdmin>} />
      </Route>
    </Routes>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\App.jsx") -Content $content_fe_app

    # --- Frontend: Docentes, Cursos, Inscripciones ---
    $content_fe_docentes = @'
import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import {
  Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box,
  Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Stack,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/EditOutlined";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import PageHeader from "../../design-system/components/PageHeader";
import ConfirmDialog from "../../design-system/components/ConfirmDialog";
import ErrorSnackbar from "../../errors/ErrorSnackbar";
import { useErrorHandler } from "../../errors/useErrorHandler";
import { useFormValidation } from "../../utils/useFormValidation";
import { validateRequired, validateEmail, ERROR_MESSAGES } from "../../utils/validation";
import { GET_DOCENTES, CREAR_DOCENTE, ACTUALIZAR_DOCENTE, ELIMINAR_DOCENTE } from "../../graphql/operations";
import { useAuth } from "../../auth/AuthContext";

const VALORES_INICIALES = { nombre: "", correo: "", especialidad: "" };

const REGLAS = {
  nombre: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
  correo: (v) => (validateEmail(v) ? null : ERROR_MESSAGES.formatoEmailInvalido),
};

export default function DocentesPage() {
  const { user } = useAuth();
  const esAdmin = user?.rol === "administrador";
  const { data, loading, error, refetch } = useQuery(GET_DOCENTES);
  const { error: formError, showError, clearError } = useErrorHandler();
  const { values, errors, handleChange, validateAll, setValues } = useFormValidation(VALORES_INICIALES, REGLAS);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editando, setEditando] = useState(null);
  const [aEliminar, setAEliminar] = useState(null);

  const [crearDocente] = useMutation(CREAR_DOCENTE);
  const [actualizarDocente] = useMutation(ACTUALIZAR_DOCENTE);
  const [eliminarDocente] = useMutation(ELIMINAR_DOCENTE);

  const abrirNuevo = () => {
    setEditando(null);
    setValues(VALORES_INICIALES);
    setDialogOpen(true);
  };

  const abrirEditar = (docente) => {
    setEditando(docente);
    setValues({ nombre: docente.nombre, correo: docente.correo, especialidad: docente.especialidad || "" });
    setDialogOpen(true);
  };

  const guardar = async () => {
    if (!validateAll()) return;
    try {
      if (editando) {
        await actualizarDocente({ variables: { id: editando.id, datos: values } });
      } else {
        await crearDocente({ variables: { datos: values } });
      }
      setDialogOpen(false);
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  const confirmarEliminar = async () => {
    const objetivo = aEliminar;
    setAEliminar(null);
    try {
      await eliminarDocente({ variables: { id: objetivo.id } });
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 02"
        title="Docentes"
        action={
          <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
            {data && (
              <Typography variant="caption" sx={{ color: "text.secondary", lineHeight: 1 }}>
                {data.docentes.length} en planta
              </Typography>
            )}
            {esAdmin && (
              <Button size="small" variant="contained" startIcon={<AddIcon />} onClick={abrirNuevo}>
                Nuevo
              </Button>
            )}
          </Stack>
        }
      />

      {loading && <CircularProgress size={24} />}
      {error && <Typography color="error">Error: {error.message}</Typography>}

      {data && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Nombre</TableCell>
                <TableCell>Correo</TableCell>
                <TableCell>Especialidad</TableCell>
                {esAdmin && <TableCell width={100} align="right">Acciones</TableCell>}
              </TableRow>
            </TableHead>
            <TableBody>
              {data.docentes.map((d) => (
                <TableRow key={d.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{d.nombre}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{d.correo}</TableCell>
                  <TableCell>{d.especialidad || "Sin especialidad"}</TableCell>
                  {esAdmin && (
                    <TableCell align="right">
                      <IconButton size="small" onClick={() => abrirEditar(d)}><EditIcon fontSize="small" /></IconButton>
                      <IconButton size="small" onClick={() => setAEliminar(d)}><DeleteIcon fontSize="small" /></IconButton>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>{editando ? "Editar docente" : "Nuevo docente"}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Nombre" value={values.nombre} onChange={handleChange("nombre")} error={!!errors.nombre} helperText={errors.nombre} fullWidth />
            <TextField label="Correo" value={values.correo} onChange={handleChange("correo")} error={!!errors.correo} helperText={errors.correo} fullWidth />
            <TextField label="Especialidad" value={values.especialidad} onChange={handleChange("especialidad")} fullWidth />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2.5 }}>
          <Button onClick={() => setDialogOpen(false)} color="inherit">Cancelar</Button>
          <Button onClick={guardar} variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={!!aEliminar}
        title="Eliminar docente"
        message={`Se dara de baja a "${aEliminar?.nombre}".`}
        onConfirm={confirmarEliminar}
        onCancel={() => setAEliminar(null)}
      />

      <ErrorSnackbar open={!!formError} message={formError} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\docentes\DocentesPage.jsx") -Content $content_fe_docentes

    $content_fe_cursos = @'
import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import {
  Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box,
  Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Stack, MenuItem,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/EditOutlined";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import PageHeader from "../../design-system/components/PageHeader";
import ConfirmDialog from "../../design-system/components/ConfirmDialog";
import ErrorSnackbar from "../../errors/ErrorSnackbar";
import { useErrorHandler } from "../../errors/useErrorHandler";
import { useFormValidation } from "../../utils/useFormValidation";
import { validateRequired, ERROR_MESSAGES } from "../../utils/validation";
import { GET_CURSOS, GET_DOCENTES, CREAR_CURSO, ACTUALIZAR_CURSO, ELIMINAR_CURSO } from "../../graphql/operations";
import { useAuth } from "../../auth/AuthContext";

const VALORES_INICIALES = { nombre: "", docente_id: "", periodo_academico: "" };

const REGLAS = {
  nombre: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
  docente_id: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
  periodo_academico: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
};

// Docentes con permiso "actualizar_cursos" pueden editar cursos existentes
// (CA-003), pero solo un administrador puede crear o eliminar.
export default function CursosPage() {
  const { user } = useAuth();
  const esAdmin = user?.rol === "administrador";
  const puedeEditar = esAdmin || user?.rol === "docente";
  const { data, loading, error, refetch } = useQuery(GET_CURSOS);
  const { data: dataDocentes } = useQuery(GET_DOCENTES);
  const { error: formError, showError, clearError } = useErrorHandler();
  const { values, errors, handleChange, validateAll, setValues } = useFormValidation(VALORES_INICIALES, REGLAS);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editando, setEditando] = useState(null);
  const [aEliminar, setAEliminar] = useState(null);

  const [crearCurso] = useMutation(CREAR_CURSO);
  const [actualizarCurso] = useMutation(ACTUALIZAR_CURSO);
  const [eliminarCurso] = useMutation(ELIMINAR_CURSO);

  const nombreDocente = (id) => dataDocentes?.docentes.find((d) => d.id === id)?.nombre || `#${id}`;

  const abrirNuevo = () => {
    setEditando(null);
    setValues(VALORES_INICIALES);
    setDialogOpen(true);
  };

  const abrirEditar = (curso) => {
    setEditando(curso);
    setValues({ nombre: curso.nombre, docente_id: curso.docente_id, periodo_academico: curso.periodo_academico });
    setDialogOpen(true);
  };

  const guardar = async () => {
    if (!validateAll()) return;
    try {
      const datos = { ...values, docente_id: Number(values.docente_id) };
      if (editando) {
        await actualizarCurso({ variables: { id: editando.id, datos } });
      } else {
        await crearCurso({ variables: { datos } });
      }
      setDialogOpen(false);
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  const confirmarEliminar = async () => {
    const objetivo = aEliminar;
    setAEliminar(null);
    try {
      await eliminarCurso({ variables: { id: objetivo.id } });
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 03"
        title="Cursos"
        action={
          <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
            {data && (
              <Typography variant="caption" sx={{ color: "text.secondary", lineHeight: 1 }}>
                {data.cursos.length} activos
              </Typography>
            )}
            {esAdmin && (
              <Button size="small" variant="contained" startIcon={<AddIcon />} onClick={abrirNuevo}>
                Nuevo
              </Button>
            )}
          </Stack>
        }
      />

      {loading && <CircularProgress size={24} />}
      {error && <Typography color="error">Error: {error.message}</Typography>}

      {data && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Curso</TableCell>
                <TableCell>Docente</TableCell>
                <TableCell width={140}>Periodo</TableCell>
                {puedeEditar && <TableCell width={100} align="right">Acciones</TableCell>}
              </TableRow>
            </TableHead>
            <TableBody>
              {data.cursos.map((c) => (
                <TableRow key={c.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{c.nombre}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{nombreDocente(c.docente_id)}</TableCell>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.85rem", color: "text.secondary" }}>
                    {c.periodo_academico}
                  </TableCell>
                  {puedeEditar && (
                    <TableCell align="right">
                      <IconButton size="small" onClick={() => abrirEditar(c)}><EditIcon fontSize="small" /></IconButton>
                      {esAdmin && <IconButton size="small" onClick={() => setAEliminar(c)}><DeleteIcon fontSize="small" /></IconButton>}
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>{editando ? "Editar curso" : "Nuevo curso"}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField label="Nombre" value={values.nombre} onChange={handleChange("nombre")} error={!!errors.nombre} helperText={errors.nombre} fullWidth />
            <TextField
              select
              label="Docente"
              value={values.docente_id}
              onChange={handleChange("docente_id")}
              error={!!errors.docente_id}
              helperText={errors.docente_id}
              fullWidth
            >
              {(dataDocentes?.docentes || []).map((d) => (
                <MenuItem key={d.id} value={d.id}>{d.nombre}</MenuItem>
              ))}
            </TextField>
            <TextField label="Periodo academico" placeholder="2026-1" value={values.periodo_academico} onChange={handleChange("periodo_academico")} error={!!errors.periodo_academico} helperText={errors.periodo_academico} fullWidth />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2.5 }}>
          <Button onClick={() => setDialogOpen(false)} color="inherit">Cancelar</Button>
          <Button onClick={guardar} variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={!!aEliminar}
        title="Eliminar curso"
        message={`Se eliminara el curso "${aEliminar?.nombre}" de forma permanente.`}
        onConfirm={confirmarEliminar}
        onCancel={() => setAEliminar(null)}
      />

      <ErrorSnackbar open={!!formError} message={formError} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\cursos\CursosPage.jsx") -Content $content_fe_cursos

    $content_fe_insc = @'
import { useState } from "react";
import { useQuery, useMutation } from "@apollo/client";
import {
  Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box,
  Button, IconButton, Dialog, DialogTitle, DialogContent, DialogActions, TextField, Stack, MenuItem,
} from "@mui/material";
import AddIcon from "@mui/icons-material/Add";
import EditIcon from "@mui/icons-material/EditOutlined";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import PageHeader from "../../design-system/components/PageHeader";
import StatusStamp from "../../design-system/components/StatusStamp";
import ConfirmDialog from "../../design-system/components/ConfirmDialog";
import ErrorSnackbar from "../../errors/ErrorSnackbar";
import { useErrorHandler } from "../../errors/useErrorHandler";
import { useFormValidation } from "../../utils/useFormValidation";
import { validateRequired, ERROR_MESSAGES } from "../../utils/validation";
import {
  GET_INSCRIPCIONES, GET_ESTUDIANTES, GET_CURSOS,
  CREAR_INSCRIPCION, ACTUALIZAR_INSCRIPCION, ELIMINAR_INSCRIPCION,
} from "../../graphql/operations";
import { useAuth } from "../../auth/AuthContext";

const ESTADOS = ["activa", "cerrada", "cupo_lleno"];
const VALORES_INICIALES = { estudiante_id: "", curso_id: "", estado: "activa" };

const REGLAS = {
  estudiante_id: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
  curso_id: (v) => (validateRequired(v) ? null : ERROR_MESSAGES.campoRequerido),
};

export default function InscripcionesPage() {
  const { user } = useAuth();
  const esAdmin = user?.rol === "administrador";
  const puedeCrear = esAdmin || user?.rol === "docente";
  const { data, loading, error, refetch } = useQuery(GET_INSCRIPCIONES);
  const { data: dataEstudiantes } = useQuery(GET_ESTUDIANTES);
  const { data: dataCursos } = useQuery(GET_CURSOS);
  const { error: formError, showError, clearError } = useErrorHandler();
  const { values, errors, handleChange, validateAll, setValues } = useFormValidation(VALORES_INICIALES, REGLAS);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editando, setEditando] = useState(null);
  const [aEliminar, setAEliminar] = useState(null);

  const [crearInscripcion] = useMutation(CREAR_INSCRIPCION);
  const [actualizarInscripcion] = useMutation(ACTUALIZAR_INSCRIPCION);
  const [eliminarInscripcion] = useMutation(ELIMINAR_INSCRIPCION);

  const nombreEstudiante = (id) => dataEstudiantes?.estudiantes.find((e) => e.id === id)?.nombre || `#${id}`;
  const nombreCurso = (id) => dataCursos?.cursos.find((c) => c.id === id)?.nombre || `#${id}`;

  const abrirNuevo = () => {
    setEditando(null);
    setValues(VALORES_INICIALES);
    setDialogOpen(true);
  };

  const abrirEditar = (inscripcion) => {
    setEditando(inscripcion);
    setValues({ estudiante_id: inscripcion.estudiante_id, curso_id: inscripcion.curso_id, estado: inscripcion.estado });
    setDialogOpen(true);
  };

  const guardar = async () => {
    if (!validateAll()) return;
    try {
      if (editando) {
        await actualizarInscripcion({ variables: { id: editando.id, datos: { estado: values.estado } } });
      } else {
        await crearInscripcion({
          variables: { datos: { estudiante_id: Number(values.estudiante_id), curso_id: Number(values.curso_id), estado: values.estado } },
        });
      }
      setDialogOpen(false);
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  const confirmarEliminar = async () => {
    const objetivo = aEliminar;
    setAEliminar(null);
    try {
      await eliminarInscripcion({ variables: { id: objetivo.id } });
      refetch();
    } catch (err) {
      showError(err.message);
    }
  };

  return (
    <Box>
      <PageHeader
        eyebrow="Registro 04"
        title="Inscripciones"
        action={
          <Stack direction="row" spacing={2} sx={{ alignItems: "center" }}>
            {data && (
              <Typography variant="caption" sx={{ color: "text.secondary", lineHeight: 1 }}>
                {data.inscripciones.length} movimientos
              </Typography>
            )}
            {puedeCrear && (
              <Button size="small" variant="contained" startIcon={<AddIcon />} onClick={abrirNuevo}>
                Nueva
              </Button>
            )}
          </Stack>
        }
      />

      {loading && <CircularProgress size={24} />}
      {error && <Typography color="error">Error: {error.message}</Typography>}

      {data && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell width={100}>Numero</TableCell>
                <TableCell>Estudiante</TableCell>
                <TableCell>Curso</TableCell>
                <TableCell width={140}>Estado</TableCell>
                {puedeCrear && <TableCell width={100} align="right">Acciones</TableCell>}
              </TableRow>
            </TableHead>
            <TableBody>
              {data.inscripciones.map((i) => (
                <TableRow key={i.id} hover>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.85rem" }}>
                    #{String(i.id).padStart(4, "0")}
                  </TableCell>
                  <TableCell>{nombreEstudiante(i.estudiante_id)}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{nombreCurso(i.curso_id)}</TableCell>
                  <TableCell>
                    <StatusStamp estado={i.estado} />
                  </TableCell>
                  {puedeCrear && (
                    <TableCell align="right">
                      <IconButton size="small" onClick={() => abrirEditar(i)}><EditIcon fontSize="small" /></IconButton>
                      {esAdmin && <IconButton size="small" onClick={() => setAEliminar(i)}><DeleteIcon fontSize="small" /></IconButton>}
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>{editando ? "Editar inscripcion" : "Nueva inscripcion"}</DialogTitle>
        <DialogContent>
          <Stack spacing={2} sx={{ mt: 1 }}>
            <TextField
              select label="Estudiante" value={values.estudiante_id} onChange={handleChange("estudiante_id")}
              error={!!errors.estudiante_id} helperText={errors.estudiante_id} fullWidth disabled={!!editando}
            >
              {(dataEstudiantes?.estudiantes || []).map((e) => (
                <MenuItem key={e.id} value={e.id}>{e.nombre}</MenuItem>
              ))}
            </TextField>
            <TextField
              select label="Curso" value={values.curso_id} onChange={handleChange("curso_id")}
              error={!!errors.curso_id} helperText={errors.curso_id} fullWidth disabled={!!editando}
            >
              {(dataCursos?.cursos || []).map((c) => (
                <MenuItem key={c.id} value={c.id}>{c.nombre}</MenuItem>
              ))}
            </TextField>
            <TextField select label="Estado" value={values.estado} onChange={handleChange("estado")} fullWidth>
              {ESTADOS.map((e) => (
                <MenuItem key={e} value={e}>{e}</MenuItem>
              ))}
            </TextField>
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2.5 }}>
          <Button onClick={() => setDialogOpen(false)} color="inherit">Cancelar</Button>
          <Button onClick={guardar} variant="contained">Guardar</Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={!!aEliminar}
        title="Eliminar inscripcion"
        message={`Se eliminara la inscripcion #${String(aEliminar?.id || 0).padStart(4, "0")}.`}
        onConfirm={confirmarEliminar}
        onCancel={() => setAEliminar(null)}
      />

      <ErrorSnackbar open={!!formError} message={formError} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\inscripciones\InscripcionesPage.jsx") -Content $content_fe_insc

    $content_fe_roles = @'
import { useEffect, useState } from "react";
import { Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box, Chip } from "@mui/material";
import PageHeader from "../../design-system/components/PageHeader";
import ErrorSnackbar from "../../errors/ErrorSnackbar";
import { useErrorHandler } from "../../errors/useErrorHandler";
import { apiFetch } from "../../utils/apiClient";

export default function RolesPage() {
  const [roles, setRoles] = useState(null);
  const [loading, setLoading] = useState(true);
  const { error, showError, clearError } = useErrorHandler();

  useEffect(() => {
    apiFetch("/roles/")
      .then(setRoles)
      .catch((err) => showError(err.message))
      .finally(() => setLoading(false));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <Box>
      <PageHeader eyebrow="CA-003" title="Roles y permisos" />

      {loading && <CircularProgress size={24} />}

      {roles && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell width={200}>Rol</TableCell>
                <TableCell>Permisos</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {roles.map((r) => (
                <TableRow key={r.rol} hover>
                  <TableCell sx={{ fontWeight: 500, textTransform: "capitalize" }}>{r.rol}</TableCell>
                  <TableCell>
                    <Box sx={{ display: "flex", flexWrap: "wrap", gap: 1 }}>
                      {r.permisos.map((p) => (
                        <Chip key={p} label={p} size="small" variant="outlined" sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.7rem" }} />
                      ))}
                    </Box>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <ErrorSnackbar open={!!error} message={error} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\roles\RolesPage.jsx") -Content $content_fe_roles

    $content_fe_auditoria = @'
import { useEffect, useState } from "react";
import {
  Typography, Paper, Table, TableHead, TableRow, TableCell, TableBody, CircularProgress, Box,
  Button, Stack, Dialog, DialogTitle, DialogContent, DialogActions, TextField,
} from "@mui/material";
import DownloadIcon from "@mui/icons-material/DownloadOutlined";
import DeleteSweepIcon from "@mui/icons-material/DeleteSweepOutlined";
import PageHeader from "../../design-system/components/PageHeader";
import ErrorSnackbar from "../../errors/ErrorSnackbar";
import { useErrorHandler } from "../../errors/useErrorHandler";
import { apiFetch, API_URL } from "../../utils/apiClient";

export default function AuditoriaPage() {
  const [registros, setRegistros] = useState(null);
  const [loading, setLoading] = useState(true);
  const { error, showError, clearError } = useErrorHandler();
  const [purgarOpen, setPurgarOpen] = useState(false);
  const [dias, setDias] = useState("");

  const cargar = () => {
    setLoading(true);
    apiFetch("/auditoria/?limite=100")
      .then(setRegistros)
      .catch((err) => showError(err.message))
      .finally(() => setLoading(false));
  };

  useEffect(cargar, []); // eslint-disable-line react-hooks/exhaustive-deps

  const exportar = async () => {
    try {
      const token = localStorage.getItem("token");
      const res = await fetch(`${API_URL}/auditoria/exportar`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) throw new Error("No se pudo exportar la auditoria");
      const blob = await res.blob();
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "auditoria.csv";
      a.click();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      showError(err.message);
    }
  };

  const purgar = async () => {
    try {
      const query = dias ? `?dias=${Number(dias)}` : "";
      const resultado = await apiFetch(`/auditoria/purgar${query}`, { method: "POST" });
      setPurgarOpen(false);
      setDias("");
      cargar();
      showError(`Se eliminaron ${resultado.eliminados} registros (retencion: ${resultado.dias_retencion} dias).`);
    } catch (err) {
      showError(err.message);
    }
  };

  return (
    <Box>
      <PageHeader
        eyebrow="CA-009"
        title="Auditoria"
        action={
          <Stack direction="row" spacing={1.5}>
            <Button size="small" variant="outlined" startIcon={<DownloadIcon />} onClick={exportar}>
              Exportar CSV
            </Button>
            <Button size="small" variant="outlined" startIcon={<DeleteSweepIcon />} onClick={() => setPurgarOpen(true)}>
              Purgar antiguos
            </Button>
          </Stack>
        }
      />

      {loading && <CircularProgress size={24} />}

      {registros && (
        <Paper variant="outlined">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell width={170}>Fecha</TableCell>
                <TableCell>Usuario</TableCell>
                <TableCell>Recurso</TableCell>
                <TableCell>Accion</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {registros.map((r) => (
                <TableRow key={r.id} hover>
                  <TableCell sx={{ fontFamily: '"IBM Plex Mono", monospace', fontSize: "0.78rem" }}>
                    {new Date(r.timestamp).toLocaleString()}
                  </TableCell>
                  <TableCell>{r.usuario_correo}</TableCell>
                  <TableCell sx={{ color: "text.secondary" }}>{r.recurso}</TableCell>
                  <TableCell sx={{ textTransform: "capitalize" }}>{r.accion}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Paper>
      )}

      <Dialog open={purgarOpen} onClose={() => setPurgarOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Purgar registros antiguos</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2, color: "text.secondary" }}>
            Elimina registros de auditoria mas antiguos que el periodo indicado. Dejar vacio para usar la
            retencion configurada por defecto del sistema.
          </Typography>
          <TextField
            label="Dias de retencion"
            type="number"
            value={dias}
            onChange={(e) => setDias(e.target.value)}
            fullWidth
          />
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2.5 }}>
          <Button onClick={() => setPurgarOpen(false)} color="inherit">Cancelar</Button>
          <Button onClick={purgar} variant="contained">Purgar</Button>
        </DialogActions>
      </Dialog>

      <ErrorSnackbar open={!!error} message={error} onClose={clearError} />
    </Box>
  );
}
'@
    Write-SkeletonFile -FilePath (Join-Path $FRONTEND_DIR "src\modules\auditoria\AuditoriaPage.jsx") -Content $content_fe_auditoria

    # Script de siembra de datos de ejemplo (no forma parte del catalogo
    # de Core Assets CA-001 a CA-011; es una utilidad opcional para tener
    # datos de prueba rapido en desarrollo). No se ejecuta automaticamente.
    Write-Host ""
    Write-Host "--- Script de siembra de datos de ejemplo ---" -ForegroundColor Cyan
    $content_seed_data = @'
"""
Script de siembra de datos de ejemplo. NO forma parte del arranque
automatico de la aplicacion (no se importa desde main.py).

Ejecutar manualmente con:
    cd backend
    python seed_data.py

Es idempotente: si una tabla ya tiene 5 filas o mas, no agrega nada;
si tiene menos, completa hasta 5 usando datos de ejemplo que no
choquen con los que ya existan (correo/codigo/nombre unicos).
"""
from core.ca005_db.database import SessionLocal, Base, engine
from core.ca005_db.models import Usuario, Docente, Estudiante, Curso, Inscripcion
from core.ca001_auth.security import get_password_hash

Base.metadata.create_all(bind=engine)
db = SessionLocal()

META = 5


def log(mensaje):
    print(f"  {mensaje}")


# --- Usuarios ---
usuarios_candidatos = [
    {"correo": "admin@academico.com", "contrasena": "admin123", "rol": "administrador"},
    {"correo": "docente1@academico.com", "contrasena": "Docente123", "rol": "docente"},
    {"correo": "maria.lopez@academico.com", "contrasena": "Docente123", "rol": "docente"},
    {"correo": "juan.perez@academico.com", "contrasena": "Docente123", "rol": "docente"},
    {"correo": "admin2@academico.com", "contrasena": "Admin123", "rol": "administrador"},
]
existentes = {u.correo for u in db.query(Usuario).all()}
for c in usuarios_candidatos:
    if len(existentes) >= META:
        break
    if c["correo"] in existentes:
        continue
    db.add(Usuario(correo=c["correo"], contrasena_hash=get_password_hash(c["contrasena"]), rol=c["rol"]))
    existentes.add(c["correo"])
    log(f"usuario creado: {c['correo']}")
db.commit()

usuarios_por_correo = {u.correo: u for u in db.query(Usuario).all()}

# --- Docentes ---
docentes_candidatos = [
    {"nombre": "Prof Garcia", "correo": "garcia@academico.com", "especialidad": "Matematicas", "usuario_correo": None},
    {"nombre": "Maria Lopez", "correo": "maria.lopez@academico.com", "especialidad": "Fisica", "usuario_correo": "maria.lopez@academico.com"},
    {"nombre": "Juan Perez", "correo": "juan.perez@academico.com", "especialidad": "Programacion", "usuario_correo": "juan.perez@academico.com"},
    {"nombre": "Laura Sanchez", "correo": "laura.sanchez@academico.com", "especialidad": "Quimica", "usuario_correo": None},
    {"nombre": "Diego Torres", "correo": "diego.torres@academico.com", "especialidad": "Historia", "usuario_correo": None},
]
existentes = {d.correo for d in db.query(Docente).all()}
for c in docentes_candidatos:
    if len(existentes) >= META:
        break
    if c["correo"] in existentes:
        continue
    usuario_id = usuarios_por_correo[c["usuario_correo"]].id if c["usuario_correo"] else None
    db.add(Docente(nombre=c["nombre"], correo=c["correo"], especialidad=c["especialidad"], usuario_id=usuario_id))
    existentes.add(c["correo"])
    log(f"docente creado: {c['nombre']}")
db.commit()

docentes_por_correo = {d.correo: d for d in db.query(Docente).all()}

# --- Estudiantes ---
estudiantes_candidatos = [
    {"nombre": "Carlos Mendoza", "codigo": "C999", "correo": "carlos.mendoza@estudiante.edu", "datos_contacto": None},
    {"nombre": "Ana Torres", "codigo": "A100", "correo": "ana.torres@estudiante.edu", "datos_contacto": None},
    {"nombre": "Sofia Ramirez", "codigo": "E001", "correo": "sofia.ramirez@estudiante.edu", "datos_contacto": "099-111-2222"},
    {"nombre": "Pedro Gomez", "codigo": "E002", "correo": "pedro.gomez@estudiante.edu", "datos_contacto": "099-222-3333"},
    {"nombre": "Valentina Cruz", "codigo": "E003", "correo": "valentina.cruz@estudiante.edu", "datos_contacto": "099-333-4444"},
]
existentes = {e.codigo for e in db.query(Estudiante).all()}
for c in estudiantes_candidatos:
    if len(existentes) >= META:
        break
    if c["codigo"] in existentes:
        continue
    db.add(Estudiante(nombre=c["nombre"], codigo=c["codigo"], correo=c["correo"], datos_contacto=c["datos_contacto"]))
    existentes.add(c["codigo"])
    log(f"estudiante creado: {c['nombre']} ({c['codigo']})")
db.commit()

estudiantes_por_codigo = {e.codigo: e for e in db.query(Estudiante).all()}

# --- Cursos ---
cursos_candidatos = [
    {"nombre": "Calculo I", "docente_correo": "garcia@academico.com", "periodo_academico": "2026-B"},
    {"nombre": "Fisica I", "docente_correo": "maria.lopez@academico.com", "periodo_academico": "2026-B"},
    {"nombre": "Programacion I", "docente_correo": "juan.perez@academico.com", "periodo_academico": "2026-B"},
    {"nombre": "Quimica General", "docente_correo": "laura.sanchez@academico.com", "periodo_academico": "2026-A"},
    {"nombre": "Historia Universal", "docente_correo": "diego.torres@academico.com", "periodo_academico": "2026-A"},
]
existentes = {c.nombre for c in db.query(Curso).all()}
for c in cursos_candidatos:
    if len(existentes) >= META:
        break
    if c["nombre"] in existentes:
        continue
    docente_id = docentes_por_correo[c["docente_correo"]].id
    db.add(Curso(nombre=c["nombre"], docente_id=docente_id, periodo_academico=c["periodo_academico"]))
    existentes.add(c["nombre"])
    log(f"curso creado: {c['nombre']}")
db.commit()

cursos_por_nombre = {c.nombre: c for c in db.query(Curso).all()}

# --- Inscripciones (sin campo unico natural; se deduplica por par estudiante+curso) ---
inscripciones_candidatas = [
    {"estudiante_codigo": "C999", "curso_nombre": "Calculo I", "estado": "activa"},
    {"estudiante_codigo": "A100", "curso_nombre": "Fisica I", "estado": "activa"},
    {"estudiante_codigo": "E001", "curso_nombre": "Programacion I", "estado": "activa"},
    {"estudiante_codigo": "E002", "curso_nombre": "Quimica General", "estado": "cupo_lleno"},
    {"estudiante_codigo": "E003", "curso_nombre": "Historia Universal", "estado": "cerrada"},
]
filas_actuales = db.query(Inscripcion).all()
pares_existentes = {(i.estudiante_id, i.curso_id) for i in filas_actuales}
total_actual = len(filas_actuales)
for c in inscripciones_candidatas:
    if total_actual >= META:
        break
    est = estudiantes_por_codigo.get(c["estudiante_codigo"])
    cur = cursos_por_nombre.get(c["curso_nombre"])
    if not est or not cur or (est.id, cur.id) in pares_existentes:
        continue
    db.add(Inscripcion(estudiante_id=est.id, curso_id=cur.id, estado=c["estado"]))
    pares_existentes.add((est.id, cur.id))
    total_actual += 1
    log(f"inscripcion creada: {c['estudiante_codigo']} -> {c['curso_nombre']} ({c['estado']})")
db.commit()

db.close()
print("Siembra completada.")
'@
    Write-SkeletonFile -FilePath (Join-Path $BACKEND_DIR "seed_data.py") -Content $content_seed_data
    Write-Host "  [OK] seed_data.py generado (ejecutar manualmente: cd backend; python seed_data.py)" -ForegroundColor Green

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



