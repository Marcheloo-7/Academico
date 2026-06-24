from pydantic import BaseModel

class StudentCreate(BaseModel):
    name: str
    email: str

class StudentRead(BaseModel):
    id: int
    name: str
    email: str

    model_config = {"from_attributes": True}
