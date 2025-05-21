#include "ssl.h"

extern const size_t g_SIGMA[10][16];
extern const size_t g_index[8][4];

static const uint64_t g_IV[8] = {
    0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
    0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
};

static void G(uint64_t v[16], const size_t index[4], uint64_t x, uint64_t y)
{
    size_t a = index[0];
    size_t b = index[1];
    size_t c = index[2];
    size_t d = index[3];

    v[a] += v[b] + x;
    v[d] = ft_rotate_right_64(v[d] ^ v[a], 32);
    v[c] += v[d];
    v[b] = ft_rotate_right_64(v[b] ^ v[c], 24);
    v[a] += v[b] + y;
    v[d] = ft_rotate_right_64(v[d] ^ v[a], 16);
    v[c] += v[d];
    v[b] = ft_rotate_right_64(v[b] ^ v[c], 63);
}

static void F(uint64_t w[16], uint64_t digest[8], uint64_t total_bytes_read, bool final)
{
    uint64_t v[16];

    for (int i = 0; i < 16; ++i)
        v[i] = (i < 8) ? digest[i] : g_IV[i - 8];

    v[12] ^= total_bytes_read;
    v[13] ^= 0;

    if (final)
        v[14] ^= 0xFFFFFFFFFFFFFFFF;

    for (int i = 0; i < 12; ++i)
    {
        const size_t *s = g_SIGMA[i % 10];

        for (int j = 0, k = 0; j < 8; ++j, k += 2)
            G(v, g_index[j], w[s[k]], w[s[k + 1]]);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] ^= v[i] ^ v[i + 8];
}

static void process_block(const uint8_t block[128], uint64_t total_bytes_read, uint64_t digest[8], bool final)
{
    uint64_t w[16];

    for (int i = 0; i < 16; ++i)
    {
        w[i] = 0;
        for (int j = 0, k = i * 8; j < 8; j++)
            w[i] |= ((uint64_t)block[k + j] << (j * 8));
    }

    F(w, digest, total_bytes_read, final);
}

static void blake2b_final(uint8_t block[128], ssize_t bytes_read, uint64_t msg_size, uint64_t digest[8])
{
    ft_memset(&block[bytes_read], 0x00, 128 - bytes_read);
    process_block(block, msg_size, digest, true);
}

static void blake2b_print(void *output)
{
    uint64_t *digest = output;
    for (int i = 0; i < 8; ++i)
        for (int j = 0; j < 8; ++j)
            ft_printf("%02x", ((digest[i] >> (j * 8)) & 0xFF));
    free(output);
}

static void *blake2b(t_input *input)
{
    uint64_t *digest = malloc(8 * sizeof(uint64_t));
    if (!digest)
    {
        print_error("blake2b", strerror(errno), NULL);
        return (NULL);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] = g_IV[i];

    digest[0] ^= 0x01010040;

    uint8_t block[128];
    uint8_t next_block[128];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    ssize_t next_bytes_read = 0;

    bytes_read = read_from_input(input, block, 128);
    if (bytes_read == -1)
    {
        print_error("blake2b", strerror(errno), NULL);
        free(digest);
        return (NULL);
    }
    total_msg_size += bytes_read;

    while (bytes_read == 128)
    {
        next_bytes_read = read_from_input(input, next_block, 128);
        if (next_bytes_read == -1)
        {
            print_error("blake2b", strerror(errno), NULL);
            free(digest);
            return (NULL);
        }
        total_msg_size += next_bytes_read;

        if (!next_bytes_read)
            break;

        process_block(block, total_msg_size - next_bytes_read, digest, false);
        ft_memcpy(block, next_block, 128);
        bytes_read = next_bytes_read;
    }
    blake2b_final(block, bytes_read, total_msg_size, digest);

    return (digest);
}

void process_blake2b(const t_command *cmd, int argc, char **argv)
{
    t_context *ctx = parse_digest(cmd, argc, argv);
    ctx->digest.cmd_func = blake2b;
    ctx->digest.print_func = blake2b_print;

    process_digest(cmd, ctx);
    free(ctx);
}
