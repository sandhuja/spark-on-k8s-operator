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

ARG SPARK_IMAGE=gcr.io/spark-operator/spark:v2.4.5
FROM ${SPARK_IMAGE}

## Setup dependencies for Google Cloud Storage access.
#RUN rm $SPARK_HOME/jars/guava-14.0.1.jar
#ADD https://repo1.maven.org/maven2/com/google/guava/guava/23.0/guava-23.0.jar $SPARK_HOME/jars
## Add the connector jar needed to access Google Cloud Storage using the Hadoop FileSystem API.
#ADD https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-latest-hadoop2.jar $SPARK_HOME/jars
#ADD https://storage.googleapis.com/spark-lib/bigquery/spark-bigquery-latest.jar $SPARK_HOME/jars

# Setup dependencies for S3 storage access.
#ARG HADOOP_AWS_VERSION=2.7.3
#ARG AWS_JAVA_SDK_VERSION=1.7.4

ARG HADOOP_AWS_VERSION=3.2.0
ARG AWS_JAVA_SDK_VERSION=1.11.375

# Add HADOOP_AWS_JAR and AWS_JAVA_SDK
# In 1.7.4, it's aws-java-sdk rather than aws-java-sdk-bundle
ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-${AWS_JAVA_SDK_VERSION}.jar $SPARK_HOME/jars

# Add Minio jars
#ADD https://repo1.maven.org/maven2/io/minio/minio/7.0.2/minio-7.0.2.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/github/spotbugs/spotbugs-annotations/4.0.0/spotbugs-annotations-4.0.0.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/google/guava/guava/25.1-jre/guava-25.1-jre.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.13.1/okhttp-3.13.1.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/squareup/okio/okio/1.17.2/okio-1.17.2.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/net/jcip/jcip-annotations/1.0/jcip-annotations-1.0.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/org/simpleframework/simple-xml/2.7.1/simple-xml-2.7.1.jar $SPARK_HOME/jars

# Setup for the Prometheus JMX exporter.
RUN mkdir -p /etc/metrics/conf
# Add the Prometheus JMX exporter Java agent jar for exposing metrics sent to the JmxSink to Prometheus.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
COPY conf/metrics.properties /etc/metrics/conf
COPY conf/prometheus.yaml /etc/metrics/conf

ENTRYPOINT ["/opt/entrypoint.sh"]
