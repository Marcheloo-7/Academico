from pydantic import BaseModel
class LoginRequest(BaseModel):
    correo: str
    contrasena: str
class TokenPayload(BaseModel):
    sub: str
    rol: str
    exp: int
