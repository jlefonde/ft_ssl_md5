#ifndef FT_SSL_H
# define FT_SSL_H

# include <stdbool.h>
# include <stdio.h>
# include <math.h>
# include <stdint.h>
# include <string.h>
# include <fcntl.h>
# include <unistd.h>
# include <stdlib.h>
# include <errno.h>
# include <poll.h>

# include "../libft/includes/libft.h"

typedef enum e_category_type
{
	CATEGORY_DIGEST,
}	t_category_type;

typedef enum e_input_type
{
    INPUT_STDIN,
	INPUT_FILE,
	INPUT_STR
}	t_input_type;

typedef struct s_input
{
	t_input_type type;
	char *str;
	size_t str_pos;
	int fd;
}	t_input;

typedef struct s_context
{
	t_list *inputs;
	union
	{
    	struct
    	{
    		bool reverse_mode;
    		bool quiet_mode;
    		bool stdin_mode;
    	}	digest;
	} u_flags;
}	t_context;

typedef struct s_command t_command;

typedef struct s_category
{
	const char *name;
	t_context (*parse_func)(int argc, char **argv);
	void (*process_func)(t_command cmd, t_context ctx);
}	t_category;

typedef struct s_command
{
    const char *name;
	const t_category *category;
	void *(*cmd_func)(t_input *input);
	void (*print_func)(void *output);
}	t_command;

t_context ft_parse_digest(int argc, char **argv);
void ft_process_digest(t_command cmd, t_context ctx);

# ifndef FT_MD5_H
#  define FT_MD5_H

typedef struct s_md5_round
{
    uint32_t A;
    uint32_t B;
    uint32_t C;
    uint32_t D;
    uint32_t w[16];
}   t_md5_round;

void *ft_md5(t_input *input);
void ft_md5_print(void *output);

# endif

#endif
