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

--[[
  format:
	["key pressed"] = { "plain", "shifted", "alpha", "shifted alpha" }
	
	This is assumed to be for US qwerty keyboards for now.
--]]

return {

	F1 = { "<file>", false, false, false },
	F2 = { "<edit>", false, false, false },
	F3 = { "<view>", false, false, false },
	F4 = { "<function>", false, false, false },
	F5 = { "<app>", false, false, false },
	F6 = { "<setting>", false, false, false },

	["a"] = { "a", "A" },
	["b"] = { "b", "B" },
	["c"] = { "c", "C" },
	["d"] = { "d", "D" },
	["e"] = { "e", "E" },
	["f"] = { "f", "F" },
	["g"] = { "g", "G" },
	["h"] = { "h", "H" },
	["i"] = { "i", "I" },
	["j"] = { "j", "J" },
	["k"] = { "k", "K" },
	["l"] = { "l", "L" },
	["m"] = { "m", "M" },
	["n"] = { "n", "N" },
	["o"] = { "o", "O" },
	["p"] = { "p", "P" }, 
	["q"] = { "q", "Q" },
	["r"] = { "r", "R" },
	["s"] = { "s", "S" },
	["t"] = { "t", "T" },
	["u"] = { "u", "U" },
	["v"] = { "v", "V" },
	["w"] = { "w", "W" }, 
	["x"] = { "x", "X" },
	["y"] = { "y", "Y" },
	["z"] = { "z", "Z" },

	["0"] = { "0", ")", "0", ")" },
	["1"] = { "1", "!", "1", "!" },
	["2"] = { "2", "@", "2", "@" },
	["3"] = { "3", "#", "3", "#" },
	["4"] = { "4", "$", "4", "$" },
	["5"] = { "5", "%", "5", "%" },
	["6"] = { "6", "^", "6", "^" },
	["7"] = { "7", "&", "7", "&" },
	["8"] = { "8", "\195\151", "8", "\195\151" },
	["9"] = { "9", "(", "9", "(" },

	["Escape"] = { "<clear>", "<poweroff>", "<clear>", false },
	["period"] = { ".", ">"},
	["slash"] = { "\195\183", "?" }
	["space"] = { "\194\177", " ", " ", " " }, --plusminus 0xc2b1
	["BackSpace"] = { "<delete>", "<undo>", "<delete>", "<delete>" },
	["Return"] = { "<enter>", "=", "<enter>", "<enter>" },

	["Shift_L"] = { "<shift>", "<shift>", "<shift>", "<shift>" },
	["Shift_R"] = { "<shift>", "<shift>", "<shift>", "<shift>" },

	["Down"] = { "<down>", "<down>", "<down>", "<down>" },
	["Up"] = { "<up>", "<up>", "<up>", "<up>" },
	["Right"] = { "<right>", "<right>", "<right>", "<right>" },
	["Left"] = { "<left>", "<left>", "<left>", "<left>" },

	["grave"] = { "`", "~" },
	
	["Tab"] = { "<sym>", "<sym>", "<sym>", "<sym>" },

	["Control_L"] = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },
	["Control_R"] = { "<alpha>", "<alpha>", "<alpha>", "<alpha>" },

	["KP_End"] = { "1", false },
	["KP_Down"] = { "2", false },
	["KP_Next"] = { "3", false },
	["KP_Left"] = { "4", false },
	["KP_Begin"] = { "5", false },
	["KP_Right"] = { "6", false },
	["KP_Home"] = { "7", false },
	["KP_Up"] = { "8", false },
	["KP_Prior"] = { "9", false },
	["KP_Divide"] = { "", false },
	["KP_Multiply"] = { "\195\151", false }, -- multiply c397
	["KP_Divide"] = { "\195\183", false },  -- divide c3b7
	["KP_Enter"] = { "<enter>", false },
	
	-- do we need to support numlock and both number pad modes?
	["Num_Lock"] = { false, false },

	-- keyboard compatibility
	["equal"] = { "=", "+" },
	["bracketleft"] = { "[", "{" },
	["bracketright"] = { "]", "}" },
	["apostrophe"] = { "'", "\"", },
	["comma"] = { ",", "<" },
	["minus"] = { "-", "_" },
	["backslash"] = { "\\", "|" }, 
	["semicolon"] = { ";",":" },
	
	-- for the hardware demo keypad, the most keys are sent as alt modified
	-- so as to distinguish them from the standard qwerty keyboard
	
	["alt-a"] = { "<f1>", "<f7>", "a", "A" },
	["alt-b"] = { "<f2>", "<f8>", "b", "B" },
	["alt-c"] = { "<f3>", "<f9>", "c", "C" },
	["alt-d"] = { "<f4>", "<f10>", "d", "D" },
	["alt-e"] = { "<f5>", "<f11>", "e", "E" },
	["alt-f"] = { "<f6>", "<f12>", "f", "F" },
	["alt-g"] = { "sin(", "asin(", "g", "G" },
	["alt-h"] = { "cos(", "acos(", "h", "H" },
	["alt-i"] = { "tan(", "atan(", "i", "I" },
	["alt-j"] = { "ln(", "e(", "j", "J" },
	["alt-k"] = { "log10(", "^10,", "k", "K" },
	["alt-l"] = { "log2(", "^2,", "l", "L" },
	["alt-m"] = { "sqrt(", "sq(", "m", "M" },
	["alt-n"] = { "yx", "xrty", "n", "N" },
	["alt-o"] = { "1/", "!", "o", "O" },
	["alt-p"] = { "%", "\207\128", "p", "P" },  -- pi   0xcf80
	["alt-q"] = { "<cut>", "<m->", "q", "Q" },
	["alt-r"] = { "<copy>", "<m+>", "r", "R" },
	["alt-s"] = { "<paste>", "<mr>", "s", "S" },
	["alt-t"] = { "ee", ":", "t", "T" },
	["alt-u"] = { "(", "<", "u", "U" },
	["alt-v"] = { ")", ">", "v", "V" },
	["alt-w"] = { "\195\151", false, "w", "W" }, -- multiply c397
	["alt-x"] = { "\195\183", "\\", "x", "X" }, -- divide c3b7
	["alt-y"] = { "-", "\226\130\172", "y", "Y" }, -- euro 0xe282ac
	["alt-z"] = { "+", "'", "z", "Z" },

	["alt-0"] = { "0", "\"", "0", "\"" },
	["alt-1"] = { "1", "_", "1", "_" },
	["alt-2"] = { "2", "@", "2", "@" },
	["alt-3"] = { "3", "#", "3", "#" },
	["alt-4"] = { "4", "$", "4", "$" },
	["alt-5"] = { "5", ";", "5", ";" },
	["alt-6"] = { "6", "^", "6", "^" },
	["alt-7"] = { "7", "&", "7", "&" },
	["alt-8"] = { "8", "~", "8", "~" },
	["alt-9"] = { "9", "|", "9", "|" },

	["alt-Return"] = { "<enter>", "=" },
	["alt-period"] = { ".", ",", ".", "," },
	
}
