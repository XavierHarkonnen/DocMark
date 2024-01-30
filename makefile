TARGET := docmark
DEFAULT_ARGUMENTS := -o test/out.html test/in.dm -c test/styles.css -f -t hello

# Ragel compiler
RLC := ragel
# C compiler
CC := gcc
# C++ compiler
CXX := g++
# linker
LD = gcc

# Ragel flags
RLFLAGS := 
# C flags
CFLAGS := -std=c17
# C++ flags
CXXFLAGS := -std=cpp17
# C/C++ flags
CPPFLAGS := -Wall -pedantic-errors

# dependency-generation flags
DEPFLAGS := -MMD -MP
# linker flags
LDFLAGS := 
# library flags
LDLIBS := 

# build directories
SRC := src/
OBJ := obj/
BIN := bin/

# git branch
BRANCH := main
# default commit message
MESSAGE := Automatically committed


RL_SOURCES := $(wildcard $(SRC)*.rl)
RC_SOURCES := $(patsubst $(SRC)%.rl, $(SRC)%.c, $(RL_SOURCES))

OBJECTS := \
	$(patsubst $(SRC)%.rl, $(OBJ)%.o, $(wildcard $(SRC)*.rl)) \
	$(patsubst $(SRC)%.c, $(OBJ)%.o, $(wildcard $(SRC)*.c)) \
	$(patsubst $(SRC)%.cc, $(OBJ)%.o, $(wildcard $(SRC)*.cc)) \
	$(patsubst $(SRC)%.cpp, $(OBJ)%.o, $(wildcard $(SRC)*.cpp)) \
	$(patsubst $(SRC)%.cxx, $(OBJ)%.o, $(wildcard $(SRC)*.cxx)) \
	$(patsubst $(SRC)%.cxx, $(OBJ)%.o, $(wildcard $(SRC)*.cxx))

# include compiler-generated dependency rules
DEPENDS := $(OBJECTS:.o=.d)

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

$(OBJ)%.o:	$(SRC)%.c $(RC_SOURCES)
	$(COMPILE.c) $<

$(OBJ)%.o:	$(SRC)%.cc
	$(COMPILE.cxx) $<

$(OBJ)%.o:	$(SRC)%.cpp
	$(COMPILE.cxx) $<

$(OBJ)%.o:	$(SRC)%.cxx
	$(COMPILE.cxx) $<

$(RC_SOURCES): $(RL_SOURCES)
	$(COMPILE.rl) $<

# force rebuild
.PHONY: remake
remake:	clean $(BIN)$(TARGET)

# execute the program
.PHONY: run
run: $(BIN)$(TARGET)
	./$(BIN)$(TARGET) $(DEFAULT_ARGUMENTS)

# remove previous build and objects
.PHONY: clean
clean:
	$(RM) $(RC_SOURCES)
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
.PHONY: push
pull:
	git pull origin $(BRANCH)

-include $(DEPENDS)