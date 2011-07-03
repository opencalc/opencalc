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


Basic = {}


local function drawSpace(self, height)
	self.x = self.x - height
end


local function drawSeparator(self)
	self.context:moveTo(0, self.x)
	self.context:lineTo(self.width, self.x)
	self.context:setLineWidth(1)
	self.context:setDash(1, 4)
	self.context:stroke()

	self.x = self.x - 1
end


-- TODO handle text wider than width
local function drawText(self, justify, size, text)
	self.context:selectFontSize(size)
	local te = self.context:textExtents(text)

	if justify == "right" and te.width < self.width then
		self.context:moveTo(self.width - te.width, self.x)
	else
		self.context:moveTo(0, self.x)
	end

	self.context:showText(text)

	self.x = self.x - math.max(te.height, size)
end


function Basic:new(sheet, context, width, height)
	obj = {
		sheet = sheet,
		context = context,
		width = width,
		height = height,
		textinput = {}
	}

	setmetatable(obj, self)
	self.__index = self
	return obj
end


function Basic:draw()
	self.context:setSourceRGB(0, 0, 0)
	self.context:rectangle(0, 0, self.width, self.height)
	self.context:fill()

	self.context:setSourceRGB(1, 1, 1)
	self.context:selectFontFace("Georgia")

	self.x = self.height

	drawText(self, "left", 14, table.concat(self.textinput))
	drawSpace(self, 4)

	drawSeparator(self)
	drawSpace(self, 4)

	local addr = self.sheet:cellRel(self.sheet:getCursor(), 0, -1)
	local range = self.sheet:rangeRel(addr, 0, -8)

	for cell in self.sheet:getCellRangeByCol(range) do
		if cell then
			drawText(self, "right", 14, cell:value())
			drawSpace(self, 2)
			drawText(self, "left", 10, cell:text())
			drawSpace(self, 4)
		else
			drawText(self, "right", 14, "-")
			drawSpace(self, 2)
			drawText(self, "left", 10, " ")
			drawSpace(self, 4)
		end
	end
end


local function moveCursor(self, relrow, relcol)
	self.sheet:setCursor(relrow, relcol)

	local cell = self.sheet:getCell()

	self.textinput = { }

	if cell then
		for c in string.gmatch(cell:text(), ".") do
			table.insert(self.textinput, c)
		end

		-- remove equals
		table.remove(self.textinput)
	end
end


function Basic:event(event)

	if event.type == "keypress" then
		if event.key == "<delete>" then
			table.remove(self.textinput)

		elseif event.key == "<move_left>" then
			moveCursor(self, -1, 0)

		elseif event.key == "<move_right>" then
			moveCursor(self, 1, 0)

		elseif event.key == "<move_up>" then
			moveCursor(self, 0, -1)

		elseif event.key == "<move_down>" then
			moveCursor(self, 0, 1)

		else
			table.insert(self.textinput, event.key)

			if event.key == "=" then
				if (#self.textinput == 1) then
					self.sheet:recalculate()
				else
					self.sheet:insertCell(table.concat(self.textinput))
				end

				moveCursor(self, 0, 0)
			end
		end
	end

end


return Basic
