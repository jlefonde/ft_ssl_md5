# include "ft_md5.h"

static const uint32_t T[64] = { 
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
};

static const uint32_t S[4][4] = { 
    {7, 12, 17, 22},
    {5,  9, 14, 20},
    {4, 11, 16, 23},
    {6, 10, 15, 21}
};

static uint32_t ft_rotate_left(const uint32_t X, const uint32_t N)
{
    return ((X << N) | (X >> (32 - N)));
}

static uint32_t ft_F(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return ((X & Y) | (~X & Z));
}

static uint32_t ft_G(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return ((X & Z) | (Y & ~Z));
}

static uint32_t ft_H(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return (X ^ Y ^ Z);
}

static uint32_t ft_I(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return (Y ^ (X | ~Z));
}

static uint32_t ft_process_round(const md5_round_t md5_round, const uint32_t func_result, const int i, const int j)
{
    uint32_t sum = md5_round.A + func_result + md5_round.w[j] + T[i];
    uint8_t shift = S[(i / 16)][(i % 4)];
    
    return md5_round.B + ft_rotate_left(sum, shift);
}

static uint32_t ft_md5_round_1(const md5_round_t md5_round, const int i)
{
    int j = i;
    uint32_t f_res = ft_F(md5_round.B, md5_round.C, md5_round.D);
    return ft_process_round(md5_round, f_res, i, j);
}

static uint32_t ft_md5_round_2(const md5_round_t md5_round, const int i)
{
    int j = ((5 * i + 1) % 16);
    uint32_t g_res = ft_G(md5_round.B, md5_round.C, md5_round.D);
    return ft_process_round(md5_round, g_res, i, j);
}

static uint32_t ft_md5_round_3(const md5_round_t md5_round, const int i)
{
    int j = ((3 * i + 5) % 16);
    uint32_t h_res = ft_H(md5_round.B, md5_round.C, md5_round.D);
    return ft_process_round(md5_round, h_res, i, j);
}

static uint32_t ft_md5_round_4(const md5_round_t md5_round, const int i)
{
    int j = ((7 * i) % 16);
    uint32_t i_res = ft_I(md5_round.B, md5_round.C, md5_round.D);
    return ft_process_round(md5_round, i_res, i, j);
}

static uint32_t (*ft_md5_round[4])(const md5_round_t md5_round, const int i) = {
    ft_md5_round_1,
    ft_md5_round_2,
    ft_md5_round_3,
    ft_md5_round_4
};

void ft_process_block(const uint8_t msg[64], uint32_t digest[4])
{
    md5_round_t md5_round;

    for (int i = 0; i < 16; ++i)
    {
        int j = i * 4;

        md5_round.w[i] = msg[j] | msg[j + 1] << 8 | msg[j + 2] << 16 | msg[j + 3] << 24;
    }

    md5_round.A = digest[0]; 
    md5_round.B = digest[1]; 
    md5_round.C = digest[2]; 
    md5_round.D = digest[3];
    for (int i = 0; i < 64; ++i)
    {
        uint32_t F = ft_md5_round[(i / 16) % 4](md5_round, i);
        md5_round.A = md5_round.D;
        md5_round.D = md5_round.C;
        md5_round.C = md5_round.B;
        md5_round.B = F;
    }

    digest[0] = digest[0] + md5_round.A;
    digest[1] = digest[1] + md5_round.B;
    digest[2] = digest[2] + md5_round.C;
    digest[3] = digest[3] + md5_round.D;
}

void ft_process_final_block(ssize_t msg_size, uint32_t digest[4])
{
    uint8_t block[64];
    int i = 0;

    block[i++] = 0x80;
    memset(&block[i], 0, 56);
    memcpy(&block[56], &msg_size, 8);
    ft_process_block(block, digest);
}

void ft_md5_final(uint8_t buffer[64], ssize_t bytes_read, ssize_t msg_size, uint32_t digest[4])
{
    buffer[bytes_read++] = 0x80;

    if (bytes_read < 56)
    {
        memset(&buffer[bytes_read], 0x00, 56 - bytes_read);
        memcpy(&buffer[56], &msg_size, 8);
        ft_process_block(buffer, digest);
    }
    else
    {
        if (bytes_read > 0)
        {
           memset(&buffer[bytes_read], 0x00, 64 - bytes_read);
           ft_process_block(buffer, digest);
        }
        ft_process_final_block(msg_size, digest);
    }
}

void ft_print_digest(const uint32_t digest[4])
{
    for (int i = 0; i < 4; ++i)
        for (int j = 0; j < 4; ++j)
            printf("%02x", ((digest[i] >> (j * 8)) & 0xFF));
    printf("\n");
}

int ft_md5_file(char *file, uint32_t digest[4])
{
    int fd = 0;
    if (file)
    {
        fd = open(file, O_RDONLY);
        if (fd == -1)
        {
            printf("Error: %s\n", strerror(errno));
            return (1);
        }
    }

    uint8_t buffer[64];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    while ((bytes_read = read(fd, buffer, 64)) >= 0)
    {
        total_msg_size += bytes_read;

        if (bytes_read == 64)
            ft_process_block(buffer, digest);
        else
        {
            ft_md5_final(buffer, bytes_read, total_msg_size * 8, digest);
            break;
        }
    }

    if (fd > 2)
        close(fd);

    if (bytes_read == -1)
    {
        printf("Error: %s\n", strerror(errno));
        return (1);
    }

    ft_print_digest(digest);
    return (0);
}

void ft_md5(char **argv)
{
    uint32_t digest[4] = {
        0x67452301,
        0xefcdab89,
        0x98badcfe,
        0x10325476
    };

    ft_md5_file(argv[1], digest);
}
