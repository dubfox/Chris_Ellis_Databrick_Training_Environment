#!/bin/bash

# Default values
IMAGE_NAME="jupyter-notebook"
IMAGE_TAG="latest"
PYTHON_VERSION="3.9-slim"
PORT="8888"
VOLUME_PATH="/opt/jupyter"
CONTAINER_NAME="jupyter_container"

# Function to remove special characters (only allow alphanumeric, dashes, and underscores)
sanitize_input() {
    echo "$1" | sed 's/[^a-zA-Z0-9_-]//g'
}

# Parse optional arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --image-name) IMAGE_NAME=$(sanitize_input "$2"); shift ;;
        --image-tag) IMAGE_TAG=$(sanitize_input "$2"); shift ;;
        --python-version) PYTHON_VERSION=$(sanitize_input "$2"); shift ;;
        --port) PORT=$(sanitize_input "$2"); shift ;;
        --volume) VOLUME_PATH="$2"; shift ;;  # Allow full paths
        --container-name) CONTAINER_NAME=$(sanitize_input "$2"); shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo "Building Docker image with the following settings:"
echo "  Image Name: $IMAGE_NAME"
echo "  Image Tag: $IMAGE_TAG"
echo "  Python Version: $PYTHON_VERSION"
echo "  Exposed Port: $PORT"
echo "  Volume Path: $VOLUME_PATH"
echo "  Container Name: $CONTAINER_NAME"

# Build the Docker image
docker build --build-arg PYTHON_VERSION="$PYTHON_VERSION" -t "$IMAGE_NAME:$IMAGE_TAG" .

# Check if the build was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to build Docker image $IMAGE_NAME:$IMAGE_TAG."
    exit 1
fi

echo "Docker image $IMAGE_NAME:$IMAGE_TAG built successfully."

# Check if a container with the same name exists
if [[ $(docker ps -a -q -f name="^${CONTAINER_NAME}$") ]]; then
    echo "Warning: Container with name $CONTAINER_NAME already exists. Restarting it..."
    docker start "$CONTAINER_NAME"
else
    echo "Starting Jupyter Notebook container..."
    docker run -d -p "$PORT":8888 -v "$VOLUME_PATH":/home/jovyan/work --name "$CONTAINER_NAME" "$IMAGE_NAME:$IMAGE_TAG"
fi

# Display logs to get Jupyter access URL
echo "Access Jupyter Notebook at: http://localhost:$PORT/"
docker logs "$CONTAINER_NAME" 2>&1 | grep -o "http://127.0.0.1:8888/.*"
