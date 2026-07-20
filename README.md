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

## 3. Preguntas interactivas (s/n) y Estado de Core Assets

Durante la ejecucion, el script realiza varias preguntas interactivas para personalizar el producto de software. Estas son las preguntas y para que sirven:

- **Desea crear el nuevo producto en la ubicacion actual?** - Define si el proyecto se instala en la carpeta actual o si se crea una nueva con un nombre especifico.
- **Que nombre desea agregar a la base de datos?** (CA-005) - Permite personalizar el nombre de la DB (por defecto es `academico_db`).
- **¿Desea mostrar el detalle de los errores en un lenguaje no técnico?** (CA-008) - Habilita mensajes de error mas amigables para el usuario, ocultando detalles tecnicos al cliente.
- **¿Desea habilitar el modulo de Registro de Auditoria?** (CA-009) - Instala el sistema de trazabilidad para registrar quien hizo que y cuando.
- **Desea incluir estilos y tipografia tipo institucional?** (CA-004) - Aplica un tema visual corporativo (fuentes serif) en lugar del diseno estandar.
- **Desea habilitar soporte para modo oscuro?** (CA-004) - Agrega el interruptor y los estilos necesarios para el Dark Mode en el frontend.
- **Desea incluir el modulo de registro publico de usuarios?** (CA-002) - Habilita la opcion de "Crear cuenta" en el login para usuarios externos.
- **Desea incluir la funcionalidad de recuperar contrasena?** (CA-002) - Integra los flujos para cuando un usuario olvida su contrasena.
- **Desea habilitar reglas de validacion estricta?** (CA-007) - Fuerza contrasenas complejas y validaciones mas rigurosas en los formularios.
- **Desea incluir el rol Docente?** (CA-003) - Instala o ignora todo el manejo de este rol dentro del control de acceso (RBAC).
- **Desea incluir el modulo Estudiantes / Docentes / Cursos / Inscripciones?** - Activa u omite estos submodulos funcionales completos en el backend y frontend.
- **Desea incluir plantillas DevOps?** (CA-011) - Genera los archivos necesarios de infraestructura (Docker, Docker Compose, CI/CD).

Todas tus respuestas se guardan en el archivo `sga_config.json`. Si vuelves a correr el script, detectara tu configuracion y solo te preguntara si deseas agregar las funcionalidades que omitiste previamente.

### Listar los Core Assets Implementados

Para ver un resumen en formato lista indicando especificamente que *Core Assets* se implementaron (ej. "CA01: Implementado") basado en tus respuestas, copia y pega este bloque en tu consola de PowerShell (en la raiz del proyecto):

```powershell
$c = Get-Content sga_config.json -Raw | ConvertFrom-Json;
$fmt = { param($v) if ($v) { "Implementado" } else { "No implementado" } };
Write-Host "--- ESTADO DE CORE ASSETS ---" -ForegroundColor Cyan;
Write-Host "CA01 (Autenticacion): Implementado (Base del sistema)";
Write-Host "CA02 (Usuarios - Registro): $(& $fmt $c.IncludeRegistroUsuario)";
Write-Host "CA03 (Roles - Docente): $(& $fmt $c.IncludeRolDocente)";
Write-Host "CA04 (Diseno - Modo Oscuro): $(& $fmt $c.IncludeModoOscuro)";
Write-Host "CA05 (Base de Datos): Implementado (DB: $($c.DbName))";
Write-Host "CA06 (GraphQL): Implementado (Base del sistema)";
Write-Host "CA07 (Validaciones Estrictas): $(& $fmt $c.IncludeValidacionEstricta)";
Write-Host "CA08 (Manejo de Errores): $(& $fmt $c.NonTechnicalErrors)";
Write-Host "CA09 (Registro de Auditoria): $(& $fmt $c.EnableAuditLog)";
Write-Host "CA10 (Configuracion Entorno): Implementado (Base del sistema)";
Write-Host "CA11 (DevOps Templates): $(& $fmt $c.IncludeDevOpsTemplates)";
```
Este comando lee directamente la configuracion guardada y te dara el listado exacto del estado de cada Core Asset.

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

Opcionalmente, `AUDIT_RETENTION_DAYS` (CA-009/CA-010) define cuantos dias se conservan los registros de auditoria antes de poder purgarlos; por defecto es `365` si no se define.

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

## 7. Funcionalidades de la aplicacion

- **Autenticacion** (`/login`): inicio de sesion contra `admin@academico.com` / `admin123` (u otro usuario existente). El boton "Salir" revoca el token en el servidor (no solo lo borra del navegador), asi que no puede reutilizarse tras cerrar sesion.
- **Registro publico** (`/registro`, enlazado desde el login): cualquiera puede crear una cuenta propia; siempre se crea con rol **docente** (crear administradores requiere que otro administrador lo haga despues desde la gestion de usuarios).
- **Estudiantes, Docentes, Cursos e Inscripciones**: CRUD completo (crear, editar, eliminar) en las cuatro secciones del menu. Eliminar es una baja logica (el registro no se borra, se marca inactivo y desaparece de los listados). Los administradores pueden crear/editar/eliminar todo; los docentes pueden editar cursos (permiso especifico `actualizar_cursos` de CA-003) y crear/editar inscripciones, pero no eliminar nada ni crear estudiantes, docentes o cursos.
- **Roles** (`/roles`, solo administrador): lista los roles del sistema y los permisos asociados a cada uno.
- **Auditoria** (`/auditoria`, solo administrador): historial de acciones (quien hizo que, cuando), boton para exportarlo a CSV y boton para purgar registros mas antiguos que un numero de dias configurable (por defecto usa `AUDIT_RETENTION_DAYS`).

Hacer clic en el titulo "SGA · Sistema de Gestion Academica" de la barra superior siempre vuelve al menu principal.

## 8. Datos de ejemplo (opcional)

Para poblar la base de datos con 5 registros de ejemplo por tabla (usuarios, docentes, estudiantes, cursos, inscripciones), correr:

```powershell
cd backend
python seed_data.py
```

Es idempotente: se puede correr varias veces sin duplicar datos (se detiene al llegar a 5 filas por tabla).

## 9. Alternativa: correr todo con Docker

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

## 10. Problemas comunes

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
