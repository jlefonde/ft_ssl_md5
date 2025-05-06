# ifndef FT_MD5_H
#  define FT_MD5_H

# include "ft_ssl.h"

typedef struct s_md5_round
{
    uint32_t A;
    uint32_t B;
    uint32_t C;
    uint32_t D;
    uint32_t w[16];
}   t_md5_round;

typedef struct s_input t_input;

void *ft_md5(t_input *input);
void ft_md5_print(void *output);

# endif