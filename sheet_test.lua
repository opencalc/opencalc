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

require "lunit"

module("sheet_textcase", lunit.testcase, package.seeall)

local Sheet = require "sheet"


function cellIndex_test()
	row,col = Sheet:cellIndex("A1")
	assert_equal(1, row)
	assert_equal(1, col)

	row,col = Sheet:cellIndex("Z9")
	assert_equal(26, row)
	assert_equal(9, col)

	row,col = Sheet:cellIndex("AA10")
	assert_equal(27, row)
	assert_equal(10, col)

	row,col = Sheet:cellIndex("IV256")
	assert_equal(256, row)
	assert_equal(256, col)

	row,col = Sheet:cellIndex("AAA999")
	assert_equal(703, row)
	assert_equal(999, col)

	assert_error(function() Sheet:cellIndex() end)
	assert_error_match("Invalid cell address", function() Sheet:cellIndex("A") end)
	assert_error_match("Invalid cell address", function() Sheet:cellIndex("9") end)
end


function cellAddr_test()
	str = Sheet:cellAddr(1, 1)
	assert_equal("A1", str)

	str = Sheet:cellAddr(26, 9)
	assert_equal("Z9", str)

	str = Sheet:cellAddr(27, 10)
	assert_equal("AA10", str)

	str = Sheet:cellAddr(256, 256)
	assert_equal("IV256", str)

	str = Sheet:cellAddr(703, 999)
	assert_equal("AAA999", str)
end


function cellRel_test()
	str = Sheet:cellRel("A1", 1, 1)
	assert_equal("B2", str)

	str = Sheet:cellRel("C3", -1, 0)
	assert_equal("B3", str)

	str = Sheet:cellRel("C3", 0, 1)
	assert_equal("C4", str)

	str = Sheet:cellRel("C3", -10, -10)
	assert_equal("A1", str)

	str = Sheet:cellRel("B10", 0, -1)
	assert_equal("B9", str)
end


function rangeRel_test()
	str = Sheet:rangeRel("A1", 1, 1)
	assert_equal("A1:B2", str)

	str = Sheet:rangeRel("C3", -1, 0)
	assert_equal("C3:B3", str)

	str = Sheet:rangeRel("C3", 0, 1)
	assert_equal("C3:C4", str)

	str = Sheet:rangeRel("C3", -10, -10)
	assert_equal("C3:A1", str)
end


function getCursor_test()
	sheet = Sheet:new()

	assert_equal("A1", sheet:getCursor())

	sheet:setCursor("B2")
	assert_equal("B2", sheet:getCursor())

	sheet:setCursor(-1, 0)
	assert_equal("A2", sheet:getCursor())

	sheet:setCursor(0, -1)
	assert_equal("A1", sheet:getCursor())

	sheet:setCursor(-1, 0)
	assert_equal("A1", sheet:getCursor())

	sheet:setCursor(0, -1)
	assert_equal("A1", sheet:getCursor())

	sheet:setCursor(3, 3)
	assert_equal("D4", sheet:getCursor())
end


function getSize_test()
	sheet = Sheet:new()

	assert_match("A1", sheet:getSize())

	sheet:insertCell("test1", "Z99")
	assert_match("Z99", sheet:getSize())
end


function insertCell_test()
	sheet = Sheet:new()

	sheet:insertCell("test1", "A1")
	assert_match("test", sheet:getCell("A1"):value())

	sheet:setCursor("Z99")
	sheet:insertCell("test2")
	assert_match("test", sheet:getCell("Z99"):value())
end


function getCell_test()
	sheet = Sheet:new()

	-- empty row
	assert_false(sheet:getCell("A1"))

	-- empty column
	sheet:insertCell("test", "A1")
	assert_false(sheet:getCell("A2"))
end


function testsheet()
	local sheet = Sheet:new()

	sheet:insertCell(99, "A1")
	sheet:insertCell(99, "A2")
	sheet:insertCell(99, "A3")
	sheet:insertCell(99, "A4")
	sheet:insertCell(99, "A5")

	sheet:insertCell(99, "B1")
	sheet:insertCell(1, "B2")
	sheet:insertCell(2, "B3")
	sheet:insertCell(3, "B4")
	sheet:insertCell(99, "B5")

	sheet:insertCell("99", "C1")
	sheet:insertCell("4", "C2")
	-- C3 is sparse
	sheet:insertCell("6", "C4")
	sheet:insertCell("99", "C5")

	-- D1:D5 is sparse

	sheet:insertCell(99, "E1")
	sheet:insertCell(99, "E2")
	sheet:insertCell(99, "E3")
	sheet:insertCell(99, "E4")
	sheet:insertCell(99, "E5")

	sheet:insertCell("testing", "F1")
	sheet:insertCell("quote \"", "F2")
	sheet:insertCell("comma ,", "F3")
	sheet:insertCell("quotecomma \",\"", "F4")
	sheet:insertCell("=2+3", "F5")

	return sheet
end


function getCellRangeByCol_test()
	sheet = testsheet()

	f = sheet:getCellRangeByCol("B2:D4")
	assert_equal(1, f():value())
	assert_equal(2, f():value())
	assert_equal(3, f():value())
	assert_equal(4, f():value())
	assert_false(f())
	assert_equal(6, f():value())
	assert_false(f())
	assert_false(f())
	assert_false(f())
	assert_nil(f())

	f = sheet:getCellRangeByCol("D4:B2")
	assert_false(f())
	assert_false(f())
	assert_false(f())
	assert_equal(6, f():value())
	assert_false(f())
	assert_equal(4, f():value())
	assert_equal(3, f():value())
	assert_equal(2, f():value())
	assert_equal(1, f():value())
	assert_nil(f())

	f = sheet:getCellRangeByCol("B2")
	assert_equal(1, f():value())
	assert_nil(f())
end


function getCellRangeByRow_test()
	sheet = testsheet()

	f = sheet:getCellRangeByRow("B2:D4")

	assert_equal(1, f():value())
	assert_equal(4, f():value())
	assert_false(f())
	assert_equal(2, f():value())
	assert_false(f())
	assert_false(f())
	assert_equal(3, f():value())
	assert_equal(6, f():value())
	assert_false(f())
	assert_nil(f())

	f = sheet:getCellRangeByRow("D4:B2")

	assert_false(f())
	assert_equal(6, f():value())
	assert_equal(3, f():value())
	assert_false(f())
	assert_false(f())
	assert_equal(2, f():value())
	assert_false(f())
	assert_equal(4, f():value())
	assert_equal(1, f():value())
	assert_nil(f())

	f = sheet:getCellRangeByRow("B2")
	assert_equal(1, f():value())
	assert_nil(f())
end


function loadSaveCsv_test()
	sheet = testsheet()
	sheet:saveCsv("test.csv")

	sheet2 = Sheet:new()
	sheet2:loadCsv("test.csv")

	assert_match(sheet:getSize(), sheet2:getSize())

	f2 = sheet2:getCellRangeByCol("A1:" .. sheet2:getSize())
	for cell in sheet:getCellRangeByCol("A1:" .. sheet:getSize()) do
		cell2 = f2()

		if cell then
			assert_equal(cell:text(), cell2:text())
			assert_equal(cell:value(), cell2:value())
		else
			assert_equal(cell, cell2)
		end
	end
end


function recalc_test()
	sheet = Sheet:new()

	sheet:insertCell(2, "A1")
	sheet:insertCell(3, "A2")
	sheet:insertCell(4, "A3")

	sheet:insertCell("=A1*A2", "B1")
	assert_equal(6, sheet:getCell("B1"):value())

	sheet:insertCell("=A2*A3", "B2")
	assert_equal(12, sheet:getCell("B2"):value())

	sheet:insertCell("=B1+B2", "B3")
	assert_equal(18, sheet:getCell("B3"):value())

	sheet:insertCell(5, "A2")
	assert_equal(30, sheet:getCell("B3"):value())
end


function cyclicreference_test()
	sheet = Sheet:new()

	sheet:insertCell("=A3", "A1")
	sheet:insertCell("=A1", "A2")
	sheet:insertCell("=A2", "A3")

	assert_equal("!REF", sheet:getCell("A3"):value())
end


function propMenu_test()
	sheet = Sheet:new()

	assert_table(sheet:propMenu())
end

function pref_test()
	sheet = Sheet:new()

	assert_nil(sheet:getProp("test"))
	assert_equal("abc", sheet:getProp("test", "abc"))

	sheet:setProp("test", "xyz")
	assert_equal("xyz", sheet:getProp("test", "abc"))
end


function view_test()
	sheet = Sheet:new()

	assert_equal("view/basic", sheet:nextView(0))

	local view1 = sheet:getView()
	assert_function(view1.draw)

	sheet:addView("view/line")
	sheet:addView("view/pie")
	sheet:addView("view/bar")

	assert_equal("view/line", sheet:nextView())

	local view2 = sheet:getView()
	assert_function(view2.draw)
	assert_not_equal(view1, view2)

	assert_equal("view/bar", sheet:nextView(2))
	assert_equal("view/basic", sheet:nextView())
end


function dump_test()
	sheet = Sheet:new()

	sheet:insertCell(1, "A1")
	sheet:insertCell("test123", "A2")
	sheet:insertCell("=1+2", "B1")

	sheet:dump()
end
