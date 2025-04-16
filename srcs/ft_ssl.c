#include "ft_ssl.h"

int main(int argc, char** argv)
{
    (void) argv;
    if (argc != 2)
        return (1);
    
    ft_md5(argv[1], strlen(argv[1]));

    return (0); 
}
