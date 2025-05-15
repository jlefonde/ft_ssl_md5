#include "ssl.h"

static const uint32_t g_T[64] = {
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
};

static const uint32_t g_S[4][4] = {
    { 7, 12, 17, 22 },
    { 5,  9, 14, 20 },
    { 4, 11, 16, 23 },
    { 6, 10, 15, 21 }
};

static uint32_t F(uint32_t x, uint32_t y, uint32_t z)
{
    return ((x & y) | (~x & z));
}

static uint32_t G(uint32_t x, uint32_t y, uint32_t z)
{
    return ((x & z) | (y & ~z));
}

static uint32_t H(uint32_t x, uint32_t y, uint32_t z)
{
    return (x ^ y ^ z);
}

static uint32_t I(uint32_t x, uint32_t y, uint32_t z)
{
    return (y ^ (x | ~z));
}

static uint32_t process_round(t_md5_round md5_round, uint32_t func_result, int i, int j)
{
    uint32_t sum = md5_round.A + func_result + md5_round.w[j] + g_T[i];
    uint32_t shift = g_S[(i / 16)][(i % 4)];

    return md5_round.B + ft_rotate_left_32(sum, shift);
}

static uint32_t md5_round_1(t_md5_round md5_round, int i)
{
    int j = i;
    uint32_t f_res = F(md5_round.B, md5_round.C, md5_round.D);
    return process_round(md5_round, f_res, i, j);
}

static uint32_t md5_round_2(t_md5_round md5_round, int i)
{
    int j = ((5 * i + 1) % 16);
    uint32_t g_res = G(md5_round.B, md5_round.C, md5_round.D);
    return process_round(md5_round, g_res, i, j);
}

static uint32_t md5_round_3(t_md5_round md5_round, int i)
{
    int j = ((3 * i + 5) % 16);
    uint32_t h_res = H(md5_round.B, md5_round.C, md5_round.D);
    return process_round(md5_round, h_res, i, j);
}

static uint32_t md5_round_4(t_md5_round md5_round, int i)
{
    int j = ((7 * i) % 16);
    uint32_t i_res = I(md5_round.B, md5_round.C, md5_round.D);
    return process_round(md5_round, i_res, i, j);
}

static uint32_t (*md5_rounds[4])(t_md5_round md5_round, int i) = {
    md5_round_1,
    md5_round_2,
    md5_round_3,
    md5_round_4
};

static void process_block(const uint8_t block[64], uint32_t digest[4])
{
    t_md5_round md5_round;

    for (int i = 0; i < 16; ++i)
    {
        int j = i * 4;

        md5_round.w[i] = block[j] | block[j + 1] << 8 | block[j + 2] << 16 | block[j + 3] << 24;
    }

    md5_round.A = digest[0];
    md5_round.B = digest[1];
    md5_round.C = digest[2];
    md5_round.D = digest[3];
    for (int i = 0; i < 64; ++i)
    {
        uint32_t F = md5_rounds[(i / 16) % 4](md5_round, i);
        md5_round.A = md5_round.D;
        md5_round.D = md5_round.C;
        md5_round.C = md5_round.B;
        md5_round.B = F;
    }

    digest[0] += md5_round.A;
    digest[1] += md5_round.B;
    digest[2] += md5_round.C;
    digest[3] += md5_round.D;
}

static void process_final_block(bool bit_1_appended, uint64_t msg_size, uint32_t digest[4])
{
    uint8_t block[64];
    int i = 0;

    if (!bit_1_appended)
        block[i++] = 0x80;

    ft_memset(&block[i], 0x00, 56 - i);
    ft_memcpy(&block[56], &msg_size, 8);
    process_block(block, digest);
}

static void md5_final(uint8_t block[64], ssize_t bytes_read, uint64_t msg_size, uint32_t digest[4])
{
    block[bytes_read++] = 0x80;

    if (bytes_read < 56)
    {
        ft_memset(&block[bytes_read], 0x00, 56 - bytes_read);
        ft_memcpy(&block[56], &msg_size, 8);
        process_block(block, digest);
    }
    else
    {
        if (bytes_read > 0)
        {
           ft_memset(&block[bytes_read], 0x00, 64 - bytes_read);
           process_block(block, digest);
        }
        process_final_block(bytes_read > 0, msg_size, digest);
    }
}

static void md5_print(void *output)
{
    uint32_t *digest = output;
    for (int i = 0; i < 4; ++i)
        for (int j = 0; j < 4; ++j)
            ft_printf("%02x", ((digest[i] >> (j * 8)) & 0xFF));
    free(output);
}

static void *md5(t_input *input)
{
    uint32_t *digest = malloc(4 * sizeof(uint32_t));
    if (!digest)
    {
        print_error("md5", strerror(errno), NULL);
        return (NULL);
    }

    digest[0] = 0x67452301;
    digest[1] = 0xefcdab89;
    digest[2] = 0x98badcfe;
    digest[3] = 0x10325476;

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
            md5_final(block, bytes_read, total_msg_size * 8, digest);
            break ;
        }
    }

    if (bytes_read == -1)
    {
        print_error("md5", strerror(errno), NULL);
        free(digest);
        return (NULL);
    }

    return (digest);
}

void process_md5(const t_command *cmd, int argc, char **argv)
{
    t_context *ctx = parse_digest(cmd, argc, argv);
    ctx->digest.cmd_func = md5;
    ctx->digest.print_func = md5_print;

    process_digest(cmd, ctx);
    free(ctx);
}
