#include "ft_ssl.h"

static const uint32_t g_K[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2};

static uint32_t ft_choose(uint32_t X, uint16_t Y, uint32_t Z)
{
    return ((X & Y) ^ (~X & Z));
}

static uint32_t ft_majority(uint32_t X, uint16_t Y, uint32_t Z)
{
    return ((X & Y) ^ (X & Z) ^ (Y & Z));
}

static uint32_t ft_big_sigma(uint32_t X, int r1, int r2, int r3)
{
    return (ft_rotate_right(X, r1) ^ ft_rotate_right(X, r2) ^ ft_rotate_right(X, r3));
}

static uint32_t ft_small_sigma(uint32_t X, int r1, int r2, int s)
{
    return (ft_rotate_right(X, r1) ^ ft_rotate_right(X, r2) ^ (X >> s));
}

static uint32_t ft_big_sigma_0(uint32_t X)
{
    return (ft_big_sigma(X, 2, 13, 22));
}

static uint32_t ft_big_sigma_1(uint32_t X)
{
    return (ft_big_sigma(X, 6, 11, 25));
}

static uint32_t ft_small_sigma_0(uint32_t X)
{
    return (ft_small_sigma(X, 7, 18, 3));
}

static uint32_t ft_small_sigma_1(uint32_t X)
{
    return (ft_small_sigma(X, 17, 19, 10));
}

static void ft_process_block(const uint8_t msg[64], uint32_t digest[8])
{
    uint32_t w[16];

    for (int i = 0; i < 16; ++i)
    {
        int j = i * 4;

        w[i] = msg[j] | msg[j + 1] << 8 | msg[j + 2] << 16 | msg[j + 3] << 24;
        printf("w[%d] = %x\n", i, w[i]);
    }
}

static void ft_process_final_block(ssize_t bytes_read, ssize_t msg_size, uint32_t digest[4])
{
    uint8_t block[64];
    int i = 0;

    if (!bytes_read)
        block[i++] = 0x80;

    ft_memset(&block[i], 0, 56 - i);
    ft_memcpy(&block[56], &msg_size, 8);
    ft_process_block(block, digest);
}

static void ft_sha256_final(uint8_t block[64], ssize_t bytes_read, ssize_t msg_size, uint32_t digest[4])
{
    block[bytes_read++] = 0x80;

    if (bytes_read < 56)
    {
        ft_memset(&block[bytes_read], 0x00, 56 - bytes_read);
        ft_memcpy(&block[56], &msg_size, 8);
        ft_process_block(block, digest);
    }
    else
    {
        if (bytes_read > 0)
        {
            ft_memset(&block[bytes_read], 0x00, 64 - bytes_read);
            ft_process_block(block, digest);
        }
        ft_process_final_block(bytes_read, msg_size, digest);
    }
}

void ft_sha256_print(void *output)
{
    printf("OUTPUT");
}

void *ft_sha256(t_input *input)
{
    uint32_t *digest = malloc(8 * sizeof(uint32_t));
    if (!digest)
        return (NULL);

    digest[0] = 0x6a09e667;
    digest[1] = 0xbb67ae85;
    digest[2] = 0x3c6ef372;
    digest[3] = 0xa54ff53a;
    digest[4] = 0x510e527f;
    digest[5] = 0x9b05688c;
    digest[6] = 0x1f83d9ab;
    digest[7] = 0x5be0cd19;

    uint8_t block[64];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    while ((bytes_read = ft_read_from_input(input, block, 64)) >= 0)
    {
        total_msg_size += bytes_read;

        if (bytes_read == 64)
            ft_process_block(block, digest);
        else
        {
            ft_sha256_final(block, bytes_read, total_msg_size * 8, digest);
            break;
        }
    }

    if (bytes_read == -1)
    {
        ft_fprintf(STDERR_FILENO, "ft_ssl: md5: %s\n", strerror(errno));
        return (NULL);
    }

    return (digest);
}
