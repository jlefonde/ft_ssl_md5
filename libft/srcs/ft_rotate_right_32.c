#include "../includes/libft.h"

uint32_t    ft_rotate_right_32(uint32_t X, uint32_t N)
{
    return ((X >> N) | (X << (32 - N)));
}
