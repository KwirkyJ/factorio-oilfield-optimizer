local layout    = require 'layout'
local assertive = require 'lib.assertive'

local assertEq = assertive.assertEquals

local expected, file, L, actual



---- set up entities module with sample elements -----------------------------

local entities = require 'entities'

entities.init ("pumpjack",
               {foot = {x=3, y=3},
                requires_power = true,
                is_source = true,
                pipe_rule = 'first',
                rotations = {
                    ['^'] = {
                        tiles = {{'P','P','^'},
                                 {'P','@','P'},
                                 {'P','P','P'}},
                        pipe_attachments = {{x=1, y=-2}}
                    },
                    ['>'] = {
                        tiles = {{'P','P','>'},
                                 {'P','@','P'},
                                 {'P','P','P'}},
                        pipe_attachments = {{x=2, y=-1}}
                    },
                    ['v'] = {
                        tiles = {{'P','P','P'},
                                 {'P','@','P'},
                                 {'v','P','P'}},
                        pipe_attachments = {{x=-1, y=2}}
                    },
                    ['<'] = {
                        tiles = {{'P','P','P'},
                                 {'P','@','P'},
                                 {'<','P','P'}},
                        pipe_attachments = {{x=-2, y=1}}
                    }}
               })
entities.init ('beacon', 
               {requires_power = true,
                bonus = {x=9, y=9},
                foot = {x=3, y=3},
                tiles = {{'B','B','B'},
                         {'B','*','B'},
                         {'B','B','B'}}
               })
entities.init ('big-pole', 
               {foot = {x=2, y=2},
                power = {area = {x=4,y=4},
                reach = 30},
                tiles = {{'T','T'},
                         {'T','T'}}
               })
entities.init ('substation', 
               {foot = {x=2, y=2},
                power = {area = {x=14,y=14},
                         reach = 14},
                tiles = {{'#','#'},
                         {'#','#'}}
               })
entities.init ('medium-pole', 
               {foot = {x=1, y=1},
                power = {area = {x=7,y=7},
                         reach = 9},
                tiles = {{'m'}}
               })
entities.init ('small-pole', 
               {foot = {x=1, y=1},
                power = {area = {x=7,y=7},
                         reach = 9},
                tiles = {{'m'}}
               })
entities.init ('pipe', 
               {foot = {x=1, y=1},
                pipe_rule = 'all',
                pipe_attachments = {{x= 0, y=-1},
                                    {x=-1, y= 0},
                                    {x= 1, y= 0},
                                    {x= 0, y= 1}},
                tiles = {{'+'}}
               })
entities.init ('pipe-to-ground', 
               {foot = {x=1, y=1},
                pipe_rule = 'first',
                rotations = {
                    ['^'] = {
                        tiles = {{'^'}},
                        pipe_attachments = {
                            {x=0, y=-1},
                            {x=0, y=-2},
                            {x=0, y=-3},
                            {x=0, y=-4},
                            {x=0, y=-5},
                            {x=0, y=-6},
                            {x=0, y=-7},
                            {x=0, y=-8},
                            {x=0, y=-9},
                            {x=0, y=-10}}
                    },
                    ['>'] = {
                        tiles = {{'>'}},
                        pipe_attachments = {
                            {x=1, y=0},
                            {x=2, y=0},
                            {x=3, y=0},
                            {x=4, y=0},
                            {x=5, y=0},
                            {x=6, y=0},
                            {x=7, y=0},
                            {x=8, y=0},
                            {x=9, y=0},
                            {x=10, y=0}}
                    },
                    ['v'] = {
                        tiles = {{'v'}},
                        pipe_attachments = {
                            {x=0, y=1},
                            {x=0, y=2},
                            {x=0, y=3},
                            {x=0, y=4},
                            {x=0, y=5},
                            {x=0, y=6},
                            {x=0, y=7},
                            {x=0, y=8},
                            {x=0, y=9},
                            {x=0, y=10}}
                    },
                    ['<'] = {
                        tiles = {{'<'}},
                        pipe_attachments = {
                            {x=-1, y=0},
                            {x=-2, y=0},
                            {x=-3, y=0},
                            {x=-4, y=0},
                            {x=-5, y=0},
                            {x=-6, y=0},
                            {x=-7, y=0},
                            {x=-8, y=0},
                            {x=-9, y=0},
                            {x=-10, y=0}}
                    }}
               })


-- ==== TEST CREATION ========================================================

expected = {grid = {},
            entities = {},
            insert = layout.insert,
            tofile = layout.tofile,}
actual = layout.new ()
assertEq (actual, expected)



-- ==== TEST INSERT ==========================================================

local pump = {x=5, y=-1, rot='v'}
expected = {grid = {[-2] = {[4] = pump, [5] = pump, [6] = pump},
                    [-1] = {[4] = pump, [5] = pump, [6] = pump},
                    [0]  = {[4] = pump, [5] = pump, [6] = pump}},
            entities = {['pumpjack'] = {[pump] = true}},
            x_min =  4,
            y_min = -2,
            x_max =  6,
            y_max =  0,
            insert = layout.insert,
            tofile = layout.tofile,}
L = layout.new ()
L:insert ('pumpjack', pump)
assertEq (L, expected)

local Bpol = {x=6.5, y=-3.5}
expected = {grid = {[-4] = {                        [6] = Bpol, [7] = Bpol},
                    [-3] = {                        [6] = Bpol, [7] = Bpol},
                    [-2] = {[4] = pump, [5] = pump, [6] = pump},
                    [-1] = {[4] = pump, [5] = pump, [6] = pump},
                     [0] = {[4] = pump, [5] = pump, [6] = pump}},
            entities = {['pumpjack'] = {[pump] = true},
                        ['big-pole'] = {[Bpol] = true}},
            x_min =  4,
            y_min = -4,
            x_max =  7,
            y_max =  0,
            insert = layout.insert,
            tofile = layout.tofile,}
L:insert ('big-pole', Bpol)
assertEq (L, expected)



local pole1 = {x= 3, y=4}
local pole2 = {x=-1, y=7}
expected = {grid = {[4] = {[3] = pole1},
                    [5] = {},
                    [6] = {},
                    [7] = {[-1] = pole2}},
            entities = {['medium-pole'] = {[pole1]=true, 
                                           [pole2]=true}},
            x_min = -1,
            y_min = 4,
            x_max = 3,
            y_max = 7,
            insert = layout.insert,
            tofile = layout.tofile}
L = layout.new ()
L:insert ("medium-pole", pole1)
L:insert ("medium-pole", pole2)
assertEq (L, expected)



---- test collisions ---------------------------------------------------------

pole2 = {x=3, y=4} 
for k, v in pairs (pole1) do
    assert (pole2[k] == v, "verify with code")
end
expected = {grid = {[4] = {[3] = pole1}},
            entities = {['medium-pole'] = {[pole1] = true}},
            x_min = 3,
            y_min = 4,
            x_max = 3,
            y_max = 4,
            insert = layout.insert,
            tofile = layout.tofile}
L = layout.new ()
assert (L:insert ("medium-pole", pole1), "insertion successful")
assert (not L:insert ("medium-pole", pole2), "insertion failed")
assertEq (L, expected)



-- pumpjack from before
Bpol = {x=6.5, y=0.5}
expected = {grid = {[-2] = {[4] = pump, [5] = pump, [6] = pump},
                    [-1] = {[4] = pump, [5] = pump, [6] = pump},
                    [0]  = {[4] = pump, [5] = pump, [6] = pump}},
            entities = {['pumpjack'] = {[pump] = true}},
            x_min =  4,
            y_min = -2,
            x_max =  6,
            y_max =  0,
            insert = layout.insert,
            tofile = layout.tofile,}
L = layout.new ()
assert (    L:insert ('pumpjack', pump))
assert (not L:insert ('big-pole', Bpol))
assertEq (L, expected)



-- ==== TEST TOFILE ==========================================================

L = layout.new (true)
L:insert ('pumpjack', {x=-1, y=-12, rot='^'})
L:insert ('pumpjack', {x= 3, y=-10, rot='<'})
L:insert ('pumpjack', {x=18, y=  5, rot='v'})

L:insert ('beacon', {x= -4, y=-17})
L:insert ('beacon', {x= -4, y=-14})
L:insert ('beacon', {x= -4, y=-11})
L:insert ('beacon', {x= -4, y= -8})
L:insert ('beacon', {x= -1, y=-17})
L:insert ('beacon', {x=  2, y=-17})
L:insert ('beacon', {x=  2, y=-14})
L:insert ('beacon', {x=  5, y=-14})
L:insert ('beacon', {x=  6, y=-11})
L:insert ('beacon', {x=  6, y= -8})
L:insert ('beacon', {x=  0, y= -7})
L:insert ('beacon', {x=  3, y= -7})
L:insert ('beacon', {x=  6, y= -5})
L:insert ('beacon', {x= 15, y=  1})
L:insert ('beacon', {x= 15, y=  4})
L:insert ('beacon', {x= 15, y=  7})
L:insert ('beacon', {x= 15, y= 10})
L:insert ('beacon', {x= 18, y=  1})
L:insert ('beacon', {x= 18, y=  9})
L:insert ('beacon', {x= 21, y=  1})
L:insert ('beacon', {x= 21, y=  4})
L:insert ('beacon', {x= 21, y=  7})
L:insert ('beacon', {x= 21, y= 10})

L:insert ('pipe', {x= 0, y=-15})
L:insert ('pipe', {x= 0, y=-14})
L:insert ('pipe', {x= 0, y= -9})
L:insert ('pipe', {x=-1, y=-15})
L:insert ('pipe', {x=-1, y= -9})
L:insert ('pipe', {x= 1, y= -9})

L:insert ('pipe-to-ground', {x=-1, y=-14, rot='v'})
L:insert ('pipe-to-ground', {x=-1, y=-10, rot='^'})
L:insert ('pipe-to-ground', {x=17, y= 11, rot='^'})
L:insert ('pipe-to-ground', {x=-8, y=-15, rot='>'})
L:insert ('pipe-to-ground', {x=17, y=  7, rot='v'})
L:insert ('pipe-to-ground', {x=-2, y=-15, rot='<'})

L:insert ('medium-pole', {x=-2, y=-10})
L:insert ('medium-pole', {x= 3, y= -5})
L:insert ('medium-pole', {x=18, y=  3})
L:insert ('medium-pole', {x=18, y=  7})

L:insert ('big-pole', {x= -6.5, y=-15.5})
L:insert ('big-pole', {x= 12.5, y=  3.5})

L:insert ('substation', {x=4.5, y=-16.5})

assertEq (L.x_min, -8)
assertEq (L.y_min,-18)
assertEq (L.x_max, 22)
assertEq (L.y_max, 11)

--       x= -8       0       8      6      2
expected = {"   BBBBBBBBB                   ", -- y=-18
            "   B*BB*BB*B##                 ",
            " TTBBBBBBBBB##                 ",
            ">TTBBB<++BBBBBB                ",
            "   B*B v+B*BB*B                ",
            "   BBBPP^BBBBBB                ",
            "   BBBP@P    BBB               ",
            "   B*BPPP PPPB*B               ",
            "   BBBm^  P@PBBB               ",
            "   BBB +++<PPBBB               ", -- y=-9
            "   B*B BBBBBBB*B               ",
            "   BBB B*BB*BBBB               ",
            "       BBBBBBBBB               ",
            "           m B*B               ",
            "             BBB               ",
            "                               ",
            "                               ",
            "                               ",
            "                      BBBBBBBBB", -- y= 0
            "                      B*BB*BB*B",
            "                      BBBBBBBBB",
            "                    TTBBB m BBB",
            "                    TTB*BPPPB*B",
            "                      BBBP@PBBB",
            "                      BBBvPPBBB",
            "                      B*Bvm B*B",
            "                      BBBBBBBBB",
            "                      BBBB*BBBB", -- y= 9
            "                      B*BBBBB*B",
            "                      BBB^  BBB"}
--       x= -8       0       8       6     1

file = io.tmpfile ()

L:tofile (file)

file:seek ('set')
actual = {}
for line in file:lines () do
    actual[#actual + 1] = line
end

assertEq (actual, expected)



print ("==== LAYOUT TEST PASSED ====")

