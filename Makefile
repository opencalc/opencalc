
LUAPKG ?= lua5.1

CFLAGS=-Wall -Werror -fPIC $(shell pkg-config --cflags cairo ${LUAPKG})

LDFLAGS=-fPIC $(shell pkg-config --libs cairo ${LUAPKG})

ifeq ($(UI),fb)
	# Framebuffer
	UI_OBJS=ui.o ui_fb.o
else
	# X11 build
	UI_OBJS=ui.o ui_x11.o
endif

MPLIB_OBJS=mplib.o

all: ui.so mplib.so

ui.so: $(UI_OBJS)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

mplib.so: $(MPLIB_OBJS)
	$(CC) -shared -o $@ $^ -lmpfr

clean:
	rm -f ui.so $(UI_OBJS) mplib.so $(MPLIB_OBJS)
