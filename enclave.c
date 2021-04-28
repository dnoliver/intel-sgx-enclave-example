#include "enclave_t.h"
#include <string.h>

void foo(char* buf, size_t len)
{
    const char *secret = "Hello Enclave!\n";
    if (len > strlen(secret)) {
        memcpy(buf, secret, strlen(secret) + 1);
    }
}