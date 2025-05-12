# ifndef FT_BLAKE2S_H
#  define FT_BLAKE2S_H

# include "ft_ssl.h"

typedef struct s_command t_command;

void ft_process_blake2s(const t_command *cmd, int argc, char **argv);

# endif