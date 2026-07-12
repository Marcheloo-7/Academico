class AppException(Exception):
    def __init__(self, codigo: str, mensaje: str, status_code: int = 400, tipo: str = "aplicacion"):
        self.codigo = codigo
        self.mensaje = mensaje
        self.status_code = status_code
        self.tipo = tipo
        super().__init__(mensaje)


class RecursoNoEncontradoException(AppException):
    def __init__(self, mensaje: str = "Recurso no encontrado"):
        super().__init__(codigo="recurso_no_encontrado", mensaje=mensaje, status_code=404, tipo="no_encontrado")


class NoAutorizadoException(AppException):
    def __init__(self, mensaje: str = "No autorizado"):
        super().__init__(codigo="no_autorizado", mensaje=mensaje, status_code=401, tipo="autenticacion")


class PermisoDenegadoException(AppException):
    def __init__(self, mensaje: str = "Permiso denegado"):
        super().__init__(codigo="permiso_denegado", mensaje=mensaje, status_code=403, tipo="autorizacion")


class ErrorDeValidacionException(AppException):
    def __init__(self, mensaje: str = "Error de validacion"):
        super().__init__(codigo="error_validacion", mensaje=mensaje, status_code=422, tipo="validacion")
