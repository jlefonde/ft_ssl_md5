#include "ssl.h"

extern const size_t g_SIGMA[10][16];
extern const size_t g_index[8][4];

static const uint32_t g_IV[8] = {
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
};

static void G(uint32_t v[16], const size_t index[4], uint32_t x, uint32_t y)
{
    size_t a = index[0];
    size_t b = index[1];
    size_t c = index[2];
    size_t d = index[3];

    v[a] += v[b] + x;
    v[d] = ft_rotate_right_32(v[d] ^ v[a], 16);
    v[c] += v[d];
    v[b] = ft_rotate_right_32(v[b] ^ v[c], 12);
    v[a] += v[b] + y;
    v[d] = ft_rotate_right_32(v[d] ^ v[a], 8);
    v[c] += v[d];
    v[b] = ft_rotate_right_32(v[b] ^ v[c], 7);
}

static void F(uint32_t w[16], uint32_t digest[8], uint64_t total_bytes_read, bool final)
{
    uint32_t v[16];

    for (int i = 0; i < 16; ++i)
        v[i] = (i < 8) ? digest[i] : g_IV[i - 8];

    v[12] ^= total_bytes_read;
    v[13] ^= (total_bytes_read >> 32);

    if (final)
        v[14] ^= 0xFFFFFFFF;

    for (int i = 0; i < 10; ++i)
    {
        const size_t *s = g_SIGMA[i % 10];

        for (int j = 0, k = 0; j < 8; ++j, k += 2)
            G(v, g_index[j], w[s[k]], w[s[k + 1]]);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] ^= v[i] ^ v[i + 8];
}

static void process_block(const uint8_t block[64], uint64_t total_bytes_read, uint32_t digest[8], bool final)
{
    uint32_t w[16];

    for (int i = 0; i < 16; ++i)
    {
        int j = i * 4;

        w[i] = block[j] | block[j + 1] << 8 | block[j + 2] << 16 | block[j + 3] << 24;
    }

    F(w, digest, total_bytes_read, final);
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
            ft_printf("%02x", ((digest[i] >> (j * 8)) & 0xFF));
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
