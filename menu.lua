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

local MARGIN = 13
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
	{ "Open", todo = true },
	{ "Save", todo = true },
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
	number: range is in item.min, item.max
	cell: sheet cell [TODO]
	range: sheet range [TODO]
	function: custom input

--]]


function Menu:new(sheet, items)
	obj =  {
		sheet = sheet,
		menu = { {
			items = items,
			selected = 1,
			screentop = 1,
			typeahead = "",
		} },
	}

	setmetatable(obj, self)
	self.__index = self

	obj.menu[1].filtered = obj:filterItems(".")

	return obj
end


function Menu:draw(context, width, height)
	local menu = self.menu[1]
	local items = menu.filtered
	local selected = menu.selected

	context:save()
	context:setLineWidth(1)

	local y = (MARGIN / 2) + PADDING
	local x = MARGIN + PADDING

	-- title
	if menu.items.title then
		local title = string.upper(menu.items.title or "")

		context:selectFontFace(FONT_FACE)
		context:selectFontSize(FONT_SIZE - 4)
		local te = context:textExtents(title)

		context:rectangle(MARGIN - 1, MARGIN - PADDING - 1,
			te.width + PADDING * 2 + 2, te.height + PADDING * 2 + 2)
		context:setSourceRGB(0, 0, 0)
		context:fill()

		context:rectangle(MARGIN, MARGIN - PADDING,
			te.width + PADDING * 2, te.height + PADDING * 2)
		context:setSourceRGB(255, 255, 255)
		context:stroke()

		context:moveTo(x, y + te.height)
		context:showText(title)

		y = y + te.height + PADDING
	end

	-- body
	context:selectFontSize(FONT_SIZE)
	local fe = context:fontExtents()

	context:rectangle(MARGIN - 1, y - 1,
		width - MARGIN * 2 + 2, height - y - MARGIN + 2)
	context:setSourceRGB(0, 0, 0)
	context:fill()

	context:rectangle(MARGIN, y,
		width - MARGIN * 2, height - y - MARGIN)
	context:setSourceRGB(255, 255, 255)
	context:stroke()

	local visible_items = math.floor((height - y - MARGIN) / fe.height)

	if selected == 1 then
		menu.screentop = 1
	elseif selected == #items then
		menu.screentop = math.max(1, #items - visible_items + 1)
	elseif selected > menu.screentop + visible_items - 2 then
		menu.screentop = menu.screentop +
			(selected - (menu.screentop + visible_items - 2))
	elseif selected < menu.screentop + 1 then
		menu.screentop = menu.screentop -
			(menu.screentop - selected + 1)
	end

	-- scroll bar
	local item_width = width - MARGIN * 2
	if #items > visible_items then
		item_width = item_width - 6

		local bar_height = height - y - MARGIN
		local bar_len = ((visible_items - 1) / #items) * bar_height
		local bar_off = ((menu.screentop - 1) / #items) * bar_height

		context:moveTo(MARGIN + item_width, y)
		context:relLineTo(0, bar_height)
		context:stroke()

		context:moveTo(MARGIN + item_width + 3, y + 2 + bar_off)
		context:relLineTo(0, bar_len)
		context:setLineWidth(2)
		context:stroke()
	end

	local pattern = "^$"
	if #menu.typeahead > 0 then
		pattern = "[" .. menu.typeahead .. string.upper(menu.typeahead) .. "]+"
	end

	for i = menu.screentop, menu.screentop + visible_items - 1 do
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
			context:rectangle(MARGIN, y,
				item_width, fe.height)
			context:fill()

			context:setSourceRGB(0, 0, 0)
		end

		context:moveTo(x, y + fe.height - fe.descent)
		context:showUnderlinedText(name, pattern)

		if type(value) == "table" then
			value = "=>"
		elseif type(value) == "string" then
			value = self.sheet:getProp(value, item.def)
		elseif type(value) == "function" then
			value = value(self.sheet)
		end

		local te = context:textExtents(value)

		context:moveTo(x + item_width - PADDING * 2 - te.width,
			y + fe.height - fe.descent)
		context:showText(value)

		y = y + fe.height
	end

	context:restore()
end


function Menu:filterItems(typeahead)
	local filtered = {}

	for i,item in ipairs(self.menu[1].items) do
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
	local menu = self.menu[1]

	for i,mitem in ipairs(menu.items) do
		if mitem == item then
			table.remove(menu.items, i)
			table.insert(menu.items, 1, item)

			return true
		end
	end

	return false
end


function Menu:event(event)
	local menu = self.menu[1]
	local items = menu.filtered
	local selected = menu.selected

	if event.type == "keypress" then
		if event.key == "<move_up>" then
			menu.selected = selected - 1
			if menu.selected < 1 then
				menu.selected = #items
			end

		elseif event.key == "<move_down>" then
			menu.selected = selected + 1
			if menu.selected > #items then
				menu.selected = 1
			end

		elseif event.key == "<move_left>" then
			if #self.menu == 1 then
				return false
			end

			table.remove(self.menu, 1)

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
			end

			if type(item[2]) == "table" then
				-- display sub-menu
				table.insert(self.menu, 1, {
					items = item[2],
					selected = 1,
					screentop = 1,
					typeahead = "",
				})
				self.menu[1].items.title = item[1]
				self.menu[1].filtered = self:filterItems(".")

			elseif type(item[2]) == "function" then
				-- custom function
				return item[2](self.sheet, value)

			elseif type(item[2]) == "string" then
				self.sheet:setProp(item[2], value)
			end
		else
			local str
			if event.key == "<delete>" then
				str = string.sub(menu.typeahead, 1, #menu.typeahead - 1)
			else
				str = menu.typeahead .. event.key
			end

			local filtered = self:filterItems(str)

			if #filtered > 0 then
				menu.filtered = filtered
				menu.typeahead = str

				if selected > #filtered then
					menu.selected = #filtered
				end
			end
		end
	end

	return true
end

return Menu
