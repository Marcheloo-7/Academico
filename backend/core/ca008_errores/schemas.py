from typing import Any, Optional
from pydantic import BaseModel


class ErrorResponse(BaseModel):
    codigo: str
    mensaje: str
    tipo: str
    detalle: Optional[Any] = None
