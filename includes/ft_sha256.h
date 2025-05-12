# ifndef FT_SHA256_H
#  define FT_SHA256_H

# include "ft_ssl.h"

typedef struct s_command t_command;

void ft_process_sha256(const t_command *cmd, int argc, char **argv);

# endif