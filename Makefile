NAME = ft_ssl

SOURCES_DIR = srcs
HEADERS_DIR = includes
OBJECTS_DIR = objs

SOURCES = ssl.c \
			utils.c \
            digest.c \
			md5.c \
			sha256.c \
			blake2s.c

OBJECTS = $(addprefix $(OBJECTS_DIR)/, $(SOURCES:.c=.o))

CFLAGS = -Wall -Wextra -Werror -I$(HEADERS_DIR)
LDFLAGS = -L./libft -lft

all: ./libft/libft.a $(NAME)

$(NAME): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@ $(LDFLAGS)

$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) -rf $(OBJECTS_DIR)

fclean: clean
	$(RM) -f $(NAME)
	@make fclean -C ./libft

re: fclean all

./libft/libft.a:
	make bonus -C ./libft

tester:
	@git clone https://github.com/bats-core/bats-core.git test/bats
	@git clone https://github.com/bats-core/bats-support.git test/test_helper/bats-support
	@git clone https://github.com/bats-core/bats-assert.git test/test_helper/bats-assert

.PHONY: all clean fclean re
