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

Basic = {}

local DEF_FORMAT = "Fix"
local DEF_FONT_SIZE = 10


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


function Basic:new(sheet, id)
	obj = {
		id = id,
		sheet = sheet,
		textinput = {}
	}

	setmetatable(obj, self)
	self.__index = self
	return obj
end


function Basic:propMenu()
	return {
		{ "View", self.id .. ".name", "[A-Za-z0-9() ]+" },
		{ "Size", self.id .. ".font_size", { 8, 10, 12, 14 }, def = DEF_FONT_SIZE },
		{ "Format", self.id .. ".base", { "Fix", "Sci", "Dec", "Hex", "Oct" }, def = DEF_FORMAT },
	}
end


function Basic:draw(context, width, height)
	self.context = context
	self.width = width
	self.height = height

	self.context:save()

	self.context:setSourceRGB(0, 0, 0)
	self.context:rectangle(0, 0, self.width, self.height)
	self.context:fill()

	self.context:setSourceRGB(1, 1, 1)

	self.x = self.height

	local font_size = self.sheet:getProp(self.id .. ".font_size", DEF_FONT_SIZE)
	local base = self.sheet:getProp(self.id .. ".base", DEF_BASE)

	local format = "= %0.4Rf"
	if base == "Sci" then
		format = "= %0.4Re"
	elseif base == "Hex" then
		format = "= 0x%x"
	elseif base == "Oct" then
		format = "= 0%o"
	end

	drawText(self, "left", font_size + 4, table.concat(self.textinput))
	drawSpace(self, 4)

	drawSeparator(self)
	drawSpace(self, 4)

	local addr = self.sheet:cellRel(self.sheet:getCursor(), 0, -1)
	local range = self.sheet:rangeRel(addr, 0, -8)

	for cell in self.sheet:getCellRangeByCol(range) do
		if cell then
			local val = cell:value()
			if type(val) == "userdata" then
				val = mp.format(format, val)
			end

			drawText(self, "right", font_size + 4, val)
			drawSpace(self, 2)
			drawText(self, "left", font_size, cell:text())
			drawSpace(self, 4)
		else
			drawText(self, "right", font_size + 4, "-")
			drawSpace(self, 2)
			drawText(self, "left", font_size, " ")
			drawSpace(self, 4)
		end
	end

	self.context:restore()
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

		elseif event.key == "<left>" then
			moveCursor(self, -1, 0)

		elseif event.key == "<right>" then
			moveCursor(self, 1, 0)

		elseif event.key == "<up>" then
			moveCursor(self, 0, -1)

		elseif event.key == "<down>" then
			moveCursor(self, 0, 1)

		else
			if event.key == "<enter>" then
				if (#self.textinput == 0) then
					self.sheet:recalculate()
				else
					self.sheet:insertCell(table.concat(self.textinput))
				end

				moveCursor(self, 0, 0)
			else
				table.insert(self.textinput, event.key)
			end
		end
	end

end


return Basic
