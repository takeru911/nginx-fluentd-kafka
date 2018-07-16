# nginx-fluentd-kafka

（おなかすいたので日本語）

## これはなんぞや

 * Kafkaのいろいろ検証用のリポジトリです。
 * nginx log -> fluentd -> Kafka(topic)なデータの流れ
   * nginx logはdockerのlog driverをfluentdにしているだけ
 * KafkaのProducer, Comsumerなんかを試したいがためのやつ
 

## 構成

```shell
~/w/w/kafka_sandbox ››› tree -L 2 ./                                                                    [master]
./
├ Makefile
├ README.md
├ fluentd
│   ├ Dockerfile
│   └ fluent.conf
├ kafka
│   ├ Dockerfile
│   └ config
└ nginx
    ├ Dockerfile
    └ nginx.conf
```

それぞれのディレクトリに、それぞれの設定なんかがかいてある

  * fluentd
    * fluent.conf: outでkafkaに行くように、基本defaultだけどflush時間だけいじった
  * kafka
    * config: 基本的にkafkaのdefaultをcopyしてきただけ
  * nginx
    * logのフォーマットだけ少しいじっている
    
## 実行

docker-composeなんてなかった

  * 各コンテナ起動

```shell
~/w/w/kafka_sandbox ››› make run
```

これでnginx, fluentd, kafka(zookeeper, kafka-server)が起動する。  
これでnginxのlogがkafkaのtestトピックに流れる.  
nginxはlocalhost:8080で公開されているので、ここにアクセスすればlogが流れてkafkaに行く。


  * topicを読みに行く
  
```shell
~/w/w/kafka_sandbox ››› make fetch-message
docker run --rm --link zookeeper:zk \
  --link kafka-server:ks kafka_sandbox:kafka \
  /opt/kafka/bin/kafka-console-consumer.sh  \
     --bootstrap-server ks:9092 --topic test --from-beginning
{"container_id":"dd8ec60cb6df9726397ff68a2ee4c7689400b058f002b04cc690e8829103d205","container_name":"/nginx","source":"stderr","log":"2018/07/16 06:13:24 [emerg] 7#7: io_setup() failed (38: Function not implemented)"}
{"container_id":"dd8ec60cb6df9726397ff68a2ee4c7689400b058f002b04cc690e8829103d205","container_name":"/nginx","source":"stderr","log":"2018/07/16 06:13:24 [emerg] 8#8: io_setup() failed (38: Function not implemented)"}
{"container_id":"dd8ec60cb6df9726397ff68a2ee4c7689400b058f002b04cc690e8829103d205","container_name":"/nginx","source":"stderr","log":"2018/07/16 06:13:24 [emerg] 9#9: io_setup() failed (38: Function not implemented)"}
{"container_id":"dd8ec60cb6df9726397ff68a2ee4c7689400b058f002b04cc690e8829103d205","container_name":"/nginx","source":"stderr","log":"2018/07/16 06:13:24 [emerg] 10#10: io_setup() failed (38: Function not implemented)"}
```

test topicに流れているmessageを取得する, from-beginningなので最初からとりに行く。  
ちなみに、fluentdのflush intervalは3sなのでlocalhost:8080にアクセスしたら3s後に流れていく。


  * topicに書き込む
  
```shell
~/w/w/kafka_sandbox ››› make send-message
docker run -i --rm --link zookeeper:zk \
  --link kafka-server:ks kafka_sandbox:kafka \
    /opt/kafka/bin/kafka-console-producer.sh --broker-list ks:9092 --topic test
>hogehoeg
>hugahuga
>^CMakefile:68: ターゲット 'send-message' のレシピで失敗しました
```

ctrl+cで抜けてください。これでtest topicに書き込まれるので、↑ので確認してください。

ほかはMakefileなんかを読んでもらえれば。
