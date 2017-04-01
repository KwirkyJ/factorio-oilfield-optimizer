local assertive = require 'lib.assertive'
local entities  = require 'entities'

local assertEq       = assertive.assertEquals
--local assertAlmostEq = assertive.assertAlmostEquals

local expected, actual



-- ==== TEST GET_TILES =======================================================

expected = {{-3, 5, 'm'}}
actual = {}
for x, y, char in entities['medium-pole'].get_tiles ({x=-3, y=5}) do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


assertEq (actual, expected)
expected = {{1533, 0, 's'}}
actual = {}
for x, y, char in entities['small-pole'].get_tiles ({x=1533, y=0}) do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


expected = {{14, 132, 'P'},
            {15, 132, 'P'},
            {16, 132, '^'},
            {14, 133, 'P'},
            {15, 133, '@'}, -- center/oifield indicator
            {16, 133, 'P'},
            {14, 134, 'P'},
            {15, 134, 'P'},
            {16, 134, 'P'}}
actual = {}
for x, y, char in entities['pumpjack'].get_tiles ({x=15, y=133, rot='^'}) do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


expected = {{14, 132, 'P'},
            {15, 132, 'P'},
            {16, 132, 'P'},
            {14, 133, 'P'},
            {15, 133, '@'},
            {16, 133, 'P'},
            {14, 134, '<'},
            {15, 134, 'P'},
            {16, 134, 'P'}}
actual = {}
for x, y, char in entities['pumpjack'].get_tiles ({x=15, y=133, rot='<'}) do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


expected = {{-1, 7, '#'},
            { 0, 7, '#'},
            {-1, 8, '#'},
            { 0, 8, '#'}}
actual = {}
for x, y, char in entities['substation'].get_tiles ({x=-0.5, y=7.5}) do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


expected = {{3, -5, '>'}}
actual = {}
for x, y, char in entities['pipe-to-ground'].get_tiles ({x=3, y=-5, rot='>'}) 
do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


expected = {{0, 0, '^'}}
actual = {}
for x, y, char in entities['pipe-to-ground'].get_tiles ({x=0, y=0, rot='^'}) 
do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)


expected = {{-1234, 54, '+'}}
actual = {}
for x, y, char in entities['pipe'].get_tiles ({x=-1234, y=54}) do
    actual[#actual+1] = {x, y, char}
end
assertEq (actual, expected)



print ("==== ENTITIES TESTS PASSED ====")

