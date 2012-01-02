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

local mp = require("mp")

module(..., package.seeall)

local Menu = require("input.menu")

Plugin = {}

local functions = {}

local units = {}
local units_cast = {}
local units_cast_default = {}
local units_convert = {}

setmetatable(units_cast, {
	__index = function()
		return units_cast_default
	end })


local newPlugins = false

function Plugin:isNewPlugins()
	if newPlugins then
		newPlugins = false
		return true
	end
	return false
end


-- Functions

--[[
	TODO document
--]]
function Plugin:addFunction(def)
	table.insert(functions, def)
	newPlugins = true

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

	-- test cases
	if plugin_testcase then
		plugin_testcase[def.name .. "_test"] = function()
			plugin_testcase.check(def.name, def.test)
		end
	else
		def.test = nil
	end
end

function Plugin:ifunctions()
	-- sort functions for parsers, longest match first
	table.sort(functions, function(a, b)
		if #a.name == #b.name then
			return a.name < b.name
		end
		return #a.name > #b.name
	end)

	return ipairs(functions)
end


-- Units

local convertMenu = {
	title = "Convert"
}

Menu:addItem(Menu.unitMenu, {
	"Convert",
	submenu = convertMenu,
})

--[[
	TODO document
--]]
function Plugin:addUnit(def)
	table.insert(units, def)
	units[def.name] = def

	newPlugins = true

	Menu:addItem(Menu.unitMenu, {
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

	Menu:addItem(convertMenu, {
		def.name,
		function(sheet, val)
			if val then
				sheet:getView():event({
					type = "keypress",
					key = " in " .. def.name
				})
				return true
			end
			return def.desc
		end,
	})
end

--[[
	TODO document
--]]
function Plugin:addCast(def)
	newPlugins = true

	assert(units[def.unit1], "Unit not defined: " .. def.unit1)
	assert(units[def.unit2], "Unit not defined: " .. def.unit2)

	local key = def.unit1 .. "," .. def.unit2

	if def.op then
		if not rawget(units_cast, def.op) then
			rawset(units_cast, def.op, {})
		end
		units_cast[def.op][key] = def.cast
	else
		units_cast_default[key] = def.cast
	end
end

--[[
	TODO document
--]]
function Plugin:addConversion(def)
	newPlugins = true

	if type(def.from) ~= "table" then
		def.from = { def.from }
		def.convert = { def.convert }
		def.inverse = { def.inverse }
	end

	assert(units[def.to], "Unit not defined: " .. def.to)

	for i,from in ipairs(def.from) do
		local convert = def.convert[i]
		local inverse = def.inverse[i]

		assert(units[from], "Unit not defined: " .. from)

		if not units_convert[from] then
			units_convert[from] = {}
		end
		units_convert[from][def.to] = convert

		if inverse then
			if not units_convert[def.to] then
				units_convert[def.to] = {}
			end
			units_convert[def.to][from] = inverse
		end
	end

	-- test cases
	if plugin_testcase then
		plugin_testcase[def.to .. "_test"] = function()
			plugin_testcase.check(def.to, def.test)
		end
	end
end

function Plugin:iunits()
	-- sort units for parsers, longest match first
	table.sort(units, function(a, b)
		if #a.name == #b.name then
			return a.name < b.name
		end
		return #a.name > #b.name
	end)

	return ipairs(units)
end

function convert(value, unit)
	local lookup1, convert1, convert2

	lookup1 = units_convert[value:unit()]
	assert(lookup1, "Can't convert " .. value:unit())

	convert1 = lookup1[unit]
	if not convert1 then
		for key,value in pairs(lookup1) do
			convert2 = units_convert[key][unit]
			if convert2 then
				convert1 = value
				break
			end
		end
	end

	assert(convert1, "Can't convert " .. value:unit() .. " to " .. unit)

	if (type(convert1) == "string") then
		value = mp.mul(value, mp.new(convert1))
	elseif (type(convert1) == "function") then
		value = convert1(value, unit)
	end

	if (type(convert2) == "string") then
		value = mp.mul(value, mp.new(convert2))
	elseif (type(convert2) == "function") then
		value = convert2(value, unit)
	end

	value = mp.new(value, unit)
	return value
end


-- configure mplib
mp.cast = units_cast
mp.convert = convert

return Plugin
