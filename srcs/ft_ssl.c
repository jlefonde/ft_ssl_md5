#include "../includes/ft_ssl.h"

t_context ft_parse_digest(char **argv)
{
    t_context ctx;

    t_input *input = (t_input *)malloc(sizeof(t_input));

    input->type = INPUT_FILE;
    input->str = "test";

    ctx.inputs = ft_lstnew(input);
    ctx.u_flags.digest.quiet_mode = false;
    ctx.u_flags.digest.reverse_mode = false;
    ctx.u_flags.digest.stdin_mode = false;
    return ctx;
}

void ft_execute_digest(t_command cmd, t_context ctx)
{
    t_input *input = ctx.inputs->content;
    cmd.cmd_func(*input);
}

static const t_category g_categories[] = {
   [CATEGORY_DIGEST] = { "Message Digest", ft_parse_digest, ft_execute_digest }
};

static const t_command g_commands[] = {
    { "md5", &g_categories[CATEGORY_DIGEST], ft_md5 }
};

const t_command *ft_get_command(char *cmd)
{
    for (int i = 0; i < sizeof(g_commands)/sizeof(g_commands[0]); ++i)
    {
        const char *command_name = g_commands[i].name;
        if (ft_strncasecmp(cmd, command_name, ft_strlen(command_name)) == 0)
            return &g_commands[i];
    }
    return NULL;
}

void ft_helper()
{
    for (int i = 0; i < sizeof(g_categories)/sizeof(g_categories[0]); ++i)
    {
        ft_fprintf(STDERR_FILENO, "%s commands:\n", g_categories[i].name);
        for (int j = 0; j < sizeof(g_commands)/sizeof(g_commands[0]); ++j)
        {
            if (g_commands[j].category == &g_categories[i])
                ft_fprintf(STDERR_FILENO, " %s\n", g_commands[j].name);
        }
    }
}

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        ft_fprintf(STDERR_FILENO, "usage: ./ft_ssl <command> [flags] [file/string]\n\n");
        ft_helper();
        return (1);
    }

    const t_command *command = ft_get_command(argv[1]);
    if (!command)
    {
        ft_fprintf(STDERR_FILENO, "ft_ssl: Error: '%s' is an invalid command.\n\n", argv[1]);
        ft_helper();
        return (1);
    }

    t_context context = command->category->parse_func(argv);
    command->category->execute_func(*command, context);

    return (0);
}
