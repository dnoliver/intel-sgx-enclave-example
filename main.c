#include <stdio.h>
#include <string.h>
#define MAX_BUF_LEN 100

void foo(char *buf, size_t len)
{
    const char *secret = "Hello App!\n";
    if (len > strlen(secret)) {
        memcpy(buf, secret, strlen(secret) + 1);
    }
}

int main()
{
    char buffer[MAX_BUF_LEN] = "Hello World!\n";
    foo(buffer, MAX_BUF_LEN);
    printf("%s", buffer);
    return 0;
}