#!/bin/bash

# Variables
IMAGE_NAME="jupyter-notebook"
CONTAINER_NAME="jupyter_container"
HOST_JUPYTER_PORT=8888
CONTAINER_JUPYTER_PORT=8888
HOST_MLFLOW_PORT=5001
CONTAINER_MLFLOW_PORT=5000
PYTHON_VERSION="3.9-slim"  # Default Python version for the base image
JUPYTER_VOLUME="/opt/jupyter:/home/jovyan/work"
MLFLOW_VOLUME="/opt/mlflow:/mlflow"  # New volume for MLflow persistence

# Validate volume mount paths
if [[ ! -d "/opt/jupyter" ]]; then
    echo "Error: Host data folder '/opt/jupyter' does not exist."
    exit 1
fi

if [[ ! -d "/opt/mlflow" ]]; then
    echo "Error: Host data folder '/opt/mlflow' does not exist."
    echo "Creating '/opt/mlflow' directory..."
    mkdir -p /opt/mlflow
fi

# Build Docker image if not exists
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo "Building Docker image $IMAGE_NAME..."
    if ! docker build --build-arg PYTHON_VERSION=$PYTHON_VERSION -t $IMAGE_NAME .; then
        echo "Error: Docker image build failed. Check your Dockerfile."
        exit 1
    fi
else
    echo "Docker image $IMAGE_NAME already exists."
fi

# Stop and remove existing container if running
RUNNING_CONTAINER=$(docker ps -q -f name=$CONTAINER_NAME)
STOPPED_CONTAINER=$(docker ps -a -q -f name=$CONTAINER_NAME)

if [[ -n "$RUNNING_CONTAINER" ]]; then
    echo "Stopping and removing running container $CONTAINER_NAME..."
    docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME
elif [[ -n "$STOPPED_CONTAINER" ]]; then
    echo "Removing stopped container $CONTAINER_NAME..."
    docker rm $CONTAINER_NAME
fi

# Run the Docker container with Jupyter and MLflow ports exposed
echo "Starting container $CONTAINER_NAME..."
if ! docker run -d \
    --name $CONTAINER_NAME \
    -p $HOST_JUPYTER_PORT:$CONTAINER_JUPYTER_PORT \
    -p $HOST_MLFLOW_PORT:$CONTAINER_MLFLOW_PORT \
    -v $JUPYTER_VOLUME \
    -v $MLFLOW_VOLUME \
    $IMAGE_NAME \
    sh -c "mlflow server --host 0.0.0.0 --port 5000 \
                --backend-store-uri sqlite:///mlflow.db \
                --default-artifact-root /mlflow/artifacts & \
           start-notebook.sh --NotebookApp.token='' --NotebookApp.password=''"; then
    echo "Error: Failed to start the container."
    exit 1
fi

# Display logs
echo "Container $CONTAINER_NAME is running."
echo "Access Jupyter Notebook at: http://localhost:$HOST_JUPYTER_PORT"
echo "Access MLflow UI at: http://localhost:$HOST_MLFLOW_PORT"
docker logs -f $CONTAINER_NAME
