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
