#include "../includes/ft_ssl.h"

static void ft_display_input(t_input *input, const char *start, const char *end)
{
    if (input->type == INPUT_FILE)
        ft_printf("%s%s%s", start, input->str, end);
    else
        ft_printf("%s\"%s\"%s", start, input->str, end);
}

static void ft_display_digest(t_input *input, t_command cmd, t_context ctx)
{
    if (!ctx.u_flags.digest.quiet_mode)
    {
        if (ctx.u_flags.digest.reverse_mode)
        {
            cmd.cmd_func(input);
            ft_display_input(input, " ", "\n");
        }
        else
        {
            char *cmd_name = ft_strmap(cmd.name, ft_toupper);
            ft_printf("%s", cmd_name);
            free(cmd_name);
            ft_display_input(input, " (", ")= ");
            cmd.cmd_func(input);
            ft_printf("\n");
        }
    }
}

t_context ft_parse_digest(int argc, char **argv)
{
    t_context ctx;
    ctx.u_flags.digest.quiet_mode = false;
    ctx.u_flags.digest.reverse_mode = false;
    ctx.u_flags.digest.stdin_mode = false;
    ctx.inputs = NULL;

    bool sum_mode = false;
    bool file_found = false;
    for (int i = 2; i < argc; ++i)
    {
        bool is_input = (sum_mode || file_found);
        if (!is_input && ft_strncmp(argv[i], "-q", 2) == 0)
            ctx.u_flags.digest.quiet_mode = true;
        else if (!is_input && ft_strncmp(argv[i], "-r", 2) == 0)
            ctx.u_flags.digest.reverse_mode = true;
        else if (!is_input && ft_strncmp(argv[i], "-p", 2) == 0)
            ctx.u_flags.digest.stdin_mode = true;
        else if (!is_input && ft_strncmp(argv[i], "-s", 2) == 0)
            sum_mode = true;
        else
        {
            t_input *input = (t_input *)malloc(sizeof(t_input));

            input->type = sum_mode ? INPUT_STR : INPUT_FILE;
            input->str = argv[i];
            input->fd = -1;
            input->str_pos = 0;

            if (sum_mode)
                sum_mode = false;
            else
                file_found = true;

            ft_lstadd_back(&ctx.inputs, ft_lstnew(input));
        }
    }
    return (ctx);
}

void ft_execute_digest(t_command cmd, t_context ctx)
{
    t_list *current = ctx.inputs;
    t_list *next;

    while (current)
    {
        next = current->next;
        t_input *input = current->content;
        if (input)
        {
            if (input->type == INPUT_FILE)
            {
                input->fd = open(input->str, O_RDONLY);
                if (input->fd == -1)
                {
                    ft_printf("ft_ssl: %s: %s: %s\n", cmd.name, input->str, strerror(errno));
                    free(input);
                    free(current);
                    current = next;
                    continue;
                }
            }
            ft_display_digest(input, cmd, ctx);
            if (input->fd > 2)
                close(input->fd);
            free(input);
        }
        free(current);
        current = next;
    }
}
