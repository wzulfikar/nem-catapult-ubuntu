FROM ubuntu:18.04 as builder

ARG BUILD_TYPE=Release
ARG WORK_PATH=/tmp

RUN mkdir -p ${WORK_PATH} \
  && apt-get update -y \
  && apt-get install make -y

WORKDIR ${WORK_PATH}

COPY Makefile .

RUN make install

RUN mkdir -p /tmp/deps && mkdir -p /tmp/localdep \
	&& cp /usr/local/lib/libboost_atomic* /tmp/deps \
	&& cp /usr/local/lib/libboost_chrono* /tmp/deps \
	&& cp /usr/local/lib/libboost_date_time* /tmp/deps \
	&& cp /usr/local/lib/libboost_filesystem* /tmp/deps \
	&& cp /usr/local/lib/libboost_log* /tmp/deps \
	&& cp /usr/local/lib/libboost_program_options* /tmp/deps \
	&& cp /usr/local/lib/libboost_regex* /tmp/deps \
	&& cp /usr/local/lib/libboost_system* /tmp/deps \
	&& cp /usr/local/lib/libboost_thread* /tmp/deps \
	&& cp /usr/local/lib/libboost_timer* /tmp/deps \
	&& cp /usr/local/lib/librocksdb* /tmp/deps \
	&& cp /usr/local/lib/libzmq* /tmp/deps \
	# Dependencies which catapult will only launch if they seem to be in the same
	# place as they are during compilation
	&& cp /usr/local/lib/libmongo* /tmp/localdep \
  && cp /usr/local/lib/libbson* /tmp/localdep

FROM ubuntu:18.04

RUN mkdir -p /catapult

COPY --from=builder /var/app/src/_build/bin/ /catapult
COPY --from=builder /tmp/deps/ /catapult
COPY --from=builder /tmp/localdep/ /usr/local/lib

WORKDIR /catapult
CMD ["/bin/bash"]