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
