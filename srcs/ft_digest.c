#include "../includes/ft_ssl.h"

t_context ft_parse_digest(int argc, char **argv)
{
    t_context ctx;
    ctx.u_flags.digest.quiet_mode = false;
    ctx.u_flags.digest.reverse_mode = false;
    ctx.u_flags.digest.stdin_mode = false;

    ctx.inputs = (t_list *)malloc(sizeof(t_list));

    bool is_sum_flag = false;
    bool file_found = false;
    for (int i = 2; i < argc - 2; ++i)
    {
        if (!file_found && ft_strncmp(argv[i], "-q", 2) == 0)
            ctx.u_flags.digest.quiet_mode = true;
        else if (!file_found && ft_strncmp(argv[i], "-r", 2) == 0)
            ctx.u_flags.digest.reverse_mode = true;
        else if (!file_found && ft_strncmp(argv[i], "-p", 2) == 0)
            ctx.u_flags.digest.stdin_mode = true;
        else if (!file_found && ft_strncmp(argv[i], "-s", 2) == 0)
            is_sum_flag = true;
        else
        {
            t_input *input = (t_input *)malloc(sizeof(t_input));

            input->type = is_sum_flag ? INPUT_STR : INPUT_FILE;
            input->str = argv[i];

            if (is_sum_flag)
                is_sum_flag = false;
            else
                file_found = true;

            ft_lstadd_back(&ctx.inputs, ft_lstnew(input));
        }
    }

    return ctx;
}

void ft_execute_digest(t_command cmd, t_context ctx)
{
    // t_input *input = ctx.inputs->content;
    // cmd.cmd_func(input);
}
