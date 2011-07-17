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

module(..., package.seeall)

local Tab = require("input.tab")

Textinput = {}

function Textinput:new(sheet, title, func, value, pattern)
	obj = {
		sheet = sheet,
		title = title,
		value = value,
		pattern = pattern,
		func = func,
	}

	setmetatable(obj, self)
	self.__index = self

	return obj
end


function Textinput:draw(context, width, height)
	Tab:draw(context, width, height, self.title)

	local x, y, w, h = context:clipExtents()

	local fe = context:fontExtents()

	context:setSourceRGB(255, 255, 255)

	context:rectangle(x + 6, y + 3, w - 12, fe.height + 6)
	context:stroke()

	context:moveTo(x + 12, y + 6 + fe.height - fe.descent)
	context:showText(self.value)
end


function Textinput:event(event)
	if event.type == "keypress" then
		if event.key == "<move_left>" then
			return false

		elseif event.key == "<move_right>" or
			event.key == "=" then

			if string.match(self.value, self.pattern) then
				return self.func(self.sheet, self.value)
			end

		elseif event.key == "<delete>" then
			self.value = string.sub(self.value, 1, #self.value - 1)

		else
			local value = self.value .. event.key

			if string.match(value, self.pattern) then
				self.value = value
			end
		end
	end
end


return Textinput
