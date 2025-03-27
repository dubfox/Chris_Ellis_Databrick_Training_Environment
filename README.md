
---

# Jupyter + Spark + MLflow Containerized Environment

## What is This?

A fully containerized development environment for running Jupyter notebooks with built-in support for:
- Apache Spark + Delta Lake
- MLflow tracking
- Python-based ML/AI libraries (PyTorch, TensorFlow, Scikit-learn, etc.)

Includes helper scripts for easy image building, container launching, and terminal access.

---

## Quick Start

```bash
./run-notebook.sh
```

Access:
- Jupyter Notebook ? [http://localhost:8888](http://localhost:8888)
- MLflow UI ? [http://localhost:5000](http://localhost:5000)
- Spark UI ? [http://localhost:4040](http://localhost:4040)

---

## Project Structure

| File                  | Purpose                                               |
|-----------------------|-------------------------------------------------------|
| `Dockerfile`          | Base image build (Jupyter + Spark + MLflow)           |
| `build-image.sh`      | Standalone image build script with argument support   |
| `run-notebook.sh`     | Build (if needed) and run container with port/volume  |
| `docker-terminal.sh`  | Open an interactive shell into the running container  |
| `.env`                | Injected env variables (excluded from Git)            |
| `README.md`           | Project documentation                                 |

---

## Build & Run Scripts

### `build-image.sh`
- Builds the Docker image separately from the runtime logic

```bash
./build-image.sh
```

---

### `run-notebook.sh`
- Builds (if not already built) and starts the container
- Mounts local volume and maps ports for Jupyter, MLflow, and Spark UI
- Accepts overrides for port, volume path, image name, etc.

```bash
./run-notebook.sh
```

---

### `docker-terminal.sh`
- Opens a terminal session inside the running container.

```bash
./docker-terminal.sh
```

---

## Configuration & Environment

- Uses `.env` to inject environment variables into the container
- Sensitive keys or tokens should be stored here (excluded via `.gitignore`)

---

## What's Inside

- ML Libraries: `mlflow`, `pyspark`, `delta-spark`, `tensorflow`, `torch`, `scikit-learn`, `xgboost`, `lightgbm`
- Data tools: `pandas`, `numpy`, `matplotlib`, `seaborn`, `pandas-ta`
- NLP & API tools: `transformers`, `fastapi`, `uvicorn`, `tiktoken`, `boto3`, `hyperopt`

---

## Volumes & Ports

| Feature            | Path/Port                       |
|--------------------|----------------------------------|
| Notebook Workspace | `/home/jovyan/work`             |
| MLflow Artifacts   | `/mlflow/artifacts`             |
| Jupyter            | Port `8888`                     |
| MLflow             | Port `5000`                     |
| Spark UI           | Port `4040`                     |

---

## Ideal For

- End-to-end ML experimentation with tracking
- Delta Lake + Spark pipelines
- Real-time analytics and big data notebooks
- Fast prototyping with full container isolation

---

## Contributing

Suggestions and pull requests are welcome! Fork it, tweak it, and let us know how it can be improved.

---
```