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

local Plugin = require("plugin")

local uc_degree = "\194\176"
local uc_superscript_1 = "\194\185"
local uc_superscript_2 = "\194\178"
local uc_superscript_minus = "\226\129\187"

local meter_squared = "m" .. uc_superscript_2
local meter_per_second = "m·s" .. uc_superscript_minus .. uc_superscript_1


-- length

Plugin:addUnit({
	name = "km",
	desc = "Kilometer",
	type = "Length",
})

Plugin:addUnit({
	name = "m",
	desc = "Meter",
	type = "Length",
})

Plugin:addUnit({
	name = "cm",
	desc = "Centimeter",
	type = "Length",
})

Plugin:addUnit({
	name = "mm",
	desc = "Millimeter",
	type = "Length",
})

Plugin:addUnit({
	name = "µm",
	desc = "Micrometre",
	type = "Length",
})

Plugin:addUnit({
	name = "nm",
	desc = "Nanometre",
	type = "Length",
})

Plugin:addUnit({
	name = "mi",
	desc = "Mile",
	type = "Length",
})

Plugin:addUnit({
	name = "yd",
	desc = "Yard",
	type = "Length",
})

Plugin:addUnit({
	name = "ft",
	desc = "Foot",
	type = "Length",
})

Plugin:addUnit({
	name = "in",
	desc = "Inch",
	type = "Length",
})


-- time 

Plugin:addUnit({
	name = "s",
	desc = "Seconds",
	type = "Time",
})

-- area

Plugin:addUnit({
	name = meter_squared,
	desc = "Meter Squared",
	type = "Area",
})

-- temperature

Plugin:addUnit({
	name = "°C",
	desc = "Celsius",
	type = "Temperature",
})

Plugin:addUnit({
	name = "°K",
	desc = "Kelvin",
	type = "Temperature",
})

Plugin:addUnit({
	name = "°F",
	desc = "Fahrenheit",
	type = "Temperature",
})

-- speed

Plugin:addUnit({
	name = meter_per_second,
	desc = "Meters per Second",
	type = "Speed",
})

-- angle

Plugin:addUnit({
	name = "°",
	desc = "Degree",
	type = "Angle",
})

Plugin:addUnit({
	name = "rad",
	desc = "Radian",
	type = "Angle",
})

Plugin:addUnit({
	name = "g",
	desc = "Grads",
	type = "Angle",
})



-- conversions

Plugin:addConversion({
	from = {
		 "nm", "µm", "mm", "cm", "km",
		 "in", "ft", "yd", "mi"
	},
	to = "m",
	convert = {
		"0.000000001", "0.000001", "0.001", "0.01", "1000",
		"0.0254", "0.3048", "0.9144", "1609.344"
	},
	inverse = {
		"1000000000", "100000", "1000", "100", "0.001",
		"39.3700787402", "3.28083989501", "1.09361329834", "6.2137119224e-4"
	},
	test = {
		"1000000000nm in m == 1m",
		"1000000µm in m == 1m",
		"1000mm in m == 1m",
		"100cm in m == 1m",
		"1000mm in m == 1m",
		"1km in m == 1000m",
		"1cm in mm == 10mm",
		"10mm in cm == 1cm",

		"10in in m == 0.254m",
		"10ft in m == 3.048m",
		"10yd in m == 9.144m",
		"10mi in m == 16093.44m",

		"1m in in == 39.37007874in",
		"1m in ft == 3.280839895ft",
		"1m in yd == 1.0936132983yd",
		"1000m in mi == 0.62137119224mi",
	},
})

Plugin:addConversion({
	from = { "in", "ft", "mi" },
	to = "yd",
	convert = { "2.7777777778e-2", "3.33333333333e-1", "1760" },
	inverse = { "36", "3", "5.68181818182e-04" },
	test = {
		"12in in ft == 1ft",
		"1ft in in == 12in",
		"3ft in yd == 1yd",
		"1yd in ft == 3ft",
		"1760yd in mi == 1mi",
		"1mi in yd == 1760yd",
	},
})

Plugin:addConversion({
	from = "°K",
	to = "°C",
	convert = function(a)
		return mp.sub(a,mp.new(273.15))
	end,
	inverse = function(a)
		return mp.add(a,mp.new(273.15))
	end,
	test = {
		"0°K in °C == -273.15°C",
		"0°C in °K == 273.15°K",
	},
})

Plugin:addConversion({
	from = "°F",
	to = "°C",
	convert = function(a)
 		return mp.mul(mp.div(mp.new(5),mp.new(9)),mp.sub(a,mp.new(32)))
	end,
	inverse = function(a)
		return mp.add(mp.mul(a,mp.div(mp.new(9),mp.new(5))),mp.new(32))
	end,
	test = {
		"0°F in °C == -17.777777778°C",
		"100°F in °C == 37.777777778°C",
		"0°C in °F == 32°F",
		"100°C in °F == 212°F",
	},
})

Plugin:addConversion({
	from = "°",
	to = "rad",
	convert = function(a)
		return mp.mul(a,mp.div(mp.pi(),mp.new("180")))
	end,
	inverse = function(a)
		return mp.mul(a,mp.div(mp.new("180"),mp.pi()))
	end,
	test = {
		"0° in rad == 0rad",
		"30° in rad == (π÷6) + 0rad",
		"45° in rad == (π÷4) + 0rad",
		"60° in rad == (π÷3) + 0rad",
		"90° in rad == (π÷2) + 0rad",
		"180° in rad == π + 0rad",
		"360° in rad == 2×π + 0rad",
		"0rad in ° == 0°",
		"((π÷6) + 0rad) in ° == 30°",
		"((π÷4) + 0rad) in ° == 45°",
		"((π÷3) + 0rad) in ° == 60°",
		"((π÷2) + 0rad) in ° == 90°",
		"(π + 0rad) in ° == 180°",
		"(2×π + 0rad) in ° == 360°",
	}
})

Plugin:addConversion({
	from = "g",
	to = "rad",
	convert = function(a)
		return mp.mul(a,mp.div(mp.pi(),mp.new("200")))
	end,
	inverse = function(a)
		return mp.mul(a,mp.div(mp.new("200"),mp.pi()))
	end,
	test = {
		"0g in rad == 0rad",
		"(100g÷3) in rad == (π÷6) + 0rad",
		"50g in rad == (π÷4) + 0rad",
		"(200g÷3) in rad == (π÷3) + 0rad",
		"100g in rad == (π÷2) + 0rad",
		"200g in rad == π + 0rad",
		"400g in rad == 2×π + 0rad",
		"0rad in g == 0g",
		"((π÷6) + 0rad) in g == (100g÷3)",
		"((π÷4) + 0rad) in g == 50g",
		"((π÷3) + 0rad) in g == (200g÷3)",
		"((π÷2) + 0rad) in g == 100g",
		"(π + 0rad) in g == 200g",
		"(2×π + 0rad) in g == 400g",
	}
})


-- multiply casts
Plugin:addCast({
	op = "mul",
	unit1 = "m",
	unit2 = "mm",
	cast = { meter_squared, "m", "m" },
	test = { "TODO", "TODO" },
})

Plugin:addCast({
	op = "mul",
	unit1 = "m",
	unit2 = "cm",
	cast = { meter_squared, "m", "m" },
	test = { "TODO", "TODO" },
})

Plugin:addCast({
	op = "mul",
	unit1 = "mm",
	unit2 = "m",
	cast = { meter_squared, "m", "m" },
	test = { "TODO", "TODO" },
})

Plugin:addCast({
	op = "mul",
	unit1 = "cm",
	unit2 = "m",
	cast = { meter_squared, "m", "m" },
	test = { "TODO", "TODO" },
})

Plugin:addCast({
	op = "mul",
	unit1 = "m",
	unit2 = "m",
	cast = { meter_squared, "m", "m" },
	test = { "TODO", "TODO" },
})

Plugin:addCast({
	op = "mul",
	unit1 = "m",
	unit2 = "s",
	cast = { meter_per_second, "m", "s" },
	test = { "TODO", "TODO" },
})

-- divide casts

Plugin:addCast({
	op = "div",
	unit1 = meter_squared,
	unit2 = "m",
	cast = { "m", meter_squared, "m" },
	test = { "TODO", "TODO" },
})

Plugin:addCast({
	op = "div",
	unit1 = meter_per_second,
	unit2 = "s",
	cast = { "m", meter_per_second, "s" },
	test = { "TODO", "TODO" },
})
