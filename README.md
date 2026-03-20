# 🔍 DBT Data Observability

> Data observability pipeline built with **dbt Core** on **Microsoft SQL Server**, using the classic `jaffle_shop` dataset as a demonstration environment.

---

## 📋 Overview

This project demonstrates how to implement **data observability** practices within a dbt project connected to a SQL Server (MSSQL) instance. It leverages dbt's native testing and source freshness capabilities to monitor data quality, pipeline health, and model reliability.

The environment is fully containerized with Docker, making it easy to spin up locally on both **macOS** and **WSL (Windows Subsystem for Linux)**.

---

## 🗂️ Project Structure

```
DBT-data-observability/
├── jaffle_shop/          # dbt project (models, seeds, tests, profiles)
│   ├── models/
│   ├── seeds/
│   ├── tests/
│   └── requirements.txt
├── tests/
│   └── docker/           # Docker configuration for tests
├── docker-compose.yml    # MSSQL containers setup
├── how_to.md             # Quick start guide
└── README.md
```

---

## 🛠️ Tech Stack

| Tool | Role |
|---|---|
| **dbt Core** | Data transformation & testing |
| **Microsoft SQL Server 2022** | Data warehouse |
| **Docker / Docker Compose** | Local environment containerization |
| **Python 3.12** | dbt runtime & dependencies |

---

## ⚡ Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & Docker Compose
- Python 3.12
- WSL2 (Windows) or macOS

---

### 1. Start the MSSQL database

**WSL:**
```bash
docker compose build mssql.configurator
docker compose up -d mssql mssql.configurator --force-recreate
```

**macOS:**
```bash
docker-compose build mssql.configurator
docker-compose up -d mssql mssql.configurator --force-recreate
```

This will spin up two SQL Server databases:
- `sql_database_demo1`
- `sql_database_demo2`

The MSSQL instance is exposed on port `1437`.

---

### 2. Set up the Python environment

```bash
cd jaffle_shop
python3.12 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

---

### 3. Load seed data

```bash
source .venv/bin/activate
dbt deps
dbt seed
```

This loads **6 seed tables** into the database from the `jaffle_shop` dataset.

---

### 4. Run dbt models & tests

```bash
# Run all models
dbt run

# Run data quality tests
dbt test --store-failures #flag used to store non-conform values

```

---

## 🔌 Database Connection

The Docker Compose stack uses the following default credentials:

| Parameter | Value |
|---|---|
| Host | `localhost` |
| Port | `1437` |
| User | `sa` |
| Password | `Password123` |
| Databases | `sql_database_demo1`, `sql_database_demo2` |

> ⚠️ These credentials are for **local development only**. Never use them in a production environment.

---

## 📊 Data Observability Features

This project covers the following observability pillars through dbt:

- **Freshness** — `dbt source freshness` to detect stale data sources
- **Schema tests** — `not_null`, `unique`, `accepted_values`, `relationships`
- **Custom tests** — Business-logic validations on top of seed and model data
- **Run artifacts** — `manifest.json`, `run_results.json` for pipeline introspection

---

## 🌱 Dataset: Jaffle Shop

The `jaffle_shop` is dbt's canonical demo project simulating an e-commerce store. It includes:

- `customers`
- `orders`
- `payments`
- and related staging & marts models

It serves as the foundation to apply and demonstrate observability patterns in a realistic context.

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

---

## 📄 License

This project is open source. See the repository for details.
