TMP_DIR := /tmp
WORKDIR := /opt/catapult-server

### utilities ###
up:
	cd ${WORKDIR}/bin && ./catapult.server

nemesis:
	@echo "generating nemesis block.."
	@echo "usage: make nemesis config=path/to/catapult-config.properties"
	# sample config: ${WORKDIR}/tools/nemgen/resources/mijin-test.properties

	${WORKDIR}/bin/catapult.tools.nemgen ${config}

	@echo "✔ nemesis block has been generated"

### installation overview ###

clean:
	rm -rf ${TMP_DIR}/*

install:
	make install-dependencies
	make parallel-install
	make install-catapult

	make workdir
	@echo "✔ Done!"

workdir:
	# create dir for data & mijin test seed
	mkdir -p ${WORKDIR}

	# there's one resources dir from build process, and another one
	# that contains catapult configs. the one from build process
	# has 'cmake_install.cmake' file in it, which we'll use
	# to identify the dir and move it to resources-bak so
	# that the resources dir that contains catapult
	# configs can be stored inside ${WORKDIR}
	@if [ -f ${WORKDIR}/resources/cmake_install.cmake ]; then \
		mv ${WORKDIR}/resources ${WORKDIR}/resources-bak; fi

	@if [ -d ${TMP_DIR}/catapult-server/resources ]; then \
		mv ${TMP_DIR}/catapult-server/resources ${WORKDIR}; fi

	# same case like resources dir
	@if [ -f ${WORKDIR}/tools/cmake_install.cmake ]; then \
		mv ${WORKDIR}/tools ${WORKDIR}/tools-bak; fi

	@if [ -d ${TMP_DIR}/catapult-server/tools ]; then \
		mv ${TMP_DIR}/catapult-server/tools ${WORKDIR}; fi

	mv ${TMP_DIR}/catapult-server/_build/* ${WORKDIR} \
	  && mkdir -p ${WORKDIR}/seed/mijin-test \
	  && mkdir -p ${WORKDIR}/data

parallel-install: install-gcc install-cmake install-mongoc
	make parallel-install-step-2

parallel-install-step-2: install-gtest install-rocksdb install-zmqlib install-mongocxx
	make install-cppzmq
	make install-boost
	@echo "✔ parallel-step-2 completed"

### installation details ###

install-dependencies:
	apt-get update -y && apt-get clean && apt-get install -y --no-install-recommends \
	  git \
	  wget \
	  autoconf \
	  automake \
	  apt-file \
	  build-essential \
	  software-properties-common \
	  pkg-config \
	  python3 \
	  python-dev \
	  libc6-dev \
	  libssl-dev \
	  libsasl2-dev \
	  libtool \
	  && apt-get clean && rm -rf /var/lib/apt/lists/*

install-gcc:
	add-apt-repository ppa:ubuntu-toolchain-r/test -y \
	  && apt-get update && apt-get install -y --no-install-recommends gcc-7 g++-7 \
	  && apt-get clean && rm -rf /var/lib/apt/lists/* \
	  && rm /usr/bin/gcc /usr/bin/g++ \
	  && ln -s /usr/bin/gcc-7 /usr/bin/gcc \
	  && ln -s /usr/bin/g++-7 /usr/bin/g++

install-cmake:
	if [ ! -d ${TMP_DIR}/cmake ]; then cd ${TMP_DIR} && git clone https://gitlab.kitware.com/cmake/cmake.git -b v3.11.1 --depth 1; fi
	cd ${TMP_DIR}/cmake && ./bootstrap --prefix=/usr/local && make -j4 && make install

install-boost:
	if [ ! -d ${TMP_DIR}/boost_1_65_1 ]; then cd ${TMP_DIR} \
		&& wget https://dl.bintray.com/boostorg/release/1.65.1/source/boost_1_65_1.tar.gz \
		&& tar xzf boost_1_65_1.tar.gz; fi

	cd ${TMP_DIR}/boost_1_65_1 && ./bootstrap.sh && ./b2 toolset=gcc install --prefix=/usr/local -j4

install-gtest:
	if [ ! -d ${TMP_DIR}/googletest ]; then cd ${TMP_DIR} && git clone https://github.com/google/googletest.git -b release-1.8.0 --depth 1; fi

	cd ${TMP_DIR}/googletest && mkdir -p googletest/_build \
		&& cd googletest/_build \
	  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install

install-rocksdb:
	if [ ! -d ${TMP_DIR}/rocksdb ]; then cd ${TMP_DIR} && git clone https://github.com/facebook/rocksdb.git -b v5.12.4 --depth 1; fi

	mkdir -p ${TMP_DIR}/rocksdb/_build && cd ${TMP_DIR}/rocksdb/_build \
	  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install

install-zmqlib:
	if [ ! -d ${TMP_DIR}/libzmq ]; then cd ${TMP_DIR} && git clone https://github.com/zeromq/libzmq.git -b v4.2.3 --depth 1; fi

	mkdir -p ${TMP_DIR}/libzmq/_build && cd ${TMP_DIR}/libzmq/_build \
	  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install

install-cppzmq:
	if [ ! -d ${TMP_DIR}/cppzmq ]; then cd ${TMP_DIR} && git clone https://github.com/zeromq/cppzmq.git -b v4.2.3 --depth 1; fi

	mkdir -p ${TMP_DIR}/cppzmq/_build && cd ${TMP_DIR}/cppzmq/_build \
	  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local .. && make -j4 && make install

install-mongoc:
	if [ ! -d ${TMP_DIR}/mongo-c-driver ]; then cd ${TMP_DIR} && git clone https://github.com/mongodb/mongo-c-driver.git -b 1.4.3 --depth 1; fi

	cd ${TMP_DIR}/mongo-c-driver \
		&& ./autogen.sh && ./configure --disable-automatic-init-and-cleanup --prefix=/usr/local \
	  && make -j4 && make install

install-mongocxx:
	if [ ! -d ${TMP_DIR}/mongo-cxx-driver ]; then cd ${TMP_DIR} && git clone https://github.com/mongodb/mongo-cxx-driver.git -b r3.0.2 --depth 1; fi

	cd ${TMP_DIR}/mongo-cxx-driver/build \
	  && cmake -DBSONCXX_POLY_USE_BOOST=1 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. \
	  && make -j4 && make install

install-catapult:
	if [ ! -d ${TMP_DIR}/catapult-server ]; then cd ${TMP_DIR} && git clone https://github.com/nemtech/catapult-server.git -b master --depth 1; fi

	cd ${TMP_DIR}/catapult-server && mkdir _build && cd _build \
  	&& cmake -DCMAKE_BUILD_TYPE=RelWithDebugInfo \
	    -DCMAKE_CXX_FLAGS="-pthread" \
	    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
	    -DBSONCXX_LIB=/usr/local/lib/libbsoncxx.so \
	    -DMONGOCXX_LIB=/usr/local/lib/libmongocxx.so \
	    .. \
  	&& make publish && make -j4