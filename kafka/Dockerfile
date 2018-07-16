FROM openjdk:8

ENV KAFKA_HOME=/opt/kafka
RUN mkdir -p /opt/
RUN mkdir -p /tmp
RUN wget -O /tmp/kafka.tgz http://ftp.jaist.ac.jp/pub/apache/kafka/1.1.0/kafka_2.11-1.1.0.tgz
RUN tar -xzf /tmp/kafka.tgz -C /opt/
RUN mv /opt/kafka_2.11-1.1.0 /opt/kafka
RUN rm -rf /opt/kafka/config
COPY ./config /opt/kafka/config
