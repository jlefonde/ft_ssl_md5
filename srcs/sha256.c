#include "ssl.h"

static const uint32_t g_IV[8] = {
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
};

static const uint32_t g_K[64] = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

static uint32_t choose(uint32_t X, uint32_t Y, uint32_t Z)
{
    return ((X & Y) ^ (~X & Z));
}

static uint32_t majority(uint32_t X, uint32_t Y, uint32_t Z)
{
    return ((X & Y) ^ (X & Z) ^ (Y & Z));
}

static uint32_t big_sigma(uint32_t X, uint32_t r1, uint32_t r2, uint32_t r3)
{
    return (ft_rotate_right_32(X, r1) ^ ft_rotate_right_32(X, r2) ^ ft_rotate_right_32(X, r3));
}

static uint32_t small_sigma(uint32_t X, uint32_t r1, uint32_t r2, uint32_t s)
{
    return (ft_rotate_right_32(X, r1) ^ ft_rotate_right_32(X, r2) ^ (X >> s));
}

static uint32_t big_sigma_0(uint32_t X)
{
    return (big_sigma(X, 2, 13, 22));
}

static uint32_t big_sigma_1(uint32_t X)
{
    return (big_sigma(X, 6, 11, 25));
}

static uint32_t small_sigma_0(uint32_t X)
{
    return (small_sigma(X, 7, 18, 3));
}

static uint32_t small_sigma_1(uint32_t X)
{
    return (small_sigma(X, 17, 19, 10));
}

static void process_block(const uint8_t msg[64], uint32_t digest[8])
{
    uint32_t w[64];

    for (int i = 0; i < 64; ++i)
    {
        if (i < 16)
        {
            int j = i * 4;

            w[i] = (msg[j] << 24) | (msg[j + 1] << 16) | (msg[j + 2] << 8) | msg[j + 3];
        }
        else
            w[i] = small_sigma_1(w[i - 2]) + w[i - 7] + small_sigma_0(w[i - 15]) + w[i - 16];
    }

    uint32_t A = digest[0];
    uint32_t B = digest[1];
    uint32_t C = digest[2];
    uint32_t D = digest[3];
    uint32_t E = digest[4];
    uint32_t F = digest[5];
    uint32_t G = digest[6];
    uint32_t H = digest[7];
    for (int i = 0; i < 64; ++i)
    {
        uint32_t T1 = H + big_sigma_1(E) + choose(E, F, G) + g_K[i] + w[i];
        uint32_t T2 = big_sigma_0(A) + majority(A, B, C);
        H = G;
        G = F;
        F = E;
        E = D + T1;
        D = C;
        C = B;
        B = A;
        A = T1 + T2;
    }

    digest[0] += A;
    digest[1] += B;
    digest[2] += C;
    digest[3] += D;
    digest[4] += E;
    digest[5] += F;
    digest[6] += G;
    digest[7] += H;
}

static void process_final_block(ssize_t bytes_read, uint64_t msg_size, uint32_t digest[8])
{
    uint8_t block[64];
    int i = 0;

    if (!bytes_read)
        block[i++] = 0x80;

    ft_memset(&block[i], 0, 56 - i);
    uint64_t msg_size_be = ft_bswap64(msg_size);
    ft_memcpy(&block[56], &msg_size_be, 8);
    process_block(block, digest);
}

static void sha256_final(uint8_t block[64], ssize_t bytes_read, uint64_t msg_size, uint32_t digest[8])
{
    block[bytes_read++] = 0x80;

    if (bytes_read < 56)
    {
        ft_memset(&block[bytes_read], 0x00, 56 - bytes_read);
        uint64_t msg_size_be = ft_bswap64(msg_size);
        ft_memcpy(&block[56], &msg_size_be, 8);
        process_block(block, digest);
    }
    else
    {
        if (bytes_read > 0)
        {
            ft_memset(&block[bytes_read], 0x00, 64 - bytes_read);
            process_block(block, digest);
        }
        process_final_block(bytes_read, msg_size, digest);
    }
}

static void sha256_print(void *output)
{
    uint32_t *digest = output;
    for (int i = 0; i < 8; ++i)
        ft_printf("%08x", digest[i]);
    free(output);
}

static void *sha256(t_input *input)
{
    uint32_t *digest = malloc(8 * sizeof(uint32_t));
    if (!digest)
    {
        print_error("sha256", strerror(errno), NULL);
        return (NULL);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] = g_IV[i];

    uint8_t block[64];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    while ((bytes_read = read_from_input(input, block, 64)) >= 0)
    {
        total_msg_size += bytes_read;

        if (bytes_read == 64)
            process_block(block, digest);
        else
        {
            sha256_final(block, bytes_read, total_msg_size * 8, digest);
            break;
        }
    }

    if (bytes_read == -1)
    {
        print_error("sha256", strerror(errno), NULL);
        free(digest);
        return (NULL);
    }

    return (digest);
}

void process_sha256(const t_command *cmd, int argc, char **argv)
{
    t_context *ctx = parse_digest(cmd, argc, argv);
    ctx->digest.cmd_func = sha256;
    ctx->digest.print_func = sha256_print;

    process_digest(cmd, ctx);
    free(ctx);
}
