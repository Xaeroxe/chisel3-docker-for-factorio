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
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | tee /etc/apt/trusted.gpg.d/sbt.asc && \
    apt-get update && \
    apt-get install -y sbt

RUN apt-get update && \
    apt-get install -y --no-install-recommends $VERILATOR_DEPS && \
    apt-get install -y --no-install-recommends $SBT_DEPS && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y verilator 

# Get yosys build deps
RUN apt-get install -y --no-install-recommends build-essential clang bison flex libreadline-dev gawk \
    tcl-dev libffi-dev git graphviz xdot pkg-config python3 libboost-system-dev libboost-python-dev \
    libboost-filesystem-dev zlib1g-dev

RUN curl -L -O https://github.com/YosysHQ/yosys/archive/refs/tags/yosys-0.34.tar.gz
RUN tar -xf yosys-0.34.tar.gz && rm yosys-0.34.tar.gz
RUN cd yosys-yosys-0.34 && make install && cd ..
RUN rm -rf yosys-yosys-0.34

# Install nodejs and npm
RUN curl -fsSL https://deb.nodesource.com/setup_23.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh && rm nodesource_setup.sh
RUN apt-get install -y nodejs
# Test the node and npm install
RUN node -v && npm -v

# Now install verilog2factorio
RUN git clone https://github.com/Redcrafter/verilog2factorio.git && cd verilog2factorio && npm install

# Compile and install v2f-adapter program
RUN apt-get update && apt-get install -y cargo
COPY ./v2f-adapter /v2f-adapter 
RUN cd /v2f-adapter && cargo build --release && cp ./target/release/v2f-adapter /usr/bin/v2f-adapter && cd ..
RUN rm -rf v2f-adapter

# Install some text editors
RUN apt-get install -y vim nano

VOLUME ["/chisel"]
WORKDIR /chisel
