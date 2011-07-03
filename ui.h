
#include <cairo.h>

struct window {
	cairo_surface_t *surface;
};


struct context {
	cairo_t *cr;
};


/* platform specific code */
int ui_get_backend(lua_State *L);
int ui_create_window(lua_State *L);
int ui_destroy_window(lua_State *L);
int ui_next_event(lua_State *L);
