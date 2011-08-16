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

require "lunit"

module("mp_textcase", lunit.testcase, package.seeall)

local mp = require("mp")

function assert_mp(expected, actual)
	local expected = mp.new(expected)

	assert_true(mp.abs(expected - actual) < mp.new(1E+10),
		"expected " .. tostring(expected) .. " got " .. tostring(actual))
end

function expr_test()
	mp.set_prec(104)

	-- test from http://www.thimet.de/CalcCollection/Calc-Precision.html
	assert_mp("+5.555555555555555556E+0", mp.new(100) / mp.new(18))
	assert_mp("+4.444444444444444444E+0", mp.new(40) / mp.new(9))
	assert_mp("+3.086419135802500000E+13", mp.new(5555555) * mp.new(5555555))  
	assert_mp("+4.450000000000000000E+0", mp.new(40) / mp.new(9) + mp.new(50) / mp.new(9000 ))
	assert_mp("+1.414213562373095049E+3", mp.sqrt(mp.new(2E6)))
	assert_mp("+1.005012520859401063E+0", mp.exp(mp.new(0.005)))
	assert_mp("+2.718279110178575917E+0", mp.exp(mp.new(0.999999)))
	assert_mp("+2.718284546742232836E+0", mp.exp(mp.new(1.000001)))
	--assert_mp("+2.688117141816135448E+43", mp.exp(mp.new(100)))
	assert_mp("-1.381551055796427410E+1", mp.log(mp.new(1E-6)))
	assert_mp("-5.001250416822979193E-4", mp.log(mp.new(0.9995)))
	assert_mp("+4.998750416510479141E-4", mp.log(mp.new(1.0005)))
	assert_mp("+1.011579454259898524E+0", mp.exp10(mp.new(0.005)))
	assert_mp("+9.999769744141629304E+0", mp.exp10(mp.new(0.99999)))
	assert_mp("+1.000023026116026881E+1", mp.exp10(mp.new(1.00001)))
	--assert_mp("+1.258925411794167210E+80", mp.exp10(mp.new(80.1)))
	assert_mp("-7.698970004336018805E+0", mp.log10(mp.new(2E-8)))
	assert_mp("-2.172015458642557997E-4", mp.log10(mp.new(0.9995)))
	assert_mp("+2.170929722302082819E-4", mp.log10(mp.new(1.0005)))
	assert_mp("+6.000043427276862670E+0", mp.log10(mp.new(1000100)))
	assert_mp("+1.099511627776000000E+12", mp.new(2)^mp.new(40))
	assert_mp("+2.718856483813477575E+0", mp.new(2)^mp.new(1.443))
	assert_mp("+2.718280469319376884E+0", mp.new(1.000001)^mp.new(1E6))
	assert_mp("+9.999833334166664683E-3", mp.sin(mp.new(0.01)))
	assert_mp("+8.414709848078965067E-1", mp.sin(mp.new(1)))
	assert_mp("+9.999500371413582332E-1", mp.sin(mp.new(1.5608)))
	assert_mp("+8.939696481970214179E-1", mp.sin(mp.new(800)))
	assert_mp("+1.000033334666720637E-2", mp.tan(mp.new(0.01)))
	assert_mp("+1.557407724654902231E+0", mp.tan(mp.new(1)))
	assert_mp("-2.722418084073540959E+5", mp.tan(mp.new(1.5708)))
	assert_mp("-1.994900160845839293E+0", mp.tan(mp.new(800)))
	assert_mp("+1.000016667416711313E-2", mp.asin(mp.new(0.01)))
	assert_mp("+5.235987755982988731E-1", mp.asin(mp.new(0.5)))
	assert_mp("+1.526071239626163188E+0", mp.asin(mp.new(0.999)))
	assert_mp("+1.566324187113108692E+0", mp.asin(mp.new(0.99999)))
	assert_mp("+9.999666686665238206E-3", mp.atan(mp.new(0.01)))
	assert_mp("+7.853481608973649763E-1", mp.atan(mp.new(0.9999)))
	assert_mp("+7.854481608975316429E-1", mp.atan(mp.new(1.0001)))
	assert_mp("+1.570696326795229953E+0", mp.atan(mp.new(1E4)))

--[[
+1.745329243133368033E-4 sin(0.01 deg)
+7.660444431189780352E-1 sin(50 deg)
+9.999984769132876988E-1 sin(89.9 deg)
-6.427876096865393263E-1 sin(5000 deg)
+1.745329269716252907E-4 tan(0.01 deg)
+1.191753592594209959E+0 tan(50 deg)
+5.729577893130590236E+3 tan(89.99 deg)
-8.390996311772800118E-1 tan(5000 deg)
+5.729673448571526491E-1 asin(0.01 deg)
+3.000000000000000000E+1 asin(0.5 deg)
+8.743744126687686209E+1 asin(0.999 deg)
+8.974376527084057279E+1 asin(0.99999 deg)
+5.729386976834859268E-1 atan(0.01 deg)
+4.499713506778012245E+1 atan(0.9999 deg)
+4.500286464574097998E+1 atan(1.0001 deg)
+8.999427042206779036E+1 atan(1E4 deg)
--]]

end


function comp_test()
	mp.set_prec(52)

	assert_true(mp.new(5) == mp.new(5))
	assert_false(mp.new(5) == mp.new(6))

	assert_true(mp.new(4) <= mp.new(5))
	assert_true(mp.new(5) <= mp.new(5))
	assert_false(mp.new(6) <= mp.new(5))

	assert_true(mp.new(4) < mp.new(5))
	assert_false(mp.new(5) < mp.new(5))
	assert_false(mp.new(6) < mp.new(5))

	assert_false(mp.new(4) > mp.new(5))
	assert_false(mp.new(5) > mp.new(5))
	assert_true(mp.new(6) > mp.new(5))

	assert_false(mp.new(4) >= mp.new(5))
	assert_true(mp.new(5) >= mp.new(5))
	assert_true(mp.new(6) >= mp.new(5))
end

function prec_test()
	mp.set_prec(2)
	assert_equal(2, mp.set_prec())
	assert_equal(mp.new("1024"), mp.new("1000") + mp.new("1"))

	mp.set_prec(8)
	assert_equal(8, mp.set_prec())
	assert_equal(mp.new("1001"), mp.new("1000") + mp.new("1"))
end
