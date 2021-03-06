ifdef CROSS
CC=$(CROSS)gcc
CXX=$(CROSS)g++
LD=$(CROSS)ld
AR=$(CROSS)ar
PKG_CONFIG=$(CROSS)pkg-config
endif

BASE_LIBS=
BASE_CFLAGS=-c -g -O2 -Wall -Wextra -pedantic-errors

#The files should compile on both C++03 and C++11
ifdef TESTCPP11
BASE_CFLAGS+= -std=c++11
else
BASE_CFLAGS+= -std=c++03
endif

#This is used to detect Mac because Mac needs CoreServices for linking
ifneq ($(OS),Windows_NT)
UNAME := $(shell uname -s)
ifeq ($(UNAME),Darwin)
BASE_LIBS+= -framework CoreServices
endif
endif

PROGRAMNAME=platform_folders

O_FILES=${PROGRAMNAME}.o sago/platform_folders.o

total: ${PROGRAMNAME}.out

clean: 
	rm -f */*.o *.o *.P */*.P ${PROGRAMNAME}.out

${PROGRAMNAME}.out: $(O_FILES)
	$(CXX) -O -o ${PROGRAMNAME}.out $(O_FILES) $(BASE_LIBS)

%.o : %.cpp
	$(CXX) -MD ${BASE_CFLAGS} -o $@ $<
	@mkdir -p `dirname .$(CROSS)deps/$*.P` && cp $*.d .$(CROSS)deps/$*.P; \
             sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
                 -e '/^$$/ d' -e 's/$$/ :/' < $*.d >> .$(CROSS)deps/$*.P; \
             rm -f $*.d

-include .$(CROSS)deps/*.P
