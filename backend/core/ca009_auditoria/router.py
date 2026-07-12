from typing import List, Optional
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from . import schemas, services
from core.ca005_db.session import get_db
from core.ca003_roles.dependencies import requiere_rol

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
