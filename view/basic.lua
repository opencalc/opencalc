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
local DEF_SHOW_GRID = "On"
local DEF_SHOW_FORMULA = "On"
local DEF_COLUMNS = 2


local function drawText(self, width, height, justify, size, text)
	self.context:selectFontSize(size)
	local te = self.context:textExtents(text)

	if justify == "right" and te.x_advance < width then
		self.context:relMoveTo(width - te.x_advance, 0)
	end

	self.context:showText(text)
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
		{ "Grid", self.id .. ".show_grid", { "On", "Off" }, def = DEF_SHOW_GRID },
		{ "Formula", self.id .. ".show_formula", { "On", "Off" }, def = DEF_SHOW_FORMULA },
		{ "Columns", self.id .. ".columns", { 1, 2, 3 }, def = DEF_COLUMNS },
		{ "Format", self.id .. ".base", { "Fix", "Sci", "Dec", "Hex", "Oct" }, def = DEF_FORMAT },
	}
end


function Basic:draw(context, width, height)
	self.context = context

	context:save()

	context:setSourceRGB(0, 0, 0)
	context:rectangle(0, 0, width, height)
	context:fill()

	context:setSourceRGB(1, 1, 1)

	local font_size = self.sheet:getProp(self.id .. ".font_size", DEF_FONT_SIZE)
	local base = self.sheet:getProp(self.id .. ".base", DEF_BASE)
	local columns = self.sheet:getProp(self.id .. ".columns", DEF_COLUMNS)
	local show_formula = self.sheet:getProp(self.id .. ".show_formula", DEF_SHOW_FORMULA) == "On"
	local show_grid = self.sheet:getProp(self.id .. ".show_grid", DEF_SHOW_GRID) == "On"
	local top_addr = self.sheet:getProp(self.id .. ".top_addr", "A1")

	local format = "%0.4Rf"
	if base == "Sci" then
		format = "%0.4Re"
	elseif base == "Hex" then
		format = "0x%x"
	elseif base == "Oct" then
		format = "0%o"
	end

	local padding = 2

	grid_font_size = 8
	context:selectFontSize(grid_font_size)
	local feg = context:fontExtents()

	context:selectFontSize(font_size)
	local fe0 = context:fontExtents()

	context:selectFontSize(font_size + 4)
	local fe4 = context:fontExtents()

	local addr_height = 0
	local addr_width = 0

	if show_grid then
		context:selectFontSize(grid_font_size)
		local te = context:textExtents("100")

		addr_height = feg.height
		addr_width = te.width + padding
	end

	local input_height = fe4.height + padding

	local cell_height = fe4.height + padding * 2
	if show_formula then
		cell_height = cell_height + fe0.height
	end

	local cell_width = (width - addr_width) / columns
	local rows = math.floor((height - addr_height - input_height) / cell_height)

	-- do not have fractional rows 
	cell_height = (height - addr_height - input_height) / rows

	local top_col, top_row = self.sheet:cellIndex(top_addr)
	local cur_col, cur_row = self.sheet:cellIndex(self.sheet:getCursor())

	-- cursor range
	if cur_col >= top_col + columns then
		top_col = top_col + (cur_col - top_col - columns + 1)
	end
	if cur_col < top_col then
		top_col = top_col - (top_col - cur_col)
	end

	if cur_row >= top_row + rows then
		top_row = top_row + (cur_row - top_row - rows + 1)
	end
	if cur_row < top_row then
		top_row = top_row - (top_row - cur_row)
	end

	self.sheet:setProp(self.id .. ".top_addr", self.sheet:cellAddr(top_col, top_row))

	-- input
	context:moveTo(0, height - fe4.descent)
	drawText(self, width, input_height, "left", font_size + 4, table.concat(self.textinput))

	-- separator
	context:setLineWidth(1)
	context:setDash(1, 4)

	context:moveTo(0, height - input_height)
	context:relLineTo(width, 0)
	context:stroke()

	context:rectangle(0, 0, width, height - input_height)
	context:clip()

	-- draw grid
	if show_grid then
		context:selectFontSize(grid_font_size)
		context:setLineWidth(1)
		context:setDash(2, 2)

		for col = 0,columns-1 do
			context:moveTo(addr_width + cell_width * col, 0)
			context:lineTo(addr_width + cell_width * col, height - input_height)
			context:stroke()

			context:moveTo(addr_width + cell_width * col + cell_width / 2, feg.ascent)
			context:showText(self.sheet:rowAddr(top_col + col))
		end

		for row = 0,rows do
			context:moveTo(0, addr_height + cell_height * row)
			context:lineTo(width, addr_height + cell_height * row )
			context:stroke()

			context:moveTo(0, addr_height + cell_height * row + cell_height / 2 + feg.descent)
			context:showText(self.sheet:colAddr(top_row + row))
		end

		-- draw cursor
		context:setLineWidth(1)
		context:setDash()

		context:moveTo(addr_width + cell_width * (cur_col-top_col), addr_height + cell_height * (cur_row-top_row))
		context:relLineTo(0, cell_height)
		context:relLineTo(cell_width, 0)
		context:relLineTo(0, -cell_height)
		context:relLineTo(-cell_width, 0)
		context:stroke()
	end

	for col = 0,columns-1 do
		for row = 0,rows do repeat
			local cell = self.sheet:getCell(self.sheet:cellAddr(top_col+col, top_row+row))
			if not cell then
				break -- continue
			end

			local val, approx = cell:value()
			if type(val) == "userdata" then
				val = mp.format(format, val)
			end

			local equalsym = approx and "\226\137\131" or "="

			local cell_x = addr_width + (cell_width * col) + padding
			local cell_y = addr_height + (cell_height * row) + padding

			if show_formula then
				cell_y = cell_y + fe0.height
				context:moveTo(cell_x, cell_y - fe0.descent)
				drawText(self, cell_width - padding * 2, cell_height - padding * 2, "left", font_size, cell:text() .. equalsym)
			end

			cell_y = cell_y + fe4.height
			context:moveTo(cell_x, cell_y - fe4.descent)
			drawText(self, cell_width - padding * 2, cell_height - padding * 2, "right", font_size + 4, val)
		until true end
	end

	context:restore()
end


local function moveCursor(self, relrow, relcol)
	self.sheet:setCursor(relrow, relcol)

	local cell = self.sheet:getCell()

	self.textinput = { }

	if cell then
		for c in string.gmatch(cell:text(), ".") do
			table.insert(self.textinput, c)
		end
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

		elseif event.key == "<clear>" then
			self.sheet:clearCell()
			moveCursor(self, 0, 0)

		elseif event.key == "<enter>" then
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


return Basic
