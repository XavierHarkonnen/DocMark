TARGET := docmark
DEFAULT_ARGUMENTS := test/test.dm
CLEAR_COMMAND := clear

# Lex Compiler
LXC := flex
# Ragel compiler
RLC := ragel
# C compiler
CC := gcc
# C++ compiler
CXX := g++
# linker
LD := gcc
# debugger
DB := valgrind # gdb

# Lex flags
LXFLAGS := 
# Ragel flags
RLFLAGS := 
# C flags
CFLAGS := 
# C++ flags
CXXFLAGS := 
# C/C++ flags
CPPFLAGS := -Wall -pedantic-errors -g -Og -ggdb

# dependency-generation flags
DEPFLAGS := -MMD -MP
# linker flags
LDFLAGS := 
# library flags
LDLIBS :=

# debugger flags
DBFLAGS := --leak-check=full --show-leak-kinds=all --track-origins=yes # -ex run --args

# build directories
SRC := src/
OBJ := obj/
BIN := bin/

# git branch
BRANCH := master
# default commit message
MESSAGE := Automatically committed

# Lex and Lex-compiled C files
LX_SOURCES  := $(wildcard $(SRC)*.l)
LXC_SOURCES := $(patsubst $(SRC)%.l, $(SRC)%.c, $(LX_SOURCES))

# Ragel and Ragel-compiled C files
RL_SOURCES  := $(wildcard $(SRC)*.rl)
RLC_SOURCES := $(patsubst $(SRC)%.rl, $(SRC)%.c, $(RL_SOURCES))

# C-compiled object files
OBJECTS := $(strip $(sort \
	$(patsubst $(SRC)%.l, $(OBJ)%.o, $(wildcard $(SRC)*.l)) \
	$(patsubst $(SRC)%.rl, $(OBJ)%.o, $(wildcard $(SRC)*.rl)) \
	$(patsubst $(SRC)%.c, $(OBJ)%.o, $(wildcard $(SRC)*.c)) \
	$(patsubst $(SRC)%.cc, $(OBJ)%.o, $(wildcard $(SRC)*.cc)) \
	$(patsubst $(SRC)%.cpp, $(OBJ)%.o, $(wildcard $(SRC)*.cpp)) \
	$(patsubst $(SRC)%.cxx, $(OBJ)%.o, $(wildcard $(SRC)*.cxx)) \
	$(patsubst $(SRC)%.cxx, $(OBJ)%.o, $(wildcard $(SRC)*.cxx)) \
	))

# include compiler-generated dependency rules
DEPENDS := $(OBJECTS:.o=.d)

# compile Lex source
COMPILE.l = $(LXC) $(LXFLAGS) -o $@
# compile Ragel source
COMPILE.rl = $(RLC) $(RLFLAGS) -C -o $@
# compile C source
COMPILE.c = $(CC) $(DEPFLAGS) $(CFLAGS) $(CPPFLAGS) -c -o $@
# compile C++ source
COMPILE.cxx = $(CXX) $(DEPFLAGS) $(CXXFLAGS) $(CPPFLAGS) -c -o $@
# link objects
LINK.o = $(LD) $(LDFLAGS) $(LDLIBS) $(OBJECTS) -o $@

.DEFAULT_GOAL = all

# build
.PHONY: all
all: $(BIN)$(TARGET)
	
$(BIN)$(TARGET): $(SRC) $(OBJ) $(BIN) $(OBJECTS)
	$(LINK.o)

$(SRC):
	mkdir -p $(SRC)

$(OBJ):
	mkdir -p $(OBJ)

$(BIN):
	mkdir -p $(BIN)

$(OBJ)%.o:	$(SRC)%.c $(RLC_SOURCES)
	$(COMPILE.c) $<

$(OBJ)%.o:	$(SRC)%.cc
	$(COMPILE.cxx) $<

$(OBJ)%.o:	$(SRC)%.cpp
	$(COMPILE.cxx) $<

$(OBJ)%.o:	$(SRC)%.cxx
	$(COMPILE.cxx) $<

$(RLC_SOURCES): $(RL_SOURCES)
	$(COMPILE.rl) $<

$(LXC_SOURCES): $(LX_SOURCES)
	$(COMPILE.l) $<

# force rebuild
.PHONY: remake
remake:	clean $(BIN)$(TARGET)

# execute the program
.PHONY: run
run: $(BIN)$(TARGET)
	./$(BIN)$(TARGET) $(DEFAULT_ARGUMENTS)

# clear terminal and execute the program
.PHONY: crun
crun: $(BIN)$(TARGET)
	$(CLEAR_COMMAND)
	./$(BIN)$(TARGET) $(DEFAULT_ARGUMENTS)

# execute the program via GDB
.PHONY: debug
debug: $(BIN)$(TARGET)
	$(DB) $(DBFLAGS) ./$(BIN)$(TARGET) $(DEFAULT_ARGUMENTS)

# remove previous build and objects
.PHONY: clean
clean:
	$(RM) $(LXC_SOURCES)
	$(RM) $(RLC_SOURCES)
	$(RM) $(OBJECTS)
	$(RM) $(DEPENDS)
	$(RM) $(BIN)$(TARGET)

# push changes to repository
.PHONY: commit
commit:
	git add .
	git commit -m "$(MESSAGE)"

# push changes to repository
.PHONY: push
push: commit
	git push origin $(BRANCH)

# pull changes from repository
.PHONY: pull
pull:
	git pull origin $(BRANCH)

-include $(DEPENDS)