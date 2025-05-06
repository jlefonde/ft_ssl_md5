#ifndef FT_SSL_H
# define FT_SSL_H

# include <stdbool.h>
# include <stdio.h>
# include <stdint.h>
# include <string.h>
# include <fcntl.h>
# include <unistd.h>
# include <stdlib.h>
# include <errno.h>

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
    t_input_type    type;
    char            *str;
    size_t          str_pos;
    int             fd;
}	t_input;

typedef union u_context
{
    struct
    {
        bool    reverse_mode;
        bool    quiet_mode;
        bool    stdin_mode;
        bool    sum_mode;
        t_list  *inputs;
    }	digest;
}	t_context;

typedef struct s_command t_command;

typedef struct s_category
{
    const char *name;
    t_context *(*parse_func)(const char *cmd_name, int argc, char **argv);
    void (*process_func)(t_command *cmd, t_context *ctx);
}	t_category;

typedef struct s_command
{
    const char          *name;
    const t_category    *category;
    void *(*cmd_func)(t_input *input);
    void (*print_func)(void *output);
}	t_command;

void ft_print_error(const char *s1, const char *s2, const char *s3);
uint32_t ft_rotate_left(const uint32_t X, const uint32_t N);
uint32_t ft_rotate_right(const uint32_t X, const uint32_t N);
ssize_t ft_read_from_input(t_input *input, void* buffer, size_t nbytes);

t_context *ft_parse_digest(const char *cmd_name, int argc, char **argv);
void ft_process_digest(t_command *cmd, t_context *ctx);

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
