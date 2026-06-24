from sqlalchemy.orm import Session
from app.models.student import Student

class StudentService:

    def get_students(self, db: Session):
        return db.query(Student).all()
