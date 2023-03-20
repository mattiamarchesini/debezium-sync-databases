ARG DEBEZIUM_VERSION
FROM quay.io/debezium/connect:$DEBEZIUM_VERSION
ENV KAFKA_CONNECT_JDBC_DIR=$KAFKA_CONNECT_PLUGINS_DIR/kafka-connect-jdbc

# These should point to the driver version to be used
ENV MAVEN_DEP_DESTINATION=$KAFKA_CONNECT_JDBC_DIR \
    REPO="confluent" \
    PACKAGE="kafka-connect-jdbc" \
    VERSION="5.4.0" \
    MD5_CHECKSUM="70B7ABBF19AA4CF57DCAF4B0B075D937"

RUN mkdir ${KAFKA_CONNECT_JDBC_DIR} && docker-maven-download "${REPO}" "$PACKAGE" "$VERSION" "$MD5_CHECKSUM"

USER kafka