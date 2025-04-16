NAME = ft_ssl

SOURCES_DIR = srcs
HEADERS_DIR = includes
OBJECTS_DIR = objs

SOURCES = ft_ssl.c \
			ft_md5.c

OBJECTS = $(addprefix $(OBJECTS_DIR)/, $(SOURCES:.c=.o))

CFLAGS = -Wall -Wextra -Werror -I$(HEADERS_DIR)
LDFLAGS = -lm

$(OBJECTS_DIR)/%.o: $(SOURCES_DIR)/%.c
	@mkdir -p $(OBJECTS_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

all: ${NAME}

$(NAME): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@ $(LDFLAGS)

clean:
	${RM} -rf ${OBJECTS_DIR}

fclean: clean
	${RM} -r ${NAME}

re: fclean all

.PHONY: all clean fclean re