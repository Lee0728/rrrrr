CC=gcc
CFLAGS=
CPPFLAGS=

OBJS=ini.o parse.o retrieve.o section.o utils.o
all: test

test: test.o $(OBJS)
	$(CC) -o test test.o $(OBJS) -framework Foundation

clean:
	rm -f test test.o $(OBJS)
