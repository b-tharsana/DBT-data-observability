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
 
## 📊 Core Behavior — Test History Persistence
 
The central feature of this project is a **modified `store_test_failures` macro** that overrides dbt's default `--store-failures` behavior to persist test results in a **non-destructive, append-only** fashion.
 
### The problem with dbt's default `--store-failures`
 
By default, when running `dbt test --store-failures`, dbt creates temporary tables for failing rows — but **recreates (truncates) them on every run**, losing all history.
 
### What this project does differently
 
The macro is modified so that instead of recreating tables, it **appends results** on every run, producing two permanent tables in MSSQL:
 
| Table | Content |
|---|---|
| `MONITOR_TABLE` | Execution log — one row per test run: test name, model, status (`pass`/`fail`), failure count, timestamp |
| `HISTO_ANOMALIES_FAILURES` | Failure detail — the actual offending rows for each failed test, with the run timestamp for traceability |
 
These tables are **never truncated**. Every `dbt test --store-failures` invocation appends new data, building a full historical record of your data quality over time.
 
### Gold Layer — `gold_anomalies`
 
The `gold_anomalies` models read from `MONITOR_TABLE` and `HISTO_ANOMALIES_FAILURES` to produce **aggregated, BI-ready indicators** consumable directly from any BI tool (Power BI, Tableau, Metabase…).
 
Examples of generated metrics:
 
- Repair rate
- Most frequently failing models
- Perimeter impacted

### Usage
 
```bash
# Run tests
dbt test --store-failures
# → tests are executed
# → execution logs are appended to MONITOR_TABLE
# → failing row details are appended to HISTO_ANOMALIES_FAILURES

# Run gold level model
dbt run --select +gold_anomalies
# → read MONITOR_TABLE + HISTO_ANOMALIES_FAILURES
# → generate agregate table ready for BI tool
```
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
