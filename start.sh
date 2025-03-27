#!/bin/bash
set -e

ROLE=${SPARK_ROLE:-master}
SPARK_MASTER_HOST=${SPARK_MASTER_HOST:-spark-master}
# Fix ownership (now with sudo!)
sudo chown jovyan:users /opt/spark/conf/spark-defaults.conf

if [ "$ROLE" = "master" ]; then
    echo "? Starting Spark Master + Jupyter + MLflow..."

    # Start Spark master
    ${SPARK_HOME}/sbin/start-master.sh

    # Start MLflow and Jupyter in the background
    mlflow server --host 0.0.0.0 --port 5000 \
        --backend-store-uri sqlite:///mlflow.db \
        --default-artifact-root /mlflow/artifacts &

    # Start Jupyter
    exec start-notebook.sh --NotebookApp.token='' --NotebookApp.password=''

elif [ "$ROLE" = "worker" ]; then
    echo "? Starting Spark Worker..."
    ${SPARK_HOME}/sbin/start-worker.sh spark://${SPARK_MASTER_HOST}:7077
    tail -f ${SPARK_HOME}/logs/*

else
    echo "? Starting Jupyter Notebook (standalone)..."
    exec start-notebook.sh --NotebookApp.token='' --NotebookApp.password=''
fi
