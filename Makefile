# Non Enclave App Build

main: main.c
	gcc -o main main.c

# Build Variables
INTEL_SGX_SDK_PATH="/root/sgx/sgxsdk"

# Enclave App Build: Trusted Part

enclave_t.c enclave_t.h: enclave.edl
	$(INTEL_SGX_SDK_PATH)/bin/x64/sgx_edger8r --trusted ./enclave.edl

enclave_t.o: enclave_t.c enclave_t.h
	gcc -I$(INTEL_SGX_SDK_PATH)/include -I$(INTEL_SGX_SDK_PATH)/include/tlibc/ -c enclave_t.c -o enclave_t.o

enclave.o: enclave.c enclave_t.h
	gcc -I$(INTEL_SGX_SDK_PATH)/include -I$(INTEL_SGX_SDK_PATH)/include/tlibc/ -c enclave.c -o enclave.o

enclave.so: enclave.o enclave_t.o
	gcc enclave.o enclave_t.o -o enclave.so \
		-nostdlib \
		-nodefaultlibs \
		-nostartfiles \
		-B/usr/local/bin \
		-Wl,-z,relro,-z,now,-z,noexecstack \
		-Wl,--no-undefined \
		-L$(INTEL_SGX_SDK_PATH)/lib64 \
		-Wl,--whole-archive \
		-lsgx_trts \
		-Wl,--no-whole-archive \
		-Wl,--start-group \
		-lsgx_tstdc \
		-lsgx_tcxx \
		-lsgx_tcrypto \
		-lsgx_tservice \
		-Wl,--end-group \
		-Wl,-Bstatic \
		-Wl,-Bsymbolic \
		-Wl,--no-undefined \
		-Wl,-pie,-eenclave_entry \
		-Wl,--export-dynamic \
		-Wl,--defsym,__ImageBase=0 \
		-Wl,--gc-sections \
		-Wl,--version-script=enclave.lds

# Enclave Signing

enclave.pem:
	openssl genrsa -out enclave.pem -3 3072

enclave.signed.so: enclave.pem enclave.so enclave.xml
	$(INTEL_SGX_SDK_PATH)/bin/x64/sgx_sign sign -key enclave.pem -enclave enclave.so -out enclave.signed.so -config enclave.xml

# Enclave App Build: Untrusted Part

enclave_u.c enclave_u.h: enclave.edl
	$(INTEL_SGX_SDK_PATH)/bin/x64/sgx_edger8r --untrusted ./enclave.edl

enclave_u.o: enclave_u.c enclave_u.h
	gcc -I$(INTEL_SGX_SDK_PATH)/include -I$(INTEL_SGX_SDK_PATH)/include/tlibc/ -c enclave_u.c -o enclave_u.o

app.o: app.c enclave_u.h
	gcc -I$(INTEL_SGX_SDK_PATH)/include -c app.c -o app.o -L$(INTEL_SGX_SDK_PATH)/lib64 -lsgx_urts

app: app.o enclave_u.o
	gcc app.o enclave_u.o -o app -L$(INTEL_SGX_SDK_PATH)/lib64 -lsgx_urts

# Enclave Execution

test: app enclave.signed.so
	./app

clean:
	rm -f main app \
		*.o *.so \
		enclave_u.c enclave_u.h \
		enclave_t.c enclave_t.h \
		enclave.pem