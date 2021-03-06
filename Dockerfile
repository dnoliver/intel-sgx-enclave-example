FROM ubuntu:20.04

RUN apt-get update && apt-get install -y build-essential python-is-python3 curl

RUN curl -L https://download.01.org/intel-sgx/sgx-linux/2.13/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.13.100.4.bin \
         -o sgx_linux_x64_sdk_2.13.100.4.bin && \
         chmod u+x sgx_linux_x64_sdk_2.13.100.4.bin && \
         ./sgx_linux_x64_sdk_2.13.100.4.bin --prefix /opt/intel/

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | tee /etc/apt/sources.list.d/intel-sgx.list && \
    curl https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
    apt-get update && apt-get install -y libsgx-urts

COPY . /root

WORKDIR /root

ENV LD_LIBRARY_PATH=/opt/intel/sgxsdk/sdk_libs

ARG SGX_MODE=Hardware

RUN make app enclave.signed.so SGX_MODE=$SGX_MODE

CMD ./app