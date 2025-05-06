#include "ft_ssl.h"

void ft_sha256_print(void *output)
{
    printf("OUTPUT");
}

void *ft_sha256(t_input *input)
{
    uint32_t *digest = malloc(8 * sizeof(uint32_t));
    if (!digest)
        return (NULL);

    uint8_t block[64];
    ssize_t total_msg_size = 0;
    ssize_t bytes_read = 0;
    while ((bytes_read = ft_read_from_input(input, block, 64)) >= 0)
    {
        total_msg_size += bytes_read;

        if (bytes_read == 64)
            ft_process_block(block, digest);
        else
        {
            ft_md5_final(block, bytes_read, total_msg_size * 8, digest);
            break ;
        }
    }

    if (bytes_read == -1)
    {
        ft_fprintf(STDERR_FILENO, "ft_ssl: md5: %s\n", strerror(errno));
        return (NULL);
    }

    return (digest);
}
