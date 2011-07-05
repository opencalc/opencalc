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


Menu = {}

local MARGIN = 14
local BORDER = 18
local FONT_SIZE = 14


-- global menus

Menu.functionMenu = { }
Menu.appMenu = {
	{ "Line Graph", todo = true },
	{ "Pie Chart", todo = true },
	{ "About", todo = true },
}
Menu.fileMenu = {
	{ "New", todo = true },
	{ "Delete", todo = true },
	{ "Open", todo = true },
	{ "Save", todo = true },
	{ "Print", todo = true },
}
Menu.editMenu = {
	{ "Bold", todo = true },
	{ "Delete Row", todo = true },
	{ "Delete Column", todo = true },
	{ "Format", todo = true },
	{ "Insert Row", todo = true },
	{ "Insert Column", todo = true },
	{ "Protect Cell", "protect", { "Lock", "Unlock" }, def = "Lock", todo = true },
	{ "Name", todo = true },
}


--[[

item[1] is the name
item[2] is the value:
	table: submenu
	string: sheet pref, item.def is default value
	function: get/set function
item[3] is the value type:
	table: string selection
	number: range is in item.min, item.max
	cell: sheet cell [TODO]
	range: sheet range [TODO]
	function: custom input

--]]


function Menu:new(sheet, items)
	obj =  {
		sheet = sheet,
		items = items,
	}

	obj.menu = { obj.items }
	obj.menu[1].selected = 1

	setmetatable(obj, self)
	self.__index = self
	return obj
end


function Menu:draw(context, width, height)
	context:save()

	context:setSourceRGB(0, 0, 0)
	context:rectangle(MARGIN, MARGIN,
		width - MARGIN * 2, height - MARGIN * 2)
	context:fill()

	context:setSourceRGB(255, 255, 255)
	context:rectangle(MARGIN, MARGIN,
		width - MARGIN * 2, height - MARGIN * 2)
	context:setLineWidth(1)
	context:stroke()

	context:selectFontFace("Georgia")
	context:selectFontSize(FONT_SIZE)
	local fe = context:fontExtents()

	local y = MARGIN + fe.height - fe.descent
	local x = BORDER

	local items = self.menu[1]

	for i, item in ipairs(items) do
		local name, value = item[1], item[2]

		if item.todo then
			context:selectFontFace("Georgia", 1)
		else
			context:selectFontFace("Georgia")
		end

		context:setSourceRGB(255, 255, 255)

		if items.selected == i then
			context:rectangle(
				MARGIN,
				y - fe.height + fe.descent,
				width - MARGIN * 2,
				fe.height)
			context:fill()

			context:setSourceRGB(0, 0, 0)
		end

		context:moveTo(x, y)
		context:showText(name)

		if type(value) == "table" then
			value = "=>"
		elseif type(value) == "string" then
			value = self.sheet:getProp(value, item.def)
		elseif type(value) == "function" then
			value = value(self.sheet)
		end

		local te = context:textExtents(value)

		context:moveTo(width - BORDER - te.width, y)
		context:showText(value)

		y = y + fe.height
	end

	context:restore()
end


function Menu:event(event)

	local items = self.menu[1]

	if event.type == "keypress" then
		if event.key == "<move_up>" then
			items.selected = items.selected - 1
			if items.selected < 1 then
				items.selected = #items
			end

		elseif event.key == "<move_down>" then
			items.selected = items.selected + 1
			if items.selected > #items then
				items.selected = 1
			end

		elseif event.key == "<move_left>" then
			if #self.menu == 1 then
				return false
			end

			table.remove(self.menu, 1)

		elseif event.key == "<move_right>" or
			event.key == "=" then
			local item = items[items.selected]

			local value = true
			if type(item[3]) == "table" then
				-- select next option
				local last_value = self.sheet:getProp(item[2], item.def)
				local options = item[3]

				value = options[1]
				for i=#options,1,-1 do
					if options[i] == last_value then
						break
					end
					value = options[i]
				end
			end

			if type(item[2]) == "table" then
				-- display sub-menu
				table.insert(self.menu, 1, item[2])
				self.menu[1].selected = 1

			elseif type(item[2]) == "function" then
				-- custom function
				return item[2](self.sheet, value)

			elseif type(item[2]) == "string" then
				self.sheet:setProp(item[2], value)
			end
		end
	end

	return true
end


return Menu
