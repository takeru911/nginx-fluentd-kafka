TOPIC_NAME:=test

build: build/nginx build/fluentd build/kafka

run:
	@echo "stating, docker containers(kafka, nginx, fluentd)."
	$(MAKE) run/kafka
	sleep 15
	$(MAKE) run/fluentd
	sleep 10
	$(MAKE) run/nginx

run/kafka: kafka.run
	docker run --rm -p 2181:2181 \
	  --name zookeeper kafka_sandbox:kafka \
	  /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties &
	sleep 15
	docker run --rm -p 9092:9092 \
	  --link zookeeper:zk --name kafka-server kafka_sandbox:kafka \
	  /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties &

kafka.run:
	@touch kafka.run

build/%:
	docker build -t kafka_sandbox:$* $*/ 

run/nginx: nginx.run
	docker run --log-driver=fluentd --rm -p 8080:80 \
	  --name nginx kafka_sandbox:nginx &

nginx.run:
	@touch nginx.run

run/fluentd: fluentd.run
	docker run --rm -p 24224:24224 \
	  --name fluentd --link kafka-server:ks kafka_sandbox:fluentd &

fluentd.run:
	@touch fluentd.run

kill:
	@echo "kill container is below"
	@docker ps
	@echo "all container is kill, after 5 seconds"
	sleep 5
	-docker ps | sed -e '1d' | awk '{print $$1}' | xargs docker kill
	@$(MAKE) clean

clean:
	rm kafka.run
	rm nginx.run
	rm fluentd.run

# run kafka sample codes.
create-topic:
	docker run --rm --link zookeeper:zk \
	  --link kafka-server:ks kafka_sandbox:kafka \
	  /opt/kafka/bin/kafka-topics.sh --create --zookeeper zk:2181  \
      --replication-factor 1 --partitions 1 --topic $(TOPIC_NAME)

list-topic:
	docker run --rm --link zookeeper:zk \
	  --link kafka-server:ks kafka_sandbox:kafka \
	  /opt/kafka/bin/kafka-topics.sh --list --zookeeper zk:2181

send-message:
	-docker run -i --rm --link zookeeper:zk \
	  --link kafka-server:ks kafka_sandbox:kafka \
	  /opt/kafka/bin/kafka-console-producer.sh --broker-list ks:9092 --topic $(TOPIC_NAME)

fetch-message:
	-docker run --rm --link zookeeper:zk \
	  --link kafka-server:ks kafka_sandbox:kafka \
	  /opt/kafka/bin/kafka-console-consumer.sh  \
	    --bootstrap-server ks:9092 --topic $(TOPIC_NAME) --from-beginning

