FROM ubuntu:25.04

MAINTAINER Xaeroxe <jake@bitcrafters.co>

#ARG BUILD_DATE
#ARG VCS_REF
#ARG VERSION
LABEL org.label-schema.name="chisel3-docker-for-factorio" \
#      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.description="Container for running chisel3 and Redcrafter/verilog2factorio." \
      org.label-schema.url="https://github.com/Xaeroxe/chisel3-docker-for-factorio" \
#      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/Xaeroxe/chisel3-docker-for-factorio" \
      org.label-schema.vendor="Xaeroxe" \
#      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"


ENV VERILATOR_DEPS \
    autoconf \
    bc \
    bison \
    build-essential \
    ca-certificates \
    flex \
    git \
    libfl-dev \
    perl \
    python3

ENV SBT_DEPS \
    openjdk-21-jdk \
    sbt 

RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg ca-certificates wget && \
    echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add -

RUN apt-get update && \
    apt-get install -y --no-install-recommends $VERILATOR_DEPS && \
    apt-get install -y --no-install-recommends $SBT_DEPS && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Specify verilator version
ARG REPO=https://github.com/verilator/verilator
ARG SOURCE_CHECKOUT=stable

WORKDIR /tmp

RUN git clone "${REPO}" verilator && \
    cd verilator && \
    git checkout "${SOURCE_CHECKOUT}" && \
    autoconf && \
    ./configure && \
    make -j "$(nproc)" && \
    make install && \
    cd .. && rm -r verilator

# Get yosys build deps
RUN apt-get install -y --no-install-recommends build-essential clang bison flex libreadline-dev gawk \
    tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev \
    libboost-filesystem-dev zlib1g-dev

RUN curl -L -O https://github.com/YosysHQ/yosys/archive/refs/tags/yosys-0.34.tar.gz
RUN tar -xf yosys-0.34.tar.gz && rm yosys-0.34.tar.gz
RUN pushd yosys-yosys-0.34 && make install && popd
RUN rm -rf yosys-yosys-0.34

# Install nodejs and npm
RUN curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh && rm nodesource_setup.sh
RUN apt-get install -y nodejs npm
# Test the node and npm install
RUN node -v && npm -v

# Now install verilog2factorio
RUN git clone https://github.com/Redcrafter/verilog2factorio.git && cd verilog2factorio && npm install

VOLUME ["/chisel"]
WORKDIR /chisel
