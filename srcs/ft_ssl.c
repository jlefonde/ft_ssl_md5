#include "../includes/ft_ssl.h"

static const t_category g_categories[] = {
    [CATEGORY_DIGEST] = { "Message Digest", ft_parse_digest, ft_execute_digest }
};

static const t_command g_commands[] = {
    { "md5", &g_categories[CATEGORY_DIGEST], ft_md5, ft_md5_print }
};

const t_command *ft_get_command(char *cmd)
{
    for (int i = 0; i < sizeof(g_commands)/sizeof(g_commands[0]); ++i)
    {
        const char *command_name = g_commands[i].name;
        if (ft_strncasecmp(cmd, command_name, ft_strlen(command_name)) == 0)
            return (&g_commands[i]);
    }
    return (NULL);
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
    if (argc < 2)
    {
        ft_fprintf(STDERR_FILENO, "usage: ./ft_ssl <command> [flags] [file/string]\n\n");
        ft_helper();
        return (1);
    }

    const t_command *cmd = ft_get_command(argv[1]);
    if (!cmd)
    {
        ft_fprintf(STDERR_FILENO, "ft_ssl: Error: '%s' is an invalid command.\n\n", argv[1]);
        ft_helper();
        return (1);
    }

    t_context ctx = cmd->category->parse_func(argc, argv);
    cmd->category->execute_func(*cmd, ctx);

    return (0);
}
