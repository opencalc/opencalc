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
	desc = "Constant \207\128",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "cos",
	call = "mp.cos",
	args = 1,
	desc = "Cosine",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "acos",
	call = "mp.acos",
	args = 1,
	desc = "Arc Cosine",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "sin",
	call = "mp.sin",
	args = 1,
	desc = "Sine",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "asin",
	call = "mp.asin",
	args = 1,
	desc = "Arc Sine",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "tan",
	call = "mp.tan",
	args = 1,
	desc = "Tan",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "atan",
	call = "mp.atan",
	args = 1,
	desc = "Arc Tan",
	test = { "TODO", "TODO" },
})

function function_10powx(x)
	return mp.pow(mp.new(10), x)
end

Function:addFunction({
	name = "x^10",
	call = "function_10powx",
	args = 1,
	desc = "Power 10",
	test = { "TODO", "TODO" },
})

function function_2powx(x)
	return mp.pow(mp.new(2), x)
end

Function:addFunction({
	name = "2^x",
	call = "function_2powx",
	args = 1,
	desc = "Two power",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "e",
	call = "mp.exp",
	args = 1,
	desc = "Exponential",
	test = { "TODO", "TODO" },
})

function function_1divx(x)
	return mp.div(mp.new(1), x)
end

Function:addFunction({
	name = "\194\185/",
	call = "function_1divx",
	args = 1,
	desc = "1/x",
	test = { "TODO", "TODO" },
})

function function_percent(x)
	return mp.div(x, mp.new(100))
end

Function:addFunction({
	name = "%",
	call = "function_percent",
	args = 1,
	desc = "Percent",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "^",
	call = "mp.pow",
	args = 2,
	desc = "Power",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "ln",
	call = "mp.log",
	args = 1,
	desc = "Natural Log",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "log10",
	call = "Log10",
	args = 1,
	desc = "Log10",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "log2",
	call = "mp.log2",
	args = 1,
	desc = "Log2",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "\226\136\154",
	call = "mp.sqrt",
	args = 1,
	desc = "Square Root",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "\194\178",
	call = "mp.sqr",
	args = 1,
	desc = "Squared",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "\226\129\191\226\136\154",
	call = "mp.root",
	args = 2,
	desc = "nth root",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "!",
	call = "mp.fac",
	args = 1,
	desc = "Factorial",
	test = { "TODO", "TODO" },
})

function function_e(x, y)
	return mp.mul(x, mp.pow(mp.new(10), y))
end

Function:addFunction({
	name = "E",
	call = "function_e",
	args = 2,
	desc = "Eng",
	test = { "TODO", "TODO" },
})

Function:addFunction({
	name = "\194\177",
	call = "mp.neg",
	args = 1,
	desc = "Negative",
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
	desc = "Sum range",
	test = { "TODO", "TODO" },
})
