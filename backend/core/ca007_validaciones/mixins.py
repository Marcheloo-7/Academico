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
