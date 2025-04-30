#ifndef FT_SSL_H
# define FT_SSL_H

# include <stdbool.h>

# include "../libft/includes/libft.h"
# include "ft_md5.h"

typedef enum e_category_type
{
	CATEGORY_DIGEST,
}	t_category_type;

typedef enum e_input_type
{
	INPUT_FILE,
	INPUT_STR
}	t_input_type;

typedef struct s_input
{
	t_input_type type;
	char *str;
}	t_input;

typedef struct u_context
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
	} mode;
}	t_context;

typedef struct s_command t_command;

typedef struct s_category
{
	t_category_type type;
	char *name;
	t_context (*parse_func)(char **argv);
	void (*execute_func)(t_command cmd, t_context ctx);
}	t_category;

typedef struct s_command
{
    const char *name;
	const t_category *category;
	void (*cmd_func)(t_input input);
}	t_command;

t_context ft_parse_digest(char **argv);
void ft_execute_digest(t_command cmd, t_context ctx);

#endif
