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

CFLAGS = -I$(HEADERS_DIR) #-Wall -Wextra -Werror
LDFLAGS = -L./libft -lft

all: libft $(NAME)

$(NAME): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@ $(LDFLAGS)

$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) -rf $(OBJECTS_DIR)

fclean: clean

re: fclean all

libft:
	make bonus -C ./libft

.PHONY: all clean fclean re libft
