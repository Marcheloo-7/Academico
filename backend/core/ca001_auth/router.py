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
