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

local lfs = require("lfs")

local Menu = require("input.menu")
local Textinput = require("input.textinput")

local DATADIR = "data/"


Menu:addItem(Menu.fileMenu, {
	"New", submenu = {
		title = "New",
		{ "New spreadsheet",
			function(sheet, value)
				if not value then return end

				sheet:clear()
				return true
			end
		},
		{
			"Cancel",
			function() return true end
		},
	}
})

Menu:addItem(Menu.fileMenu, {
	"Open",
	function(sheet, value, item)
		if not value then return end

		sheet:load(DATADIR .. item.filename)
		return true
	end,
	filename = "",
	submenu = function(sheet, item)
		local items = {
			title = "Open " .. item.filename,
		}

		for name in lfs.dir(DATADIR .. item.filename) do repeat
			local filename = item.filename .. name

			if string.match(name, "^%.") then
				break
			end

			if lfs.attributes(DATADIR .. filename, "mode") == "directory" then
				table.insert(items, {
					name,
					item[2],
					filename = filename .. "/",
					submenu = item.submenu,
				})
				break
			end

			local name, ext = string.match(name, "^(.+)%.(...)$")
			if ext == "csv" or ext == "ocs" then
				table.insert(items, {
					name,
					item[2],
					filename = filename,
				})
			end
		until true end

		table.sort(items, function(a, b)
			return a[1] < b[1]
		end)

		return Menu:new(sheet, items)
	end
})

Menu:addItem(Menu.fileMenu, {
	"Save",
 	function(sheet, filename)
		if not filename then return end

		sheet:saveOcs(DATADIR .. filename)
		return true
	end, 
	submenu = function(sheet, item)
		return Textinput:new(sheet, item[1], item[2],
			sheet:getProp("name") or "", "^[a-zA-Z0-9%.]+$")
	end,
})

Menu:addItem(Menu.fileMenu, {
	"Delete",
	hidden = function(sheet)
		return sheet:getProp("name") == nil
	end,
	submenu = {
		title = "Delete",
		{
			function(sheet)
				return "Delete " .. sheet:getProp("name")
			end,
			function(sheet, value)
				if not value then return end

				os.remove(sheet:getProp("path"))
				sheet:clear()
				return true
			end
		},
		{
			"Cancel",
			function() return true end
		},
	}
})

Menu:addItem(Menu.fileMenu, {
	"Print", todo = true
})
