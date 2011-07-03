
CFLAGS=-fPIC $(shell pkg-config --cflags cairo)

LDFLAGS=-fPIC $(shell pkg-config --libs cairo)

# X11 build
UI_OBJS=ui.o ui_x11.o

# Framebuffer
#UI_OBJS=ui.o ui_fb.o


all: ui.so

ui.so: $(UI_OBJS)
	$(CC) $(LDFLAGS) -shared -o $@ $^
