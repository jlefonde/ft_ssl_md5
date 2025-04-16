#include <stdio.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

void ft_md5(char *msg, size_t msg_size)
{
    (void) msg;
    (void) msg_size;
    const uint32_t S[4][4] = { 
        {7, 12, 17, 22},
        {5,  9, 14, 20},
        {4, 11, 16, 23},
        {6, 10, 15, 21}
    };
    uint32_t s[64];
    uint32_t T[64];

    size_t k = 0;
    for (size_t i = 0; i < 4; ++i)
        for (size_t j = 0; j < 16; ++j)
            s[k++] = S[i][j % 4];

    for (size_t i = 0; i < 64; ++i)
        T[i] = floor(4294967296 * fabs(sin(i + 1)));

    uint32_t A = 0x67452301;
    uint32_t B = 0xefcdab89;
    uint32_t C = 0x98badcfe;
    uint32_t D = 0x10325476;
}
