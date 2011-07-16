
#include <alloca.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"

#include "ui.h"


static int ui_save(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_save(c->cr);
	return 0;
}

static int ui_restore(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_restore(c->cr);
	return 0;
}

static int ui_get_current_point(lua_State *L)
{
	double x, y;

	struct context *c = lua_touserdata(L, 1);

	cairo_get_current_point(c->cr, &x, &y);

	lua_pushnumber(L, x);
	lua_pushnumber(L, y);

	return 2;
}

static int ui_move_to(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_move_to(c->cr,
		      lua_tonumber(L, 2),
		      lua_tonumber(L, 3));
	return 0;
}

static int ui_rel_move_to(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_rel_move_to(c->cr,
			  lua_tonumber(L, 2),
			  lua_tonumber(L, 3));
	return 0;
}

static int ui_translate(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_translate(c->cr,
			lua_tonumber(L, 2),
			lua_tonumber(L, 3));
	return 0;
}

static int ui_scale(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_scale(c->cr,
		    lua_tonumber(L, 2),
		    lua_tonumber(L, 3));
	return 0;
}

static int ui_line_to(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_line_to(c->cr,
		      lua_tonumber(L, 2),
		      lua_tonumber(L, 3));
	return 0;
}

static int ui_rel_line_to(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_rel_line_to(c->cr,
			  lua_tonumber(L, 2),
			  lua_tonumber(L, 3));
	return 0;
}

static int ui_rectangle(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_rectangle(c->cr,
		      lua_tonumber(L, 2),
		      lua_tonumber(L, 3),
		      lua_tonumber(L, 4),
		      lua_tonumber(L, 5));
	return 0;
}

static int ui_clip(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_clip(c->cr);
	return 0;
}

static int ui_clip_extents(lua_State *L)
{
	double x, y, w, h;

	struct context *c = lua_touserdata(L, 1);

	cairo_clip_extents(c->cr, &x, &y, &w, &h);

	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	lua_pushnumber(L, w);
	lua_pushnumber(L, h);
	return 4;
}

static int ui_stroke(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_stroke(c->cr);
	return 0;

}

static int ui_fill(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_fill(c->cr);
	return 0;

}

static int ui_set_line_width(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_set_line_width(c->cr, lua_tonumber(L, 2));
	return 0;

}

static int ui_set_dash(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	// TODO expand api
	if (lua_tonumber(L, 2)) {
		double dashes[2] = { lua_tonumber(L, 2), lua_tonumber(L, 2) }; 
		cairo_set_dash(c->cr, dashes, 2, 0);
	}
	else {
		cairo_set_dash(c->cr, NULL, 0, 0);
	}
	return 0;
}



static int ui_set_source_rgb(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_set_source_rgb(c->cr,
			     lua_tonumber(L, 2),
			     lua_tonumber(L, 3),
			     lua_tonumber(L, 4));

	return 0;
}

static int ui_set_source_surface(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	struct window *w = lua_touserdata(L, 2);

	cairo_set_source_surface(c->cr, w->surface, 0, 0);

	return 0;
}

static int ui_select_font_face(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	const char *face = lua_tostring(L, 2);
	int slant = luaL_optint(L, 3, 0);

	cairo_select_font_face(c->cr, face,
			       (slant) ? CAIRO_FONT_SLANT_ITALIC : CAIRO_FONT_SLANT_NORMAL,
			       CAIRO_FONT_WEIGHT_BOLD);

	return  0;
}

static int ui_select_font_size(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);

	cairo_set_font_size(c->cr, lua_tonumber(L, 2));

	return 0;
}

static int ui_font_extents(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	const char *str = lua_tostring(L, 2);

	cairo_font_extents_t te;
	cairo_font_extents(c->cr, &te);

	lua_newtable(L);

	lua_pushnumber(L, te.ascent);
	lua_setfield(L, -2, "ascent");

	lua_pushnumber(L, te.descent);
	lua_setfield(L, -2, "descent");

	lua_pushnumber(L, te.height);
	lua_setfield(L, -2, "height");

	lua_pushnumber(L, te.max_x_advance);
	lua_setfield(L, -2, "max_x_advance");

	lua_pushnumber(L, te.max_y_advance);
	lua_setfield(L, -2, "max_y_advance");

	return 1;
}

static int ui_text_extents(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	const char *str = lua_tostring(L, 2);	

	cairo_text_extents_t te;
	cairo_text_extents (c->cr, str, &te);

	lua_newtable(L);

	lua_pushnumber(L, te.x_bearing);
	lua_setfield(L, -2, "x_bearing");

	lua_pushnumber(L, te.y_bearing);
	lua_setfield(L, -2, "y_bearing");

	lua_pushnumber(L, te.width);
	lua_setfield(L, -2, "width");

	lua_pushnumber(L, te.height);
	lua_setfield(L, -2, "height");

	lua_pushnumber(L, te.x_advance);
	lua_setfield(L, -2, "x_advance");

	lua_pushnumber(L, te.y_advance);
	lua_setfield(L, -2, "y_advance");	

	return 1;
}

static int ui_show_text(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	const char *str = lua_tostring(L, 2);	

	cairo_show_text(c->cr, str);

	return 0;
}

static int ui_show_underlined_text(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	const char *str = lua_tostring(L, 2);	

	if (!str) {
		return 0;
	}

	char *tmp = alloca(strlen(str)+1);

	double x1, y1;
	cairo_get_current_point(c->cr, &x1, &y1);

	cairo_show_text(c->cr, str);

	double x2, y2;
	cairo_get_current_point(c->cr, &x2, &y2);

	if (lua_isnil(L, 3)) {
		/* underline full string */
		cairo_move_to(c->cr, x1, y1);
		cairo_line_to(c->cr, x2, y2);
		cairo_stroke(c->cr);
		return 0;
	}

	/* underline pattern */
	lua_getfield(L, LUA_GLOBALSINDEX, "string");
	lua_getfield(L, -1, "find");

	lua_pushvalue(L, -1); /* string.find */
	lua_pushvalue(L, 2); /* str */
	lua_pushvalue(L, 3); /* pattern */
	lua_call(L, 2, 2);

	while (!lua_isnil(L, -2)) {
		int start = lua_tointeger(L, -2);
		int end = lua_tointeger(L, -1);

		cairo_text_extents_t te1;
		memcpy(tmp, str, start-1);
		tmp[start-1] = 0;
		cairo_text_extents(c->cr, tmp, &te1);

		cairo_text_extents_t te2;
		memcpy(tmp, str+start-1, end-start+1);
		tmp[end-start+1] = 0;
		cairo_text_extents(c->cr, tmp, &te2);

		cairo_move_to(c->cr, x1 + te1.x_advance, y1 + 1);
		cairo_rel_line_to(c->cr, te2.x_advance, 0);
		cairo_stroke(c->cr);

		lua_pop(L, 2);

		lua_pushvalue(L, -1); /* string.find */
		lua_pushvalue(L, 2); /* str */
		lua_pushvalue(L, 3); /* pattern */
		lua_pushinteger(L, end + 1); /* init */
		lua_call(L, 3, 2);
	}

	cairo_move_to(c->cr, x2, y2);
	return 0;
}

static int ui_set_antialias(lua_State *L)
{
	struct context *c = lua_touserdata(L, 1);
	int enable = lua_toboolean(L, 2);

	cairo_antialias_t antialias = (enable) ?
		CAIRO_ANTIALIAS_DEFAULT : CAIRO_ANTIALIAS_NONE;

	cairo_set_antialias(c->cr, antialias);

	cairo_font_options_t *options;
	options = cairo_font_options_create();
	cairo_font_options_set_antialias(options, antialias);
	cairo_set_font_options(c->cr, options);

	return 0;
}

static int ui_get_context(lua_State *L)
{
	struct window *w = lua_touserdata(L, 1);

	struct context *c = lua_newuserdata(L, sizeof(struct context));
	c->cr = cairo_create(w->surface);

	luaL_getmetatable(L, "ui.context");
	lua_setmetatable(L, -2);

	return 1;
}


static int ui_create_from_png(lua_State *L)
{
	struct window *window =
		lua_newuserdata(L, sizeof(struct window));

	window->surface =
		cairo_image_surface_create_from_png(lua_tostring(L, 1));

	luaL_getmetatable(L, "ui.image");
	lua_setmetatable(L, -2);

	return 1;
}


static int ui_create_image(lua_State *L)
{
	struct window *window =
		lua_newuserdata(L, sizeof(struct window));

	window->surface =
		// FIXME using 565 makes unit tests fail
		//cairo_image_surface_create(CAIRO_FORMAT_RGB16_565,
		cairo_image_surface_create(CAIRO_FORMAT_ARGB32,
					   lua_tonumber(L, 1),
					   lua_tonumber(L, 2));

	luaL_getmetatable(L, "ui.image");
	lua_setmetatable(L, -2);

	return 1;
}


static int ui_destroy_image(lua_State *L)
{
	struct window *window = lua_touserdata(L, 1);

	cairo_surface_destroy(window->surface);
	return 0;
}


static int ui_writepng_image(lua_State *L)
{
	struct window *window = lua_touserdata(L, 1);

	cairo_surface_write_to_png(window->surface,
				   lua_tostring(L, 2));

	return 0;
}


static int ui_equal_image(lua_State *L)
{
	struct window *op1 = lua_touserdata(L, 1);
	struct window *op2 = lua_touserdata(L, 2);

	/* note: assumes images are same format */

	int len = cairo_image_surface_get_stride(op1->surface)
		* cairo_image_surface_get_height(op1->surface);

	if (len != cairo_image_surface_get_stride(op2->surface)
	    * cairo_image_surface_get_height(op2->surface)) {
		lua_pushboolean(L, 0);
		return 1;
	}

	unsigned char *d1 = cairo_image_surface_get_data(op1->surface);
	unsigned char *d2 = cairo_image_surface_get_data(op2->surface);

	lua_pushboolean(L, memcmp(d1, d2, len) == 0);
	return 1;
}


static const struct luaL_Reg context_m[] = {
	{ "save", ui_save },
	{ "restore", ui_restore },
	{ "translate", ui_translate },
	{ "scale", ui_scale },
	{ "getCurrentPoint", ui_get_current_point },
	{ "moveTo", ui_move_to },
	{ "lineTo", ui_line_to },
	{ "relMoveTo", ui_rel_move_to },
	{ "relLineTo", ui_rel_line_to },
	{ "rectangle", ui_rectangle },
	{ "clip", ui_clip },
	{ "clipExtents", ui_clip_extents },
	{ "stroke", ui_stroke },
	{ "fill", ui_fill },
	{ "setLineWidth", ui_set_line_width },
	{ "setDash", ui_set_dash },
	{ "setSourceRGB", ui_set_source_rgb },
	{ "setSourceSurface", ui_set_source_surface },
	{ "selectFontFace", ui_select_font_face },
	{ "selectFontSize", ui_select_font_size },
	{ "showText", ui_show_text },
	{ "showUnderlinedText", ui_show_underlined_text },
	{ "fontExtents", ui_font_extents },
	{ "textExtents", ui_text_extents },
	{ "setAntialias", ui_set_antialias },
	{ NULL, NULL }
};

static const struct luaL_Reg window_m[] = {
	{ "__gc", ui_destroy_window },
	{ "getContext", ui_get_context },
	{ "nextEvent", ui_next_event },
	{ NULL, NULL }
};

static const struct luaL_Reg image_m[] = {
	{ "__gc", ui_destroy_image },
	{ "__eq", ui_equal_image },
	{ "getContext", ui_get_context },
	{ "writePng", ui_writepng_image },
	{ NULL, NULL }
};

static const struct luaL_Reg ui[] = {
	{ "getBackend", ui_get_backend },
	{ "createFromPng", ui_create_from_png },
	{ "createImage", ui_create_image },
	{ "createWindow", ui_create_window },
	{ NULL, NULL }
};


int luaopen_ui(lua_State *L)
{
	luaL_newmetatable(L, "ui.context");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, context_m);

	luaL_newmetatable(L, "ui.window");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, window_m);

	luaL_newmetatable(L, "ui.image");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	luaL_register(L, NULL, image_m);

	luaL_register(L, "ui", ui);
	return 1;
}
