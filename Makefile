NAME 			=	webserv

INC_PATH		=	src/includes/
OBJS_PATH 		=	obj/
SRCS_PATH 		=	src/
CC 				=	clang++
CFLAGS			=	-Wall -Werror -Wextra -Wpedantic -std=c++98
RM				=	rm -rf

INC_FILES 		=	colors.hpp defines.hpp status_codes.hpp

SRCS_FILES		=	main.cpp 

UTILS_FILES		=	logger.cpp utils.cpp Error.cpp
UTILS_HDRS		=	utils.hpp

PARSER_FILES	=	ConfigParser.cpp ConfigParser_utils.cpp RequestParser.cpp
PARSER_HDRS		=	config_fields.hpp ConfigParser.hpp RequestParser.hpp
				
SERVER_FILES	= 	Server.cpp Socket.cpp Response.cpp Get.cpp Post.cpp Delete.cpp CGI.cpp
SERVER_HDRS		= 	Server.hpp Socket.hpp Response.hpp

CGI_FILES		=		
CGI_HDRS		=	CGI.hpp

UTILS_PATH		= 	$(SRCS_PATH)utils/
SERVER_PATH		=	$(SRCS_PATH)server/
PARSER_PATH		=	$(SRCS_PATH)parser/
CGI_PATH		=	$(SRCS_PATH)cgi/

SRCS 			=	$(addprefix $(SRCS_PATH), $(SRCS_FILES))
SERVER_SRCS		=	$(addprefix $(SERVER_PATH), $(SERVER_FILES))
UTILS_SRCS		= 	$(addprefix $(UTILS_PATH), $(UTILS_FILES))
PARSER_SRCS		= 	$(addprefix $(PARSER_PATH), $(PARSER_FILES))
CGI_SRCS		=	$(addprefix $(CGI_PATH), $(CGI_FILES))

OBJS_FILES		= 	$(SRCS_FILES:.cpp=.o) $(UTILS_FILES:.cpp=.o) $(SERVER_FILES:.cpp=.o)\
					$(PARSER_FILES:.cpp=.o) $(CGI_FILES:.cpp=.o)

INCLUDES		=	$(addprefix $(INC_PATH), $(INC_FILES))	
OBJS 			=	$(addprefix $(OBJS_PATH), $(OBJS_FILES))

VPATH			=	$(SRCS_PATH) $(UTILS_PATH) $(SERVER_PATH) $(PARSER_PATH) $(CGI_PATH)

ALL_SRCS		= 	$(addprefix $(SRCS_PATH), $(SRCS_FILES))\
					$(addprefix $(UTILS_PATH), $(UTILS_FILES))\
					$(addprefix $(PARSER_PATH), $(PARSER_FILES))\
					$(addprefix $(SERVER_PATH), $(SERVER_FILES))\
#					$(addprefix $(CGI_PATH), $(CGI_FILES))\

USAGE			=	"\033[38;5;57m./webserv <empty for default config file>\\n"\
					"Default Ports: \033[38;5;135m8081 || 4242\033[0m\\n"


$(OBJS_PATH)%.o: %.cpp
	@$(CC) $(CFLAGS) -I$(INC_PATH) -c $< -o $@
	@printf "\033[93m▓▓▓\033[0m"

all:	$(NAME)

$(NAME):	$(OBJS_PATH) $(OBJS) 
	@$(CC) $(OBJS) -o $(NAME)
	@echo "\\n\033[32;1m\nWebServ IS READY \033[0m \\n"
	@echo $(USAGE)

$(OBJS_PATH):
	@mkdir -p $(OBJS_PATH)
	@echo "\033[34;1mCreating Object Directory\n \033[0m"
	@printf "\033[32;1m\nCompiling with: \033[38;5;208m$(CFLAGS)\033[0m\\n\\n"
	
linux : CFLAGS += -g
linux :	$(OBJS_PATH) $(OBJS)
	@echo "\033[95mCompiling WebServ \033[0m"
	$(CC) $(OBJS) -o $(NAME)
	@echo "\\n\033[32;1mWebServ IS READY \033[0m \\n"
	@echo $(USAGE)

debug:	CFLAGS += -g -fstandalone-debug -DDEBUG=1 -fno-limit-debug-info
debug:	$(NAME)
	@printf "\033[32;1m\nCompiling with: \033[38;5;208m$(CFLAGS)\033[0m \\n"

release: CFLAGS += -O3
release: all

fmt:
	clang-format -i $(ALL_SRCS) $(addsuffix *.hpp, $(INC_PATH))

clean:
	@$(RM) $(OBJS_FILES) $(OBJS_PATH) 
	@echo "\033[34;1mCLEAN DONE\033[0m"

fclean: clean
	@$(RM) $(NAME)
	@echo "\033[34;1mFCLEAN DONE\033[0m"

re: fclean all

redebug: fclean debug

.PHONY: all clean fclean re linux debug redebug
