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

module(..., package.seeall)


Line = {}

local DEF_RANGE = "A1:B10"


function Line:new(sheet, id)
	obj = {
		sheet = sheet,
		id = id
	}

	setmetatable(obj, self)
	self.__index = self
	return obj
end


function Line:propMenu()
	return {
		{ "Range", self.id .. ".range", "string", def = DEF_RANGE, todo = true },
	}
end


function Line:draw(context, width, height)
	context:setSourceRGB(0, 0, 0)
	context:rectangle(0, 0, width, height)
	context:fill()

	context:setSourceRGB(1, 1, 1)


	-- todo detect range, or use settings
	local minx, maxx = -1, 11
	local miny, maxy = -10, 100

	local totx = maxx - minx
	local toty = maxy - miny

	local mulx = width / totx
	local muly = height / toty


	-- axes
	-- todo co-ordinates?
	context:setDash(1, 4)

	context:moveTo(0, height - (-miny * muly))
	context:lineTo(width, height - (-miny * muly))
	context:stroke()

	context:moveTo(-minx * mulx, 0)
	context:lineTo(-minx * mulx, height)
	context:stroke()

	context:setDash()

	-- line
	local range = self.sheet:getProp(self.id .. ".range", DEF_RANGE)

	local i = self.sheet:getCellRangeByRow("A1:B10")

	context:moveTo(
		(i():value():tonumber() - minx) * mulx,
		height - (i():value():tonumber() - miny) * muly)

	local cell = i()
	while cell do
		context:lineTo(
			(cell:value():tonumber() - minx) * mulx,
			height - ((i():value():tonumber() - miny) * muly))

		cell = i()
	end

	context:stroke()
end


function Line:event(event)

	if event.type == "keypress" then
		if event.key == "=" then
			self.sheet:recalculate()
		end
	end

end


return Line
