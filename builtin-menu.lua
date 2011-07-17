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

		sheet:loadCsv(DATADIR, item.filename)
		return true
	end,
	submenu = function(sheet, item)
		local items = {
			title = "Open",
		}

		for filename in lfs.dir(DATADIR) do
			if not string.match(filename, "^%.") then
				table.insert(items, {
					filename,
					item[2],
					filename = filename,
				})
			end
		end
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

		sheet:saveCsv(DATADIR, filename)
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

				os.remove(sheet:getProp("filename"))
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
