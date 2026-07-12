# Modulo centralizado de configuracion (CA-010). El resto del proyecto
# (ca001_auth/security.py, ca005_db/database.py) sigue usando os.getenv()
# + load_dotenv() directamente; no se migro ese codigo existente a este
# modulo para no forzar un refactor fuera del alcance de este Core Asset.
# El codigo nuevo debe preferir "settings" en vez de os.getenv() suelto.
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "postgresql+psycopg2://postgres:postgres@localhost:5432/academico_db"
    jwt_secret_key: str = "super_secret_key_123"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30
    cors_origins: str = "http://localhost:5173"
    environment: str = "development"
    log_level: str = "INFO"

    @property
    def cors_origins_list(self) -> list[str]:
        return [origen.strip() for origen in self.cors_origins.split(",") if origen.strip()]


settings = Settings()
