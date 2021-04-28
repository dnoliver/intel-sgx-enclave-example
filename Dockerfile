FROM ubuntu:20.04

RUN apt-get update && apt-get install -y build-essential python-is-python3 curl

RUN curl -L https://download.01.org/intel-sgx/sgx-linux/2.13/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.13.100.4.bin \
         -o sgx_linux_x64_sdk_2.13.100.4.bin && \
         chmod u+x sgx_linux_x64_sdk_2.13.100.4.bin && \
         ./sgx_linux_x64_sdk_2.13.100.4.bin --prefix /opt/intel/

COPY . /root

WORKDIR /root

CMD make app enclave.signed.so
