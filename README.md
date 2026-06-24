# Academico — Backend

REST API built with FastAPI and PostgreSQL for academic management.

## Tech Stack

- Python 3.12
- FastAPI
- PostgreSQL
- SQLAlchemy 2.0
- Alembic
- Pydantic v2
- GraphQL _(future sprint)_

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

# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some Oxlint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Oxc](https://oxc.rs)
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/)

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the Oxlint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and Oxlint's TypeScript related rules in your project.
