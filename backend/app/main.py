from fastapi import FastAPI
from app.middleware.logging import LoggingMiddleware

app = FastAPI(
    title="Factory Backend Template",
    version="1.0.0"
)

app.add_middleware(LoggingMiddleware)

@app.get("/")
def root():
    return {"message": "Backend operativo"}