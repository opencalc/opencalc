#!/usr/local/bin/lua

--[[
opencalc - an open source calcualtor

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


local ui = require("ui")

local Sheet = require("sheet")


local WINDOW_WIDTH, WINDOW_HEIGHT = 160, 160
local WINDOW_BORDER = 10
local WINDOW_SCALE = 1.5


local sheet = Sheet:new()


	-- TODO delete this code, it's for testing
	for i = 1,10 do
		sheet:insertCell(i-1, "A"..i)
		sheet:insertCell("(A"..i.."^2)-6=", "B"..i)
	end
	sheet:addView("view/line")
	sheet:setCursor("B11")


local backend = ui.getBackend()

local window = ui.createWindow(
      (WINDOW_WIDTH + WINDOW_BORDER) * WINDOW_SCALE,
      (WINDOW_HEIGHT + WINDOW_BORDER) * WINDOW_SCALE)

local context = window:getContext()

if backend ~= "fb" then
	context:translate(WINDOW_BORDER, WINDOW_BORDER)
	context:scale(WINDOW_SCALE, WINDOW_SCALE)
end

context:rectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
context:clip()


-- keymap
local keymap = require("keymap." .. backend)

-- key modifier state (eg shift, abc, sym)
local keymod = 1


-- view
local viewtype, view


while (true) do
	if viewtype ~= sheet:nextView(0) then
		viewtype = sheet:nextView(0)

		local mod = require(viewtype)
		view = mod:new(sheet, context, WINDOW_WIDTH, WINDOW_HEIGHT)
	end

	view:draw()

	local event = window:nextEvent()

	if event.type == "keypress" then
		event.key = event.value
		if keymap[event.value] then
			event.key = keymap[event.value][keymod]
		end

print("value=", event.value .. " " .. tostring(event.key))

		-- handle global keys here
		if event.key == "<shift>" then
			keymod = 2

		elseif event.key == "<view>" then
			sheet:nextView()

		elseif event.key then
			view:event(event)
		end

	elseif event.type == "keyrelease" then
		local key = event.value
		if keymap[event.value] then
			key = keymap[event.value][keymod]
		end

		if key == "<shift>" then
			keymod = 1

		elseif event.key then
			view:event(event)
		end
	end
end
