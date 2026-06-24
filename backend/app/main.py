from fastapi import FastAPI
from app.middleware.logging import LoggingMiddleware
from app.api.routes.students import router as students_router

app = FastAPI(
    title="Factory Backend Template",
    version="1.0.0"
)

app.add_middleware(LoggingMiddleware)
app.include_router(students_router)

@app.get("/")
def root():
    return {"message": "Backend operativo"}