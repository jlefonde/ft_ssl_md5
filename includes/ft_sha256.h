# ifndef FT_SHA256_H
#  define FT_SHA256_H

# include "ft_ssl.h"

typedef struct s_input t_input;

void *ft_sha256(t_input *input);
void ft_sha256_print(void *output);

# endif