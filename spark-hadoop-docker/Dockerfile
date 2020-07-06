#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM openjdk:8-slim

ENV SPARK_HOME /opt/spark
ARG SPARK_VERSION=2.4.5
ARG HADOOP_VERSION=2.7

# Variables that define which software versions to install.
ENV JAVA_HOME=/usr/local/openjdk-8

# Install dependencies
RUN apt update \
    && apt install -y curl \
    && apt install -y wget

# Download Spark Hadoop Image
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
      && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
      && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark \
      && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz 


# Setup dependencies for S3 storage access.
ARG HADOOP_AWS_VERSION=2.7.3
ARG AWS_JAVA_SDK_VERSION=1.7.4

# Add HADOOP_AWS_JAR and AWS_JAVA_SDK
# In 1.7.4, it's aws-java-sdk rather than aws-java-sdk-bundle
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-${AWS_JAVA_SDK_VERSION}.jar $SPARK_HOME/jars

# Add Minio jars
ADD https://repo1.maven.org/maven2/io/minio/minio/7.0.2/minio-7.0.2.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/github/spotbugs/spotbugs-annotations/4.0.0/spotbugs-annotations-4.0.0.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/google/guava/guava/25.1-jre/guava-25.1-jre.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.13.1/okhttp-3.13.1.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/squareup/okio/okio/1.17.2/okio-1.17.2.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/net/jcip/jcip-annotations/1.0/jcip-annotations-1.0.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/org/simpleframework/simple-xml/2.7.1/simple-xml-2.7.1.jar $SPARK_HOME/jars


# Setup for the Prometheus JMX exporter.
RUN mkdir -p /etc/metrics/conf
# Add the Prometheus JMX exporter Java agent jar for exposing metrics sent to the JmxSink to Prometheus.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
COPY conf/metrics.properties /etc/metrics/conf
COPY conf/prometheus.yaml /etc/metrics/conf

# Set necessary environment variables. 
#ENV SPARK_HOME="/opt/spark"
ENV PATH="/opt/spark/bin:${PATH}"
RUN echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath)" >> /opt/spark/conf/spark-env.sh

COPY entrypoint.sh /opt
RUN mkdir -p /opt/spark/work-dir 

# Add 'spark' user so that this cluster is not run as root.
RUN groupadd -g 1080 spark && \
    useradd -r -m -u 1080 -g spark spark && \
    chown -R -L spark /opt/spark && \
    chgrp -R -L spark /opt/spark
    
RUN chown spark /opt/entrypoint.sh

USER spark

WORKDIR /opt/spark/work-dir

ENTRYPOINT [ "/opt/entrypoint.sh" ]
