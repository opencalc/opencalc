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


Line = {}


function Line:new(sheet, context, width, height)
	obj = {
		sheet = sheet,
		context = context,
		width = width,
		height = height,
	}

	setmetatable(obj, self)
	self.__index = self
	return obj
end


function Line:draw()
	self.context:setSourceRGB(0, 0, 0)
	self.context:rectangle(0, 0, self.width, self.height)
	self.context:fill()

	self.context:setSourceRGB(1, 1, 1)


	-- todo detect range, or use settings
	local minx, maxx = -1, 11
	local miny, maxy = -10, 100

	local totx = maxx - minx
	local toty = maxy - miny

	local mulx = self.width / totx
	local muly = self.height / toty


	-- axes
	-- todo co-ordinates?
	self.context:setDash(1, 4)

	self.context:moveTo(0, self.height - (-miny * muly))
	self.context:lineTo(self.width, self.height - (-miny * muly))
	self.context:stroke()

	self.context:moveTo(-minx * mulx, 0)
	self.context:lineTo(-miny * muly, self.width)
	self.context:stroke()

	self.context:setDash()

	-- line
	-- todo use settings for range
	local i = self.sheet:getCellRangeByRow("A1:B10")

	self.context:moveTo(
		(i():value() - minx) * mulx,
		self.height - ((i():value() - miny) * muly))

	local cell = i()
	while cell do
		self.context:lineTo(
			(cell:value() - minx) * mulx,
			self.height - ((i():value() - miny) * muly))

		cell = i()
	end

	self.context:stroke()
end


function Line:event(event)

	if event.type == "keypress" then
		if event.key == "=" then
			self.sheet:recalculate()
		end
	end

end


return Line
