/*
opencalc - an open source calculator

Copyright (C) 2011  Richard Titmuss <richard@opencalc.me>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program in the file COPYING; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#include <cairo.h>
#include <cairo-xlib.h>

#include "lua.h"
#include "lauxlib.h"

#include "ui.h"


struct window_x11 {
	cairo_surface_t *surface;

	Display *dpy;
	int scr;

	Window win;
	GC gc;

	int width, height;
};


int ui_get_backend(lua_State *L)
{
	lua_pushstring(L, "x11");
	return 1;
}


int ui_create_window(lua_State *L)
{
	struct window_x11 *window =
		lua_newuserdata(L, sizeof(struct window_x11));

	window->dpy = XOpenDisplay(0);
	if (window->dpy == NULL) {
		// FIXME lua error
		fprintf(stderr, "Failed to open display\n");
		return 0;
	}

	Window root;

	window->width = luaL_checknumber(L, 1);
	window->height = luaL_checknumber(L, 2);

	root = DefaultRootWindow(window->dpy);
	window->scr = DefaultScreen(window->dpy);

	window->win = XCreateSimpleWindow(window->dpy, root, 0, 0,
					  window->width, window->height, 0,
					  BlackPixel(window->dpy, window->scr),
					  BlackPixel(window->dpy, window->scr));

	XSelectInput(window->dpy, window->win,
		     KeyPressMask
		     |KeyReleaseMask
		     |ExposureMask);

	XMapWindow(window->dpy, window->win);
	XStoreName(window->dpy, window->win, "OpenCalc");
	
	Visual *visual = DefaultVisual(window->dpy, DefaultScreen(window->dpy));
	XClearWindow(window->dpy, window->win);

	window->surface = cairo_xlib_surface_create(
		window->dpy, window->win, visual,
		window->width, window->height);

	luaL_getmetatable(L, "ui.window");
	lua_setmetatable(L, -2);

	return 1;
}


int ui_destroy_window(lua_State *L)
{
	struct window_x11 *window = lua_touserdata(L, 1);

	XDestroyWindow(window->dpy, window->win);
	XCloseDisplay(window->dpy);

	return 0;
}


int ui_next_event(lua_State *L)
{
	struct window_x11 *window = lua_touserdata(L, 1);

	XEvent xev;

	XNextEvent(window->dpy, &xev);

	lua_newtable(L);

	switch(xev.type) {
	case KeyPress:
	case KeyRelease:
		{
			XKeyEvent *kev = &xev.xkey;

			KeySym sym = XKeycodeToKeysym(window->dpy,
						      kev->keycode, 0);

			lua_pushstring(L, (xev.type == KeyPress) ? "keypress" : "keyrelease");
			lua_setfield(L, -2, "type");

			lua_pushstring(L, XKeysymToString(sym));
			lua_setfield(L, -2, "value");
		}
		break;
	default:
	case Expose:
		{
			lua_pushstring(L, "draw");
			lua_setfield(L, -2, "type");
		}
		break;
	}

	return 1;
}
