from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, JSON
from core.ca005_db.database import Base


class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(Integer, primary_key=True, index=True)
    usuario_correo = Column(String, nullable=False)
    recurso = Column(String, nullable=False)
    accion = Column(String, nullable=False)
    valores_anteriores = Column(JSON, nullable=True)
    valores_nuevos = Column(JSON, nullable=True)
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False)
