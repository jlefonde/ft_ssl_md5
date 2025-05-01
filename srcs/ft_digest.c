#include "../includes/ft_ssl.h"

t_context ft_parse_digest(char **argv)
{
    t_context ctx;

    t_input *input = (t_input *)malloc(sizeof(t_input));

    input->type = INPUT_FILE;
    input->str = "file";

    ctx.inputs = ft_lstnew(input);
    ctx.u_flags.digest.quiet_mode = false;
    ctx.u_flags.digest.reverse_mode = false;
    ctx.u_flags.digest.stdin_mode = false;
    return ctx;
}

void ft_execute_digest(t_command cmd, t_context ctx)
{
    t_input *input = ctx.inputs->content;
    cmd.cmd_func(input);
}
