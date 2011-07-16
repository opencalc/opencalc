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
local Textinput = require("input.textinput")

local lfs = require("lfs")

Menu = {}

local PADDING = 5
local FONT_FACE = "courier"
local FONT_SIZE = 14


-- global menus

Menu.functionMenu = {
	title = "Functions",
}
Menu.appMenu = {
	title = "Apps",
	{ "Line Graph", todo = true },
	{ "Pie Chart", todo = true },
	{ "About", todo = true },
}
Menu.fileMenu = {
	title = "File",
	{ "New", todo = true },
	{ "Delete", todo = true },
	{ "Open",
		function(sheet, file)
			print("open " .. tostring(x))
		end,
		function(sheet, item)
			local items = {
				title = "Open",
			}

			for file in lfs.dir(".") do
				if not string.match(file, "%.") then
					table.insert(items, { file })
				end
			end
			table.sort(items, function(a, b)
				return a[1] < b[1]
			end)

			return Menu:new(sheet, items)
		end,
	},
	{ "Save",
		function(sheet, x)
			print("save " .. tostring(x))
			if x ~= nil then return true end
		end, 
		function(sheet, item)
			return Textinput:new(sheet, item[1], item[2], "^[a-zA-Z0-9]+$")
		end,
	},
	{ "Print", todo = true },
}
Menu.editMenu = {
	title = "Edit",
	{ "Bold", todo = true },
	{ "Delete Row", todo = true },
	{ "Delete Column", todo = true },
	{ "Format", todo = true },
	{ "Insert Row", todo = true },
	{ "Insert Column", todo = true },
	{ "Protect Cell", "protect", { "Lock", "Unlock" }, def = "Lock", todo = true },
	{ "Name", todo = true },
	{ "Find", todo = true },
	{ "Find Next", todo = true },

	{ "Submenu", Menu.fileMenu },
}


--[[

item.title is the title
item[1] is the name
item[2] is the value:
	table: submenu
	string: sheet pref, item.def is default value
	function: get/set function
item[3] is the value type:
	table: string selection
	number: range is in item.min, item.max [TODO]
	cell: sheet cell [TODO]
	range: sheet range [TODO]
	function: custom input

--]]


function Menu:new(sheet, items)
	obj =  {
		sheet = sheet,
		title = items.title,
		items = items,
		selected = 1,
		screentop = 1,
		typeahead = "",
	}

	setmetatable(obj, self)
	self.__index = self

	obj.filtered = obj:filterItems(".")

	return obj
end


function Menu:draw(context, width, height)
	Tab:draw(context, width, height, self.title)

	local x, y, w, h = context:clipExtents()

	local items = self.filtered
	local selected = self.selected

	context:save()

	context:selectFontSize(FONT_SIZE)
	local fe = context:fontExtents()

	local visible_items = math.floor(h / fe.height)

	if selected == 1 then
		self.screentop = 1
	elseif selected == #items then
		self.screentop = math.max(1, #items - visible_items + 1)
	elseif selected > self.screentop + visible_items - 2 then
		self.screentop = self.screentop +
			(selected - (self.screentop + visible_items - 2))
	elseif selected < self.screentop + 1 then
		self.screentop = self.screentop -
			(self.screentop - selected + 1)
	end

	-- scroll bar
	local item_width = w
	if #items > visible_items then
		item_width = item_width - 6

		local bar_height = h
		local bar_len = ((visible_items - 1) / #items) * bar_height
		local bar_off = ((self.screentop - 1) / #items) * bar_height

		context:setSourceRGB(255, 255, 255)

		context:moveTo(item_width, y)
		context:relLineTo(0, bar_height)
		context:stroke()

		context:moveTo(item_width + 3, y + 2 + bar_off)
		context:relLineTo(0, bar_len)
		context:setLineWidth(2)
		context:stroke()
	end

	local pattern = "^$"
	if #self.typeahead > 0 then
		pattern = "[" .. self.typeahead .. string.upper(self.typeahead) .. "]+"
	end

	for i = self.screentop, self.screentop + visible_items - 1 do
		local item = items[i]
		if not item then
			break
		end

		local name, value = item[1], item[2]

		if item.todo then
			context:selectFontFace(FONT_FACE, 1)
		else
			context:selectFontFace(FONT_FACE)
		end

		context:setSourceRGB(255, 255, 255)

		if selected == i then
			context:rectangle(x, y,
				item_width, fe.height)
			context:fill()

			context:setSourceRGB(0, 0, 0)
		end

		context:moveTo(x + PADDING, y + fe.height - fe.descent)
		context:showUnderlinedText(name, pattern)

		if type(value) == "table" then
			value = "=>"
		elseif type(value) == "string" then
			value = self.sheet:getProp(value, item.def)
		elseif type(value) == "function" then
			value = value(self.sheet)
		end

		local te = context:textExtents(value)

		context:moveTo(x + item_width - PADDING - te.width,
			y + fe.height - fe.descent)
		context:showText(value)

		y = y + fe.height
	end

	context:restore()
end


function Menu:filterItems(typeahead)
	local filtered = {}

	for i,item in ipairs(self.items) do
		local name = string.lower(item[1])

		local match = true
		for c in string.gmatch(typeahead, ".") do
			if not string.find(name, c) then
				match = false
				break
			end
		end

		if match then
			table.insert(filtered, item)
		end
	end

	return filtered
end


function Menu:promoteItem(item)
	for i,mitem in ipairs(self.items) do
		if mitem == item then
			table.remove(self.items, i)
			table.insert(self.items, 1, item)

			return true
		end
	end

	return false
end


function Menu:event(event)
	local items = self.filtered
	local selected = self.selected

	if event.type == "keypress" then
		if event.key == "<move_up>" then
			self.selected = selected - 1
			if self.selected < 1 then
				self.selected = #items
			end

		elseif event.key == "<move_down>" then
			self.selected = selected + 1
			if self.selected > #items then
				self.selected = 1
			end

		elseif event.key == "<move_left>" then
			return false

		elseif event.key == "<move_right>" or
			event.key == "=" then
			local item = items[selected]

			self:promoteItem(item)

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

			elseif type(item[3]) == "function" then
				-- create submenu/input
				return item[3](sheet, item)

			elseif type(item[2]) == "table" then
				-- display sub-menu
				if not item[2].title then
					item[2].title = item[1]
				end
				return Menu:new(self.sheet, item[2])
			end

			if type(item[2]) == "function" then
				-- custom function
				return item[2](self.sheet, value)

			elseif type(item[2]) == "string" then
				self.sheet:setProp(item[2], value)
			end
		else
			local str
			if event.key == "<delete>" then
				str = string.sub(self.typeahead, 1, #self.typeahead - 1)
			else
				str = self.typeahead .. event.key
			end

			local filtered = self:filterItems(str)

			if #filtered > 0 then
				self.filtered = filtered
				self.typeahead = str

				if selected > #filtered then
					self.selected = #filtered
				end
			end
		end
	end
end

return Menu
