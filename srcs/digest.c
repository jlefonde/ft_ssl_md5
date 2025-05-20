#include "ssl.h"

static void print_cmd(const t_command *cmd)
{
    char *cmd_name = ft_strmap(cmd->name, ft_toupper);
    ft_printf("%s", cmd_name);
    free(cmd_name);
}

static void display_input(t_context *ctx, t_input *input, char *start, const char *end)
{
    bool is_file = (input->type == INPUT_FILE);
    bool is_stdin = (input->type == INPUT_STDIN);
    bool add_quotes = (!is_file || (is_stdin && ctx->digest.stdin_mode));

    if (is_stdin && !ctx->digest.stdin_mode)
        ft_printf("%sstdin%s", start, end);
    else if (add_quotes)
        ft_printf("%s\"%s\"%s", start, input->str, end);
    else
        ft_printf("%s%s%s", start, input->str, end);
}

static void print_quiet_mode(t_context *ctx, void *output)
{
    ctx->digest.print_func(output);
    ft_printf("\n");
}

static void print_reverse_mode(t_context *ctx, t_input *input, void *output)
{
    ctx->digest.print_func(output);
    display_input(ctx, input, " ", "\n");
}

static void print_normal_mode(const t_command *cmd, t_context *ctx, t_input *input, void *output)
{
    print_cmd(cmd);
    display_input(ctx, input, "(", ")= ");
    ctx->digest.print_func(output);
    ft_printf("\n");
}

static void handle_stdin_input(const t_command *cmd, int argc, t_context *ctx, bool file_found)
{
    bool any_flags = (ctx->digest.reverse_mode || ctx->digest.quiet_mode || ctx->digest.stdin_mode || ctx->digest.sum_mode);
    bool has_input = ft_lstsize(ctx->digest.inputs) > 0;

    if ((argc == 2 || ctx->digest.stdin_mode || !has_input) && (!file_found || any_flags))
    {
        t_input *input = (t_input *)malloc(sizeof(t_input));
        if (!input)
            fatal_error(ctx, cmd->name, strerror(errno), NULL);

        input->type = INPUT_STDIN;
        input->fd = STDIN_FILENO;
        input->str = NULL;
        input->str_pos = ctx->digest.stdin_mode ? 0 : -1;

        ft_lstadd_front(&ctx->digest.inputs, ft_lstnew(input));
    }
}

static void process_cmd(const t_command *cmd, t_context *ctx, t_input *input)
{
    void *output = ctx->digest.cmd_func(input);
    if (!output)
        return ;

    if (ctx->digest.quiet_mode)
        print_quiet_mode(ctx, output);
    else if (ctx->digest.reverse_mode && input->type != INPUT_STDIN)
        print_reverse_mode(ctx, input, output);
    else
        print_normal_mode(cmd, ctx, input, output);
}

t_context *parse_digest(const t_command *cmd, int argc, char **argv)
{
    t_context *ctx = (t_context *)malloc(sizeof(t_context));
    if (!ctx)
    {
        print_error(cmd->name, strerror(errno), NULL);
        exit(EXIT_FAILURE);
    }

    ctx->digest.quiet_mode = false;
    ctx->digest.reverse_mode = false;
    ctx->digest.stdin_mode = false;
    ctx->digest.sum_mode = false;
    ctx->digest.inputs = NULL;

    bool sum_mode = false;
    bool file_found = false;
    for (int i = 2; i < argc; ++i)
    {
        bool is_input = (sum_mode || file_found);

        if (!is_input && argv[i][0] == '-')
        {
            if (ft_strcmp(argv[i], "-q") == 0)
                ctx->digest.quiet_mode = true;
            else if (ft_strcmp(argv[i], "-r") == 0)
                ctx->digest.reverse_mode = true;
            else if (ft_strcmp(argv[i], "-p") == 0)
                ctx->digest.stdin_mode = true;
            else if (ft_strcmp(argv[i], "-s") == 0)
            {
                ctx->digest.sum_mode = true;
                sum_mode = true;
            }
            else
                fatal_error(ctx, cmd->name, argv[i], "Unknown flag");
        }
        else
        {
            t_input *input = (t_input *)malloc(sizeof(t_input));
            if (!input)
                fatal_error(ctx, cmd->name, strerror(errno), NULL);

            input->type = sum_mode ? INPUT_STR : INPUT_FILE;
            input->str = ft_strdup(argv[i]);
            input->fd = -1;
            input->str_pos = 0;

            if (sum_mode)
                sum_mode = false;
            else
                file_found = true;

            ft_lstadd_back(&ctx->digest.inputs, ft_lstnew(input));
        }
    }

    if (sum_mode)
        fatal_error(ctx, cmd->name, NULL, "Option -s needs a value");

    handle_stdin_input(cmd, argc, ctx, file_found);

    return (ctx);
}

void process_digest(const t_command *cmd, t_context *ctx)
{
    t_list *current = ctx->digest.inputs;
    t_list *next;

    while (current)
    {
        next = current->next;
        t_input *input = current->content;
        if (input->type == INPUT_FILE)
        {
            input->fd = open(input->str, O_RDONLY);
            if (input->fd == -1)
            {
                print_error(cmd->name, input->str, strerror(errno));
                free_input(input);
                free(current);
                current = next;
                continue;
            }
        }
        process_cmd(cmd, ctx, input);
        free_input(input);
        free(current);
        current = next;
    }
}
