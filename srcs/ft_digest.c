#include "../includes/ft_ssl.h"

static void ft_display_input(bool add_quotes, const char *start, const char *input_str, const char *end)
{
    if (add_quotes)
        printf("%s\"%s\"%s", start, input_str, end);
    else
        printf("%s%s%s", start, input_str, end);
}

static void ft_print_quiet_mode(t_command cmd, void *output)
{
    cmd.print_func(output);
    printf("\n");
}

static void ft_print_reverse_mode(t_command cmd, t_input *input, void *output, bool add_quotes)
{
    cmd.print_func(output);
    ft_display_input(add_quotes, " ", input->str, "\n");
}

static void ft_print_stdin_mode(t_command cmd, t_input *input, void *output, bool add_quotes)
{
    if (!add_quotes)
        ft_display_input(add_quotes, "(", "stdin", ")= ");
    else
        ft_display_input(add_quotes, "(", input->str, ")= ");
    cmd.print_func(output);
    printf("\n");
}

static void ft_print_normal_mode(t_command cmd, t_input *input, void *output, bool add_quotes)
{
    char *cmd_name = ft_strmap(cmd.name, ft_toupper);
    printf("%s", cmd_name);
    free(cmd_name);

    ft_display_input(add_quotes, "(", input->str, ")= ");
    cmd.print_func(output);
    printf("\n");
}

static void ft_process_cmd(t_command cmd, t_context ctx, t_input *input)
{
    void *output = cmd.cmd_func(input);
    if (!output)
        return ;

    bool is_file = (input->type == INPUT_FILE);
    bool is_stdin = (input->type == INPUT_STDIN);
    bool add_quotes = (!is_file && !is_stdin || (is_stdin && ctx.u_flags.digest.stdin_mode));

    if (ctx.u_flags.digest.quiet_mode)
        ft_print_quiet_mode(cmd, output);
    else if (is_stdin)
        ft_print_stdin_mode(cmd, input, output, add_quotes);
    else if (ctx.u_flags.digest.reverse_mode)
        ft_print_reverse_mode(cmd, input, output, add_quotes);
    else
        ft_print_normal_mode(cmd, input, output, add_quotes);
}

void ft_handle_stdin_input(int argc, t_context *ctx, bool file_found)
{
    bool any_flags = (ctx->u_flags.digest.reverse_mode || ctx->u_flags.digest.quiet_mode || ctx->u_flags.digest.stdin_mode || ctx->u_flags.digest.sum_mode);
    bool has_input = ft_lstsize(ctx->inputs) > 0;
    
    if ((argc == 2 || ctx->u_flags.digest.stdin_mode || !has_input) && (!file_found || any_flags))
    {
        t_input *input = (t_input *)malloc(sizeof(t_input));

        input->type = INPUT_STDIN;
        input->fd = STDIN_FILENO;
        input->str = NULL;
        input->str_pos = 0;

        ft_lstadd_front(&ctx->inputs, ft_lstnew(input));
    }
}

void ft_print_error(const char *cmd_name, const char *input, const char *error_msg)
{
    if (cmd_name && input  && error_msg)
        ft_fprintf(STDERR_FILENO, "ft_ssl: %s: %s: %s\n", cmd_name, input, error_msg);
    else if (cmd_name && !input  && error_msg)
        ft_fprintf(STDERR_FILENO, "ft_ssl: %s: %s\n", cmd_name, error_msg);
    else if (!cmd_name && !input  && error_msg)
        ft_fprintf(STDERR_FILENO, "ft_ssl: %s\n", error_msg);
}

t_context ft_parse_digest(const char *cmd_name, int argc, char **argv)
{
    t_context ctx;
    ctx.u_flags.digest.quiet_mode = false;
    ctx.u_flags.digest.reverse_mode = false;
    ctx.u_flags.digest.stdin_mode = false;
    ctx.u_flags.digest.sum_mode = false;
    ctx.inputs = NULL;

    bool sum_mode = false;
    bool file_found = false;
    for (int i = 2; i < argc; ++i)
    {
        bool is_input = (sum_mode || file_found);

        if (!is_input && argv[i][0] == '-')
        {
            if (ft_strncmp(argv[i], "-q", 3) == 0)
                ctx.u_flags.digest.quiet_mode = true;
            else if (ft_strncmp(argv[i], "-r", 3) == 0)
                ctx.u_flags.digest.reverse_mode = true;
            else if (ft_strncmp(argv[i], "-p", 3) == 0)
                ctx.u_flags.digest.stdin_mode = true;
            else if (ft_strncmp(argv[i], "-s", 3) == 0)
            {
                ctx.u_flags.digest.sum_mode = true;
                sum_mode = true;
            }
            else
            {
                ft_print_error(cmd_name, argv[i], "Unknown flag");
                exit(EXIT_FAILURE);
            }
        }
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

    if (sum_mode)
    {
        ft_print_error(cmd_name, NULL, "Missing argument for -s");
        exit(EXIT_FAILURE);
    }

    ft_handle_stdin_input(argc, &ctx, file_found);

    return (ctx);
}

void ft_process_digest(t_command cmd, t_context ctx)
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
                    ft_print_error(cmd.name, input->str, strerror(errno));
                    free(input);
                    free(current);
                    current = next;
                    continue;
                }
            }
            ft_process_cmd(cmd, ctx, input);
            if (input->type == INPUT_FILE)
                close(input->fd);
            free(input);
        }
        free(current);
        current = next;
    }
}
