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

local lpeg = require("lpeg")
local mp = require("mp")

local Function = require("function")
local Menu = require("input.menu")


local P, R, S, V, C, Cb, Cc, Cg, Ct = lpeg.P, lpeg.R, lpeg.S, lpeg.V, lpeg.C, lpeg.Cb, lpeg.Cc, lpeg.Cg, lpeg.Ct

-- grammer
local G = false

local function token(id, patt)
	return Ct(Cc(id) * C(patt))
end

function compile(self)
	if G and not Function:isNewFunctions() then
		return
	end

	-- Lexical Elements
	local Space = S(" \n\t")^0
	local Open = "(" * Space
	local Close = ")" * Space
	local Comma = "," * Space

	-- Number
	local Number = token("num",
		S"+-"^-1 * R"09"^1 * P"." * R"09"^1 * P"e" * S"+-"^-1* R"09"^1 +
	 	S"+-"^-1 * R"09"^1 * P"e" * S"+-"^-1 * R"09"^1 +
		S"+-"^-1 * R"09"^1 * P"." * R"09"^1 +
	 	S"+-"^-1 * R"09"^1
	) * Space

	-- Cell address
	local Column = R"AZ"^1
	local Row = R"09"^1

	local Cell =
		Column * Row +
	      	"$" * Column * Row +
      		Column * "$" * Row +
	      	"$" * Column * "$" * Row

	local CellAddr = token("addr",
		Cell
	) * Space

	local CellRange = token("range",
		Cell * ":" * Cell
	) * Space

	-- Functions
	local Func = {}
	for i, def in Function:ifunctions() do
		--print(def.name, def.call, def.args)

		local idx = def.args
		if Func[idx] then
			Func[idx] = Func[idx] + P(def.name) / def.call
		else
			Func[idx] = P(def.name) / def.call
		end
	end

	for i = 0, 2 do
		if Func[i] then
			Func[i] = ( Func[i]) * Space
		else
			Func[i] = lpeg.P(false)
		end
	end

	-- Operators
	local FactorOp = (
		P"+" / "mp.add" +
		P"-" / "mp.sub"
	) * Space

	local TermOp = (
		P"\195\151" / "mp.mul" +
		P"\195\183" / "mp.div"
	) * Space

	-- Grammar
	local Exp, Term, Factor, Function = V("Exp"), V("Term"), V("Factor"), V("Function")
	G = P{Exp;
		Exp =
			Cg(Factor, "x") * Cg(FactorOp, "f") * Cg(Exp, "y") * Ct(Cb"f" * Cb"x" * Cb"y") +
			Factor,
		Factor =
 			Cg(Function, "x") * Cg(TermOp, "f") * Cg(Factor, "y") * Ct(Cb"f" * Cb"x" * Cb"y") +
 			Function,
		Function =
			Cg(Term, "x") * Cg(Func[1], "f") * Ct(Cb"f" * Cb"x") +
			Cg(Term, "x") * Cg(Func[2], "f") * Cg(Function, "y") * Ct(Cb"f" * Cb"x" * Cb"y") +
			Term,
		Term =
			Ct(Func[0]) +
  			Number +
			CellRange +
			CellAddr +
			Open * Exp * Close
	}

	G = Space * G * -1
end


function eval(sheet, f, t)
	if (type(t[1]) == "table") then
		for i = 1, #t do
			eval(sheet, f, t[i])
		end
	else
		if (t[1] == "num") then
	 		table.insert(f, "mp.new('")
			table.insert(f, t[2])
			table.insert(f, "')")

		elseif (t[1] == "addr") then
			local row, col = sheet:cellIndex(t[2])

			table.insert(f, "_s.cells[")
	 		table.insert(f, row)
	 		table.insert(f, "][")
	 		table.insert(f, col)
	 		table.insert(f, "]:value()")

		elseif (t[1] == "range") then
			table.insert(f, '"')
			table.insert(f, t[2])
			table.insert(f, '"')

		else
 			table.insert(f, t[1])
 			table.insert(f, "(")
			for i = 2, #t do
				eval(sheet, f, t[i])
	 			table.insert(f, ",")
			end
 			table.insert(f, "_s,_c)")
		end
	end
end


function parse(self, sheet, row, col, text)
	local t = lpeg.match(G, text)
  	if not t then
  		return text
	end

	local f = {"local _s,_c = ... return "}
	eval(sheet, f, t)
--print(text, table.concat(f))
	local f, err = loadstring(table.concat(f))

	return nil, f or err
end
