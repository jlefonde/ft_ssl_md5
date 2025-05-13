#include "ssl.h"

void free_input(void *content)
{
    t_input *input = (t_input *)content;

    if (input->str)
        free(input->str);
    if (input->type == INPUT_FILE)
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

    ft_fprintf(STDERR_FILENO, "ssl");
    if (s1)
        ft_fprintf(STDERR_FILENO, ": %s", s1);
    if (s2)
        ft_fprintf(STDERR_FILENO, ": %s", s2);
    if (s3)
        ft_fprintf(STDERR_FILENO, ": %s", s3);
    ft_fprintf(STDERR_FILENO, "\n");
}

uint32_t rotate_left(uint32_t X, uint32_t N)
{
    return ((X << N) | (X >> (32 - N)));
}

uint32_t rotate_right(uint32_t X, uint32_t N)
{
    return ((X >> N) | (X << (32 - N)));
}

void to_big_endian(uint64_t *value)
{
    *value = ((*value >> 56) & 0x00000000000000FF) |
            ((*value >> 40) & 0x000000000000FF00) |
            ((*value >> 24) & 0x0000000000FF0000) |
            ((*value >> 8)  & 0x00000000FF000000) |
            ((*value << 8)  & 0x000000FF00000000) |
            ((*value << 24) & 0x0000FF0000000000) |
            ((*value << 40) & 0x00FF000000000000) |
            ((*value << 56) & 0xFF00000000000000);
}

ssize_t read_from_input(t_input *input, void* buffer, size_t nbytes)
{
    if (input->type == INPUT_STR)
    {
        size_t remaining_bytes = strlen(&input->str[input->str_pos]);
        if (!remaining_bytes)
            return (0);

        size_t to_copy = remaining_bytes < nbytes ? remaining_bytes : nbytes;
        ft_memcpy(buffer, &input->str[input->str_pos], to_copy);
        input->str_pos += to_copy;

        return (to_copy);
    }

    ssize_t bytes_read = read(input->fd, buffer, nbytes);
    if (input->type == INPUT_STDIN)
    {
        ((char*)buffer)[bytes_read] = '\0';
        if (!input->str)
            input->str = strdup(buffer);
        else
        {
            char *current_str = strdup(input->str);
            input->str = ft_strjoin(current_str, buffer);
            free(current_str);
        }
    }
    return (bytes_read);
}
