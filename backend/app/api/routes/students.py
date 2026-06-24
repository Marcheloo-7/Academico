from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.core.database import SessionLocal
from app.schemas.student import StudentRead
from app.services.student import StudentService

router = APIRouter(prefix="/students", tags=["students"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/", response_model=List[StudentRead])
def list_students(db: Session = Depends(get_db)):
    return StudentService().get_students(db)
