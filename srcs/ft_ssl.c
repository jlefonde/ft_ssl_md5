#include "ft_ssl.h"

static const t_category g_categories[] = {
    [CATEGORY_DIGEST] = { "Message Digest" }
};

static const t_command g_commands[] = {
    { "md5", &g_categories[CATEGORY_DIGEST], ft_process_md5 },
    { "sha256", &g_categories[CATEGORY_DIGEST], ft_process_sha256 }
};

static const t_command *ft_get_command(char *cmd)
{
    for (size_t i = 0; i < sizeof(g_commands)/sizeof(g_commands[0]); ++i)
    {
        const char *command_name = g_commands[i].name;
        if (ft_strcasecmp(cmd, command_name) == 0)
            return (&g_commands[i]);
    }
    return (NULL);
}

static void ft_helper(int fd)
{
    size_t categories_size = sizeof(g_categories)/sizeof(g_categories[0]);
    for (size_t i = 0; i < categories_size; ++i)
    {
        ft_fprintf(fd, "%s commands:\n", g_categories[i].name);
        for (size_t j = 0; j < sizeof(g_commands)/sizeof(g_commands[0]); ++j)
        {
            if (g_commands[j].category == &g_categories[i])
                ft_fprintf(fd, " %s\n", g_commands[j].name);
        }
        if ((i + 1) < categories_size)
            ft_fprintf(fd, "\n");
    }
}

int main(int argc, char** argv)
{
    if (argc < 2)
    {
        ft_fprintf(STDERR_FILENO, "usage: ./ft_ssl <command> [options] [file/string]\n\n");
        ft_helper(STDERR_FILENO);
        return (1);
    }

    const t_command *cmd = ft_get_command(argv[1]);
    if (!cmd)
    {
        ft_fprintf(STDERR_FILENO, "ft_ssl: '%s' is an invalid command\n\n", argv[1]);
        ft_helper(STDERR_FILENO);
        return (1);
    }

    cmd->process_func(cmd, argc, argv);

    return (0);
}
