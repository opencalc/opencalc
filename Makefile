
CFLAGS=-Wall -Werror -fPIC $(shell pkg-config --cflags cairo lua5.1)

LDFLAGS=-fPIC $(shell pkg-config --libs cairo lua5.1)

ifeq ($(UI),fb)
	# Framebuffer
	UI_OBJS=ui.o ui_fb.o
else
	# X11 build
	UI_OBJS=ui.o ui_x11.o
endif

all: ui.so

ui.so: $(UI_OBJS)
	$(CC) $(LDFLAGS) -shared -o $@ $^

clean:
	rm -f ui.so $(UI_OBJS)
