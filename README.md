# Sistema de Gestion Academica (SGA)

Linea de Productos de Software (LPS) del Dominio Academico. Este repositorio contiene `setup_core_assets.ps1`, el script que genera el backend (FastAPI + GraphQL) y el frontend (React + Vite + MUI) a partir de los 11 Core Assets reutilizables del catalogo.

## 1. Requisitos previos

Antes de correr el script, asegurate de tener instalado:

- Python 3.10 o superior (con `pip` actualizado)
- Node.js 18 o superior (incluye npm 9+)
- PostgreSQL corriendo localmente (o accesible por red)
- PowerShell (Windows) o Git Bash

Verificar versiones:

```powershell
python --version
node --version
npm --version
pip --version
```

## 2. Como ejecutar el script

Desde la raiz del proyecto (donde esta `setup_core_assets.ps1`), abrir una consola de **PowerShell nativo** (no Git Bash, ver nota abajo) y correr:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_core_assets.ps1
```

> **Nota:** ejecutar el script desde PowerShell nativo o CMD, no desde Git Bash. Si se lanza desde un shell tipo bash, algunos comandos npm/npx pueden interpretar mal las rutas con backslash. El script ya incluye una mitigacion (usa rutas relativas con `Push-Location`), pero PowerShell nativo es el entorno mas seguro y probado.

El script tarda varios minutos (instala dependencias de Python con pip, dependencias de Node con npm, y genera el backend y el frontend completos). No cerrar la consola hasta que termine.

## 3. Preguntas interactivas (s/n)

Durante la ejecucion (seccion CA-003), el script pregunta que roles del sistema incluir:

```
Desea incluir el rol Administrador? (s/n)
Desea incluir el rol Docente? (s/n)
```

Responder `s` o `n` y presionar Enter. Si no estas seguro, responde `s` a ambas (es lo recomendado; el resto del sistema asume que existen ambos roles).

## 4. Que genera el script

El script instala y genera, en orden, los 11 Core Assets:

| Asset | Nombre |
|---|---|
| CA-001 | Autenticacion y Autorizacion (JWT) |
| CA-002 | Gestion de Usuarios (usuarios, estudiantes, docentes) |
| CA-003 | Gestion de Roles y Permisos (RBAC) |
| CA-004 | Sistema de Diseno (React + Vite + MUI, tema propio) |
| CA-005 | Configuracion de Base de Datos (PostgreSQL + SQLAlchemy) |
| CA-006 | Esquema GraphQL Base (Strawberry + Apollo Client) |
| CA-007 | Validaciones Comunes |
| CA-008 | Manejo Centralizado de Errores |
| CA-009 | Registro de Auditoria |
| CA-010 | Configuracion del Entorno (Settings tipado, CORS) |
| CA-011 | DevOps Templates (Docker, docker-compose, CI/CD) |

Al terminar, tendras dos carpetas nuevas: `backend/` y `frontend/`, ademas de archivos de infraestructura en la raiz (`Dockerfile`, `docker-compose.yml`, `.github/workflows/`).

El script es **idempotente**: si un archivo ya existe, lo omite (`[OMITIDO]`) en vez de sobreescribirlo. Se puede volver a correr sin miedo a perder cambios manuales ya hechos.

## 5. Configuracion obligatoria despues de correr el script

El script crea `backend/.env` con valores de PostgreSQL por defecto (usuario `postgres`, password `postgres`). Antes de levantar el backend, editar `backend/.env` y ajustar:

```env
DB_USER=<tu_usuario_postgres>
DB_PASSWORD=<tu_password_real>
DATABASE_URL=postgresql+psycopg2://<usuario>:<password>@localhost:5432/academico_db
```

La base de datos `academico_db` debe existir de antemano en tu servidor PostgreSQL (crearla manualmente si no existe):

```sql
CREATE DATABASE academico_db;
```

El `JWT_SECRET_KEY` que genera el script es un placeholder. Para un uso mas serio, generar una clave real:

```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```

y reemplazar el valor de `JWT_SECRET_KEY` en `backend/.env`.

## 6. Levantar los servidores de desarrollo

En una terminal, arrancar el backend (FastAPI + GraphQL):

```powershell
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

En otra terminal, arrancar el frontend (React + Vite):

```powershell
cd frontend
npm run dev
```

- Backend: http://localhost:8000
- Frontend: http://localhost:5173

Al primer arranque del backend se crea automaticamente un usuario administrador de prueba:

```
correo:     admin@academico.com
contrasena: admin123
```

## 7. Datos de ejemplo (opcional)

Para poblar la base de datos con 5 registros de ejemplo por tabla (usuarios, docentes, estudiantes, cursos, inscripciones), correr:

```powershell
cd backend
python seed_data.py
```

Es idempotente: se puede correr varias veces sin duplicar datos (se detiene al llegar a 5 filas por tabla).

## 8. Alternativa: correr todo con Docker

Si prefieres no instalar Python/Node/PostgreSQL localmente, podes levantar todo con Docker (requiere Docker Desktop corriendo):

```powershell
docker compose up --build
```

Esto expone:

| Servicio | URL |
|---|---|
| backend | http://localhost:8001 |
| frontend | http://localhost:5174 |
| postgres | localhost:5433 |

(Los puertos son distintos a los del desarrollo local a proposito, para poder correr ambos entornos al mismo tiempo sin conflicto.)

Para bajar los contenedores:

```powershell
docker compose down
```

## 9. Problemas comunes

**`password authentication failed for user postgres`**
El `DB_PASSWORD` en `backend/.env` no coincide con la contrasena real de tu PostgreSQL. Verificarla (por ejemplo con pgAdmin) y actualizar `backend/.env`.

**El frontend no conecta al backend / errores de CORS**
Verificar que `CORS_ORIGINS` en `backend/.env` incluya el origen desde el que estas accediendo (por defecto `http://localhost:5173`).

**Puerto ocupado (8000, 5173 o 5432)**
Verificar que no haya otra instancia de uvicorn, vite o postgres corriendo en el mismo puerto. En Windows:

```powershell
Get-NetTCPConnection -LocalPort 8000 -State Listen
```

**Volver a generar el proyecto desde cero**
Borrar las carpetas `backend/` y `frontend/` (y `docker-compose.yml`, `.github/` si se desea) y volver a correr el script.
