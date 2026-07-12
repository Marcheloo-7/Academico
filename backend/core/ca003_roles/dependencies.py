from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from core.ca001_auth.security import verify_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    return verify_token(token)

def requiere_rol(*roles: str):
    def verificador(token_payload = Depends(get_current_user)):
        if token_payload.rol not in roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="No tiene permisos para esta accion")
        return token_payload
    return verificador
