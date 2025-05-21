#include "ssl.h"

void free_input(void *content)
{
    t_input *input = (t_input *)content;

    if (input->str)
        free(input->str);
    if (input->type == INPUT_FILE && input->fd != -1)
        close(input->fd);
    free(input);
}

void fatal_error(t_context *ctx, const char *s1, const char *s2, const char *s3)
{
    print_error(s1, s2, s3);
    if (ctx->digest.inputs)
        ft_lstclear(&ctx->digest.inputs, free_input);
    free(ctx);
    exit(EXIT_FAILURE);
}

void print_error(const char *s1, const char *s2, const char *s3)
{
    if (!s1 && !s2 && !s3)
        return ;

    ft_fprintf(STDERR_FILENO, "ft_ssl");
    if (s1)
        ft_fprintf(STDERR_FILENO, ": %s", s1);
    if (s2)
        ft_fprintf(STDERR_FILENO, ": %s", s2);
    if (s3)
        ft_fprintf(STDERR_FILENO, ": %s", s3);
    ft_fprintf(STDERR_FILENO, "\n");
}

ssize_t read_from_input(t_input *input, void* buffer, size_t nbytes)
{
    if (input->type == INPUT_STR)
    {
        if (!input->str)
            return (0);
        size_t remaining_bytes = ft_strlen(&input->str[input->str_pos]);
        if (!remaining_bytes)
            return (0);

        size_t to_copy = remaining_bytes < nbytes ? remaining_bytes : nbytes;
        ft_memcpy(buffer, &input->str[input->str_pos], to_copy);
        input->str_pos += to_copy;

        return (to_copy);
    }
    else if (input->type == INPUT_STDIN)
    {
        ssize_t total_bytes_read = 0;
        ssize_t bytes_read = 0;

        while (total_bytes_read < (ssize_t)nbytes)
        {
            bytes_read = read(input->fd, buffer + total_bytes_read, nbytes - total_bytes_read);
            if (bytes_read <= 0)
                break;
            if (input->str_pos == 0)
            {
                ((char *)buffer)[bytes_read] = 0;
                if (!input->str)
                    input->str = ft_strdup(buffer);
                else
                {
                    char *joined = ft_strjoin(input->str, buffer);
                    free(input->str);
                    input->str = joined;
                }
            }
            total_bytes_read += bytes_read;
        }
        return (total_bytes_read > 0 ? total_bytes_read : bytes_read);
    }
    return (read(input->fd, buffer, nbytes));
}
