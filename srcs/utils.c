#include "ft_ssl.h"

void ft_print_error(const char *s1, const char *s2, const char *s3)
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

uint32_t ft_rotate_left(uint32_t X, uint32_t N)
{
    return ((X << N) | (X >> (32 - N)));
}

uint32_t ft_rotate_right(uint32_t X, uint32_t N)
{
    return ((X >> N) | (X << (32 - N)));
}

ssize_t ft_read_from_input(t_input *input, void* buffer, size_t nbytes)
{
    if (input->type == INPUT_STR)
    {
        size_t remaining_bytes = ft_strlen(&input->str[input->str_pos]);
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
            input->str = ft_strdup(buffer);
        else
        {
            char *current_str = ft_strdup(input->str);
            input->str = ft_strjoin(current_str, buffer);
            free(current_str);
        }
    }
    return (bytes_read);
}
