  
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#ARG java_image_tag=8-jre-slim
ARG java_image_tag=8u242-jre-slim

FROM openjdk:${java_image_tag}
#FROM openjdk:8-slim

ARG spark_uid=185
RUN useradd -u ${spark_uid} spark

RUN set -ex && \
    sed -i 's/http:\/\/deb.\(.*\)/https:\/\/deb.\1/g' /etc/apt/sources.list && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules krb5-user libnss3 procps && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

ARG SPARK_VERSION=2.4.5
ARG HADOOP_VERSION=2.7

#ARG HADOOP_AWS_VERSION=2.7.3
ARG HADOOP_AWS_VERSION=2.6.0-cdh5.16.2
ARG AWS_JAVA_SDK_VERSION=1.7.4

#ARG HADOOP_AWS_VERSION=3.2.0
#ARG AWS_JAVA_SDK_VERSION=1.11.375

# Variables that define which software versions to install.
ENV JAVA_HOME=/usr/local/openjdk-8

# Install dependencies
RUN apt update \
    && apt install -y curl \
    && apt install -y wget
    
# Setup for the Prometheus JMX exporter.
RUN mkdir -p /etc/metrics/conf
# Add the Prometheus JMX exporter Java agent jar for exposing metrics sent to the JmxSink to Prometheus.
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar /prometheus/
COPY conf/metrics.properties /etc/metrics/conf
COPY conf/prometheus.yaml /etc/metrics/conf

####################################################################################
# Download and extract the Hadoop binary package.
#RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_AWS_VERSION/hadoop-$HADOOP_AWS_VERSION.tar.gz \
RUN curl http://archive.cloudera.com/cdh5/cdh/5/hadoop-$HADOOP_AWS_VERSION.tar.gz \
	| tar xvz -C /opt/  \
	&& ln -s /opt/hadoop-$HADOOP_AWS_VERSION /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc
	
#RUN curl http://archive.cloudera.com/cdh5/cdh/5/hbase-1.2.0-cdh5.16.2.tar.gz \
#	| tar xvz -C /opt/  \
#	&& ln -s /opt/hbase-1.2.0-cdh5.16.2 /opt/hadoop/hbase  

# Add S3a jars to the classpath using this hack.
RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

# Add 'hadoop' user so that this cluster is not run as root.
#RUN groupadd -g 1010 hadoop && \
#    useradd -r -m -u 1010 -g hadoop hadoop && \
#    mkdir -p /opt/hadoop/logs && \
#    chown -R -L hadoop /opt/hadoop && \
#    chgrp -R -L hadoop /opt/hadoop
    
RUN groupadd -f -g 1010 hadoop && \
    usermod -G hadoop spark && \
    mkdir -p /opt/hadoop/logs && \
    chown -R -L spark /opt/hadoop && \
    chgrp -R -L hadoop /opt/hadoop



# Set necessary environment variables. 
ENV HADOOP_HOME="/opt/hadoop"
#ENV HBASE_HOME="/opt/hadoop/hbase"
#ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop:$HBASE_HOME/conf
#ENV PATH="$HADOOP_HOME/bin:$HBASE_HOME/bin:${PATH}"
ENV PATH="$HADOOP_HOME/bin:${PATH}"


####################################################################################

# Download Spark Hadoop Image
#https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz

#RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
#      && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
#      && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_HOME \
#      && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz 

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
      && tar -xvzf spark-${SPARK_VERSION}-bin-without-hadoop.tgz \
      && mv spark-${SPARK_VERSION}-bin-without-hadoop /opt/spark \
      && rm spark-${SPARK_VERSION}-bin-without-hadoop.tgz 

# Add HADOOP_AWS_JAR and AWS_JAVA_SDK
#ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar /opt/spark/jars
#ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar /opt/spark/jars

# Set necessary environment variables. 
ENV SPARK_HOME="/opt/spark"
ENV PATH="${SPARK_HOME}/bin:${PATH}"

#RUN rm $SPARK_HOME/jars/guava-14.0.1.jar
ADD https://repo1.maven.org/maven2/com/google/guava/guava/23.0/guava-23.0.jar $SPARK_HOME/jars

COPY jars/appender-core-2.6.0.jar $SPARK_HOME/jars
COPY jars/log4j-api-2.13.3.jar $SPARK_HOME/jars
COPY jars/log4j-api-scala_2.13-12.0.jar $SPARK_HOME/jars
COPY jars/log4j-core-2.13.3.jar $SPARK_HOME/jars
COPY jars/log4j-slf4j-impl-2.13.3.jar $SPARK_HOME/jars
COPY jars/log4js3-1.0.0.jar $SPARK_HOME/jars
COPY jars/slf4j-api-1.7.25.jar $SPARK_HOME/jars
# Add log4j 1.2 compatibility
ADD https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-1.2-api/2.13.3/log4j-1.2-api-2.13.3.jar $SPARK_HOME/jars

## Add Minio jars
ADD https://repo1.maven.org/maven2/io/minio/minio/7.0.2/minio-7.0.2.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-annotations/2.10.3/jackson-annotations-2.10.3.jar $SPARK_HOME/jars/minio
#ADD https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-core/2.10.3/jackson-core-2.10.3.jar $SPARK_HOME/jars/minio
#ADD https://repo1.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.10.3/jackson-databind-2.10.3.jar $SPARK_HOME/jars/minio
ADD https://repo1.maven.org/maven2/com/github/spotbugs/spotbugs-annotations/4.0.0/spotbugs-annotations-4.0.0.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar $SPARK_HOME/jars
#ADD https://repo1.maven.org/maven2/com/google/guava/guava/25.1-jre/guava-25.1-jre.jar $SPARK_HOME/jars/minio
ADD https://repo1.maven.org/maven2/com/squareup/okhttp3/okhttp/3.13.1/okhttp-3.13.1.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/com/squareup/okio/okio/1.17.2/okio-1.17.2.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/net/jcip/jcip-annotations/1.0/jcip-annotations-1.0.jar $SPARK_HOME/jars
ADD https://repo1.maven.org/maven2/org/simpleframework/simple-xml/2.7.1/simple-xml-2.7.1.jar $SPARK_HOME/jars

RUN rm $HADOOP_HOME/share/hadoop/common/lib/log4j-1.2.17.jar \
   && rm $HADOOP_HOME/share/hadoop/common/lib/slf4j-api-1.7.5.jar \
   && rm $HADOOP_HOME/share/hadoop/common/lib/slf4j-log4j12-1.7.5.jar
   

# Add 'spark' user so that this cluster is not run as root.
#RUN groupadd -g 1080 spark && \
#    useradd -r -m -u 1080 -g spark spark && \
#    chown -R -L spark /opt/spark && \
#    chgrp -R -L spark /opt/spark

RUN groupadd -f -g 1080 spark && \
    usermod -g spark spark && \
    chown -R -L spark /opt/spark && \
    chgrp -R -L spark /opt/spark
    
#USER spark
#WORKDIR /home/spark



#ENV SPARK_CONF_DIR=$SPARK_HOME/conf
#RUN mkdir $SPARK_CONF_DIR
#COPY conf/spark-env.sh $SPARK_CONF_DIR


#RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native" >> $SPARK_HOME/conf/spark-env.sh
#RUN echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath)" >> $SPARK_HOME/conf/spark-env.sh
#RUN echo "export HADOOP_HOME=/opt/hadoop" >> $SPARK_HOME/conf/spark-env.sh
#RUN echo "export HADOOP_CONF_DIR=$HADOOP_HOME/conf" >> $SPARK_HOME/conf/spark-env.sh


# Retrieve Spark cloud jar      
#ADD https://repository.cloudera.com/artifactory/cloudera-repos/org/apache/spark/spark-hadoop-cloud_2.11/2.4.0-cdh6.3.3/spark-hadoop-cloud_2.11-2.4.0-cdh6.3.3.jar $SPARK_HOME/jars
#ADD http://repo1.purestorage.int/spark/2.4.6/hadoop-cloud/spark-hadoop-cloud_2.11-2.4.4.3.1.6.3-1.jar $SPARK_HOME/jars      

# Setup dependencies for S3 storage access.
# Add HADOOP_AWS_JAR and AWS_JAVA_SDK
# In 1.7.4, it's aws-java-sdk rather than aws-java-sdk-bundle
#ADD https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_AWS_VERSION}/hadoop-aws-${HADOOP_AWS_VERSION}.jar $SPARK_HOME/jars/minio
#ADD https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-${AWS_JAVA_SDK_VERSION}.jar $SPARK_HOME/jars/minio

#RUN mkdir $SPARK_HOME/jars/minio



# Add minio jars to the hadoop classpath using this hack.
#RUN ln -s $SPARK_HOME/jars/minio/* /opt/hadoop/share/hadoop/common/lib/

#RUN cp $SPARK_HOME/jars/minio/minio-7.0.2.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/jackson-annotations-2.10.3.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/jackson-core-2.10.3.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/jackson-databind-2.10.3.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/spotbugs-annotations-4.0.0.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/jsr305-3.0.2.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/guava-25.1-jre.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/okhttp-3.13.1.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/okio-1.17.2.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/jcip-annotations-1.0.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
#    cp $SPARK_HOME/jars/minio/simple-xml-2.7.1.jar $HADOOP_HOME/share/hadoop/common/lib/


#COPY classpath.sh /opt
#RUN chmod a+x /opt/classpath.sh
#RUN ./opt/classpath.sh

#RUN cd $SPARK_HOME/jars
#ENV VAR="$(ls | xargs realpath  |  tr '\n' ':')"
#ENV SPARK_CLASSPATH="$SPARK_CLASSPATH:$VAR"
#RUN echo "spark.driver.extraClassPath=$SPARK_CLASSPATH" >> $SPARK_HOME/conf/spark.properties
#RUN echo "spark.executor.extraClassPath=$SPARK_CLASSPATH" >> $SPARK_HOME/conf/spark.properties

USER spark
RUN mkdir -p /opt/spark/work-dir 
WORKDIR /opt/spark/work-dir

USER root
COPY entrypoint.sh /opt
COPY decom.sh /opt
RUN chmod g+w /opt/spark/work-dir
RUN chmod a+x /opt/decom.sh
RUN chmod a+x /opt/entrypoint.sh


ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Specify the User that the actual main process will run as
USER ${spark_uid}
#USER spark
