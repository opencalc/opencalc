#!/usr/local/bin/lua

--[[
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
--]]


require("builtin-menu")
require("builtin-functions")
require("builtin-units")

local ui = require("ui")

local Sheet = require("sheet")
local Menu = require("input.menu")

local FONT_FACE = "DejaVuSansMono"

local WINDOW_WIDTH, WINDOW_HEIGHT = 240, 160
local WINDOW_BORDER = 10
local WINDOW_SCALE = 2


local sheet = Sheet:new()

if arg[1] then
	sheet:load(arg[1])
end


local global_menus = {
	["<file>"] = Menu.fileMenu,
	["<function>"] = Menu.functionMenu,
	["<edit>"] = Menu.editMenu,
	["<apps>"] = function(sheet)
		return sheet:viewMenu()
	end,
	["<unit>"] = Menu.unitMenu,
	["<setting>"] = function(sheet)
		return sheet:propMenu()
	end,
}


local backend = ui.getBackend()

local window = ui.createWindow(
      (WINDOW_WIDTH + WINDOW_BORDER) * WINDOW_SCALE,
      (WINDOW_HEIGHT + WINDOW_BORDER) * WINDOW_SCALE)

local context = window:getContext()

local window_image = false
local window_context = false
if backend ~= "fb" then
	window_context = context
	window_context:translate(WINDOW_BORDER, WINDOW_BORDER)
	window_context:scale(WINDOW_SCALE, WINDOW_SCALE)

	window_image = ui.createImage(WINDOW_WIDTH, WINDOW_HEIGHT)
	context = window_image:getContext()
end

context:selectFontFace(FONT_FACE)
context:setAntialias(false)
context:rectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
context:clip()

-- keymap
local keymap = require("keymap." .. backend)

-- key modifier state (eg shift, alpha)
local keymod = 1
local keyprefix = ""


-- view
local view, menu_open
local menu = { }

while (true) do
	view = sheet:getView()

	context:save()
	view:draw(context, WINDOW_WIDTH, WINDOW_HEIGHT)
	context:restore()

	if #menu > 0 then
		context:save()
		menu[1]:draw(context, WINDOW_WIDTH, WINDOW_HEIGHT)
		context:restore()
	end

	if window_context then
		-- upscale for emulator
		window_context:setSourceSurface(window_image, true)
		window_context:rectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
		window_context:fill()
	end

	local event = window:nextEvent()

	if event.type == "keypress" then
		event.key = event.value
		local index = keyprefix .. event.value
		if keymap[index] then
			event.key = keymap[index][keymod]
			event.alpha = keymap[index][keymod == 1 and 3 or 4]
		end

print("value=", index .. " " .. tostring(event.key))

		-- handle global keys here
		if event.key == "<shift>" then
			keymod = keymod + 1

		elseif event.key == "<alpha>" then
			keymod = keymod + 2

		elseif event.key == "Alt_L" or event.key =="Alt_R" then
			keyprefix = "alt-"
			
		elseif global_menus[event.key] then
			local items = global_menus[event.key]
			if type(items) == "function" then
				items = items(sheet)
			end
			if items and (#menu == 0 or menu_open ~= event.key) then
				menu = { Menu:new(sheet, items) }
				menu_open = event.key
			else
				menu = { }
			end

		elseif event.key then
			local submenu = (menu[1] or view):event(event)

			if type(submenu) == "table" then
				table.insert(menu, 1, submenu)

			elseif submenu == false then
				table.remove(menu, 1)

			elseif submenu == true then
				menu = { }
			end
		end

	elseif event.type == "keyrelease" then
		local key = event.value
		local index = keyprefix .. event.value
		if keymap[index] then
			key = keymap[index][keymod]
		end
		
		if key == "<shift>" then
			keymod = keymod - 1

		elseif key == "<alpha>" then
			keymod = keymod - 2

		elseif event.value == "Alt_L" or event.value =="Alt_R" then
			keyprefix = ""

		elseif event.key then
			(menu[1] or view):event(event)
		end
	end
end
