#!/usr/local/bin/lua

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

local Function = require("function")


Function:addFunction({
	name = "\207\128",
	call = "mp.pi",
	args = 0,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "cos",
	call = "mp.cos",
	args = 1,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "sin",
	call = "mp.sin",
	args = 1,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "tan",
	call = "mp.tan",
	args = 1,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "^",
	call = "mp.pow",
	args = 2,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "rand",
	call = "mp.urandom",
	args = 0,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})

function function_sum(range, sheet, cell)
	local val = mp.new(0)
	for v in sheet:getCellRangeByCol(range) do
		val = val + v:value()
	end
	return val
end

Function:addFunction({
	name = "sum",
	call = "function_sum",
	args = 1,
	desc = "TODO ...",
	test = { "TODO", "TODO" },
})
