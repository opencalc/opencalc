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

-- simple parser for bringup

local Menu = require("input.menu")


-- TODO function menu, this does not belong here
local fnmenu = function(str)
	return function(sheet, val)
		if val then
			local view = sheet:getView()
			view:event({ type = "keypress", key = str })
			return true
		end
	end
end
table.insert(Menu.functionMenu, { "Cos", fnmenu("cos(") })
table.insert(Menu.functionMenu, { "Rand", fnmenu("rand(") })
table.insert(Menu.functionMenu, { "Sin", fnmenu("sin(") })
table.insert(Menu.functionMenu, { "Sum", fnmenu("sum(") })
table.insert(Menu.functionMenu, { "Tan", fnmenu("tan(") })


function func_sum(_s, _c, range)
	local val = 0
	for v in _s:getCellRangeByCol(range) do
		val = val + v:value()
	end
	return val
end


function parser_toy(sheet, row, col, text)
	local val = tonumber(text)
	if val then
		return val
	end

	local eq = false
	if string.match(text,"^%s*=") then
		eq = string.match(text, "^%s*=%s*(.*)")
	elseif string.match(text, "=%s*$") then
		eq = string.match(text, "(.*)=")
	else
		return text
	end

	eq = string.gsub(eq, "\195\151", "*")
	eq = string.gsub(eq, "\195\183", "/")

	for addr, range in string.gmatch(eq, "(%u+%d+)(:?%u*%d*)") do
		if range == "" then
			local row, col = sheet:cellIndex(addr)
			eq = string.gsub(eq, addr, "(_s.cells["..row.."]["..col.."]):value()")
		else
			eq = string.gsub(eq, addr..range, "_s,_c,\""..addr..range.."\"")
		end
	end

	eq = string.gsub(eq, "sin", "math.sin")
	eq = string.gsub(eq, "cos", "math.cos")
	eq = string.gsub(eq, "tan", "math.tan")
	eq = string.gsub(eq, "rand", "math.random")
	eq = string.gsub(eq, "sum", "func_sum")


	--print("eq=" .. text .. " => " .. eq)

	local f, err = loadstring("local _s,_c = ...; return " .. eq)

	return nil, f or err
end
