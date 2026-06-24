# Academico — Backend

REST API built with FastAPI and PostgreSQL for academic management.

## Tech Stack

- Python 3.12
- FastAPI
- PostgreSQL
- SQLAlchemy 2.0
- Alembic
- Pydantic v2
- GraphQL *(future sprint)*

## Project Structure

```
backend/
├── app/
│   ├── api/
│   │   ├── routes/
│   │   └── dependencies/
│   ├── core/
│   │   ├── config.py        # Environment settings
│   │   ├── database.py      # SQLAlchemy engine and session
│   │   ├── base.py          # Declarative base
│   │   └── init_db.py       # Table creation
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic schemas
│   ├── services/            # Business logic
│   ├── middleware/          # HTTP middleware
│   └── main.py              # App entrypoint
├── tests/
├── requirements.txt
├── .env
└── README.md
```

## Setup

```bash
git clone <repository>
cd backend

python -m venv venv
source venv/Scripts/activate        # Windows
# source venv/bin/activate          # Linux / macOS

pip install -r requirements.txt
```

## Environment

Create a `.env` file in `backend/`:

```env
DATABASE_URL=postgresql://postgres:1234@localhost:5432/factory_db
```

## Initialize Database

```bash
python -m app.core.init_db
```

## Run

```bash
uvicorn app.main:app --reload
```

API available at `http://localhost:8000`
Interactive docs at `http://localhost:8000/docs`
