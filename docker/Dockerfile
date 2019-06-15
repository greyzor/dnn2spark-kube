## Default versions:
## tensorflow.__version__ : 2.0.0-dev20190611
FROM ufoym/deepo:keras

RUN apt-get update && \
	add-apt-repository ppa:openjdk-r/ppa && \
	apt-get install -y openjdk-8-jdk && \
	update-alternatives --config java

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ARG spark_jars=jars
ARG img_path=kubernetes/dockerfiles
ARG k8s_tests=kubernetes/tests

# Before building the docker image, first build and make a Spark distribution following
# the instructions in http://spark.apache.org/docs/latest/building-spark.html.
# If this docker file is being used in the context of building your images from a Spark
# distribution, the docker build command should be invoked from the top level directory
# of the Spark distribution. E.g.:
# docker build -t spark:latest -f kubernetes/dockerfiles/spark/Dockerfile .

RUN set -ex && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd

# Install Spark
RUN mkdir -p /opt/spark/jars

COPY spark/${spark_jars} /opt/spark/jars
COPY spark/bin /opt/spark/bin
COPY spark/sbin /opt/spark/sbin
COPY spark/${img_path}/spark/entrypoint.sh /opt/
COPY spark/examples /opt/spark/examples
COPY spark/${k8s_tests} /opt/spark/tests
COPY spark/data /opt/spark/data

ENV SPARK_HOME /opt/spark
WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]

# Install custom Python scripts
ARG py_scripts=./py_scripts/
ADD ${py_scripts} /opt/py_scripts/

# Requirements specific to current Python scripts
## FIXME: downgrade numpy from 1.16.4 to 1.16.1 to fix keras imdb.load_data bug
# https://stackoverflow.com/questions/55890813/how-to-fix-object-arrays-cannot-be-loaded-when-allow-pickle-false-for-imdb-loa
RUN pip install numpy==1.16.1

## FIXME: downgrade tensorflow from 2.0.0b2
RUN pip install tensorflow==1.13.1
RUN pip install pyspark elephas

## FIXME: downloading data locally since pods by defaut cannot access internet.
##  We should patch coredns to reach 8.8.8.8 like nameserver.
RUN mkdir -p ~/.keras/datasets/ && \
	wget https://s3.amazonaws.com/text-datasets/imdb.npz -O ~/.keras/datasets/imdb.npz && \
	wget https://s3.amazonaws.com/text-datasets/imdb_word_index.json -O ~/.keras/datasets/imdb_word_index.json