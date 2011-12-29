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

local Menu = require("input.menu")


Function = {}

local functions = {}

local newFunctions = false

function Function:isNewFunctions()
	return newFunctions
end

function Function:addFunction(def)
	table.insert(functions, def)
	newFunctions = true

	Menu:addItem(Menu.functionMenu, {
		def.name,
		function(sheet, val)
			if val then
				sheet:getView():event({
					type = "keypress",
					key = def.name
				})
				return true
			end
			return def.desc
		end,
	})
end

function Function:ifunctions()
	return ipairs(functions)
end

return Function
