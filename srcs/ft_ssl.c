#include "../includes/ft_ssl.h"

t_context ft_parse_digest(char **argv)
{
    t_context ctx;

    t_input *input = (t_input *)malloc(sizeof(t_input));

    input->type = INPUT_FILE;
    input->str = "test";

    ctx.inputs = ft_lstnew(input);
    ctx.mode.digest.quiet_mode = false;
    ctx.mode.digest.reverse_mode = false;
    ctx.mode.digest.stdin_mode = false;
    return ctx;
}

void ft_execute_digest(t_command cmd, t_context ctx)
{
    t_input *input = ctx.inputs->content;
    cmd.cmd_func(*input);
}

static const t_category categories[] = {
   { CATEGORY_DIGEST, "Message Digest", ft_parse_digest, ft_execute_digest }
};

static const t_command commands[] = {
    { "md5", &categories[0], ft_md5 }
};

const t_command *find_command(char *cmd)
{
    for (int i = 0; i < sizeof(commands)/sizeof(commands[0]); ++i)
    {
        if (ft_strncmp(cmd, commands[i].name, ft_strlen(cmd)) == 0)
            return &commands[i];
    }
    return NULL;
}

int main(int argc, char** argv)
{
    if (argc != 2)
    {
        ft_fprintf(2, "usage: ./ft_ssl command [flags] [file/string]\n");
        return (1);
    }

    const t_command *cmd = find_command(argv[1]);
    if (!cmd)
    {
        ft_fprintf(2, "ft_ssl: Error: '%s' is an invalid command.\n", argv[1]);
        return (1);
    }

    t_context ctx = cmd->category->parse_func(argv);
    cmd->category->execute_func(*cmd, ctx);

    return (0);
}
