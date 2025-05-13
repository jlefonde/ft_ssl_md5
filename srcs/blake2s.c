#include "ssl.h"

static uint32_t g_IV[8] = {
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
};

static size_t g_SIGMA[10][16] = {
    {  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15 },
    { 14, 10,  4,  8,  9, 15, 13,  6,  1, 12,  0,  2, 11,  7,  5,  3 },
    { 11,  8, 12,  0,  5,  2, 15, 13, 10, 14,  3,  6,  7,  1,  9,  4 },
    {  7,  9,  3,  1, 13, 12, 11, 14,  2,  6,  5, 10,  4,  0, 15,  8 },
    {  9,  0,  5,  7,  2,  4, 10, 15, 14,  1, 11, 12,  6,  8,  3, 13 },
    {  2, 12,  6, 10,  0, 11,  8,  3,  4, 13,  7,  5, 15, 14,  1,  9 },
    { 12,  5,  1, 15, 14, 13,  4, 10,  0,  7,  6,  3,  9,  2,  8, 11 },
    { 13, 11,  7, 14, 12,  1,  3,  9,  5,  0, 15,  4,  8,  6,  2, 10 },
    {  6, 15, 14,  9, 11,  3,  0,  8, 12,  2, 13,  7,  1,  4, 10,  5 },
    { 10,  2,  8,  4,  7,  6,  1,  5, 15, 11,  9, 14,  3, 12, 13,  0 }
};

static size_t g_index[8][4] = {
    { 0, 4,  8, 12 },
    { 1, 5,  9, 13 },
    { 2, 6, 10, 14 },
    { 3, 7, 11, 15 },
    { 0, 5, 10, 15 },
    { 1, 6, 11, 12 },
    { 2, 7,  8, 13 },
    { 3, 4,  9, 14 }
};

static void G(uint32_t v[16], size_t index[4], uint32_t x, uint32_t y)
{
    size_t a = index[0];
    size_t b = index[1];
    size_t c = index[2];
    size_t d = index[3];

    v[a] = (v[a] + v[b] + x) % 4294967296;
    v[d] = rotate_right(v[d] ^ v[a], 16);
    v[c] = (v[c] + v[d]) % 4294967296;
    v[b] = rotate_right(v[b] ^ v[c], 12);
    v[a] = (v[a] + v[b] + y) % 4294967296;
    v[d] = rotate_right(v[d] ^ v[a], 8);
    v[c] = (v[c] + v[d]) % 4294967296;
    v[b] = rotate_right(v[b] ^ v[c], 7);
}

static void F(uint32_t block[16], uint32_t digest[8], uint64_t total_bytes_read, bool final)
{
    uint32_t v[16];

    for (int i = 0; i < 16; ++i)
        v[i] = (i < 8) ? digest[i] : g_IV[i - 8];

    v[12] ^= (total_bytes_read % 4294967296);
    v[13] ^= (total_bytes_read >> 32);

    if (final)
        v[14] ^= 0xFFFFFFFF;

    for (int i = 0; i < 10; ++i)
    {
        uint32_t s[16];

        for (int j = 0; j < 16; ++j)
            s[j] = g_SIGMA[i % 10][j];

        for (int j = 0, k = 0; j < 8; ++j, k += 2)
            G(v, g_index[j], block[s[k]], block[s[k + 1]]);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] ^= v[i] ^ v[i + 8];
}

static void process_block(const uint8_t msg[64], uint64_t msg_size, uint32_t digest[8], bool final)
{    
    uint32_t w[16];

    for (int i = 0; i < 16; ++i)
    {
        int j = i * 4;

        w[i] = msg[j] | msg[j + 1] << 8 | msg[j + 2] << 16 | msg[j + 3] << 24;
    }

    F(w, digest, msg_size, final);
}

static void blake2s_final(uint8_t block[64], ssize_t bytes_read, uint64_t msg_size, uint32_t digest[8])
{
    ft_memset(&block[bytes_read], 0x00, 64 - bytes_read);
    process_block(block, msg_size, digest, true);
}

static void blake2s_print(void *output)
{
    uint32_t *digest = output;
    for (int i = 0; i < 8; ++i)
        for (int j = 0; j < 4; ++j)
            printf("%02x", ((digest[i] >> (j * 8)) & 0xFF));
    free(output);
}

static void *blake2s(t_input *input)
{
    uint32_t *digest = malloc(8 * sizeof(uint32_t));
    if (!digest)
    {
        print_error("blake2s", strerror(errno), NULL);
        return (NULL);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] = g_IV[i];

    digest[0] ^= 0x01010020;

    uint8_t block[64];
    uint8_t next_block[64];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    ssize_t next_bytes_read = 0;

    bytes_read = read_from_input(input, block, 64);
    if (bytes_read == -1)
    {
        print_error("blake2s", strerror(errno), NULL);
        free(digest);
        return (NULL);
    }
    total_msg_size += bytes_read;

    while (bytes_read == 64)
    {
        next_bytes_read = read_from_input(input, next_block, 64);
        if (next_bytes_read == -1)
        {
            print_error("blake2s", strerror(errno), NULL);
            free(digest);
            return (NULL);
        }
        total_msg_size += next_bytes_read;

        if (!next_bytes_read)
            break;

        process_block(block, total_msg_size - next_bytes_read, digest, false);
        ft_memcpy(block, next_block, 64);
        bytes_read = next_bytes_read;
    }
    blake2s_final(block, bytes_read, total_msg_size, digest);

    return (digest);
}

void process_blake2s(const t_command *cmd, int argc, char **argv)
{
    t_context *ctx = parse_digest(cmd, argc, argv);
    ctx->digest.cmd_func = blake2s;
    ctx->digest.print_func = blake2s_print;

    process_digest(cmd, ctx);
    free(ctx);
}