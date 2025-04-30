NAME = ft_ssl

SOURCES_DIR = srcs
HEADERS_DIR = includes
OBJECTS_DIR = objs

SOURCES = ft_ssl.c \
			ft_md5.c

OBJECTS = $(addprefix $(OBJECTS_DIR)/, $(SOURCES:.c=.o))

CFLAGS = -I$(HEADERS_DIR) #-Wall -Wextra -Werror
LDFLAGS = -L./libft -lft -lm

all: $(NAME)

$(NAME): $(OBJECTS)
	make bonus -C ./libft
	$(CC) $(CFLAGS) $(OBJECTS) -o $@ $(LDFLAGS)

$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
#	@make clean -C ./libft
	$(RM) -rf $(OBJECTS_DIR)

fclean: clean
#	@make fclean -C ./libft

re: fclean all

.PHONY: all clean fclean re
