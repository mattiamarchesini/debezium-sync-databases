export DEBEZIUM_VERSION='2.0'
export SQLSERVER_USER='sa'
export SQLSERVER_PW='Password!'
export SQLSERVER_PORT='1433'
export MYSQL_USER=''
export MYSQL_PW=''
export MYSQL_PORT='3306'
export KAFKA_PORT='9092'
export KAFKA_CONNECT_PORT='8083'

# Start the containers in detached mode
docker-compose up -d

# Start MySQL connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" "http://localhost:${KAFKA_CONNECT_PORT}/connectors/" -d @register-mysql.json

# Consume messages from a Debezium topic
# docker-compose -f docker-compose-mysql.yaml exec kafka /kafka/bin/kafka-console-consumer.sh \
#     --bootstrap-server kafka:${KAFKA_PORT} \
#     --from-beginning \
#     --property print.key=true \
#     --topic dbserver1.inventory.customers

# Modify records in the database via MySQL client
# docker-compose -f docker-compose-mysql.yaml exec mysql bash -c 'mysql -u $MYSQL_USER -p$MYSQL_PASSWORD inventory'

# Initialize database and insert test data
cat debezium-sqlserver-init/inventory.sql | docker-compose -f prova.yaml exec -T sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD'

# Start SQL Server connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:${KAFKA_CONNECT_PORT}/connectors/ -d @register-sqlserver.json

# Consume messages from a Debezium topic
docker-compose exec kafka /kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server "kafka:${KAFKA_PORT}" \
    --from-beginning \
    --property print.key=true \
    --topic server1.testDB.dbo.customers

# Modify records in the database via SQL Server client (do not forget to add `GO` command to execute the statement)
docker-compose exec sqlserver bash -c '/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -d testDB'

# Shut down the cluster
# docker-compose down