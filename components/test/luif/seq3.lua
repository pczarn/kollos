--[[
Copyright 2015 Jeffrey Kegler
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
--]]

-- Prototype the LUIF parser

local inspect = require 'kollos.inspect'
require 'Test.More'
-- luacheck: globals ok plan
plan(1)

-- luacheck: globals __LINE__ __FILE__

local K = require 'kollos'

local kollos = K.config_new{interface = 'alpha'}

ok(kollos, 'config_new() returned')

local l0 = kollos:grammar_new{ line = __LINE__, file = __FILE__,  name = 'l0' }
l0:line_set(__LINE__)
l0:rule_new{'top'}
l0:alternative_new{'one_open'}
l0:alternative_new{'one_closed'}
l0:alternative_new{'seven_fixed'}
l0:alternative_new{'seven_open'}
l0:alternative_new{'seven_closed'}
l0:line_set(__LINE__)
l0:rule_new{'one_open'}
l0:alternative_new{'b', 'c', max=-1 }
l0:line_set(__LINE__)
l0:rule_new{'one_closed'}
l0:alternative_new{'b', 'c', max=7 }
l0:line_set(__LINE__)
l0:rule_new{'seven_fixed'}
l0:alternative_new{'b', 'c', min=7, max=7 }
l0:rule_new{'seven_open'}
l0:alternative_new{'b', 'c', min=7, }
l0:rule_new{'seven_closed'}
l0:alternative_new{'b', 'c', min=7, max=11 }
l0:rule_new{'b'}
l0:alternative_new{l0:string'b'}
l0:rule_new{'c'}
l0:alternative_new{l0:string'c'}
l0:compile{ seamless = 'top', line = __LINE__}

-- print(inspect(l0))

-- vim: expandtab shiftwidth=4:
