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

#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <linux/fb.h>
#include <linux/input.h>

#include "lua.h"
#include "lauxlib.h"

#include "ui.h"


struct window_fb {
	cairo_surface_t *surface;

	int fb_fd;
	unsigned char *fb_data;
	long fb_screensize;
	struct fb_var_screeninfo fb_vinfo;

	int ev_fd;
};


int ui_get_backend(lua_State *L)
{
	lua_pushstring(L, "fb");
	return 1;
}


int ui_create_window(lua_State *L)
{
	struct window_fb *window =
		lua_newuserdata(L, sizeof(struct window_fb));

	/* open the file for reading and writing */
	window->fb_fd = open("/dev/fb0", O_RDWR);
	if (window->fb_fd == -1) {
		perror("Error: cannot open framebuffer device");
		exit(1);
	}

	/* get variable screen information */
	if (ioctl(window->fb_fd, FBIOGET_VSCREENINFO, &window->fb_vinfo) == -1) {
		perror("Error reading variable information");
		exit(3);
	}

	/* figure out the size of the screen in bytes */
	window->fb_screensize = window->fb_vinfo.xres * window->fb_vinfo.yres
		* window->fb_vinfo.bits_per_pixel / 8;

	/* map the device to memory */
	window->fb_data = mmap(0, window->fb_screensize,
			       PROT_READ | PROT_WRITE, MAP_SHARED,
			       window->fb_fd, 0);
	if (window->fb_data == (unsigned char *)-1) {
		perror("Error: failed to map framebuffer device to memory");
		exit(4);
	}

	/* clear screen */
	memset(window->fb_data, 0x010101, window->fb_screensize);

	window->surface = cairo_image_surface_create_for_data(window->fb_data,
	              CAIRO_FORMAT_RGB16_565,
	              window->fb_vinfo.xres,
	              window->fb_vinfo.yres,
		      cairo_format_stride_for_width(CAIRO_FORMAT_RGB16_565,
						    window->fb_vinfo.xres));

	window->ev_fd = open("/dev/input/event1", O_RDWR);
	if (window->ev_fd == -1) {
		perror("Error: cannot open keyboard");
		exit(1);
	}

	luaL_getmetatable(L, "ui.window");
	lua_setmetatable(L, -2);

	return 1;
}


int ui_destroy_window(lua_State *L)
{
	struct window_fb *window = lua_touserdata(L, 1);

	munmap(window->fb_data, window->fb_screensize);
	close(window->fb_fd);

	close(window->ev_fd);

	return 0;
}


int ui_next_event(lua_State *L)
{
	struct window_fb *window = lua_touserdata(L, 1);

	while (1) {
		int rd;
		struct input_event ev;

		rd = read(window->ev_fd, &ev, sizeof(struct input_event));

		// FIXME error checking on rd

		if (ev.type == EV_KEY && ev.value < 2) {
			lua_newtable(L);

			lua_pushstring(L, (ev.value == 1) ? "keypress" : "keyrelease");
			lua_setfield(L, -2, "type");

			lua_pushnumber(L, ev.code);
			lua_setfield(L, -2, "value");

			return 1;
		}
	}
}
