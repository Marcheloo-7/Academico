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
