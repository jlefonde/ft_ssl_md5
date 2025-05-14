#include "../includes/libft.h"

uint64_t    ft_rotate_left_64(uint64_t X, uint64_t N)
{
    return ((X << N) | (X >> (64 - N)));
}
