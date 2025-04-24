# include <stdio.h>
# include <math.h>
# include <stdint.h>
# include <string.h>
# include <fcntl.h>
# include <unistd.h>
# include <stdlib.h>

static uint32_t ft_rotate_left(const uint32_t X, const uint32_t N)
{
    return ((X << N) | (X >> (32 - N)));
}

static uint32_t F(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return ((X & Y) | (~X & Z));
}

static uint32_t G(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return ((X & Z) | (Y & ~Z));
}

static uint32_t H(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return (X ^ Y ^ Z);
}

static uint32_t I(const uint32_t X, const uint32_t Y, const uint32_t Z)
{
    return (Y ^ (X | ~Z));
}

static int ft_get_word_index_round_1(const int i)
{
    return (i);
}

static int ft_get_word_index_round_2(const int i)
{
    return ((5 * i + 1) % 16);
}

static int ft_get_word_index_round_3(const int i)
{
    return ((3 * i + 5) % 16);
}

static int ft_get_word_index_round_4(const int i)
{
    return ((7 * i) % 16);
}

static uint32_t (*ft_md5_round[4])(const uint32_t X, const uint32_t Y, const uint32_t Z) = {
    F, G, H, I
};

static int (*ft_get_word_index[4])(const int i) = {
    ft_get_word_index_round_1,
    ft_get_word_index_round_2,
    ft_get_word_index_round_3,
    ft_get_word_index_round_4
};

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

int ft_get_padding_zeros(ssize_t msg_size)
{
    int res = (msg_size * 8 + 1) % 512;
    if (res <= 448)
        return 448 - res;
    return 512 - res + 448;
}

uint32_t ft_md5_rounds(uint32_t A, uint32_t B, uint32_t C, uint32_t D, uint32_t w[16])
{
    uint32_t round_res = 0;
    uint32_t combine = 0;

    for (int i = 0; i < 64; ++i)
    {
        int j = ft_get_word_index[((i / 16) % 4)](i);
        round_res = ft_md5_round[((i / 16) % 4)](B, C, D);
        combine = B + ft_rotate_left((A + round_res + w[j] + T[i]), S[(i / 16)][(i % 4)]);
    }
    return (combine);
}

void ft_process_block(const uint8_t msg[64], uint32_t digest[4])
{
    uint32_t w[16];

    for (int i = 0; i < 16; ++i)
    {
        int j = i * 4;

        w[i] = msg[j] | msg[j + 1] << 8 | msg[j + 2] << 16 | msg[j + 3] << 24;
    }

    uint32_t A = digest[0];
    uint32_t B = digest[1];
    uint32_t C = digest[2];
    uint32_t D = digest[3];

    digest[0] = D + A;
    digest[1] = ft_md5_rounds(A, B, C, D, w) + B;
    digest[2] = B + C;
    digest[3] = C + D;
}

void ft_md5(char **argv)
{
    uint32_t digest[4] = {
        0x67452301,
        0xefcdab89,
        0x98badcfe,
        0x10325476
    };

    int fd = open(argv[1], O_RDONLY);
    if (fd == -1)
        exit(1);
    
    uint8_t buffer[64];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    while ((bytes_read = read(fd, buffer, 64)) > 0)
    {
        total_msg_size += bytes_read;

        if (bytes_read < 64)
        {
            printf("%lu<64\n", total_msg_size);
            printf("%d\n", ft_get_padding_zeros(total_msg_size));
        }

        buffer[bytes_read] = 0;
        printf("%s\n", buffer);
        ft_process_block(buffer, digest);
    }
    for (int i = 0; i < 4; ++i)
        printf("%x%x%x%x",
            digest[i] & 0xFF,
            (digest[i] >> 8) & 0xFF,
            (digest[i] >> 16) & 0xFF,
            (digest[i] >> 24) & 0xFF);

    printf("\n");
    close(fd);
}
