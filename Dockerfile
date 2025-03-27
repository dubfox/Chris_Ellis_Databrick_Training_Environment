# Use the official Jupyter Data Science image as base
FROM jupyter/datascience-notebook:latest

# Set the working directory inside the container
WORKDIR /home/jovyan/work

# Set environment variables for Spark
ENV SPARK_VERSION=3.5.4
ENV HADOOP_VERSION=3
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV SPARK_HOME=/opt/spark
ENV DELTA_VERSION=3.1.0
ENV SCALA_VERSION=2.12
ENV PYSPARK_PIN_THREAD=false
ENV PATH="$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"
ENV MLFLOW_SPARK_VERSION=2.0.1

# Switch to root user for installations
USER root

# Install Java (required for Spark) & SQLite
RUN apt-get update && apt-get install -y sqlite3 openjdk-11-jdk curl sudo rsync && apt-get clean

RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/jovyan && chmod 0440 /etc/sudoers.d/jovyan


# Ensure necessary directories exist and have correct permissions
RUN mkdir -p /mnt/delta/ /mlflow/artifacts /home/jovyan/mlruns && \
    chmod -R 777 /mnt/delta/ /mlflow/artifacts /home/jovyan/mlruns

# Install Spark and Hadoop Dependencies
RUN curl -fSL --retry 3 --retry-delay 5 \
    "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -o /tmp/spark.tgz && \
    tar -xzf /tmp/spark.tgz -C /opt/ && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_HOME && \
    rm /tmp/spark.tgz

# Download and install Delta Lake JARs
RUN mkdir -p /opt/spark/jars && \
    curl -fSL --retry 3 --retry-delay 5 \
    "https://repo1.maven.org/maven2/io/delta/delta-spark_${SCALA_VERSION}/${DELTA_VERSION}/delta-spark_${SCALA_VERSION}-${DELTA_VERSION}.jar" -o /opt/spark/jars/delta-spark_${SCALA_VERSION}-${DELTA_VERSION}.jar && \
    curl -fSL --retry 3 --retry-delay 5 \
    "https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/delta-storage-${DELTA_VERSION}.jar" -o /opt/spark/jars/delta-storage-${DELTA_VERSION}.jar


RUN curl -fSL --retry 3 --retry-delay 5 \
        "https://repo1.maven.org/maven2/org/mlflow/mlflow-spark/${MLFLOW_SPARK_VERSION}/mlflow-spark-${MLFLOW_SPARK_VERSION}.jar" \
        -o /opt/spark/jars/mlflow-spark-${MLFLOW_SPARK_VERSION}.jar
    



# Copy the .env file into the working directory
COPY .env /home/jovyan/work/.env
RUN chmod 644 /home/jovyan/work/.env

# Install additional dependencies
RUN pip install --no-cache-dir python-dotenv

COPY start.sh /start.sh
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf
RUN chmod +x /start.sh
RUN chown jovyan:users /opt/spark/conf/spark-defaults.conf 

# Change ownership back to Jupyter user
RUN chown -R jovyan:users $SPARK_HOME /opt/spark/jars /opt/spark/conf /home/jovyan/mlruns

# Switch back to jovyan user
USER jovyan

# Install additional Python libraries for Machine Learning, Spark & Delta Lake
RUN pip install --no-cache-dir \
    mlflow \
    pyspark==${SPARK_VERSION} \
    pymongo \ 
    dotenv \
    delta-spark==${DELTA_VERSION} \
    tensorflow \
    torch torchvision torchaudio \
    scikit-learn \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    hyperopt \
    xgboost \
    lightgbm \
    boto3 \
    requests \
    findspark \
    databricks-feature-store \
    tabulate \
    pandas-ta \
    transformers \
    accelerate \
    fastapi \
    uvicorn \
    tiktoken \
    yfinance

    
# Set MLflow tracking URI (Local SQLite database)
ENV MLFLOW_TRACKING_URI="sqlite:///mlflow.db"

# Set required Spark session extensions for Delta Lake & LogStore
ENV PYSPARK_SUBMIT_ARGS="--jars /opt/spark/jars/delta-spark_${SCALA_VERSION}-${DELTA_VERSION}.jar,/opt/spark/jars/delta-storage-${DELTA_VERSION}.jar pyspark-shell"

# Expose necessary ports
EXPOSE 8888 4040 8080 7077 5000

# Start MLflow server on container startup (accessible externally)

ENTRYPOINT ["/start.sh"]

