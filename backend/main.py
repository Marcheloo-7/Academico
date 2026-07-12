from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from strawberry.fastapi import GraphQLRouter
from sqlalchemy.orm import Session

from core.ca001_auth.router import router as auth_router
from core.ca002_usuarios.router import router as usuarios_router
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
app.include_router(auditoria_router)
app.include_router(graphql_app, prefix="/graphql")

@app.get("/")
def root():
    return {"mensaje": "API activa"}
