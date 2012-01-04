OS=$(shell uname)

ifeq ($(OS),Darwin)
	LUAPKG ?= lua
else
	LUAPKG ?= lua5.1
endif

CFLAGS=-Wall -Werror -fPIC $(shell pkg-config --cflags cairo ${LUAPKG})

LDFLAGS=-fPIC -lgmp -lmpfr $(shell pkg-config --libs cairo ${LUAPKG})

ifeq ($(UI),fb)
	# Framebuffer
	UI_OBJS=ui.o ui_fb.o
else
	# X11 build
	UI_OBJS=ui.o ui_x11.o
	LDFLAGS+=-lX11
endif

MPLIB_OBJS=mplib.o

all: ui.so mplib.so

ui.so: $(UI_OBJS)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

mplib.so: $(MPLIB_OBJS)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

clean:
	rm -f ui.so $(UI_OBJS) mplib.so $(MPLIB_OBJS)
