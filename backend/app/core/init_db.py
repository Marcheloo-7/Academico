from app.core.database import engine
from app.models.student import Student
from app.core.database import Base

Base.metadata.create_all(bind=engine)
