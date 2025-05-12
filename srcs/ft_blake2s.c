#include "ft_ssl.h"

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

static void ft_G(uint32_t v[16], size_t index[4], uint32_t x, uint32_t y)
{
    size_t a = index[0];
    size_t b = index[1];
    size_t c = index[2];
    size_t d = index[3];

    v[a] = (v[a] + v[b] + x) % 4294967296;
    v[d] = ft_rotate_right(v[d] ^ v[a], 16);
    v[c] = (v[c] + v[d]) % 4294967296;
    v[b] = ft_rotate_right(v[b] ^ v[c], 12);
    v[a] = (v[a] + v[b] + y) % 4294967296;
    v[d] = ft_rotate_right(v[d] ^ v[a], 8);
    v[c] = (v[c] + v[d]) % 4294967296;
    v[b] = ft_rotate_right(v[b] ^ v[c], 7);
}

static void ft_F(uint8_t block[16], uint32_t digest[8], uint64_t total_bytes_read, bool final)
{
    uint32_t v[16];

    for (int i = 0; i < 16; ++i)
        v[i] = (i < 8) ? digest[i] : g_IV[i / 2];

    v[12] ^= (total_bytes_read % 4294967296);
    v[13] ^= (total_bytes_read >> 32);

    if (final)
        v[14] ^= 0xFFFFFFFF;

    for (int i = 0; i < 10; ++i)
    {
        uint32_t s[16];

        for (int j = 0; j < 10; ++j)
            s[j] = g_SIGMA[i % 10][j];

        ft_G(v, g_index[0], block[s[0]], block[s[1]]);
        ft_G(v, g_index[1], block[s[2]], block[s[3]]);
        ft_G(v, g_index[2], block[s[4]], block[s[5]]);
        ft_G(v, g_index[3], block[s[6]], block[s[7]]);
        ft_G(v, g_index[4], block[s[8]], block[s[9]]);
        ft_G(v, g_index[5], block[s[10]], block[s[11]]);
        ft_G(v, g_index[6], block[s[12]], block[s[13]]);
        ft_G(v, g_index[7], block[s[14]], block[s[15]]);
    }

    for (int i = 0; i < 8; ++i)
        digest[i] ^= v[i] ^ v[i + 8];
}

static void ft_blake2s_print(void *output)
{

}

static void *ft_blake2s(t_input *input)
{
    uint32_t *digest = malloc(8 * sizeof(uint32_t));
    if (!digest)
        return (NULL);

    digest[0] = g_IV[0]; 
    digest[1] = g_IV[1];
    digest[2] = g_IV[2];
    digest[3] = g_IV[3];
    digest[4] = g_IV[4];
    digest[5] = g_IV[5];
    digest[6] = g_IV[6];
    digest[7] = g_IV[7];
}

void ft_process_blake2s(const t_command *cmd, int argc, char **argv)
{
    printf("%ld ", g_IV[1]);
    // t_context *ctx = ft_parse_digest(cmd, argc, argv);
    // ctx->digest.cmd_func = ft_blake2s;
    // ctx->digest.print_func = ft_blake2s_print;

    // ft_process_digest(cmd, ctx);
    // free(ctx);
}