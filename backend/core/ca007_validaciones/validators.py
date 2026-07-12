import re
from datetime import datetime
from typing import Optional

EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def es_email_valido(valor: str) -> bool:
    return bool(valor) and bool(EMAIL_REGEX.match(valor))


def validar_longitud(valor: str, minimo: int = 0, maximo: Optional[int] = None) -> bool:
    if valor is None:
        return False
    largo = len(valor)
    if largo < minimo:
        return False
    if maximo is not None and largo > maximo:
        return False
    return True


def es_fecha_valida(valor: str, formato: str = "%Y-%m-%d") -> bool:
    try:
        datetime.strptime(valor, formato)
        return True
    except (ValueError, TypeError):
        return False


def es_cedula_valida(valor: str) -> bool:
    # Validacion basica: solo digitos y longitud entre 6 y 15.
    # Un checksum real de cedula es especifico de cada pais/producto
    # y queda fuera del alcance de este Core Asset generico.
    return bool(valor) and valor.isdigit() and 6 <= len(valor) <= 15


def es_password_seguro(valor: str) -> bool:
    if not valor or len(valor) < 8:
        return False
    tiene_mayuscula = any(c.isupper() for c in valor)
    tiene_minuscula = any(c.islower() for c in valor)
    tiene_digito = any(c.isdigit() for c in valor)
    return tiene_mayuscula and tiene_minuscula and tiene_digito
