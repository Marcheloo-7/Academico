from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from .exceptions import AppException
from .schemas import ErrorResponse
from .logging_config import logger


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    logger.warning("Error de validacion en %s: %s", request.url.path, exc.errors())
    error = ErrorResponse(
        codigo="error_validacion",
        mensaje="Los datos enviados no son validos.",
        tipo="validacion",
        detalle=exc.errors(),
    )
    return JSONResponse(status_code=422, content=error.model_dump())


async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    logger.warning("HTTPException en %s: %s", request.url.path, exc.detail)
    error = ErrorResponse(
        codigo="error_http",
        mensaje=str(exc.detail),
        tipo="cliente" if exc.status_code < 500 else "servidor",
    )
    return JSONResponse(status_code=exc.status_code, content=error.model_dump())


async def app_exception_handler(request: Request, exc: AppException):
    logger.warning("AppException en %s: %s", request.url.path, exc.mensaje)
    error = ErrorResponse(codigo=exc.codigo, mensaje=exc.mensaje, tipo=exc.tipo)
    return JSONResponse(status_code=exc.status_code, content=error.model_dump())


async def generic_exception_handler(request: Request, exc: Exception):
    logger.error("Error no controlado en %s: %s", request.url.path, exc, exc_info=True)
    error = ErrorResponse(
        codigo="error_servidor",
        mensaje="Ocurrio un error inesperado en el servidor.",
        tipo="servidor",
    )
    return JSONResponse(status_code=500, content=error.model_dump())
